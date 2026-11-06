import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_health.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// Phase 1d — the world's read model: ONE dynamic assembly of the
/// daemon truth, the DISCOVERED palette (never a hardcoded cast), the
/// journal projections and the arm seam (leg B G2–G5).
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
  }) => {
    'daemon': <String, Object?>{
      'live': live,
      'pid': 42,
      'worldHome': worldHome,
      'residentStartedAt': '2026-11-05T10:00:00.000Z',
      'binaryStaleVsArtifact': false,
    },
    'artifacts': {
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

  WorldStateService buildService({
    final Map<String, Object?> Function(String)? doctorOverride,
  }) => WorldStateService(
    store: store,
    health: PaletteHealthStore(resolveHome: () => deviceHome.path),
    debugDoctor: doctorOverride ?? (_) => doctor(),
    debugWorldHome: worldHome,
  );

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
    // The authority row's configurationRoot — the daemon's own fallback
    // source, and the discovery chain's first candidate.
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
      final service = buildService();
      await service.refresh();

      expect(service.daemonLive, isTrue);
      expect(service.daemonPid, 42);
      expect(service.daemonBinaryStale, isFalse);
      expect(service.worldHome, worldHome);
    });

    test('a dead daemon renders down, never an error surface', () async {
      final service = buildService(doctorOverride: (_) => doctor(live: false));
      await service.refresh();

      expect(service.daemonLive, isFalse);
    });

    test('the arm refuses by name when the AOT artifact is absent', () async {
      final service = buildService();
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

  group('the palette is DISCOVERED, never hardcoded (the Zed rule)', () {
    test('the authority configurationRoot wins the chain', () async {
      writePaletteConfig(configRoot, paletteDoc());
      final service = buildService();
      await service.refresh();

      expect(service.paletteConfigPath, '$configRoot/.xsoulspace/config.json');
      expect(service.paletteAbsence, isNull);
      // Cast order is the palette order — nothing sorted or invented.
      expect(service.rungs.map((final rung) => rung.id), [
        'modelscope_qwen38max',
        'openrouter_deepseek',
        'qwen',
        'laya',
      ]);
    });

    test('without an authority row the world-home walk-up finds it', () async {
      // A fresh store with NO authority row.
      final bareStore = RealmControlStore(
        Directory('${tempRoot.path}/coordination2')
          ..createSync(recursive: true),
      );
      writePaletteConfig(worldHome, paletteDoc());
      final service = WorldStateService(
        store: bareStore,
        health: PaletteHealthStore(resolveHome: () => deviceHome.path),
        debugDoctor: (_) => doctor(),
        debugWorldHome: worldHome,
      );
      await service.refresh();

      expect(service.paletteConfigPath, '$worldHome/.xsoulspace/config.json');
      expect(service.rungs, hasLength(4));
    });

    test('health and ladder merge onto the declaration', () async {
      writePaletteConfig(configRoot, paletteDoc());
      final service = buildService();
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
    });

    test('no config declares a palette: an honest empty, no default', () async {
      final service = buildService();
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
      final service = buildService();
      await service.refresh();

      expect(service.palette, isNull);
      expect(service.paletteAbsence, contains('palette_unknown_transport'));
    });

    test(
      'the delegation rung is a session choice, not a config write',
      () async {
        writePaletteConfig(configRoot, paletteDoc());
        final service = buildService();
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
      final service = buildService();
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
      final service = buildService();
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
        final service = buildService();
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
      final service = buildService();
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
        final service = buildService();
        await service.refresh();

        final scout = service.telemetryByActor['scout']!;
        expect(scout.rounds, 5);
        expect(scout.stalled, isTrue);
        expect(scout.cacheHitRate, closeTo(0.8, 0.001));
        expect(scout.at, '2026-11-05T12:00:00Z');
      },
    );

    test('attention = open permissions + running tasks', () async {
      final service = buildService();
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
}
