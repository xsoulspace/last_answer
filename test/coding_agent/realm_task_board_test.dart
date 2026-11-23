import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/ui_boards/realm_task_board.dart';
import 'package:material_ui/material_ui.dart';

import '../shell/hermetic_world_state.dart';

/// The realm coordination board (ADR 0039): the durable queue rendered
/// in canonical lanes over the journal projection — never a second
/// store. The lane word comes from `cardStatusOfQueue` (the ONE
/// vocabulary law: `unknown` renders failed), the workspace scoping is
/// a FILTER (owner decision: all / per workspace), and the attention
/// preset keeps unproven settlements visible.
void main() {
  Future<void> pumpBoard(
    final WidgetTester tester,
    final WorldStateService world,
  ) => tester.pumpWidget(
    MaterialApp(
      // The kit overlay host: LaSelect/LaTooltip build PortalTargets
      // even while closed (the house pattern).
      builder: (final context, final child) =>
          Portal(child: child ?? const SizedBox.shrink()),
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: Scaffold(body: RealmTaskBoard(world: world)),
    ),
  );

  testWidgets('queue states render in canonical lanes; unknown is honest '
      'failure', (final tester) async {
    final world = hermeticWorldState(daemonLive: true);
    addTearDown(world.dispose);
    world.debugTasksOverride = const [
      WorldTaskRow(
        taskId: 'task-queued',
        state: 'queued',
        task: 'fix the shell test',
        terminal: false,
      ),
      WorldTaskRow(
        taskId: 'task-started',
        state: 'started',
        task: 'wire the board feed',
        terminal: false,
        modelId: 'modelscope_qwen38max',
      ),
      WorldTaskRow(
        taskId: 'task-done',
        state: 'succeeded',
        task: 'ship the schema',
        terminal: true,
      ),
      WorldTaskRow(
        taskId: 'task-unknown',
        state: 'unknown',
        task: 'the lease expired mid-run',
        terminal: true,
      ),
    ];
    await pumpBoard(tester, world);
    await tester.pump();

    expect(find.text('requested (1)'), findsOneWidget);
    expect(find.text('running (1)'), findsOneWidget);
    expect(find.text('completed (1)'), findsOneWidget);
    // The honesty law: an unproven settlement is a FAILED lane row,
    // never a success.
    expect(find.text('failed (1)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('board.realm.lane.failed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('board.realm.card.task-unknown.state')),
      findsOneWidget,
    );
    expect(find.text('cancelled (0)'), findsOneWidget);
  });

  testWidgets('attribution renders: origin actor, addressees, workspace', (
    final tester,
  ) async {
    final world = hermeticWorldState(daemonLive: true);
    addTearDown(world.dispose);
    world.debugTasksOverride = const [
      WorldTaskRow(
        taskId: 'task-1',
        state: 'leased',
        task: 'refactor the inbox',
        terminal: false,
        actorId: 'zcode-seat-1',
        addressees: ['agent-fixer'],
        projectId: 'proj-a',
      ),
    ];
    await pumpBoard(tester, world);
    await tester.pump();

    expect(
      find.text('by zcode-seat-1 · to agent-fixer · @proj-a'),
      findsOneWidget,
    );
  });

  testWidgets('a cancel riding live work marks the row and stays in the '
      'attention preset', (final tester) async {
    final world = hermeticWorldState(daemonLive: true);
    addTearDown(world.dispose);
    world.debugTasksOverride = const [
      WorldTaskRow(
        taskId: 'task-ride',
        state: 'started',
        task: 'long migration',
        terminal: false,
        cancelRequested: true,
      ),
    ];
    await pumpBoard(tester, world);
    await tester.pump();

    expect(find.text('cancel requested'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('board.realm.filter.attention')),
    );
    await tester.pump();
    // Still visible: a durable cancel on live work IS attention.
    expect(
      find.byKey(const ValueKey('board.realm.card.task-ride')),
      findsOneWidget,
    );
  });

  testWidgets('the attention preset drops settled rows, keeps running and '
      'unproven ones', (final tester) async {
    final world = hermeticWorldState(daemonLive: true);
    addTearDown(world.dispose);
    world.debugTasksOverride = const [
      WorldTaskRow(
        taskId: 'task-live',
        state: 'started',
        task: 'live work',
        terminal: false,
      ),
      WorldTaskRow(
        taskId: 'task-settled',
        state: 'succeeded',
        task: 'settled work',
        terminal: true,
      ),
      WorldTaskRow(
        taskId: 'task-unproven',
        state: 'unknown',
        task: 'unproven settlement',
        terminal: true,
      ),
    ];
    await pumpBoard(tester, world);
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey('board.realm.filter.attention')),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('board.realm.card.task-live')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('board.realm.card.task-unproven')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('board.realm.card.task-settled')),
      findsNothing,
    );
    // Off again — the settled row returns (the preset is a filter, not
    // a deletion).
    await tester.tap(
      find.byKey(const ValueKey('board.realm.filter.attention')),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('board.realm.card.task-settled')),
      findsOneWidget,
    );
  });

  testWidgets('the workspace filter narrows to one project; the all choice '
      'rests everything', (final tester) async {
    final world = hermeticWorldState(daemonLive: true);
    addTearDown(world.dispose);
    world.debugTasksOverride = const [
      WorldTaskRow(
        taskId: 'task-a',
        state: 'started',
        task: 'project A work',
        terminal: false,
        projectId: 'proj-a',
      ),
      WorldTaskRow(
        taskId: 'task-b',
        state: 'started',
        task: 'project B work',
        terminal: false,
        projectId: 'proj-b',
      ),
    ];
    await pumpBoard(tester, world);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('board.realm.card.task-a')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('board.realm.card.task-b')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('board.realm.filter.workspace')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('proj-b').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('board.realm.card.task-b')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('board.realm.card.task-a')), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('board.realm.filter.workspace')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('all workspaces').last);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('board.realm.card.task-a')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('board.realm.card.task-b')),
      findsOneWidget,
    );
  });

  testWidgets('tapping a row opens the shared durable detail', (
    final tester,
  ) async {
    final world = hermeticWorldState(daemonLive: true);
    addTearDown(world.dispose);
    world.debugTasksOverride = const [
      WorldTaskRow(
        taskId: 'task-open',
        state: 'queued',
        task: 'open me',
        terminal: false,
      ),
    ];
    await pumpBoard(tester, world);
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('board.realm.card.task-open')));
    await tester.pumpAndSettle();

    // One truth pane: the SAME detail dialog the inbox opens.
    expect(
      find.byKey(const ValueKey('inbox.task.task-open.detail')),
      findsOneWidget,
    );
  });

  testWidgets('no world service renders the honest quiet note', (
    final tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (final context, final child) =>
            Portal(child: child ?? const SizedBox.shrink()),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: const Scaffold(body: RealmTaskBoard(world: null)),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('board.realm')), findsOneWidget);
    expect(
      find.text('the realm journal is not open — no coordination to show'),
      findsOneWidget,
    );
  });
}
