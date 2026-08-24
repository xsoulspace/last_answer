import 'package:headless_core/headless_core.dart';

import 'document_repository.dart';

/// In-memory [DocumentRepository] for tests and ephemeral use.
final class InMemoryDocumentRepository implements DocumentRepository {
  final Map<NodeId, DocumentNode> _nodes = {};

  @override
  Future<DocResult> get(NodeId id) async {
    final node = _nodes[id];
    return node == null ? DocNotFound(id) : DocFound(node);
  }

  @override
  Future<void> save(DocumentNode node) async {
    if (!node.satisfiesChildInvariants) {
      throw InvariantViolation(
        'node ${node.id} is a child but lacks anchorSpan or spanSnapshot',
      );
    }
    _nodes[node.id] = node;
  }

  @override
  Future<void> delete(NodeId id) async {
    _nodes.remove(id);
  }

  @override
  Future<List<NodeId>> childrenOf(NodeId? parentId) async => _nodes.values
      .where((n) => n.parentDocId == parentId)
      .map((n) => n.id)
      .toList();

  @override
  Future<List<NodeId>> allIds() async => _nodes.keys.toList();
}
