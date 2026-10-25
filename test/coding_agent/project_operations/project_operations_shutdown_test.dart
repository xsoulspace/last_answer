import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations_entry.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations_session.dart';
import 'package:oka_core/oka_core.dart';
import 'package:oka_core/project_operations.dart';

import 'project_operations_test_support.dart';

final class ControlledTarget implements ProjectBrowserTarget {
  final release = Completer<ProjectBrowserSessionOutcome>();
  int detachCalls = 0;
  bool throwDetach = false;
  bool recovered = false;
  @override
  Uri get url => Uri.parse('http://127.0.0.1:5173');
  @override
  ProjectSessionOwnership get ownership => ProjectSessionOwnership.owned;
  @override
  Future<ProjectBrowserSessionOutcome> attach({
    Uri? url,
    bool replace = false,
  }) async => ProjectBrowserSessionOutcome(
    ok: true,
    url: this.url,
    ownership: ownership,
  );
  @override
  Future<ProjectBrowserSessionOutcome> detach() async {
    detachCalls++;
    if (throwDetach) throw StateError('cleanup transport unavailable');
    if (recovered) {
      return ProjectBrowserSessionOutcome(
        ok: true,
        url: url,
        ownership: ownership,
      );
    }
    return release.future;
  }
}

void main() {
  late Directory root;
  late Directory workspace;
  late ProcessLeaseRegistry leases;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('project_shutdown_');
    workspace = Directory('${root.path}/project')..createSync();
    leases = ProcessLeaseRegistry(Directory('${root.path}/leases'));
    writeDeclaration(workspace, workingTreeDeclaration);
  });
  tearDown(() => root.delete(recursive: true));

  ProjectOperationsSession makeSession({
    ProjectBrowserTarget? target,
    ProjectProcessRunner? runner,
  }) => ProjectOperationsSession(
    workspace: workspace,
    leaseRegistry: leases,
    runner: runner,
    browserTargetFactory: target == null ? null : (_) => target,
  );

  test(
    'concurrent shutdowns share one detach and close only after success',
    () async {
      final target = ControlledTarget();
      final session = makeSession(target: target);
      await session.load();
      await session.serve();
      final first = session.shutdown();
      final second = session.shutdown();
      expect(identical(first, second), isTrue);
      expect(session.closing, isTrue);
      expect(session.closed, isFalse);
      expect(target.detachCalls, 1);
      target.release.complete(
        ProjectBrowserSessionOutcome(
          ok: true,
          url: target.url,
          ownership: target.ownership,
        ),
      );
      await Future.wait([first, second]);
      expect(session.closed, isTrue);
      expect(session.hasTarget, isFalse);
      await session.shutdown();
      expect(target.detachCalls, 1);
      session.dispose();
    },
  );

  test(
    'thrown target cleanup retains visible recovery state and can retry',
    () async {
      final target = ControlledTarget()..throwDetach = true;
      final session = makeSession(target: target);
      var notifications = 0;
      session.addListener(() => notifications++);
      await session.load();
      await session.serve();
      await expectLater(session.shutdown(), throwsStateError);
      expect(session.closed, isFalse);
      expect(session.closing, isFalse);
      expect(session.hasTarget, isTrue);
      expect(session.endpoint, target.url);
      expect(session.error, 'project_session_cleanup_failed');
      expect(notifications, greaterThan(2));
      target
        ..throwDetach = false
        ..recovered = true;
      await session.shutdown();
      expect(session.closed, isTrue);
      session.dispose();
    },
  );

  test(
    'unverified command keeps identity and cannot be overwritten or closed',
    () async {
      final runner = FakeProjectRunner(
        awaitCancellation: true,
        unverifiedCancellation: true,
      );
      Future<BoundedRunResult> identifiedRun(
        String executable,
        List<String> arguments, {
        required Duration timeout,
        String? workingDirectory,
        Map<String, String>? environment,
        ProcessRunCancellation? cancellation,
      }) async {
        final result = await runner.call(
          executable,
          arguments,
          timeout: timeout,
          workingDirectory: workingDirectory,
          environment: environment,
          cancellation: cancellation,
        );
        return BoundedRunResult(
          cause: result.cause,
          exitCode: result.exitCode,
          stdout: result.stdout,
          stderr: result.stderr,
          truncatedOutput: result.truncatedOutput,
          duration: result.duration,
          rootPid: result.rootPid,
          rootIdentityToken: 'fixture-process-identity',
          rootExitObserved: result.rootExitObserved,
          teardownVerified: result.teardownVerified,
          survivors: result.survivors,
          errorMessage: result.errorMessage,
        );
      }

      final session = makeSession(runner: identifiedRun);
      await session.load();
      final run = session.runCheck();
      await expectLater(session.shutdown(), throwsStateError);
      await run;
      final receipt = session.outcome;
      expect(receipt!.physicallySettled, isFalse);
      expect(receipt.rootIdentityToken, 'fixture-process-identity');
      expect(receipt.toJson()['rootIdentityToken'], 'fixture-process-identity');
      expect(session.closed, isFalse);
      expect(session.hasUnsettledCommand, isTrue);
      expect(session.errorDetail, contains('pid=999999'));
      await session.runCheck();
      await session.runBuild();
      await session.serve();
      expect(identical(session.outcome, receipt), isTrue);
      expect(runner.runs, hasLength(1));
      await expectLater(session.shutdown(), throwsStateError);
      expect(identical(session.outcome, receipt), isTrue);
      session.dispose();
      await Future<void>.delayed(Duration.zero);
    },
  );

  testWidgets(
    'ordinary dialog refuses close for an unverified command '
    'and keeps its receipt',
    (tester) async {
      final runner = FakeProjectRunner(
        awaitCancellation: true,
        unverifiedCancellation: true,
      );
      final session = makeSession(runner: runner.call);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ProjectOperationsDialog(session: session),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('project_operations.check')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('project_operations.close')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('project_operations.dialog')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('project_operations.cleanup_error')),
        findsOneWidget,
      );
      expect(session.closed, isFalse);
      expect(session.outcome!.pid, 999999);
      expect(session.outcome!.survivors, [999999]);
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const Key('project_operations.check')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const Key('project_operations.close')),
            )
            .onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
      session.dispose();
      await tester.pump();
    },
  );

  testWidgets(
    'ordinary dialog close stays open after failed cleanup then retries',
    (tester) async {
      final target = ControlledTarget();
      final session = makeSession(target: target);
      await session.load();
      await session.serve();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ProjectOperationsDialog(session: session),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('project_operations.close')));
      await tester.pump();
      expect(session.closed, isFalse);
      expect(find.text('Stopping owned work…'), findsOneWidget);
      target.release.complete(
        ProjectBrowserSessionOutcome(
          ok: false,
          url: target.url,
          ownership: target.ownership,
          error: 'teardown_unverified',
          detail: 'Retry through owner; lease retained',
          pid: 42,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('project_operations.dialog')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('project_operations.cleanup_error')),
        findsOneWidget,
      );
      expect(session.hasTarget, isTrue);
      expect(session.serveOutcome!.pid, 42);
      expect(session.endpoint, target.url);
      target.recovered = true;
      await tester.tap(find.byKey(const Key('project_operations.close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('project_operations.dialog')), findsNothing);
      expect(session.closed, isTrue);
      expect(target.detachCalls, 2);
      session.dispose();
    },
  );
}
