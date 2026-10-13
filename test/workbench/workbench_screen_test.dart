import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/workbench/workbench_screen.dart';
import 'package:provider/provider.dart';
import 'package:universal_automation_interface/universal_automation_interface.dart';

void main() {
  testWidgets(
    'visible article proposal adopts and semantic action undoes same effect',
    (tester) async {
      tester.view.resetPhysicalSize();
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = InMemoryDocumentRepository();
      await repo.save(
        DocumentNode(
          id: const NodeId('article'),
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          blocks: const [
            Block(
              id: NodeId('one'),
              type: BlockType.paragraph,
              content: 'First paragraph',
            ),
            Block(
              id: NodeId('two'),
              type: BlockType.paragraph,
              content: 'Second paragraph',
            ),
          ],
        ),
      );
      await tester.pumpWidget(
        Provider<DocumentRepository>.value(
          value: repo,
          child: const MaterialApp(home: WorkbenchScreen(project: 'article')),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('block-one')));
      await tester.pump();
      await tester.tap(find.text('Inspect'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move down'));
      await tester.pumpAndSettle();
      final endpoint = WorkbenchScreen.endpoint!;
      final id = endpoint.state()['proposal'] as String;
      await tester.ensureVisible(find.byKey(ValueKey('adopt-$id')));
      await tester.tap(find.byKey(ValueKey('adopt-$id')));
      await tester.pumpAndSettle();
      final adopted = await repo.get(const NodeId('article')) as DocFound;
      expect(adopted.node.blocks.first.id.value, 'two');
      final result = await endpoint.act('undo', {
        'proposal': id,
        'project': 'article',
      }, InteractionOrigin.semanticAgent);
      await tester.pumpAndSettle();
      expect(result['ok'], true);
      expect(
        (await repo.get(const NodeId('article')) as DocFound)
            .node
            .blocks
            .first
            .id
            .value,
        'one',
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('dragging an executable edge stages a real behaviour proposal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = InMemoryDocumentRepository();
    await repo.save(
      DocumentNode(
        id: const NodeId('article'),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        blocks: const [
          Block(
            id: NodeId('claim'),
            type: BlockType.paragraph,
            content: 'Some work',
          ),
        ],
      ),
    );
    await tester.pumpWidget(
      Provider<DocumentRepository>.value(
        value: repo,
        child: const MaterialApp(home: WorkbenchScreen(project: 'article')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project opening connection'));
    await tester.pumpAndSettle();
    final operation = find.byKey(const ValueKey('restore-operation'));
    final edge = find.byKey(const ValueKey('project-opening-edge'));
    await tester.ensureVisible(operation);
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(tester.getCenter(operation));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(edge));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    final state = WorkbenchScreen.endpoint!.state();
    final metadata = state['metadata'] as Map;
    final proposal = ((metadata['proposals'] as Map).values.single as Map);
    expect((proposal['config'] as Map)['restore'], false);
    expect(proposal['status'], 'staged');
    expect((state['behaviour'] as Map)['restore'], true);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'narrow touch view exposes accessible controls without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = InMemoryDocumentRepository();
      await tester.pumpWidget(
        Provider<DocumentRepository>.value(
          value: repo,
          child: const MaterialApp(home: WorkbenchScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open sample article'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Project opening connection'));
      await tester.pumpAndSettle();
      expect(find.text('Restore position'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
