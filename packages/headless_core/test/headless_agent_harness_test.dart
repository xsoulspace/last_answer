import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';

void main() {
  test('runs a scripted streaming chat without UI or an LLM', () async {
    final harness = HeadlessAgentHarness(
      responses: [
        ScriptedAgentResponse(
          match: (prompt) => prompt == 'hello',
          chunks: ['Hello', ', ', 'world'],
        ),
      ],
    );

    await harness.install();
    await harness.start('/tmp/project');
    final chat = await harness.createChat();
    await harness.sendUserMessage('hello');
    await harness.reload(chat.id);

    expect(harness.prompts, ['hello']);
    expect(harness.sessionId, 'session-1');
    final messages = harness.current!.blocks
        .where((block) => block.type == BlockType.message)
        .toList();
    expect(messages, hasLength(2));
    expect(messages.first.role, ChatRole.user);
    expect(messages.first.content, 'hello');
    expect(messages.last.role, ChatRole.assistant);
    expect(messages.last.content, 'Hello, world');
    expect(messages.last.status, MessageStatus.complete);
  });

  test('marks assistant failures deterministically', () async {
    final harness = HeadlessAgentHarness(
      responses: [
        ScriptedAgentResponse(
          match: (prompt) => prompt == 'fail',
          error: StateError('scripted failure'),
        ),
      ],
    );
    await harness.install();
    await harness.start('/tmp/project');
    await harness.createChat();

    await expectLater(harness.sendUserMessage('fail'), throwsStateError);
    await harness.reload(harness.current!.id);

    final messages = harness.current!.blocks
        .where((block) => block.type == BlockType.message)
        .toList();
    expect(messages.last.status, MessageStatus.failed);
  });

  test('enforces the full deterministic agent lifecycle', () async {
    final harness = HeadlessAgentHarness();

    await expectLater(harness.sendUserMessage('hello'), throwsStateError);

    await expectLater(
      () => harness.send('hello').drain<void>(),
      throwsStateError,
    );
    await harness.install();
    await harness.start('/tmp');
    await harness.createChat();

    await expectLater(harness.newSession('/tmp'), completion('session-2'));
    final unstarted = HeadlessAgentHarness()..install();
    await expectLater(
      () => unstarted.send('hello').drain<void>(),
      throwsStateError,
    );
    await expectLater(() => harness.switchTo('missing'), throwsStateError);
    harness.switchTo('session-1');
    await harness.sendUserMessage('hello');
    expect(harness.prompts, ['hello']);

    await harness.stop();
    expect(harness.isReady, isFalse);
  });

  test('starts anchored threads from any message block', () async {
    final harness = HeadlessAgentHarness();
    await harness.install();
    await harness.start('/tmp/project');
    final chat = await harness.createChat();
    await harness.sendUserMessage('thread me');
    await harness.reload(chat.id);

    final message = harness.current!.blocks.firstWhere(
      (block) => block.type == BlockType.message,
    );
    final thread = await harness.chat.startAgentThread(
      parentNodeId: chat.id,
      anchorBlockId: message.id,
      title: message.content,
    );

    expect(thread.isChild, isTrue);
    expect(thread.anchorSpan!.blockId, message.id);
    expect(thread.spanSnapshot, message.content);
  });
}
