// PLAN 9 — "Queue + cooled turns" (ADR 0011 §"Implementation mapping —
// the queue rides the frontier"; conversation-model.md state machine).
//
// Every scenario drives the REAL surface keys (DESIGN §8): queue while
// running, steer default, flush order on verdict, edit queued, cancel
// queued (superseded — queryable), send-now (reject perm → stop →
// partial-spend verdict → immediate turn), cooled-turn edit with the
// EDITED annotation + history expand. The scripted mover keeps the
// harness LLM-free.
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

ProjectModelDoc _agentDoc() => ProjectModel.emptyAgent() as ProjectModelDoc;

Finder _keyPrefix(final String prefix) => find.byWidgetPredicate(
  (final w) => switch (w.key) {
    final ValueKey<String> k => k.value.startsWith(prefix),
    _ => false,
  },
);

/// Row-level actions are InkWells — this excludes the composer's
/// `send now ⌘⏎` TextButton, which shares the sendNow key prefix.
Finder _rowAction(final String prefix) => find.byWidgetPredicate(
  (final w) => switch ((w, w.key)) {
    (InkWell(), final ValueKey<String> k) => k.value.startsWith(prefix),
    _ => false,
  },
);

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('lastanswer_queue');
    File('${workspace.path}/main.dart').writeAsStringSync(
      "void main() { throw StateError('not implemented'); }\n",
    );
  });

  tearDown(() {
    try {
      workspace.deleteSync(recursive: true);
    } on Object {
      // best effort
    }
  });

  Future<HarnessSessionController> pumpSurface(
    final WidgetTester tester,
    final List<ProjectModelDoc> docUpdates,
  ) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) =>
            ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
      ),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(
            doc: _agentDoc(),
            controller: controller,
            onDocChanged: docUpdates.add,
          ),
        ),
      ),
    );
    await tester.pump();
    return controller;
  }

  Future<void> bindAndDelegate(
    final WidgetTester tester,
    final HarnessSessionController controller,
    final String task,
  ) async {
    await tester.enterText(
      find.byKey(const Key('coding_agent.workspace')),
      workspace.path,
    );
    await tester.enterText(find.byKey(const Key('coding_agent.task')), task);
    await tester.tap(find.byKey(const Key('coding_agent.delegate')));
    await tester.pump();
  }

  /// Submits [text] from the composer while a turn is running (⏎ =
  /// steer, the default) — the composer NEVER blocks.
  Future<void> steerFromComposer(
    final WidgetTester tester,
    final String text,
  ) async {
    await tester.enterText(find.byKey(const Key('coding_agent.task')), text);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
  }

  /// Drives the turn sequence to [want] turns: every flushed turn runs
  /// the scripted mover's write (a permission round-trip each), so the
  /// user-actor allows each prompt as it surfaces, through the REAL
  /// permission row.
  Future<void> drainTurns(
    final WidgetTester tester,
    final HarnessSessionController controller, {
    required final int want,
  }) async {
    for (var i = 0; i < 1200; i++) {
      if (controller.pendingPermission != null) {
        await tester.tap(
          find.byKey(const Key('coding_agent.permission.allow')),
        );
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      final turns = controller.current?.turns ?? const <HarnessTurn>[];
      if (turns.length >= want && !controller.isRunning) return;
    }
    fail(
      'turns did not drain to $want: '
      '${controller.current?.turns.length} turns, '
      'running=${controller.isRunning}',
    );
  }

  testWidgets(
    'steer default: submitting while running queues the message '
    '(STEER + position), and the queue flushes IN ORDER when the '
    "running turn's verdict lands (one verdict per turn)",
    (final tester) async {
      final docUpdates = <ProjectModelDoc>[];
      final controller = await pumpSurface(tester, docUpdates);

      await bindAndDelegate(tester, controller, 'Fix main.dart.');
      await pumpUntil(tester, () => controller.pendingPermission != null);
      await tester.pump();

      // The composer does not block: two submits join the queue.
      await steerFromComposer(tester, 'second message');
      await steerFromComposer(tester, 'third message');
      await tester.pump();

      expect(
        find.textContaining('STEER 1'),
        findsOneWidget,
        reason: 'queued rows render with lane position (DESIGN §10)',
      );
      expect(find.textContaining('STEER 2'), findsOneWidget);
      expect(find.text('second message'), findsOneWidget);
      expect(find.text('third message'), findsOneWidget);
      expect(controller.queue.openInLane().length, 2);
      expect(
        AgentDocSurface.debugState!.queue
            .where((final q) => q.status == 'open')
            .length,
        2,
        reason: 'the projection carries the same queue the human sees',
      );
      expect(
        AgentDocSurface.debugState!.queue.first.position,
        1,
        reason: 'open steps carry their 1-based lane position',
      );

      // The verdict of turn 1 lands → the queue flushes IN ORDER:
      // second message becomes turn 2, third becomes turn 3.
      await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
      await drainTurns(tester, controller, want: 3);
      await tester.pump();

      final turns = controller.current!.turns;
      expect(turns, hasLength(3));
      expect(turns[1].taskSentence, 'second message');
      expect(turns[2].taskSentence, 'third message');
      expect(turns[1].verdictLine, contains('PASS'));
      expect(turns[2].verdictLine, contains('PASS'));
      expect(controller.queue.openInLane(), isEmpty);
      expect(
        controller.queue.steps.every(
          (final s) => s.status == QueueStepStatus.delivered,
        ),
        isTrue,
        reason: 'delivered steps stay queryable (never silently dropped)',
      );

      // The durable copy lives in the doc payload (step-shaped).
      final payloadBlocks = docUpdates.last.blocks
          .where((final b) => b.id.value.startsWith('queue-lane-'))
          .toList();
      expect(payloadBlocks, hasLength(1));
      final payload = jsonDecode(payloadBlocks.first.content)
          as Map<String, Object?>;
      expect(payload['from'], 'human');
      expect(payload['to'], 'agent');
      expect(
        (payload['steps']! as List<Object?>).length,
        2,
        reason: 'the payload history keeps delivered steps queryable',
      );
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  testWidgets(
    'edit queued: the row re-opens in place (it is just text) and the '
    'edited claim is what the next turn receives',
    (final tester) async {
      final docUpdates = <ProjectModelDoc>[];
      final controller = await pumpSurface(tester, docUpdates);

      await bindAndDelegate(tester, controller, 'Fix main.dart.');
      await pumpUntil(tester, () => controller.pendingPermission != null);
      await steerFromComposer(tester, 'second message');
      await tester.pump();

      await tester.tap(_keyPrefix('coding_agent.queue.edit.'));
      await tester.pump();
      await tester.enterText(
        _keyPrefix('coding_agent.queue.edit.field.'),
        'second message, EDITED',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(find.text('second message, EDITED'), findsOneWidget);
      expect(
        controller.queue.steps.first.text,
        'second message, EDITED',
        reason: 'the step claim edits before it is worked',
      );

      await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
      await drainTurns(tester, controller, want: 2);
      expect(
        controller.current!.turns[1].taskSentence,
        'second message, EDITED',
      );
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  testWidgets(
    'cancel queued: the step is marked SUPERSEDED (queryable in the '
    'projection AND the payload — never silently dropped) and is skipped '
    'by the flush',
    (final tester) async {
      final docUpdates = <ProjectModelDoc>[];
      final controller = await pumpSurface(tester, docUpdates);

      await bindAndDelegate(tester, controller, 'Fix main.dart.');
      await pumpUntil(tester, () => controller.pendingPermission != null);
      await steerFromComposer(tester, 'cancelled message');
      await steerFromComposer(tester, 'kept message');
      await tester.pump();

      // Two queued rows carry cancel actions — target the FIRST row
      // ('cancelled message', rendered furthest from the composer).
      await tester.tap(_keyPrefix('coding_agent.queue.cancel.').last);
      await tester.pump();

      expect(find.textContaining('STEER 1'), findsOneWidget);
      expect(find.text('cancelled message'), findsNothing);
      expect(controller.queue.openInLane().map((final s) => s.text), [
        'kept message',
      ]);
      expect(
        controller.queue.steps
            .where((final s) => s.status == QueueStepStatus.superseded)
            .map((final s) => s.text),
        ['cancelled message'],
        reason: 'cancellation is superseded — queryable, not dropped',
      );

      await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
      await drainTurns(tester, controller, want: 2);
      await tester.pump();

      expect(controller.current!.turns[1].taskSentence, 'kept message');
      expect(controller.current!.turns, hasLength(2));
      final payload = jsonDecode(
        docUpdates.last.blocks
            .firstWhere((final b) => b.id.value.startsWith('queue-lane-'))
            .content,
      )
          as Map<String, Object?>;
      final statuses = (payload['steps']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map((final s) => s['status']);
      expect(
        statuses,
        containsAll(<String>['superseded', 'delivered']),
        reason: 'the payload keeps the superseded step queryable',
      );
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  testWidgets(
    'send-now: rejects the pending permission FIRST → stops the running '
    'turn → the verdict LANDS with honest partial spend (no fabricated '
    'figures) → the immediate message becomes the new turn',
    (final tester) async {
      final docUpdates = <ProjectModelDoc>[];
      final controller = await pumpSurface(tester, docUpdates);

      await bindAndDelegate(tester, controller, 'Fix main.dart.');
      await pumpUntil(tester, () => controller.pendingPermission != null);
      await steerFromComposer(tester, 'immediate message');
      await tester.pump();

      // The explicit send-now on the queued row.
      await tester.tap(_rowAction('coding_agent.queue.sendNow.'));
      await tester.pump();

      // The pending permission was rejected first (deny = the write never
      // lands), and the turn was stopped.
      expect(
        controller.current!.turns.first.permissions.first.allowed,
        isFalse,
        reason: 'reject-first ordering (DESIGN §4)',
      );
      await pumpUntil(
        tester,
        () => controller.current != null && !controller.current!.running,
      );
      await tester.pump();

      final interrupted = controller.current!.turns.first;
      expect(interrupted.interrupted, isTrue);
      expect(interrupted.spend, isNull,
          reason: 'no spend figures exist for a cancelled turn — the '
              'surface must not fabricate them');
      expect(
        find.textContaining('INTERRUPTED'),
        findsWidgets,
        reason: 'the interrupted verdict lands as data',
      );
      expect(
        find.textContaining(' tok'),
        findsNothing,
        reason: 'an interrupted verdict must never render token figures',
      );
      expect(
        find.textContaining('decisions'),
        findsNothing,
        reason: 'nor decision counts — only truly observed numbers',
      );
      expect(
        File('${workspace.path}/main.dart').readAsStringSync(),
        contains('StateError'),
        reason: 'the rejected write never landed',
      );

      // The flush delivers the immediate message as the NEW turn.
      await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
      await drainTurns(tester, controller, want: 2);
      expect(controller.current!.turns[1].taskSentence, 'immediate message');
      expect(controller.current!.turns[1].verdictLine, contains('PASS'));
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  testWidgets(
    'cooled turns are editable: the edit adds a dim EDITED SYS annotation '
    'with tap-to-expand prior versions, and the history persists into '
    'the doc payload',
    (final tester) async {
      final docUpdates = <ProjectModelDoc>[];
      final controller = await pumpSurface(tester, docUpdates);

      await bindAndDelegate(tester, controller, 'Fix main.dart.');
      await pumpUntil(tester, () => controller.pendingPermission != null);
      await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
      await pumpUntil(
        tester,
        () => controller.current != null && !controller.current!.running,
      );
      await tester.pump();

      // Live turns stay locked; cooled turns carry the [edit] affordance.
      expect(
        _keyPrefix('coding_agent.turn.edit.'),
        findsOneWidget,
        reason: 'the cooled turn is editable like document text',
      );
      await tester.tap(_keyPrefix('coding_agent.turn.edit.'));
      await tester.pump();
      await tester.enterText(
        _keyPrefix('coding_agent.turn.edit.field.'),
        'Fix main.dart. (clarified by the human)',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(
        controller.current!.turns.first.taskSentence,
        contains('clarified'),
      );
      expect(
        find.textContaining('EDITED · 1 prior version'),
        findsOneWidget,
        reason: 'the edit gains a dim EDITED SYS annotation',
      );

      // Tap-to-expand shows the turn's prior version.
      await tester.tap(_keyPrefix('coding_agent.turn.history.toggle.'));
      await tester.pump();
      expect(find.text('Fix main.dart.'), findsOneWidget);

      // Per-turn edit history persists into the doc payload.
      expect(
        docUpdates.last.blocks
            .where((final b) => b.id.value == 'agent-turn-history'),
        hasLength(1),
      );
      final restored = controller.turnHistory;
      expect(restored, hasLength(1));
      expect(restored.values.single, ['Fix main.dart.']);
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
