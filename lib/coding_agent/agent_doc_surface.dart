import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/permission_doc_router.dart';
import 'package:lastanswer/coding_agent/turn_queue.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// ADR 0003 (Phase 1) — the agent-doc surface: the coding-agent machinery
/// bound to a `ProjectModel.doc` (formatId: `agent`). The document carries
/// the durable, syncable data (workspace set, backend, check override); the
/// world snapshots stay device-local in the workspace.
///
/// Phase 1.5 UX rewrite (Tufte × Müller-Brockmann): the working surface is
/// TEXT — a conversation of turns on one strict grid. A fixed role gutter
/// (YOU / agent / SYS / PERM) carries every line; turns render as small
/// multiples; tool beats are dim monospace rows; the verdict is one colored
/// rule with the spend. PROFILE and SETUP are toggleable panes over the
/// same grid, not always-on chrome. No cards, no bubbles, no decorative
/// icons — ink is data.
///
/// The screen is a projection of the same typed state an agent reads —
/// [debugState] exposes it for the MCP/intent surface (agent-friendly UI).
final class AgentDocSurface extends StatefulWidget {
  const AgentDocSurface({
    required this.doc,
    this.controller,
    this.onDocChanged,
    this.config,
    super.key,
  });

  final ProjectModelDoc doc;

  /// Optional pre-built controller (tests inject the scripted seam).
  final HarnessSessionController? controller;

  /// Persist the doc payload after workspace/backend/check changes. The app
  /// wires the projects repository; tests capture in memory.
  final ValueChanged<ProjectModelDoc>? onDocChanged;

  /// Optional host config override (tests inject the scripted seam; its
  /// backend/check are overridden by the doc payload).
  final HarnessHostConfig? config;

  /// The live surface state for the agent/intent projection
  /// (`DocView.debugDocState` pattern).
  static AgentDocDebugState? debugState;

  /// The live surface for intent-driven actions (delegate/answer) —
  /// set while the doc is open, cleared on dispose.
  static _AgentDocSurfaceState? debugSurface;

  /// Task O — the peer-side SHADOW doc (`mesh_open_doc`): the honest
  /// viewer/answerer projection a paired peer opens over a SHARED doc id
  /// — no workspace, no daemon session (the peer observes the host's
  /// world and answers routed permissions). Null until opened; the
  /// `agent_doc_state` verb falls back to it when no real surface is
  /// open, so the peer's projection stops being an error envelope.
  static AgentDocShadow? shadowDoc;

  /// R9.a — app wiring for the `agent_doc_create` intent: creates a NEW
  /// agent doc AND opens it (the `OpenedProjectNotifier.createAgentProject`
  /// path, including the route push), returning the created doc. Installed
  /// by the app shell in debug/profile builds only (same guard that
  /// registers the MCP entries); headless drivers need create+open as ONE
  /// verb — a form fill cannot do it (Phase-1.5 measurement).
  static ProjectModelDoc Function()? createAgentProjectHook;

  /// Task H — app wiring for the multiplayer seams, installed by the app
  /// shell in debug/profile builds (same guard as [createAgentProjectHook]).
  /// The live mesh replica is owned by `StorageBackendsNotifier`; this
  /// wiring is how the doc surface REACHES it:
  ///
  /// - [AgentDocMeshWiring.routerFor] builds the doc channel for remote
  ///   permission routing over the mesh-attached [DocReplicaStore] —
  ///   [docId] is the deterministic per-doc replica id the surface derives
  ///   (`agent-<projectDocId>`), so perm ops land in a SYNCED doc.
  /// - [AgentDocMeshWiring.joinDoc]/[leaveDoc] carry presence (ADR 0031
  ///   §1: doc-scoped join is the CALLER's job) — the surface calls them
  ///   on open/dispose, so presence follows doc sessions.
  /// - [AgentDocMeshWiring.statusFor] reads the mesh status the status
  ///   projection exposes (hosting / connected / peers / presence).
  static AgentDocMeshWiring? meshWiring;

  @override
  State<AgentDocSurface> createState() => _AgentDocSurfaceState();
}

/// ADR 0009 (D4) — the full agent-doc projection a registered SURFACE
/// handle carries beside the host [SessionHandle] contract. The MCP verbs
/// resolve their target through the session registry (D1/D2) — never a
/// widget static; a resolved handle that IS an [AgentDocHandle] projects
/// the complete doc state (the queue, the mesh status, the roster —
/// everything [AgentDocDebugState] carries, DESIGN §5), while any other
/// handle (a daemon runner, a scripted seam) exposes the host
/// [SessionSnapshot] only.
abstract interface class AgentDocHandle implements SessionHandle {
  /// The live agent-doc projection — the same typed state the human
  /// screen renders (one state, many projections, DESIGN §5).
  AgentDocDebugState get debugState;
}

class _AgentDocSurfaceState extends State<AgentDocSurface>
    implements AgentDocHandle {
  late ProjectModelDoc _doc = widget.doc;
  late final HarnessSessionController _controller =
      widget.controller ?? HarnessSessionController(config: _configFor(_doc));
  late final bool _ownsController = widget.controller == null;
  final _workspaceField = TextEditingController();
  final _taskField = TextEditingController();
  final _keyField = TextEditingController();
  final _checkField = TextEditingController();
  final _composerFocus = FocusNode();
  final _expandedBeats = <int>{};
  String? _pickError;
  bool _setupOpen = false;
  bool _profileOpen = false;
  String? _routingError;

  // PLAN 9 — the queue + cooled-turn editing state (pure view state; the
  // DATA lives in the controller's queue and the doc payload blocks).
  final _queueEditField = TextEditingController();
  final _turnEditField = TextEditingController();
  String? _editingStepId;
  int? _editingTurnKey;
  final _expandedTurnHistory = <int>{};
  String _queueSignature = '';

  /// Task H — the deterministic replica id of THIS doc in the mesh sync
  /// cycle: flat (`agent-<projectDocId>`) so the per-doc replica file sits
  /// directly in the store's directory, and identical on every paired
  /// device (the project doc id is the shared key).
  String get _meshDocId => 'agent-${_doc.id.value}';

  /// Marks THIS doc the device-local focused session (the "last
  /// interaction" heuristic — ADR 0009 §Open questions 1: device-local,
  /// never synced). Called on initState and on any delegate/permission/
  /// composer ACTION with the surface — deliberate interactions only
  /// (a passive focus gain — e.g. a spurious autofocus re-resolution on
  /// a rebuild — must not steal the marker).
  void _markFocused() {
    HarnessSessionRegistry.instance.focused = _meshDocId;
  }

  @override
  void initState() {
    super.initState();
    AgentDocSurface.debugSurface = this;
    // ADR 0009 (D1) — presence in the host registry under the
    // deterministic mesh replica id (the addressable session id). The
    // registry — not a widget static — is the one index the MCP verbs and
    // the profiler resolve through; registration grants observability and
    // intent routing, never authority (ADR 0007 §3). Registration does
    // not move focus: mark it explicitly.
    HarnessSessionRegistry.instance.register(_meshDocId, this);
    _markFocused();
    _workspaceField.text = _doc.agent?.workspaces.firstOrNull ?? '';
    _checkField.text = _doc.agent?.checkCommand.join(' ') ?? '';
    // Listen to the controller, NOT onChanged: programmatic/semantic value
    // injection (agent fill_form, paste) never fires onChanged, and the
    // override silently failed to reach the daemon in the Phase-1.5 GUI
    // run (measured). Controller edits fire this for typing AND fill.
    _checkField.addListener(_onCheckChanged);
    // PLAN 9 — return-after-interruption reconstructs the queue (DESIGN
    // §10): the durable copy lives in the doc payload's reserved blocks.
    _restoreQueueFromDoc();
    unawaited(_controller.ensureStarted());
    // PLAN 9 — the queue must survive into the doc payload on EVERY
    // transition, including the flush pump's deliveries (controller-internal).
    _queueSignature = _controller.queue.signature;
    _controller.addListener(_onControllerChanged);
    // Task H — presence follows the doc session (ADR 0031 §1): while the
    // doc is open, this device is on the doc's presence channel; the
    // leave goes out on dispose.
    unawaited(AgentDocSurface.meshWiring?.joinDoc(_meshDocId));
  }

  HarnessHostConfig _configFor(final ProjectModelDoc doc) {
    final base = widget.config ?? const HarnessHostConfig();
    final agent = doc.agent ?? const AgentDocModel();
    return base.copyWith(
      backend: agent.backend,
      checkCommand: agent.checkCommand.isEmpty ? null : agent.checkCommand,
      // R9.1 — the agent doc's embedded runtime is the MEANING runtime:
      // reads are budgeted zoom cuts, mutations are host-materialized edit
      // moves (verify + auto-revert). The conventional command profile
      // stays only for external CLI squad members (R9.c).
      meaningProfile: true,
    );
  }

  /// Intent surface: delegate a task sentence (host-injected decision)
  /// without touching the text fields. Returns (ok, message).
  ({bool ok, String message}) delegateFromIntent(final String task) {
    // A host-injected decision targets THIS doc — the device-local focus
    // follows the last interaction (ADR 0009 §Open questions 1).
    _markFocused();
    final current = _controller.current;
    if (current?.running ?? false) {
      return (ok: false, message: 'a task is already running.');
    }
    final workspace = _workspaceField.text.trim();
    if (workspace.isEmpty) {
      return (ok: false, message: 'no workspace bound to the doc yet.');
    }
    unawaited(() async {
      await _syncConfigBeforeTurn();
      if (current == null || current.cwd != workspace) {
        await _controller.createSession(workspace);
      }
      final agent = _doc.agent ?? const AgentDocModel();
      if (!agent.workspaces.contains(workspace)) {
        _persist(agent.copyWith(workspaces: [...agent.workspaces, workspace]));
      }
      await _controller.delegate(task);
    }());
    return (ok: true, message: 'delegated: $task');
  }

  /// Intent surface: answer the pending permission round-trip.
  ({bool ok, String message}) answerPermissionFromIntent({
    required final bool allow,
  }) {
    _markFocused();
    if (_controller.pendingPermission == null) {
      return (ok: false, message: 'no pending permission request.');
    }
    _controller.answerPermission(allow: allow);
    return (ok: true, message: allow ? 'allowed' : 'rejected');
  }

  // -------------------------------------------------------------------
  // ADR 0009 (D1) — the registry seam ([SessionHandle]): the SAME
  // projection the human screen renders, exposed to the host layer's one
  // index of live sessions. DESIGN §5/§6 — honest mapping: every field
  // below is read from the typed state the pane truly shows; a figure
  // with no source (spend before a verdict, a context cut with no
  // session) stays null/empty, never fabricated.
  // -------------------------------------------------------------------

  /// The live agent-doc projection — the canonical typed state the human
  /// screen and the MCP verbs read (one state, many projections —
  /// DESIGN §5).
  @override
  AgentDocDebugState get debugState => _projectState();

  @override
  SessionSnapshot get state {
    final projection = debugState;
    final current = _controller.current;
    final lastTurn = current?.turns.lastOrNull;
    final spend = lastTurn?.spend;
    // The beats the pane renders: the turn text's dim `[tool] …` rows
    // (the same parse `_TurnBody` performs for the grid rows).
    final beats = [
      for (final raw in (lastTurn?.text.toString() ?? '').split('\n'))
        if (raw.startsWith('['))
          SessionBeat(
            name:
                RegExp(r'^\[([a-z0-9_\-]+)\]').firstMatch(raw)?.group(1) ??
                'tool',
            detail: raw.replaceFirst(RegExp(r'^\[[^\]]+\]\s?'), ''),
          ),
    ];
    // The PROFILE pane's CONTEXT LOAD row, as data — figures the host
    // truly observes (no session → honest absence, never a zero cut).
    var decisions = 0;
    var tokens = 0;
    for (final turn in current?.turns ?? const <HarnessTurn>[]) {
      final s = turn.spend;
      if (s != null) {
        decisions += s.decisions;
        tokens += s.tokens;
      }
    }
    final contextSummary = current == null
        ? ''
        : 'turns ${current.turns.length} · decisions $decisions · '
              '${(tokens / 1000).toStringAsFixed(1)}k tok · '
              '${current.transcript.length} chars';
    return SessionSnapshot(
      sessionId: current?.id ?? '',
      kind: 'surface',
      running: projection.running,
      pendingPermissionTitle: projection.pendingPermissionTitle,
      verdict: projection.verdict,
      spend: spend == null
          ? null
          : SessionSpend(
              decisions: spend.decisions,
              rounds: spend.rounds,
              tokens: spend.tokens,
              wallMs: spend.wallMs,
            ),
      transcriptTail: projection.transcriptTail,
      turnCount: projection.turnCount,
      beats: beats,
      contextSummary: contextSummary,
    );
  }

  /// Intent action (host-layer contract, byte-compatible with the
  /// debugSurface path — [delegateFromIntent] IS this decision).
  @override
  SessionIntentResult delegateTask(final String task) =>
      delegateFromIntent(task);

  @override
  SessionIntentResult answerPermission({required final bool allow}) =>
      answerPermissionFromIntent(allow: allow);

  /// Task H — PROFILE: remote permission routing (ADR 0005 §5, DESIGN §4 —
  /// one simple place, on the grid). ON: the controller's doc router is
  /// attached (over the mesh-attached live store, deterministic replica
  /// id per doc) and the policy enabled — pending permissions are
  /// announced as doc ops peers can answer. OFF: local answering,
  /// byte-for-byte unchanged, nothing written.
  ({bool ok, String message}) setRemoteRouting({required final bool enabled}) {
    if (!enabled) {
      _controller.remotePermissionRouting = false;
      setState(() => _routingError = null);
      // Task O — the agent projection re-reads the policy synchronously.
      AgentDocSurface.debugState = _projectState();
      return (ok: true, message: 'remote routing off — answering stays local.');
    }
    final wiring = AgentDocSurface.meshWiring;
    if (wiring == null) {
      setState(
        () => _routingError = 'mesh wiring is not installed in this build.',
      );
      return (ok: false, message: _routingError!);
    }
    try {
      _controller
        ..attachPermissionRouter(wiring.routerFor(NodeId(_meshDocId)))
        ..remotePermissionRouting = true;
    } on Object catch (error) {
      setState(() => _routingError = 'mesh is not live on this device: $error');
      return (ok: false, message: _routingError!);
    }
    setState(() => _routingError = null);
    // Task O — the agent projection re-reads the policy synchronously:
    // `mesh_routing` returns AFTER the projected state carries it.
    AgentDocSurface.debugState = _projectState();
    return (
      ok: true,
      message:
          'remote routing on — pending permissions are announced as doc ops.',
    );
  }

  /// Task H — app wiring (after every mesh sync cycle): the folded doc
  /// state may have changed under us — a peer answered a routed
  /// permission. Re-read the projection.
  void refreshAfterMeshSync() {
    _controller.refreshPermissions();
    // Task O — re-project IMMEDIATELY, not on the next frame: the
    // MCP/intent projection must match the live service within one sync
    // cycle (the T3 gate diffs debugState byte-for-byte) — a build-frame
    // delay must never stand between an agent and the truth.
    if (mounted) AgentDocSurface.debugState = _projectState();
    if (mounted) setState(() {});
  }

  /// The typed state both projections render ([AgentDocSurface
  /// .debugState]): extracted so the sync-cycle hook and the intent
  /// surface re-project synchronously — build timing is not part of the
  /// agent contract (DESIGN §5: one state, many projections).
  AgentDocDebugState _projectState() {
    final controller = _controller;
    final current = controller.current;
    String? lastGuidance;
    for (final turn in (current?.turns ?? const <HarnessTurn>[]).reversed) {
      if (turn.guidance != null) {
        lastGuidance = turn.guidance;
        break;
      }
    }
    return AgentDocDebugState(
      docId: _doc.id.value,
      workspaces: _doc.agent?.workspaces ?? const [],
      checkCommand: _doc.agent?.checkCommand ?? const <String>[],
      backend: controller.config.backend,
      runtimeProfile: controller.config.meaningProfile
          ? 'meaning'
          : 'commands',
      sessionId: current?.id,
      running: controller.isRunning,
      pendingPermissionTitle: controller.pendingPermission?.request.title,
      remotePermissions: controller.remotePermissions,
      remotePermissionRouting: controller.remotePermissionRouting,
      meshStatus: AgentDocSurface.meshWiring?.statusFor(_meshDocId),
      verdict: current?.verdictLine,
      transcriptTail: current?.transcript.toString() ?? '',
      turnCount: current?.turns.length ?? 0,
      lastGuidance: lastGuidance,
      actors: controller.roster.all,
      sessionActors: {
        for (final session in controller.sessions)
          '${session.viewId}': List.of(session.actorIds),
      },
      // PLAN 9 — the queue in the projection (DESIGN §5/§8): headless
      // drivers see the SAME queue the human sees — open steps with
      // position + age, superseded/delivered steps queryable.
      queue: [
        for (final step in controller.queue.steps)
          AgentDocQueueEntry(
            id: step.id,
            text: step.text,
            status: step.status.name,
            from: step.from,
            to: step.to,
            immediate: step.immediate,
            createdAtMs: step.createdAt.millisecondsSinceEpoch,
            position: step.status == QueueStepStatus.open
                ? controller.queue.positionOf(step)
                : null,
            ageMs: DateTime.now().difference(step.createdAt).inMilliseconds,
          ),
      ],
    );
  }

  /// R9.a — intent surface: bind the workspace (absolute path) and the
  /// optional check override DIRECTLY onto the doc payload. NEVER a form
  /// fill: semantic text injection does not fire controller listeners, so
  /// a filled field silently bypassed persistence (measured, Phase 1.5).
  /// Persists via [onDocChanged] and reflects the binding in the human UI
  /// (fields + SETUP state) — the same typed state, two projections.
  ({bool ok, String message}) bindFromIntent({
    required final String workspace,
    final String? check,
  }) {
    final trimmed = workspace.trim();
    if (trimmed.isEmpty) {
      return (ok: false, message: 'workspace (absolute path) is required.');
    }
    if (!trimmed.startsWith('/')) {
      return (ok: false, message: 'workspace must be an absolute path.');
    }
    if (_controller.isRunning) {
      return (
        ok: false,
        message: 'a task is running — binding is refused while a turn runs.',
      );
    }
    final agent = _doc.agent ?? const AgentDocModel();
    final words = check == null
        ? agent.checkCommand
        : check
              .trim()
              .split(RegExp(r'\s+'))
              .where((final w) => w.isNotEmpty)
              .toList();
    _persist(
      agent.copyWith(
        workspaces: agent.workspaces.contains(trimmed)
            ? agent.workspaces
            : [...agent.workspaces, trimmed],
        checkCommand: words,
      ),
    );
    // Reflect the binding for the human. The check field's listener
    // re-fires on this assignment but persists nothing new: the payload
    // already carries exactly these words.
    _workspaceField.text = trimmed;
    if (check != null) _checkField.text = check;
    setState(() {});
    unawaited(_syncConfigBeforeTurn().catchError((final _) {}));
    return (
      ok: true,
      message: check == null
          ? 'bound workspace $trimmed.'
          : 'bound workspace $trimmed with check override.',
    );
  }

  /// R9.a — intent surface: escalation guidance for the open doc's LAST
  /// turn. A host-injected decision (same channel as a delegate), recorded
  /// as FIRST-CLASS grid state: the turn carries its guidance provenance,
  /// the composer pre-fills the continuation sentence, and the turn is
  /// delegated immediately. Monotonic: exactly one guidance per ended
  /// turn — a second `agent_task_guide` for the same turn is refused.
  ({bool ok, String message}) guideFromIntent(final String guidance) {
    final trimmed = guidance.trim();
    if (trimmed.isEmpty) return (ok: false, message: 'guidance is required.');
    final session = _controller.current;
    if (session == null) {
      return (ok: false, message: 'no session yet — delegate a task first.');
    }
    if (_controller.isRunning) {
      return (
        ok: false,
        message: 'a task is running — guidance is refused while a turn runs.',
      );
    }
    final last = session.turns.lastOrNull;
    if (last == null || !last.isDone) {
      return (ok: false, message: 'the last turn has not ended yet.');
    }
    if (last.guidance != null) {
      return (
        ok: false,
        message: 'guidance already recorded for the last turn (monotonic).',
      );
    }
    last.guidance = trimmed;
    // The composer pre-fills the continuation — visible, editable by the
    // human, and the exact sentence the host receives.
    _taskField.text = 'continue with guidance: $trimmed';
    setState(() {});
    unawaited(_delegate());
    return (
      ok: true,
      message: 'guidance recorded; continuing with guidance.',
    );
  }

  bool get _hasBoundWorkspace => _doc.agent?.workspaces.isNotEmpty ?? false;

  /// Setup stays open until the doc is bound (onboarding), then the user
  /// toggles it. Sovereignty: the human decides what is visible.
  bool get _showSetup => _setupOpen || !_hasBoundWorkspace;

  @override
  void dispose() {
    if (identical(AgentDocSurface.debugSurface, this)) {
      AgentDocSurface.debugSurface = null;
    }
    // ADR 0009 (D1) — leave the registry with the IDENTICAL GUARD: a
    // stale teardown (this slot re-registered by a newer projection) is a
    // no-op and never clobbers the live handle.
    HarnessSessionRegistry.instance.unregister(_meshDocId, this);
    unawaited(AgentDocSurface.meshWiring?.leaveDoc(_meshDocId));
    _checkField.removeListener(_onCheckChanged);
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    _workspaceField.dispose();
    _taskField.dispose();
    _keyField.dispose();
    _checkField.dispose();
    _composerFocus.dispose();
    _queueEditField.dispose();
    _turnEditField.dispose();
    super.dispose();
  }

  void _persist(final AgentDocModel agent) {
    _doc = _doc.copyWith(agent: agent);
    widget.onDocChanged?.call(_doc);
  }

  /// Ensures the daemon config matches the doc payload before a turn
  /// (check override, backend). No-op when unchanged; refused while a turn
  /// runs. Doc-payload edits made while a session exists otherwise never
  /// reach the daemon — the session silently keeps the stale config
  /// (measured twice in the Phase-1.5 GUI run).
  ///
  /// Only DOC-OWNED fields are re-derived (backend, check) — over the LIVE
  /// config, never from a fresh default: a rebuild would drop the host
  /// seam (injected handler) and strand the daemon on the wrong runtime
  /// (measured: the scripted mover vanished and the turn never started).
  /// The API key stays device-local — carried, never persisted.
  Future<void> _syncConfigBeforeTurn() async {
    if (_controller.isRunning) return;
    final agent = _doc.agent;
    await _controller.switchBackend(
      _controller.config.copyWith(
        backend: agent?.backend ?? _controller.config.backend,
        checkCommand: agent == null || agent.checkCommand.isEmpty
            ? const <String>[]
            : agent.checkCommand,
      ),
    );
  }

  /// Persists the check override (whitespace-split argv — no shell, no
  /// interpolation; the verifier runs it via `Process.run` literally).
  /// Empty = the workspace convention decides (D8). While no session is
  /// running, the host config is refreshed so the next session picks it up.
  void _onCheckChanged() {
    final words = _checkField.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((final w) => w.isNotEmpty)
        .toList();
    final agent = _doc.agent ?? const AgentDocModel();
    if (_listEquals(words, agent.checkCommand)) return;
    _persist(agent.copyWith(checkCommand: words));
    unawaited(_syncConfigBeforeTurn().catchError((final _) {}));
  }

  static bool _listEquals(final List<String> a, final List<String> b) =>
      a.length == b.length && a.indexed.every((final e) => b[e.$1] == e.$2);

  /// Phase 1.5 — the human path: pick a workspace directory with the
  /// system dialog (the raw text field stays for power users). The picked
  /// path lands in the same field, so persistence stays exactly as today
  /// (the doc payload pins the workspace on delegate).
  Future<void> _pickWorkspace() async {
    String? path;
    try {
      path = await getDirectoryPath();
    } on Object catch (e) {
      setState(() => _pickError = '$e');
      return;
    }
    if (path == null || path.isEmpty) return; // user cancelled.
    final picked = path;
    setState(() {
      _pickError = null;
      _workspaceField.text = picked;
    });
  }

  Future<void> _delegate() async {
    final workspace = _workspaceField.text.trim();
    final task = _taskField.text.trim();
    if (workspace.isEmpty || task.isEmpty) return;
    // Messenger pattern: the sentence leaves the composer once accepted
    // (it renders as the turn's YOU row / queued row from here on).
    _taskField.clear();
    final current = _controller.current;
    await _syncConfigBeforeTurn();
    if (current == null || current.cwd != workspace) {
      await _controller.createSession(workspace);
    }
    // Pin the workspace into the doc payload (syncable doc data, ADR 0003).
    final agent = _doc.agent ?? const AgentDocModel();
    if (!agent.workspaces.contains(workspace)) {
      _persist(agent.copyWith(workspaces: [...agent.workspaces, workspace]));
    }
    await _controller.delegate(task);
  }

  // ---------------------------------------------------------------------
  // PLAN 9 — queue + cooled turns. The composer never blocks while a
  // turn runs (DESIGN §10: queued messages are visible and editable,
  // never "trusted to send"); steer is the default, send-now is explicit.
  // ---------------------------------------------------------------------

  /// Composer submit: while a turn RUNS the message joins the queue
  /// (steer by default; immediate = the explicit ⌘⏎ send-now — it stops
  /// the running turn and delivers first on the flush). While IDLE the
  /// submit sends immediately — today's behavior, byte for byte.
  Future<void> _submitFromComposer({final bool immediate = false}) async {
    // A composer submit is a user interaction with THIS doc — the
    // device-local focus follows it (ADR 0009 §Open questions 1).
    _markFocused();
    if (_controller.isRunning) {
      final task = _taskField.text.trim();
      if (task.isEmpty) return;
      _taskField.clear();
      _controller.enqueueSteer(task, immediate: immediate);
      setState(() {});
      return;
    }
    await _delegate();
  }

  void _beginQueuedEdit(final String stepId) {
    final step = _controller.queue.byId(stepId);
    if (step == null) return;
    _queueEditField.text = step.text;
    setState(() => _editingStepId = stepId);
  }

  void _commitQueuedEdit() {
    final id = _editingStepId;
    final text = _queueEditField.text.trim();
    setState(() {
      _editingStepId = null;
      _queueEditField.clear();
    });
    if (id == null || text.isEmpty) return;
    _controller.editQueued(id, text);
  }

  void _beginTurnEdit(final HarnessTurn turn) {
    _turnEditField.text = turn.taskSentence;
    setState(() => _editingTurnKey = turn.startedAt.microsecondsSinceEpoch);
  }

  void _commitTurnEdit(final HarnessTurn turn) {
    final text = _turnEditField.text.trim();
    setState(() {
      _editingTurnKey = null;
      _turnEditField.clear();
    });
    if (text.isEmpty) return;
    _controller.editCooledTurn(turn, text);
  }

  /// The reserved doc-payload blocks that carry the queue + per-turn edit
  /// history (durable, syncable; step-shaped per ADR 0011). One block per
  /// lane keeps further lanes additive (ADR 0011 D5).
  static const _queueBlockPrefix = 'queue-lane-';
  static const _turnHistoryBlockId = 'agent-turn-history';

  /// The deterministic block id of one lane's queue payload block:
  /// `queue-lane-<from>-to-<to>` — lanes additive (ADR 0011 D5).
  static String _queueLaneBlockId(final QueueStep step) {
    String sanitize(final String s) => s.toLowerCase().replaceAll(
      RegExp('[^a-z0-9]'),
      '_',
    );
    return '$_queueBlockPrefix${sanitize(step.from)}-to-${sanitize(step.to)}';
  }

  void _restoreQueueFromDoc() {
    final history = <int, List<String>>{};
    for (final block in _doc.blocks) {
      final id = block.id.value;
      if (id.startsWith(_queueBlockPrefix) && block.content.isNotEmpty) {
        try {
          _controller.queue.restoreJson(block.content);
        } on Object {
          // A corrupt payload block must never wedge the surface — the
          // live queue (empty at startup) stays the truth.
        }
      } else if (id == _turnHistoryBlockId && block.content.isNotEmpty) {
        try {
          final decoded = jsonDecode(block.content);
          if (decoded is Map<String, Object?> && decoded['turns'] is Map) {
            for (final entry
                in (decoded['turns']! as Map<Object?, Object?>).entries) {
              final key = int.tryParse('${entry.key}');
              if (key == null || entry.value is! List) continue;
              history[key] = [
                for (final v in entry.value! as List<Object?>) '$v',
              ];
            }
          }
        } on Object {
          // Same honesty: corrupt history is dropped, never fatal.
        }
      }
    }
    _controller.restoreTurnHistory(history);
  }

  /// Persists the queue + turn-edit history into the doc payload (called
  /// on every queue transition — user actions AND the flush pump's
  /// deliveries — via the controller listener).
  void _persistQueueState() {
    final controller = _controller;
    final lanes = <String, List<QueueStep>>{};
    for (final step in controller.queue.steps) {
      lanes.putIfAbsent('${step.from}→${step.to}', () => []).add(step);
    }
    final reserved = <DocBlockModel>[
      for (final lane in lanes.entries)
        DocBlockModel(
          id: DocBlockId(_queueLaneBlockId(lane.value.first)),
          type: DocBlockType.paragraph,
          content: jsonEncode({
            'from': lane.value.first.from,
            'to': lane.value.first.to,
            'steps': [for (final s in lane.value) s.toJson()],
          }),
        ),
      if (controller.turnHistory.isNotEmpty)
        DocBlockModel(
          id: const DocBlockId(_turnHistoryBlockId),
          type: DocBlockType.paragraph,
          content: _historyJson(controller),
        ),
    ];
    final kept = [
      for (final block in _doc.blocks)
        if (!block.id.value.startsWith(_queueBlockPrefix) &&
            block.id.value != _turnHistoryBlockId)
          block,
    ];
    final blocks = [...kept, ...reserved];
    if (blocks.length == _doc.blocks.length &&
        blocks.indexed.every((final e) => identical(e.$2, _doc.blocks[e.$1]))) {
      return; // nothing changed — no write, no listener noise.
    }
    _doc = _doc.copyWith(blocks: blocks);
    widget.onDocChanged?.call(_doc);
  }

  /// Controller listener: persist whenever the queue or the per-turn edit
  /// history changed — covers the flush pump's internal deliveries too.
  void _onControllerChanged() {
    final signature =
        '${_controller.queue.signature}|${_historyJson(_controller)}';
    if (signature == _queueSignature) return;
    _queueSignature = signature;
    _persistQueueState();
  }

  /// The turn-history JSON (string keys — JSON never carries int keys).
  String _historyJson(final HarnessSessionController controller) => jsonEncode({
    'turns': {
      for (final e in controller.turnHistory.entries) '${e.key}': e.value,
    },
  });

  Future<void> _switchBackend(final String backend) async {
    // Doc payload first (the doc is the source of truth for the binding —
    // ADR 0003): syncConfigBeforeTurn derives the daemon config from it.
    // Persisting after the async switch left a window where a concurrent
    // delegate saw the stale backend and reverted the switch (measured).
    final agent = _doc.agent ?? const AgentDocModel();
    if (agent.backend != backend) {
      _persist(agent.copyWith(backend: backend));
    }
    await _controller.switchBackend(
      _controller.config.copyWith(
        backend: backend,
        apiKey: backend == 'open_router' && _keyField.text.trim().isNotEmpty
            ? _keyField.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (final context, final _) {
        final current = _controller.current;
        final controller = _controller;
        AgentDocSurface.debugState = _projectState();
        return ColoredBox(
          color: theme.colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusRule(
                backend: controller.config.backend,
                workspace: _workspaceField.text.trim(),
                running: controller.isRunning,
                turnCount: current?.turns.length ?? 0,
                toolCount: current?.openTurn?.toolCalls.length ?? 0,
                setupOpen: _showSetup,
                profileOpen: _profileOpen,
                onToggleSetup: () => setState(() => _setupOpen = !_setupOpen),
                onToggleProfile: () =>
                    setState(() => _profileOpen = !_profileOpen),
                onOpenSetup: () => setState(() => _setupOpen = true),
                onCancel: controller.cancelCurrent,
              ),
              if (controller.error != null)
                _Banner(
                  key: const Key('coding_agent.error'),
                  text: 'error: ${controller.error}',
                  color: theme.colorScheme.errorContainer,
                ),
              if (_showSetup)
                _SetupPane(
                  workspaceField: _workspaceField,
                  checkField: _checkField,
                  keyField: _keyField,
                  backend: controller.config.backend,
                  busy: controller.isRunning,
                  pickError: _pickError,
                  onPick: _pickWorkspace,
                  onBackend: (final b) => unawaited(_switchBackend(b)),
                ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Conversation(
                        key: const Key('coding_agent.transcript'),
                        controller: controller,
                        docWorkspace: _workspaceField.text.trim(),
                        expandedBeats: _expandedBeats,
                        onToggleBeat: (final id) => setState(() {
                          _expandedBeats.contains(id)
                              ? _expandedBeats.remove(id)
                              : _expandedBeats.add(id);
                        }),
                        backend: controller.config.backend,
                        expandedTurnHistory: _expandedTurnHistory,
                        onToggleTurnHistory: (final key) => setState(() {
                          _expandedTurnHistory.contains(key)
                              ? _expandedTurnHistory.remove(key)
                              : _expandedTurnHistory.add(key);
                        }),
                        editingStepId: _editingStepId,
                        queueEditField: _queueEditField,
                        onBeginQueuedEdit: _beginQueuedEdit,
                        onCommitQueuedEdit: _commitQueuedEdit,
                        onCancelQueued: (final id) =>
                            _controller.cancelQueued(id),
                        onSendNowQueued: (final id) =>
                            _controller.sendNowQueued(id),
                        editingTurnKey: _editingTurnKey,
                        turnEditField: _turnEditField,
                        onBeginTurnEdit: _beginTurnEdit,
                        onCommitTurnEdit: _commitTurnEdit,
                      ),
                    ),
                    if (_profileOpen)
                      SizedBox(
                        width: 300,
                        child: _ProfilePane(
                          controller: controller,
                          routingError: _routingError,
                          onSetRouting: (final enabled) {
                            final result = setRemoteRouting(enabled: enabled);
                            if (!result.ok) {
                              setState(
                                () => _routingError =
                                    _routingError ?? result.message,
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              if (controller.pendingPermission != null)
                _PendingPermission(controller: controller),
              _Composer(
                taskField: _taskField,
                composerFocus: _composerFocus,
                running: _controller.isRunning,
                onSubmit: _submitFromComposer,
                onCancel: controller.cancelCurrent,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// The grid: one column rule, role gutter, monospace data. Tufte: ink is
// data — no cards, no bubbles, no decorative icons. Brockmann: everything
// aligns to the same gutter; hierarchy is typographic.
// ---------------------------------------------------------------------------

const _gutterWidth = 52.0;

TextStyle _label(final ThemeData theme) => theme.textTheme.labelSmall!.copyWith(
  fontSize: 9.5,
  letterSpacing: 1.2,
  color: theme.colorScheme.onSurfaceVariant,
  fontFeatures: const [FontFeature.tabularFigures()],
);

TextStyle _mono(final ThemeData theme, {final Color? color}) =>
    theme.textTheme.bodySmall!.copyWith(
      fontFamily: 'Menlo',
      fontFamilyFallback: const ['monospace'],
      fontSize: 11,
      height: 1.45,
      color: color ?? theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

class _Rule extends StatelessWidget {
  const _Rule();
  @override
  Widget build(final BuildContext context) =>
      Container(height: 0.6, color: Theme.of(context).dividerColor);
}

/// The top rule: binding, live state, and the two surface toggles. The
/// user is in control from one simple place — PROFILE / SETUP.
class _StatusRule extends StatelessWidget {
  const _StatusRule({
    required this.backend,
    required this.workspace,
    required this.running,
    required this.turnCount,
    required this.toolCount,
    required this.setupOpen,
    required this.profileOpen,
    required this.onToggleSetup,
    required this.onToggleProfile,
    required this.onOpenSetup,
    required this.onCancel,
  });

  final String backend;
  final String workspace;
  final bool running;
  final int turnCount;
  final int toolCount;
  final bool setupOpen;
  final bool profileOpen;
  final VoidCallback onToggleSetup;
  final VoidCallback onToggleProfile;
  final VoidCallback onOpenSetup;
  final VoidCallback onCancel;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final wsName = workspace.isEmpty
        ? 'no workspace'
        : workspace.split('/').where((p) => p.isNotEmpty).last;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text('AGENT', style: _label(theme)),
              const SizedBox(width: 10),
              _TextToggle(
                label: 'AFM',
                active: backend == 'apple_foundation_afm',
                onTap: onOpenSetup,
              ),
              const SizedBox(width: 6),
              _TextToggle(
                label: 'OR',
                active: backend == 'open_router',
                onTap: onOpenSetup,
              ),
              const SizedBox(width: 14),
              Flexible(
                child: InkWell(
                  onTap: onOpenSetup,
                  child: Text(
                    wsName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(
                      theme,
                      color: workspace.isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (running)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    'running · $toolCount tools',
                    style: _mono(theme),
                  ),
                ),
              _TextToggle(
                label: 'PROFILE',
                active: profileOpen,
                onTap: onToggleProfile,
                toggleKey: const Key('coding_agent.profile.toggle'),
              ),
              const SizedBox(width: 8),
              _TextToggle(
                label: 'SETUP',
                active: setupOpen,
                onTap: onToggleSetup,
                toggleKey: const Key('coding_agent.setup.toggle'),
              ),
            ],
          ),
        ),
        const _Rule(),
      ],
    );
  }
}

/// A quiet text toggle — underlined when active. No icons, no fills.
class _TextToggle extends StatelessWidget {
  const _TextToggle({
    required this.label,
    required this.active,
    required this.onTap,
    this.toggleKey,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Key? toggleKey;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      key: toggleKey,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: _label(theme).copyWith(
            color: active
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
            decoration: active ? TextDecoration.underline : null,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// SETUP — the binding pane, collapsed once bound. Grid rows: small-caps
/// label column, hairline-underline fields. Backend as plain text toggles.
class _SetupPane extends StatelessWidget {
  const _SetupPane({
    required this.workspaceField,
    required this.checkField,
    required this.keyField,
    required this.backend,
    required this.busy,
    required this.pickError,
    required this.onPick,
    required this.onBackend,
  });

  final TextEditingController workspaceField;
  final TextEditingController checkField;
  final TextEditingController keyField;
  final String backend;
  final bool busy;
  final String? pickError;
  final Future<void> Function() onPick;
  final ValueChanged<String> onBackend;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final underline = UnderlineInputBorder(
      borderSide: BorderSide(color: theme.dividerColor),
      borderRadius: BorderRadius.zero,
    );
    InputDecoration plain(final String hint) => InputDecoration(
      isDense: true,
      hintText: 'none',
      hintStyle: _mono(theme, color: theme.colorScheme.outline),
      enabledBorder: underline,
      focusedBorder: underline.copyWith(
        borderSide: BorderSide(color: theme.colorScheme.onSurface, width: 0.8),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              SizedBox(
                width: 84,
                child: Text('WORKSPACE', style: _label(theme)),
              ),
              Expanded(
                child: TextField(
                  key: const Key('coding_agent.workspace'),
                  controller: workspaceField,
                  enabled: !busy,
                  style: _mono(theme, color: theme.colorScheme.onSurface),
                  decoration: plain('/absolute/path/of/the/project'),
                ),
              ),
              IconButton(
                key: const Key('coding_agent.workspace.pick'),
                tooltip: 'Choose a workspace directory',
                onPressed: busy ? null : onPick,
                icon: const Icon(Icons.folder_open, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 84, child: Text('CHECK', style: _label(theme))),
              Expanded(
                child: TextField(
                  key: const Key('coding_agent.check'),
                  controller: checkField,
                  enabled: !busy,
                  style: _mono(theme, color: theme.colorScheme.onSurface),
                  decoration: plain('workspace convention decides'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 84, child: Text('RUNTIME', style: _label(theme))),
              _TextToggle(
                label: 'AFM · real work',
                active: backend == 'apple_foundation_afm',
                onTap: busy ? () {} : () => onBackend('apple_foundation_afm'),
              ),
              const SizedBox(width: 8),
              _TextToggle(
                label: 'OpenRouter · backup',
                active: backend == 'open_router',
                onTap: busy ? () {} : () => onBackend('open_router'),
              ),
              if (backend == 'open_router')
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TextField(
                      key: const Key('coding_agent.api_key'),
                      controller: keyField,
                      enabled: !busy,
                      obscureText: true,
                      style: _mono(theme, color: theme.colorScheme.onSurface),
                      decoration: plain('sk-or-… (or OPENROUTER_API_KEY)'),
                      onSubmitted: (_) => onBackend('open_router'),
                    ),
                  ),
                ),
            ],
          ),
          if (pickError != null)
            Text(
              'workspace picker: $pickError',
              key: const Key('coding_agent.pick_error'),
              style: _mono(theme, color: theme.colorScheme.error),
            ),
          const _Rule(),
        ],
      ),
    );
  }
}

/// The conversation: turns as small multiples on the role grid, newest at
/// the bottom (reverse list = bottom-anchored, messenger pattern).
class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.controller,
    required this.docWorkspace,
    required this.expandedBeats,
    required this.onToggleBeat,
    required this.backend,
    required this.expandedTurnHistory,
    required this.onToggleTurnHistory,
    required this.editingStepId,
    required this.queueEditField,
    required this.onBeginQueuedEdit,
    required this.onCommitQueuedEdit,
    required this.onCancelQueued,
    required this.onSendNowQueued,
    required this.editingTurnKey,
    required this.turnEditField,
    required this.onBeginTurnEdit,
    required this.onCommitTurnEdit,
    super.key,
  });

  final HarnessSessionController controller;
  final String docWorkspace;
  final Set<int> expandedBeats;
  final void Function(int id) onToggleBeat;
  final String backend;
  final Set<int> expandedTurnHistory;
  final void Function(int key) onToggleTurnHistory;
  final String? editingStepId;
  final TextEditingController queueEditField;
  final void Function(String stepId) onBeginQueuedEdit;
  final VoidCallback onCommitQueuedEdit;
  final void Function(String stepId) onCancelQueued;
  final void Function(String stepId) onSendNowQueued;
  final int? editingTurnKey;
  final TextEditingController turnEditField;
  final void Function(HarnessTurn turn) onBeginTurnEdit;
  final void Function(HarnessTurn turn) onCommitTurnEdit;

  @override
  Widget build(final BuildContext context) {
    final current = controller.current;
    final theme = Theme.of(context);
    final turns = current?.turns ?? const <HarnessTurn>[];
    final queued = controller.queue.openInLane().toList();
    return ListView(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      children: [
        // PLAN 9 — the queue rides the frontier (ADR 0011): queued rows
        // render as YOU rows with a dim STEER/NOW gutter annotation +
        // position + age — visible, editable, cancellable (DESIGN §10:
        // never "trusted to send"). Bottom-most, nearest the composer.
        for (final step in queued.reversed)
          _QueuedRow(
            step: step,
            position: controller.queue.positionOf(step),
            editing: editingStepId == step.id,
            editField: queueEditField,
            onBeginEdit: () => onBeginQueuedEdit(step.id),
            onCommitEdit: onCommitQueuedEdit,
            onCancel: () => onCancelQueued(step.id),
            onSendNow: () => onSendNowQueued(step.id),
          ),
        // PLAN 5c — remote permission rows (DESIGN §9): announced by the
        // owning device, visible AND answerable from this peer's flow —
        // same PERM row, same reject-first ordering, origin label in the
        // gutter. Never a modal, never a separate pane.
        for (final record in controller.remotePermissions)
          _RemotePermRow(
            record: record,
            originLabel: controller.originLabelOf(record),
            onAnswer: (final allow) => unawaited(
              controller.answerRemotePermission(record.requestId, allow: allow),
            ),
          ),
        if (controller.pendingPermission == null && (current?.running ?? false))
          const _LiveRow(),
        if (current?.hasVerdict ?? false)
          _VerdictRow(turn: current!.turns.last, showCard: true),
        for (final turn in turns.reversed) ...[
          _TurnView(
            turn: turn,
            backend: backend,
            expandedBeats: expandedBeats,
            onToggleBeat: onToggleBeat,
            editing: editingTurnKey == turn.startedAt.microsecondsSinceEpoch,
            editField: turnEditField,
            onBeginEdit: () => onBeginTurnEdit(turn),
            onCommitEdit: () => onCommitTurnEdit(turn),
            historyExpanded: expandedTurnHistory.contains(
              turn.startedAt.microsecondsSinceEpoch,
            ),
            onToggleHistory: () =>
                onToggleTurnHistory(turn.startedAt.microsecondsSinceEpoch),
          ),
          const SizedBox(height: 14),
        ],
        if (docWorkspace.trim().isEmpty && turns.isEmpty)
          const _EmptyStateGuide(key: Key('coding_agent.empty_state')),
        if (turns.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'conversations start here — the surface is text; every line '
              'is a node you and the agent share.',
              style: _mono(theme, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

/// One queued message (PLAN 9): a YOU row with a dim gutter annotation —
/// `STEER` (default) or `NOW` (explicit send-now) + lane position + age
/// (DESIGN §10: time made visible). In-flow, text-first actions: edit
/// (the row re-opens in place — it is just text), cancel (superseded —
/// queryable, never dropped), now (reject perm → stop turn → deliver
/// first). No cards, no bubbles, no filled buttons.
class _QueuedRow extends StatelessWidget {
  const _QueuedRow({
    required this.step,
    required this.position,
    required this.editing,
    required this.editField,
    required this.onBeginEdit,
    required this.onCommitEdit,
    required this.onCancel,
    required this.onSendNow,
  });

  final QueueStep step;
  final int position;
  final bool editing;
  final TextEditingController editField;
  final VoidCallback onBeginEdit;
  final VoidCallback onCommitEdit;
  final VoidCallback onCancel;
  final VoidCallback onSendNow;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final age = DateTime.now().difference(step.createdAt);
    final ageLabel = age.inMinutes < 1
        ? '<1m'
        : age.inHours < 1
        ? '${age.inMinutes}m'
        : '${age.inHours}h';
    final annotation = step.immediate ? 'NOW' : 'STEER';
    return Padding(
      key: Key('coding_agent.queue.row.${step.id}'),
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _gutterWidth,
                child: Text(
                  '$annotation $position · $ageLabel',
                  key: Key('coding_agent.queue.steer.${step.id}'),
                  style: _label(theme).copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: editing
                    ? CallbackShortcuts(
                        bindings: {
                          const SingleActivator(LogicalKeyboardKey.enter):
                              onCommitEdit,
                        },
                        child: TextField(
                          key: Key(
                            'coding_agent.queue.edit.field.${step.id}',
                          ),
                          controller: editField,
                          autofocus: true,
                          minLines: 1,
                          maxLines: 6,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          onSubmitted: (_) => onCommitEdit(),
                        ),
                      )
                    : Text(
                        step.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
              ),
            ],
          ),
          if (!editing)
            Padding(
              padding: const EdgeInsets.only(left: _gutterWidth, top: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    key: Key('coding_agent.queue.edit.${step.id}'),
                    onTap: onBeginEdit,
                    child: Text('[edit]', style: _mono(theme)),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    key: Key('coding_agent.queue.sendNow.${step.id}'),
                    onTap: onSendNow,
                    child: Text('[now]', style: _mono(theme)),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    key: Key('coding_agent.queue.cancel.${step.id}'),
                    onTap: onCancel,
                    child: Text(
                      '[cancel]',
                      style: _mono(
                        theme,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One turn — the small multiple. Role gutter + text column; tool beats
/// dim and monospace; tap a beat to expand it. COOLED turns (verdict
/// landed) are editable like document text: an edit adds a dim `EDITED`
/// SYS annotation with tap-to-expand prior versions (PLAN 9). Live turns
/// stay locked.
class _TurnView extends StatelessWidget {
  const _TurnView({
    required this.turn,
    required this.backend,
    required this.expandedBeats,
    required this.onToggleBeat,
    required this.editing,
    required this.editField,
    required this.onBeginEdit,
    required this.onCommitEdit,
    required this.historyExpanded,
    required this.onToggleHistory,
  });

  final HarnessTurn turn;
  final String backend;
  final Set<int> expandedBeats;
  final void Function(int id) onToggleBeat;
  final bool editing;
  final TextEditingController editField;
  final VoidCallback onBeginEdit;
  final VoidCallback onCommitEdit;
  final bool historyExpanded;
  final VoidCallback onToggleHistory;

  String get _agentRole => switch (backend) {
    'apple_foundation_afm' => 'AFM',
    'open_router' => 'OR',
    _ => 'AGT',
  };

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final turnKey = turn.startedAt.microsecondsSinceEpoch;
    final cooled = turn.isDone && !editing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GridRow(
          role: 'YOU',
          child: editing
              ? CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.enter):
                        onCommitEdit,
                  },
                  child: TextField(
                    key: Key('coding_agent.turn.edit.field.$turnKey'),
                    controller: editField,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 6,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    onSubmitted: (_) => onCommitEdit(),
                  ),
                )
              : SelectableText(
                  turn.taskSentence,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
        ),
        if (cooled)
          Padding(
            padding: const EdgeInsets.only(left: _gutterWidth, bottom: 2),
            child: InkWell(
              key: Key('coding_agent.turn.edit.$turnKey'),
              onTap: onBeginEdit,
              child: Text(
                '[edit]',
                style: _mono(theme, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        if (turn.edited)
          _GridRow(
            role: 'SYS',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  key: Key('coding_agent.turn.history.toggle.$turnKey'),
                  onTap: onToggleHistory,
                  child: Text(
                    'EDITED · ${turn.editHistory.length} prior '
                    '${turn.editHistory.length == 1 ? 'version' : 'versions'}',
                    style: _label(theme),
                  ),
                ),
                if (historyExpanded)
                  for (var i = 0; i < turn.editHistory.length; i++)
                    Padding(
                      key: Key('coding_agent.turn.history.$turnKey.$i'),
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        turn.editHistory[turn.editHistory.length - 1 - i],
                        style: _mono(theme),
                      ),
                    ),
              ],
            ),
          ),
        _GridRow(
          role: _agentRole,
          child: _TurnBody(
            turn: turn,
            expandedBeats: expandedBeats,
            onToggleBeat: onToggleBeat,
          ),
        ),
        if (turn.guidance != null)
          _GridRow(
            role: 'GUIDE',
            child: SelectableText(
              turn.guidance!,
              key: const Key('coding_agent.guidance'),
              style: _mono(theme, color: theme.colorScheme.onSurface),
            ),
          ),
      ],
    );
  }
}

/// The agent's stream, parsed into lines: prose, tool beats (dim mono),
/// escalation markers, and the verdict rule. This IS what the model said
/// and did — rendered on the grid, never re-chunked into bubbles.
class _TurnBody extends StatelessWidget {
  const _TurnBody({
    required this.turn,
    required this.expandedBeats,
    required this.onToggleBeat,
  });

  final HarnessTurn turn;
  final Set<int> expandedBeats;
  final void Function(int id) onToggleBeat;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];
    final prose = StringBuffer();
    var beatIndex = 0;

    void flushProse() {
      final text = prose.toString().trim();
      if (text.isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SelectableText(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        );
      }
      prose.clear();
    }

    for (final raw in turn.text.toString().split('\n')) {
      final line = raw.trimRight();
      if (line.isEmpty) continue;
      if (line.startsWith('delegated:')) continue; // the YOU row carries it
      if (line.startsWith('verdict:')) continue; // the verdict row carries it
      if (line.startsWith('— turn')) continue;
      if (line.startsWith('[')) {
        flushProse();
        final id = Object.hash(turn.startedAt, beatIndex++);
        children.add(
          _BeatLine(
            line: line,
            expanded: expandedBeats.contains(id),
            onTap: () => onToggleBeat(id),
          ),
        );
        continue;
      }
      prose.writeln(line);
    }
    flushProse();

    // Permission round-trips recorded on this turn. A remote answer is
    // recorded exactly like a local one — indistinguishable except by
    // the resolved origin label (ADR 0005 §5, DESIGN §9).
    for (final p in turn.permissions) {
      final origin = p.originLabel;
      children.add(
        _GridRow(
          role: 'PERM',
          child: Text(
            '${p.title}  →  ${switch (p.allowed) {
              true => 'allow',
              false => 'reject',
              null => 'awaiting…',
            }}${origin == null ? '' : ' · $origin'}',
            style: _mono(
              theme,
              color: p.allowed == false ? theme.colorScheme.error : null,
            ),
          ),
        ),
      );
    }
    // PLAN 9 — a cooled turn carries its own verdict as durable record:
    // the SYS card above is the session's LATEST verdict (attention row);
    // this one stays with the turn — including an interrupted turn's
    // honest partial spend — after later turns push the card off.
    if (turn.isDone) {
      children.add(_VerdictRow(turn: turn, showCard: false));
    }
    if (turn.toolCalls.isNotEmpty && turn.permissions.isEmpty) {
      // (tool calls already render as beats; nothing extra)
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// A tool beat: one quiet monospace line. Tap to expand (long payloads).
class _BeatLine extends StatelessWidget {
  const _BeatLine({
    required this.line,
    required this.expanded,
    required this.onTap,
  });

  final String line;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final name = RegExp(r'^\[([a-z_]+)\]').firstMatch(line)?.group(1) ?? '·';
    final payload = line.replaceFirst(RegExp(r'^\[[a-z_\-]+\]\s?'), '');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: Text(
                name,
                style: _mono(
                  theme,
                  color: theme.colorScheme.onSurfaceVariant,
                ).copyWith(fontSize: 10),
              ),
            ),
            Expanded(
              child: Text(
                expanded
                    ? payload
                    : (payload.length > 96
                          ? '${payload.substring(0, 96)}…'
                          : payload),
                maxLines: expanded ? null : 1,
                overflow: TextOverflow.ellipsis,
                style: _mono(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The verdict: one SYS row + one colored rule. The spend states its
/// source (backend verdict chunk) — Tufte: annotation, not decoration.
class _VerdictRow extends StatelessWidget {
  const _VerdictRow({required this.turn, required this.showCard});

  final HarnessTurn turn;
  final bool showCard;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final passed = turn.verdictPassed;
    // PLAN 9 — an interrupted turn's verdict lands with whatever partial
    // spend exists. The backend emits no spend figures on cancel, so the
    // row renders only what the client TRULY observed (beats + wall
    // time) — zeros and guesses are never fabricated (DESIGN §6).
    final interrupted = turn.interrupted;
    final color = interrupted
        ? theme.colorScheme.onSurfaceVariant
        : passed
        ? Colors.green.shade600
        : theme.colorScheme.error;
    final spend = turn.spend;
    final wallS = interrupted
        ? ((turn.completedAt ?? DateTime.now()).millisecondsSinceEpoch -
              turn.startedAt.millisecondsSinceEpoch) /
              1000
        : 0.0;
    final interruptedSpend = interrupted
        ? ' · ${turn.toolCalls.length} beats · '
              '${wallS.toStringAsFixed(1)}s'
        : '';
    return Container(
      key: showCard ? const Key('coding_agent.verdict.card') : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _gutterWidth - 2,
            child: Text('SYS', style: _label(theme)),
          ),
          Expanded(
            child: Text(
              spend == null
                  ? '${(turn.verdictLine ?? '').split('(').first.trim()}'
                        '$interruptedSpend'
                  : '${turn.verdictLine!.split('(').first.trim()} · '
                        'd${spend.decisions} r${spend.rounds} '
                        '${(spend.tokens / 1000).toStringAsFixed(1)}k tok '
                        '${(spend.wallMs / 1000).toStringAsFixed(1)}s',
              key: showCard ? const Key('coding_agent.verdict') : null,
              style: _mono(
                theme,
                color: color,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid row: role gutter + content. THE layout primitive.
class _GridRow extends StatelessWidget {
  const _GridRow({required this.role, required this.child});

  final String role;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _gutterWidth,
            child: Text(role, style: _label(theme)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Live pulse while a turn runs (honest: only what the host truly sees —
/// tool-beat count and elapsed wall time; spend lands with the verdict).
class _LiveRow extends StatelessWidget {
  const _LiveRow();

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return _GridRow(
      role: '···',
      child: Text(
        'running…',
        style: _mono(
          theme,
          color: theme.colorScheme.onSurfaceVariant,
        ).copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}

/// One REMOTE permission record on the peer's flow (DESIGN §9): the same
/// PERM row a local request gets — title, outcome, reject-first actions —
/// with the origin (roster-resolved actor, else the announcing device) as
/// the gutter label. Pending rows carry the actions; answered rows keep
/// the decision visible as data, never dropped.
class _RemotePermRow extends StatelessWidget {
  const _RemotePermRow({
    required this.record,
    required this.originLabel,
    required this.onAnswer,
  });

  final PermRequestRecord record;
  final String originLabel;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final pending = record.isPending;
    return Padding(
      key: Key('coding_agent.perm.${record.requestId}'),
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _gutterWidth,
            child: Text(
              originLabel,
              key: Key('coding_agent.perm.${record.requestId}.origin'),
              style: _label(theme).copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              '${record.title}  →  ${switch (record.status) {
                PermRequestStatus.pending => 'awaiting…',
                PermRequestStatus.allow => 'allow',
                PermRequestStatus.reject => 'reject',
              }}',
              style: _mono(
                theme,
                color: record.status == PermRequestStatus.reject
                    ? theme.colorScheme.error
                    : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (pending) ...[
            const SizedBox(width: 12),
            TextButton(
              key: Key('coding_agent.perm.${record.requestId}.reject'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 30),
              ),
              onPressed: () => onAnswer(false),
              child: Text('[reject]', style: _mono(theme)),
            ),
            const SizedBox(width: 6),
            TextButton(
              key: Key('coding_agent.perm.${record.requestId}.allow'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                minimumSize: const Size(0, 30),
              ),
              onPressed: () => onAnswer(true),
              child: Text('[allow]', style: _mono(theme)),
            ),
          ],
        ],
      ),
    );
  }
}

/// The pending permission, in flow — never a floating card. Deny first
/// (default), allow second; both are plain text actions on the grid.
class _PendingPermission extends StatelessWidget {
  const _PendingPermission({required this.controller});

  final HarnessSessionController controller;

  @override
  Widget build(final BuildContext context) {
    final pending = controller.pendingPermission!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('coding_agent.permission'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.error),
          bottom: BorderSide(color: theme.dividerColor, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _gutterWidth,
            child: Text('PERM', style: _label(theme)),
          ),
          Expanded(
            child: Text(
              pending.request.title,
              style: _mono(theme, color: theme.colorScheme.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            key: const Key('coding_agent.permission.reject'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 30),
            ),
            onPressed: () => controller.answerPermission(allow: false),
            child: Text('[reject]', style: _mono(theme)),
          ),
          const SizedBox(width: 6),
          TextButton(
            key: const Key('coding_agent.permission.allow'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              minimumSize: const Size(0, 30),
            ),
            onPressed: () => controller.answerPermission(allow: true),
            child: Text('[allow]', style: _mono(theme)),
          ),
        ],
      ),
    );
  }
}

/// The composer — messenger pattern, note-UI heritage: bottom-anchored,
/// autofocus, ⏎ delegates (⇧⏎ newline). The task sentence IS the input.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.taskField,
    required this.composerFocus,
    required this.running,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController taskField;
  final FocusNode composerFocus;
  final bool running;

  /// PLAN 9 — `immediate: false` = steer (queued while running, sent
  /// while idle); `immediate: true` = the explicit ⌘⏎ send-now.
  final Future<void> Function({required bool immediate}) onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Rule(),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: _gutterWidth - 8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text('YOU', style: _label(theme)),
                ),
              ),
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.enter): () =>
                        unawaited(onSubmit(immediate: false)),
                    // PLAN 9 — send-now: reject the pending permission →
                    // stop the running turn → the verdict lands with
                    // partial spend → this message becomes the new turn.
                    const SingleActivator(
                      LogicalKeyboardKey.enter,
                      meta: true,
                    ): () => unawaited(onSubmit(immediate: true)),
                  },
                  child: TextField(
                    key: const Key('coding_agent.task'),
                    controller: taskField,
                    focusNode: composerFocus,
                    minLines: 1,
                    maxLines: 6,
                    // PLAN 9 — the composer NEVER blocks while a turn
                    // runs: submitting queues the message (steer by
                    // default). Queued rows are visible + editable above.
                    autofocus: true,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration.collapsed(
                      hintText: running
                          ? 'running — ⏎ steers (queues after this turn), '
                                '⌘⏎ sends now'
                          : 'task sentence — ⏎ to delegate, ⇧⏎ newline',
                      hintStyle: _mono(theme),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (running) ...[
                TextButton(
                  key: const Key('coding_agent.queue.sendNow.composer'),
                  onPressed: () => unawaited(onSubmit(immediate: true)),
                  child: Text('send now \u2318\u23ce', style: _mono(theme)),
                ),
                const SizedBox(width: 6),
                TextButton(
                  key: const Key('coding_agent.cancel'),
                  onPressed: onCancel,
                  child: Text('stop', style: _mono(theme)),
                ),
              ] else
                TextButton(
                  key: const Key('coding_agent.delegate'),
                  // Always enabled when idle — validation (non-empty
                  // sentence + workspace) happens in the delegate path, NOT
                  // in build-time button state: text edits never rebuild
                  // this widget, so a computed guard would strand the
                  // button disabled after typing (measured).
                  onPressed: () => unawaited(onSubmit(immediate: false)),
                  child: Text('run \u23ce', style: _mono(theme)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// PROFILE — the honest profiler pane: what the host truly observes.
/// Context load (per-turn spend from the verdict line), permission log,
/// sessions, actors. Small multiples, monospace, no axes, no boxes.
class _ProfilePane extends StatefulWidget {
  const _ProfilePane({
    required this.controller,
    required this.onSetRouting,
    this.routingError,
  });

  final HarnessSessionController controller;

  /// Task H — remote permission routing toggle (DESIGN §4: one simple
  /// place, on the grid).
  final ValueChanged<bool> onSetRouting;
  final String? routingError;

  @override
  State<_ProfilePane> createState() => _ProfilePaneState();
}

class _ProfilePaneState extends State<_ProfilePane> {
  final _nameField = TextEditingController();
  final _brainField = TextEditingController();
  final _roleField = TextEditingController();
  ActorKind _kind = ActorKind.model;
  bool _adding = false;

  @override
  void dispose() {
    _nameField.dispose();
    _brainField.dispose();
    _roleField.dispose();
    super.dispose();
  }

  /// Commits the in-flow add. Validation happens HERE — the action path —
  /// never as build-time field state (DESIGN forbidden list). Empty name
  /// simply does nothing; the form stays open.
  void _commit() {
    final name = _nameField.text.trim();
    if (name.isEmpty) return;
    final roster = widget.controller.roster;
    roster.upsert(
      ActorProfile(
        actorId: roster.newActorId(name),
        displayName: name,
        kind: _kind,
        brainRef: _brainField.text.trim(),
        role: _roleField.text.trim(),
      ),
    );
    _closeForm();
  }

  void _closeForm() {
    _nameField.clear();
    _brainField.clear();
    _roleField.clear();
    setState(() {
      _kind = ActorKind.model;
      _adding = false;
    });
  }

  @override
  Widget build(final BuildContext context) {
    final controller = widget.controller;
    final theme = Theme.of(context);
    final current = controller.current;
    final roster = controller.roster;
    final turns = current?.turns ?? const <HarnessTurn>[];
    var totalDecisions = 0;
    var totalTokens = 0;
    for (final turn in turns) {
      final s = turn.spend;
      if (s != null) {
        totalDecisions += s.decisions;
        totalTokens += s.tokens;
      }
    }
    return DecoratedBox(
      key: const Key('coding_agent.profile'),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.dividerColor)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('CONTEXT LOAD', style: _label(theme)),
          const SizedBox(height: 6),
          Text(
            'turns ${turns.length} · decisions $totalDecisions · '
            '${(totalTokens / 1000).toStringAsFixed(1)}k tok'
            '${current == null ? '' : ' · ${current.transcript.length} chars'}',
            style: _mono(theme, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < turns.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _TurnStatRow(index: i + 1, turn: turns[i]),
            ),
          if (turns.isEmpty) Text('no turns yet', style: _mono(theme)),
          const SizedBox(height: 14),
          Text('PERMISSIONS', style: _label(theme)),
          const SizedBox(height: 6),
          if (turns.every((final t) => t.permissions.isEmpty))
            Text('none asked', style: _mono(theme)),
          for (final turn in turns)
            for (final p in turn.permissions)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${_hm(p.at)}  ${p.allowed == null
                      ? '·  '
                      : p.allowed!
                      ? '✓  '
                      : '✕  '}'
                  '${p.title}',
                  style: _mono(
                    theme,
                    color: p.allowed == false ? theme.colorScheme.error : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          const SizedBox(height: 14),
          // Task H — ROUTING (ADR 0005 §5, DESIGN §4): remote permission
          // routing as one text toggle on the grid. OFF is the honest
          // default: answering stays local, nothing is written. A
          // failed enable surfaces in-flow with the cause named (§7).
          Text('ROUTING', style: _label(theme)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'remote permission routing — pending round-trips '
                  'answerable from paired peers',
                  style: _mono(theme),
                ),
              ),
              _TextToggle(
                label: controller.remotePermissionRouting ? '[on]' : '[off]',
                active: controller.remotePermissionRouting,
                onTap: () => widget.onSetRouting(
                  !controller.remotePermissionRouting,
                ),
                toggleKey: const Key('coding_agent.routing.toggle'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              controller.remotePermissionRouting
                  ? 'policy on — announced as doc ops'
                  : 'policy off — answering stays local',
              key: const Key('coding_agent.routing.status'),
              style: _mono(theme, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          if (widget.routingError != null)
            Text(
              'routing: ${widget.routingError}',
              key: const Key('coding_agent.routing.error'),
              style: _mono(theme, color: theme.colorScheme.error),
            ),
          const SizedBox(height: 14),
          Text('SESSIONS', style: _label(theme)),
          const SizedBox(height: 6),
          // ADR 0006 registry on one grid: workspaces as small-caps
          // section labels, sessions as indented small multiples, a quiet
          // "+ new" row per workspace. No boxes, no avatars (DESIGN §3/§9).
          if (controller.workspaces.isEmpty)
            Text('no workspace bound', style: _mono(theme)),
          for (var i = 0; i < controller.workspaces.length; i++) ...[
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6, bottom: 2),
              child: Text(
                controller.workspaces[i].cwd
                    .split('/')
                    .where((p) => p.isNotEmpty)
                    .last
                    .toUpperCase(),
                style: _label(theme),
                key: Key('coding_agent.workspace.$i'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            for (final session in controller.workspaces[i].sessions) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: InkWell(
                  key: Key('coding_agent.session.${session.viewId}'),
                  onTap: () => controller.selectSession(session),
                  child: Text(
                    '${session == controller.current ? '▸ ' : '  '}'
                    '${session.id} · '
                    '${session.turns.length} '
                    '${session.turns.length == 1 ? 'turn' : 'turns'}',
                    style: _mono(theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // ADR 0007 §4 — session rows list their actors: the
              // registry's `Actors[]` resolved through the roster, as the
              // small-caps gutter vocabulary (DESIGN §9). No avatars.
              if (session.actors(roster) case final actors
                  when actors.isNotEmpty)
                Padding(
                  key: Key('coding_agent.session.${session.viewId}.actors'),
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '    ${actors.map((final a) => a.gutterLabel).join('  ')}',
                    style: _label(theme).copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: InkWell(
                key: Key('coding_agent.workspace.$i.new'),
                onTap: () => unawaited(
                  controller.openNewSession(controller.workspaces[i].cwd),
                ),
                child: Text(
                  '  + new session',
                  style: _mono(
                    theme,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          // ADR 0007 §4 — the ACTORS section: roster entries as small
          // multiples on the grid (small-caps name = the gutter label,
          // kind · brain · role in mono). Add/remove in flow — no cards,
          // no chips, no forms-as-pages (DESIGN §4).
          Text('ACTORS', style: _label(theme)),
          const SizedBox(height: 6),
          if (roster.isEmpty && !_adding) ...[
            Text(
              'no actors yet. two steps:',
              style: _mono(theme, color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              '1. add an actor — a model, an agent runtime, or yourself.',
              style: _mono(theme, color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              '2. actors recur across sessions; their names join the '
              'gutter labels.',
              style: _mono(theme, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          for (final profile in roster.all)
            _ActorRow(
              profile: profile,
              onRemove: () {
                roster.remove(profile.actorId);
                setState(() {});
              },
            ),
          if (_adding) ...[
            _ActorFieldRow(
              label: 'NAME',
              fieldKey: const Key('coding_agent.actors.name'),
              controller: _nameField,
              hint: 'display name',
              onCommit: _commit,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text('KIND', style: _label(theme)),
                  ),
                  _TextToggle(
                    label: 'model',
                    active: _kind == ActorKind.model,
                    onTap: () => setState(() => _kind = ActorKind.model),
                    toggleKey: const Key('coding_agent.actors.kind.model'),
                  ),
                  const SizedBox(width: 6),
                  _TextToggle(
                    label: 'agent',
                    active: _kind == ActorKind.agent,
                    onTap: () => setState(() => _kind = ActorKind.agent),
                    toggleKey: const Key('coding_agent.actors.kind.agent'),
                  ),
                  const SizedBox(width: 6),
                  _TextToggle(
                    label: 'human',
                    active: _kind == ActorKind.human,
                    onTap: () => setState(() => _kind = ActorKind.human),
                    toggleKey: const Key('coding_agent.actors.kind.human'),
                  ),
                ],
              ),
            ),
            _ActorFieldRow(
              label: 'BRAIN',
              fieldKey: const Key('coding_agent.actors.brain'),
              controller: _brainField,
              hint: 'backend / model identity',
              onCommit: _commit,
            ),
            _ActorFieldRow(
              label: 'ROLE',
              fieldKey: const Key('coding_agent.actors.role'),
              controller: _roleField,
              hint: 'role — e.g. coder',
              onCommit: _commit,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Row(
                children: [
                  InkWell(
                    key: const Key('coding_agent.actors.confirm'),
                    onTap: _commit,
                    child: Text('[add]', style: _mono(theme)),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    key: const Key('coding_agent.actors.cancel'),
                    onTap: _closeForm,
                    child: Text(
                      '[cancel]',
                      style: _mono(
                        theme,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: InkWell(
                key: const Key('coding_agent.actors.add'),
                onTap: () => setState(() => _adding = true),
                child: Text(
                  '+ add actor',
                  style: _mono(
                    theme,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One roster entry — the small multiple: the gutter-vocabulary name,
/// the kind · brain · role line, and a quiet in-flow remove.
class _ActorRow extends StatelessWidget {
  const _ActorRow({required this.profile, required this.onRemove});

  final ActorProfile profile;
  final VoidCallback onRemove;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final detail = [
      if (profile.brainRef.isNotEmpty) profile.brainRef,
      if (profile.role.isNotEmpty) profile.role,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.gutterLabel,
                  key: Key('coding_agent.actors.${profile.actorId}'),
                  style: _label(theme).copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                key: Key('coding_agent.actors.${profile.actorId}.remove'),
                onTap: onRemove,
                child: Text(
                  '[remove]',
                  style: _mono(
                    theme,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          Text(
            detail.isEmpty
                ? profile.kind.name
                : '${profile.kind.name} · $detail',
            style: _mono(theme),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// One inline add-form row: small-caps label column + hairline-underline
/// field (same discipline as SETUP). ⏎ commits.
class _ActorFieldRow extends StatelessWidget {
  const _ActorFieldRow({
    required this.label,
    required this.fieldKey,
    required this.controller,
    required this.hint,
    required this.onCommit,
  });

  final String label;
  final Key fieldKey;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onCommit;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final underline = UnderlineInputBorder(
      borderSide: BorderSide(color: theme.dividerColor),
      borderRadius: BorderRadius.zero,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(label, style: _label(theme))),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              style: _mono(theme, color: theme.colorScheme.onSurface),
              onSubmitted: (_) => onCommit(),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                hintStyle: _mono(theme, color: theme.colorScheme.outline),
                enabledBorder: underline,
                focusedBorder: underline.copyWith(
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface,
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One small multiple in the profile: index, verdict, spend, task snippet.
class _TurnStatRow extends StatelessWidget {
  const _TurnStatRow({required this.index, required this.turn});

  final int index;
  final HarnessTurn turn;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final spend = turn.spend;
    final state = turn.hasVerdict
        ? turn.interrupted
              ? 'INT'
              : turn.verdictPassed
              ? 'PASS'
              : 'FAIL'
        : '···';
    final color = turn.hasVerdict
        ? turn.interrupted
              ? theme.colorScheme.onSurfaceVariant
              : turn.verdictPassed
              ? Colors.green.shade600
              : theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '#$index $state'
        '${spend == null ? '' : '  d${spend.decisions} r${spend.rounds} '
                  '${(spend.tokens / 1000).toStringAsFixed(1)}k '
                  '${(spend.wallMs / 1000).toStringAsFixed(0)}s'}'
        '  ${turn.toolCalls.length} beats'
        '\n   ${_taskSnippet(turn)}',
        style: _mono(theme, color: color),
      ),
    );
  }

  static String _taskSnippet(final HarnessTurn turn) {
    final task = turn.taskSentence.replaceAll('\n', ' ');
    return task.length > 64 ? '${task.substring(0, 64)}…' : task;
  }
}

String _hm(final DateTime at) =>
    '${at.hour.toString().padLeft(2, '0')}:'
    '${at.minute.toString().padLeft(2, '0')}';

/// The agent/intent projection of the surface state (canonical, typed —
/// an agent parses this, never a screenshot).
final class AgentDocDebugState {
  const AgentDocDebugState({
    required this.docId,
    required this.workspaces,
    required this.backend,
    this.checkCommand = const [],
    this.runtimeProfile = 'meaning',
    this.sessionId,
    this.running = false,
    this.pendingPermissionTitle,
    this.verdict,
    this.transcriptTail = '',
    this.turnCount = 0,
    this.lastGuidance,
    this.actors = const [],
    this.sessionActors = const {},
    this.remotePermissions = const [],
    this.remotePermissionRouting = false,
    this.meshStatus,
    this.queue = const [],
    this.viewer = false,
  });

  final String docId;
  final List<String> workspaces;

  /// The bound check override (the doc's `--check`, ADR 0003) — empty = the
  /// workspace convention decides.
  final List<String> checkCommand;
  final String backend;

  /// R9.1 — which tool surface the runtime speaks: `meaning` (zoom cuts,
  /// edit moves — the AFM path) or `commands` (conventional, CLI squad
  /// members only).
  final String runtimeProfile;
  final String? sessionId;
  final bool running;
  final String? pendingPermissionTitle;
  final String? verdict;
  final String transcriptTail;
  final int turnCount;

  /// R9.a — escalation guidance carried by the latest turn (null when the
  /// last turn was not guided).
  final String? lastGuidance;

  /// ADR 0007 — the roster (one state, many projections, DESIGN §5): the
  /// agent reads the same actor identities the PROFILE pane renders.
  final List<ActorProfile> actors;

  /// ADR 0006 registry `Actors[]`: session view id → attached actor ids.
  final Map<String, List<String>> sessionActors;

  /// PLAN 5c — remote permission records announced by OTHER peers
  /// (pending and answered): the same doc state the peer's flow renders
  /// (one state, many projections, DESIGN §5) — an agent reads who is
  /// asking, from where, and what has been decided.
  final List<PermRequestRecord> remotePermissions;

  /// Task H — whether remote permission routing is enabled (the PROFILE
  /// toggle's state, projected for the agent — DESIGN §5).
  final bool remotePermissionRouting;

  /// Task H — the mesh status of this device relative to the open doc:
  /// hosting / connected / peer count / presence count. Null when the app
  /// wiring is not installed (mesh never set up) — an agent reads the
  /// same status rule data the human sees (DESIGN §5/§9).
  final AgentDocMeshStatus? meshStatus;

  /// PLAN 9 — the queue state (ADR 0011): every step — open (with lane
  /// position + age), superseded (cancelled, queryable), delivered — the
  /// same queue the grid renders (DESIGN §5: one state, many projections).
  final List<AgentDocQueueEntry> queue;

  /// Task O — the honest viewer marker (DESIGN §6: label what the host
  /// sees vs what the peer observes). False on the host (it owns the
  /// world); true on a peer's SHADOW doc (`mesh_open_doc`): the peer
  /// observes the shared doc and answers routed permissions — it binds no
  /// workspace and runs no daemon session.
  final bool viewer;

  Map<String, Object?> toJson() => {
    'docId': docId,
    'workspaces': workspaces,
    'checkCommand': checkCommand,
    'backend': backend,
    'runtimeProfile': runtimeProfile,
    'sessionId': ?sessionId,
    'running': running,
    'pendingPermissionTitle': ?pendingPermissionTitle,
    'verdict': ?verdict,
    'turnCount': turnCount,
    'lastGuidance': ?lastGuidance,
    'actors': [for (final a in actors) a.toJson()],
    'sessionActors': sessionActors,
    'remotePermissions': [for (final p in remotePermissions) p.toJson()],
    'remotePermissionRouting': remotePermissionRouting,
    if (meshStatus != null) 'meshStatus': meshStatus!.toJson(),
    'queue': [for (final q in queue) q.toJson()],
    'viewer': viewer,
    'transcriptTail': transcriptTail.length > 4000
        ? '${transcriptTail.substring(0, 4000)}…'
        : transcriptTail,
  };
}

/// PLAN 9 — one queue step in the projection: lane key `(from, to)`
/// (ADR 0011 D5), step status (`open | superseded | delivered`), the
/// claim text, and — for open steps — the 1-based position in the lane
/// and the age (DESIGN §10: time made visible).
final class AgentDocQueueEntry {
  const AgentDocQueueEntry({
    required this.id,
    required this.text,
    required this.status,
    required this.from,
    required this.to,
    required this.immediate,
    required this.createdAtMs,
    this.position,
    this.ageMs,
  });

  final String id;
  final String text;
  final String status;
  final String from;
  final String to;
  final bool immediate;
  final int createdAtMs;

  /// 1-based position among the lane's open steps; null when superseded
  /// or delivered (no longer in the rendered queue).
  final int? position;
  final int? ageMs;

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'status': status,
    'from': from,
    'to': to,
    'immediate': immediate,
    'createdAtMs': createdAtMs,
    'position': ?position,
    'ageMs': ?ageMs,
  };
}

/// Task H — the mesh status of THIS device relative to one doc's channel
/// (what the status rule reports, DESIGN §9: connection truth in tabular
/// mono). Honest by construction: every value is read from the live mesh
/// replica; when the replica is not open, the wiring reports the zeros.
final class AgentDocMeshStatus {
  const AgentDocMeshStatus({
    this.hosting = false,
    this.connected = false,
    this.peerCount = 0,
    this.presenceCount = 0,
  });

  /// Whether this device hosts the relay ("main device").
  final bool hosting;

  /// Whether the replica has a transport connected.
  final bool connected;

  /// Registered peers on the replica.
  final int peerCount;

  /// Live presence entries on the doc's channel ("who is here" right
  /// now — [MeshStorageService.presence]).
  final int presenceCount;

  Map<String, Object?> toJson() => {
    'hosting': hosting,
    'connected': connected,
    'peerCount': peerCount,
    'presenceCount': presenceCount,
  };
}

/// Task O — the peer-side SHADOW agent doc (T3 gate, DESIGN §6): what a
/// paired peer projects when it OPENS a shared doc it does not own. No
/// workspace, no daemon session — the host owns the world; the peer is a
/// viewer/answerer:
///
/// - `agent_doc_state` falls back to this projection when no real surface
///   is open, so the peer's state stops being an error envelope and
///   carries the SHARED doc id, live mesh status, and the routed
///   permission round-trips folded into the shared replica;
/// - `agent_permission_answer` routes through [router] — the answer is a
///   doc op on the SAME `perm/<requestId>` register; the host's future
///   completes when the answer op folds back with the next sync cycle.
final class AgentDocShadow {
  AgentDocShadow({
    required this.docId,
    required this.meshDocId,
    required this.router,
    this.roster,
    final AgentDocMeshStatus Function(String channel)? statusFor,
  }) : statusFor =
           statusFor ??
           // Default: the wiring when installed, else the honest zeros —
           // a shadow with no reachable service must not fabricate a mesh.
           ((final channel) =>
               AgentDocSurface.meshWiring?.statusFor(channel) ??
               const AgentDocMeshStatus());

  /// The SHARED project doc id — the exact id the host's surface reports
  /// (the doc channel derives from it: `agent-<docId>`).
  final String docId;

  /// The deterministic mesh replica id of the shared doc (`agent-<docId>`
  /// — the channel the host's surface joins on open).
  final String meshDocId;

  /// The peer's doc channel over the mesh-attached [DocReplicaStore]:
  /// `pendingRemote` is what the peer may answer, `remoteEntries` what it
  /// renders (one state, many projections, DESIGN §5).
  final PermissionDocRouter router;

  /// The device's synced roster — origin labels resolve through it when
  /// one is available (ADR 0007: identity, never authority).
  final ActorRoster? roster;

  /// Reads the live mesh status for a doc channel. The app wiring takes
  /// precedence when installed; the fallback (what `mesh_open_doc`
  /// installs from the live service) keeps the projection self-sufficient
  /// — the shadow must carry hosting/connected/peers/presence either way.
  final AgentDocMeshStatus Function(String channel) statusFor;

  /// The viewer projection. Honest by construction: session-owned fields
  /// (sessionId, turns, transcript) stay empty — the peer runs no daemon
  /// session; turn ops are not yet synced (v1), so `turnCount` is 0.
  AgentDocDebugState toDebugState() => AgentDocDebugState(
    docId: docId,
    // Viewer markers: no workspace is bound (DESIGN §6), no check
    // override, and the runtime profile is the doc surface's default —
    // the peer runs no daemon of its own.
    workspaces: const [],
    backend: const HarnessHostConfig().backend,
    pendingPermissionTitle: router.pendingRemote().firstOrNull?.title,
    remotePermissions: router.remoteEntries(),
    meshStatus: statusFor(meshDocId),
    actors: roster?.all ?? const [],
    viewer: true,
  );

  /// Task O (P1) — answers the FIRST pending REMOTE permission through
  /// the doc (reject-first is the law; deny-by-default preserved). The
  /// answer op lands in the shared replica; the host's future completes
  /// when it folds back with the next mesh sync cycle.
  Future<({bool ok, String message})> answerRemotePermission({
    required final bool allow,
  }) async {
    final pending = router.pendingRemote().firstOrNull;
    if (pending == null) {
      return (
        ok: false,
        message: 'no pending remote permission request.',
      );
    }
    try {
      await router.answerRequest(requestId: pending.requestId, allow: allow);
    } on Object catch (error) {
      return (ok: false, message: 'remote permission answer refused: $error');
    }
    return (
      ok: true,
      message:
          '${allow ? 'allowed' : 'rejected'}: ${pending.title} '
          '(the answer ships as a doc op with the next sync cycle).',
    );
  }
}

/// Task H — the app wiring contract between the doc surface and the live
/// mesh replica (installed by the app shell; see
/// [AgentDocSurface.meshWiring]).
final class AgentDocMeshWiring {
  const AgentDocMeshWiring({
    required this.routerFor,
    required this.joinDoc,
    required this.leaveDoc,
    required this.statusFor,
  });

  /// Builds the doc channel for remote permission routing over the
  /// mesh-attached [DocReplicaStore]. Throws when the mesh replica is not
  /// live on this device — the surface surfaces the failure in-flow.
  final PermissionDocRouter Function(NodeId docId) routerFor;

  /// Joins [docId]'s presence channel (doc opened).
  final Future<void> Function(String docId) joinDoc;

  /// Leaves [docId]'s presence channel (doc closed).
  final Future<void> Function(String docId) leaveDoc;

  /// Reads the mesh status for [docId]'s channel.
  final AgentDocMeshStatus Function(String docId) statusFor;
}

/// The honest empty state (Phase 1.5): an agent doc with no bound
/// workspace instructs the human — quiet numbered lines on the grid.
class _EmptyStateGuide extends StatelessWidget {
  const _EmptyStateGuide({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: DefaultTextStyle(
        style: _mono(theme, color: muted),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 3,
          children: [
            Text('Bind a workspace to start — open SETUP above. Four steps:'),
            Text('1. Pick a project directory — the agent works ONLY there.'),
            Text(
              '2. Write the task as ONE sentence that names the file and '
              'what “done” means.',
            ),
            Text(
              '3. Every write the agent makes asks you first — allow or '
              'reject; rejecting means the change never lands.',
            ),
            Text(
              '4. When the turn ends, the verdict (PASS/FAIL) lands in the '
              'SYS line — with decisions, rounds, tokens, wall time.',
            ),
          ],
        ),
      ),
    );
  }
}

final class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.color, super.key});

  final String text;
  final Color color;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        text,
        style: _mono(theme, color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}
