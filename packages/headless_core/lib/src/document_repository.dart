import 'package:headless_core/headless_core.dart';

/// Result of a repository read that may not exist.
sealed class DocResult {
  const DocResult();
}

class DocFound extends DocResult {
  const DocFound(this.node);
  final DocumentNode node;
}

class DocNotFound extends DocResult {
  const DocNotFound(this.id);
  final NodeId id;
}

/// Failure with reason (I/O error, corrupt JSON, invariant violation).
class DocError extends DocResult {
  const DocError(this.id, this.message);
  final NodeId id;
  final String message;
}

/// Provider-agnostic contract for storing and retrieving document nodes.
///
/// Implementations must preserve [DocumentNode] identity (ids) exactly —
/// anchors depend on it. One file per node on filesystem backends per
/// ADR 0001; in-memory for tests.
abstract interface class DocumentRepository {
  /// Reads a node by id. Returns [DocFound], [DocNotFound], or [DocError].
  Future<DocResult> get(NodeId id);

  /// Creates or overwrites a node. Implementations should validate child
  /// invariants before persisting.
  Future<void> save(DocumentNode node);

  /// Deletes a node. Collapsed nodes are never auto-deleted by domain
  /// logic, but explicit deletion is allowed (e.g. project teardown).
  Future<void> delete(NodeId id);

  /// Lists all node ids directly parented to [parentId].
  /// Pass null for root documents.
  Future<List<NodeId>> childrenOf(NodeId? parentId);

  /// Lists all stored node ids (index-level operation).
  Future<List<NodeId>> allIds();
}

/// Thrown when saving a node violates ADR 0001 invariants.
class InvariantViolation implements Exception {
  InvariantViolation(this.message);
  final String message;

  @override
  String toString() => 'InvariantViolation: $message';
}
