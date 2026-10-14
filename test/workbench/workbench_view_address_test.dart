import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/workbench/workbench_mcp_tools.dart';
import 'package:lastanswer/workbench/workbench_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'two views require explicit tool addresses and dispose independently',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
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
              id: NodeId('a'),
              type: BlockType.paragraph,
              content: 'Shared artifact',
            ),
          ],
        ),
      );
      var showLeft = true;
      late StateSetter rebuild;
      await tester.pumpWidget(
        Provider<DocumentRepository>.value(
          value: repo,
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return Row(
                  children: [
                    if (showLeft)
                      const Expanded(
                        key: ValueKey('left'),
                        child: WorkbenchScreen(
                          project: 'article',
                          viewerId: 'left',
                        ),
                      ),
                    const Expanded(
                      key: ValueKey('right'),
                      child: WorkbenchScreen(
                        project: 'article',
                        viewerId: 'right',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final entries = workbenchMcpEntries();
      final state = entries.firstWhere(
        (entry) => entry.name == 'workbench_state',
      );
      final action = entries.firstWhere(
        (entry) => entry.name == 'workbench_action',
      );
      expect(WorkbenchScreen.endpoint, isNull);
      expect(
        (await state.invokeDirect({})).data['error'],
        'workbench_view_ambiguous',
      );
      expect(
        (await action.invokeDirect({
          'action': 'select',
          'project': 'article',
          'arguments': jsonEncode({'object': 'a'}),
        })).data['error'],
        'workbench_view_ambiguous',
      );
      final selected = await action.invokeDirect({
        'viewerId': 'left',
        'action': 'select',
        'project': 'article',
        'arguments': jsonEncode({'object': 'a'}),
      });
      await tester.pumpAndSettle();
      expect(selected.data['ok'], isTrue);
      expect(WorkbenchScreen.endpoints['left']!.state()['selected'], 'a');
      expect(WorkbenchScreen.endpoints['right']!.state()['selected'], isNull);
      final right = WorkbenchScreen.endpoints['right'];
      rebuild(() => showLeft = false);
      await tester.pumpAndSettle();
      expect(WorkbenchScreen.endpoint, same(right));
      expect(
        (await state.invokeDirect({'viewerId': 'left'})).data['error'],
        'workbench_view_unknown',
      );
      expect(
        (await state.invokeDirect({'viewerId': 'right'})).data['ok'],
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(WorkbenchScreen.endpoints, isEmpty);
    },
  );

  for (final width in [320.0, 800.0, 1440.0]) {
    testWidgets(
      'document-first workbench fits width $width with enlarged text',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
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
                id: NodeId('a'),
                type: BlockType.paragraph,
                content: 'Shared artifact',
              ),
            ],
          ),
        );
        await WorkbenchOwner(
          repo,
        ).saveView('article', {'version': 999}, viewerId: 'reading');
        final frameDirectory = Platform.environment['HARNESS_FIRST_FRAMES'];
        if (frameDirectory != null) {
          await tester.runAsync(() async {
            final font = await File(
              '/System/Library/Fonts/Supplemental/Arial.ttf',
            ).readAsBytes();
            await (FontLoader(
              'HarnessFrameSans',
            )..addFont(Future.value(ByteData.sublistView(font)))).load();
          });
        }
        final frameKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: frameKey,
            child: Provider<DocumentRepository>.value(
              value: repo,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: frameDirectory == null
                    ? null
                    : ThemeData(fontFamily: 'HarnessFrameSans'),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.5),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
                home: const WorkbenchScreen(
                  project: 'article',
                  viewerId: 'reading',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('workbench-error')), findsOneWidget);
        expect(
          WorkbenchScreen.endpoints['reading']!.state()['projection'],
          'document',
        );
        expect(tester.takeException(), isNull);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(FocusManager.instance.primaryFocus, isNotNull);
        expect(
          FocusManager.instance.primaryFocus,
          isNot(same(FocusManager.instance.rootScope)),
        );
        if (frameDirectory != null) {
          await tester.runAsync(() async {
            final boundary =
                frameKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            try {
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await Directory(frameDirectory).create(recursive: true);
              await File(
                '$frameDirectory/workbench-${width.toInt()}.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
            } finally {
              image.dispose();
            }
          });
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  test(
    'stable viewer checkpoints coexist with legacy presentation state',
    () async {
      final repo = InMemoryDocumentRepository();
      await repo.save(
        DocumentNode(
          id: const NodeId('article'),
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          blocks: const [
            Block(
              id: NodeId('a'),
              type: BlockType.paragraph,
              content: 'Shared artifact',
            ),
          ],
        ),
      );
      final owner = WorkbenchOwner(repo);
      await owner.saveView('article', {'selected': 'legacy'});
      await owner.saveView('article', {
        'version': 1,
        'selected': 'a',
      }, viewerId: 'left');
      await owner.saveView('article', {
        'version': 1,
        'selected': null,
      }, viewerId: 'right');
      final restored = await WorkbenchOwner(repo).state('article');
      expect(restored['view'], {'selected': 'legacy'});
      expect(restored['views'], {
        'left': {'version': 1, 'selected': 'a'},
        'right': {'version': 1, 'selected': null},
      });
    },
  );
}
