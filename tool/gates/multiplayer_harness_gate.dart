// Multiplayer T3 gate as a flutter_mcp_harness scenario — the user-directed
// regular cross-platform (incl. web) testing mechanism, replacing the bash
// `flutter run` + mcp-toolkit-CLI driving of multiplayer_gate.sh (kept as
// the runbook reference).
//
// Two REAL app instances, one doc, the mesh task console end to end:
//   host (macOS binary, owns workspace + harness) ← relay → peer (Chrome
//   web build, viewer/answerer role). Peer dispatches an agent task; the
//   host auto-runs it through its delegate path; the verdict converges
//   back over the CRDT task board (MeshTaskBoard over ecsly world-sync);
//   the permission round-trip is answered reject-first from the peer.
//
// Usage:
//   fvm dart tool/gates/multiplayer_harness_gate.dart [--skip-build]
//   --skip-build reuses the existing macOS binary + web compilation.
//
// Evidence: $TMPDIR/mp_hgate_evidence/ (state dumps + steps log).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_mcp_harness/flutter_mcp_harness.dart';

const _projectDir = '.';

final _tmp = Platform.environment['TMPDIR'] ?? '/tmp';
final _evidenceDir = Directory('$_tmp/mp_hgate_evidence')
  ..createSync(recursive: true);
final _hostStore = '$_tmp/mp_hgate_host_mesh_store';
final _peerStore = '$_tmp/mp_hgate_peer_mesh_store';
final _stepsLog = File('${_evidenceDir.path}/steps.log');

void row(final String status, final String step, final String detail) {
  final line = '${status.padRight(6)}${step.padRight(26)}$detail';
  // ignore: avoid_print
  print(line);
  _stepsLog.writeAsStringSync('$line\n', mode: FileMode.append);
}

const _dartDefines = ['--dart-define-from-file=configs/envs/prod.json'];

Future<void> main(final List<String> args) async {
  final skipBuild = args.contains('--skip-build');
  final scratchWs = Directory.systemTemp.createTempSync('mp_hgate_ws.');
  // The doc binds THIS, never the repo.
  File('${scratchWs.path}/README.md').writeAsStringSync(
    'multiplayer harness gate scratch workspace\n',
  );
  LaunchedApp? host;
  LaunchedApp? peer;
  var passed = false;
  try {
    final scenario = Scenario('multiplayer T3 harness gate', steps: [
      (
        'launch-host',
        (final context) async {
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
              ..._dartDefines,
            ],
            environment: {'LAST_ANSWER_MESH_STORE': _hostStore},
            name: 'host',
            vmServiceTimeout: const Duration(minutes: 10),
          ).launch(build: !skipBuild);
          host = launched;
          context.bag['host'] = launched;
          final vm = await VmClient.connect(launched.vmUri);
          context.bag['hostVm'] = vm;
          row('PASS', 'launch-host', 'vm=${launched.vmUri}');
        },
      ),
      (
        'host-create-bind',
        (final context) async {
          final vm = context.take<VmClient>('hostVm');
          // The create hook is installed by the app shell's first
          // HomeScreen build, which can land AFTER the VM service URI is
          // announced — retry until the verb stops refusing. Both the
          // hook-not-wired refusal and the pre-registration -32601 are
          // retry-tolerant; a permanent absence exhausts the attempts.
          final Map<String, Object?>? created = await retry(
            () async {
              try {
                final out = await _verb(vm, 'agent_doc_create');
                return out['ok'] == true ? out : null;
              } on Object {
                return null;
              }
            },
            attempts: 60,
          );
          final docId = created?['docId'] as String?;
          if (docId == null) {
            throw StateError('agent_doc_create never succeeded');
          }
          context.bag['docId'] = docId;
          await _poll(
            () async => (await _verb(vm, 'agent_doc_state'))['docId'] ==
                docId,
            attempts: 90,
          );
          final bound = await _verb(
            vm,
            'agent_doc_bind',
            {'workspace': scratchWs.path},
          );
          if (bound['ok'] != true) {
            throw StateError('agent_doc_bind: $bound');
          }
          row('PASS', 'host-create-bind', 'docId=$docId ws=${scratchWs.path}');
        },
      ),
      (
        'host-relay',
        (final context) async {
          final vm = context.take<VmClient>('hostVm');
          final hosted = await _verb(vm, 'mesh_host');
          final endpoint = hosted['endpoint'] as String?;
          final pairingCode = hosted['pairingCode'] as String?;
          if (endpoint == null || pairingCode == null) {
            throw StateError('mesh_host: $hosted');
          }
          context.bag['pairingCode'] = pairingCode;
          row('PASS', 'host-relay', 'endpoint=$endpoint');
        },
      ),
      (
        'launch-peer',
        (final context) async {
          final peerFlutterLog = File('/tmp/mp_hgate_peer_flutter.log');
          final launched = await FlutterRunTarget(
            projectDir: _projectDir,
            device: 'chrome',
            extraArgs: _dartDefines,
            environment: {'LAST_ANSWER_MESH_STORE': _peerStore},
            name: 'peer',
            vmServiceTimeout: const Duration(minutes: 12),
            onLine: (line) => peerFlutterLog.writeAsStringSync(
              '$line\n',
              mode: FileMode.append,
            ),
          ).launch();
          peer = launched;
          context.bag['peer'] = launched;
          final vm = await VmClient.connect(launched.vmUri);
          context.bag['peerVm'] = vm;
          row('PASS', 'launch-peer', 'vm=${launched.vmUri}');
        },
      ),
      (
        'peer-pair',
        (final context) async {
          final vm = context.take<VmClient>('peerVm');
          final code = context.bag['pairingCode']! as String;
          final Map<String, Object?>? paired = await retry(
            () async {
              try {
                final out = await _verb(vm, 'mesh_pair', {
                  'pairingCode': code,
                });
                return out['ok'] == true ? out : null;
              } on Object {
                // -32601 before the web peer's dynamic verbs register
                // (DWDS boot is slow) — retry, never abort.
                return null;
              }
            },
            attempts: 10,
            delay: const Duration(seconds: 5),
          );
          if (paired == null) {
            throw StateError('mesh_pair never succeeded');
          }
          row(
            'PASS',
            'peer-pair',
            'peerId=${paired['peerId']} synced=${paired['synced']}',
          );
        },
      ),
      (
        'peer-join-open',
        (final context) async {
          final vm = context.take<VmClient>('peerVm');
          final docId = context.bag['docId']! as String;
          final joined = await _verb(vm, 'mesh_join_doc', {'docId': docId});
          if (joined['ok'] != true) {
            throw StateError('mesh_join_doc: $joined');
          }
          final opened = await retry(
            () async {
              final out = await _verb(vm, 'mesh_open_doc', {'docId': docId});
              return out['ok'] == true && out['viewer'] == true ? out : null;
            },
            attempts: 10,
          );
          if (opened == null) {
            throw StateError('mesh_open_doc viewer shadow never opened');
          }
          row(
            'PASS',
            'peer-join-open',
            'channel=agent-$docId presence=${joined['presenceCount']}',
          );
        },
      ),
      (
        'presence-host',
        (final context) async {
          final hostVm = context.take<VmClient>('hostVm');
          final docId = context.bag['docId']! as String;
          final status = await _verb(
            hostVm,
            'mesh_status',
            {'docId': docId},
          );
          final count = (status['presenceCount'] as num?)?.toInt() ?? 0;
          if (count < 1) {
            throw StateError('host presenceCount=$count');
          }
          row('PASS', 'presence-host', 'host presenceCount=$count');
        },
      ),
      (
        'concurrent-edits',
        (final context) async {
          final hostVm = context.take<VmClient>('hostVm');
          final peerVm = context.take<VmClient>('peerVm');
          final a = await _verb(hostVm, 'agent_doc_edit', {
            'blockId': 'gate-a',
            'text': 'host append',
          });
          if (a['ok'] != true) throw StateError('host edit: $a');
          final b = await _verb(peerVm, 'agent_doc_edit', {
            'blockId': 'gate-b',
            'text': 'peer prepend',
          });
          if (b['ok'] != true) throw StateError('peer edit: $b');
          await _verb(hostVm, 'storage_mesh_sync');
          await _verb(peerVm, 'storage_mesh_sync');
          row('PASS', 'concurrent-edits', 'both replicas flushed + absorbed');
        },
      ),
      (
        'surface-diff',
        (final context) async {
          await _diffOrThrow(context, 'surface-diff');
        },
      ),
      (
        'task-console',
        (final context) async {
          final hostVm = context.take<VmClient>('hostVm');
          final peerVm = context.take<VmClient>('peerVm');
          final docId = context.bag['docId']! as String;
          final dispatched = await _verb(peerVm, 'mesh_task_dispatch', {
            'docId': docId,
            'task': 'Read README.md in the workspace and report its first '
                'line as the verdict.',
          });
          final taskId = dispatched['taskId'] as String?;
          if (taskId == null) {
            throw StateError('mesh_task_dispatch: $dispatched');
          }
          await _verb(peerVm, 'storage_mesh_sync');
          await _verb(hostVm, 'storage_mesh_sync');
          row('PASS', 'task-dispatch-peer', 'taskId=$taskId');

          String? status;
          Map<String, Object?>? row0;
          try {
            await _poll(() async {
              // BOTH sides cycle per poll (runbook discipline): the host
              // claims + auto-runs, the peer ships/absorbs — a host-only
              // cycle lets the host's empty board file win the whole-file
              // exchange every time and the request never lands.
              await _verb(hostVm, 'storage_mesh_sync');
              row0 = await _taskOfSafe(peerVm, docId, taskId);
              status = row0?['status'] as String?;
              final terminal =
                  status == 'completed' || status == 'failed';
              if (!terminal) {
                await _verbSafe(peerVm, 'storage_mesh_sync');
              }
              return terminal;
            },
            attempts: 90,
            // Slow cadence on the peer side: every web-peer verb call is a
            // DWDS evaluation — sustained fast polling killed the DDC
            // compiler mid-run twice.
            delay: const Duration(seconds: 6),
            label: 'peer saw a terminal task status',
          );
          } on TimeoutException {
            // Diagnostics: both boards + the host surface projection, so
            // the failure names WHERE the pipeline broke (exchange, claim,
            // delegate or write-back).
            final hostBoard = await _verb(hostVm, 'mesh_tasks', {
              'docId': docId,
            });
            final hostState = await _verb(hostVm, 'agent_doc_state');
            for (final entry in {
              'task_timeout_host_board.json': hostBoard,
              'task_timeout_host_state.json': hostState,
              'task_timeout_peer_board.json': await _verb(
                peerVm,
                'mesh_tasks',
                {'docId': docId},
              ),
            }.entries) {
              File(
                '${_evidenceDir.path}/${entry.key}',
              ).writeAsStringSync(
                const JsonEncoder.withIndent('  ').convert(entry.value),
              );
            }
            rethrow;
          }
          final verdict = row0?['verdict'];
          if (verdict == null) {
            throw StateError('no verdict map on $taskId');
          }
          row('PASS', 'task-auto-run', 'peer status=$status verdict=$verdict');

          final hostRow = await _taskOf(hostVm, docId, taskId);
          if (hostRow?['status'] != status) {
            throw StateError(
              'boards disagree: host=${hostRow?['status']} peer=$status',
            );
          }
          row('PASS', 'task-converged', 'both boards: $taskId=$status');
        },
      ),
      (
        'perm-from-peer',
        (final context) async {
          final hostVm = context.take<VmClient>('hostVm');
          final peerVm = context.take<VmClient>('peerVm');
          final routed = await _verb(hostVm, 'mesh_routing', {
            'enabled': true,
          });
          if (routed['ok'] != true) throw StateError('mesh_routing: $routed');
          row('PASS', 'mesh_routing', 'remote permission routing ON');

          Future<String> delegateAndAwaitPeerAnswer(
            final String task,
            final String allowFlag,
          ) async {
            final delegated = await _verb(hostVm, 'agent_task_delegate', {
              'task': task,
            });
            if (delegated['ok'] != true) {
              throw StateError('agent_task_delegate: $delegated');
            }
            String? pending;
            await _poll(() async {
              await _verb(hostVm, 'storage_mesh_sync');
              final state = await _verbSafe(peerVm, 'agent_doc_state');
              pending = state['pendingPermissionTitle'] as String?;
              if (pending != null) return true;
              // Both sides cycle per poll (runbook discipline) — the
              // announcement and the answer are doc ops and only move
              // when BOTH replicas flush + absorb.
              await _verbSafe(peerVm, 'storage_mesh_sync');
              return false;
            },
            attempts: 60,
            // Same DWDS-load reasoning as the console poll.
            delay: const Duration(seconds: 6),
            label: 'permission reached the peer',
          );
            await _verb(peerVm, 'agent_permission_answer', {
              'allow': allowFlag == 'allow',
            });
            await _verb(peerVm, 'storage_mesh_sync');
            return pending!;
          }

          final rejected = await delegateAndAwaitPeerAnswer(
            'Write one line into gate-permission-target.txt: the write gate '
            'fires, the PEER answers.',
            'reject',
          );
          row('PASS', 'perm-reject', 'peer REJECTED: $rejected');

          final allowed = await delegateAndAwaitPeerAnswer(
            'retry the write to gate-permission-target.txt',
            'allow',
          );
          row('PASS', 'perm-allow', 'peer ALLOWED: $allowed');
          await _verb(hostVm, 'storage_mesh_sync');
          await _verb(peerVm, 'storage_mesh_sync');
        },
      ),
      (
        'final-diff',
        (final context) async {
          await _diffOrThrow(context, 'final-diff');
        },
      ),
    ]);

    passed = await scenario.run();
    scenario.report.printSummary();
    if (!passed) {
      stdout.writeln('---- host tail ----');
      (host?.stdout.tail(25) ?? const <String>[]).forEach(stdout.writeln);
      stdout.writeln('---- peer tail ----');
      (peer?.stdout.tail(25) ?? const <String>[]).forEach(stdout.writeln);
    }
  } finally {
    await peer?.stop();
    await host?.stop();
    scratchWs.deleteSync(recursive: true);
  }
  row('VERDICT', passed ? 'MP-HGATE PASS' : 'MP-HGATE FAIL', '');
  exit(passed ? 0 : 1);
}

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

/// Poll-loop variant: a transient VM-service hiccup (DWDS evaluation
/// failure, debug-service reconnect) must not abort the whole run — the
/// next cycle retries.
Future<Map<String, Object?>> _verbSafe(
  final VmClient vm,
  final String verb, [
  final Map<String, Object?> args = const <String, Object?>{},
]) async {
  try {
    return await _verb(vm, verb, args);
  } on Object {
    return const <String, Object?>{};
  }
}

Future<Map<String, Object?>?> _taskOf(
  final VmClient vm,
  final String docId,
  final String taskId,
) async {
  final out = await _verb(vm, 'mesh_tasks', {'docId': docId});
  for (final task in (out['tasks'] as List? ?? const [])) {
    if (task is Map && task['taskId'] == taskId) {
      return task.cast<String, Object?>();
    }
  }
  return null;
}

/// Poll-loop variant of [_taskOf] — transient peer VM failures read as
/// "no row yet" instead of aborting the run.
Future<Map<String, Object?>?> _taskOfSafe(
  final VmClient vm,
  final String docId,
  final String taskId,
) async {
  final out = await _verbSafe(vm, 'mesh_tasks', {'docId': docId});
  for (final task in (out['tasks'] as List? ?? const [])) {
    if (task is Map && task['taskId'] == taskId) {
      return task.cast<String, Object?>();
    }
  }
  return null;
}

Future<void> _poll(
  final Future<bool> Function() action, {
  required final int attempts,
  final String? label,
  final Duration delay = const Duration(seconds: 2),
}) async {
  for (var i = 0; i < attempts; i++) {
    if (await action()) return;
    await Future<void>.delayed(delay);
  }
  throw TimeoutException('poll never passed: ${label ?? 'condition'}');
}

/// Dumps both debugSurfaces, strips the named device-role divergence
/// ledger (runbook §oracle), and throws on any remaining difference.
Future<void> _diffOrThrow(
  final HarnessContext context,
  final String label,
) async {
  final hostVm = context.take<VmClient>('hostVm');
  final peerVm = context.take<VmClient>('peerVm');
  final host = await _verb(hostVm, 'agent_doc_state');
  final peer = await _verb(peerVm, 'agent_doc_state');
  File('${_evidenceDir.path}/host_$label.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(host),
  );
  File('${_evidenceDir.path}/peer_$label.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(peer),
  );
  _stripLedger(host);
  _stripLedger(peer);
  final a = const JsonEncoder().convert(host);
  final b = const JsonEncoder().convert(peer);
  if (a != b) {
    throw StateError(
      '$label: non-empty debugSurface diff (divergence ledger has no entry '
      'for it — this is a BUG row; see ${_evidenceDir.path})',
    );
  }
  row('PASS', label, 'host vs peer debugSurface identical (ledger-stripped)');
}

/// The NAMED divergence ledger — every entry is a justified device-role
/// divergence, stripped from BOTH dumps (runbook §oracle).
void _stripLedger(final Map<String, Object?> state) {
  final mesh = state['meshStatus'];
  if (mesh is Map) {
    mesh
      ..remove('endpoint') // each surface reports its OWN relay endpoint
      ..remove('hosting') // device role: the main device hosts, peer joins
      ..remove('peerCount'); // each registry holds only ITS paired peers
  }
  state
    ..remove('type')
    ..remove('method') // mcp envelope artifacts
    ..remove('viewer') // honest viewer marker: peer true, host false
    ..remove('workspaces') // device-local workspace binding
    ..remove('registryKey') // host registered-session marker (ADR 0009):
    // the peer opens the doc as a viewer shadow, never a registry session.
    // Host-owned daemon session projections (ADR 0005 §3: the owner runs
    // the harness; turn ops are not doc ops in v1). The projection is
    // nested under `session` since the surface refactor.
    ..remove('session')
    ..remove('sessionId')
    ..remove('running')
    ..remove('verdict')
    ..remove('transcriptTail')
    ..remove('turnCount')
    ..remove('lastGuidance')
    ..remove('sessionActors')
    ..remove('remotePermissionRouting') // owner-side announce policy
    ..remove('remotePermissions'); // each side lists only OTHERS' announcements
  final tasks = state['tasks'];
  if (tasks is List) {
    for (final task in tasks) {
      if (task is Map) task.remove('createdAtMs'); // board-internal timing
    }
  }
}
