// TASK B / R8 — the AFM e2e gate: a REAL on-device coding task through the
// embedded harness, run as a real macOS app:
//
//   flutter test integration_test/coding_agent_afm_e2e_test.dart -d macos
//
// Requires macOS 26+ with Apple Intelligence enabled. The backend is
// `apple_foundation_afm` (the daemon's lean profile — the ~4k on-device
// window). The user-actor auto-allows the write round-trip (the app's
// permission UI is the same surface a human taps). A FAIL is an honest
// result — the transcript is printed for failure classification, never
// dropped.
//
// Skips honestly (no failure) when the AFM engine is unavailable on this
// machine — the gate is runtime-gated, not CI-gated.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';
import 'package:xsoulspace_inference_apple_foundation/xsoulspace_inference_apple_foundation.dart';

const _afmUnavailableMarker = 'AFM_UNAVAILABLE';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'AFM e2e: real on-device task — delegate → permission → verdict',
    (final tester) async {
      // Runtime availability gate: Apple Intelligence may be off. Skips
      // honestly instead of failing the suite on a machine that cannot
      // possibly run the gate.
      final afm = AppleFoundationNativeClient();
      final available = await afm.refreshAvailability();
      if (!available) {
        // ignore: avoid_print
        print('$_afmUnavailableMarker: AFM engine unavailable — skip');
        return;
      }

      // Fixture: a bare main.dart (no pubspec) — the D8 workspace
      // convention resolves to `dart run main.dart`; fully self-contained.
      final workspace = await Directory.systemTemp.createTemp(
        'lastanswer_afm_e2e',
      );
      addTearDown(() {
        try {
          workspace.deleteSync(recursive: true);
        } on Object {
          // best effort
        }
      });
      File('${workspace.path}/main.dart').writeAsStringSync(
        "void main() { throw StateError('not implemented'); }\n",
      );

      final controller = HarnessSessionController(
        config: const HarnessHostConfig(),
      );
      addTearDown(controller.dispose);
      // The user-actor approves writes (the permission UI answers these in
      // production; auto-allow here keeps the e2e unattended).
      controller.host.permissionRequests.listen((final p) => p.allow());

      await tester.pumpWidget(
        MaterialApp(home: CodingAgentScreen(controller: controller)),
      );

      // The full UI flow: type workspace + sentence, delegate.
      await tester.enterText(
        find.byKey(const Key('coding_agent.workspace')),
        workspace.path,
      );
      await tester.enterText(
        find.byKey(const Key('coding_agent.task')),
        'Fix main.dart: replace the throw with a print of "ok" so '
        '`dart run main.dart` exits 0.',
      );
      await tester.tap(find.byKey(const Key('coding_agent.delegate')));
      await tester.pump();
      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pump();
      // ignore: avoid_print
      print(
        'AFM e2e after delegate tap: error=${controller.error} '
        'current=${controller.current?.id} '
        'sessions=${controller.sessions.length} '
        'running=${controller.isRunning}',
      );

      // Real async under the integration binding: poll with real delays
      // until the turn ends (AFM generation + dart run — minutes at most).
      const poll = Duration(milliseconds: 250);
      final deadline = DateTime.now().add(const Duration(minutes: 12));
      while (controller.isRunning && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(poll);
        await tester.pump();
      }

      final transcript = controller.current?.transcript.toString() ?? '';
      // ignore: avoid_print
      print('AFM e2e transcript:\n$transcript');
      // ignore: avoid_print
      print('AFM e2e verdict: ${controller.current?.verdictLine}');

      expect(
        controller.current?.hasVerdict,
        isTrue,
        reason: 'the verdict must surface (transcript:\n$transcript)',
      );
      expect(
        controller.current?.verdictPassed,
        isTrue,
        reason:
            'AFM should fix the fixture on-device '
            '(transcript:\n$transcript)',
      );
      expect(
        File('${workspace.path}/main.dart').readAsStringSync(),
        contains('ok'),
        reason: 'the write must land (transcript:\n$transcript)',
      );
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
