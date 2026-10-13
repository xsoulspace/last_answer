import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_controller.dart';
import 'package:lastanswer/coding_agent/meaning_greeting_binding.dart';

import '../../../test/coding_agent/meaning_native_test_composition.dart';

void main() {
  test(
    'diagnostic only: trace first legacy preview; not acceptance',
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
            nativeComposition: MeaningGreetingNativeComposition(
              processRunner: (executable, args, cwd) async {
                print('DIAGNOSTIC process start: $executable $args');
                final watch = Stopwatch()..start();
                final result = await runMeaningComponentDart(executable, args, cwd);
                print('DIAGNOSTIC process terminal: $args ${result.exitCode} ${watch.elapsedMilliseconds}ms');
                return result;
              },
              observe: meaningNativeTestComposition.observe,
            ),
          ),
        ),
      );
      addTearDown(host.stop);
      await host.start();
      final session = await host.newSession(workspace.path);
      final controller = MeaningExperimentController(
        invoke: (action, args) async {
          print('DIAGNOSTIC action start: $action');
          final result = await host.meaningAction(session, action, args);
          print('DIAGNOSTIC action terminal: $action ${result['ok']} ${result['error']}');
          return result;
        },
      );
      addTearDown(controller.dispose);
      final preview = await controller.action('preview');
      expect(preview['ok'], true, reason: '$preview');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
