import 'package:universal_storage_convergence/universal_storage_convergence.dart';

import 'doc_replica.dart';
import 'doc_replica_store.dart';
import 'document_node.dart';
import 'document_repository.dart';

/// A [DocumentRepository] whose storage is a [DocReplicaStore] — docs are
/// event-sourced over the convergence kernel (ADR 0005 §1), so two
/// devices holding replicas of the same doc converge (the mesh sync
/// cycle ships the ops; the kernel's VV dedupe makes folding idempotent).
///
/// `save` translates a whole-node write into the MINIMAL kernel-op diff
/// against the current projection: new blocks issue [DocReplica.addBlock],
/// changed blocks issue text-delete/insert (RGA) and per-field LWW ops,
/// vanished blocks issue [DocReplica.removeBlock]. This keeps concurrent
/// editors converging instead of whole-file-clobbering (the failure mode
/// of a plain LWW JSON store for multiplayer).
///
/// Field coverage: the diff carries every [Block] field including the
/// chat transport metadata (`provider`/`model`/`agentKey`/`workspace`/
/// `ownerPeerId`/`systemPrompt`) via [DocReplica.setBlockField] — fields
/// `addBlock` does not issue itself.
///
/// Known limits (honest): `childrenOf`/`allIds` answer only replicas
/// opened in this process — a store never scans the replica directory
/// (peers' files arrive through the sync cycle). `delete` tombstones the
/// blocks and marks the node `collapsed`; kernel ops are never erased.
class ReplicaDocumentRepository implements DocumentRepository {
  ReplicaDocumentRepository(this._store);

  final DocReplicaStore _store;

  @override
  Future<DocResult> get(final NodeId id) async {
    final replica = await _store.open(id);
    // Existence marker: the raw createdAt register (a fresh replica
    // projects epoch times — see DocReplica.wasBorn).
    if (!replica.wasBorn) {
      return DocNotFound(id);
    }
    return DocFound(replica.document());
  }

  @override
  Future<void> save(final DocumentNode node) => _store.edit(node.id, (
    replica,
  ) {
    final now = DateTime.now();
    final ops = <OpRecord>[];
    final current = replica.document();
    if (!replica.wasBorn) {
      ops.addAll(replica.createNode(now: now));
      final kind = node.kind;
      if (kind.isNotEmpty) {
        ops.addAll(replica.setNodeField('kind', value: kind, now: now));
      }
      final formatId = node.formatId;
      if (formatId != null) {
        ops.addAll(replica.setNodeField('formatId', value: formatId, now: now));
      }
      final parentDocId = node.parentDocId;
      if (parentDocId != null) {
        ops.addAll(
          replica.setNodeField('parentDocId', value: parentDocId.value, now: now),
        );
      }
      final anchor = node.anchorSpan;
      if (anchor != null) {
        ops.addAll(replica.setAnchor(anchor.blockId, now: now));
        final prefixHash = anchor.prefixHash;
        if (prefixHash != null) {
          ops.addAll(
            replica.setNodeField(
              'anchorPrefixHash',
              value: prefixHash,
              now: now,
            ),
          );
        }
        final suffixHash = anchor.suffixHash;
        if (suffixHash != null) {
          ops.addAll(
            replica.setNodeField(
              'anchorSuffixHash',
              value: suffixHash,
              now: now,
            ),
          );
        }
      }
      final spanSnapshot = node.spanSnapshot;
      if (spanSnapshot != null) {
        ops.addAll(
          replica.setNodeField('spanSnapshot', value: spanSnapshot, now: now),
        );
      }
    }
    ops.addAll(
      replica.setNodeField(
        'status',
        value: node.status.name,
        now: now,
      ),
    );
    // Span snapshot refreshes on every save (LWW; the fresh-born branch
    // above also wrote it — the kernel dedupes identical registers).
    final spanSnapshot = node.spanSnapshot;
    if (spanSnapshot != null) {
      ops.addAll(
        replica.setNodeField('spanSnapshot', value: spanSnapshot, now: now),
      );
    }

    final currentBlocks = {
      for (final block in current.blocks) block.id.value: block,
    };
    final targetIds = node.blocks.map((final b) => b.id.value).toSet();

    for (var i = 0; i < node.blocks.length; i++) {
      final block = node.blocks[i];
      final existing = currentBlocks[block.id.value];
      if (existing == null) {
        ops.addAll(replica.addBlock(block, index: i, now: now));
        ops.addAll(_metadataFields(replica, block, now));
        continue;
      }
      // Order first (insertion position may drive UI reads).
      final ordered = current.blocks.map((final b) => b.id.value).toList();
      if (ordered.indexOf(block.id.value) != i) {
        ops.addAll(
          replica.placeChild(
            parentId: node.id,
            childId: block.id,
            index: i,
            now: now,
          ),
        );
      }
      if (existing.content != block.content) {
        // RGA replace: tombstone the divergent tail, insert the new tail.
        // A shared-prefix trim keeps the common case (streamed assistant
        // checkpoints growing at the tail) from churning the whole text.
        final oldText = existing.content;
        final newText = block.content;
        var prefix = 0;
        while (prefix < oldText.length &&
            prefix < newText.length &&
            oldText.codeUnitAt(prefix) == newText.codeUnitAt(prefix)) {
          prefix++;
        }
        ops.addAll(
          replica.deleteTextRange(
            block.id,
            prefix,
            oldText.length - prefix,
            now: now,
          ),
        );
        // Only the SURVIVING tail is inserted — the shared prefix's RGA
        // elements are still live and must not be duplicated.
        ops.addAll(
          replica.insertTextAt(
            block.id,
            prefix,
            newText.substring(prefix),
            now: now,
          ),
        );
      }
      ops.addAll(_changedFields(replica, existing, block, now));
    }

    for (final existing in current.blocks) {
      if (!targetIds.contains(existing.id.value)) {
        ops.addAll(replica.removeBlock(existing.id, now: now));
      }
    }

    ops.addAll(
      replica.setNodeField(
        'updatedAt',
        value: now.toUtc().toIso8601String(),
        now: now,
      ),
    );
    return ops;
  });

  /// Metadata fields `addBlock` does not issue — carried for new blocks
  /// only (existing blocks take the changed-field diff below).
  List<OpRecord> _metadataFields(
    final DocReplica replica,
    final Block block,
    final DateTime now,
  ) {
    final ops = <OpRecord>[];
    void field(final String name, final String? value) {
      if (value == null) return;
      ops.addAll(replica.setBlockField(block.id, name, value: value, now: now));
    }

    field('provider', block.provider);
    field('model', block.model);
    field('agentKey', block.agentKey);
    field('workspace', block.workspace);
    field('ownerPeerId', block.ownerPeerId);
    field('systemPrompt', block.systemPrompt);
    return ops;
  }

  List<OpRecord> _changedFields(
    final DocReplica replica,
    final Block existing,
    final Block block,
    final DateTime now,
  ) {
    final ops = <OpRecord>[];
    void field(final String name, final String? next, final String? prev) {
      final newValue = next;
      final oldValue = prev;
      if (newValue == oldValue) return;
      if (newValue == null) {
        // LWW field deletion is a tombstone write; the empty string is
        // the repository's null encoding for optional block fields.
        ops.addAll(replica.setBlockField(block.id, name, value: '', now: now));
        return;
      }
      ops.addAll(replica.setBlockField(block.id, name, value: newValue, now: now));
    }

    if (existing.type != block.type) {
      ops.addAll(
        replica.setBlockField(block.id, 'type', value: block.type.name, now: now),
      );
    }
    field('level', block.level?.toString(), existing.level?.toString());
    field('role', block.role?.name, existing.role?.name);
    field('messageId', block.messageId, existing.messageId);
    field('sessionId', block.sessionId, existing.sessionId);
    field('toolCallId', block.toolCallId, existing.toolCallId);
    field('title', block.title, existing.title);
    field('provider', block.provider, existing.provider);
    field('model', block.model, existing.model);
    field('agentKey', block.agentKey, existing.agentKey);
    field('workspace', block.workspace, existing.workspace);
    field('ownerPeerId', block.ownerPeerId, existing.ownerPeerId);
    field('systemPrompt', block.systemPrompt, existing.systemPrompt);
    if (existing.status != block.status) {
      ops.addAll(
        replica.setBlockField(
          block.id,
          'status',
          value: block.status.name,
          now: now,
        ),
      );
    }
    return ops;
  }

  @override
  Future<void> delete(final NodeId id) => _store.edit(id, (replica) {
    final now = DateTime.now();
    final ops = <OpRecord>[
      for (final blockId in replica.orderedChildren(id.value))
        ...replica.removeBlock(NodeId(blockId), now: now),
      ...replica.setNodeField('status', value: 'collapsed', now: now),
    ];
    return ops;
  });

  @override
  Future<List<NodeId>> childrenOf(final NodeId? parentId) async {
    if (parentId == null) return _store.openedDocIds;
    return [
      for (final id in _store.openedDocIds)
        if ((await get(id)) case final DocFound found
            when found.node.parentDocId == parentId)
          id,
    ];
  }

  @override
  Future<List<NodeId>> allIds() async => _store.openedDocIds;
}
