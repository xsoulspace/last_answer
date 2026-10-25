import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';
import 'package:oka_core/project_operations.dart';

void main() {
  test(
    'the declared profile is exposed next to the binding, never over it',
    () async {
      final root = await Directory.systemTemp.createTemp('project_ops_');
      addTearDown(() => root.delete(recursive: true));
      final workspace = Directory('${root.path}/project')..createSync();
      final support = Directory('${root.path}/support')..createSync();
      File('${workspace.path}/main.dart').writeAsStringSync('void main() {}\n');
      File('${workspace.path}/package.json').writeAsStringSync('{}');
      const profile = ProjectOperationProfile(
        id: 'fixture',
        operations: <ProjectOperation>[
          ProjectOperation(
            id: 'check',
            kind: ProjectOperationKind.check,
            command: ProjectCommand(
              executable: '/bin/echo',
              arguments: <String>['declared-check'],
            ),
          ),
        ],
      );
      final tooling = ProductWorkspaceTooling(
        supportDirectory: () async => support,
        projectOperations: profile,
      );
      final binding = await tooling.prepare(workspace.path);
      expect(binding.projectOperations, same(profile));
      expect(binding.toJson()['projectOperations'], 'fixture');
      final outcome = await binding.runProjectOperation(
        ProjectOperationKind.check,
      );
      expect(outcome.ok, isTrue, reason: '${outcome.toJson()}');
      expect(outcome.stdout.trim(), 'declared-check');
      expect(outcome.workingDirectory, workspace.resolveSymbolicLinksSync());
      // The candidate verification contract is untouched: a project-scoped
      // command never stands in for a candidate check.
      final refused = await binding.verifyCandidate(workspace);
      expect(refused.ok, isFalse);
      expect(
        refused.evidence['error'],
        'coding_contained_verifier_unavailable',
      );
    },
    skip: Platform.isWindows ? 'POSIX fixtures only' : null,
  );

  test('without a profile the declared operations are absent', () async {
    final root = await Directory.systemTemp.createTemp('project_ops_');
    addTearDown(() => root.delete(recursive: true));
    final workspace = Directory('${root.path}/project')..createSync();
    final support = Directory('${root.path}/support')..createSync();
    File('${workspace.path}/main.dart').writeAsStringSync('void main() {}\n');
    final tooling = ProductWorkspaceTooling(
      supportDirectory: () async => support,
    );
    final binding = await tooling.prepare(workspace.path);
    expect(binding.projectOperations, isNull);
    expect(binding.toJson().containsKey('projectOperations'), isFalse);
    final outcome = await binding.runProjectOperation(
      ProjectOperationKind.check,
    );
    expect(outcome.ok, isFalse);
    expect(outcome.error, 'project_operations_profile_absent');
  });
}
