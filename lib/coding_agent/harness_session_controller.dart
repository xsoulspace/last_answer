import 'dart:async';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter/foundation.dart';
import 'package:headless_core/headless_core.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/permission_doc_router.dart';

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

  /// PLAN 5c — the answer's origin, resolved through the roster at record
  /// time (small-caps actor/device label, DESIGN §9). Null for local
  /// answers: a remote answer is recorded on the turn exactly like a
  /// local one, indistinguishable except by origin (ADR 0005 §5).
  String? originLabel;
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
///
/// A session is a TRANSCRIPT PROJECTION onto the workspace's world, not
/// the world itself (ADR 0006): several sessions may sit on one workspace
/// — one world, one daemon — and each carries its own turn stream.
/// [viewId] is projection-local (unique per view even when two views
/// share the host's per-workspace session id); [id] is the host session.
final class HarnessSessionView {
  HarnessSessionView({required this.id, required this.cwd})
    : viewId = _nextViewId++;

  static int _nextViewId = 1;

  final String id;
  final int viewId;
  final String cwd;
  final StringBuffer transcript = StringBuffer();
  final List<HarnessTurn> turns = [];
  String? verdictLine;
  bool running = false;

  /// ADR 0006 registry `Actors[]`, roster-backed (ADR 0007 §4): stable,
  /// syncable ids — display identity resolves through the roster at read
  /// time ([actors]), so a late-arriving profile lights the row up without
  /// a registry rewrite.
  final List<String> actorIds = [];

  /// Resolves [actorIds] through [roster]. Unknown (not yet synced) ids
  /// are skipped, never guessed — honest surfaces (DESIGN §6).
  List<ActorProfile> actors(final ActorRoster roster) => [
    for (final actorId in actorIds) ?roster.get(actorId),
  ];

  bool get hasVerdict => verdictLine != null;
  bool get verdictPassed => verdictLine?.contains('PASS') ?? false;
  HarnessTurn? get openTurn => turns.isEmpty ? null : turns.last;
}

/// One bound workspace in the session registry (ADR 0006):
/// `Workspace (≤1 world/daemon) → Sessions[] → Actors[]`. The backend
/// keys sessions per cwd — a second `session/new` for the same workspace
/// CONTINUES the live world — so every session listed here is a
/// projection on one single-writer world.
final class HarnessWorkspaceView {
  HarnessWorkspaceView({required this.cwd});

  final String cwd;
  final List<HarnessSessionView> sessions = [];
}

/// The UI-facing state over one [HarnessHost]: the workspace-aware session
/// registry, streamed progress, pending permission round-trips, and
/// surfaced verdicts.
///
/// The user is an actor in the world: their task inputs are host-injected
/// decisions ([delegate]), their approvals ride the existing
/// `session/request_permission` round-trip ([answerPermission]) — the
/// controller adds no protocol of its own.
final class HarnessSessionController extends ChangeNotifier {
  HarnessSessionController({
    required HarnessHostConfig config,
    final ActorRoster? roster,
  }) : _config = config,
       roster = roster ?? ActorRoster(replicaId: 'device'),
       host = HarnessHost(config: config);

  HarnessHostConfig _config;
  HarnessHostConfig get config => _config;

  /// ADR 0007 — the actor roster: one durable LWW kernel doc of actor
  /// identities shared by every session projection. Identity, not
  /// authority: joining with a profile grants nothing (ADR 0007 §3).
  final ActorRoster roster;

  /// The embedded daemon. Recreated by [switchBackend] (the per-workspace
  /// snapshot stores make the world survive the restart — R7c).
  HarnessHost host;

  /// PLAN 5c — the doc channel for remote permission routing (ADR 0005
  /// §5). Null until the app wiring attaches one
  /// ([attachPermissionRouter]); without it, permissions are purely
  /// device-local round-trips.
  PermissionDocRouter? permissionRouter;

  /// PLAN 5c policy — default OFF: local answering is unchanged and no
  /// permission op is ever written. ON: a pending host permission is
  /// announced as a doc op and its future completes when the ANSWER op
  /// folds into the doc (from a peer or from this device — one state, one
  /// completion path). Deny-by-default is preserved: no answer op → no
  /// completion; the host's own 5-minute deadline remains the backstop.
  bool remotePermissionRouting = false;

  bool get _routingEnabled =>
      remotePermissionRouting && permissionRouter != null;

  /// Attaches the doc channel for remote permission routing (see
  /// [permissionRouter]). The caller owns the router's store lifecycle.
  void attachPermissionRouter(final PermissionDocRouter router) {
    permissionRouter = router;
    notifyListeners();
  }

  /// Routed permission round-trips: pending future → doc request id.
  final Map<PendingPermission, String> _routedPermissionIds = {};

  /// ADR 0006 registry: workspaces (each with ≤1 world) and their
  /// session projections. Several sessions per workspace are legal;
  /// the world stays single-writer by backend construction.
  final List<HarnessWorkspaceView> workspaces = [];

  /// Flat view over all sessions (workspace order preserved). Kept for
  /// consumers that do not care about grouping; the profile pane renders
  /// the grouped registry.
  Iterable<HarnessSessionView> get sessions sync* {
    for (final workspace in workspaces) {
      yield* workspace.sessions;
    }
  }

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
    workspaces.clear();
    final oldHost = host;
    host = HarnessHost(config: config);
    unawaited(oldHost.stop());
    notifyListeners();
  }

  /// Creates (or resumes) the first session projection for [cwd] and
  /// selects it. The world for [cwd] is continued, never duplicated.
  Future<void> createSession(final String cwd) async {
    await ensureStarted();
    if (error != null) {
      notifyListeners();
      return;
    }
    try {
      final id = await host.newSession(cwd);
      _adoptSession(cwd, id);
    } on Object catch (e) {
      error = '$e';
    }
    notifyListeners();
  }

  /// ADR 0006 — opens a NEW session projection on [cwd]'s world. Several
  /// sessions per workspace are legal; the world (and its daemon) stays
  /// single-writer. World-level effects (cancel, world state) are shared
  /// across projections on the same workspace — recorded honestly, never
  /// hidden.
  Future<void> openNewSession(final String cwd) async {
    await ensureStarted();
    if (error != null) {
      notifyListeners();
      return;
    }
    try {
      final id = await host.newSession(cwd);
      _adoptSession(cwd, id, forceNew: true);
    } on Object catch (e) {
      error = '$e';
    }
    notifyListeners();
  }

  HarnessWorkspaceView _workspace(final String cwd) {
    for (final workspace in workspaces) {
      if (workspace.cwd == cwd) return workspace;
    }
    final workspace = HarnessWorkspaceView(cwd: cwd);
    workspaces.add(workspace);
    return workspace;
  }

  HarnessSessionView _adoptSession(
    final String cwd,
    final String id, {
    final bool forceNew = false,
  }) {
    final workspace = _workspace(cwd);
    if (!forceNew) {
      final existing = workspace.sessions
          .where((final s) => s.id == id)
          .firstOrNull;
      if (existing != null) {
        current = existing;
        return existing;
      }
    }
    final view = HarnessSessionView(id: id, cwd: cwd);
    workspace.sessions.add(view);
    current = view;
    return view;
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
  ///
  /// PLAN 5c: when [remotePermissionRouting] is ON and the pending was
  /// announced as a doc op, the answer is ISSUED AS A DOC OP — the host's
  /// future completes when the answer op folds back (immediately for a
  /// locally-issued answer; with the next sync for a peer's). OFF (or not
  /// announced): the direct local round-trip, byte-for-byte unchanged.
  void answerPermission({required final bool allow}) {
    final pending = pendingPermission;
    pendingPermission = null;
    final logged = _permissionTurns[pending];
    if (logged != null) logged.allowed = allow;
    final requestId = pending == null ? null : _routedPermissionIds[pending];
    if (pending != null && requestId != null) {
      // Kept in _routedPermissionIds: the future completes when the answer
      // op folds back (refreshPermissions) — the fold records the outcome
      // on the turn and retires the mapping.
      unawaited(_answerThroughDoc(requestId, allow));
    } else if (pending != null) {
      allow ? pending.allow() : pending.reject();
    }
    notifyListeners();
  }

  /// Issues the answer op through the doc channel; [refreshPermissions]
  /// then completes the host's future from the folded op.
  Future<void> _answerThroughDoc(
    final String requestId,
    final bool allow,
  ) async {
    final router = permissionRouter;
    if (router == null) return;
    try {
      await router.answerRequest(requestId: requestId, allow: allow);
    } on Object catch (e) {
      // The write failed (storage gone) or a concurrent answer folded in
      // first (first answer wins). The human decided — the round-trip
      // must not strand: complete directly, conservatively.
      error = 'permission answer not recorded as doc op: $e';
      final pending = _pendingForRequest(requestId);
      if (pending != null && !pending.isAnswered) {
        allow ? pending.allow() : pending.reject();
        _routedPermissionIds.remove(pending);
      }
      notifyListeners();
      return;
    }
    refreshPermissions();
  }

  PendingPermission? _pendingForRequest(final String requestId) {
    for (final entry in _routedPermissionIds.entries) {
      if (entry.value == requestId) return entry.key;
    }
    return null;
  }

  /// PLAN 5c — peer-side answer (ADR 0005 §3 input rights): answers a
  /// remote pending permission through the doc. Recorded as data (the
  /// answer op); the OWNER's future completes when the op arrives with
  /// the next sync cycle. Nothing here grants authority beyond the one
  /// round-trip (ADR 0007 §3).
  Future<void> answerRemotePermission(
    final String requestId, {
    required final bool allow,
  }) async {
    final router = permissionRouter;
    if (router == null) return;
    try {
      await router.answerRequest(requestId: requestId, allow: allow);
    } on Object catch (e) {
      error = 'remote permission answer refused: $e';
      notifyListeners();
      return;
    }
    refreshPermissions();
  }

  /// Signature of the remote-permission projection — a change means the
  /// surface (and the agent projection) must rebuild.
  String? _remotePermSignature;

  static String _permSignatureOf(final List<PermRequestRecord> records) =>
      records.map((final r) => '${r.requestId}:${r.status.name}').join('|');

  /// Re-reads the folded permission state of the doc replica: completes
  /// routed futures whose ANSWER op has arrived (locally issued answers
  /// fold immediately; remote answers fold with the mesh sync cycle —
  /// the app wiring calls this after [MeshStorageService.sync]).
  /// Attributes remote answers on the turn with a roster-resolved origin
  /// label (DESIGN §9); local answers keep none. Also notifies when the
  /// remote-permission projection changed (a request arrived, or an
  /// answer landed) — one state, many projections (DESIGN §5).
  void refreshPermissions() {
    final router = permissionRouter;
    if (router == null) return;
    var changed = false;
    if (_routedPermissionIds.isNotEmpty) {
      for (final record in router.entries()) {
        if (record.isPending) continue;
        final pending = _pendingForRequest(record.requestId);
        if (pending == null) continue;
        _routedPermissionIds.remove(pending);
        changed = true;
        if (!pending.isAnswered) {
          final allow = record.status == PermRequestStatus.allow;
          allow ? pending.allow() : pending.reject();
          final logged = _permissionTurns[pending];
          if (record.responderPeerId != null &&
              record.responderPeerId != router.selfId) {
            // Remote answer: recorded on the turn exactly like a local
            // one, attributed with the roster-resolved origin (DESIGN §9).
            logged
              ?..allowed = allow
              ..originLabel =
                  roster.get(record.responderActorId ?? '')?.gutterLabel ??
                  actorGutterLabel(record.responderPeerId!);
          } else {
            logged?.allowed = allow;
          }
        }
      }
    }
    final signature = _permSignatureOf(remotePermissions);
    if (signature != _remotePermSignature) {
      _remotePermSignature = signature;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// Remote permission entries (announced by OTHER peers, pending and
  /// answered) — the peer-side in-flow projection (DESIGN §9). Own
  /// announcements render through [pendingPermission] / the turn log.
  List<PermRequestRecord> get remotePermissions =>
      permissionRouter?.remoteEntries() ?? const [];

  /// Origin gutter label for a remote permission record: the roster
  /// actor when resolvable, else the announcing device (small-caps —
  /// DESIGN §9; identity, never authority, ADR 0007 §3).
  String originLabelOf(final PermRequestRecord record) =>
      roster.get(record.originActorId ?? '')?.gutterLabel ??
      actorGutterLabel(record.originPeerId);

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

  /// ADR 0007 — attaches a roster actor to a session projection (the
  /// registry's `Actors[]`). Data-first: an id the roster does not (yet)
  /// know still attaches — it renders once the roster resolves it.
  void attachActor(final HarnessSessionView session, final String actorId) {
    if (actorId.isEmpty || session.actorIds.contains(actorId)) return;
    session.actorIds.add(actorId);
    notifyListeners();
  }

  /// Detaches a roster actor from a session projection.
  void detachActor(final HarnessSessionView session, final String actorId) {
    if (!session.actorIds.remove(actorId)) return;
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
    if (_routingEnabled) {
      unawaited(_announcePermission(pending));
    }
    _permissionArrived?.complete(pending);
    _permissionArrived = null;
    notifyListeners();
  }

  /// PLAN 5c — announces the pending round-trip as a doc op so peers see
  /// it and can answer (the gate: a permission answered from the second
  /// device). Attributed to the session's attached actor when one is
  /// registered (ADR 0007 §2). If the round-trip was decided while the
  /// announcement was in flight (deny-first cancel), the recorded answer
  /// goes out as an op too — a decided request is never left pending.
  Future<void> _announcePermission(final PendingPermission pending) async {
    final router = permissionRouter;
    if (router == null) return;
    final String requestId;
    try {
      requestId = await router.announceRequest(
        title: pending.request.title,
        originActorId: current?.actorIds.firstOrNull,
      );
    } on Object catch (e) {
      // The doc channel is down: the round-trip stays local (the host's
      // own deadline is the backstop). Named, never silent.
      error = 'permission not announced to the mesh: $e';
      notifyListeners();
      return;
    }
    _routedPermissionIds[pending] = requestId;
    final decided = _permissionTurns[pending]?.allowed;
    if (decided != null) {
      _routedPermissionIds.remove(pending);
      unawaited(_answerThroughDoc(requestId, decided));
    }
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
