import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_controller.dart';
import 'package:lastanswer/coding_agent/meaning_greeting_binding.dart';

import 'meaning_native_test_composition.dart';

void main() {
  test(
    'real installed action preview, exact consent, apply and rollback',
    () async {
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
      final preview = await controller.action('preview');
      expect(preview['ok'], true, reason: '$preview');
      expect(controller.proposalId, isNotNull);
      expect(source.readAsBytesSync(), before);
      var allow = false;
      final consent = <Map<String, Object?>>[];
      final sub = host.permissionRequests.listen((pending) {
        consent.add(
          jsonDecode(pending.request.details!) as Map<String, Object?>,
        );
        allow ? pending.allow() : pending.reject();
      });
      addTearDown(sub.cancel);
      final rejected = await controller.action('apply');
      expect(rejected['ok'], false, reason: '$rejected');
      expect(source.readAsBytesSync(), before);
      expect(consent.single['proposalId'], controller.proposalId);
      final rejectedId = controller.proposalId;
      expect((await controller.action('status'))['ok'], true);
      allow = true;
      expect((await controller.action('preview'))['ok'], true);
      expect(controller.proposalId, isNot(rejectedId));
      final applied = await controller.action('apply');
      expect(applied['ok'], true, reason: '$applied');
      expect(source.readAsStringSync(), contains(' — updated'));
      expect(controller.rollbackAvailable, true);
      expect(
        (await controller.action('preview'))['error'],
        'meaning_native_run_open',
      );
      final run = controller.runId;
      final rollback = await controller.action('rollback');
      expect(rollback['ok'], true, reason: '$rollback');
      expect(source.readAsBytesSync(), before);
      expect(controller.rollbackAvailable, false);
      expect((await controller.action('status'))['ok'], true);
      expect(controller.rollbackAvailable, false);
      expect((await controller.action('preview'))['ok'], true);
      expect((await controller.action('apply'))['ok'], true);
      expect(controller.runId, isNot(run));
      expect((await controller.action('rollback'))['ok'], true);
      expect(source.readAsBytesSync(), before);
      // Actual host-issued receipts and measured times, not synthetic UI data.
      // ignore: avoid_print
      print('MEANING_PRODUCT_NATIVE ${jsonEncode(controller.toJson())}');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
