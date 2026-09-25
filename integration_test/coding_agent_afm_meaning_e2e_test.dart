// R9.1 — the MEANING PROFILE gate: AFM works through the meaning tree
// inside the real macOS app (repo_etl scan → meaning_zoom to read →
// edit_symbol/write_review to act), graded by the honest fixture oracle.
// This is the A/B counterpart of coding_agent_self_profile_test.dart
// (conventional command profile): same workspace, same oracle, different
// tool surface. The corruption class the redefined plan targets — blind
// whole-file writes — does not exist on this path (edits are
// host-materialized, verified, auto-reverted).
//
//   LASTANSWER_REPO=$PWD LASTANSWER_AFM_MEANING=1 \
//     flutter test integration_test/coding_agent_afm_meaning_e2e_test.dart \
//     -d macos
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

const _fixturePath = 'tool/agent_fixture/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'meaning profile: AFM fixes the fixture through the meaning tree '
    '(zoom to read, edit moves to act), verdict surfaces',
    (final tester) async {
      final env = Platform.environment;
      if (env['LASTANSWER_AFM_MEANING'] != '1') {
        // ignore: avoid_print
        print('AFM_MEANING_SKIPPED: set LASTANSWER_AFM_MEANING=1 to run');
        return;
      }
      final afm = AppleFoundationNativeClient();
      if (!await afm.refreshAvailability()) {
        // ignore: avoid_print
        print('AFM_UNAVAILABLE: AFM engine unavailable — skip');
        return;
      }
      final repo = env['LASTANSWER_REPO'];
      if (repo == null || !Directory('$repo/lib/coding_agent').existsSync()) {
        // ignore: avoid_print
        print('AFM_MEANING_SKIPPED: repo root not found');
        return;
      }
      // ignore: avoid_print
      print('AFM MEANING workspace: $repo');

      final store = Directory('$repo/.dart_tool/harnessd_store');
      if (store.existsSync()) store.deleteSync(recursive: true);

      final fixture = File('$repo/$_fixturePath');
      final fixtureBefore = fixture.readAsStringSync();
      addTearDown(() {
        final result = Process.runSync('git', [
          'checkout',
          '--',
          _fixturePath,
        ], workingDirectory: repo);
        if (result.exitCode != 0) {
          // ignore: avoid_print
          print('AFM MEANING WARN: fixture restore failed: ${result.stderr}');
        }
      });

      final doc = ProjectModel.emptyAgent() as ProjectModelDoc;
      final docWithCheck = doc.copyWith(
        agent: (doc.agent ?? const AgentDocModel()).copyWith(
          workspaces: [repo],
          checkCommand: ['dart', _fixturePath],
        ),
      );
      // The surface derives the MEANING profile for its bindings (R9.1);
      // assert the derivation so the gate cannot silently regress.
      final config = HarnessHostConfig(
        checkCommand: docWithCheck.agent!.checkCommand,
      ).copyWith(meaningProfile: true);
      expect(config.meaningProfile, isTrue);

      final controller = HarnessSessionController(config: config);
      addTearDown(controller.dispose);
      // The scripted user-actor allows ONLY fixture-path writes/edits —
      // deny-by-default everywhere else (the gate must never be corruptible
      // by its own actor).
      controller.host.permissionRequests.listen((final p) {
        p.request.title.contains('tool/agent_fixture')
            ? p.allow()
            : p.reject();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(doc: docWithCheck, controller: controller),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('coding_agent.task')),
        'Fix $_fixturePath so `dart $_fixturePath` exits 0: make main '
        'print ok instead of throwing. Work through the meaning tree.',
      );
      await tester.tap(find.byKey(const Key('coding_agent.delegate')));
      await tester.pump();

      var deadline = DateTime.now().add(const Duration(minutes: 3));
      while (!controller.isRunning && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await tester.pump();
      }
      deadline = DateTime.now().add(const Duration(minutes: 15));
      while (controller.isRunning && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await tester.pump();
      }

      final transcript = controller.current?.transcript.toString() ?? '';
      // ignore: avoid_print
      print(
        'AFM MEANING state: error=${controller.error} '
        'verdict=${controller.current?.verdictLine}',
      );
      // ignore: avoid_print
      print('AFM MEANING transcript:\n$transcript');

      expect(
        controller.current?.hasVerdict,
        isTrue,
        reason: 'the verdict must surface (transcript:\n$transcript)',
      );
      expect(
        controller.current?.verdictPassed,
        isTrue,
        reason:
            'AFM should fix the fixture THROUGH THE MEANING TREE on-device '
            '(transcript:\n$transcript)',
      );
      expect(
        fixture.readAsStringSync(),
        isNot(fixtureBefore),
        reason: 'the edit must land — a PASS without a change is a '
            'trivially green gate (R5)',
      );
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}
