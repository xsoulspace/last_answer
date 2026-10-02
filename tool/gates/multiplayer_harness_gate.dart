// Multiplayer T3 gate as a flutter_mcp_harness scenario — the user-directed
// regular cross-platform (incl. web) testing mechanism.
//
// Two REAL app instances, one doc, the mesh task console end to end:
//   host (macOS binary, owns workspace + harness) ← relay → peer (Chrome
//   web build). The peer dispatches an agent task from the VISIBLE mesh
//   task console (MeshTaskConsoleView); the host auto-runs it through its
//   delegate path; the verdict converges back over the CRDT task board
//   (MeshTaskBoard over ecsly world-sync) and the peer READS it in the
//   same console. The permission round-trip is answered reject-first from
//   the peer's transcript buttons, proven by the workspace file oracle.
//
// Driving split (the 2026-10 CDP redesign):
//   host  — macOS binary driven through the mcp-toolkit VM-service verbs
//           (the proven, reliable tier);
//   peer  — `flutter build web --debug` + a static file server + Chrome
//           attached over CDP (ChromeAppTarget/CdpDriver). NO VM service
//           on the web side: the DWDS/DDC evaluation layer that killed
//           compilers under polling is gone. The peer is driven through
//           its accessibility tree exactly like a human/agent would:
//           locate by text/aria-label in the live `flt-semantics` DOM,
//           click the bounding-box center, type into the focused field,
//           read the AX snapshot. (Semantic ClickAction's
//           backendDOMNodeIds go stale on Flutter web — measured; the
//           DOM-geometry path is the working one.)
//
// The old byte-diff debugSurface oracle is replaced by named oracles:
// board rows read back from BOTH sides (host verb + peer console UI),
// and the workspace file for the permission round. The web peer cannot
// host a relay and has no ACP harness — viewer/answerer role, unchanged
// from the runbook (tool/gates/multiplayer_gate.sh).
//
// Usage:
//   fvm dart tool/gates/multiplayer_harness_gate.dart [--skip-build]
//   --skip-build reuses the existing macOS binary + web build.
//
// Evidence: $TMPDIR/mp_hgate_evidence/ (state dumps + steps log).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_mcp_harness/flutter_mcp_harness.dart';
import 'package:universal_browser_cdp/universal_browser_cdp.dart';

const _projectDir = '.';

final _tmp = Platform.environment['TMPDIR'] ?? '/tmp';
final _evidenceDir = Directory('$_tmp/mp_hgate_evidence')
  ..createSync(recursive: true);
final _hostStore = '$_tmp/mp_hgate_host_mesh_store';
final _stepsLog = File('${_evidenceDir.path}/steps.log');
const _dartDefines = ['--dart-define-from-file=configs/envs/prod.json'];

/// The web server port is fixed; the Chrome CDP port is picked FREE per
/// run — a fixed CDP port gets adopted as a borrowed session when a stale
/// Chrome from an earlier crashed run is still answering (measured), and
/// a zombie browser with no page targets fails the attach. A fresh port
/// never collides.

const _webPort = 18091;

void row(final String status, final String step, final String detail) {
  final line = '${status.padRight(6)}${step.padRight(26)}$detail';
  // ignore: avoid_print
  print(line);
  _stepsLog.writeAsStringSync('$line\n', mode: FileMode.append);
}

Future<void> main(final List<String> args) async {
  final skipBuild = args.contains('--skip-build');
  // Fresh evidence per run: the steps log appends otherwise.
  if (_stepsLog.existsSync()) _stepsLog.deleteSync();
  final scratchWs = Directory.systemTemp.createTempSync('mp_hgate_ws.');
  // The doc binds THIS, never the repo. Also the permission file oracle:
  // the peer's reject must keep it absent, the allow must create it.
  final permTarget = File('${scratchWs.path}/gate-permission-target.txt');
  File('${scratchWs.path}/README.md').writeAsStringSync(
    'multiplayer harness gate scratch workspace\n',
  );
  LaunchedApp? host;
  _CdpPeer? peer;
  _StaticWebServer? server;
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
              '--no-pub',
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
          // The surface registration races its first rebuild (a disposed
          //-then-remounted window was measured once: state matched, bind
          // saw no surface). Bind is the real gate — retry it until the
          // surface holds still.
          final bound = await retry(
            () async {
              try {
                final state = await _verbSafe(vm, 'agent_doc_state');
                if (state['docId'] != docId) return null;
                final out = await _verb(vm, 'agent_doc_bind', {
                  'workspace': scratchWs.path,
                });
                return out['ok'] == true ? out : null;
              } on Object {
                return null;
              }
            },
            attempts: 30,
          );
          if (bound == null) {
            throw StateError('agent_doc_bind never succeeded');
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
          // Publish the payload: the joining peer pulls
          // `last-answer-data.json` from the store to restore the shared
          // doc into its project list — nothing ships until the host
          // writes it (the old shadow-peer flow never needed this).
          final backed = await _verb(vm, 'storage_backup', {
            'backend': 'mesh',
          });
          if (backed['ok'] != true) {
            throw StateError('storage_backup: $backed');
          }
          row('PASS', 'host-relay', 'endpoint=$endpoint payload published');
        },
      ),
      (
        'serve-launch-peer',
        (final context) async {
          if (!skipBuild) {
            row('WAIT', 'web-build', 'flutter build web --debug --no-pub');
            final build = await Process.start('fvm', [
              'flutter',
              'build',
              'web',
              '--debug',
              '--no-pub',
              ..._dartDefines,
            ]);
            final exitCode = await _teeAndWait(
              build,
              File('${_evidenceDir.path}/peer_web_build.log'),
            );
            if (exitCode != 0) {
              throw StateError('flutter build web failed (exit $exitCode, '
                  'see peer_web_build.log)');
            }
          }
          final webDir = Directory('build/web');
          if (!webDir.existsSync()) {
            throw StateError('build/web missing — run without --skip-build');
          }
          server = await _StaticWebServer.start(webDir, _webPort);
          peer = await _CdpPeer.launch(server!.base);
          context.bag['peer'] = peer;
          await peer!.waitText('Settings', attempts: 60);
          // Sacrificial first click: Flutter web swallows it (known).
          await peer!.warmUpClick();
          row('PASS', 'serve-launch-peer', 'url=${server!.base}');
        },
      ),
      (
        'peer-enable-mesh',
        (final context) async {
          final p = context.take<_CdpPeer>('peer');
          // The settings chrome may open on any tab (the concurrent
          // Agents & Models tab is the current default) — only the
          // chrome itself proves the click; the pin below lands General.
          await p.clickTextUntil('Settings', expect: 'Agents & Models');
          await p.clickTextUntil('General', expect: 'Theme:');
          await p.clickTextUntil(
            'Sync between devices',
            expect: 'I have a pairing code',
            attempts: 20,
          );
          row('PASS', 'peer-enable-mesh', 'MeshSyncPanel mounted');
        },
      ),
      (
        'peer-pair',
        (final context) async {
          final p = context.take<_CdpPeer>('peer');
          final code = context.bag['pairingCode']! as String;
          // Self-heal: if the enable click raced the panel animation and
          // toggled the backend off, the panel is gone — re-enable.
          if (!await p.hasText('I have a pairing code')) {
            await p.clickTextUntil(
              'Sync between devices',
              expect: 'I have a pairing code',
            );
          }
          await p.clickTextUntil(
            'I have a pairing code',
            expect: 'Paste pairing code',
          );
          // The dialog's TextField is autofocused; typing goes to the
          // focused element. Verify the field swallowed the code before
          // connecting (createPairingCode returns PURE base64 — the
          // 'mesh-pair/v1' prefix is a paste/QR decoration, so assert
          // on length, not prefix).
          await p.typeFocused(code);
          final typed = await p.textboxValue();
          if (typed == null || typed.length < 64) {
            final shown =
                typed == null ? '<none>' : '${typed.length} chars';
            throw StateError(
              'pairing code did not land in the dialog field '
              '(value: $shown)',
            );
          }
          await p.clickTextUntil('Connect', expect: 'Unpair devices');
          // joinWithCode: accept + connect + payload restore — visible
          // when the panel flips to the joined controls.
          await p.waitText('Unpair devices', attempts: 60);
          row('PASS', 'peer-pair', 'payload restored (panel shows Unpair)');
        },
      ),
      (
        'peer-open-doc',
        (final context) async {
          final p = context.take<_CdpPeer>('peer');
          // In-app navigation ONLY: the web mesh store is memory, a page
          // reload would drop the pairing. Leave the settings route.
          await p.leaveSettings();
          // The payload restore lands the shared doc; the surface
          // auto-opens in the ProjectView pane (measured) — otherwise
          // tap the restored tile.
          final auto = await p.waitAny(const ['mesh tasks'], attempts: 30);
          if (auto == null) {
            await p.clickTextUntil('Untitled', expect: 'mesh tasks');
          }
          // The mesh task console renders only when the wiring is live
          // AND the board is attached — the peer's readiness proof.
          await p.waitText('mesh tasks', attempts: 60);
          await p.dumpAx('peer_surface_open');
          row('PASS', 'peer-open-doc', 'surface + mesh console visible');
        },
      ),
      (
        'concurrent-writes',
        (final context) async {
          final vm = context.take<VmClient>('hostVm');
          final p = context.take<_CdpPeer>('peer');
          final docId = context.bag['docId']! as String;
          // Lane 1 (host, verb): a text block op on the shared doc.
          final edited = await _verb(vm, 'agent_doc_edit', {
            'blockId': 'gate-a',
            'text': 'host append',
          });
          if (edited['ok'] != true) throw StateError('host edit: $edited');
          // Lane 2 (peer, UI): a board row through the console composer.
          await p.clickText('new task for the owner');
          await p.typeFocused(
            'Read README.md in the workspace and report its first line '
            'as the verdict.',
          );
          await p.clickText('dispatch to owner');
          await p.waitText('[requested]', attempts: 15);
          await p.dumpAx('peer_after_dispatch');
          // Convergence: the host pulls the peer's board row.
          final shipped = await retry(
            () async {
              await _verbSafe(vm, 'storage_mesh_sync');
              final board = await _verbSafe(vm, 'mesh_tasks', {
                'docId': docId,
              });
              final tasks = board['tasks'] as List? ?? const [];
              return tasks.isNotEmpty ? board : null;
            },
            attempts: 20,
            delay: const Duration(seconds: 3),
          );
          if (shipped == null) {
            throw StateError('peer board row never reached the host');
          }
          row(
            'PASS',
            'concurrent-writes',
            'host text op + peer board row converged',
          );
        },
      ),
      (
        'task-console',
        (final context) async {
          final vm = context.take<VmClient>('hostVm');
          final p = context.take<_CdpPeer>('peer');
          final docId = context.bag['docId']! as String;
          final host = context.take<LaunchedApp>('host');
          final taskId = await _poll(
            () async {
              // Each attempt pulls the peer's flushed row (whole-file
              // exchange: the row only moves when THIS side syncs).
              await _verbSafe(vm, 'storage_mesh_sync');
              final board = await _verbSafe(vm, 'mesh_tasks', {
                'docId': docId,
              });
              for (final task in board['tasks'] as List? ?? const []) {
                if (task is Map && task['status'] == 'requested') {
                  return task['taskId'] as String;
                }
              }
              return null;
            },
            attempts: 20,
            label: 'a requested task row on the host board',
          );
          row('PASS', 'task-claimed', 'taskId=$taskId');

          // The host auto-runs on its sync cycle (refreshAfterMeshSync →
          // _autoRunPendingRemoteTasks → delegate → verdict as board
          // data). Host stdout names the claim — assert it, then drive
          // sync cycles until the verdict is folded.
          final claim = await host.stdout.waitFor(
            'mesh task console: claiming $taskId',
            timeout: const Duration(seconds: 90),
          );
          row('PASS', 'host-auto-run', 'claimed: ${claim.trim()}');

          String? verdictHeadline;
          await _poll(() async {
            // Keep cycling: every sync fires the surface's
            // refreshAfterMeshSync (claim + auto-run) and eventually
            // flushes the completed row + verdict.
            await _verbSafe(vm, 'storage_mesh_sync');
            final board = await _verbSafe(vm, 'mesh_tasks', {
              'docId': docId,
            });
            for (final task in board['tasks'] as List? ?? const []) {
              if (task is Map && task['taskId'] == taskId) {
                final status = task['status'];
                if (status == 'completed' || status == 'failed') {
                  final verdict = task['verdict'];
                  verdictHeadline = verdict is Map
                      ? (verdict['verdict'] as String? ??
                            verdict['error'] as String? ??
                            '')
                      : '';
                  return true;
                }
              }
            }
            return false;
          }, attempts: 60, label: 'host board reaches a terminal status');
          // Ship the verdict: the flush in the terminating cycle may have
          // happened before completeTask wrote it.
          await _verbSafe(vm, 'storage_mesh_sync');

          // The peer READS the converged row in the console UI (its
          // periodic 30s sync is the shipping cadence — this is the
          // honest mesh latency, no verb shortcuts exist on the peer).
          await p.waitText(
            '[completed]',
            attempts: 24,
            delay: const Duration(seconds: 5),
          );
          final consoleLine = await p.textContaining('[completed]');
          if (consoleLine == null ||
              !consoleLine.contains(verdictHeadline!.split('\n').first)) {
            throw StateError(
              'peer console row does not carry the host verdict '
              '(console: ${consoleLine ?? '<none>'}; '
              'host verdict: $verdictHeadline)',
            );
          }
          await p.dumpAx('peer_after_verdict');
          row(
            'PASS',
            'task-converged',
            'peer console: $consoleLine',
          );
        },
      ),
      (
        'perm-from-peer',
        (final context) async {
          final vm = context.take<VmClient>('hostVm');
          final p = context.take<_CdpPeer>('peer');
          final routed = await _verb(vm, 'mesh_routing', {
            'enabled': true,
          });
          if (routed['ok'] != true) throw StateError('mesh_routing: $routed');

          Future<void> delegateAndAwaitPeerAnswer(
            final String task,
            final String answer,
          ) async {
            final delegated = await _verb(vm, 'agent_task_delegate', {
              'task': task,
            });
            if (delegated['ok'] != true) {
              throw StateError('agent_task_delegate: $delegated');
            }
            await _verbSafe(vm, 'storage_mesh_sync');
            // The announcement is a doc op: the host flush ships it, the
            // peer's periodic cycle absorbs it, the transcript renders
            // the routed permission row.
            await p.waitText('[$answer]', attempts: 40);
            await p.clickText('[$answer]');
            row('PASS', 'perm-$answer', 'peer answered from the transcript');
          }

          await delegateAndAwaitPeerAnswer(
            'Write one line into gate-permission-target.txt: the write gate '
            'fires, the PEER answers.',
            'reject',
          );
          // Round-trip proof: the answered row folds back to the peer as
          // plain `→ reject` text (pending buttons vanish on answer) —
          // the answer reached the host, the harness processed it, and
          // the outcome converged back.
          await p.waitText('→ reject', attempts: 60);
          await _verbSafe(vm, 'storage_mesh_sync');
          // The file oracle: a rejected write NEVER lands.
          if (permTarget.existsSync()) {
            throw StateError(
              'perm-reject: gate-permission-target.txt EXISTS after the '
              'peer rejected — the write landed',
            );
          }
          row('PASS', 'perm-reject-oracle', 'target file absent');

          await delegateAndAwaitPeerAnswer(
            'retry the write to gate-permission-target.txt',
            'allow',
          );
          await _poll(
            () async {
              await _verbSafe(vm, 'storage_mesh_sync');
              return permTarget.existsSync();
            },
            attempts: 30,
            label: 'gate-permission-target.txt to land after ALLOW',
          );
          row(
            'PASS',
            'perm-allow-oracle',
            'target file: ${permTarget.readAsStringSync().trim()}',
          );
        },
      ),
      (
        'final-convergence',
        (final context) async {
          final vm = context.take<VmClient>('hostVm');
          final p = context.take<_CdpPeer>('peer');
          final docId = context.bag['docId']! as String;
          await _verbSafe(vm, 'storage_mesh_sync');
          // Both sides agree on the task board, each through its own
          // projection: the host verb and the peer console rows.
          final hostBoard = await _verb(vm, 'mesh_tasks', {'docId': docId});
          final hostStatuses = [
            for (final t in hostBoard['tasks'] as List? ?? const [])
              if (t is Map) '${t['taskId']}=${t['status']}',
          ];
          final peerLine = await p.textContaining('[completed]');
          if (peerLine == null) {
            throw StateError('peer console lost the completed row');
          }
          await p.dumpAx('final_peer');
          File('${_evidenceDir.path}/final_host_board.json')
              .writeAsStringSync(
            const JsonEncoder.withIndent('  ').convert(hostBoard),
          );
          row(
            'PASS',
            'final-convergence',
            'host board: ${hostStatuses.join(', ')}; peer console row: '
                '$peerLine',
          );
        },
      ),
    ]);

    passed = await scenario.run();
    scenario.report.printSummary();
    if (!passed) {
      stdout.writeln('---- host tail ----');
      (host?.stdout.tail(25) ?? const <String>[]).forEach(stdout.writeln);
      try {
        await peer?.dumpAx('failure_final');
      } on Object {
        // The peer may be dead already; the tail above is the evidence.
      }
    }
  } finally {
    await peer?.stop();
    await server?.stop();
    await host?.stop();
    scratchWs.deleteSync(recursive: true);
  }
  row('VERDICT', passed ? 'MP-HGATE PASS' : 'MP-HGATE FAIL', '');
  exit(passed ? 0 : 1);
}

// ---------------------------------------------------------------------------
// Host-side helpers: the mcp-toolkit VM-service tier (unchanged).
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

/// Poll-loop variant: a transient VM-service hiccup must not abort the
/// whole run — the next cycle retries.
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

/// Poll until [action] returns non-null; returns that value. A null
/// variant of the boolean poll — steps usually need the payload.
Future<T> _poll<T>(
  final Future<T?> Function() action, {
  required final int attempts,
  final String? label,
  final Duration delay = const Duration(seconds: 2),
}) async {
  for (var i = 0; i < attempts; i++) {
    final result = await action();
    if (result != null) return result;
    await Future<void>.delayed(delay);
  }
  throw TimeoutException('poll never passed: ${label ?? 'condition'}');
}

Future<int> _teeAndWait(final Process process, final File log) async {
  final sink = log.openWrite();
  final done = Future.wait([
    process.stdout.map(utf8.decode).forEach(sink.write),
    process.stderr.map(utf8.decode).forEach(sink.write),
  ]);
  final code = await process.exitCode;
  await done;
  await sink.close();
  return code;
}

// ---------------------------------------------------------------------------
// Peer-side helpers: the CDP tier (no VM service on the web).
// ---------------------------------------------------------------------------

/// Serves a built web bundle. A plain static server with an index.html
/// fallback — the app uses hash routing, so no SPA rewrites are needed.
final class _StaticWebServer {
  _StaticWebServer._(this._server, this.root);
  final HttpServer _server;
  final Directory root;
  Uri get base => Uri.parse('http://127.0.0.1:${_server.port}/');

  static const _mime = <String, String>{
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.mjs': 'application/javascript',
    '.json': 'application/json',
    '.wasm': 'application/wasm',
    '.css': 'text/css',
    '.png': 'image/png',
    '.svg': 'image/svg+xml',
    '.ttf': 'font/ttf',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.map': 'application/json',
  };

  static Future<_StaticWebServer> start(
    final Directory root,
    final int port,
  ) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    server.listen((final request) async {
      final path = request.uri.path == '/' ? '/index.html' : request.uri.path;
      var file = File('${root.path}$path');
      if (!file.existsSync()) file = File('${root.path}/index.html');
      final ext = file.path.contains('.')
          ? file.path.substring(file.path.lastIndexOf('.'))
          : '';
      request.response.headers.contentType =
          ContentType.parse(_mime[ext] ?? 'application/octet-stream');
      await request.response.addStream(file.openRead());
      await request.response.close();
    });
    return _StaticWebServer._(server, root);
  }

  Future<void> stop() => _server.close(force: true);
}

/// The CDP-driven web peer. See the file-header driving split: locate by
/// text/aria-label in the LIVE `flt-semantics` DOM (the AX cache's
/// backendDOMNodeIds go stale on Flutter web), click the bounding-box
/// center, type into the focused field, read the AX snapshot.
final class _CdpPeer {
  _CdpPeer._(this.chrome, this.page, this.driver) {
    // Console + uncaught exceptions are app-side evidence: a flaky build
    // throw renders as a canvas error screen — invisible in the DOM.
    _console = File('${_evidenceDir.path}/peer_console.log')
        .openWrite(mode: FileMode.append);
    page.connection.on('Runtime.consoleAPICalled').listen((final event) {
      final args = event.params['args'] as List? ?? const [];
      final text = [
        for (final arg in args)
          if (arg is Map) (arg['value'] ?? arg['description'] ?? '').toString(),
      ].join(' ');
      _console?.writeln('[console] $text');
    });
    page.connection.on('Runtime.exceptionThrown').listen((final event) {
      final details = event.params['exceptionDetails'];
      _console?.writeln('[exception] ${const JsonEncoder().convert(details)}');
    });
  }
  final LaunchedChrome chrome;
  final CdpPage page;
  final CdpDriver driver;
  IOSink? _console;

  static Future<_CdpPeer> launch(final Uri url) async {
    final target = ChromeAppTarget(
      port: await _freePort(),
      headless: false,
      startUrl: url,
    );
    final chrome = await target.launch();
    final session = await chrome.attach();
    if (File('${_evidenceDir.path}/peer_console.log').existsSync()) {
      File('${_evidenceDir.path}/peer_console.log').deleteSync();
    }
    await session.page.navigate(url, waitUntil: NavigateWait.networkIdle);
    return _CdpPeer._(chrome, session.page, session.driver);
  }

  /// A fresh accessibility snapshot as compact JSON (evidence dumps).
  Future<List<Map<String, Object?>>> axNodes() async {
    final snap = await driver.snapshot();
    return [
      for (final node in snap.nodes)
        {
          'role': node.role,
          if ((node.name ?? '').isNotEmpty) 'name': node.name,
          if ((node.value ?? '').isNotEmpty) 'value': node.value,
        },
    ];
  }

  Future<void> dumpAx(final String label) async {
    final nodes = await axNodes();
    final domTexts = await page.evaluate(
      '''
(() => { const els = [...document.querySelectorAll('flt-semantics')];
      return JSON.stringify(els.map(e => (e.textContent ||
        e.getAttribute('aria-label') || '').trim())
        .filter(t => t.length > 0).slice(0, 80)); })()''',
    );
    File('${_evidenceDir.path}/ax_$label.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'ax': nodes,
        'dom_texts': domTexts,
      }),
    );
  }

  /// A sacrificial click on the page body — the first pointer event
  /// after load is swallowed by the Flutter web engine, so burn it on
  /// nothing before real interactions.
  Future<void> warmUpClick() async {
    await page.connection.send('Page.bringToFront');
    await page.clickAt(680, 500);
  }

  /// Click the LAST `flt-semantics` whose text content or aria-label
  /// CONTAINS [text]. Last match wins: dialogs and the doc surface sit
  /// deeper in the DOM than the page chrome, and a newer transcript row
  /// is newer data. Clicks are real input events at the bounding-box
  /// center (page.clickAt).
  Future<void> clickText(
    final String text, {
    final int attempts = 8,
    final Duration delay = const Duration(seconds: 1),
  }) =>
      clickTextUntil(text, attempts: attempts, delay: delay);

  /// Click [text] until [expect] is visible — Flutter web swallows the
  /// first click after load (measured here and in the glide web demo),
  /// so a state-transition click is retried until its EFFECT shows.
  Future<void> clickTextUntil(
    final String text, {
    final String? expect,
    final int attempts = 10,
    final Duration delay = const Duration(seconds: 1),
  }) async {
    for (var i = 1; i <= attempts; i++) {
      // Effect FIRST: a re-click of a toggle flips it back off (the mesh
      // checkbox measured exactly that) — only click while the expected
      // state is absent.
      if (expect != null && await _stableRect(expect) != null) {
        row('PASS', 'peer-click', '"$text" → "$expect" visible');
        return;
      }
      final box = await _stableRect(text);
      if (box != null) {
        await page.clickAt(box.$1, box.$2);
        if (expect == null) {
          row(
            'PASS',
            'peer-click',
            '"$text" @ (${box.$1.toStringAsFixed(0)}, '
            '${box.$2.toStringAsFixed(0)})',
          );
          return;
        }
      }
      await Future<void>.delayed(delay);
    }
    await dumpAx('click_miss_$text');
    throw StateError(
      'clickText never landed "$text"'
      '${expect == null ? '' : ' (effect "$expect" never showed)'}',
    );
  }

  /// A rect that reads the SAME twice, 300ms apart — panels animate open
  /// after a click, and a rect taken mid-animation clicks whatever widget
  /// scrolls under the coordinates (measured: the mesh checkbox toggled
  /// itself off and unmounted the panel).
  Future<(double, double)?> _stableRect(final String text) async {
    final first = await _rectOf(text);
    if (first == null) return null;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final second = await _rectOf(text);
    if (second == null) return null;
    const tolerance = 3.0;
    return (first.$1 - second.$1).abs() <= tolerance &&
            (first.$2 - second.$2).abs() <= tolerance
        ? second
        : null;
  }

  Future<(double, double)?> _rectOf(final String text) async {
    final raw = await page.evaluate(
      '(() => { const els = [...document.querySelectorAll("flt-semantics")];'
      ' const el = els.reverse().find(e => '
      '(e.textContent || "").includes("$text") || '
      '(e.getAttribute("aria-label") || "").includes("$text"));'
      ' if (!el) return null;'
      ' const b = el.getBoundingClientRect();'
      ' if (b.width < 2 || b.height < 2) return null;'
      ' return JSON.stringify({x: b.x + b.width / 2, '
      'y: b.y + b.height / 2}); })()',
    );
    if (raw is! String || raw.isEmpty) return null;
    final box = jsonDecode(raw) as Map<String, Object?>;
    return ((box['x']! as num).toDouble(), (box['y']! as num).toDouble());
  }

  /// The settings chrome's close button: the FIRST top-left button in
  /// the live DOM (leading position of the settings app bar). In-app
  /// navigation only — a page reload would drop the memory mesh store.
  /// Pops the settings route while its chrome is visible — via
  /// `history.back()`: go_router pushed the route, so a history pop is
  /// the app's own in-app back (no reload, no focus needed, nothing
  /// clicked — the click heuristics proved unstable here).
  Future<void> leaveSettings({final int attempts = 15}) async {
    for (var i = 1; i <= attempts; i++) {
      final inSettings =
          await _rectOf('Advanced settings (debug)') != null ||
              await _rectOf('Theme:') != null;
      if (!inSettings) return;
      // Input events are focus-sensitive: re-forward the page before
      // every mechanism.
      await page.connection.send('Page.bringToFront');
      // 1) the app bar's leading close button (leftmost top-row control
      //    of the centered settings column).
      try {
        await clickTopLeftButton();
      } on Object {
        // 2) history pop (router-level pushes only)…
        await page.evaluate('history.back()');
        // 3) …and Escape (needs the focus bringToFront restored).
        await page.keyPress('Escape');
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    await dumpAx('leave_settings_miss');
    throw StateError('settings never closed');
  }

  /// First of [texts] present in the live DOM, polled for [attempts];
  /// null when none appears.
  Future<String?> waitAny(
    final List<String> texts, {
    final int attempts = 30,
    final Duration delay = const Duration(seconds: 2),
  }) async {
    for (var i = 1; i <= attempts; i++) {
      for (final text in texts) {
        if (await _rectOf(text) != null) return text;
      }
      await Future<void>.delayed(delay);
    }
    return null;
  }

  /// Pops pushed routes until [expect] is visible (in-app navigation
  /// only — a reload would drop the memory mesh store). Primary: the
  /// settings chrome's leading close button (top-left). Fallback:
  /// Escape, which needs page focus (bringToFront first — key events to
  /// a background window land nowhere, same as typing).
  Future<void> popUntilText(
    final String key,
    final String expect, {
    final int attempts = 12,
  }) async {
    await page.connection.send('Page.bringToFront');
    for (var i = 1; i <= attempts; i++) {
      if (await _rectOf(expect) != null) return;
      try {
        await clickTopLeftButton();
      } on ProtocolException {
        // No close button on this screen — the Escape below carries on.
      }
      await page.keyPress('Escape');
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    await dumpAx('pop_miss_$key');
    throw StateError('never revealed "$expect" after $attempts pops');
  }

  /// The leading top-left button of the current screen chrome (the
  /// settings close button sits at AppBar.leading).
  Future<void> clickTopLeftButton() async {
    final raw = await page.evaluate(
      '''
(() => { const els = [...document.querySelectorAll(
        'flt-semantics[role="button"]')];
      const row = els.filter(e => { const b = e.getBoundingClientRect();
        return b.top >= 0 && b.top < 80 && b.width > 2 && b.height > 2; });
      if (!row.length) return null;
      const el = row.sort((a, b) =>
        a.getBoundingClientRect().left - b.getBoundingClientRect().left)[0];
      if (!el) return null;
      const b = el.getBoundingClientRect();
      return JSON.stringify({x: b.x + b.width / 2, y: b.y + b.height / 2});
      })()''',
    );
    if (raw is! String || raw.isEmpty) {
      throw StateError('no top-left button found');
    }
    final box = jsonDecode(raw) as Map<String, Object?>;
    await page.clickAt(
      (box['x']! as num).toDouble(),
      (box['y']! as num).toDouble(),
    );
  }

  /// Types into the FOCUSED editable. `Input.insertText` goes straight
  /// to the page's focused element's caret — a background Chrome window
  /// has no OS focus, so per-key `Input.dispatchKeyEvent` events (the
  /// driver's page.type) silently land nowhere (measured: field stayed
  /// empty, window `document.hasFocus()` false).
  Future<void> typeFocused(final String text) async {
    await page.connection.send('Page.bringToFront');
    await page.connection.send('Input.insertText', {'text': text});
  }

  /// The editable inside the pairing dialog (`[role="alertdialog"]`) —
  /// the settings screen carries text boxes of its own, so "the last
  /// input on the page" reads the wrong field (measured).
  Future<String?> textboxValue() async {
    final raw = await page.evaluate(
      '''
(() => { const dialog = document.querySelector(
        'flt-semantics[role="alertdialog"]');
      if (!dialog) return null;
      const el = dialog.querySelector('textarea, input');
      return el ? String(el.value ?? '') : null; })()''',
    );
    return raw is String ? raw : null;
  }

  /// True when the live DOM carries [text] (textContent or aria-label).
  Future<bool> hasText(final String text) async =>
      await _rectOf(text) != null;

  Future<void> waitText(
    final String text, {
    final int attempts = 30,
    final Duration delay = const Duration(seconds: 2),
  }) async {
    for (var i = 1; i <= attempts; i++) {
      if (await hasText(text)) return;
      await Future<void>.delayed(delay);
    }
    await dumpAx('wait_miss_$text');
    throw TimeoutException('peer never showed "$text"');
  }

  /// The first AX node whose name CONTAINS [text] — the console row is
  /// plain data (`[<status>] <task> — verdict: …`), so this reads back
  /// what the human/agent sees.
  Future<String?> textContaining(final String text) async {
    final snap = await driver.snapshot();
    for (final node in snap.nodes) {
      final name = node.name ?? '';
      if (name.contains(text)) return name;
    }
    return null;
  }

  Future<void> stop() async {
    await _console?.flush();
    await _console?.close();
    await chrome.stop();
  }
}

/// A free loopback port (bind-and-close race is acceptable here: the
/// window is one Chrome boot).
Future<int> _freePort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}
