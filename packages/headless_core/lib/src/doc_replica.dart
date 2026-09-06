import 'package:universal_storage_convergence/universal_storage_convergence.dart';

import 'document_node.dart';
import 'fractional_order.dart';

/// Doc↔op layer over the convergence kernel — the ADR 0005 §2 op-mapping
/// table, v1 (last_answer side of infra ADR 0029's contract):
///
/// - Node/block fields → LWW `k: 'node/<nodeId>/<field>'` (values are
///   JSON strings — enums by `.name`, timestamps ISO-8601).
/// - Child order (blocks and child documents) → LWW
///   `k: 'order/<parentId>/<childId>'` with the fractional order key as
///   value (see `fractional_order.dart`); rebalancing is a last_answer
///   policy, never a kernel type.
/// - Block text (incl. streamed agent text) → RGA `k: 'text/<blockId>'`
///   via `RgaTextStrategy`.
///
/// One document = one [DocReplica]. The LWW namespace and the RGA
/// namespace fold in two sibling kernel `ConvergenceDoc`s sharing the
/// document id: `ConvergenceDoc` fixes a single merge strategy and its
/// serialization registry (`ConvergenceDoc.strategyFor`) knows only
/// kernel-registered strategies, so a composite dispatching strategy would
/// break the kernel `fromJson` round-trip. [applyRemote] routes incoming
/// ops by payload key prefix; a shared HLC watermark (fed through the
/// kernel's `lastIssued` seam) keeps op ids unique across both docs.
///
/// last_answer never merges by hand: fold, ordering, dedupe, and
/// serialization are entirely kernel-owned (ADR 0011 sub-star discipline).
final class DocReplica {
  DocReplica({required this.nodeId, required this.actorId})
    : _meta = ConvergenceDoc(docId: nodeId.value, actorId: actorId),
      _text = ConvergenceDoc(
        docId: nodeId.value,
        actorId: actorId,
        strategy: const RgaTextStrategy(),
      );

  DocReplica._(this._meta, this._text)
    : nodeId = NodeId(_meta.docId),
      actorId = _meta.actorId;

  /// Restores both kernel docs through `ConvergenceDoc.fromJson` plus the
  /// shared HLC watermark, so a restored replica keeps issuing strictly
  /// increasing op ids across both docs even on a frozen wall clock.
  factory DocReplica.fromJson(final Map<String, dynamic> json) {
    final meta = ConvergenceDoc.fromJson(
      Map<String, dynamic>.from(json['meta'] as Map<dynamic, dynamic>),
    );
    final text = ConvergenceDoc.fromJson(
      Map<String, dynamic>.from(json['text'] as Map<dynamic, dynamic>),
    );
    final replica = DocReplica._(meta, text);
    Hlc? last = json['last_issued'] == null
        ? null
        : Hlc.fromJson(
            Map<String, dynamic>.from(
              json['last_issued'] as Map<dynamic, dynamic>,
            ),
          );
    for (final op in replica.pendingOps) {
      if (op.actorId != replica.actorId) continue;
      if (last == null || op.hlc > last) last = op.hlc;
    }
    replica._lastIssued = last;
    return replica;
  }

  /// Key namespace for node/block field registers (LWW map).
  static const String nodeKeyPrefix = 'node/';

  /// Key namespace for fractional child order registers (LWW map).
  static const String orderKeyPrefix = 'order/';

  /// Key namespace for block text sequences (RGA).
  static const String textKeyPrefix = 'text/';

  /// Kernel replica for LWW data: node fields and fractional child order.
  final ConvergenceDoc _meta;

  /// Kernel replica for RGA block text sequences.
  final ConvergenceDoc _text;

  /// Highest HLC issued across BOTH kernel docs — passed into every
  /// `applyLocal` so the two docs never reuse a tick and op ids (derived
  /// from `docId#wall#counter#actor`) stay unique per document.
  Hlc? _lastIssued;

  /// The document this replica projects.
  final NodeId nodeId;
  final String actorId;

  // ---------------------------------------------------------------------------
  // Local edits (each returns the ops the caller must persist/gossip)
  // ---------------------------------------------------------------------------

  /// Issues the document's birth fields (`createdAt`/`updatedAt`).
  List<OpRecord> createNode({final DateTime? now}) {
    final at = now ?? DateTime.now();
    final iso = at.toUtc().toIso8601String();
    return [
      _issueField('createdAt', iso, at),
      _issueField('updatedAt', iso, at),
    ];
  }

  /// Writes a document-node field (`formatId`, `parentDocId`, `kind`,
  /// `status`, `spanSnapshot`, …) as an LWW op `node/<nodeId>/<field>`.
  /// Values are JSON strings.
  List<OpRecord> setNodeField(
    final String name, {
    required final String value,
    final DateTime? now,
  }) => [_issueField(name, value, now ?? DateTime.now())];

  /// Anchors this (child) document to a block of its parent
  /// (ADR 0001, block-granularity v1).
  List<OpRecord> setAnchor(final NodeId blockId, {final DateTime? now}) => [
    _issueField('anchorBlockId', blockId.value, now ?? DateTime.now()),
  ];

  /// Inserts [block] into the document's block order at [index] (null =
  /// append at the end) and issues LWW ops for every non-default block
  /// field plus one RGA text op when [Block.content] is non-empty.
  List<OpRecord> addBlock(
    final Block block, {
    final int? index,
    final DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final ops = _place(NodeId(nodeId.value), block.id, index: index, at: at);
    void field(final String name, final String value) {
      ops.add(_issueBlockField(block.id, name, value, at));
    }

    field('type', block.type.name);
    final level = block.level;
    if (level != null) field('level', '$level');
    final role = block.role;
    if (role != null) field('role', role.name);
    final messageId = block.messageId;
    if (messageId != null) field('messageId', messageId);
    final sessionId = block.sessionId;
    if (sessionId != null) field('sessionId', sessionId);
    final toolCallId = block.toolCallId;
    if (toolCallId != null) field('toolCallId', toolCallId);
    final title = block.title;
    if (title != null) field('title', title);
    if (block.status != MessageStatus.complete) {
      field('status', block.status.name);
    }
    if (block.content.isNotEmpty) {
      ops.add(
        _insertTextOp(
          block.id,
          block.content,
          after: _lastLiveElementId(block.id),
          at: at,
        ),
      );
    }
    return ops;
  }

  /// Orders [childId] under [parentId] at [index] (null = append). Works
  /// for both blocks inside this document (parentId = [nodeId]) and child
  /// documents. Emits one LWW op `order/<parentId>/<childId>` with a
  /// fractional key, or a full [freshKeys] rebalance set when no key fits
  /// between the neighbours.
  List<OpRecord> placeChild({
    required final NodeId parentId,
    required final NodeId childId,
    final int? index,
    final DateTime? now,
  }) => _place(parentId, childId, index: index, at: now ?? DateTime.now());

  /// Removes [blockId] from the document's order by tombstoning its order
  /// register (`del: true` — LWW deletes win forever, so the removal
  /// reaches replicas that never saw the value). Block fields and text
  /// stay until their own ops say otherwise; the projection drops the
  /// block as soon as its order entry is gone.
  List<OpRecord> removeBlock(final NodeId blockId, {final DateTime? now}) {
    final op = _meta.applyLocal(
      {'k': _orderKey(nodeId, blockId), 'del': true},
      now ?? DateTime.now(),
      lastIssued: _lastIssued,
    );
    _observeIssued(op.hlc);
    return [op];
  }

  /// Appends [text] at the end of [blockId]'s content, anchored after the
  /// last live RGA element (or the RGA root when the block is empty) —
  /// the streaming-agent-text path (ADR 0005 §2).
  List<OpRecord> appendText(
    final NodeId blockId,
    final String text, {
    final DateTime? now,
  }) {
    if (text.isEmpty) return const [];
    return [
      _insertTextOp(
        blockId,
        text,
        after: _lastLiveElementId(blockId),
        at: now ?? DateTime.now(),
      ),
    ];
  }

  /// Inserts [text] at visible character [offset]; offset 0 anchors on the
  /// RGA root. Throws [RangeError] when [offset] is outside
  /// `0..visibleLength`.
  ///
  /// Merge semantics are the kernel RGA's, not strictly positional:
  /// siblings of an anchor sort by `(Hlc, index)` ascending and traversal
  /// is depth-first, so an insert issued with a higher HLC than the chain
  /// following its anchor lands after that chain. Appends at the visible
  /// end ([appendText]) are the reliable streaming path; true positional
  /// mid-text inserts need kernel-side sibling-order support (tracked as
  /// a limitation in the ADR 0005 Phase 5 work).
  List<OpRecord> insertTextAt(
    final NodeId blockId,
    final int offset,
    final String text, {
    final DateTime? now,
  }) {
    if (text.isEmpty) return const [];
    final ids = _visibleElementIds(blockId);
    if (offset < 0 || offset > ids.length) {
      throw RangeError.range(offset, 0, ids.length, 'offset');
    }
    return [
      _insertTextOp(
        blockId,
        text,
        after: offset == 0 ? null : ids[offset - 1],
        at: now ?? DateTime.now(),
      ),
    ];
  }

  /// Deletes [length] visible characters from [offset] by tombstoning
  /// their RGA element ids in one op. Tombstones may reach replicas before
  /// the elements they reference — the kernel honors them whenever the
  /// element arrives.
  List<OpRecord> deleteTextRange(
    final NodeId blockId,
    final int offset,
    final int length, {
    final DateTime? now,
  }) {
    if (length <= 0) return const [];
    final ids = _visibleElementIds(blockId);
    if (offset < 0 || offset + length > ids.length) {
      throw RangeError.range(offset + length, 0, ids.length, 'offset + length');
    }
    final op = _text.applyLocal(
      {'k': _textKey(blockId), 'del': ids.sublist(offset, offset + length)},
      now ?? DateTime.now(),
      lastIssued: _lastIssued,
    );
    _observeIssued(op.hlc);
    return [op];
  }

  // ---------------------------------------------------------------------------
  // Remote delivery & projection
  // ---------------------------------------------------------------------------

  /// Folds remote ops into the owning kernel doc, routed by payload key
  /// prefix (`text/…` → RGA doc, everything else → LWW doc). Idempotent
  /// and delivery-order independent per the kernel contract. Returns how
  /// many ops were newly applied.
  int applyRemote(final Iterable<OpRecord> ops, {final DateTime? now}) {
    final textOps = <OpRecord>[];
    final metaOps = <OpRecord>[];
    for (final op in ops) {
      final k = op.payload['k'];
      if (k is String && k.startsWith(textKeyPrefix)) {
        textOps.add(op);
      } else {
        metaOps.add(op);
      }
    }
    var applied = 0;
    if (metaOps.isNotEmpty) applied += _meta.applyRemote(metaOps, now: now);
    if (textOps.isNotEmpty) applied += _text.applyRemote(textOps, now: now);
    if (applied > 0) _absorbRemoteClock(ops, now: now);
    return applied;
  }

  /// HLC receive rule: local ops issued after folding remote ones must
  /// order after them, even when the wall clock stands still (the kernel's
  /// `ConvergenceDoc` dedupes and folds but never ticks on receive, so
  /// the doc layer owns causality here via the kernel's `Hlc.receive`).
  /// The base always carries THIS replica's actor id — `Hlc.receive`
  /// keeps the receiver's actor, and adopting a remote-actor HLC here
  /// would make later local ops issue foreign op ids that collide with
  /// the remote's in dedupe.
  void _absorbRemoteClock(final Iterable<OpRecord> ops, {final DateTime? now}) {
    Hlc? maxRemote;
    for (final op in ops) {
      if (maxRemote == null || op.hlc > maxRemote) maxRemote = op.hlc;
    }
    if (maxRemote == null) return;
    final base = _lastIssued ?? Hlc.zero(actorId);
    if (base >= maxRemote) return; // watermark already covers the delivery
    _observeIssued(base.receive(maxRemote, now ?? DateTime.now()));
  }

  /// Rebuilds the document projection from folded kernel state.
  /// Deterministic: blocks in fractional-key order with ties broken by
  /// block id (concurrent writers landing the same key still converge to
  /// one projection), text via the kernel RGA traversal.
  DocumentNode document() {
    final blockIds = orderedChildren(nodeId.value);
    final blocks = <Block>[];
    for (final blockId in blockIds) {
      final id = NodeId(blockId);
      blocks.add(
        Block(
          id: id,
          type: _enumField(
            id,
            'type',
            BlockType.values,
            orElse: BlockType.paragraph,
          ),
          content: RgaTextStrategy.readText(_text.state, _textKey(id)) ?? '',
          level: _intField(id, 'level'),
          role: _optionalEnumField(id, 'role', ChatRole.values),
          messageId: _field(id, 'messageId'),
          sessionId: _field(id, 'sessionId'),
          toolCallId: _field(id, 'toolCallId'),
          title: _field(id, 'title'),
          status: _enumField(
            id,
            'status',
            MessageStatus.values,
            orElse: MessageStatus.complete,
          ),
        ),
      );
    }
    final anchorBlockId = _docField('anchorBlockId');
    final parentDocId = _docField('parentDocId');
    return DocumentNode(
      id: nodeId,
      kind: _docField('kind') ?? 'doc',
      formatId: _docField('formatId'),
      blocks: blocks,
      parentDocId: parentDocId == null ? null : NodeId(parentDocId),
      anchorSpan: anchorBlockId == null
          ? null
          : AnchorSpan(
              blockId: NodeId(anchorBlockId),
              prefixHash: _docField('anchorPrefixHash'),
              suffixHash: _docField('anchorSuffixHash'),
            ),
      status: _enumField(
        nodeId,
        'status',
        DocumentStatus.values,
        orElse: DocumentStatus.open,
      ),
      spanSnapshot: _docField('spanSnapshot'),
      createdAt: _timeField(nodeId, 'createdAt'),
      updatedAt: _timeField(nodeId, 'updatedAt'),
    );
  }

  /// Visible text of [blockId]; empty when the block has no RGA state.
  String blockText(final NodeId blockId) =>
      RgaTextStrategy.readText(_text.state, _textKey(blockId)) ?? '';

  /// Child ids of [parentId] ordered by fractional key (ties broken by
  /// child id). [parentId] is the plain id string (`nodeId.value`).
  List<String> orderedChildren(final String parentId) {
    final prefix = '$orderKeyPrefix$parentId/';
    final entries = <(String, String)>[];
    final state = _meta.state;
    for (final key in state.keys) {
      if (!key.startsWith(prefix)) continue;
      final value = LwwMapStrategy.readValue(state, key);
      if (value == null) continue; // tombstoned order entry
      entries.add((key.substring(prefix.length), value));
    }
    entries.sort((final x, final y) {
      final byKey = x.$2.compareTo(y.$2);
      if (byKey != 0) return byKey;
      return x.$1.compareTo(y.$1);
    });
    return [for (final entry in entries) entry.$1];
  }

  /// The fractional key currently registered for [childId] under
  /// [parentId]; null when absent or tombstoned.
  String? orderKeyOf(final NodeId parentId, final NodeId childId) =>
      LwwMapStrategy.readValue(_meta.state, _orderKey(parentId, childId));

  // ---------------------------------------------------------------------------
  // Introspection / persistence
  // ---------------------------------------------------------------------------

  /// Ops pending delta-shipping in both kernel docs.
  List<OpRecord> get pendingOps => [..._meta.pendingOps, ..._text.pendingOps];

  /// Version vector of the LWW kernel doc (anti-entropy header half 1).
  VersionVector get metaVersionVector => _meta.vv;

  /// Version vector of the RGA kernel doc (anti-entropy header half 2).
  VersionVector get textVersionVector => _text.vv;

  /// Full serialization for durable local persistence; both kernel docs
  /// serialize through the kernel (`ConvergenceDoc.toJson`).
  Map<String, dynamic> toJson() => {
    'doc_id': nodeId.value,
    'actor_id': actorId,
    if (_lastIssued != null) 'last_issued': _lastIssued!.toJson(),
    'meta': _meta.toJson(),
    'text': _text.toJson(),
  };

  // ---------------------------------------------------------------------------
  // Internals: op issuing
  // ---------------------------------------------------------------------------

  OpRecord _issueField(
    final String name,
    final String value,
    final DateTime at,
  ) => _issueMeta(_nodeKey(nodeId, name), value, at);

  OpRecord _issueBlockField(
    final NodeId blockId,
    final String name,
    final String value,
    final DateTime at,
  ) => _issueMeta(_nodeKey(blockId, name), value, at);

  OpRecord _issueMeta(final String key, final String value, final DateTime at) {
    final op = _meta.applyLocal(
      {'k': key, 'v': value},
      at,
      lastIssued: _lastIssued,
    );
    _observeIssued(op.hlc);
    return op;
  }

  OpRecord _insertTextOp(
    final NodeId blockId,
    final String text, {
    required final String? after,
    required final DateTime at,
  }) {
    final op = _text.applyLocal(
      {'k': _textKey(blockId), 'after': after, 'text': text},
      at,
      lastIssued: _lastIssued,
    );
    _observeIssued(op.hlc);
    return op;
  }

  void _observeIssued(final Hlc hlc) {
    final current = _lastIssued;
    if (current == null || hlc > current) _lastIssued = hlc;
  }

  static String _nodeKey(final NodeId id, final String field) =>
      '$nodeKeyPrefix${id.value}/$field';

  static String _orderKey(final NodeId parentId, final NodeId childId) =>
      '$orderKeyPrefix${parentId.value}/${childId.value}';

  static String _textKey(final NodeId blockId) =>
      '$textKeyPrefix${blockId.value}';

  // ---------------------------------------------------------------------------
  // Internals: fractional placement (last_answer policy, see
  // fractional_order.dart; infra ADR 0029 §2 keeps it out of the kernel)
  // ---------------------------------------------------------------------------

  List<OpRecord> _place(
    final NodeId parentId,
    final NodeId childId, {
    required final int? index,
    required final DateTime at,
  }) {
    final siblings = orderedChildren(
      parentId.value,
    ).where((final id) => id != childId.value).toList();
    final NodeId? after;
    String? bound;
    if (index == null || siblings.isEmpty) {
      after = siblings.isEmpty ? null : NodeId(siblings.last);
    } else {
      final i = index < 0
          ? 0
          : (index > siblings.length ? siblings.length : index);
      after = i == 0 ? null : NodeId(siblings[i - 1]);
      bound = i < siblings.length ? siblings[i] : null;
    }
    final key = fractionalBetween(
      after == null ? null : orderKeyOf(parentId, after),
      bound == null ? null : orderKeyOf(parentId, NodeId(bound)),
    );
    if (key != null) {
      return [_issueMeta(_orderKey(parentId, childId), key, at)];
    }
    // Rebalance: fresh evenly spaced keys for the whole sibling list with
    // [childId] at the requested position. Each child's key is its own LWW
    // register, so concurrent rebalances stay convergent (some registers
    // may end at either written key; ordering stays deterministic through
    // the (key, childId) tie-break).
    final insertIdx = index == null
        ? siblings.length
        : (index < 0 ? 0 : (index > siblings.length ? siblings.length : index));
    final desired = [...siblings]..insert(insertIdx, childId.value);
    final fresh = freshKeys(desired.length);
    final ops = <OpRecord>[];
    for (var i = 0; i < desired.length; i++) {
      final existing = orderKeyOf(parentId, NodeId(desired[i]));
      if (desired[i] == childId.value || fresh[i] != existing) {
        ops.add(
          _issueMeta(_orderKey(parentId, NodeId(desired[i])), fresh[i], at),
        );
      }
    }
    return ops;
  }

  // ---------------------------------------------------------------------------
  // Internals: RGA anchor resolution
  // ---------------------------------------------------------------------------

  /// Live (non-tombstoned) RGA element ids for [blockId] in visible-text
  /// order. Mirrors the kernel's documented `RgaTextStrategy.readText`
  /// traversal (root children, depth-first, siblings by `(Hlc, index)`);
  /// the conformance tests cross-check this against `RgaTextStrategy
  /// .readText` via [blockText].
  List<String> _visibleElementIds(final NodeId blockId) {
    final raw = _text.state[_textKey(blockId)];
    if (raw is! Map) return const [];
    final nodesRaw = raw['nodes'];
    if (nodesRaw is! Map) return const [];
    final tombRaw = raw['tomb'];
    final tomb = <String, bool>{
      if (tombRaw is Map)
        for (final entry in tombRaw.entries)
          entry.key as String: entry.value == true,
    };
    final children = <String?, List<MapEntry<String, Map<String, Object?>>>>{};
    nodesRaw.forEach((final id, final node) {
      final map = Map<String, Object?>.from(node as Map<dynamic, dynamic>);
      children
          .putIfAbsent(map['a'] as String?, () => [])
          .add(MapEntry(id as String, map));
    });
    for (final list in children.values) {
      list.sort((final x, final y) {
        final byHlc =
            hlcFromJson(
              Map<String, dynamic>.from(x.value['h']! as Map<dynamic, dynamic>),
            ).compareTo(
              hlcFromJson(
                Map<String, dynamic>.from(
                  y.value['h']! as Map<dynamic, dynamic>,
                ),
              ),
            );
        if (byHlc != 0) return byHlc;
        return (x.value['i']! as int).compareTo(y.value['i']! as int);
      });
    }
    final out = <String>[];
    void visit(final String? anchor) {
      for (final entry
          in children[anchor] ??
              const <MapEntry<String, Map<String, Object?>>>[]) {
        if (!(tomb[entry.key] ?? false)) out.add(entry.key);
        visit(entry.key);
      }
    }

    visit(null);
    return out;
  }

  String? _lastLiveElementId(final NodeId blockId) {
    final ids = _visibleElementIds(blockId);
    return ids.isEmpty ? null : ids.last;
  }

  // ---------------------------------------------------------------------------
  // Internals: projection field readers
  // ---------------------------------------------------------------------------

  String? _docField(final String name) => _field(nodeId, name);

  String? _field(final NodeId id, final String name) =>
      LwwMapStrategy.readValue(_meta.state, _nodeKey(id, name));

  int? _intField(final NodeId id, final String name) {
    final raw = _field(id, name);
    return raw == null ? null : int.tryParse(raw);
  }

  DateTime _timeField(final NodeId id, final String name) =>
      DateTime.tryParse(_field(id, name) ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  T _enumField<T extends Enum>(
    final NodeId id,
    final String name,
    final List<T> values, {
    required final T orElse,
  }) {
    final raw = _field(id, name);
    if (raw == null) return orElse;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return orElse;
  }

  T? _optionalEnumField<T extends Enum>(
    final NodeId id,
    final String name,
    final List<T> values,
  ) {
    final raw = _field(id, name);
    if (raw == null) return null;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}
