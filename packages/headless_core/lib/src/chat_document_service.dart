import 'document_node.dart';
import 'document_repository.dart';

/// Pure-Dart operations for chat documents and anchored chat threads.
final class ChatDocumentService {
  ChatDocumentService({required this.repository});

  final DocumentRepository repository;

  /// Creates an empty root chat. [sessionId] is persisted on the title block
  /// so the active ACP session survives repository round-trips.
  Future<DocumentNode> createChat(
    String title, {
    NodeId? nodeId,
    String? sessionId,
    DateTime? at,
  }) async {
    final timestamp = at ?? DateTime.now().toUtc();
    final node = DocumentNode(
      id: nodeId ?? const NodeId('chat'),
      formatId: 'chat',
      blocks: [
        Block(
          id: const NodeId('title'),
          type: BlockType.heading,
          content: title,
          level: 1,
          sessionId: sessionId,
        ),
      ],
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    await repository.save(node);
    return node;
  }

  /// Appends one message in list order.
  Future<DocumentNode> appendMessage(
    NodeId nodeId, {
    required ChatRole role,
    required String content,
    String? messageId,
    String? sessionId,
    String? toolCallId,
    String? title,
    MessageStatus status = MessageStatus.complete,
    NodeId? blockId,
    DateTime? at,
    }) => _update(
    nodeId,
    at: at,
    blocks: (node) => [
      ...node.blocks,
      Block(
        id:
            blockId ??
            NodeId('${node.id.value}:message:${node.blocks.length + 1}'),
        type: BlockType.message,
        content: content,
        role: role,
        messageId: messageId,
        sessionId: sessionId,
        toolCallId: toolCallId,
        title: title,
        status: status,
      ),
    ],
  );

  /// Replaces a message's content while preserving its identity.
  Future<DocumentNode> replaceMessage(
    NodeId nodeId,
    NodeId blockId, {
    required String content,
    DateTime? at,
  }) => _updateBlock(
    nodeId,
    blockId,
    at: at,
    update: (block) => block.copyWith(content: content),
  );

  /// Transitions message state; use `failed` after stream/backend errors.
  Future<DocumentNode> updateMessageStatus(
    NodeId nodeId,
    NodeId blockId, {
    required MessageStatus status,
    DateTime? at,
  }) => _updateBlock(
    nodeId,
    blockId,
    at: at,
    update: (block) => block.copyWith(status: status),
  );

  /// Opens an anchored child discussion using existing ADR 0001 invariants.
  Future<DocumentNode> startAgentThread({
    required NodeId parentNodeId,
    required NodeId anchorBlockId,
    required String title,
    NodeId? childId,
    String? sessionId,
    DateTime? at,
  }) async {
    final parent = (await _require(parentNodeId)).node;
    if (parent.status != DocumentStatus.open) {
      throw StateError('parent $parentNodeId is not open');
    }
    final anchor = parent.blockById(anchorBlockId);
    if (anchor == null) {
      throw StateError('parent $parentNodeId does not contain $anchorBlockId');
    }
    final timestamp = at ?? DateTime.now().toUtc();
    final child = DocumentNode(
      id:
          childId ??
          NodeId('${parent.id.value}:${anchorBlockId.value}:discussion'),
      formatId: 'chat',
      parentDocId: parent.id,
      anchorSpan: AnchorSpan(blockId: anchorBlockId),
      spanSnapshot: anchor.content,
      blocks: [
        Block(
          id: const NodeId('title'),
          type: BlockType.heading,
          content: title,
          level: 1,
          sessionId: sessionId,
        ),
      ],
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    await repository.save(child);
    return child;
  }

  Future<DocumentNode> _update(
    NodeId nodeId, {
    required List<Block> Function(DocumentNode node) blocks,
    DateTime? at,
  }) async {
    final node = (await _require(nodeId)).node;
    final updated = node.withBlocks(
      blocks(node),
      at: at ?? DateTime.now().toUtc(),
    );
    await repository.save(updated);
    return updated;
  }

  Future<DocumentNode> _updateBlock(
    NodeId nodeId,
    NodeId blockId, {
    required Block Function(Block block) update,
    DateTime? at,
  }) => _update(
    nodeId,
    at: at,
    blocks: (node) {
      var found = false;
      final updated = [
        for (final block in node.blocks)
          if (block.id.value == blockId.value)
            () {
              found = true;
              return update(block);
            }()
          else
            block,
      ];
      if (!found) {
        throw StateError('message $blockId not found in $nodeId');
      }
      return updated;
    },
  );

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
}
