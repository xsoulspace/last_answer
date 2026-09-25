// ADR 0003 Phase 1 — the self-profiling gate: the app's agent-doc surface
// delegates a REAL task against THIS codebase (last_answer itself), graded
// by an oracle that FAILS until the agent acts (never trivially green —
// R5: analyze-only on a clean tree proves nothing).
//
// The fixture: `tool/agent_fixture/main.dart` throws until an agent fixes
// it; the doc's check override is `dart run tool/agent_fixture/main.dart`.
// The test RESTORES the fixture afterwards (`git checkout -- ` that one
// file) so the gate stays honest on every run. The task MUTATES the repo —
// gated behind an explicit env flag:
//
//   LASTANSWER_REPO=$PWD LASTANSWER_SELF_PROFILE=1 \
//     XS_FM_BRIDGE_PATH=<hook-built dylib> \
//     flutter test integration_test/coding_agent_self_profile_test.dart \
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
    'self-profile: agent doc bound to THIS repo, AFM task, honest oracle',
    (final tester) async {
      final env = Platform.environment;
      if (env['LASTANSWER_SELF_PROFILE'] != '1') {
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
      final repo = env['LASTANSWER_REPO'];
      if (repo == null || !Directory('$repo/lib/coding_agent').existsSync()) {
        // ignore: avoid_print
        print(
          'SELF_PROFILE_SKIPPED: repo root not found '
          '(pass LASTANSWER_REPO=<abs path>)',
        );
        return;
      }
      // ignore: avoid_print
      print('SELF PROFILE workspace: $repo');

      // Wipe the per-workspace world store: sessions CONTINUE per
      // workspace (R7c), and a stale goal from a previous run leaks old
      // context into this run (measured: the restored world made the model
      // replay its previous moves). The store is derived cache — it is
      // rebuilt on the next session; the gate needs a clean world.
      final store = Directory('$repo/.dart_tool/harnessd_store');
      if (store.existsSync()) store.deleteSync(recursive: true);

      final fixture = File('$repo/$_fixturePath');
      final fixtureBefore = fixture.readAsStringSync();
      // The gate must never be trivially green: the fixture throws until
      // the agent acts. Restore it afterwards, whatever the outcome.
      addTearDown(() {
        final result = Process.runSync('git', [
          'checkout',
          '--',
          _fixturePath,
        ], workingDirectory: repo);
        if (result.exitCode != 0) {
          // ignore: avoid_print
          print('SELF PROFILE WARN: fixture restore failed: ${result.stderr}');
        }
      });

      final doc = ProjectModel.emptyAgent() as ProjectModelDoc;
      // The doc's check override (the product's `--check`): targeted at the
      // fixture, NOT the repo convention (`flutter test` — minutes). Plain
      // `dart <file>` (no `run`): `dart run` inside the app process hits
      // the build-hook churn every grade ("File modified during build") —
      // the recorded dogfood finding; it derailed three gate runs.
      final docWithCheck = doc.copyWith(
        agent: (doc.agent ?? const AgentDocModel()).copyWith(
          workspaces: [repo],
          checkCommand: ['dart', _fixturePath],
        ),
      );
      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          checkCommand: docWithCheck.agent!.checkCommand,
        ),
      );
      addTearDown(controller.dispose);
      // The scripted user-actor allows ONLY fixture-path writes. A blanket
      // allow once let the wandering model overwrite THIS gate file
      // (measured); deny-by-default stays the rule for everything else.
      controller.host.permissionRequests.listen((final p) {
        p.request.title.contains('tool/agent_fixture') ? p.allow() : p.reject();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(doc: docWithCheck, controller: controller),
          ),
        ),
      );

      // The doc is PRE-BOUND (workspaces: [repo]) — the binding is doc
      // data, so SETUP stays collapsed and the workspace field is
      // pre-filled. The human only writes the task sentence; SETUP is one
      // toggle away when they want to change the binding.
      await tester.enterText(
        find.byKey(const Key('coding_agent.task')),
        'Fix $_fixturePath so `dart run $_fixturePath` exits 0: make main '
        'print ok instead of throwing. Read the file first, then edit it.',
      );
      await tester.tap(find.byKey(const Key('coding_agent.delegate')));
      await tester.pump();

      // Wait for the turn to START (createSession completes slightly after
      // the tap) and then for it to END.
      var deadline = DateTime.now().add(const Duration(minutes: 2));
      while (!controller.isRunning && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await tester.pump();
      }
      deadline = DateTime.now().add(const Duration(minutes: 12));
      while (controller.isRunning && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await tester.pump();
      }

      // ignore: avoid_print
      print(
        'SELF PROFILE state: error=${controller.error} '
        'current=${controller.current?.id} '
        'sessions=${controller.sessions.length}',
      );
      final transcript = controller.current?.transcript.toString() ?? '';
      // ignore: avoid_print
      print('SELF PROFILE transcript:\n$transcript');
      // ignore: avoid_print
      print('SELF PROFILE verdict: ${controller.current?.verdictLine}');

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
        fixture.readAsStringSync(),
        isNot(fixtureBefore),
        reason:
            'the write must land — a PASS without a change is a '
            'trivially green gate (R5)',
      );
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
