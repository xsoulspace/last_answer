import 'dart:async';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter/foundation.dart';

import 'package:lastanswer/coding_agent/harness_host.dart';

/// One visible harness session: id, delegated workspace, the streamed
/// transcript, and the latest surfaced verdict.
final class HarnessSessionView {
  HarnessSessionView({required this.id, required this.cwd});

  final String id;
  final String cwd;
  final StringBuffer transcript = StringBuffer();
  String? verdictLine;
  bool running = false;

  bool get hasVerdict => verdictLine != null;
  bool get verdictPassed => verdictLine?.contains('PASS') ?? false;
}

/// The UI-facing state over one [HarnessHost]: session list, streamed
/// progress, pending permission round-trips, and surfaced verdicts.
///
/// The user is an actor in the world: their task inputs are host-injected
/// decisions ([delegate]), their approvals ride the existing
/// `session/request_permission` round-trip ([answerPermission]) — the
/// controller adds no protocol of its own.
final class HarnessSessionController extends ChangeNotifier {
  HarnessSessionController({required HarnessHostConfig config})
    : _config = config,
      host = HarnessHost(config: config);

  HarnessHostConfig _config;
  HarnessHostConfig get config => _config;

  /// The embedded daemon. Recreated by [switchBackend] (the per-workspace
  /// snapshot stores make the world survive the restart — R7c).
  HarnessHost host;

  final List<HarnessSessionView> sessions = [];
  HarnessSessionView? current;
  PendingPermission? pendingPermission;
  String? error;
  bool _started = false;
  Completer<PendingPermission>? _permissionArrived;
  StreamSubscription<PendingPermission>? _permissionSub;

  bool get isRunning => current?.running ?? false;

  /// Idempotently starts the daemon and subscribes to its permission
  /// round-trips.
  Future<void> ensureStarted() async {
    if (_started) return;
    if (!_config.openRouterKeyResolvable) {
      error =
          'OpenRouter needs an API key: enter one below or set '
          'OPENROUTER_API_KEY.';
      notifyListeners();
      return;
    }
    _started = true;
    try {
      _permissionSub = host.permissionRequests.listen(_onPermissionRequest);
      await host.start();
    } on Object catch (e) {
      error = '$e';
      _started = false;
    }
    notifyListeners();
  }

  /// Switches the backend (AFM on-device ↔ OpenRouter) and restarts the
  /// daemon. Sessions of the old backend are dropped; the NEXT session for
  /// a known workspace RESTORES its world from the per-workspace snapshot
  /// store (R7c `loadSession`) — work continues across the switch.
  Future<void> switchBackend(final HarnessHostConfig config) async {
    if (isRunning) {
      error = 'a task is running — cancel it before switching backends.';
      notifyListeners();
      return;
    }
    if (config.backend == _config.backend && config.apiKey == _config.apiKey) {
      return;
    }
    _config = config;
    error = null;
    _started = false;
    await _permissionSub?.cancel();
    _permissionSub = null;
    pendingPermission = null;
    current = null;
    sessions.clear();
    final oldHost = host;
    host = HarnessHost(config: config);
    unawaited(oldHost.stop());
    notifyListeners();
  }

  /// Creates (or resumes) the session for [cwd] and selects it.
  Future<void> createSession(final String cwd) async {
    await ensureStarted();
    if (error != null) {
      notifyListeners();
      return;
    }
    try {
      final id = await host.newSession(cwd);
      final existing = sessions.where((s) => s.id == id).firstOrNull;
      current = existing ?? HarnessSessionView(id: id, cwd: cwd);
      if (existing == null) sessions.add(current!);
    } on Object catch (e) {
      error = '$e';
    }
    notifyListeners();
  }

  /// Delegates a task sentence to [session] (default: the current one) as a
  /// host-injected decision, streaming progress into its transcript.
  Future<AcpStopReason?> delegate(
    final String task, {
    final HarnessSessionView? session,
  }) async {
    final target = session ?? current;
    if (target == null || target.running) return null;
    target
      ..running = true
      ..verdictLine = null;
    notifyListeners();
    try {
      final stop = await host.delegateTask(
        target.id,
        task,
        onText: (final delta) {
          target.transcript.write(delta);
          _extractVerdict(target, delta);
          notifyListeners();
        },
        onToolCall: (final title) {
          target.transcript.write('\n[tool] $title\n');
          notifyListeners();
        },
      );
      target.transcript.write('\n— turn ended ($stop) —\n');
      return stop;
    } on Object catch (e) {
      error = '$e';
      target.transcript.write('\n— turn failed: $e —\n');
      return null;
    } finally {
      target
        ..running = false
        ..transcript.write('\n');
      notifyListeners();
    }
  }

  /// Answers the pending permission round-trip (allow = the write/edit
  /// proceeds; reject = it never lands).
  void answerPermission({required final bool allow}) {
    final pending = pendingPermission;
    pendingPermission = null;
    if (pending != null) {
      allow ? pending.allow() : pending.reject();
    }
    notifyListeners();
  }

  /// Cancels the current session's in-flight turn (real cancellation).
  void cancelCurrent() {
    final session = current;
    if (session != null) host.cancel(session.id);
  }

  /// Selects a session from the list as the current one.
  void selectSession(final HarnessSessionView session) {
    current = session;
    notifyListeners();
  }

  /// Test helper: the next pending permission request (or the one already
  /// waiting).
  Future<PendingPermission> nextPermission({
    final Duration timeout = const Duration(seconds: 60),
  }) {
    final waiting = pendingPermission;
    if (waiting != null) return Future.value(waiting);
    final completer = Completer<PendingPermission>();
    _permissionArrived = completer;
    return completer.future.timeout(timeout);
  }

  /// Test helper: resolves when the current turn is no longer running.
  Future<void> whenIdle({
    final Duration timeout = const Duration(minutes: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while ((current?.running ?? false) && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  void _onPermissionRequest(final PendingPermission pending) {
    pendingPermission = pending;
    _permissionArrived?.complete(pending);
    _permissionArrived = null;
    notifyListeners();
  }

  void _extractVerdict(final HarnessSessionView session, final String delta) {
    final match = RegExp('verdict: (PASS|FAIL)').firstMatch(delta);
    if (match != null) session.verdictLine = match.group(0);
  }

  @override
  void dispose() {
    unawaited(_permissionSub?.cancel());
    unawaited(host.stop());
    super.dispose();
  }
}
