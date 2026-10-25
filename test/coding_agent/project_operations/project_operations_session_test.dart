import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations_session.dart';
import 'package:oka_core/oka_core.dart';
import 'package:oka_core/project_operations.dart';
import 'project_operations_test_support.dart';

void main() {
  late Directory root;
  late Directory workspace;
  late ProcessLeaseRegistry leases;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('project_ops_session_');
    workspace = Directory('${root.path}/project')..createSync();
    leases = ProcessLeaseRegistry(Directory('${root.path}/leases'));
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  ProjectOperationsSession sessionWith({
    ProjectProcessRunner? runner,
    ProjectBrowserTarget? target,
  }) => ProjectOperationsSession(
    workspace: workspace,
    leaseRegistry: leases,
    runner: runner,
    browserTargetFactory: target == null ? null : (_) => target,
  );

  test('a project without a declaration declares nothing', () async {
    final session = sessionWith();
    await session.load();
    expect(session.loadState, ProjectOperationsLoadState.absent);
    expect(session.profile, isNull);
    expect(session.supports(ProjectOperationKind.check), isFalse);
    expect(session.declarationError, isNull);
  });

  test('a refused declaration stays refused and visible', () async {
    writeDeclaration(workspace, '{"id":"broken","operations":[]}');
    final session = sessionWith();
    await session.load();
    expect(session.loadState, ProjectOperationsLoadState.invalid);
    expect(
      session.declarationError,
      'project_operation_profile_no_operations',
    );
    expect(session.profile, isNull);
  });

  test('a declared profile is read without running anything', () async {
    writeDeclaration(workspace, workingTreeDeclaration);
    final runner = FakeProjectRunner();
    final session = sessionWith(runner: runner.call);
    await session.load();
    expect(session.loadState, ProjectOperationsLoadState.loaded);
    expect(session.profile!.id, 'declared_project');
    expect(session.supports(ProjectOperationKind.check), isTrue);
    expect(session.supports(ProjectOperationKind.build), isFalse);
    // Reading a declaration starts no process.
    expect(runner.runs, isEmpty);
  });

  test('the working tree check runs the project command on the owner tree',
      () async {
    writeDeclaration(workspace, workingTreeDeclaration);
    final runner = FakeProjectRunner();
    final session = sessionWith(runner: runner.call);
    await session.load();
    await session.runCheck();
    expect(session.runState, ProjectOperationsRunState.completed);
    expect(session.outcome!.ok, isTrue);
    expect(runner.runs, hasLength(1));
    expect(runner.runs.single.executable, 'npm');
    expect(runner.runs.single.arguments, <String>['run', 'build']);
    expect(
      runner.runs.single.workingDirectory,
      workspace.resolveSymbolicLinksSync(),
    );
    expect(session.logs, contains('declared output'));
  });

  test('a candidate operation is refused honestly in the working tree view',
      () async {
    writeDeclaration(
      workspace,
      '{"id":"candidate_only","operations":[{"id":"check","kind":"check",'
      '"command":{"executable":"npm",'
      '"workingDirectory":{"kind":"candidate"}}}]}',
    );
    final runner = FakeProjectRunner();
    final session = sessionWith(runner: runner.call);
    await session.load();
    await session.runCheck();
    expect(session.runState, ProjectOperationsRunState.failed);
    expect(session.outcome!.error, 'project_operation_directory_unavailable');
    expect(session.outcome!.detail, contains('candidate_required'));
    // The command never ran: a candidate operation has no candidate here.
    expect(runner.runs, isEmpty);
  });

  test('the served target keeps one session and is never spawned twice',
      () async {
    writeDeclaration(workspace, plainWebDeclaration);
    final target = FakeBrowserTarget(
      attachedUrl: Uri.parse('http://127.0.0.1:8080/'),
    );
    final session = sessionWith(target: target);
    await session.load();
    await session.serve();
    expect(session.runState, ProjectOperationsRunState.completed);
    expect(session.endpoint, Uri.parse('http://127.0.0.1:8080/'));
    expect(session.ownership, ProjectSessionOwnership.owned);
    expect(target.attachCalls, 1);
    await session.serve();
    expect(target.attachCalls, 2);
  });

  test('an owned target is stopped and its endpoint is released', () async {
    writeDeclaration(workspace, plainWebDeclaration);
    final target = FakeBrowserTarget(
      attachedUrl: Uri.parse('http://127.0.0.1:8080/'),
    );
    final session = sessionWith(target: target);
    await session.load();
    await session.serve();
    await session.stop();
    expect(target.detachCalls, 1);
    expect(session.endpoint, isNull);
  });

  test('a borrowed target is left running and keeps its URL', () async {
    writeDeclaration(workspace, plainWebDeclaration);
    final target = FakeBrowserTarget(
      attachedUrl: Uri.parse('http://127.0.0.1:8080/'),
      ownership: ProjectSessionOwnership.borrowed,
    );
    final session = sessionWith(target: target);
    await session.load();
    await session.serve();
    await session.stop();
    expect(target.detachCalls, 1);
    expect(session.endpoint, Uri.parse('http://127.0.0.1:8080/'));
    expect(session.ownership, ProjectSessionOwnership.borrowed);
    expect(session.serveOutcome!.detail, contains('borrowed'));
  });

  test('a cancel stops the real command, it does not only relabel it',
      () async {
    writeDeclaration(workspace, longRunningDeclaration);
    final session = sessionWith();
    await session.load();
    final watch = Stopwatch()..start();
    final run = session.runCheck();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    session.cancel();
    await run.timeout(const Duration(seconds: 30));
    watch.stop();
    expect(session.runState, ProjectOperationsRunState.cancelled);
    expect(session.outcome!.error, 'project_operation_cancelled');
    expect(session.outcome!.physicallySettled, isTrue);
    expect(session.outcome!.survivors, isEmpty);
    expect(
      watch.elapsed,
      lessThan(const Duration(seconds: 20)),
      reason: 'the cancel must not wait for the 60s budget',
    );
    final pid = session.outcome!.pid!;
    expect(
      await const HostProcessLiveness().isAlive(pid),
      isFalse,
      reason: 'the command must be physically stopped, not abandoned',
    );
  },
      skip: Platform.isWindows ? 'POSIX fixtures only' : null,
      timeout: const Timeout(Duration(minutes: 2)));

  test('an unverified cancellation is a failure that keeps its receipt',
      () async {
    writeDeclaration(workspace, workingTreeDeclaration);
    final session = sessionWith(
      runner: FakeProjectRunner(
        awaitCancellation: true,
        unverifiedCancellation: true,
      ).call,
    );
    await session.load();
    final run = session.runCheck();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    session.cancel();
    await run.timeout(const Duration(seconds: 30));
    expect(session.runState, ProjectOperationsRunState.failed);
    expect(session.outcome!.error, 'project_operation_cancelled');
    expect(session.outcome!.physicallySettled, isFalse);
    expect(session.outcome!.survivors, isNotEmpty);
    // The receipt stays visible: a swallowed failure must not look clean.
    expect(session.logs, contains('survivors'));
    expect(session.errorDetail, isNotNull);
  });

  test('shutdown cancels the command and joins it', () async {
    writeDeclaration(workspace, longRunningDeclaration);
    final session = sessionWith();
    await session.load();
    final run = session.runCheck();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final watch = Stopwatch()..start();
    await session.shutdown();
    watch.stop();
    await run.timeout(const Duration(seconds: 30));
    expect(
      watch.elapsed,
      lessThan(const Duration(seconds: 20)),
      reason: 'the shutdown must not wait for the 60s budget',
    );
    expect(session.outcome!.error, 'project_operation_cancelled');
    expect(session.outcome!.physicallySettled, isTrue);
    final pid = session.outcome!.pid!;
    expect(await const HostProcessLiveness().isAlive(pid), isFalse);
  },
      skip: Platform.isWindows ? 'POSIX fixtures only' : null,
      timeout: const Timeout(Duration(minutes: 2)));

  test('the dispose joins the cleanup of the served target', () async {
    writeDeclaration(workspace, plainWebDeclaration);
    final target = FakeBrowserTarget(
      attachedUrl: Uri.parse('http://127.0.0.1:8080/'),
    );
    final session = sessionWith(target: target);
    await session.load();
    await session.serve();
    session.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(target.detachCalls, 1);
  });

  test('the session never reports a working tree check as acceptance',
      () async {
    writeDeclaration(workspace, workingTreeDeclaration);
    final session = sessionWith(runner: FakeProjectRunner().call);
    await session.load();
    await session.runCheck();
    // The outcome is the project's own report about its working tree: it
    // carries no acceptance claim of any kind.
    expect(session.outcome!.toJson().containsKey('accepted'), isFalse);
    expect(session.outcome!.toJson().containsKey('candidate'), isFalse);
  });
}
