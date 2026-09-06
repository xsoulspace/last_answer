import 'dart:async';

import 'package:core/core.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';

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

  /// R9.a — app wiring for the `agent_doc_create` intent: creates a NEW
  /// agent doc AND opens it (the `OpenedProjectNotifier.createAgentProject`
  /// path, including the route push), returning the created doc. Installed
  /// by the app shell in debug/profile builds only (same guard that
  /// registers the MCP entries); headless drivers need create+open as ONE
  /// verb — a form fill cannot do it (Phase-1.5 measurement).
  static ProjectModelDoc Function()? createAgentProjectHook;

  @override
  State<AgentDocSurface> createState() => _AgentDocSurfaceState();
}

class _AgentDocSurfaceState extends State<AgentDocSurface> {
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

  @override
  void initState() {
    super.initState();
    AgentDocSurface.debugSurface = this;
    _workspaceField.text = _doc.agent?.workspaces.firstOrNull ?? '';
    _checkField.text = _doc.agent?.checkCommand.join(' ') ?? '';
    // Listen to the controller, NOT onChanged: programmatic/semantic value
    // injection (agent fill_form, paste) never fires onChanged, and the
    // override silently failed to reach the daemon in the Phase-1.5 GUI
    // run (measured). Controller edits fire this for typing AND fill.
    _checkField.addListener(_onCheckChanged);
    unawaited(_controller.ensureStarted());
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
    if (_controller.pendingPermission == null) {
      return (ok: false, message: 'no pending permission request.');
    }
    _controller.answerPermission(allow: allow);
    return (ok: true, message: allow ? 'allowed' : 'rejected');
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
    _checkField.removeListener(_onCheckChanged);
    if (_ownsController) _controller.dispose();
    _workspaceField.dispose();
    _taskField.dispose();
    _keyField.dispose();
    _checkField.dispose();
    _composerFocus.dispose();
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
        final controller = _controller;
        final current = controller.current;
        String? lastGuidance;
        for (final turn in (current?.turns ?? const <HarnessTurn>[]).reversed) {
          if (turn.guidance != null) {
            lastGuidance = turn.guidance;
            break;
          }
        }
        AgentDocSurface.debugState = AgentDocDebugState(
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
          verdict: current?.verdictLine,
          transcriptTail: current?.transcript.toString() ?? '',
          turnCount: current?.turns.length ?? 0,
          lastGuidance: lastGuidance,
        );
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
                      ),
                    ),
                    if (_profileOpen)
                      SizedBox(
                        width: 300,
                        child: _ProfilePane(controller: controller),
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
                onDelegate: _delegate,
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
    super.key,
  });

  final HarnessSessionController controller;
  final String docWorkspace;
  final Set<int> expandedBeats;
  final void Function(int id) onToggleBeat;
  final String backend;

  @override
  Widget build(final BuildContext context) {
    final current = controller.current;
    final theme = Theme.of(context);
    final turns = current?.turns ?? const <HarnessTurn>[];
    return ListView(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      children: [
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

/// One turn — the small multiple. Role gutter + text column; tool beats
/// dim and monospace; tap a beat to expand it.
class _TurnView extends StatelessWidget {
  const _TurnView({
    required this.turn,
    required this.backend,
    required this.expandedBeats,
    required this.onToggleBeat,
  });

  final HarnessTurn turn;
  final String backend;
  final Set<int> expandedBeats;
  final void Function(int id) onToggleBeat;

  String get _agentRole => switch (backend) {
    'apple_foundation_afm' => 'AFM',
    'open_router' => 'OR',
    _ => 'AGT',
  };

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GridRow(
          role: 'YOU',
          child: SelectableText(
            turn.taskSentence,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
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

    // Permission round-trips recorded on this turn.
    for (final p in turn.permissions) {
      children.add(
        _GridRow(
          role: 'PERM',
          child: Text(
            '${p.title}  →  ${switch (p.allowed) {
              true => 'allow',
              false => 'reject',
              null => 'awaiting…',
            }}',
            style: _mono(
              theme,
              color: p.allowed == false ? theme.colorScheme.error : null,
            ),
          ),
        ),
      );
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
    final color = passed ? Colors.green.shade600 : theme.colorScheme.error;
    final spend = turn.spend;
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
                  ? (turn.verdictLine ?? '')
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
    required this.onDelegate,
    required this.onCancel,
  });

  final TextEditingController taskField;
  final FocusNode composerFocus;
  final bool running;
  final Future<void> Function() onDelegate;
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
                        unawaited(onDelegate()),
                  },
                  child: TextField(
                    key: const Key('coding_agent.task'),
                    controller: taskField,
                    focusNode: composerFocus,
                    minLines: 1,
                    maxLines: 6,
                    enabled: !running,
                    autofocus: true,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration.collapsed(
                      hintText: running
                          ? 'running — the turn is on the grid above'
                          : 'task sentence — ⏎ to delegate, ⇧⏎ newline',
                      hintStyle: _mono(theme),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (running)
                TextButton(
                  key: const Key('coding_agent.cancel'),
                  onPressed: onCancel,
                  child: Text('stop', style: _mono(theme)),
                )
              else
                TextButton(
                  key: const Key('coding_agent.delegate'),
                  // Always enabled when idle — validation (non-empty
                  // sentence + workspace) happens in the delegate path, NOT
                  // in build-time button state: text edits never rebuild
                  // this widget, so a computed guard would strand the
                  // button disabled after typing (measured).
                  onPressed: () => unawaited(onDelegate()),
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
/// sessions. Small multiples, monospace, no axes, no boxes.
class _ProfilePane extends StatelessWidget {
  const _ProfilePane({required this.controller});

  final HarnessSessionController controller;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final current = controller.current;
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
            for (final session in controller.workspaces[i].sessions)
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
        ? (turn.verdictPassed ? 'PASS' : 'FAIL')
        : '···';
    final color = turn.hasVerdict
        ? (turn.verdictPassed ? Colors.green.shade600 : theme.colorScheme.error)
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
    'transcriptTail': transcriptTail.length > 4000
        ? '${transcriptTail.substring(0, 4000)}…'
        : transcriptTail,
  };
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
