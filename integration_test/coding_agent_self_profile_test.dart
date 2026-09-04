// ADR 0003 Phase 1 — the self-profiling gate: the app's agent-doc surface
// delegates a REAL task against THIS codebase (last_answer itself), graded
// by its own analyzer. This is the dogfooding proof the product direction
// asks for: "start working with AFM and the agentic harness on its own
// codebase".
//
// GATED: the task mutates the repository (a dartdoc comment), so it only
// runs when explicitly requested:
//
//   LASTANSWER_SELF_PROFILE=1 flutter test \
//     integration_test/coding_agent_self_profile_test.dart -d macos
//
// Requires macOS 26+ with Apple Intelligence enabled; skips honestly
// otherwise (and when the flag is absent).
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';
import 'package:xsoulspace_inference_apple_foundation/xsoulspace_inference_apple_foundation.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'self-profile: agent doc bound to THIS repo, AFM task, analyzer oracle',
    (final tester) async {
      if (Platform.environment['LASTANSWER_SELF_PROFILE'] != '1') {
        // ignore: avoid_print
        print('SELF_PROFILE_SKIPPED: set LASTANSWER_SELF_PROFILE=1 to run');
        return;
      }
      final afm = AppleFoundationNativeClient();
      if (!await afm.refreshAvailability()) {
        // ignore: avoid_print
        print('AFM_UNAVAILABLE: AFM engine unavailable — skip');
        return;
      }

      // Inside the macOS test app, Directory.current is NOT the project
      // dir — resolve the repo by walking up from the executable until a
      // pubspec.yaml with lib/coding_agent is found.
      var repo = File(Platform.resolvedExecutable).parent.path;
      var found = false;
      for (var i = 0; i < 8; i++) {
        if (File('$repo/pubspec.yaml').existsSync() &&
            Directory('$repo/lib/coding_agent').existsSync()) {
          found = true;
          break;
        }
        repo = File('$repo/..').parent.path;
      }
      if (!found) {
        // ignore: avoid_print
        print('SELF_PROFILE_SKIPPED: repo root not found from executable');
        return;
      }
      // ignore: avoid_print
      print('SELF PROFILE workspace: $repo');
      final target = '$repo/lib/coding_agent/harness_session_controller.dart';
      final before = File(target).readAsStringSync();

      final doc = ProjectModel.emptyAgent() as ProjectModelDoc;
      // The doc's check override: the workspace convention of THIS repo is
      // `flutter test` (minutes) — the doc binding narrows the oracle to
      // the analyzer over the touched directories, exactly like the CLI's
      // --check. Small, mechanical, verifiable.
      final docWithCheck = doc.copyWith(
        agent: (doc.agent ?? const AgentDocModel()).copyWith(
          workspaces: [repo],
          checkCommand: ['dart', 'analyze', 'lib/coding_agent'],
        ),
      );
      final controller = HarnessSessionController(
        config: const HarnessHostConfig(
          checkCommand: ['dart', 'analyze', 'lib/coding_agent'],
        ),
      );
      addTearDown(controller.dispose);
      controller.host.permissionRequests.listen((final p) => p.allow());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(doc: docWithCheck, controller: controller),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('coding_agent.workspace')),
        repo,
      );
      await tester.enterText(
        find.byKey(const Key('coding_agent.task')),
        'Improve the doc comment on HarnessSessionController.switchBackend: '
        'state in two sentences that switching restarts the daemon and '
        'that the per-workspace snapshot store restores the world on the '
        'next session. Then run dart analyze lib/coding_agent to verify.',
      );
      await tester.tap(find.byKey(const Key('coding_agent.delegate')));
      await tester.pump();

      final deadline = DateTime.now().add(const Duration(minutes: 12));
      while (controller.isRunning && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await tester.pump();
      }

      final transcript = controller.current?.transcript.toString() ?? '';
      // ignore: avoid_print
      print('SELF PROFILE transcript:\n$transcript');
      // ignore: avoid_print
      print('SELF PROFILE verdict: ${controller.current?.verdictLine}');
      // ignore: avoid_print
      final changed = File(target).readAsStringSync() != before;
      // ignore: avoid_print
      print(
        'SELF PROFILE diff: '
        "${changed ? 'CHANGED — review with git diff' : '(file unchanged)'}",
      );

      expect(
        controller.current?.hasVerdict,
        isTrue,
        reason: 'the verdict must surface (transcript:\n$transcript)',
      );
      expect(
        controller.current?.verdictPassed,
        isTrue,
        reason:
            'AFM should land the dartdoc edit on-device '
            '(transcript:\n$transcript)',
      );
      expect(
        docWithCheck.agent!.checkCommand,
        isNotEmpty,
        reason: 'the doc binding carries the check override (ADR 0003)',
      );
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
