import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ecs_plugins/boards/planning_board_controller.dart';
import 'package:lastanswer/ui_boards/board_view.dart';
import 'package:lastanswer/ui_boards/delegation.dart';
import 'package:lastanswer/ui_boards/mesh_task_doc_link.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _noopOpen(final String _) {}

/// ADR 0039 stage 4 — dispatch is an op (ADR 0013): a planning card
/// admits as realm work through the shell-mounted seam; the ledger
/// remembers which card asked; a refusal renders in words; the ACP
/// session link opens the doc whose bridge served the turn.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpBoard(
    final WidgetTester tester,
    final PlanningBoardController controller, {
    final BoardDelegate? delegate,
    final BoardDelegationLedger? ledger,
  }) => tester.pumpWidget(
    MaterialApp(
      builder: (final context, final child) =>
          Portal(child: child ?? const SizedBox.shrink()),
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: Scaffold(
        body: BoardView(
          controller: controller,
          delegate: delegate,
          ledger: ledger,
        ),
      ),
    ),
  );

  testWidgets('the delegate op admits the card and records provenance', (
    final tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = PlanningBoardController();
    controller.addCard(title: 'ship the wiring', column: 'backlog');
    final ledger = BoardDelegationLedger();
    var delegatedTitle = '';
    await pumpBoard(
      tester,
      controller,
      ledger: ledger,
      delegate: (final title) async {
        delegatedTitle = title;
        return const BoardDelegationResult.admitted('task-abc123');
      },
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('board.op.delegate')));
    await tester.pumpAndSettle();

    expect(delegatedTitle, 'ship the wiring');
    expect(ledger.taskIdOf(controller.allCards.single.cardId), 'task-abc123');
    expect(
      find.byKey(
        ValueKey('board.card.${controller.allCards.single.cardId}.taskId'),
      ),
      findsOneWidget,
    );
    expect(find.text('→ task-abc123'), findsOneWidget);
  });

  testWidgets('a refusal renders in words, never a fabricated success', (
    final tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = PlanningBoardController();
    controller.addCard(title: 'the impossible task', column: 'backlog');
    final ledger = BoardDelegationLedger();
    await pumpBoard(
      tester,
      controller,
      ledger: ledger,
      delegate: (final _) async =>
          const BoardDelegationResult.refused('the world serves no seat'),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('board.op.delegate')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        ValueKey('board.card.${controller.allCards.single.cardId}.refusal'),
      ),
      findsOneWidget,
    );
    expect(find.text('the world serves no seat'), findsOneWidget);
    expect(ledger.taskIdOf(controller.allCards.single.cardId), isNull);
  });

  testWidgets('no seam, no delegate op — the board never dispatches by '
      'itself', (final tester) async {
    final controller = PlanningBoardController();
    controller.addCard(title: 'plain card', column: 'backlog');
    await pumpBoard(tester, controller);

    expect(find.byKey(const ValueKey('board.op.delegate')), findsNothing);
  });

  test('the ledger persists provenance across instances', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ledger = BoardDelegationLedger();
    await ledger.record('card-1', 'task-9');
    final reloaded = BoardDelegationLedger();
    await reloaded.ensureLoaded();
    expect(reloaded.taskIdOf('card-1'), 'task-9');
    expect(reloaded.taskIdOf('card-none'), isNull);
  });

  testWidgets('the mesh doc link opens the serving doc; absent docId '
      'renders nothing', (final tester) async {
    String? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              MeshTaskDocLink(
                verdict: const {'docId': 'spec-note', 'status': 'PASS'},
                onOpen: (final docId) => opened = docId,
              ),
              MeshTaskDocLink(
                verdict: const {'status': 'PASS'},
                onOpen: _noopOpen,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('boards.mesh.docLink.spec-note')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('boards.mesh.docLink.spec-note')));
    expect(opened, 'spec-note');
  });
}
