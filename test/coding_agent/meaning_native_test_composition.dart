// Component evidence uses an explicitly admitted real SDK. Ordinary product
// acceptance omits this composition and requires its packaged runtime.
import 'dart:convert';
import 'dart:io';

import 'package:lastanswer/coding_agent/meaning_greeting_binding.dart';

String get meaningComponentDart {
  final configured = Platform.environment['HARNESS_TEST_DART'];
  final file = File(configured ?? '/Users/antonio/fvm/default/bin/dart');
  if (!file.isAbsolute || !file.existsSync()) {
    throw StateError('Component test requires an existing absolute Dart SDK');
  }
  return file.resolveSymbolicLinksSync();
}

Future<ProcessResult> runMeaningComponentDart(
  String executable,
  List<String> arguments,
  String workingDirectory,
) {
  if (executable != 'dart') {
    throw StateError('Unexpected native component executable: $executable');
  }
  return Process.run(
    meaningComponentDart,
    arguments,
    workingDirectory: workingDirectory,
    environment: const {'PATH': '/usr/bin:/bin:/usr/sbin:/sbin'},
  );
}

final meaningNativeTestComposition = MeaningGreetingNativeComposition(
  processRunner: runMeaningComponentDart,
  observe: (Directory workspace) async {
    final result = await runMeaningComponentDart('dart', [
      'run',
      'tool/observe.dart',
    ], workspace.path);
    if (result.exitCode != 0) {
      throw StateError(
        'Real native observation failed: '
        '${result.exitCode}: ${result.stdout}${result.stderr}',
      );
    }
    return jsonDecode((result.stdout as String).trim());
  },
);
