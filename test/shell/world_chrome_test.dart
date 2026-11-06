import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/realm_chat/palette_health.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/landing_inbox.dart';
import 'package:lastanswer/shell/status_edge.dart';
import 'package:lastanswer/shell/view_models.dart';

import 'hermetic_world_state.dart';

/// Phase 1d chrome: the status edge, the landing inbox and the Models
/// surface render the world's read model — honest segments, reject-first
/// permissions, the dynamic palette (a discovered document, never a
/// hardcoded cast) and the editor's harness-grade refusals.
Widget _wrap(final Widget child) => MaterialApp(
  locale: const Locale('en'),
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
      File(
        '$worldHome/.xsoulspace/config.json',
      ).writeAsStringSync(jsonEncode(_paletteDoc()));
      Directory('${temp.path}/.xsoulspace').createSync(recursive: true);
      File('${temp.path}/.xsoulspace/config.json').writeAsStringSync(
        jsonEncode({
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

      expect(
        find.byKey(const ValueKey('models.rung.modelscope_qwen38max')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.rung.openrouter_deepseek')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('models.rung.qwen')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.rung.laya')), findsOneWidget);
      // The declared primary + the local lanes are facts, shown as chips.
      expect(find.text('primary'), findsOneWidget);
      expect(find.text('local'), findsNWidgets(2));
      // The ladder's next rung rides the row.
      expect(find.text('→ openrouter_deepseek'), findsOneWidget);
      // The failed primary's health detail is visible BEFORE any send.
      expect(find.textContaining('transport_http_403'), findsOneWidget);
      // The local lane's honesty: the weights fact, never a dead toggle.
      expect(find.textContaining('never downloads'), findsOneWidget);
      // A live daemon offers restart/stop, and the editor.
      expect(find.byKey(const ValueKey('models.restart')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.stop')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.edit')), findsOneWidget);
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

      // A decision rung is data, not a delegation choice.
      await tester.tap(find.byKey(const ValueKey('models.rung.laya')));
      await tester.pump();
      expect(world.selectedRungId, 'modelscope_qwen38max');
    });

    testWidgets('the editor validates with the harness parser and saves the '
        'real document with a .bak', (final tester) async {
      await mountModels(tester);

      await tester.tap(find.byKey(const ValueKey('models.edit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('models.editor')), findsOneWidget);

      // A malformed document is refused by name, before any write.
      await tester.enterText(
        find.byKey(const ValueKey('models.editor.field')),
        '{not json',
      );
      await tester.tap(find.byKey(const ValueKey('models.editor.validate')));
      await tester.pump();
      expect(find.textContaining('json_malformed'), findsOneWidget);

      // A valid edit saves into the REAL file, with the previous bytes
      // kept as a .bak sibling, and the rungs re-read.
      final edited = _paletteDoc();
      final cast = (edited['model_palette']! as Map)['cast']! as List;
      cast.add({
        'id': 'modelscope_qwen38flash',
        'provider': 'modelscope',
        'model': 'Qwen3.8-Max-Preview',
        'role': 'generative',
      });
      await tester.enterText(
        find.byKey(const ValueKey('models.editor.field')),
        jsonEncode(edited['model_palette']),
      );
      await tester.tap(find.byKey(const ValueKey('models.editor.save')));
      await tester.pump();
      expect(find.text('saved'), findsOneWidget);
      expect(
        File('$worldHome/.xsoulspace/config.json.bak').existsSync(),
        isTrue,
      );
      expect(
        world.rungs.map((final rung) => rung.id),
        contains('modelscope_qwen38flash'),
      );
      // The save offers the supervised restart (never tapped here: the
      // stop ladder is real IO).
      expect(
        find.byKey(const ValueKey('models.editor.restart')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('models.editor.close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('models.editor')), findsNothing);
    });

    testWidgets('a malformed declared palette renders the harness refusal', (
      final tester,
    ) async {
      temp = Directory.systemTemp.createTempSync('models_bad_');
      RealmWorld.debugDeviceHome = temp.path;
      worldHome = '${temp.path}/worlds/local';
      Directory('$worldHome/.xsoulspace').createSync(recursive: true);
      File('$worldHome/.xsoulspace/config.json').writeAsStringSync(
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
      // A dead daemon offers the arm, never the stop.
      expect(find.byKey(const ValueKey('models.arm')), findsOneWidget);
      expect(find.byKey(const ValueKey('models.stop')), findsNothing);
    });
  });
}
