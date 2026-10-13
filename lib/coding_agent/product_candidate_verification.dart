import 'dart:io';

import 'package:lastanswer/coding_agent/product_dart_runtime.dart';
import 'package:xsoulspace_agentic_host/conventional_change.dart';
import 'package:xsoulspace_tooling_runtime/xsoulspace_tooling_runtime.dart';

/// App-owned compiler evidence for dependency-free Dart. Functional criteria
/// are an independent host recipe; this adapter never claims task acceptance.
final class ProductDartCandidateVerifier {
  ProductDartCandidateVerifier({
    Future<ProductDartRuntime> Function()? runtime,
    this.verifier = const MacOsCandidateVerifier(),
  }) : runtime = runtime ?? ProductDartRuntime.forApplication;

  static final instance = ProductDartCandidateVerifier();
  final Future<ProductDartRuntime> Function() runtime;
  final MacOsCandidateVerifier verifier;

  Future<ConventionalCheck> verifyCandidate(Directory candidate) async {
    if (!Platform.isMacOS) {
      return const ConventionalCheck(
        ok: false,
        evidence: {'error': 'coding_contained_compiler_platform_unavailable'},
      );
    }
    // The compiler is the bundled runtime, never PATH or flutter_tester.
    final ProductDartRuntime toolchain;
    final Map<String, Object?> identity;
    try {
      toolchain = await runtime();
      identity = await toolchain.inspect();
    } on Object catch (error) {
      return ConventionalCheck(
        ok: false,
        evidence: {
          'error': 'coding_bundled_compiler_unavailable',
          'detail': '$error',
          'candidateExecuted': false,
        },
      );
    }
    final entrypoints = [
      if (File('${candidate.path}/main.dart').existsSync()) 'main.dart',
      if (Directory('${candidate.path}/bin').existsSync())
        for (final file in Directory('${candidate.path}/bin').listSync())
          if (file is File && file.path.endsWith('.dart'))
            file.path.substring(candidate.path.length + 1),
    ]..sort();
    if (entrypoints.isEmpty) {
      return const ConventionalCheck(
        ok: false,
        evidence: {
          'error': 'coding_supported_dart_entrypoint_required',
          'grade': 'compiler_only',
          'candidateExecuted': false,
        },
      );
    }
    if (entrypoints.length > 4) {
      return const ConventionalCheck(
        ok: false,
        evidence: {
          'error': 'coding_compiler_entrypoint_scope_required',
          'grade': 'compiler_only',
          'candidateExecuted': false,
        },
      );
    }
    final sdk = '${toolchain.bundleRoot.path}/dart-sdk';
    final output = Directory('${candidate.path}/.dart_tool/coding_verification')
      ..createSync(recursive: true);
    final checks = <Map<String, Object?>>[];
    for (var i = 0; i < entrypoints.length; i++) {
      final check = await verifier.verifyCandidate(
        executable: '$sdk/bin/dartaotruntime',
        arguments: [
          '$sdk/bin/snapshots/gen_kernel_aot.dart.snapshot',
          '--platform',
          '$sdk/lib/_internal/vm_platform_strong.dill',
          entrypoints[i],
          '-o',
          '${output.path}/entry_$i.dill',
        ],
        candidateRoot: candidate.path,
        readOnlyRoots: [sdk],
        deadline: const Duration(seconds: 30),
      );
      checks.add({
        'entrypoint': entrypoints[i],
        'exitCode': check.process?.exitCode,
        'stdout': check.process?.stdout,
        'stderr': check.process?.stderr,
        'refusal': check.refusal,
        'physicallySettled': check.physicallySettled,
        'retainedScratchRoot': check.retainedScratchRoot,
      });
      if (!check.ok) {
        return ConventionalCheck(
          ok: false,
          physicallySettled: check.physicallySettled,
          evidence: {
            'error': check.refusal ?? 'coding_candidate_compile_failed',
            'grade': 'compiler_only',
            'runtime': identity,
            'checks': checks,
            'candidateExecuted': false,
            'taskAcceptance': false,
          },
        );
      }
    }
    return ConventionalCheck(
      ok: true,
      physicallySettled: checks.every(
        (check) => check['physicallySettled'] == true,
      ),
      evidence: {
        'grade': 'compiler_only',
        'runtime': identity,
        'checks': checks,
        'candidateExecuted': false,
        'functionalBehaviorVerified': false,
        'taskAcceptance': false,
      },
    );
  }
}
