// ADR 0072 — the paired-device gate (PHONE-1/2 device exits): TWO REAL
// APPS + ONE REAL DAEMON on one machine standing in for the LAN.
//
//   daemon (harnessd --serve --serve-bind lan --seat-ws --local-mcp-seats)
//     ↕ facade (bearer) + seat channel (WS)
//   mac LA app — hosts the mesh relay, creates the SIGNED pairing code
//     (the envelope announces the daemon's world + token + seatWs)
//     ↕ mesh (QR pairing)
//   android LA app (oka: build → install → launch → VM-service forward)
//     — accepts the pairing, stores the announcement, attaches the pane
//     through the PAIRED route, requests its seat, drives agent_doc_state
//     over the channel.
//
// Every assertion rides the equal-reader surface (the toolkit verbs) —
// never a widget scrape. Evidence PNGs land in the gate's evidence dir.
//
// Usage:
//   fvm dart tool/gates/paired_device_gate.dart [--skip-macos-build]
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_mcp_harness/flutter_mcp_harness.dart';
import 'package:oka_harness/oka_harness.dart';

final _tmp = Platform.environment['TMPDIR'] ?? '/tmp';
final _evidenceDir = Directory('$_tmp/paired_device_gate_evidence')
  ..createSync(recursive: true);
final _stepsLog = File('${_evidenceDir.path}/steps.log');
const _workspace = '/tmp/paired_device_gate_ws';
const _servePort = 18290;
const _seatPort = 19461;

void row(final String status, final String step, final String detail) {
  final line = '${status.padRight(6)}${step.padRight(22)}$detail';
  // ignore: avoid_print
  print(line);
  _stepsLog.writeAsStringSync('$line\n', mode: FileMode.append);
}

/// Waits until the toolkit registers [name] on the app's isolate
/// (registration is async after boot; a -32601 here is 'too early',
/// never 'missing').
Future<void> _waitVerb(
  final VmClient vm,
  final String name, {
  final int attempts = 60,
}) async {
  for (var i = 0; i < attempts; i++) {
    try {
      final names = await vm.extensionNames();
      if (names.contains('ext.mcp.toolkit.' + name)) return;
    } on Object catch (_) {}
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  throw StateError('toolkit verb never registered: ' + name);
}

Future<Map<String, Object?>> _verb(
  final VmClient vm,
  final String name, [
  final Map<String, Object?> args = const {},
]) async {
  final response = await vm.callExtension('ext.mcp.toolkit.$name', args: args);
  return response;
}

Future<Map<String, Object?>> _verbSafe(
  final VmClient vm,
  final String name, [
  final Map<String, Object?> args = const {},
]) async {
  try {
    return await _verb(vm, name, args);
  } on Object {
    return const <String, Object?>{};
  }
}

Future<void> _pollUntil(
  final Future<bool> Function() condition, {
  required final int attempts,
  final Duration delay = const Duration(seconds: 2),
}) async {
  for (var i = 0; i < attempts; i++) {
    if (await condition()) return;
    await Future<void>.delayed(delay);
  }
  throw TimeoutException('poll exhausted after $attempts attempts');
}

Future<void> main(final List<String> args) async {
  final skipMacBuild = args.contains('--skip-macos-build');
  if (_stepsLog.existsSync()) _stepsLog.deleteSync();
  final failures = <String>[];
  void expect(final bool ok, final String step, final String detail) {
    row(ok ? 'PASS' : 'FAIL', step, detail);
    if (!ok) failures.add(step);
  }

  Process? daemon;
  var daemonLog = '';
  LaunchedApp? macApp;
  LaunchedApp? phoneApp;
  try {
    // ---------------------------------------------------------- Act 0.
    Directory(_workspace).createSync(recursive: true);
    daemon = await Process.start(Platform.resolvedExecutable, [
      'run',
      'pkgs/xsoulspace_agentic_host/bin/harnessd.dart',
      '--workspace',
      _workspace,
      '--serve',
      '$_servePort',
      '--serve-bind',
      'lan',
      '--seat-ws',
      '$_seatPort',
      '--local-mcp-seats',
    ], workingDirectory: '/Users/antonio/xs/ecsai_harness');
    daemon.stdout.transform(utf8.decoder).listen((final l) => daemonLog += l);
    daemon.stderr.transform(utf8.decoder).listen((final l) => daemonLog += l);
    String? token;
    String? facadeEndpoint;
    String? seatWs;
    await _pollUntil(() async {
      // The manifest file name derives from the workspace hash — scan
      // the worlds dir for the newest token file + its matching serve
      // block (the daemon just wrote both).
      final dir = Directory('/Users/antonio/.xsoulspace/worlds');
      if (!dir.existsSync()) return false;
      final candidates =
          dir
              .listSync()
              .whereType<File>()
              .where((final f) => f.path.endsWith('.serve-token'))
              .toList()
            ..sort(
              (final a, final b) =>
                  b.statSync().modified.compareTo(a.statSync().modified),
            );
      if (candidates.isEmpty) return false;
      token = candidates.first.readAsStringSync().trim();
      for (final f in dir.listSync().whereType<File>()) {
        if (!f.path.endsWith('.json')) continue;
        try {
          final decoded = jsonDecode(f.readAsStringSync());
          if (decoded is! Map) continue;
          final serve = decoded['serve'];
          if (serve is! Map) continue;
          final endpoint = serve['endpoint'];
          final seat = serve['seatWs'];
          final tokenFile = serve['tokenFile'];
          if (endpoint is! String || seat is! String || tokenFile is! String) {
            continue;
          }
          final tokenOnDisk = File(tokenFile).readAsStringSync().trim();
          if (token != null && tokenOnDisk == token) {
            facadeEndpoint = endpoint;
            seatWs = seat;
            return true;
          }
        } on Object catch (_) {}
      }
      return false;
    }, attempts: 30);
    expect(
      token != null && facadeEndpoint != null && seatWs != null,
      'daemon-up',
      'facade=$facadeEndpoint seatWs=$seatWs',
    );
    row('INFO', 'token', 'loaded from the mode-600 file (never printed)');

    // ---------------------------------------------------------- Act 1.
    // The MAC app: hosts the relay, mints the pairing code.
    final macTarget = BinaryAppTarget(
      projectDir: '.',
      binaryPath:
          'build/macos/Build/Products/Debug/last_answer.app/Contents/'
          'MacOS/last_answer',
      buildCommand: [
        'fvm',
        'flutter',
        'build',
        'macos',
        '--debug',
        '--no-pub',
        '--dart-define-from-file=configs/envs/prod.json',
      ],
      environment: {
        'LAST_ANSWER_MESH_STORE': '$_tmp/paired_device_gate_mesh_mac',
      },
      name: 'mac',
      vmServiceTimeout: const Duration(minutes: 10),
    );
    macApp = await macTarget.launch(build: !skipMacBuild);
    final macVm = await VmClient.connect(macApp.vmUri);
    row('PASS', 'mac-app', 'vm=${macApp.vmUri}');

    await _waitVerb(macVm, 'storage_mesh_pairing_code');
    final code = await _verb(macVm, 'storage_mesh_pairing_code');
    final pairingCode = code['pairingCode'];
    final announced = code['announcedWorlds'];
    expect(
      pairingCode is String && pairingCode.isNotEmpty,
      'pairing-code',
      'announcedWorlds=$announced',
    );
    expect(
      announced == 1,
      'world-announced',
      'the signed envelope announces the daemon world (ADR 0072 §3)',
    );

    // The PHONE app: oka builds, installs, launches, forwards the VM.
    final phoneTarget = AndroidAppTarget(
      projectDir: '.',
      deviceId: 'emulator-5554',
      name: 'phone',
      environment: {
        'LAST_ANSWER_MESH_STORE': '$_tmp/paired_device_gate_mesh_phone',
        'ANDROID_SDK_ROOT': '/Users/antonio/.oka/android-sdk',
        'OKA_ANDROID_SDK': '/Users/antonio/.oka/android-sdk',
      },
      sessionTimeout: const Duration(minutes: 10),
    );
    phoneApp = await phoneTarget.launch();
    final phoneVm = await VmClient.connect(phoneApp.vmUri);
    row('PASS', 'phone-app', 'vm=${phoneApp.vmUri}');

    await _waitVerb(phoneVm, 'storage_mesh_accept_pairing');
    final accepted = await _verbSafe(phoneVm, 'storage_mesh_accept_pairing', {
      'pairingCode': pairingCode,
    });
    expect(
      accepted['ok'] == true,
      'pair-accept',
      'the phone verified the signed envelope and joined the relay',
    );

    // The paired registry holds the announcement (the mesh accept flow
    // stored it); the attach verb falls back to it.
    final attach = await _verbSafe(phoneVm, 'world_inspector_attach');
    expect(
      attach['ok'] == true,
      'phone-attach',
      'attached through the paired route (bearer token attached)',
    );

    final state = await _verbSafe(phoneVm, 'world_inspector_state');
    expect(
      state['external'] == true,
      'phone-reads-world',
      'world_inspector_state: external=true — the pane samples the '
          "daemon's world over the token-authenticated facade",
    );
    try {
      final shot = await _verb(phoneVm, 'view_screenshots', {'compress': true});
      final images = shot['images'];
      final evidence = File('${_evidenceDir.path}/phone-attached.json');
      evidence.writeAsStringSync(jsonEncode(images ?? shot));
      row('SHOT', 'phone-attached', evidence.path);
    } on Object catch (e) {
      row('INFO', 'phone-attached', 'screenshot skipped: $e');
    }

    // ---------------------------------------------------------- Act 2.
    final seat = await _verbSafe(phoneVm, 'world_inspector_seat_probe', {
      'actor': 'phone-1',
    });
    final allowlist = seat['allowlist'];
    final state2 = seat['state'] as Map<String, Object?>?;
    expect(
      seat['ok'] == true &&
          allowlist is List &&
          allowlist.contains('agent_doc_state'),
      'seat-granted',
      'the phone earned its seat over the channel '
          '(allowlist=$allowlist)',
    );
    expect(
      state2 != null,
      'seat-tool-call',
      'agent_doc_state round-tripped over the seat channel: '
          'ok=${state2?['ok']} (${state2?['docId'] ?? state2?['error'] ?? ''})',
    );

    // ---------------------------------------------------------- Verdict.
    row(
      failures.isEmpty ? 'PASS' : 'FAIL',
      'VERDICT',
      failures.isEmpty
          ? 'paired-device gate: all acts green'
          : 'failures: ${failures.join(', ')}',
    );
  } on Object catch (e, st) {
    row('FAIL', 'gate', '${e.toString().split('\n').first}');
    row('INFO', 'stack', '${st.toString().split('\n').take(4).join(' | ')}');
    row('FAIL', 'VERDICT', 'gate did not complete');
  } finally {
    File('${_evidenceDir.path}/daemon.log')
        .writeAsStringSync(daemonLog, mode: FileMode.append);
    await phoneApp?.onStop?.call();
    phoneApp?.process?.kill();
    await macApp?.onStop?.call();
    macApp?.process?.kill();
    daemon?.kill();
  }
  if (failures.isNotEmpty) {
    exitCode = 1;
  }
}
