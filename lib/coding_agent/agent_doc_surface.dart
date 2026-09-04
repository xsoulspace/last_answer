import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';

/// ADR 0003 (Phase 1) — the agent-doc surface: the coding-agent machinery
/// bound to a `ProjectModel.doc` (formatId: `agent`). The document carries
/// the durable, syncable data (workspace set, backend, check override); the
/// world snapshots stay device-local in the workspace.
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

  @override
  void initState() {
    super.initState();
    _workspaceField.text = _doc.agent?.workspaces.firstOrNull ?? '';
    unawaited(_controller.ensureStarted());
  }

  HarnessHostConfig _configFor(final ProjectModelDoc doc) {
    final base = widget.config ?? const HarnessHostConfig();
    final agent = doc.agent ?? const AgentDocModel();
    return base.copyWith(
      backend: agent.backend,
      checkCommand: agent.checkCommand.isEmpty ? null : agent.checkCommand,
    );
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    _workspaceField.dispose();
    _taskField.dispose();
    _keyField.dispose();
    super.dispose();
  }

  void _persist(final AgentDocModel agent) {
    _doc = _doc.copyWith(agent: agent);
    widget.onDocChanged?.call(_doc);
  }

  Future<void> _delegate() async {
    final workspace = _workspaceField.text.trim();
    final task = _taskField.text.trim();
    if (workspace.isEmpty || task.isEmpty) return;
    final current = _controller.current;
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
    await _controller.switchBackend(
      _controller.config.copyWith(
        backend: backend,
        apiKey: backend == 'open_router' && _keyField.text.trim().isNotEmpty
            ? _keyField.text.trim()
            : null,
      ),
    );
    final agent = _doc.agent ?? const AgentDocModel();
    if (agent.backend != backend) {
      _persist(agent.copyWith(backend: backend));
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (final context, final _) {
        final controller = _controller;
        final current = controller.current;
        AgentDocSurface.debugState = AgentDocDebugState(
          docId: _doc.id.value,
          workspaces: _doc.agent?.workspaces ?? const [],
          backend: controller.config.backend,
          sessionId: current?.id,
          running: controller.isRunning,
          pendingPermissionTitle: controller.pendingPermission?.request.title,
          verdict: current?.verdictLine,
          transcriptTail: current?.transcript.toString() ?? '',
        );
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              if (controller.error != null)
                _Banner(
                  key: const Key('coding_agent.error'),
                  text: 'error: ${controller.error}',
                  color: theme.colorScheme.errorContainer,
                ),
              _BackendSwitcher(
                controller: controller,
                keyField: _keyField,
                onSwitch: _switchBackend,
              ),
              TextField(
                key: const Key('coding_agent.workspace'),
                controller: _workspaceField,
                enabled: current == null || !current.running,
                decoration: const InputDecoration(
                  labelText: 'Workspace directory',
                  hintText: '/absolute/path/of/the/project',
                ),
              ),
              TextField(
                key: const Key('coding_agent.task'),
                controller: _taskField,
                enabled: current == null || !current.running,
                maxLines: 2,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Task sentence',
                  hintText: 'Fix main.dart so `dart run main.dart` exits 0.',
                ),
              ),
              Row(
                children: [
                  FilledButton(
                    key: const Key('coding_agent.delegate'),
                    onPressed: current?.running ?? false ? null : _delegate,
                    child: const Text('Delegate'),
                  ),
                  const SizedBox(width: 8),
                  if (current?.running ?? false)
                    OutlinedButton(
                      key: const Key('coding_agent.cancel'),
                      onPressed: controller.cancelCurrent,
                      child: const Text('Cancel'),
                    ),
                ],
              ),
              if (controller.pendingPermission != null)
                _PermissionCard(
                  key: const Key('coding_agent.permission'),
                  controller: controller,
                ),
              if (current != null && current.hasVerdict)
                _VerdictCard(
                  key: const Key('coding_agent.verdict'),
                  view: current,
                ),
              if (controller.sessions.isNotEmpty)
                _SessionList(controller: controller),
              if (current != null)
                Expanded(
                  child: Container(
                    key: const Key('coding_agent.transcript'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        current.transcript.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The agent/intent projection of the surface state (canonical, typed —
/// an agent parses this, never a screenshot).
final class AgentDocDebugState {
  const AgentDocDebugState({
    required this.docId,
    required this.workspaces,
    required this.backend,
    this.sessionId,
    this.running = false,
    this.pendingPermissionTitle,
    this.verdict,
    this.transcriptTail = '',
  });

  final String docId;
  final List<String> workspaces;
  final String backend;
  final String? sessionId;
  final bool running;
  final String? pendingPermissionTitle;
  final String? verdict;
  final String transcriptTail;

  Map<String, Object?> toJson() => {
    'docId': docId,
    'workspaces': workspaces,
    'backend': backend,
    'sessionId': ?sessionId,
    'running': running,
    'pendingPermissionTitle': ?pendingPermissionTitle,
    'verdict': ?verdict,
    'transcriptTail': transcriptTail.length > 4000
        ? '${transcriptTail.substring(0, 4000)}…'
        : transcriptTail,
  };
}

final class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.controller, super.key});

  final HarnessSessionController controller;

  @override
  Widget build(final BuildContext context) {
    final pending = controller.pendingPermission!;
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              'Permission requested',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(pending.request.title),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                OutlinedButton(
                  key: const Key('coding_agent.permission.reject'),
                  onPressed: () => controller.answerPermission(allow: false),
                  child: const Text('Reject'),
                ),
                FilledButton(
                  key: const Key('coding_agent.permission.allow'),
                  onPressed: () => controller.answerPermission(allow: true),
                  child: const Text('Allow'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.view, super.key});

  final HarnessSessionView view;

  @override
  Widget build(final BuildContext context) {
    final passed = view.verdictPassed;
    final color = passed ? Colors.green.shade100 : Colors.red.shade100;
    return Card(
      key: const Key('coding_agent.verdict.card'),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(passed ? Icons.check_circle : Icons.error),
            const SizedBox(width: 8),
            Expanded(child: Text(view.verdictLine ?? '')),
          ],
        ),
      ),
    );
  }
}

final class _SessionList extends StatelessWidget {
  const _SessionList({required this.controller});

  final HarnessSessionController controller;

  @override
  Widget build(final BuildContext context) => SizedBox(
    height: 44,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final session in controller.sessions)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              key: Key('coding_agent.session.${session.id}'),
              label: Text(
                '${session.id} · '
                '${session.cwd.split('/').where((p) => p.isNotEmpty).last}',
              ),
              selected: session == controller.current,
              onSelected: (_) => controller.selectSession(session),
            ),
          ),
      ],
    ),
  );
}

final class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.color, super.key});

  final String text;
  final Color color;

  @override
  Widget build(final BuildContext context) => Card(
    color: color,
    child: Padding(padding: const EdgeInsets.all(8), child: Text(text)),
  );
}

/// The backend switcher: AFM (on-device, local-first) ↔ OpenRouter.
/// Switching restarts the daemon; the per-workspace snapshot stores restore
/// the world on the next session (R7c), so work continues across switches.
final class _BackendSwitcher extends StatelessWidget {
  const _BackendSwitcher({
    required this.controller,
    required this.keyField,
    required this.onSwitch,
  });

  final HarnessSessionController controller;
  final TextEditingController keyField;
  final Future<void> Function(String backend) onSwitch;

  static const _afm = 'apple_foundation_afm';
  static const _openRouter = 'open_router';

  @override
  Widget build(final BuildContext context) {
    final busy = controller.isRunning;
    final selected = controller.config.backend;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        SegmentedButton<String>(
          key: const Key('coding_agent.backend'),
          segments: const [
            ButtonSegment(
              value: _afm,
              icon: Icon(Icons.laptop_mac),
              label: Text('AFM (on-device)'),
            ),
            ButtonSegment(
              value: _openRouter,
              icon: Icon(Icons.cloud_outlined),
              label: Text('OpenRouter'),
            ),
          ],
          selected: {selected},
          onSelectionChanged: busy
              ? null
              : (final selection) => onSwitch(selection.first).ignore(),
        ),
        if (selected == _openRouter) ...[
          TextField(
            key: const Key('coding_agent.api_key'),
            controller: keyField,
            enabled: !busy,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'OpenRouter API key',
              hintText: 'sk-or-… (or set OPENROUTER_API_KEY)',
              suffixIcon: IconButton(
                key: const Key('coding_agent.api_key.apply'),
                tooltip: 'Use key',
                onPressed: keyField.text.trim().isEmpty
                    ? null
                    : () => onSwitch(_openRouter).ignore(),
                icon: const Icon(Icons.check),
              ),
            ),
            onSubmitted: (_) => onSwitch(_openRouter).ignore(),
          ),
        ],
      ],
    );
  }
}
