import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/scripted_session_handle.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/answer_rail.dart';
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/app.dart'
    show WorkbenchMemory;
import 'package:xsoulspace_agentic_harness_inspector/src/source.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/trace.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// A scripted EXTERNAL source: the pane samples whatever a
/// [WorldInspectorPane.externalOverride] carries, verbatim.
class ScriptedTraceSource extends TraceSource {
  @override
  Future<InspectorTrace?> sample() async => const InspectorTrace(
    rows: [],
    metrics: {'sessionId': 'foreign-daemon', 'running': false},
  );
}

void main() {
  setUp(() {
    // The bench memory is static per world key — a clean bench per test.
    WorkbenchMemory.clearAll();
  });

  group('ScriptedSessionHandle', () {
    test('delegateTask appends the sentence and an honest ack beat', () {
      final handle = ScriptedSessionHandle(sessionId: 's1');
      final result = handle.delegateTask('fix the failing test');
      expect(result.ok, isTrue);
      final beats = handle.state.beats;
      expect(beats, hasLength(2));
      expect(beats.first.name, 'you');
      expect(beats.first.detail, 'fix the failing test');
      expect(beats.last.detail, contains('no actor ran'));
      expect(handle.state.turnCount, 1);
    });

    test('delegateTask refuses an empty sentence', () {
      final handle = ScriptedSessionHandle(sessionId: 's1');
      expect(handle.delegateTask('   ').ok, isFalse);
    });

    test('answerPermission resolves exactly once, deny-by-default', () {
      final handle = ScriptedSessionHandle(
        sessionId: 's1',
        pendingPermissionTitle: 'Write lib/x.dart',
      );
      expect(handle.answerPermission(allow: false).ok, isTrue);
      expect(handle.state.pendingPermissionTitle, isNull);
      expect(handle.state.beats.last.name, 'perm');
      expect(handle.state.beats.last.detail, contains('reject'));
      // Nothing pending → refused (never a silent no-op).
      expect(handle.answerPermission(allow: true).ok, isFalse);
    });

    test('seed fixture: a running worker and a blocked planner', () {
      final seeded = seedScriptedSessions();
      expect(seeded.keys, containsAll(['seed-worker', 'seed-planner']));
      final worker = seeded['seed-worker']!;
      expect(worker.state.running, isTrue);
      expect(
        worker.state.beats.map((final b) => b.name),
        contains('tool:dart_test'),
      );
      final planner = seeded['seed-planner']!;
      expect(planner.state.running, isFalse);
      expect(planner.state.pendingPermissionTitle, isNotNull);
      expect(planner.state.spend, isNotNull);
      // Seeded data never reads as a live run (DESIGN §6).
      expect(worker.kind, 'test');
    });
  });

  group('RegistrySource over scripted sessions', () {
    test('projects beats into rows and the verdict into a stop row', () async {
      final registry = HarnessSessionRegistry();
      final handle = seedScriptedSessions()['seed-planner']!;
      registry.register('seed-planner', handle);
      final trace = await RegistrySource(registry: registry).sample();
      expect(trace, isNotNull);
      final rows = trace!.rows;
      // One row per beat + one stop row for the verdict.
      expect(rows, hasLength(handle.state.beats.length + 1));
      expect(
        rows.any((final r) => (r.detail ?? '').contains('dstep_1')),
        isTrue,
      );
      expect(rows.last.kind.name, contains('stop'));
      expect(trace.metrics['sessionId'], 'seed-planner');
      expect(trace.metrics['spend'], contains('12300tok'));
    });

    test('an empty registry samples null (honest absence)', () async {
      final trace = await RegistrySource(
        registry: HarnessSessionRegistry(),
      ).sample();
      expect(trace, isNull);
    });
  });

  group('WorldInspectorPane widget', () {
    testWidgets(
      'fullscreen expansion uses finite remaining space '
      'and reveals Answer Rail',
      (tester) async {
        final registry = HarnessSessionRegistry()
          ..register('seed-planner', seedScriptedSessions()['seed-planner']!)
          ..focused = 'seed-planner';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 48, child: Text('WORLD INSPECTOR')),
                    Expanded(
                      child: WorldInspectorPane(
                        registry: registry,
                        expandedHeight: double.infinity,
                        showScene: false,
                        pollInterval: const Duration(milliseconds: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.byKey(const Key('world_inspector.toggle')));
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        final pane = tester.getRect(
          find.byKey(const Key('world_inspector.pane')),
        );
        expect(pane.height, greaterThan(0));
        expect(pane.height.isFinite, isTrue);
        final fullscreen = tester.getRect(find.byType(Scaffold));
        expect(pane.bottom, lessThanOrEqualTo(fullscreen.bottom));
        expect(find.byType(AnswerRail), findsOneWidget);
        expect(
          find.bySemanticsLabel(RegExp('answer rail.*top: perm:')),
          findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 10));
      },
    );

    testWidgets('rule lists sessions; expanding renders the bands', (
      final tester,
    ) async {
      final seeded = seedScriptedSessions();
      final registry = HarnessSessionRegistry()
        ..register('seed-planner', seeded['seed-planner']!)
        ..register('seed-worker', seeded['seed-worker']!)
        ..focused = 'seed-worker';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WorldInspectorPane(
                  registry: registry,
                  pollInterval: const Duration(milliseconds: 10),
                  showScene: false,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      // The rule is the L0 layer: one line, the TOP NEED (S2) — the
      // planner's pending permission outranks the ambient running count.
      expect(
        find.textContaining('needs you', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'perm: Write lib/src/registry.dart',
          findRichText: true,
        ),
        findsOneWidget,
      );
      // The headless projection carries the same needs (equal readers);
      // the title carries the age word (the fixture opened it ~2m ago).
      final needJson = WorldInspectorPane.lastProjection?.needs.first.toJson();
      expect(needJson?['severity'], 'permission');
      expect(
        needJson?['title'],
        stringContainsInOrder([
          'perm: Write lib/src/registry.dart',
          'waiting',
          'seed-planner',
        ]),
      );
      // Collapsed: no canvas yet.
      expect(find.byKey(const Key('world_inspector.pane')), findsNothing);

      await tester.tap(find.byKey(const Key('world_inspector.toggle')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byKey(const Key('world_inspector.pane')), findsOneWidget);
      // World-as-canvas (S2): the world owns the surface, slates closed.
      // The rail's running item echoes the worker's LAST beat as its
      // detail — the only beat ink visible until a slate is summoned.
      expect(
        find.textContaining('34 passed', findRichText: true),
        findsOneWidget,
      );
      // The ONE needs source law: the rail speaks the FLEET aggregate the
      // rule speaks — the planner's permission ranks first, the focused
      // worker's running row follows. (It never again says "1 need" while
      // the rule says "1 needs you · perm: …".)
      expect(
        find.bySemanticsLabel(RegExp('answer rail · 2 needs · top: perm:')),
        findsOneWidget,
      );
      // The registry law: bands sample the FOCUSED session only — the
      // planner's beats show in the rule, never in the worker's trace.
      expect(find.textContaining('dstep_1', findRichText: true), findsNothing);
      // Summon the view slate; the beats appear; the planner's stay absent.
      await tester.tap(find.bySemanticsLabel('view dock'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        find.textContaining('34 passed', findRichText: true),
        findsWidgets,
      );
      expect(find.textContaining('dstep_1', findRichText: true), findsNothing);
      // showScene: false → the honest off placeholder fills the canvas.
      expect(find.bySemanticsLabel('world scene off'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });

    testWidgets('the palette runs product verbs over the canvas', (
      final tester,
    ) async {
      final seeded = seedScriptedSessions();
      final planner = seeded['seed-planner']!;
      final registry = HarnessSessionRegistry()
        ..register('seed-planner', planner)
        ..register('seed-worker', seeded['seed-worker']!)
        ..focused = 'seed-worker';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WorldInspectorPane(
                  registry: registry,
                  pollInterval: const Duration(milliseconds: 10),
                  showScene: false,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const Key('world_inspector.toggle')));
      await tester.pump(const Duration(milliseconds: 50));
      // Open the palette (the one verb grammar, S4).
      await tester.tap(find.byKey(const Key('world_inspector.palette-toggle')));
      await tester.pump(const Duration(milliseconds: 50));
      // The roster: allow/reject for the planner's pending permission,
      // delegate for the running worker.
      expect(
        find.bySemanticsLabel(RegExp('command palette · 3 commands')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('command: allow — Write lib/src/registry.dart'),
        findsWidgets,
      );
      // Run ALLOW: the product answers through the registry — the planner
      // resolves, the palette closes, the rule returns to counts form.
      await tester.tap(
        find
            .bySemanticsLabel('command: allow — Write lib/src/registry.dart')
            .first,
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(planner.state.pendingPermissionTitle, isNull);
      expect(planner.state.beats.last.name, 'perm');
      expect(find.bySemanticsLabel(RegExp('command palette.*')), findsNothing);
      expect(
        find.textContaining('needs you', findRichText: true),
        findsNothing,
      );
      expect(find.textContaining('2 session(s)'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });

    testWidgets('gate sequence: slate open/close, projection flip, palette', (
      final tester,
    ) async {
      final seeded = seedScriptedSessions();
      final registry = HarnessSessionRegistry()
        ..register('seed-planner', seeded['seed-planner']!)
        ..register('seed-worker', seeded['seed-worker']!)
        ..focused = 'seed-worker';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WorldInspectorPane(
                  registry: registry,
                  pollInterval: const Duration(milliseconds: 10),
                  showScene: false,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const Key('world_inspector.toggle')));
      await tester.pump(const Duration(milliseconds: 50));
      // Projection chip exists over the canvas.
      expect(find.bySemanticsLabel('canvas · world'), findsOneWidget);
      // Open then close the view slate.
      await tester.tap(find.bySemanticsLabel('view dock'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.bySemanticsLabel('slate panel · view'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('view dock'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.bySemanticsLabel('slate panel · view'), findsNothing);
      // Flip to history: the time spine replaces the world.
      await tester.tap(find.bySemanticsLabel('canvas · world'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        find.bySemanticsLabel(RegExp('time spine · 3 rows.*')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('world scene off'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });

    testWidgets('external attach: the pane observes a foreign world, '
        'read-only', (final tester) async {
      final registry = HarnessSessionRegistry()
        ..register('seed-worker', seedScriptedSessions()['seed-worker']!)
        ..focused = 'seed-worker';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorldInspectorPane(
              registry: registry,
              pollInterval: const Duration(milliseconds: 10),
              showScene: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      // Attach an EXTERNAL source (the http-facade route stands in here
      // with a scripted source — the pane treats every override alike).
      WorldInspectorPane.externalOverride.value = ScriptedTraceSource();
      await tester.pump(const Duration(milliseconds: 50));
      // The rule names the mode; the sampled session is the external one.
      expect(find.textContaining('EXTERNAL (read-only)'), findsOneWidget);
      expect(
        WorldInspectorPane.lastProjection?.sampledSession,
        'foreign-daemon',
      );
      // Detach returns to the in-process registry.
      WorldInspectorPane.externalOverride.value = null;
      await tester.pump(const Duration(milliseconds: 50));
      expect(WorldInspectorPane.lastProjection?.sampledSession, 'seed-worker');
      WorldInspectorPane.lastProjection = null;
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });

    testWidgets('empty registry: the rule instructs, never blanks', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorldInspectorPane(
              registry: HarnessSessionRegistry(),
              pollInterval: const Duration(milliseconds: 10),
              showScene: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('no live sessions'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });

    testWidgets('the headless projection follows the pane', (
      final tester,
    ) async {
      final registry = HarnessSessionRegistry()
        ..register('seed-worker', seedScriptedSessions()['seed-worker']!)
        ..focused = 'seed-worker';
      WorldInspectorPane.lastProjection = null;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorldInspectorPane(
              registry: registry,
              pollInterval: const Duration(milliseconds: 10),
              showScene: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      final projection = WorldInspectorPane.lastProjection;
      expect(projection, isNotNull);
      expect(projection!.sampledRows, 3); // the worker's three beats
      expect(projection.sampledSession, 'seed-worker');
      expect(projection.sessions.first.running, isTrue);
      // No attention need anywhere → the rule stays in counts form.
      expect(projection.needs, isEmpty);
      expect(find.textContaining('session(s)'), findsOneWidget);
      expect(find.textContaining('1 running'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    });
  });
}
