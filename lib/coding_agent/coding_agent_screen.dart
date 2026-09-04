import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';

/// TASK B — the minimal coding-agent surface (coding agent FIRST, nothing
/// else): task input (sentence + workspace), session list, streamed
/// progress, permission prompts, verdict. Repair-pack editor: deferred.
///
/// The screen owns nothing protocol-shaped — everything rides the embedded
/// [HarnessHost] (ACP v1). Production default backend is AFM-first
/// (on-device, local); tests inject a scripted host config.
final class CodingAgentScreen extends StatefulWidget {
  const CodingAgentScreen({super.key, this.config, this.controller});

  /// Optional host config override (tests inject the scripted seam).
  final HarnessHostConfig? config;

  /// Optional pre-built controller (tests inject a scripted one).
  final HarnessSessionController? controller;

  @override
  State<CodingAgentScreen> createState() => _CodingAgentScreenState();
}

class _CodingAgentScreenState extends State<CodingAgentScreen> {
  late final HarnessSessionController _controller =
      widget.controller ??
      HarnessSessionController(
        host: HarnessHost(config: widget.config ?? const HarnessHostConfig()),
      );
  late final bool _ownsController = widget.controller == null;
  final _workspaceField = TextEditingController();
  final _taskField = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_controller.ensureStarted());
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    _workspaceField.dispose();
    _taskField.dispose();
    super.dispose();
  }

  Future<void> _delegate() async {
    final workspace = _workspaceField.text.trim();
    final task = _taskField.text.trim();
    if (workspace.isEmpty || task.isEmpty) return;
    final current = _controller.current;
    if (current == null || current.cwd != workspace) {
      await _controller.createSession(workspace);
    }
    await _controller.delegate(task);
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Coding agent')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (final context, final _) {
            final controller = _controller;
            final current = controller.current;
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
                      hintText:
                          'Fix main.dart so `dart run main.dart` exits 0.',
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
        ),
      ),
    );
  }
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
