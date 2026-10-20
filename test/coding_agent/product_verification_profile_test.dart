import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';

void main() {
  test('existing profile preserves dependency-free verifier composition', () {
    final tooling = ProductWorkspaceTooling.forProfile('existing');
    expect(tooling.useProductCompiler, false);
    expect(tooling.verifyCandidate, isNotNull);
    expect(tooling.verificationScratchPaths, ['.dart_tool']);
    expect(tooling.standingAuthority, isNull);
    expect(tooling.verificationDescription, contains('dependency-free'));
  });

  test('package_snapshot is the explicit retained compiler composition', () {
    final tooling = ProductWorkspaceTooling.forProfile('package_snapshot');
    expect(tooling.useProductCompiler, true);
    expect(tooling.verifyCandidate, isNull);
    expect(tooling.verificationScratchPaths, ['.dart_tool']);
    expect(tooling.standingAuthority, isNull);
    expect(
      tooling.verificationDescription,
      contains('Opt-in captured package'),
    );
  });

  test('unknown profile refuses by name without fallback', () {
    expect(
      () => ProductWorkspaceTooling.forProfile('unknown'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          'unknown_verification_profile',
        ),
      ),
    );
  });

  test('ordinary product singleton follows the explicit build profile', () {
    // Exercise the actual public build selection, including the default.
    // ignore: do_not_use_environment
    const selected = String.fromEnvironment(
      'LAST_ANSWER_CODING_VERIFICATION_PROFILE',
      defaultValue: 'existing',
    );
    expect(
      ProductWorkspaceTooling.instance.useProductCompiler,
      selected == 'package_snapshot',
    );
    expect(ProductWorkspaceTooling.instance.standingAuthority, isNull);
  });
}
