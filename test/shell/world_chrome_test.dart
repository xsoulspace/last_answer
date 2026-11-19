import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/ui_chat/palette_health.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_shell/landing_inbox.dart';
import 'package:lastanswer/ui_models/models_view.dart';
import 'package:lastanswer/ui_shell/status_edge.dart';
import 'package:oka_supervisor/oka_supervisor.dart';

import 'hermetic_world_state.dart';

/// Phase 1d chrome: the status edge, the landing inbox and the Models
/// surface render the world's read model — honest segments, reject-first
/// permissions, the dynamic palette (a discovered document, never a
/// hardcoded cast) and the editor's harness-grade refusals.
Widget _wrap(final Widget child) => MaterialApp(
  // The kit overlay host (same shape as last_answer_app.dart):
  // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
  builder: (final context, final child) =>
      Portal(child: child ?? const SizedBox.shrink()),locale: const Locale('en'),
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: Scaffold(body: child),
);

Map<String, Object?> _paletteDoc() => {
  'model_palette': {
    'providers': {
      'modelscope': {
        'transport': 'openai_compatible',
        'base_url': 'https://api-inference.modelscope.ai/v1',
        'credential_env': 'MODELSCOPE_API_KEY',
        'models': [
          {'id': 'Qwen3.8-Max-Preview', 'max_tokens': 262144},
        ],
      },
      'openrouter': {
        'transport': 'openrouter',
        'credential_env': 'OPENROUTER_API_KEY',
        'models': [
          {'id': 'deepseek/deepseek-v4.1-flash-1017'},
        ],
      },
    },
    'cast': [
      {
        'id': 'modelscope_qwen38max',
        'provider': 'modelscope',
        'model': 'Qwen3.8-Max-Preview',
        'role': 'generative',
      },
      {
        'id': 'openrouter_deepseek',
        'provider': 'openrouter',
        'model': 'deepseek/deepseek-v4.1-flash-1017',
        'role': 'generative',
        'primary': true,
      },
      {'id': 'qwen', 'builtin': true, 'role': 'generative'},
      {'id': 'laya', 'builtin': true, 'role': 'decision'},
    ],
  },
};

void main() {
  group('the status edge', () {
    testWidgets('a live world with a palette names its primary rung', (
      final tester,
    ) async {
      final world = hermeticWorldState(daemonLive: true);
      await world.refresh();
      var modelsOpened = 0;
      var inboxOpened = 0;
      await tester.pumpWidget(
        _wrap(
          StatusEdge(
            world: world,
            onOpenModels: () => modelsOpened++,
            onOpenInbox: () => inboxOpened++,
          ),
        ),
      );

      expect(find.text('world live'), findsOneWidget);
      expect(find.text('mesh off'), findsOneWidget);
      expect(find.text('no palette declared'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('edge.backend')));
      await tester.pump();
      expect(modelsOpened, 1);

      await tester.tap(find.byKey(const ValueKey('edge.attention')));
      await tester.pump();
      expect(inboxOpened, 1);
      addTearDown(world.dispose);
    });

    testWidgets('attention counts permissions and running tasks, and the '
        'chosen rung rides the edge', (final tester) async {
      final world = hermeticWorldState(daemonLive: true);
      await world.refresh();
      world.debugPermissionsOverride = [
        InboxPermission(
          sessionId: 'doc-1',
          title: 'write to lib/shell/app_shell.dart',
          answer: (_) async {},
        ),
      ];
      world.debugTasksOverride = const [
        WorldTaskRow(
          taskId: 'task-1',
          state: 'queued',
          task: 'fix the shell test',
          terminal: false,
        ),
      ];
      world.selectRung('modelscope_qwen38max');
      await tester.pumpWidget(
        _wrap(
          StatusEdge(world: world, onOpenModels: () {}, onOpenInbox: () {}),
        ),
      );

      expect(find.text('attention: 1 permissions, 1 running'), findsOneWidget);
      expect(find.text('via modelscope_qwen38max'), findsOneWidget);
      addTearDown(world.dispose);
    });

    testWidgets('a down world shows the ONE-click arm', (final tester) async {
      final world = hermeticWorldState();
      await world.refresh();
      await tester.pumpWidget(
        _wrap(
          StatusEdge(world: world, onOpenModels: () {}, onOpenInbox: () {}),
        ),
      );

      expect(find.text('world down'), findsOneWidget);
      expect(find.byKey(const ValueKey('edge.arm')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('edge.arm')));
      await tester.pump();
      // The refusal is the segment's label — never a silent spinner.
      expect(find.textContaining('arm failed'), findsOneWidget);
      addTearDown(world.dispose);
    });
  });

  group('the landing inbox', () {
    testWidgets('permissions render reject-first and answer through the '
        'row callback', (final tester) async {
      final world = hermeticWorldState(daemonLive: true);
      await world.refresh();
      final answers = <bool>[];
      world.debugPermissionsOverride = [
        InboxPermission(
          sessionId: 'doc-1',
          title: 'write to lib/shell/app_shell.dart',
          kind: 'fs_write',
          answer: (final allow) async => answers.add(allow),
        ),
      ];
      await tester.pumpWidget(
        _wrap(LandingInbox(world: world, service: null, onOpenThread: (_) {})),
      );

      expect(find.text('write to lib/shell/app_shell.dart'), findsOneWidget);
      final deny = find.byKey(const ValueKey('inbox.perm.deny.doc-1'));
      final allow = find.byKey(const ValueKey('inbox.perm.allow.doc-1'));
      expect(deny, findsOneWidget);
      expect(allow, findsOneWidget);
      // Reject-first: Deny is the leading (leftmost) action.
      final denyBox = tester.getRect(deny);
      final allowBox = tester.getRect(allow);
      expect(denyBox.left, lessThan(allowBox.left));

      await tester.tap(deny);
      await tester.pump();
      expect(answers, [false]);
      addTearDown(world.dispose);
    });

    testWidgets('running tasks and last verdicts render as rows', (
      final tester,
    ) async {
      final world = hermeticWorldState(daemonLive: true);
      await world.refresh();
      world.debugTasksOverride = const [
        WorldTaskRow(
          taskId: 'task-1',
          state: 'queued',
          task: 'fix the failing shell test',
          terminal: false,
          modelId: 'modelscope_qwen38max',
        ),
      ];
      world.debugVerdictsOverride = const [
        WorldVerdictRow(
          id: 'task-0',
          state: 'succeeded',
          line: 'the note is written',
          spend: r'$0.012',
        ),
      ];
      await tester.pumpWidget(
        _wrap(LandingInbox(world: world, service: null, onOpenThread: (_) {})),
      );

      expect(find.byKey(const ValueKey('inbox.task.task-1')), findsOneWidget);
      expect(find.text('fix the failing shell test'), findsOneWidget);
      expect(find.text('modelscope_qwen38max'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('inbox.verdict.task-0')),
        findsOneWidget,
      );
      expect(find.text('the note is written'), findsOneWidget);
      addTearDown(world.dispose);
    });

    testWidgets('a live world with nothing open says so quietly', (
      final tester,
    ) async {
      final world = hermeticWorldState(daemonLive: true);
      await world.refresh();
      await tester.pumpWidget(
        _wrap(LandingInbox(world: world, service: null, onOpenThread: (_) {})),
      );

      expect(find.byKey(const ValueKey('inbox.quiet')), findsOneWidget);
      expect(find.text('Nothing needs attention'), findsOneWidget);
      addTearDown(world.dispose);
    });

    testWidgets('a down daemon arms from the inbox too', (final tester) async {
      final world = hermeticWorldState();
      await world.refresh();
      await tester.pumpWidget(
        _wrap(LandingInbox(world: world, service: null, onOpenThread: (_) {})),
      );

      expect(find.byKey(const ValueKey('inbox.arm')), findsOneWidget);
      expect(find.text('The ecsai world is not running'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('inbox.arm.button')));
      await tester.pump();
      expect(find.textContaining('Arm failed'), findsOneWidget);
      addTearDown(world.dispose);
    });
  });

  group('the Models surface (the dynamic palette)', () {
    late Directory temp;
    late String worldHome;
    late WorldStateService world;

    Future<void> mountModels(final WidgetTester tester) async {
      temp = Directory.systemTemp.createTempSync('models_view_');
      RealmWorld.debugDeviceHome = temp.path;
      worldHome = '${temp.path}/worlds/local';
      Directory('$worldHome/.xsoulspace').createSync(recursive: true);
      // The global-config law (2026-11-19): the DEVICE home carries the
      // palette (and the ladder) — the default file the chain reads.
      Directory('${temp.path}/.xsoulspace').createSync(recursive: true);
      File('${temp.path}/.xsoulspace/config.json').writeAsStringSync(
        jsonEncode({
          'model_palette': _paletteDoc()['model_palette'],
          'realm_actor_escalation': {
            'modelscope_qwen38max': 'openrouter_deepseek',
          },
        }),
      );
      File('${temp.path}/.xsoulspace/palette_health.json').writeAsStringSync(
        jsonEncode({
          'entries': {
            'openrouter_deepseek': {
              'status': 'failed',
              'code': 'transport_http_403',
              'detail': 'HTTP 403 from the provider',
            },
            'modelscope_qwen38max': {'status': 'ok'},
            'qwen': {
              'status': 'not_downloaded',
              'detail': 'weights are not cached; the runtime never downloads',
            },
          },
        }),
      );
      world = WorldStateService(
        health: PaletteHealthStore(resolveHome: () => temp.path),
        debugDoctor: (_) => <String, Object?>{
          'daemon': {'live': true, 'pid': 7, 'worldHome': worldHome},
          'artifacts': {
            'daemon': {'present': false, 'path': ''},
          },
        },
        debugWorldHome: worldHome,
      );
      await world.refresh();
      await tester.pumpWidget(_wrap(ModelsView(world: world)));
      addTearDown(() {
        world.dispose();
        RealmWorld.debugDeviceHome = null;
        temp.deleteSync(recursive: true);
      });
    }

    testWidgets('every declared rung renders with health, ladder and role', (
      final tester,
    ) async {
      await mountModels(tester);

      // The refactor's IA: the ladder lives in the BINDINGS lens, the
      // health detail and the daemon verbs in OBSERVE.

      expect(
        find.byKey(const ValueKey('models.rung.modelscope_qwen38max')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.rung.openrouter_deepseek')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('models.rung.qwen')), findsOneWidget);
      // laya is a decision role: it lives under System lanes now —
      // present and named, but explicitly not the reader's business.
      expect(
        find.byKey(const ValueKey('models.systemLane.laya')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('models.systemLanes')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('models.systemLane.laya')),
        findsOneWidget,
      );
      // The default is position 1 now (the brain-policy law,
      // 2026-11-16): the retired primary chip is gone, the behavior
      // sentences replace it — position 1 thinks first, every later
      // row names what it falls back FROM. The on-device class chips:
      // qwen rides a policy row, laya's own chip shows expanded.
      expect(find.text('primary'), findsNothing);
      expect(find.text('thinks first'), findsOneWidget);
      // The ladder's hint + the two fallback sentences all speak the
      // fallback (the merged surface added the hint line).
      expect(find.textContaining('is down or stuck'), findsNWidgets(3));
      expect(find.text('on-device'), findsNWidgets(2));

      // The Observe absorption (2026-11-19): the health verdict rides
      // the row's chip — tap it open for the verbatim detail.
      await tester.tap(
        find.byKey(const ValueKey('models.rung.openrouter_deepseek.health')),
      );
      await tester.pump();
      // The failed primary's health detail is visible BEFORE any send.
      expect(find.textContaining('transport_http_403'), findsOneWidget);
      // The local lane's honesty: the weights fact, never a dead toggle.
      await tester.tap(find.byKey(const ValueKey('models.rung.qwen.health')));
      await tester.pump();
      expect(find.textContaining('never downloads'), findsOneWidget);
      // The daemon strip rides the header on every lens: a live daemon
      // offers restart/stop (the Pro-gated editor entry is RETIRED —
      // the harness's owner-only apply is the single gate).
      expect(find.byKey(const ValueKey('models.restart')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.stop')), findsOneWidget);
    });

    testWidgets('the header carries the honest scheduler row in both '
        'states (G1)', (final tester) async {
      await mountModels(tester);

      // No supervisor record for this hermetic world home: the row is
      // honestly DOWN — a delegated task would sit `queued`. The strip
      // rides the header (the Observe absorption) — no lens switch.
      expect(find.byKey(const ValueKey('models.scheduler')), findsOneWidget);
      expect(find.text('scheduler down'), findsOneWidget);

      // A registry record naming a LIVE pid (the test process) flips
      // the row to live · pid — the same read the arm writes.
      final registry = MachineRegistry(root: '${temp.path}/oka-registry');
      registry.upsert(
        SupervisorRecord(
          componentId: 'ecsai-scheduler',
          providerName: 'leased-scheduler',
          shape: 'service',
          revisionHash: 'widgettest01',
          epoch: 1,
          killPolicy: KillPolicy.spawned,
          startedAt: DateTime.now().toUtc(),
          restartCount: 0,
          windowStartedAt: DateTime.now().toUtc(),
          trigger: 'none',
          pid: pid,
          handle: 'ecsai-scheduler',
        ),
        scope: registry.scopeFor(worldHome),
      );
      world.debugSupervisorRegistry = registry;
      await world.refresh();
      await tester.pump();

      expect(find.byKey(const ValueKey('models.scheduler')), findsOneWidget);
      expect(find.text('scheduler live · pid $pid'), findsOneWidget);
      // The arm/stop buttons keep their labels — they arm the WORLD
      // (both components) now.
      expect(find.byKey(const ValueKey('models.restart')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.stop')), findsOneWidget);
    });

    testWidgets('a generative rung tap is the session delegation choice', (
      final tester,
    ) async {
      await mountModels(tester);

      await tester.tap(
        find.byKey(const ValueKey('models.rung.modelscope_qwen38max')),
      );
      await tester.pump();
      expect(world.selectedRungId, 'modelscope_qwen38max');

      // A decision rung is data, not a delegation choice — it lives
      // under System lanes now, and a system-lane row is not tappable
      // at all.
      final expander = find.byKey(const ValueKey('models.systemLanes'));
      await tester.ensureVisible(expander);
      await tester.pumpAndSettle();
      await tester.tap(expander);
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const ValueKey('models.systemLane.laya')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('models.systemLane.laya')));
      await tester.pump();
      expect(world.selectedRungId, 'modelscope_qwen38max');
    });

    testWidgets('a malformed declared palette renders the harness refusal', (
      final tester,
    ) async {
      temp = Directory.systemTemp.createTempSync('models_bad_');
      RealmWorld.debugDeviceHome = temp.path;
      worldHome = '${temp.path}/worlds/local';
      Directory('$worldHome/.xsoulspace').createSync(recursive: true);
      // The malformed palette rides the DEVICE home (the global-config
      // law: the default file the chain reads).
      Directory('${temp.path}/.xsoulspace').createSync(recursive: true);
      File('${temp.path}/.xsoulspace/config.json').writeAsStringSync(
        jsonEncode({
          'model_palette': {
            'providers': {
              'pigeon': {'transport': 'carrier_pigeon'},
            },
            'cast': <Object?>[],
          },
        }),
      );
      world = WorldStateService(
        health: PaletteHealthStore(resolveHome: () => temp.path),
        debugDoctor: (_) => <String, Object?>{
          'daemon': {'live': false, 'worldHome': worldHome},
          'artifacts': {
            'daemon': {'present': false, 'path': ''},
          },
        },
        debugWorldHome: worldHome,
      );
      await world.refresh();
      await tester.pumpWidget(_wrap(ModelsView(world: world)));
      addTearDown(() {
        world.dispose();
        RealmWorld.debugDeviceHome = null;
        temp.deleteSync(recursive: true);
      });

      expect(
        find.byKey(const ValueKey('models.palette.refusal')),
        findsOneWidget,
      );
      expect(find.textContaining('palette_unknown_transport'), findsOneWidget);
      // The daemon strip rides the header: a dead daemon offers the
      // arm, never the stop.
      expect(find.byKey(const ValueKey('models.arm')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.stop')), findsNothing);
    });
  });
}
