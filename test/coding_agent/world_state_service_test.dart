import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/data_agents/supervised/supervised_world.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/ui_chat/palette_health.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

/// Phase 1d — the world's read model: ONE dynamic assembly of the
/// daemon truth, the DISCOVERED palette (never a hardcoded cast), the
/// journal projections and the arm seam (leg B G2–G5), plus the G1
/// scheduler truth: the delegation lane's claimant pump read from the
/// oka supervisor registry, and the arm refusals that NAME the
/// component missing its artifact.
void main() {
  late Directory tempRoot;
  late Directory deviceHome;
  late String worldHome;
  late String configRoot;
  late RealmControlStore store;

  Map<String, Object?> doctor({
    final bool live = true,
    final bool exePresent = false,
    final String exePath = '/nonexistent/ecsai_daemon.exe',
    final String? root,
  }) => {
    'daemon': <String, Object?>{
      'live': live,
      'pid': 42,
      'worldHome': worldHome,
      'residentStartedAt': '2026-11-05T10:00:00.000Z',
      'binaryStaleVsArtifact': false,
    },
    'artifacts': {
      'root': root,
      'daemon': {'path': exePath, 'present': exePresent, 'fresh': true},
    },
  };

  void writePaletteConfig(final String dir, final Map<String, Object?> doc) {
    Directory('$dir/.xsoulspace').createSync(recursive: true);
    File('$dir/.xsoulspace/config.json').writeAsStringSync(jsonEncode(doc));
  }

  Map<String, Object?> paletteDoc() => {
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
        {'id': 'jev', 'builtin': true, 'role': 'decision'},
        {
          'id': 'apple_foundation_afm',
          'builtin': true,
          'role': 'generative',
        },
      ],
    },
  };

  void writeHealth() {
    File(
      '${deviceHome.path}/.xsoulspace/palette_health.json',
    ).writeAsStringSync(
      jsonEncode({
        'entries': {
          'openrouter_deepseek': {
            'status': 'failed',
            'code': 'transport_http_403',
            'detail': 'HTTP 403 from the provider',
            'at': '2026-11-05T17:44:00Z',
          },
          'modelscope_qwen38max': {
            'status': 'ok',
            'at': '2026-11-05T17:44:00Z',
          },
          'qwen': {
            'status': 'not_downloaded',
            'detail': 'weights are not cached; the runtime never downloads',
          },
        },
      }),
    );
  }

  void writeGlobalConfig() {
    Directory('${deviceHome.path}/.xsoulspace').createSync(recursive: true);
    File('${deviceHome.path}/.xsoulspace/config.json').writeAsStringSync(
      jsonEncode({
        'realm_actor_escalation': {
          'modelscope_qwen38max': 'openrouter_deepseek',
          'qwen': 'modelscope_qwen38max',
        },
      }),
    );
  }

  Future<WorldStateService> buildService({
    final Map<String, Object?> Function(String)? doctorOverride,
    // The global-config law (2026-11-19): the discovery chain reads
    // [override, device-global]. The palette-staging tests point the
    // OVERRIDE at the staged root — the legitimate way a workspace
    // config applies now; `stagedRoot: false` keeps the global-only
    // default.
    final bool stagedRoot = true,
  }) async {
    final service = WorldStateService(
      store: store,
      health: PaletteHealthStore(resolveHome: () => deviceHome.path),
      debugDoctor: doctorOverride ?? (_) => doctor(),
      debugWorldHome: worldHome,
    );
    if (stagedRoot) {
      // The setter fires its own refresh; wait for ITS completion
      // (one listener notification) so the test's own refresh is not
      // guard-coalesced away — the race the models_local poll names.
      final settled = Completer<void>();
      void listener() {
        if (!settled.isCompleted) settled.complete();
      }

      service.addListener(listener);
      service.configRootOverride = configRoot;
      await settled.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
      service.removeListener(listener);
    }
    return service;
  }

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('world_state_test');
    deviceHome = Directory('${tempRoot.path}/home')
      ..createSync(recursive: true);
    worldHome = '${tempRoot.path}/worlds/local';
    Directory(worldHome).createSync(recursive: true);
    configRoot = '${tempRoot.path}/harness';
    Directory(configRoot).createSync(recursive: true);
    // The realm's device root moves under the hermetic home (the same
    // pin the realm-chat tests use).
    RealmWorld.debugDeviceHome = deviceHome.path;
    store = RealmControlStore(
      Directory('${tempRoot.path}/coordination')..createSync(recursive: true),
    );
    writeGlobalConfig();
    writeHealth();
    // The authority row's configurationRoot — the daemon's deployment
    // fallback, and since the 2026-11-19 global-config law NO LONGER a
    // candidate in LA's own discovery chain (staged roots apply via
    // the override).
    await store.transact((tx) {
      tx.put('coordination', 'authority', <String, Object?>{
        'state': 'granted',
        'configurationRoot': configRoot,
      });
      // The LIVE journal shape (verified against the realm journal on
      // 2026-11-06): the sentence rides `payload.prompt`, the rung
      // `model`, the timestamps admitted/started/settled — the terminal
      // RESULT text lives in the actor's doc, never in the row.
      tx.put('durable_tasks', 'task-running', <String, Object?>{
        'taskId': 'task-running',
        'state': 'started',
        'model': 'modelscope_qwen38max',
        'payload': {
          'prompt': 'fix the failing shell test',
          'addressees': ['scout'],
        },
        'admittedAt': '2026-11-05T18:00:00Z',
      });
      tx.put('durable_tasks', 'task-done', <String, Object?>{
        'taskId': 'task-done',
        'state': 'succeeded',
        'model': 'modelscope_qwen38max',
        'payload': {'prompt': 'write the note'},
        'settledAt': '2026-11-05T17:00:00Z',
      });
      tx.put('tool_loop_telemetry', 'tl-old', <String, Object?>{
        'actorId': 'scout',
        'rounds': 2,
        'promptTokens': 1000,
        'cachedTokens': 100,
        'stalled': false,
        'at': '2026-11-05T10:00:00Z',
      });
      tx.put('tool_loop_telemetry', 'tl-new', <String, Object?>{
        'actorId': 'scout',
        'rounds': 5,
        'promptTokens': 2000,
        'cachedTokens': 1600,
        'completionTokens': 400,
        'toolCalls': 12,
        'promptChars': 3400,
        'appliedWrites': 3,
        'stalled': true,
        'at': '2026-11-05T12:00:00Z',
      });
    });
  });

  tearDown(() {
    RealmWorld.debugDeviceHome = null;
    tempRoot.deleteSync(recursive: true);
  });

  group('the daemon truth (the doctor probe, G2)', () {
    test('live/pid/stale come from the doctor report', () async {
      final service = await buildService();
      await service.refresh();

      expect(service.daemonLive, isTrue);
      expect(service.daemonPid, 42);
      expect(service.daemonBinaryStale, isFalse);
      expect(service.worldHome, worldHome);
    });

    test('a dead daemon renders down, never an error surface', () async {
      final service = await buildService(doctorOverride: (_) => doctor(live: false));
      await service.refresh();

      expect(service.daemonLive, isFalse);
    });

    test('the arm refuses by name when the AOT artifact is absent', () async {
      final service = await buildService();
      await service.refresh();

      final report = await service.armWorld();

      expect(report['ok'], isFalse);
      expect(report['bounce'], 'daemon_artifact_absent');
      expect(service.armState, WorldArmState.error);
      expect(service.armError, 'daemon_artifact_absent');
      // The refusal carries the fix hint — never a silent gap.
      expect(service.armFindings.single, contains('AOT daemon'));
    });
  });

  group('the scheduler truth + the arm refusals (G1)', () {
    /// A pid that is dead by the time it is used: a spawned-and-reaped
    /// `/bin/sh` exit (the pid probe is `kill -0`, so a reaped pid is
    /// honestly down).
    Future<int> exitedPid() async {
      final process = await Process.start('/bin/sh', ['-c', 'exit 0']);
      await process.exitCode;
      return process.pid;
    }

    SupervisorRecord schedulerRecord({required final int? pid}) =>
        SupervisorRecord(
          componentId: 'ecsai-scheduler',
          providerName: 'leased-scheduler',
          shape: 'service',
          revisionHash: 'testrevision1',
          epoch: 1,
          killPolicy: KillPolicy.spawned,
          startedAt: DateTime.now().toUtc(),
          restartCount: 0,
          windowStartedAt: DateTime.now().toUtc(),
          trigger: 'none',
          pid: pid,
          handle: 'ecsai-scheduler',
        );

    test('schedulerLive/schedulerPid read the oka registry record', () async {
      final registry = MachineRegistry(root: '${tempRoot.path}/oka-registry');
      registry.upsert(
        schedulerRecord(pid: pid), // the test process: alive
        scope: registry.scopeFor(worldHome),
      );
      final service = await buildService()..debugSupervisorRegistry = registry;
      await service.refresh();

      expect(service.schedulerLive, isTrue);
      expect(service.schedulerPid, pid);

      // A record naming a DEAD pid reads down — the record is evidence,
      // the pid probe is the truth.
      final dead = await exitedPid();
      registry.upsert(
        schedulerRecord(pid: dead),
        scope: registry.scopeFor(worldHome),
      );
      await service.refresh();
      expect(service.schedulerLive, isFalse);
      expect(service.schedulerPid, dead);
    });

    test('no record: the scheduler is honestly down, never an error', () async {
      final service = await buildService(
        doctorOverride: (_) => doctor(root: configRoot),
      )..debugSupervisorRegistry = MachineRegistry(
        root: '${tempRoot.path}/oka-empty',
      );
      await service.refresh();

      expect(service.schedulerLive, isFalse);
      expect(service.schedulerPid, isNull);
      expect(service.harnessRoot, configRoot);
    });

    test(
      'the arm refuses by name when the scheduler script is absent',
      () async {
      // A fake harness checkout that EXISTS but carries no
      // pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart.
      final fakeHarness = '${tempRoot.path}/harness-checkout';
      Directory(fakeHarness).createSync(recursive: true);
      final service = await buildService(
        doctorOverride: (_) => doctor(
          exePresent: true,
          exePath: '$fakeHarness/build/ecsai_daemon.exe',
          root: fakeHarness,
        ),
      );
      await service.refresh();

      final report = await service.armWorld();

      expect(report['ok'], isFalse);
      expect(report['bounce'], 'scheduler_entrypoint_absent');
      // The refusal NAMES the component missing its artifact AND lists
      // the world's components (the arm is both-or-neither).
      expect(report['component'], 'ecsai-scheduler');
      expect(report['components'], ['ecsai-daemon', 'ecsai-scheduler']);
      expect(service.armState, WorldArmState.error);
      expect(service.armError, 'scheduler_entrypoint_absent');
      expect(
        service.armFindings.single,
        contains(schedulerEntrypointPath(fakeHarness)),
      );
    });

    test('the arm refuses by name when no harness root was resolved', () async {
      final service = await buildService(
        doctorOverride: (_) => doctor(exePresent: true),
      );
      await service.refresh();

      final report = await service.armWorld();

      expect(report['ok'], isFalse);
      expect(report['bounce'], 'harness_root_unresolved');
      expect(report['component'], 'ecsai-scheduler');
      expect(service.armState, WorldArmState.error);
      expect(service.armError, 'harness_root_unresolved');
      expect(service.armFindings.single, contains('ECSAID_ROOT'));
    });

    test('the daemon artifact is still the FIRST refusal', () async {
      final service = await buildService(
        doctorOverride: (_) => doctor(root: configRoot),
      );
      await service.refresh();

      final report = await service.armWorld();

      expect(report['bounce'], 'daemon_artifact_absent');
      expect(report['component'], 'ecsai-daemon');
      expect(report['components'], ['ecsai-daemon', 'ecsai-scheduler']);
    });
  });

  group('the palette is DISCOVERED, never hardcoded (the Zed rule)', () {
    test('the override leads the chain: the staged root wins over the '
        'global file', () async {
      writePaletteConfig(configRoot, paletteDoc());
      final service = await buildService(); // stagedRoot → the override law
      await service.refresh();

      expect(service.paletteConfigPath, '$configRoot/.xsoulspace/config.json');
      expect(service.paletteAbsence, isNull);
      // Cast order is the palette order — nothing sorted or invented.
      expect(service.rungs.map((final rung) => rung.id), [
        'modelscope_qwen38max',
        'openrouter_deepseek',
        'qwen',
        'laya',
        'jev',
        'apple_foundation_afm',
      ]);
    });

    test('the DEVICE GLOBAL is the default read (the 2026-11-19 law): '
        'no override, no authority row, no walk-up', () async {
      // The global config gains the palette (merged beside the
      // escalation ladder the ladder test reads).
      Directory('${deviceHome.path}/.xsoulspace').createSync(recursive: true);
      File(
        '${deviceHome.path}/.xsoulspace/config.json',
      ).writeAsStringSync(
        jsonEncode({
          'realm_actor_escalation': <String, String>{
            'modelscope_qwen38max': 'openrouter_deepseek',
            'qwen': 'modelscope_qwen38max',
          },
          ...paletteDoc(),
        }),
      );
      final service = await buildService(stagedRoot: false);
      await service.refresh();

      expect(
        service.paletteConfigPath,
        '${deviceHome.path}/.xsoulspace/config.json',
      );
      expect(service.rungs, hasLength(6));
    });

    test('health and ladder merge onto the declaration', () async {
      writePaletteConfig(configRoot, paletteDoc());
      final service = await buildService();
      await service.refresh();

      final healthy = service.rungs.firstWhere(
        (final rung) => rung.id == 'modelscope_qwen38max',
      );
      expect(healthy.healthStatus, 'ok');
      expect(healthy.ladderNext, 'openrouter_deepseek');
      expect(healthy.builtin, isFalse);

      // The declared primary is failed health — shown as data, BEFORE
      // any send (G3's acceptance).
      final primary = service.primaryRung!;
      expect(primary.id, 'openrouter_deepseek');
      expect(primary.primary, isTrue);
      expect(primary.healthStatus, 'failed');
      expect(primary.health?.code, 'transport_http_403');

      // The local lane's honesty: not_downloaded + the weights fact.
      final local = service.rungs.firstWhere((final rung) => rung.id == 'qwen');
      expect(local.builtin, isTrue);
      expect(local.isLocal, isTrue);
      expect(local.healthStatus, 'not_downloaded');
      expect(local.health?.detail, contains('never downloads'));

      // The lane-truth law (2026-11-15): builtin is NOT local — jev
      // rides the composition root's HOSTED OpenRouter lane, afm the
      // Apple-specific on-device one.
      final jev = service.rungs.firstWhere((final rung) => rung.id == 'jev');
      expect(jev.builtin, isTrue);
      expect(jev.isLocal, isFalse, reason: 'the hosted OpenRouter lane');
      final afm = service.rungs.firstWhere(
        (final rung) => rung.id == 'apple_foundation_afm',
      );
      expect(afm.builtin, isTrue);
      expect(afm.isLocal, isTrue, reason: 'on-device, Apple-specific');
    });

    test('no config declares a palette: an honest empty, no default', () async {
      final service = await buildService();
      await service.refresh();

      expect(service.palette, isNull);
      expect(service.rungs, isEmpty);
      expect(service.paletteAbsence, isNull);
      expect(service.primaryRung, isNull);
    });

    test('a malformed palette renders the harness refusal verbatim', () async {
      writePaletteConfig(configRoot, {
        'model_palette': {
          'providers': {
            'pigeon': {'transport': 'carrier_pigeon'},
          },
          'cast': <Object?>[],
        },
      });
      final service = await buildService();
      await service.refresh();

      expect(service.palette, isNull);
      expect(service.paletteAbsence, contains('palette_unknown_transport'));
    });

    test(
      'the delegation rung is a session choice, not a config write',
      () async {
        writePaletteConfig(configRoot, paletteDoc());
        final service = await buildService();
        await service.refresh();
        var notified = 0;
        service.addListener(() => notified++);

        service.selectRung('modelscope_qwen38max');
        expect(service.selectedRungId, 'modelscope_qwen38max');
        expect(notified, 1);

        service.selectRung(null);
        expect(service.selectedRungId, isNull);
      },
    );
  });

  group('the editor writes the REAL document (G7 first step)', () {
    test('a valid save lands with a .bak and re-reads the rungs', () async {
      writePaletteConfig(configRoot, paletteDoc());
      final service = await buildService();
      await service.refresh();

      final edited = paletteDoc();
      final cast = (edited['model_palette']! as Map)['cast']! as List;
      cast.add({
        'id': 'modelscope_qwen38flash',
        'provider': 'modelscope',
        'model': 'Qwen3.8-Max-Preview',
        'role': 'generative',
      });
      final refusal = service.savePaletteJson(
        jsonEncode(edited['model_palette']),
      );

      expect(refusal, isNull);
      expect(
        File('$configRoot/.xsoulspace/config.json.bak').existsSync(),
        isTrue,
      );
      expect(
        service.rungs.map((final rung) => rung.id),
        contains('modelscope_qwen38flash'),
      );
    });

    test('malformed JSON is refused before any write', () async {
      writePaletteConfig(configRoot, paletteDoc());
      final service = await buildService();
      await service.refresh();
      final before = File(
        '$configRoot/.xsoulspace/config.json',
      ).readAsStringSync();

      final refusal = service.savePaletteJson('{not json');

      expect(refusal, startsWith('json_malformed'));
      expect(
        File('$configRoot/.xsoulspace/config.json').readAsStringSync(),
        before,
      );
    });

    test(
      'a structurally invalid palette is refused by the harness code',
      () async {
        writePaletteConfig(configRoot, paletteDoc());
        final service = await buildService();
        await service.refresh();

        final refusal = service.savePaletteJson(
          jsonEncode({
            'providers': <String, Object?>{},
            'cast': [
              {'id': 'ghost', 'provider': 'absent', 'model': 'x'},
            ],
          }),
        );

        expect(refusal, isNotNull);
        expect(refusal, contains('palette_'));
      },
    );
  });

  group('the journal projections (tasks, telemetry, attention)', () {
    test('running tasks sort first; terminals carry their summary', () async {
      writePaletteConfig(configRoot, paletteDoc());
      final service = await buildService();
      await service.refresh();

      expect(service.tasks, hasLength(2));
      final running = service.runningTasks.single;
      expect(running.taskId, 'task-running');
      expect(running.state, 'started');
      expect(running.modelId, 'modelscope_qwen38max');
      expect(running.addressees, ['scout']);
      expect(service.tasks.first.taskId, 'task-running');

      final done = service.tasks.last;
      expect(done.terminal, isTrue);
      // The row carries the sentence, not an invented summary — the
      // terminal result text lives in the actor's doc (task op:show).
      expect(done.task, 'write the note');
      expect(done.summary, isNull);
      expect(done.at, '2026-11-05T17:00:00Z');
    });

    test(
      'telemetry keeps the newest row per actor with its cache rate',
      () async {
        final service = await buildService();
        await service.refresh();

        final scout = service.telemetryByActor['scout']!;
        expect(scout.rounds, 5);
        expect(scout.stalled, isTrue);
        expect(scout.cacheHitRate, closeTo(0.8, 0.001));
        expect(scout.at, '2026-11-05T12:00:00Z');
        // 0b — the inline work texture: the projection keeps the FULL
        // journal row (the old one discarded these and the work cards
        // starved).
        expect(scout.toolCalls, 12);
        expect(scout.completionTokens, 400);
        expect(scout.promptChars, 3400);
        expect(scout.appliedWrites, 3);
      },
    );

    test('attention = open permissions + running tasks', () async {
      final service = await buildService();
      await service.refresh();
      expect(service.attentionCount, 1);

      service.debugPermissionsOverride = [
        InboxPermission(
          sessionId: 'doc-1',
          title: 'write to lib/shell/app_shell.dart',
          answer: (_) async {},
        ),
      ];
      expect(service.attentionCount, 2);
      service.debugPermissionsOverride = null;
    });
  });
  // Wave N5 — task honesty: the detail pane reads the durable row
  // VERBATIM, the cancel rides the queue's own verb, and bounces name
  // their input (the stuck-rehearsal-row law: nothing is "running"
  // that the queue calls queued).
  group('task honesty (wave N5)', () {
    test('detail verbatim, events raw, cancel through the queue verb',
        () async {
      final service = await buildService();
      await service.refresh();
      // Admit through the queue's OWN verb: the row shape is the
      // queue's contract, not a test fixture guess.
      final admitted = await DurableTaskQueue(store: store).admit(
        const DurableTaskRequest(
          requestId: 'req-stuck',
          model: 'openrouter_deepseek',
          frozenCheck: <String, Object?>{'kind': 'task'},
          payload: <String, Object?>{
            'prompt': 'ADR 0118 fixture task — confirm universal creation.',
          },
        ),
        authority: const DurableTaskAuthority(
          actorId: 'scout',
          projectId: '/proj/sealed',
        ),
      );
      final taskId = admitted.taskId;

      final detail = await service.taskDetail(taskId);
      expect(detail?['state'], 'queued');
      expect(
        (detail?['payload'] as Map<Object?, Object?>?)?['prompt'],
        contains('ADR 0118'),
      );
      // Admission itself is a control event; cancel adds more.
      final eventsBefore = await service.taskEvents(taskId);
      expect(eventsBefore, isNotEmpty);

      final receipt = await service.taskCancel(taskId);
      expect(receipt['ok'], true, reason: 'bounce: ${receipt['bounce']}');
      final after = await service.taskDetail(taskId);
      expect(after?['state'], 'cancelled');
      expect(
        (await service.taskEvents(taskId)).length,
        greaterThan(eventsBefore.length),
      );

      // A ghost id bounces by name, verbatim.
      final bounce = await service.taskCancel('task-ghost');
      expect(bounce['ok'], isFalse);
      expect('${bounce['bounce']}', contains('task_not_found'));
    });
  });
}
