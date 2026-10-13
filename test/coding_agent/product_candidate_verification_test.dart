import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/product_candidate_verification.dart';
import 'package:lastanswer/coding_agent/product_dart_runtime.dart';

void main() {
  final bundle = Directory(
    'build/macos/Build/Products/Debug/last_answer.app/Contents/Resources/meaning_runtime',
  ).absolute;
  test(
    'bundled compiler produces contained evidence without running candidate',
    () async {
      final root = await Directory.systemTemp.createTemp('product_compile_');
      var mayClean = true;
      addTearDown(() async {
        if (mayClean) await root.delete(recursive: true);
      });
      final candidate = Directory('${root.path}/candidate')..createSync();
      final support = Directory('${root.path}/support')..createSync();
      final outside = File('${root.path}/candidate-must-not-run');
      File('${candidate.path}/main.dart').writeAsStringSync(
        "import 'dart:io';\nvoid main() => File('${outside.path}') "
        ".writeAsStringSync('escaped');\n",
      );
      final verifier = ProductDartCandidateVerifier(
        runtime: () async =>
            ProductDartRuntime(bundleRoot: bundle, supportDirectory: support),
      );
      mayClean = false;
      final result = await verifier.verifyCandidate(candidate);
      mayClean = result.physicallySettled;
      expect(result.ok, true, reason: '${result.evidence}');
      expect(result.physicallySettled, true);
      expect(result.evidence['grade'], 'compiler_only');
      expect(result.evidence['candidateExecuted'], false);
      expect(result.evidence['functionalBehaviorVerified'], false);
      expect(result.evidence['taskAcceptance'], false);
      expect(
        File(
          '${candidate.path}/.dart_tool/coding_verification/entry_0.dill',
        ).existsSync(),
        true,
      );
      expect(outside.existsSync(), false);
      File(
        '${candidate.path}/main.dart',
      ).writeAsStringSync('this is invalid Dart;');
      mayClean = false;
      final rejected = await verifier.verifyCandidate(candidate);
      mayClean = rejected.physicallySettled;
      expect(rejected.ok, false);
      expect(rejected.physicallySettled, true);
      expect(rejected.evidence['error'], 'coding_candidate_compile_failed');
      expect(outside.existsSync(), false);
    },
    skip:
        !Platform.isMacOS || !File('${bundle.path}/manifest.json').existsSync(),
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
