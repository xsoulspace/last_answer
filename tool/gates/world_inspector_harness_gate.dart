// World inspector visual gate as a flutter_mcp_harness scenario — the
// user-directed declarative testing mechanism (the multiplayer gate's
// macOS tier, pointed at the embedded harness inspector).
//
// ONE real macOS app instance. The gate opens an agent doc (the world
// inspector pane mounts under it), seeds the registry with the
// deterministic scripted pair (no provider, no daemon, no inference —
// the seed verb never reads as a live run), and then verifies the pane
// the way a human/agent experiences it:
//   rule (L0)   — `WORLD · 2 session(s) · 1 running · 1 perm pending`;
//   expansion   — the inspector bands render the FOCUSED session's beats
//                 (RichText ink via the toolkit a11y snapshot);
//   the 3D band — `AttachSceneBand` builds the replay world: the a11y
//                 anchor names `world scene · N actors`, and the honest
//                 `world scene off` placeholder is ABSENT (rev. 3 law:
//                 ONE version, the 3D one — FLTEnableFlutterGPU is set).
// Screenshots at every state land in the evidence dir for visual review.
//
// Usage:
//   fvm dart tool/gates/world_inspector_harness_gate.dart [--skip-build]
//   --skip-build reuses the existing macOS binary.
//
// Evidence: $TMPDIR/world_inspector_gate_evidence/ (steps.log + PNGs).

import 'dart:async';
import 'dart:io';

import 'package:flutter_mcp_harness/flutter_mcp_harness.dart';
import 'package:universal_automation_interface/universal_automation_interface.dart';

const _projectDir = '.';
const _dartDefines = ['--dart-define-from-file=configs/envs/prod.json'];

final _tmp = Platform.environment['TMPDIR'] ?? '/tmp';
final _evidenceDir = Directory('$_tmp/world_inspector_gate_evidence')
  ..createSync(recursive: true);
final _stepsLog = File('${_evidenceDir.path}/steps.log');
final _meshStore = '$_tmp/world_inspector_gate_mesh_store';

void row(final String status, final String step, final String detail) {
  final line = '${status.padRight(6)}${step.padRight(24)}$detail';
  // ignore: avoid_print
  print(line);
  _stepsLog.writeAsStringSync('$line\n', mode: FileMode.append);
}

Future<void> main(final List<String> args) async {
  final skipBuild = args.contains('--skip-build');
  if (_stepsLog.existsSync()) _stepsLog.deleteSync();
  final scenario = Scenario('world inspector harness gate', steps: [
    (
      'launch-host',
      (final context) async {
        // ONE instance per machine (the runs share one mesh-store dir —
        // a lingering instance from a previous run churns the doc store
        // and remounts the surface mid-run). Measured 2026-10-05: two
        // instances → wait-sample focus-steal loop; one → clean.
        final stale = await Process.run('pkill', const [
          '-f',
          'last_answer.app/Contents/MacOS/last_answer',
        ]);
        if (stale.exitCode == 0) {
          // Wait until the process is REALLY gone (SIGTERM handling can
          // take seconds; a half-dead predecessor holds the mesh store).
          for (var i = 0; i < 20; i++) {
            final check = await Process.run('pgrep', const [
              '-f',
              'last_answer.app/Contents/MacOS/last_answer',
            ]);
            if (check.exitCode != 0) break;
            await Process.run('pkill', const ['-9', '-f',
              'last_answer.app/Contents/MacOS/last_answer',
            ]);
            await Future<void>.delayed(const Duration(milliseconds: 500));
          }
          row('PASS', 'launch-host', 'cleared a stale instance first');
        }
        final binary = File(
          'build/macos/Build/Products/Debug/last_answer.app/Contents/'
          'MacOS/last_answer',
        );
        final launched = await BinaryAppTarget(
          projectDir: _projectDir,
          binaryPath: binary.path,
          buildCommand: [
            'fvm',
            'flutter',
            'build',
            'macos',
            '--debug',
            '--no-pub',
            ..._dartDefines,
          ],
          environment: {'LAST_ANSWER_MESH_STORE': _meshStore},
          name: 'host',
          vmServiceTimeout: const Duration(minutes: 10),
        ).launch(build: !skipBuild);
        context.bag['host'] = launched;
        context.bag['vm'] = await VmClient.connect(launched.vmUri);
        row('PASS', 'launch-host', 'vm=${launched.vmUri}');
      },
    ),
    (
      'open-agent-doc',
      (final context) async {
        final vm = context.take<VmClient>('vm');
        // Cold-start JIT answers -32601 until the toolkit registers;
        // retry until the verb stops refusing (the multiplayer gate law).
        final created = await _retry(() async {
          try {
            final out = await _verb(vm, 'agent_doc_create');
            return out['ok'] == true ? out : null;
          } on Object {
            return null;
          }
        }, attempts: 60);
        final docId = created['docId'] as String?;
        if (docId == null) {
          throw StateError('agent_doc_create never succeeded');
        }
        context.bag['docId'] = docId;
        // The verb returns BEFORE the surface route finishes mounting; the
        // surface's initState registers it and re-marks registry focus —
        // seeding before that mount would lose focus to the doc session
        // (measured). Wait until the registry holds the doc's session.
        await _pollUntil(() async {
          final state = await _verbSafe(vm, 'world_inspector_state');
          final sessions = state['sessions'] as List? ?? const [];
          return sessions.whereType<Map>().any(
                (final s) => s['id'] == 'agent-$docId',
              );
        }, attempts: 30);
        row('PASS', 'open-agent-doc', 'docId=$docId (surface registered)');
      },
    ),
    (
      'seed-world',
      (final context) async {
        final vm = context.take<VmClient>('vm');
        final out = await _verb(vm, 'world_inspector_seed');
        if (out['ok'] != true) {
          throw StateError('world_inspector_seed: $out');
        }
        row(
          'PASS',
          'seed-world',
          '${(out['seeded'] as List?)?.length ?? 0} '
              'scripted sessions (kind test — no real actors ran)',
        );
      },
    ),
    (
      'wait-sample',
      (final context) async {
        final vm = context.take<VmClient>('vm');
        final driver = ToolkitDriver(vm);
        context.bag['driver'] = driver;
        // Evidence first: what the screen shows while we wait.
        await _shot(driver, '00-after-seed');
        var lastState = <String, Object?>{};
        var waitAttempts = 0;
        // The VM connection dies intermittently while the app lives on
        // (measured 2026-10-05: verb/screenshot RPCs fail permanently
        // mid-run; the process is fine). A dead client is RECONNECTED —
        // the vmUri is stable for the process's lifetime.
        Future<void> reconnect() async {
          final launched = context.take<LaunchedApp>('host');
          final fresh = await VmClient.connect(launched.vmUri);
          context.bag['vm'] = fresh;
          context.bag['driver'] = ToolkitDriver(fresh);
        }

        await _pollUntil(() async {
          lastState = await _verbSafe(vm, 'world_inspector_state');
          if (lastState.isEmpty && waitAttempts % 3 == 2) {
            await reconnect();
          }
          if ((lastState['sampledRows'] as num? ?? 0) > 0) return true;
          // A doc-surface REMOUNT re-marks registry focus (initState) and
          // can steal it from the fixture any time after seeding — the
          // mount-race fix covers registration, not remounts. Re-seeding
          // is idempotent and restores the focus law.
          waitAttempts++;
          if (waitAttempts % 5 == 0) {
            await _verbSafe(vm, 'world_inspector_seed');
          }
          row(
            'WAIT',
            'wait-sample',
            'attempt $waitAttempts sampled='
                '${lastState['sampledSession']} '
                'sampleError=${lastState['sampleError']}',
          );
          return false;
        }, attempts: 30, onTick: (final attempt) {
          if (attempt % 5 == 0) {
            row(
              'WAIT',
              'wait-sample',
              'attempt $attempt (re-seeded every 5): $lastState',
            );
          }
        });
        row('PASS', 'wait-sample', 'pane sampled the focused session');
      },
    ),
    (
      'rule-collapsed',
      (final context) async {
        await _ensureAlive(context);
        final driver = context.take<ToolkitDriver>('driver');
        // Evidence FIRST: screenshot + the full label dump land before any
        // assertion, so a failure still shows what the human would see.
        await _shot(driver, '01-rule-collapsed');
        final labels = _labelsOf(await driver.snapshot());
        await File(
          '${_evidenceDir.path}/labels-collapsed.txt',
        ).writeAsString(labels.join('\n'));
        // The registry's honest count includes the doc's own session
        // alongside the two seeded ones; S2 law: the rule leads with the
        // TOP NEED (the planner's pending permission), not raw counts.
        for (final expected in const [
          'WORLD',
          'needs you',
          'perm:',
          'Write lib/src/registry.dart',
          'waiting',
        ]) {
          if (!labels.any((final l) => l.contains(expected))) {
            throw StateError(
              'collapsed rule never showed "$expected" '
              '(labels dump: labels-collapsed.txt, ${labels.length} nodes)',
            );
          }
        }
        row('PASS', 'rule-collapsed', 'WORLD rule renders all state (L0)');
      },
    ),
    (
      'expand-inspector',
      (final context) async {
        await _ensureAlive(context);
        final driver = context.take<ToolkitDriver>('driver');
        final vm = context.take<VmClient>('vm');
        await driver.perform(const ClickAction(name: 'inspect'));
        await _pollUntil(() async {
          final state = await _verbSafe(vm, 'world_inspector_state');
          return state['expanded'] == true;
        }, attempts: 15);
        // The 3D band builds its replay world on the next trace tick.
        await Future<void>.delayed(const Duration(seconds: 2));
        row('PASS', 'expand-inspector', 'bands + scene band mounted');
      },
    ),
      (
        'bands-and-scene',
        (final context) async {
          await _ensureAlive(context);
        final driver = context.take<ToolkitDriver>('driver');
          final vm = context.take<VmClient>('vm');
          // Evidence first: the expanded pane, before any assertion.
          // The GPU scene initializes asynchronously — settle before
          // shooting (shot 02 once caught the loading arc, not the
          // world).
          await Future<void>.delayed(const Duration(milliseconds: 1500));
          await _shot(driver, '02-expanded-bands-scene');
          final labels = _labelsOf(await driver.snapshot());
        // S2 canvas: the Answer Rail floats and speaks the FLEET
        // aggregate (audit 3, the ONE needs source law): the planner's
        // permission ranks first + the focused worker's running row —
        // 2 needs, top: perm. The slates are docked at the bottom edge.
        for (final expected in const [
          'answer rail · 2 needs · top: perm:',
          'view dock',
          'budget dock',
          'ledger dock',
          'time dock',
          'canvas · world',
        ]) {
          if (!labels.any((final l) => l.contains(expected))) {
            throw StateError(
              'canvas never showed "$expected"; '
              'labels: ${labels.take(60).join(' | ')}',
            );
          }
        }
        // The focused session's beats are reachable through the view
        // slate (and echo in the rail's running-item detail).
        await driver.perform(const ClickAction(name: 'view dock'));
        await _pollUntil(() async {
          final now = _labelsOf(await driver.snapshot());
          return now.any((final l) => l.contains('slate panel · view'));
        }, attempts: 10);
        await _shot(driver, '03-view-slate-open');
        final openLabels = _labelsOf(await driver.snapshot());
        if (!openLabels.any((final l) => l.contains('34 passed'))) {
          throw StateError(
            'view dock never showed the focused worker beat; '
            'labels: ${openLabels.take(60).join(' | ')}',
          );
        }
        // S3: the altitude chip names the semantic-zoom tier (distance 10
        // → steps); tapping it cycles the tier without the camera.
        if (!openLabels.any((final l) => l.contains('altitude · steps'))) {
          throw StateError(
            'altitude chip never named the steps tier; '
            'labels: ${openLabels.take(60).join(' | ')}',
          );
        }
        await driver.perform(const ClickAction(name: 'altitude · steps'));
        await _pollUntil(() async {
          final now = _labelsOf(await driver.snapshot());
          return now.any((final l) => l.contains('altitude · beats'));
        }, attempts: 10);
        await _shot(driver, '04-altitude-beats');
        // Dismiss the view slate.
        await driver.perform(const ClickAction(name: 'view dock'));
        await _pollUntil(() async {
          final now = _labelsOf(await driver.snapshot());
          return now.every((final l) => !l.contains('slate panel · view'));
        }, attempts: 10);
        row('PASS', 'dismiss-slate', 'view slate closed');
        // rev. 3: the 3D band is THE band. Its a11y anchor names the
        // replay world; the honest-off placeholder must be ABSENT.
        final worldLabels = _labelsOf(await driver.snapshot());
        final sceneLabel = worldLabels
            .where((final l) => l.contains('world scene'))
            .toList();
        if (sceneLabel.isEmpty ||
            sceneLabel.any((final l) => l.contains('off'))) {
          throw StateError(
            '3D world band absent or in off state; scene labels: '
            '$sceneLabel',
          );
        }
        // S4: the one verb grammar — the palette opens over the canvas
        // with the product's verbs (allow/reject for the pending perm).
        await driver.perform(const ClickAction(name: 'inspector palette'));
        await _pollUntil(() async {
          final now = _labelsOf(await driver.snapshot());
          final palette = now.any(
            (final l) => l.startsWith('command palette ·'),
          );
          final allowRow = now.any(
            (final l) =>
                l.contains('command: allow — Write lib/src/registry.dart'),
          );
          return palette && allowRow;
        }, attempts: 10);
        await _shot(driver, '06-command-palette');
        await driver.perform(const ClickAction(name: 'inspector palette'));
        // The headless projection agrees with what the pixels show —
        // including the S2 fleet-level Answer Rail top need.
        final state = await _verb(vm, 'world_inspector_state');
        final rows = state['sampledRows'];
        final session = state['sampledSession'];
        if (rows != 3 || session != 'seed-worker') {
          throw StateError(
            'state verb disagrees with the pane: '
            'rows=$rows session=$session ($state)',
          );
        }
        final needs = state['needs'] as List? ?? const [];
        if (needs.isEmpty ||
            (needs.first as Map)['severity'] != 'permission' ||
            !((needs.first as Map)['title'] as String)
                .contains('Write lib/src/registry.dart')) {
          throw StateError(
            'state verb lost the ranked top need: needs=$needs',
          );
        }
        final sessions = state['sessions'] as List? ?? const [];
        final planner = sessions.whereType<Map>().firstWhere(
              (final s) => s['id'] == 'seed-planner',
              orElse: () => const {},
            );
        if (planner['pendingPermissionTitle'] == null) {
          throw StateError(
            'seed planner lost its pending permission: $planner',
          );
        }
        // S6, last (the flip re-mounts the GPU band on flip-back and the
        // macOS a11y tree lags that remount — the widget tests cover both
        // directions headlessly; the live gate proves the world→history
        // read): the canvas becomes the time spine — the SAME run read
        // as history.
        await driver.perform(const ClickAction(name: 'canvas · world'));
        await _pollUntil(() async {
          final now = _labelsOf(await driver.snapshot());
          return now.any((final l) => l.contains('time spine'));
        }, attempts: 10);
        await _shot(driver, '05-projection-history');
        final historyLabels = _labelsOf(await driver.snapshot());
        if (historyLabels.any((final l) => l.contains('world scene'))) {
          throw StateError(
            'history projection still carries the world scene',
          );
        }
        row(
          'PASS',
          'bands-and-scene',
          'canvas rail + view slate + palette · scene "${sceneLabel.first}" · '
              'state verb agrees (top need: permission)',
        );
      },
    ),
  ]);
  var passed = false;
  try {
    passed = await scenario.run();
    scenario.report.printSummary();
  } on Object catch (error) {
    row('FAIL', 'scenario', '$error');
  }
  row('VERDICT', passed ? 'WI-GATE PASS' : 'WI-GATE FAIL', '');
  exit(passed ? 0 : 1);
}

// ---------------------------------------------------------------------------
// Helpers: the mcp-toolkit VM-service tier + evidence.
// ---------------------------------------------------------------------------

/// Calls `ext.mcp.toolkit.<verb>` — the same service extensions the
/// mcp-toolkit server routes to — and returns the app's `parameters` map.
Future<Map<String, Object?>> _verb(
  final VmClient vm,
  final String verb, [
  final Map<String, Object?> args = const <String, Object?>{},
]) async {
  final response = await vm.callExtension('ext.mcp.toolkit.$verb', args: args);
  final parameters = response['parameters'];
  if (parameters is Map) {
    return parameters.cast<String, Object?>();
  }
  return response;
}

/// Cheap VM liveness probe: a dead websocket (measured: heavy
/// view_screenshots traffic drops it mid-run while the app lives on)
/// reconnects the bag's vm/driver so the step's `context.take`s get a
/// FRESH client. Idempotent when the connection is healthy.
Future<void> _ensureAlive(final HarnessContext context) async {
  final vm = context.take<VmClient>('vm');
  try {
    await vm
        .callExtension('ext.mcp.toolkit.world_inspector_state')
        .timeout(const Duration(seconds: 5));
    return;
  } on Object {
    final launched = context.take<LaunchedApp>('host');
    final fresh = await VmClient.connect(launched.vmUri);
    context.bag['vm'] = fresh;
    context.bag['driver'] = ToolkitDriver(fresh);
  }
}

Future<Map<String, Object?>> _verbSafe(
  final VmClient vm,
  final String verb,
) async {
  try {
    return await _verb(vm, verb);
  } on Object {
    return const <String, Object?>{};
  }
}

Future<T> _retry<T>(
  final Future<T?> Function() action, {
  required final int attempts,
  final Duration delay = const Duration(seconds: 2),
}) async {
  for (var i = 0; i < attempts; i++) {
    final result = await action();
    if (result != null) return result;
    await Future<void>.delayed(delay);
  }
  throw TimeoutException('retry never succeeded after $attempts attempts');
}

Future<void> _pollUntil(
  final Future<bool> Function() action, {
  required final int attempts,
  final Duration delay = const Duration(seconds: 2),
  final void Function(int attempt)? onTick,
}) async {
  for (var i = 0; i < attempts; i++) {
    onTick?.call(i);
    if (await action()) return;
    await Future<void>.delayed(delay);
  }
  throw TimeoutException('poll never passed after $attempts attempts');
}

/// Every a11y label in the snapshot, flattened (the toolkit wire is a
/// ref-linked node list; the names ARE what a human/agent reads).
List<String> _labelsOf(final Snapshot snapshot) {
  final labels = <String>[];
  void walk(final AxNode node) {
    final name = node.name;
    if (name != null && name.isNotEmpty) labels.add(name);
    node.children.forEach(walk);
  }

  snapshot.roots.forEach(walk);
  return labels;
}

Future<void> _shot(final ToolkitDriver driver, final String name) async {
  final bytes = await driver.screenshot();
  final file = File('${_evidenceDir.path}/$name.png');
  await file.writeAsBytes(bytes);
  row('SHOT', name, file.path);
}
