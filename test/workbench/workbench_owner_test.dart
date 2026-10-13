import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';

DocumentNode article() => DocumentNode(
  id: const NodeId('article'),
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  blocks: const [
    Block(id: NodeId('a'), type: BlockType.heading, content: 'First', level: 1),
    Block(
      id: NodeId('b'),
      type: BlockType.paragraph,
      content: 'Keep the work close.',
    ),
    Block(
      id: NodeId('c'),
      type: BlockType.heading,
      content: 'Second',
      level: 1,
    ),
    Block(id: NodeId('d'), type: BlockType.paragraph, content: 'Other content'),
  ],
);

class InterruptedRepository implements DocumentRepository {
  final delegate = InMemoryDocumentRepository();
  bool failSettlement = false;
  bool effectWritten = false;
  @override
  Future<DocResult> get(NodeId id) => delegate.get(id);
  @override
  Future<void> save(DocumentNode node) async {
    if (failSettlement && effectWritten && node.kind == 'workbench_metadata') {
      failSettlement = false;
      throw StateError('process_ended_after_effect');
    }
    await delegate.save(node);
    if (failSettlement && node.id.value == 'article') effectWritten = true;
  }

  @override
  Future<void> delete(NodeId id) => delegate.delete(id);
  @override
  Future<List<NodeId>> allIds() => delegate.allIds();
  @override
  Future<List<NodeId>> childrenOf(NodeId? id) => delegate.childrenOf(id);
}

void main() {
  test('queued proposals require current revision and authorization', () async {
    final repo = InMemoryDocumentRepository();
    await repo.save(article());
    final owner = WorkbenchOwner(repo);
    Future<String> propose({String? revision, bool allowed = true}) =>
        owner.propose(
          project: 'article',
          actor: 'task:editing',
          intent: 'A scoped rewrite',
          operation: 'rewrite_block',
          arguments: {'block': 'b', 'text': 'Suggested'},
          expectedRevision: revision,
          authorizationStillValid: () => allowed,
        );
    await expectLater(
      propose(revision: 'old'),
      throwsA(isA<WorkbenchRefusal>()),
    );
    await expectLater(
      propose(allowed: false),
      throwsA(isA<WorkbenchRefusal>()),
    );
    expect((await owner.state('article'))['proposals'], isEmpty);
    final id = await propose(revision: workRevision(article()));
    final proposals = (await owner.state('article'))['proposals'] as Map;
    expect((proposals[id] as Map)['origin'], 'surfaceInput');
  });
  test(
    'moving section retains content ids and evidence after restart and undo',
    () async {
      final repo = InMemoryDocumentRepository();
      await repo.save(article());
      final owner = WorkbenchOwner(repo);
      await owner.linkEvidence(
        'article',
        claim: 'b',
        source: 'https://example.org/source',
        relation: EvidenceRelation.unresolved,
        actor: 'human',
      );
      final id = await owner.propose(
        project: 'article',
        actor: 'human',
        intent: 'Move section',
        operation: 'move_section',
        arguments: {'block': 'c', 'before': 'a'},
      );
      expect((await owner.read('article')).blocks.first.id.value, 'a');
      await owner.adopt('article', id);
      final restarted = WorkbenchOwner(repo);
      expect((await restarted.read('article')).blocks.map((b) => b.id.value), [
        'c',
        'd',
        'a',
        'b',
      ]);
      expect((await restarted.state('article'))['links'], isNotEmpty);
      await restarted.undo('article', id);
      expect(
        workRevision(await restarted.read('article')),
        workRevision(article()),
      );
    },
  );
  test('conflicting proposals refuse and undo protects a later edit', () async {
    final repo = InMemoryDocumentRepository();
    await repo.save(article());
    final owner = WorkbenchOwner(repo);
    Future<String> propose(String actor, String text) => owner.propose(
      project: 'article',
      actor: actor,
      intent: 'Rewrite claim',
      operation: 'rewrite_block',
      arguments: {'block': 'b', 'text': text},
    );
    final ids = await Future.wait([
      propose('human', 'Human'),
      propose('agent', 'Agent'),
    ]);
    await owner.adopt('article', ids[0]);
    await expectLater(
      owner.adopt('article', ids[1]),
      throwsA(isA<WorkbenchRefusal>()),
    );
    final third = await propose('human', 'Later');
    await owner.adopt('article', third);
    await expectLater(
      owner.undo('article', ids[0]),
      throwsA(isA<WorkbenchRefusal>()),
    );
    expect((await owner.read('article')).blocks[1].content, 'Later');
  });
  test(
    'restart reconciles an effect whose settlement was interrupted',
    () async {
      final repo = InterruptedRepository();
      await repo.save(article());
      final owner = WorkbenchOwner(repo);
      final id = await owner.propose(
        project: 'article',
        actor: 'human',
        intent: 'Move',
        operation: 'move_block',
        arguments: {'block': 'b', 'destination': 3},
      );
      repo.failSettlement = true;
      await expectLater(owner.adopt('article', id), throwsStateError);
      final restarted = WorkbenchOwner(repo);
      final state = await restarted.state('article');
      expect(((state['proposals'] as Map)[id] as Map)['status'], 'adopted');
      await restarted.undo('article', id);
      expect(
        workRevision(await restarted.read('article')),
        workRevision(article()),
      );
    },
  );
  test('split refuses surrogate boundary and retains original anchor', () {
    final node = article().withBlocks(const [
      Block(id: NodeId('b'), type: BlockType.paragraph, content: 'a😀b'),
    ]);
    expect(
      () => ArticleOperations.split(node, 'b', 2, 'new'),
      throwsA(isA<WorkbenchRefusal>()),
    );
    final result = ArticleOperations.split(node, 'b', 3, 'new');
    expect(result.first.id.value, 'b');
    expect(result.map((b) => b.content).join(), 'a😀b');
  });
  test(
    'adoption persists executable behaviour and a later candidate is stale',
    () async {
      final repo = InMemoryDocumentRepository();
      await repo.save(article());
      final owner = WorkbenchOwner(repo);
      final first = await owner.propose(
        project: 'article',
        actor: 'human',
        intent: 'No restore',
        operation: 'return_behaviour',
        arguments: {'restore': false, 'width': 600},
      );
      final second = await owner.propose(
        project: 'article',
        actor: 'agent',
        intent: 'Wider',
        operation: 'return_behaviour',
        arguments: {'width': 900},
      );
      await owner.adopt('article', first);
      await expectLater(
        owner.adopt('article', second),
        throwsA(isA<WorkbenchRefusal>()),
      );
      final state = await WorkbenchOwner(repo).state('article');
      expect(
        ReturnBehaviour.fromJson(
          Map<String, dynamic>.from(state['behaviour'] as Map),
        ).sequence,
        ['open', 'focus'],
      );
      await owner.undo('article', first);
      expect((await owner.state('article'))['behaviour'], isNull);
    },
  );
}
