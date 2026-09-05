import 'dart:async';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter/foundation.dart';

import 'package:lastanswer/coding_agent/harness_host.dart';

/// One structured beat inside a turn: a tool call the agent made.
final class TurnToolCall {
  TurnToolCall(this.title, this.at);
  final String title;
  final DateTime at;
}

/// One permission round-trip inside a turn. `allowed == null` while the
/// human (or agent) has not answered — deny-by-default is the UI's job to
/// make visible, never to hide.
final class TurnPermission {
  TurnPermission(this.title, this.at);
  final String title;
  final DateTime at;
  bool? allowed;
}

/// One delegated task turn — the conversation node. The raw transcript
/// string stays the record (tests, debugState); [HarnessTurn] is the
/// structured projection the doc surface renders (small multiples: every
/// turn is laid out identically — task sentence, agent text, tool beats,
/// permission round-trips, verdict with spend).
final class HarnessTurn {
  HarnessTurn(this.taskSentence, this.startedAt);

  final String taskSentence;
  final DateTime startedAt;

  /// R9.a — escalation guidance this turn continues (host-injected via
  /// `agent_task_guide`). First-class grid data, not a transcript line.
  String? guidance;
  final StringBuffer text = StringBuffer();
  final List<TurnToolCall> toolCalls = [];
  final List<TurnPermission> permissions = [];
  String? verdictLine;
  DateTime? completedAt;

  bool get hasVerdict => verdictLine != null;
  bool get verdictPassed => verdictLine?.contains('PASS') ?? false;
  bool get isDone => completedAt != null;

  /// Spend parsed from the verdict line — the tokens source is the backend
  /// verdict chunk (never a guess). Null until the turn ends.
  ({int decisions, int rounds, int tokens, int wallMs})? get spend {
    final v = verdictLine;
    if (v == null) return null;
    int? figure(final String label) {
      final match = RegExp('$label (\\d+)').firstMatch(v);
      return match == null ? null : int.tryParse(match.group(1)!);
    }

    return (
      decisions: figure('decisions') ?? 0,
      rounds: figure('rounds') ?? 0,
      tokens: figure('tokens') ?? 0,
      wallMs: figure('wall') ?? 0,
    );
  }
}

/// One visible harness session: id, delegated workspace, the streamed
/// transcript, structured turns, and the latest surfaced verdict.
final class HarnessSessionView {
  HarnessSessionView({required this.id, required this.cwd});

  final String id;
  final String cwd;
  final StringBuffer transcript = StringBuffer();
  final List<HarnessTurn> turns = [];
  String? verdictLine;
  bool running = false;

  bool get hasVerdict => verdictLine != null;
  bool get verdictPassed => verdictLine?.contains('PASS') ?? false;
  HarnessTurn? get openTurn => turns.isEmpty ? null : turns.last;
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
    if (config.backend == _config.backend &&
        config.apiKey == _config.apiKey &&
        _sameList(config.checkCommand, _config.checkCommand)) {
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
    final turn = HarnessTurn(task, DateTime.now());
    target.turns.add(turn);
    notifyListeners();
    try {
      final stop = await host.delegateTask(
        target.id,
        task,
        onText: (final delta) {
          target.transcript.write(delta);
          turn.text.write(delta);
          _extractVerdict(target, delta, turn);
          notifyListeners();
        },
        onToolCall: (final title) {
          target.transcript.write('\n[tool] $title\n');
          turn.toolCalls.add(TurnToolCall(title, DateTime.now()));
          notifyListeners();
        },
      );
      target.transcript.write('\n— turn ended ($stop) —\n');
      turn.text.write('\n— turn ended ($stop) —\n');
      return stop;
    } on Object catch (e) {
      error = '$e';
      target.transcript.write('\n— turn failed: $e —\n');
      turn.text.write('\n— turn failed: $e —\n');
      return null;
    } finally {
      target
        ..running = false
        ..transcript.write('\n');
      turn.completedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Answers the pending permission round-trip (allow = the write/edit
  /// proceeds; reject = it never lands). The outcome is recorded on the
  /// turn's permission log — the conversation shows the human's decision
  /// as data, same as the agent sees it.
  void answerPermission({required final bool allow}) {
    final pending = pendingPermission;
    pendingPermission = null;
    final logged = _permissionTurns[pending];
    if (logged != null) logged.allowed = allow;
    if (pending != null) {
      allow ? pending.allow() : pending.reject();
    }
    notifyListeners();
  }

  /// Cancels the current session's in-flight turn (real cancellation).
  /// An ANSWER-PENDING permission is rejected first: the human's stop must
  /// break the round-trip — an unanswered write otherwise stalls the tool
  /// for its full 5-minute deadline (measured, Phase-1.5 GUI run), and
  /// deny is the conservative answer.
  void cancelCurrent() {
    if (pendingPermission != null) {
      answerPermission(allow: false);
    }
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
    // Project into the open turn's permission log (same state the UI and
    // the agent projection read — one truth, two renderings).
    final open = current?.openTurn;
    if (open != null) {
      _permissionTurns[pending] = TurnPermission(
        pending.request.title,
        DateTime.now(),
      )..allowed = null;
      open.permissions.add(_permissionTurns[pending]!);
    }
    _permissionArrived?.complete(pending);
    _permissionArrived = null;
    notifyListeners();
  }

  final Map<PendingPermission, TurnPermission> _permissionTurns = {};

  void _extractVerdict(
    final HarnessSessionView session,
    final String delta,
    final HarnessTurn? turn,
  ) {
    final match = RegExp('verdict: (PASS|FAIL)').firstMatch(delta);
    if (match != null) {
      final line = match.group(0);
      session.verdictLine = line;
      if (turn != null) turn.verdictLine = line;
    }
  }

  @override
  void dispose() {
    unawaited(_permissionSub?.cancel());
    unawaited(host.stop());
    super.dispose();
  }

  static bool _sameList(final List<String>? a, final List<String>? b) {
    final x = a ?? const <String>[];
    final y = b ?? const <String>[];
    return x.length == y.length &&
        x.indexed.every((final e) => y[e.$1] == e.$2);
  }
}
