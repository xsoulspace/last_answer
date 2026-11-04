import 'package:ecsly_boards/ecsly_boards.dart' show BoardTaskStatus;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/board_view.dart';
import 'package:lastanswer/coding_agent/planning_board_controller.dart';

/// The boards view (stage 4): every op through the real
/// `ecsly_boards` substrate, keyed for the agent contract (DESIGN law:
/// widget keys are the UI contract). The card affordances are always
/// visible quiet buttons (board.op.*) — one tap per op, no selection
/// machine.
void main() {
  Future<void> pumpBoard(
    final WidgetTester tester,
    final PlanningBoardController controller,
  ) => tester.pumpWidget(
    MaterialApp(home: Scaffold(body: BoardView(controller: controller))),
  );

  testWidgets('an empty board shows the default lanes', (final tester) async {
    await pumpBoard(tester, PlanningBoardController());
    expect(find.byKey(const ValueKey('board.column.backlog')), findsOneWidget);
    expect(find.byKey(const ValueKey('board.column.doing')), findsOneWidget);
    expect(find.byKey(const ValueKey('board.column.done')), findsOneWidget);
    expect(find.byKey(const ValueKey('board.add.backlog')), findsOneWidget);
  });

  testWidgets('adding a card lands it ranked in its lane', (
    final tester,
  ) async {
    await pumpBoard(tester, PlanningBoardController());
    await tester.enterText(
      find.byKey(const ValueKey('board.add.backlog')),
      'ship the board view',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('ship the board view'), findsOneWidget);
    expect(find.text('backlog (1)'), findsOneWidget);
  });

  testWidgets('move a card a lane, settle it done', (final tester) async {
    final controller = PlanningBoardController();
    controller.addCard(title: 'write the schema', column: 'backlog');
    await pumpBoard(tester, controller);

    await tester.tap(find.byKey(const ValueKey('board.op.next')));
    await tester.pump();

    final moved = controller.cardsOf('doing').single;
    expect(moved.title, 'write the schema');
    expect(moved.rank, isNotNull);

    await tester.tap(find.byKey(const ValueKey('board.op.done')));
    await tester.pump();

    expect(
      controller.cardsOf('doing').single.status,
      BoardTaskStatus.completed,
    );
  });

  testWidgets('decomposition adds a ranked child from the row', (
    final tester,
  ) async {
    final controller = PlanningBoardController();
    controller.addCard(title: 'ship the board', column: 'backlog');
    await pumpBoard(tester, controller);

    await tester.tap(find.byKey(const ValueKey('board.op.decompose')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('board.child.input')),
      'schema v2',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    final children = controller.cardsOf('backlog');
    expect(children, hasLength(2));
    expect(children.last.title, 'schema v2');
    expect(children.last.rank, isNotNull);
  });
}
