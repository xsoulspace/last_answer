import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_controller.dart';
import 'package:lastanswer/coding_agent/meaning_greeting_binding.dart';

import 'meaning_native_test_composition.dart';

void main() {
  test('fresh host exposes recovery journal '
      'without restoring or replaying authority', () async {
    final temporary = await Directory.systemTemp.createTemp('la_meaning_');
    addTearDown(() => temporary.delete(recursive: true));
    final workspace = await Directory('${temporary.path}/fixture').create();
    final fixture = Directory(
      '../../ecsai_harness/pkgs/xsoulspace_agentic_experiments/'
      'test/fixtures/meaning_greeting',
    );
    final manifest =
        jsonDecode(File('${fixture.path}/manifest.json').readAsStringSync())
            as Map;
    for (final raw in manifest['assets'] as List) {
      final asset = raw as Map;
      final copied = File('${workspace.path}/${asset['workspace_path']}');
      copied.parent.createSync(recursive: true);
      copied.writeAsBytesSync(
        File('${fixture.path}/${asset['fixture_path']}').readAsBytesSync(),
      );
    }
    final pub = await runMeaningComponentDart('dart', [
      'pub',
      'get',
      '--offline',
    ], workspace.path);
    expect(pub.exitCode, 0, reason: '${pub.stderr}');
    final source = File('${workspace.path}/lib/greeting.dart');
    final before = source.readAsBytesSync();
    final host = HarnessHost(
      config: HarnessHostConfig(
        meaningProfile: true,
        checkCommand: const ['dart', 'test'],
        extraToolsWithContext: meaningGreetingTools(
          workspace.path,
          nativeComposition: meaningNativeTestComposition,
        ),
      ),
    );
    addTearDown(host.stop);
    await host.start();
    final session = await host.newSession(workspace.path);
    final controller = MeaningExperimentController(
      invoke: (action, args) => host.meaningAction(session, action, args),
    );
    addTearDown(controller.dispose);
    expect((await controller.action('preview'))['ok'], true);
    final consent = host.permissionRequests.listen(
      (pending) => pending.allow(),
    );
    expect((await controller.action('apply'))['ok'], true);
    final oldProposal = controller.proposalId!;
    final oldRun = controller.runId!;
    final appliedBytes = source.readAsBytesSync();
    expect(appliedBytes, isNot(before));
    await consent.cancel();
    await host.stop();
    final fresh = HarnessHost(
      config: HarnessHostConfig(
        meaningProfile: true,
        checkCommand: const ['dart', 'test'],
        extraToolsWithContext: meaningGreetingTools(
          workspace.path,
          nativeComposition: meaningNativeTestComposition,
        ),
      ),
    );
    addTearDown(fresh.stop);
    await fresh.start();
    final freshSession = await fresh.newSession(workspace.path);
    final restored =
        MeaningExperimentController(
            invoke: (action, args) =>
                fresh.meaningAction(freshSession, action, args),
          )
          ..proposalId = oldProposal
          ..runId = oldRun
          ..rollbackAvailable = true;
    addTearDown(restored.dispose);
    var freshConsent = 0;
    final freshSub = fresh.permissionRequests.listen((pending) {
      freshConsent++;
      pending.reject();
    });
    addTearDown(freshSub.cancel);
    final status = await restored.action('status');
    expect(status['ok'], true, reason: '$status');
    expect(status['issued_previews'], isEmpty);
    expect(
      (status['native_runs']! as List).any((raw) {
        final run = raw as Map;
        return run['runId'] == oldRun &&
            run['known_in_session'] == false &&
            run['status'] == 'applied';
      }),
      true,
      reason: '$status',
    );
    expect(restored.proposalId, isNull);
    expect(restored.rollbackAvailable, false);
    expect(
      (await restored.action('apply'))['error'],
      'meaning_preview_required',
    );
    final staleApply = await fresh.meaningAction(freshSession, 'apply', {
      'proposalId': oldProposal,
    });
    expect(staleApply['ok'], false, reason: '$staleApply');
    final staleRollback = await fresh.meaningAction(freshSession, 'rollback', {
      'proposalId': oldProposal,
      'runId': oldRun,
    });
    expect(staleRollback['ok'], false, reason: '$staleRollback');
    expect(source.readAsBytesSync(), appliedBytes);
    expect(freshConsent, 0);
    final freshDisplay = MeaningExperimentController(
      invoke: (action, args) => fresh.meaningAction(freshSession, action, args),
    );
    addTearDown(freshDisplay.dispose);
    final freshPreview = await freshDisplay.action('preview');
    // A restored unresolved native run must block new issuance itself.
    expect(
      freshPreview['error'],
      'meaning_open_run_requires_recovery_or_finalize',
      reason: '$freshPreview',
    );
    expect(source.readAsBytesSync(), appliedBytes);
    final evidence = {
      'status': status,
      'stale_apply': staleApply,
      'stale_rollback': staleRollback,
      'fresh_preview': freshPreview,
      'fresh_permission_requests': freshConsent,
    };
    // ignore: avoid_print
    print('MEANING_PRODUCT_RESTART ${jsonEncode(evidence)}');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
