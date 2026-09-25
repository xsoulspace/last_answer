import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';

void main() {
  test('creates an empty persisted chat with active session id', () async {
    final repository = InMemoryDocumentRepository();
    final service = ChatDocumentService(repository: repository);

    final chat = await service.createChat(
      'Agent chat',
      nodeId: const NodeId('chat-1'),
      sessionId: 'acp-session',
    );
    final loadedResult = await repository.get(const NodeId('chat-1'));
    if (loadedResult is! DocFound) fail('chat was not persisted');
    final loaded = loadedResult.node;

    expect(chat.formatId, 'chat');
    expect(loaded, chat);
    expect(loaded.blocks.single.sessionId, 'acp-session');
  });

  test('appends, streams replacement, and marks failure', () async {
    final repository = InMemoryDocumentRepository();
    final service = ChatDocumentService(repository: repository);
    final chat = await service.createChat('', nodeId: const NodeId('chat'));
    const userBlock = NodeId('user-turn');
    const assistantBlock = NodeId('assistant-turn');

    await service.appendMessage(
      chat.id,
      role: ChatRole.user,
      content: 'Hello',
      blockId: userBlock,
      messageId: 'm1',
      sessionId: 's1',
    );
    await service.appendMessage(
      chat.id,
      role: ChatRole.assistant,
      content: '',
      blockId: assistantBlock,
      messageId: 'm2',
      status: MessageStatus.streaming,
    );
    var updated = await service.replaceMessage(
      chat.id,
      assistantBlock,
      content: 'Partial response',
    );
    expect(updated.blockById(assistantBlock)!.status, MessageStatus.streaming);
    expect(updated.blockById(assistantBlock)!.content, 'Partial response');

    updated = await service.updateMessageStatus(
      chat.id,
      assistantBlock,
      status: MessageStatus.failed,
    );
    expect(updated.updatedAt.isAfter(chat.updatedAt), isTrue);
    expect(updated.blockById(assistantBlock)!.status, MessageStatus.failed);
  });

  test(
    'starts a child thread satisfying repository child invariants',
    () async {
      final repository = InMemoryDocumentRepository();
      final service = ChatDocumentService(repository: repository);
      final chat = await service.createChat('', nodeId: const NodeId('chat'));
      await service.appendMessage(
        chat.id,
        role: ChatRole.user,
        content: 'Anchor this idea',
        blockId: const NodeId('message'),
      );

      final thread = await service.startAgentThread(
        parentNodeId: chat.id,
        anchorBlockId: const NodeId('message'),
        title: 'Thread',
        sessionId: 'thread-session',
      );
      final loadedResult = await repository.get(thread.id);
      if (loadedResult is! DocFound) fail('thread was not persisted');
      final loaded = loadedResult.node;

      expect(loaded.formatId, 'chat');
      expect(loaded.satisfiesChildInvariants, isTrue);
      expect(loaded.anchorSpan!.blockId, const NodeId('message'));
      expect(loaded.spanSnapshot, 'Anchor this idea');
      expect(loaded.blocks.single.sessionId, 'thread-session');
    },
  );

  test('chat blocks survive JSON persistence', () {
    const block = Block(
      id: NodeId('message'),
      type: BlockType.message,
      content: 'Ready',
      role: ChatRole.assistant,
      messageId: 'm1',
      sessionId: 's1',
      toolCallId: 't1',
      title: 'Read file',
      status: MessageStatus.streaming,
    );
    final restored = Block.fromJson(block.toJson());

    expect(restored, block);
  });
}
