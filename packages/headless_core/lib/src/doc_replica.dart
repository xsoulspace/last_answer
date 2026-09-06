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
/// One document = ONE [ConvergenceDoc] with the kernel's
/// `CompositeMergeStrategy` (ADR 0030 §1): the lane map is part of the
/// composite's wire-stable registry name, so `ConvergenceDoc.fromJson`
/// restores the full document without parent-side routing. Anti-entropy
/// (version vector, `opsSince`, `needsSnapshotFor`, snapshots,
/// compaction) is per-kernel-doc and therefore trivially per-document —
/// one VV, one op log, one snapshot decision.
///
/// last_answer never merges by hand: fold, ordering, dedupe, lane
/// dispatch, and serialization are entirely kernel-owned (ADR 0011
/// sub-star discipline).
final class DocReplica {
  DocReplica({required this.nodeId, required this.actorId})
    : _doc = ConvergenceDoc(
        docId: nodeId.value,
        actorId: actorId,
        strategy: _lanes,
      );

  DocReplica._(this._doc)
    : nodeId = NodeId(_doc.docId),
      actorId = _doc.actorId;

  /// Restores the kernel doc through `ConvergenceDoc.fromJson` — the
  /// composite lane map comes back from the strategy registry name, no
  /// parent-side re-routing (ADR 0030 §1). The HLC receive watermark is
  /// recomputed from the restored doc so local ops issued after the
  /// restore keep ordering after every pre-restore op.
  factory DocReplica.fromJson(final Map<String, dynamic> json) {
    final doc = ConvergenceDoc.fromJson(
      Map<String, dynamic>.from(json['doc'] as Map<dynamic, dynamic>),
    );
    final replica = DocReplica._(doc);
    Hlc? last = json['last_issued'] == null
        ? null
        : Hlc.fromJson(
            Map<String, dynamic>.from(
              json['last_issued'] as Map<dynamic, dynamic>,
            ),
          );
    final vvWatermark = doc.vv[replica.actorId];
    if (vvWatermark != null && (last == null || vvWatermark > last)) {
      last = vvWatermark;
    }
    for (final op in replica.pendingOps) {
      if (op.actorId != replica.actorId) continue;
      if (last == null || op.hlc > last) last = op.hlc;
    }
    replica._lastIssued = last;
    return replica;
  }

  /// Lane map for document ops (ADR 0030 §1): LWW lanes for node fields
  /// and fractional child order, RGA lane for block text.
  static final CompositeMergeStrategy _lanes = CompositeMergeStrategy({
    'node/': const LwwMapStrategy(),
    'order/': const LwwMapStrategy(),
    'text/': const RgaTextStrategy(),
  });

  /// Key namespace for node/block field registers (LWW map lane).
  static const String nodeKeyPrefix = 'node/';

  /// Key namespace for fractional child order registers (LWW map lane).
  static const String orderKeyPrefix = 'order/';

  /// Key namespace for block text sequences (RGA lane).
  static const String textKeyPrefix = 'text/';

  /// The ONE kernel replica for the whole document (ADR 0030 §1):
  /// composite strategy, one version vector, one op log, one snapshot.
  final ConvergenceDoc _doc;

  /// Highest HLC issued or causally received by THIS replica. With one
  /// kernel doc, op-id uniqueness is kernel-owned; this watermark now
  /// serves only the HLC receive rule (causality): local ops issued after
  /// folding remote ones must order after them, even on a frozen wall
  /// clock — fed back into `applyLocal` via the kernel's `lastIssued`
  /// seam.
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
    final op = _doc.applyLocal(
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
    final op = _doc.applyLocal(
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

  /// Folds remote ops into the ONE kernel doc — lane dispatch happens
  /// inside the composite strategy by key prefix, not here (ADR 0030 §1).
  /// Idempotent and delivery-order independent per the kernel contract.
  /// Returns how many ops were newly applied.
  int applyRemote(final Iterable<OpRecord> ops, {final DateTime? now}) {
    final applied = _doc.applyRemote(ops, now: now);
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

  /// Rebuilds the document projection from the folded kernel state.
  /// Deterministic: blocks in fractional-key order with ties broken by
  /// block id (concurrent writers landing the same key still converge to
  /// one projection), text via the kernel RGA traversal.
  DocumentNode document() {
    final state = _doc.state;
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
          content: RgaTextStrategy.readText(state, _textKey(id)) ?? '',
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
      RgaTextStrategy.readText(_doc.state, _textKey(blockId)) ?? '';

  /// Child ids of [parentId] ordered by fractional key (ties broken by
  /// child id). [parentId] is the plain id string (`nodeId.value`).
  List<String> orderedChildren(final String parentId) {
    final prefix = '$orderKeyPrefix$parentId/';
    final entries = <(String, String)>[];
    final state = _doc.state;
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
      LwwMapStrategy.readValue(_doc.state, _orderKey(parentId, childId));

  // ---------------------------------------------------------------------------
  // Introspection / persistence
  // ---------------------------------------------------------------------------

  /// Ops pending delta-shipping in the kernel doc (all lanes).
  List<OpRecord> get pendingOps => _doc.pendingOps;

  /// Ops this replica holds that a remote whose version vector is
  /// [remoteVv] has not observed — the kernel's VV diff, i.e. the
  /// delta-shipping seam doc sync exchanges (ADR 0005 §1).
  List<OpRecord> pendingOpsSince(final VersionVector remoteVv) =>
      _doc.opsSince(remoteVv);

  /// THE version vector of the document's kernel doc — one anti-entropy
  /// header for every lane (ADR 0030 §1).
  VersionVector get versionVector => _doc.vv;

  /// Full serialization for durable local persistence; the kernel doc
  /// serializes through the kernel (`ConvergenceDoc.toJson`), carrying
  /// the composite lane map in its registry name.
  Map<String, dynamic> toJson() => {
    'doc_id': nodeId.value,
    'actor_id': actorId,
    'doc': _doc.toJson(),
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
    final op = _doc.applyLocal(
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
    final op = _doc.applyLocal(
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
    final raw = _doc.state[_textKey(blockId)];
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
      LwwMapStrategy.readValue(_doc.state, _nodeKey(id, name));

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
