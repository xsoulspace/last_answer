import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations_session.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations_widget.dart';
import 'package:oka_core/oka_core.dart' show ProcessLeaseRegistry;

import 'project_operations_test_support.dart';

void main() {
  late Directory root;
  late Directory workspace;
  late ProcessLeaseRegistry leases;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('project_ops_widget_');
    workspace = Directory('${root.path}/project')..createSync();
    leases = ProcessLeaseRegistry(Directory('${root.path}/leases'));
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<void> show(
    WidgetTester tester,
    ProjectOperationsSession session, {
    Future<void> Function(BuildContext context, Uri url)? openBrowser,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectOperationsWidget(
            session: session,
            openBrowser: openBrowser,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a project without a declaration says so', (tester) async {
    final session = ProjectOperationsSession(
      workspace: workspace,
      leaseRegistry: leases,
    );
    await show(tester, session);
    expect(find.byKey(const Key('project_operations.absent')), findsOneWidget);
    expect(find.byKey(const Key('project_operations.error')), findsNothing);
  });

  testWidgets('a refused declaration is visible', (tester) async {
    writeDeclaration(workspace, '{"id":"broken","operations":[]}');
    final session = ProjectOperationsSession(
      workspace: workspace,
      leaseRegistry: leases,
    );
    await show(tester, session);
    expect(find.byKey(const Key('project_operations.error')), findsOneWidget);
    expect(
      find.textContaining('project_operation_profile_no_operations'),
      findsOneWidget,
    );
  });

  testWidgets('the check is a working tree check, never a candidate check',
      (tester) async {
    writeDeclaration(workspace, workingTreeDeclaration);
    final session = ProjectOperationsSession(
      workspace: workspace,
      leaseRegistry: leases,
      runner: FakeProjectRunner().call,
    );
    await show(tester, session);
    expect(find.text('Working tree check'), findsOneWidget);
    expect(find.textContaining('Candidate'), findsNothing);
    expect(
      find.byKey(const Key('project_operations.working_tree_note')),
      findsOneWidget,
    );
  });

  testWidgets('a click runs the declared command and shows its outcome',
      (tester) async {
    writeDeclaration(workspace, workingTreeDeclaration);
    final runner = FakeProjectRunner();
    final session = ProjectOperationsSession(
      workspace: workspace,
      leaseRegistry: leases,
      runner: runner.call,
    );
    await show(tester, session);
    await tester.tap(find.byKey(const Key('project_operations.check')));
    await tester.pumpAndSettle();
    expect(runner.runs, hasLength(1));
    expect(runner.runs.single.executable, 'npm');
    final status = tester.widget<Text>(
      find.byKey(const Key('project_operations.status')),
    );
    expect(status.data, contains('ok'));
  });

  testWidgets('serve opens the browser at the served URL', (tester) async {
    writeDeclaration(workspace, plainWebDeclaration);
    final target = FakeBrowserTarget(
      attachedUrl: Uri.parse('http://127.0.0.1:8080/'),
    );
    Uri? opened;
    final session = ProjectOperationsSession(
      workspace: workspace,
      leaseRegistry: leases,
      browserTargetFactory: (_) => target,
    );
    await show(
      tester,
      session,
      openBrowser: (context, url) async => opened = url,
    );
    await tester.tap(find.byKey(const Key('project_operations.serve')));
    await tester.pumpAndSettle();
    expect(opened, Uri.parse('http://127.0.0.1:8080/'));
    expect(
      find.byKey(const Key('project_operations.endpoint')),
      findsOneWidget,
    );
  });

  testWidgets('the panel never shows an environment value', (tester) async {
    writeDeclaration(workspace, workingTreeDeclaration);
    final session = ProjectOperationsSession(
      workspace: workspace,
      leaseRegistry: leases,
      runner: FakeProjectRunner().call,
    );
    await show(tester, session);
    expect(find.textContaining('s3cr3t-value'), findsNothing);
  });
}
