import 'dart:async';

import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';

final class _ScriptedInference {
  final requests = <DocumentAgentRequest>[];
  final controller = StreamController<DocumentAgentEvent>();

  Stream<DocumentAgentEvent> call(DocumentAgentRequest request) {
    requests.add(request);
    return controller.stream;
  }
}

DocumentNode _root() => DocumentNode(
  id: const NodeId('root'),
  blocks: const [
    Block(
      id: NodeId('head'),
      type: BlockType.heading,
      content: 'Old',
      level: 1,
    ),
  ],
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  late InMemoryDocumentRepository repository;
  late _ScriptedInference source;
  late DocumentAgentService service;

  setUp(() {
    repository = InMemoryDocumentRepository();
    source = _ScriptedInference();
    service = DocumentAgentService(
      repository: repository,
      inference: source.call,
    );
  });

  test('answerQuestion streams deltas and includes parent context', () async {
    await repository.save(_root());
    await repository.save(
      DocumentNode(
        id: const NodeId('child'),
        parentDocId: const NodeId('root'),
        anchorSpan: const AnchorSpan(blockId: NodeId('head')),
        spanSnapshot: 'Old',
        blocks: const [
          Block(id: NodeId('note'), type: BlockType.paragraph, content: 'Why?'),
        ],
        createdAt: DateTime.utc(2026, 1, 2),
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
    );

    final future = service.answerQuestion(
      const NodeId('child'),
      question: 'What should the heading say?',
    );
    unawaited(
      Future(() async {
        await source.controller.emitCompleted('New heading');
      }),
    );
    final answer = await future;

    expect(answer.text, 'New heading');
    expect(source.requests.single.operation, 'answerQuestion');
    expect(source.requests.single.documents.map((d) => d.role), [
      AgentDocumentRole.discussion,
      AgentDocumentRole.parent,
    ]);
  });

  test('openDiscussion uses child invariants and anchor snapshot', () async {
    await repository.save(_root());
    final at = DateTime.utc(2026, 1, 3);

    final child = await service.openDiscussion(
      parentId: const NodeId('root'),
      parentBlockId: const NodeId('head'),
      title: 'Discuss heading',
      at: at,
    );
    final loaded = (await repository.get(child.id)) as DocFound;

    expect(child.isChild, isTrue);
    expect(child.spanSnapshot, 'Old');
    expect(loaded.node.anchorSpan?.blockId, const NodeId('head'));
    expect(await repository.childrenOf(const NodeId('root')), [child.id]);
  });

  test('proposeParentRewrite returns text without changing parent', () async {
    await repository.save(_root());
    final discussion = await service.openDiscussion(
      parentId: const NodeId('root'),
      parentBlockId: const NodeId('head'),
      title: 'Discussion',
    );
    unawaited(
      Future(() async {
        await source.controller.emitDeltaOnly('Rewritten');
      }),
    );

    final answer = await service.proposeParentRewrite(discussion.id);
    final parent =
        ((await repository.get(const NodeId('root'))) as DocFound).node;

    expect(answer.text, 'Rewritten');
    expect(parent.blocks.single.content, 'Old');
    expect(source.requests.single.documents.first.blocks.single.content, 'Old');
  });

  test('applyParentRewrite replaces only anchored block', () async {
    await repository.save(
      DocumentNode(
        id: const NodeId('parent'),
        blocks: const [
          Block(id: NodeId('one'), type: BlockType.paragraph, content: 'one'),
          Block(id: NodeId('two'), type: BlockType.paragraph, content: 'two'),
        ],
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );
    final discussion = await service.openDiscussion(
      parentId: const NodeId('parent'),
      parentBlockId: const NodeId('two'),
      title: 'Discussion',
    );

    final updated = await service.applyParentRewrite(
      discussion.id,
      rewrittenText: 'new two',
      at: DateTime.utc(2026, 1, 4),
    );

    expect(updated.blocks.map((b) => b.content), ['one', 'new two']);
    expect(updated.updatedAt, DateTime.utc(2026, 1, 4));
    expect(
      ((await repository.get(discussion.id)) as DocFound).node.status,
      DocumentStatus.open,
    );
  });

  test('missing documents and invalid anchors fail clearly', () async {
    await expectLater(
      service.answerQuestion(const NodeId('nope'), question: '?'),
      throwsStateError,
    );
    await repository.save(_root());
    await expectLater(
      service.openDiscussion(
        parentId: const NodeId('root'),
        parentBlockId: const NodeId('bad'),
        title: 'x',
      ),
      throwsStateError,
    );
  });
}

extension on StreamController<DocumentAgentEvent> {
  Future<void> emitCompleted(String text) async {
    add(DocumentAgentDelta(text));
    add(DocumentAgentCompleted(text));
    await close();
  }

  Future<void> emitDeltaOnly(String text) async {
    add(DocumentAgentDelta(text));
    await close();
  }
}
