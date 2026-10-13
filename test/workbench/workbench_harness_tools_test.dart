import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/workbench/workbench_harness_tools.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_harness/src/tools/fs_tools.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

void main() {
  test(
    'harness tool only stages shared scope; stale/unbound callers refuse',
    () async {
      final repo = InMemoryDocumentRepository();
      final node = DocumentNode(
        id: const NodeId('article'),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        blocks: const [
          Block(
            id: NodeId('shared'),
            type: BlockType.paragraph,
            content: 'Shared claim',
          ),
          Block(
            id: NodeId('private'),
            type: BlockType.paragraph,
            content: 'Private text',
          ),
        ],
      );
      await repo.save(node);
      final owner = WorkbenchOwner(repo);
      var current = true;
      var bound = true;
      final world = World();
      final context = HostToolExtensionContext(
        world: world,
        workspace: Directory.systemTemp,
        taskId: 'task-1',
        fileLocks: FileLockTable(),
        editOwner: Object(),
        reviewProposals: ReviewProposalLedger(),
        authorizeIssuedProposal: (_) async => false,
        isCurrent: () => current,
        isCallerBound: () => bound,
      );
      final tools = workbenchHarnessTools(
        owner,
        const SharedWorkbenchScope(
          project: 'article',
          block: 'shared',
          content: 'Shared claim',
        ),
        context,
      );
      final read = await tools.first.execute(null);
      expect('$read', contains('Shared claim'));
      expect('$read', isNot(contains('Private text')));
      await tools.last.execute({
        'text': 'Suggested claim',
        'reason': 'Source needs qualification',
      });
      expect(
        (await owner.read('article')).blocks.first.content,
        'Shared claim',
      );
      final state = await owner.state('article');
      final proposals = state['proposals'] as Map;
      expect((proposals.values.single as Map)['status'], 'staged');
      bound = false;
      await expectLater(
        tools.last.execute({'text': 'Denied', 'reason': 'x'}),
        throwsA(isA<WorkbenchRefusal>()),
      );
      bound = true;
      current = false;
      await expectLater(
        tools.first.execute(null),
        throwsA(isA<WorkbenchRefusal>()),
      );
    },
  );
}
