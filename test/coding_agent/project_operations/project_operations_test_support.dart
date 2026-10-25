import 'dart:io';

import 'package:lastanswer/coding_agent/project_operations/project_operations_session.dart';
import 'package:oka_core/oka_core.dart'
    show
        BoundedRunCause,
        BoundedRunResult,
        ProcessRunCancellation;
import 'package:oka_core/project_operations.dart';

/// A plain static web project: a served target and nothing else.
const String plainWebDeclaration = '''
{
  "id": "plain_web",
  "operations": [
    {
      "id": "serve",
      "kind": "serve",
      "command": {
        "executable": "python3",
        "arguments": ["-m", "http.server", "8080", "--directory", "."],
        "workingDirectory": {"kind": "project"},
        "timeoutMs": 1800000
      },
      "endpoint": {"host": "127.0.0.1", "port": 8080, "path": "/"},
      "readiness": {"kind": "tcp", "host": "127.0.0.1", "port": 8080}
    }
  ]
}
''';

/// A project that publishes a working tree check and a served target.
const String workingTreeDeclaration = '''
{
  "id": "declared_project",
  "operations": [
    {
      "id": "check",
      "kind": "check",
      "command": {
        "executable": "npm",
        "arguments": ["run", "build"],
        "environment": {"SECRET": "s3cr3t-value"}
      }
    },
    {
      "id": "serve",
      "kind": "serve",
      "command": {
        "executable": "npm",
        "arguments": ["run", "dev"]
      },
      "endpoint": {"host": "127.0.0.1", "port": 5173}
    }
  ]
}
''';

/// Writes a declaration into [workspace].
void writeDeclaration(Directory workspace, String declaration) {
  File(
    '${workspace.path}/${ProjectOperationProfileCodec.declarationPath}',
  )
    ..createSync(recursive: true)
    ..writeAsStringSync(declaration);
}

/// A project that publishes a long-running working tree check.
const String longRunningDeclaration = '''
{
  "id": "long_running",
  "operations": [
    {
      "id": "check",
      "kind": "check",
      "command": {
        "executable": "sh",
        "arguments": ["-c", "exec sleep 30"],
        "timeoutMs": 60000
      }
    }
  ]
}
''';

/// One recorded bounded run.
class RecordedRun {
  const RecordedRun({
    required this.executable,
    required this.arguments,
    required this.timeout,
    required this.workingDirectory,
    required this.environment,
  });

  final String executable;
  final List<String> arguments;
  final Duration timeout;
  final String? workingDirectory;
  final Map<String, String>? environment;
}

/// A bounded run that starts no process.
///
/// The fake honours a cancellation the way oka's bounded run does: it
/// reports the cancellation cause and the teardown verification instead of
/// a label. [unverifiedCancellation] simulates a stop that could not be
/// verified, which keeps the run unsettled and its receipt visible.
final class FakeProjectRunner {
  FakeProjectRunner({
    this.exitCode = 0,
    this.stdout = 'declared output',
    this.awaitCancellation = false,
    this.unverifiedCancellation = false,
  });

  final int exitCode;
  final String stdout;

  /// Whether the fake waits for a cancellation before it reports.
  ///
  /// A run that finishes before the cancellation arrives reports its normal
  /// outcome, exactly like a real command that finished in time.
  final bool awaitCancellation;

  /// Whether the simulated stop could not be verified.
  final bool unverifiedCancellation;
  final runs = <RecordedRun>[];

  Future<BoundedRunResult> call(
    String executable,
    List<String> arguments, {
    required Duration timeout,
    String? workingDirectory,
    Map<String, String>? environment,
    ProcessRunCancellation? cancellation,
  }) async {
    runs.add(
      RecordedRun(
        executable: executable,
        arguments: arguments,
        timeout: timeout,
        workingDirectory: workingDirectory,
        environment: environment,
      ),
    );
    if (cancellation?.requested ?? false) {
      return _cancelled();
    }
    if (awaitCancellation) {
      await cancellation!.whenRequested;
      return _cancelled();
    }
    return BoundedRunResult(
      cause: BoundedRunCause.exited,
      exitCode: exitCode,
      stdout: stdout,
      stderr: exitCode == 0 ? '' : 'declared failure',
      truncatedOutput: false,
      duration: const Duration(milliseconds: 5),
    );
  }

  BoundedRunResult _cancelled() => BoundedRunResult(
    cause: BoundedRunCause.cancelled,
    exitCode: -1,
    stdout: stdout,
    stderr: '',
    truncatedOutput: false,
    duration: const Duration(milliseconds: 5),
    rootPid: unverifiedCancellation ? 999999 : null,
    rootExitObserved: !unverifiedCancellation,
    teardownVerified: !unverifiedCancellation,
    survivors: unverifiedCancellation ? const <int>[999999] : const [],
    errorMessage: unverifiedCancellation
        ? 'simulated unverified teardown; survivors unknown'
        : null,
  );
}

/// A served target that starts no process.
final class FakeBrowserTarget implements ProjectBrowserTarget {
  FakeBrowserTarget({
    this.attachedUrl,
    this.ownership = ProjectSessionOwnership.owned,
    this.attachOutcome,
    this.detachOutcome,
  });

  Uri? attachedUrl;
  @override
  ProjectSessionOwnership ownership;
  ProjectBrowserSessionOutcome? attachOutcome;
  ProjectBrowserSessionOutcome? detachOutcome;
  int attachCalls = 0;
  int detachCalls = 0;

  @override
  Uri? get url => attachedUrl;

  @override
  Future<ProjectBrowserSessionOutcome> attach({
    Uri? url,
    bool replace = false,
  }) async {
    attachCalls++;
    return attachOutcome ??
        ProjectBrowserSessionOutcome(
          ok: true,
          url: attachedUrl,
          ownership: ownership,
        );
  }

  @override
  Future<ProjectBrowserSessionOutcome> detach() async {
    detachCalls++;
    return detachOutcome ??
        ProjectBrowserSessionOutcome(
          ok: true,
          url: attachedUrl,
          ownership: ownership,
          detail: ownership == ProjectSessionOwnership.borrowed
              ? 'borrowed target left untouched'
              : null,
        );
  }
}
