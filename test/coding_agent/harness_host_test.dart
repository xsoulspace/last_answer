// TASK B — embedded-harness end-to-end gate (LLM-free, scripted mover):
//
// 1. the host starts the REAL daemon stack in-process (HarnessAcpBackend +
//    AcpStdioServer over an in-memory channel) and runs one scripted
//    session: delegate → WRITE permission round-trip (allow) → verdict
//    surfaces as PASS and the write lands;
// 2. the deny path: the same session rejects the write — the content never
//    lands and the verdict surfaces as FAIL (failures are data);
// 3. the daemon lifecycle is controllable from the host: start, per-
//    workspace session continuation, stop.

import 'dart:io';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart' show AcpStopReason;
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';

import 'scripted_write_mover.dart';

/// The scripted mover lives in [ScriptedWriteMover] (shared with the
/// widget test) — one gated `write`, then done.

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('lastanswer_harness');
    // Bare main.dart (no pubspec) — the D8 workspace convention resolves to
    // `dart run main.dart`, which needs no pub get: fully self-contained.
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

  ScriptedWriteMover scriptedMover() =>
      ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n");

  HarnessHost scriptedHost() => HarnessHost(
    config: HarnessHostConfig(handlerFactory: (_) => scriptedMover()),
  );

  test('delegate → permission (allow) → verdict surfaces as PASS, '
      'the write lands', () async {
    final host = scriptedHost();
    addTearDown(host.stop);
    await host.start();

    final sessionId = await host.newSession(workspace.path);
    expect(sessionId, isNotEmpty);

    // The user-actor answers every permission request with allow.
    host.permissionRequests.listen((final pending) => pending.allow());

    final chunks = StringBuffer();
    final stop = await host.delegateTask(
      sessionId,
      'Fix main.dart so `dart run main.dart` exits 0.',
      onText: chunks.write,
    );

    expect(stop, AcpStopReason.endTurn, reason: chunks.toString());
    expect(chunks.toString(), contains('verdict: PASS'));
    expect(
      File('${workspace.path}/main.dart').readAsStringSync(),
      contains("print('ok')"),
      reason: 'the allowed write must land',
    );
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('delegate → permission (reject) → the write never lands, '
      'verdict surfaces as FAIL', () async {
    final host = scriptedHost();
    addTearDown(host.stop);
    await host.start();

    final sessionId = await host.newSession(workspace.path);
    host.permissionRequests.listen((final pending) => pending.reject());

    final chunks = StringBuffer();
    await host.delegateTask(
      sessionId,
      'Fix main.dart so `dart run main.dart` exits 0.',
      onText: chunks.write,
    );

    expect(chunks.toString(), contains('verdict: FAIL'));
    expect(
      File('${workspace.path}/main.dart').readAsStringSync(),
      isNot(contains("print('ok')")),
      reason: 'a rejected write must never land',
    );
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('daemon lifecycle: sessions are keyed per workspace and the host can '
      'start/stop cleanly', () async {
    final host = scriptedHost();
    addTearDown(host.stop);
    await host.start();
    expect(host.isRunning, isTrue);

    // Per-workspace keying (R7c): a second session/new for the same cwd
    // continues ONE session — the world (and snapshot store) persist.
    final first = await host.newSession(workspace.path);
    final second = await host.newSession(workspace.path);
    expect(second, first);

    await host.stop();
    expect(host.isRunning, isFalse);
    expect(
      Directory('${workspace.path}/.dart_tool/harnessd_store').existsSync(),
      isTrue,
      reason: 'the per-workspace snapshot store must exist',
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}
