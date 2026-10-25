import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations.dart';
import 'package:oka_core/oka_core.dart' show ProcessLeaseRegistry;

/// The state of the project's declaration.
enum ProjectOperationsLoadState {
  /// Nothing has been read yet.
  idle,

  /// The project declared nothing.
  absent,

  /// The declaration was read.
  loaded,

  /// The declaration was refused; the refusal is visible, never repaired.
  invalid,
}

/// The state of the last declared operation run.
enum ProjectOperationsRunState {
  /// Nothing has run yet.
  idle,

  /// A declared operation is running.
  running,

  /// The declared operation reported success.
  completed,

  /// The declared operation reported a failure.
  failed,

  /// The run was cancelled from the surface.
  cancelled,
}

/// The narrow handle the surface uses to own a served target.
///
/// The real implementation is oka's `ProjectBrowserSession`; this is a
/// *handle*, not a second executor. The ownership laws stay oka's: a target
/// this session spawned is owned and may be stopped, a target somebody else
/// serves is borrowed and is never signalled.
abstract interface class ProjectBrowserTarget {
  /// The URL a browser window navigates to, when the target is attached.
  Uri? get url;

  /// Who owns the process behind the target.
  ProjectSessionOwnership? get ownership;

  /// Attaches to the declared target.
  Future<ProjectBrowserSessionOutcome> attach({Uri? url, bool replace = false});

  /// Releases the target.
  Future<ProjectBrowserSessionOutcome> detach();
}

/// The handle over oka's own browser session.
final class OkaProjectBrowserTarget implements ProjectBrowserTarget {
  /// Wraps an oka browser session.
  OkaProjectBrowserTarget(this._session);

  final ProjectBrowserSession _session;

  @override
  Uri? get url => _session.url;

  @override
  ProjectSessionOwnership? get ownership => _session.ownership;

  @override
  Future<ProjectBrowserSessionOutcome> attach({
    Uri? url,
    bool replace = false,
  }) => _session.attach(url: url, replace: replace);

  @override
  Future<ProjectBrowserSessionOutcome> detach() => _session.detach();
}

/// The declared project operations of one workspace.
///
/// The session reads the project's own declaration
/// (`.oka/project_operations.json`) and runs the operations a person asks
/// for. It owns no executor of its own: a check or a build runs through
/// oka's `ProjectOperationController`, and a served target belongs to oka's
/// `ProjectBrowserSession`.
///
/// Two laws travel with it. A *working tree* check runs the project's own
/// command against the owner project root, so it is never evidence about a
/// candidate and never acceptance. A served target is stopped only when the
/// session owns the process behind it.
final class ProjectOperationsSession extends ChangeNotifier {
  /// Creates a session over [workspace].
  ///
  /// [leaseRegistry] belongs to the caller: the lease records must live in a
  /// directory the application owns, never inside somebody else's project
  /// tree. [runner] and [browserTargetFactory] are the seams the focused
  /// tests substitute; the production path uses oka's own runner and
  /// browser session.
  ProjectOperationsSession({
    required Directory workspace,
    required this.leaseRegistry,
    this.runner,
    this.browserTargetFactory,
  }) : workspace = _canonical(workspace);

  /// The owner project root.
  ///
  /// The root is canonical: a command runs in the same tree the rest of the
  /// product knows, not in a symlinked alias of it.
  final Directory workspace;

  /// The lease registry of the served processes.
  final ProcessLeaseRegistry leaseRegistry;

  /// The bounded run seam, when the caller substitutes one.
  final ProjectProcessRunner? runner;

  /// The browser target seam, when the caller substitutes one.
  final ProjectBrowserTarget Function(ProjectOperationProfile profile)?
  browserTargetFactory;

  ProjectOperationProfile? _profile;
  ProjectOperationsLoadState _loadState = ProjectOperationsLoadState.idle;
  String? _declarationError;
  String? _declarationDetail;
  ProjectOperationsRunState _runState = ProjectOperationsRunState.idle;
  ProjectOperationOutcome? _outcome;
  ProjectBrowserSessionOutcome? _serveOutcome;
  String? _error;
  String? _errorDetail;
  String _logs = '';
  Uri? _endpoint;
  ProjectSessionOwnership? _ownership;
  bool _busy = false;
  bool _cancelled = false;
  bool _disposed = false;
  bool _released = false;
  bool _closed = false;
  bool _targetCleanupUnverified = false;
  Future<void>? _shutdown;
  Future<ProjectBrowserSessionOutcome?>? _release;
  Future<ProjectOperationOutcome>? _activeRun;
  Future<ProjectBrowserSessionOutcome>? _activeAttach;
  ProjectOperationController? _controller;
  ProjectBrowserTarget? _browserTarget;

  /// The declared profile, when the project declared one.
  ProjectOperationProfile? get profile => _profile;

  /// The state of the declaration.
  ProjectOperationsLoadState get loadState => _loadState;

  /// The named reason of a refused declaration.
  String? get declarationError => _declarationError;

  /// The detail of a refused declaration.
  String? get declarationDetail => _declarationDetail;

  /// The state of the last run.
  ProjectOperationsRunState get runState => _runState;

  /// The outcome of the last check or build.
  ProjectOperationOutcome? get outcome => _outcome;

  /// The outcome of the last serve request.
  ProjectBrowserSessionOutcome? get serveOutcome => _serveOutcome;

  /// The named failure of the last run.
  String? get error => _error;

  /// The detail of the last failure.
  String? get errorDetail => _errorDetail;

  /// The bounded logs of the last run.
  String get logs => _logs;

  /// The URL a browser window navigates to.
  Uri? get endpoint => _endpoint;

  /// Who owns the process behind [endpoint].
  ProjectSessionOwnership? get ownership => _ownership;

  /// Whether the last failure kept the last known good target.
  bool get retainedLastKnownGood =>
      _serveOutcome?.retainedLastKnownGood ?? false;

  /// Whether an operation is running.
  bool get busy => _busy;

  /// Cleanup is joined before the ordinary surface may close.
  bool get closing => _shutdown != null;

  /// A successful shutdown is terminal; a failed cleanup remains retryable.
  bool get closed => _closed;

  /// An unresolved command receipt must not be replaced by another run.
  bool get hasUnsettledCommand => _outcome?.physicallySettled == false;

  bool get canStartOperation =>
      !_disposed &&
      !_closed &&
      !closing &&
      !_busy &&
      _release == null &&
      !_targetCleanupUnverified &&
      !hasUnsettledCommand;

  /// Whether the profile declares an operation of [kind].
  bool supports(ProjectOperationKind kind) => _profile?.supports(kind) ?? false;

  /// Whether a served target is attached.
  bool get hasTarget => _browserTarget != null;

  /// Reads the project's declaration.
  ///
  /// Reading is not running: no process starts, no endpoint is probed, and no
  /// command is guessed. A refused declaration stays refused and visible.
  Future<void> load() async {
    _declarationError = null;
    _declarationDetail = null;
    try {
      final profile = ProjectOperationProfileCodec.loadDeclaredProfile(
        workspace,
      );
      _profile = profile;
      _loadState = profile == null
          ? ProjectOperationsLoadState.absent
          : ProjectOperationsLoadState.loaded;
    } on ProjectOperationProfileFormatException catch (error) {
      _profile = null;
      _loadState = ProjectOperationsLoadState.invalid;
      _declarationError = error.reason;
      _declarationDetail = error.detail;
    }
    _notify();
  }

  /// Runs the declared *working tree* check.
  ///
  /// The command runs against the owner project root. The result is the
  /// project's own report about its working tree; it is not a candidate
  /// verification and never an acceptance.
  Future<void> runCheck() => _run(ProjectOperationKind.check);

  /// Runs the declared build.
  Future<void> runBuild() => _run(ProjectOperationKind.build);

  /// Starts the declared serve and keeps its target.
  ///
  /// The session keeps one target: an already attached target is returned
  /// instead of spawning a second server.
  Future<void> serve() async {
    final profile = _profile;
    if (profile == null || !canStartOperation) return;
    if (!profile.supports(ProjectOperationKind.serve)) {
      _runState = ProjectOperationsRunState.failed;
      _error = 'project_operation_unavailable';
      _errorDetail = 'the profile "${profile.id}" declares no serve operation';
      _notify();
      return;
    }
    _busy = true;
    _cancelled = false;
    _runState = ProjectOperationsRunState.running;
    _error = null;
    _errorDetail = null;
    _serveOutcome = null;
    _notify();
    if (_browserTarget == null) {
      _browserTarget = _createTarget(profile);
      _released = false;
    }
    final target = _browserTarget!;
    final attach = target.attach();
    _activeAttach = attach;
    final outcome = await attach;
    _activeAttach = null;
    _busy = false;
    _serveOutcome = outcome;
    _endpoint = outcome.url;
    _ownership = outcome.ownership;
    _error = outcome.error;
    _errorDetail = outcome.detail;
    if (outcome.stderr.isNotEmpty) _logs = _bounded(outcome.stderr);
    if (_cancelled) {
      // The attach could not be interrupted — the browser session owns the
      // spawn. It is joined, and the target it produced is released under
      // the session's ownership law.
      final released = await _releaseTarget();
      _runState = released?.ok == false
          ? ProjectOperationsRunState.failed
          : ProjectOperationsRunState.cancelled;
    } else {
      _runState = outcome.ok
          ? ProjectOperationsRunState.completed
          : ProjectOperationsRunState.failed;
    }
    _notify();
  }

  /// Stops the served target.
  ///
  /// Only a process the session owns is stopped. A borrowed target is left
  /// running and keeps its URL; the outcome says so. A cleanup that could
  /// not be verified keeps the target and its lease for recovery.
  Future<void> stop() async {
    if (closing || _closed) return;
    try {
      final released = await _releaseTarget();
      if (released?.ok == false) {
        _runState = ProjectOperationsRunState.failed;
      }
    } on Object catch (error) {
      _error = 'project_session_cleanup_failed';
      _errorDetail = '$error';
      _runState = ProjectOperationsRunState.failed;
    }
    _notify();
  }

  /// Cancels the running operation from the surface.
  ///
  /// The command is really stopped: the controller asks the bounded run for
  /// the same identity-gated tree stop the deadline performs, and the run
  /// reports whether that stop was verified. A served target cannot be
  /// interrupted mid-attach — the browser session owns the spawn — so the
  /// attach is joined and the target it produced is released.
  void cancel() {
    if (!_busy) return;
    _cancelled = true;
    _controller?.cancelActiveRun();
    _notify();
  }

  /// Joins the cleanup: the running command, the serve attachment and the
  /// owned target.
  ///
  /// The cancellation is requested first, so the command's own stop happens
  /// instead of waiting for its deadline. The caller awaits this when it must
  /// know that the cleanup happened; the widget's dispose calls it without
  /// awaiting.
  Future<void> shutdown() {
    if (_closed) return Future<void>.value();
    final pending = _shutdown;
    if (pending != null) return pending;
    final completion = Completer<void>();
    _shutdown = completion.future;
    _notify();
    unawaited(() async {
      try {
        await _shutdownOwnedWork();
        _closed = true;
        completion.complete();
      } on Object catch (error, stack) {
        _error = 'project_session_cleanup_failed';
        _errorDetail = '$error';
        _runState = ProjectOperationsRunState.failed;
        completion.completeError(error, stack);
      } finally {
        _shutdown = null;
        _notify();
      }
    }());
    return completion.future;
  }

  Future<void> _shutdownOwnedWork() async {
    _cancelled = true;
    _controller?.cancelActiveRun();
    final active = _activeRun;
    if (active != null) {
      try {
        await active;
      } on Object {
        // The run's own failure is reported on the surface; the cleanup
        // continues either way.
      }
    }
    final attach = _activeAttach;
    if (attach != null) {
      try {
        await attach;
      } on Object {
        // A refused attachment is reported by the session itself.
      }
    }
    final released = await _releaseTarget();
    if (released != null && !released.ok) {
      throw StateError(
        '${released.error ?? 'project_target_cleanup_unverified'}: '
        '${released.detail ?? 'Target retained; retry Close or Stop.'}',
      );
    }
    if (hasUnsettledCommand) {
      throw StateError(
        'project_command_cleanup_unverified: the command recovery receipt '
        'is retained; pid=${_outcome?.pid}, '
        'identity=${_outcome?.rootIdentityToken ?? 'unknown'}, '
        'survivors=${_outcome?.survivors.join(', ')}. '
        'Resolve through the process owner before closing.',
      );
    }
  }

  /// Releases the served target under the session's ownership law.
  ///
  /// An owned target is stopped; a borrowed target is left running and keeps
  /// its URL. A cleanup that could not be verified retains the target and its
  /// lease and keeps the failure visible.
  Future<ProjectBrowserSessionOutcome?> _releaseTarget() {
    final pending = _release;
    if (pending != null) return pending;
    final completion = Completer<ProjectBrowserSessionOutcome?>();
    _release = completion.future;
    unawaited(() async {
      try {
        completion.complete(await _detachTarget());
      } on Object catch (error, stack) {
        _targetCleanupUnverified = true;
        completion.completeError(error, stack);
      } finally {
        _release = null;
      }
    }());
    return completion.future;
  }

  Future<ProjectBrowserSessionOutcome?> _detachTarget() async {
    final target = _browserTarget;
    if (target == null) return null;
    if (_released) return _serveOutcome;
    final outcome = await target.detach();
    _targetCleanupUnverified = !outcome.ok;
    _serveOutcome = outcome;
    _ownership = outcome.ownership;
    _endpoint =
        !outcome.ok || outcome.ownership == ProjectSessionOwnership.borrowed
        ? outcome.url ?? target.url
        : null;
    if (outcome.stderr.isNotEmpty) _logs = _bounded(outcome.stderr);
    _error = outcome.error;
    _errorDetail = outcome.detail;
    if (outcome.ok) {
      _released = true;
      _browserTarget = null;
    }
    return outcome;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    // Disposal cannot report success on behalf of a failed cleanup. Ordinary
    // Close awaits shutdown before disposing; forced teardown retains receipts.
    unawaited(shutdown().catchError((Object _) {}));
    super.dispose();
  }

  Future<void> _run(ProjectOperationKind kind) async {
    final profile = _profile;
    if (profile == null || !canStartOperation) return;
    if (!profile.supports(kind)) {
      _runState = ProjectOperationsRunState.failed;
      _error = 'project_operation_unavailable';
      _errorDetail =
          'the profile "${profile.id}" declares no ${kind.name} operation';
      _notify();
      return;
    }
    _busy = true;
    _cancelled = false;
    _runState = ProjectOperationsRunState.running;
    _outcome = null;
    _error = null;
    _errorDetail = null;
    _logs = '';
    _notify();
    final controller = ProjectOperationController(
      profile: profile,
      workspace: workspace,
      runner: runner,
    );
    _controller = controller;
    final run = controller.run(kind);
    _activeRun = run;
    ProjectOperationOutcome outcome;
    try {
      outcome = await run;
    } on Object catch (error) {
      _activeRun = null;
      _controller = null;
      _busy = false;
      _runState = ProjectOperationsRunState.failed;
      _error = 'project_operation_failed';
      _errorDetail = '$error';
      _notify();
      return;
    }
    _activeRun = null;
    _controller = null;
    _busy = false;
    _outcome = outcome;
    _error = outcome.error;
    _errorDetail =
        outcome.detail ??
        (outcome.survivors.isEmpty
            ? null
            : 'known survivors: ${outcome.survivors.join(', ')}');
    final receipt = outcome.survivors.isEmpty
        ? ''
        : 'survivors: ${outcome.survivors.join(', ')}';
    _logs = _bounded(
      [
        outcome.stdout,
        outcome.stderr,
        receipt,
      ].where((part) => part.isNotEmpty).join('\n'),
    );
    final cancelled =
        _cancelled || outcome.error == 'project_operation_cancelled';
    _runState = cancelled
        ? outcome.physicallySettled
              ? ProjectOperationsRunState.cancelled
              : ProjectOperationsRunState.failed
        : outcome.ok
        ? ProjectOperationsRunState.completed
        : ProjectOperationsRunState.failed;
    _notify();
  }

  ProjectBrowserTarget _createTarget(ProjectOperationProfile profile) =>
      browserTargetFactory?.call(profile) ??
      OkaProjectBrowserTarget(
        ProjectBrowserSession(
          profile: profile,
          workspace: workspace,
          leaseRegistry: leaseRegistry,
        ),
      );

  static Directory _canonical(Directory directory) {
    try {
      return Directory(directory.resolveSymbolicLinksSync());
    } on FileSystemException {
      return directory;
    }
  }

  static String _bounded(String text) {
    const limit = 4000;
    if (text.length <= limit) return text;
    return '…${text.substring(text.length - limit)}';
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}
