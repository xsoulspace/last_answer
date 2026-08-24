import 'document_node.dart';
import 'document_repository.dart';

/// Role of the document content sent to an inference port.
enum AgentDocumentRole { parent, discussion, template }

/// Provider-neutral description of one document context.
final class AgentDocumentContext {
  const AgentDocumentContext({
    required this.id,
    required this.role,
    required this.blocks,
    this.formatId,
    this.status = DocumentStatus.open,
  });

  final NodeId id;
  final AgentDocumentRole role;
  final List<Block> blocks;
  final String? formatId;
  final DocumentStatus status;
}

/// One request sent to a backend-agnostic inference callback.
final class DocumentAgentRequest {
  const DocumentAgentRequest({
    required this.operation,
    required this.prompt,
    required this.documents,
  });

  final String operation;
  final String prompt;
  final List<AgentDocumentContext> documents;
}

/// Incremental output from an inference backend.
sealed class DocumentAgentEvent {
  const DocumentAgentEvent();
}

final class DocumentAgentDelta extends DocumentAgentEvent {
  const DocumentAgentDelta(this.text);

  final String text;
}

final class DocumentAgentCompleted extends DocumentAgentEvent {
  const DocumentAgentCompleted(this.text);

  final String text;
}

final class DocumentAgentFailed extends DocumentAgentEvent {
  const DocumentAgentFailed(this.message);

  final String message;
}

/// Generic streaming port. The app adapts ACP, HTTP, CLI, or local models
/// to this signature; headless_core remains independent of all backends.
typedef DocumentInferencePort =
    Stream<DocumentAgentEvent> Function(DocumentAgentRequest request);

/// A complete answer assembled from a successful inference stream.
final class DocumentAgentAnswer {
  const DocumentAgentAnswer({required this.text, required this.rawEvents});

  final String text;
  final List<DocumentAgentEvent> rawEvents;
}

/// Pure-Dart document agent operations over [DocumentRepository].
///
/// The service never mutates a parent implicitly: rewrites are returned to
/// the caller and applied only by [applyParentRewrite].
final class DocumentAgentService {
  DocumentAgentService({
    required DocumentRepository repository,
    required this.inference,
  }) : repository = repository;

  final DocumentInferencePort inference;
  final DocumentRepository repository;

  /// Answers [question] using the node and, when present, its anchored
  /// parent. Returns only text; never changes storage.
  Future<DocumentAgentAnswer> answerQuestion(
    NodeId nodeId, {
    required String question,
  }) async {
    final (node, parent) = await _loadNodeWithOptionalParent(nodeId);
    return _complete(
      DocumentAgentRequest(
        operation: 'answerQuestion',
        prompt: question,
        documents: [
          _contextFor(node, AgentDocumentRole.discussion),
          if (parent != null) _contextFor(parent, AgentDocumentRole.parent),
        ],
      ),
    );
  }

  /// Proposes a replacement for the parent block anchored by [discussionId].
  /// The proposal is not persisted.
  Future<DocumentAgentAnswer> proposeParentRewrite(NodeId discussionId) async {
    final result = await _require(discussionId);
    if (!result.node.isChild || result.node.anchorSpan == null) {
      throw StateError('node $discussionId is not an anchored discussion');
    }
    final parentId = result.node.parentDocId!;
    final parentResult = await _require(parentId);
    final parent = parentResult.node;
    final block = parentResult.node.blockById(result.node.anchorSpan!.blockId);
    if (block == null) {
      throw StateError(
        'parent $parentId does not contain anchor '
        '${result.node.anchorSpan!.blockId}',
      );
    }

    return _complete(
      DocumentAgentRequest(
        operation: 'proposeParentRewrite',
        prompt:
            'Rewrite only the anchored parent block using the discussion. '
            'Return the complete replacement block text.',
        documents: [
          AgentDocumentContext(
            id: parent.id,
            role: AgentDocumentRole.parent,
            blocks: [block],
            formatId: parent.formatId,
          ),
          _contextFor(result.node, AgentDocumentRole.discussion),
        ],
      ),
    );
  }

  /// Opens a new child discussion anchored to [parentBlockId]. The initial
  /// heading is deterministic so creation has no hidden model call.
  Future<DocumentNode> openDiscussion({
    required NodeId parentId,
    required NodeId parentBlockId,
    required String title,
    NodeId? childId,
    DateTime? at,
  }) async {
    final parentResult = await _require(parentId);
    final parent = parentResult.node;
    final block = parent.blockById(parentBlockId);
    if (block == null) {
      throw StateError('parent $parentId does not contain $parentBlockId');
    }
    if (parent.status != DocumentStatus.open) {
      throw StateError('parent $parentId is not open');
    }

    final timestamp = at ?? DateTime.now().toUtc();
    final child = DocumentNode(
      id:
          childId ??
          NodeId('${parent.id.value}:${parentBlockId.value}:discussion'),
      parentDocId: parent.id,
      anchorSpan: AnchorSpan(blockId: parentBlockId),
      spanSnapshot: block.content,
      blocks: [
        Block(
          id: const NodeId('title'),
          type: BlockType.heading,
          content: title,
          level: 1,
        ),
      ],
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    await repository.save(child);
    return child;
  }

  /// Applies an explicit rewrite to exactly the anchored parent block and
  /// persists the updated parent. Child state is intentionally untouched;
  /// callers decide when to collapse it.
  Future<DocumentNode> applyParentRewrite(
    NodeId discussionId, {
    required String rewrittenText,
    DateTime? at,
  }) async {
    final discussionResult = await _require(discussionId);
    final discussion = discussionResult.node;
    final anchor = discussion.anchorSpan;
    if (!discussion.isChild || anchor == null) {
      throw StateError('node $discussionId is not an anchored discussion');
    }

    final parent = (await _require(discussion.parentDocId!)).node;
    var replaced = false;
    final blocks = [
      for (final block in parent.blocks)
        if (block.id.value == anchor.blockId.value) ...[
          () {
            replaced = true;
            return block.copyWith(content: rewrittenText);
          }(),
        ] else
          block,
    ];
    if (!replaced) {
      throw StateError('anchor ${anchor.blockId} is missing from parent');
    }
    final updated = parent.withBlocks(blocks, at: at ?? DateTime.now().toUtc());
    await repository.save(updated);
    return updated;
  }

  Future<(DocumentNode, DocumentNode?)> _loadNodeWithOptionalParent(
    NodeId nodeId,
  ) async {
    final node = (await _require(nodeId)).node;
    final parentId = node.parentDocId;
    if (parentId == null) return (node, null);
    return (node, (await _require(parentId)).node);
  }

  Future<DocFound> _require(NodeId id) async {
    final result = await repository.get(id);
    switch (result) {
      case DocFound(:final node):
        return DocFound(node);
      case DocNotFound(:final id):
        throw StateError('document $id not found');
      case DocError(:final id, :final message):
        throw StateError('document $id could not be read: $message');
    }
  }

  AgentDocumentContext _contextFor(DocumentNode node, AgentDocumentRole role) =>
      AgentDocumentContext(
        id: node.id,
        role: role,
        blocks: node.blocks,
        formatId: node.formatId,
        status: node.status,
      );

  Future<DocumentAgentAnswer> _complete(DocumentAgentRequest request) async {
    final events = <DocumentAgentEvent>[];
    final buffer = StringBuffer();
    await for (final event in inference(request)) {
      events.add(event);
      switch (event) {
        case DocumentAgentDelta(:final text):
          buffer.write(text);
        case DocumentAgentCompleted(:final text):
          return DocumentAgentAnswer(text: text, rawEvents: events);
        case DocumentAgentFailed(:final message):
          throw StateError('inference failed: $message');
      }
    }
    final text = buffer.toString();
    if (text.isEmpty) {
      throw StateError('inference ended without completion');
    }
    return DocumentAgentAnswer(text: text, rawEvents: events);
  }
}
