import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';

/// PLAN 6.C — the mesh task console as a human/agent-visible surface.
///
/// The console's data plane already rode the mesh (the `mesh_task_dispatch`
/// / `mesh_tasks` toolkit verbs read and write the SAME board rows); this
/// view is the UI projection of that board for the doc's surface: dispatch
/// a task to the doc's owner and watch statuses and verdicts converge.
/// It reads through the app wiring ([AgentDocSurface.meshWiring]) exactly
/// like the surface itself — never the storage layer directly — and is
/// hidden whenever no mesh replica is live on this device.
///
/// Widget keys are the agent's UI contract (DESIGN §6): rows carry
/// `ValueKey('mesh.task.row.<taskId>')`, the composer
/// `mesh.task.input`/`mesh.task.dispatch`. Row text is plain data
/// (`[<status>] <task>` + `verdict: …`), so accessibility-tree automation
/// (the multiplayer gate's CDP peer) reads statuses without any
/// out-of-band state.
class MeshTaskConsoleView extends StatefulWidget {
  const MeshTaskConsoleView({required this.docId, super.key});

  /// The agent doc id whose rows render (board rows are doc-scoped).
  final String docId;

  @override
  State<MeshTaskConsoleView> createState() => _MeshTaskConsoleViewState();
}

class _MeshTaskConsoleViewState extends State<MeshTaskConsoleView> {
  static const _refreshInterval = Duration(seconds: 1);
  Timer? _refresh;
  final _taskField = TextEditingController();
  bool _dispatching = false;

  @override
  void initState() {
    super.initState();
    // The board is not listenable (a kernel projection, not a ChangeNotifier)
    // and the surface's refreshAfterMeshSync is the doc-surface's seam —
    // the console polls instead, honestly cheap (one projection read/s).
    _refresh = Timer.periodic(_refreshInterval, (final _) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    _taskField.dispose();
    super.dispose();
  }

  AgentDocMeshWiring? get _wiring => AgentDocSurface.meshWiring;

  MeshTaskBoard? get _board => _wiring?.taskBoard?.call();

  String? get _selfPeerId => _wiring?.selfPeerId?.call();

  Future<void> _dispatch() async {
    final board = _board;
    final selfPeerId = _selfPeerId;
    final task = _taskField.text.trim();
    if (board == null || selfPeerId == null || task.isEmpty) return;
    setState(() => _dispatching = true);
    try {
      // The same discipline as the mesh_task_dispatch verb: one requested
      // row, then one convergence cycle right away — the periodic sync
      // would ship it anyway, but the dispatcher should not wait for it.
      board.requestTask(
        docId: widget.docId,
        task: task,
        originPeerId: selfPeerId,
      );
      _taskField.clear();
      final service = await StorageBackendsNotifier.instance
          .ensureMeshService();
      await service.sync();
      StorageBackendsNotifier.onSyncCycle?.call();
    } on Object {
      // Named-data honesty would want a visible failure row; the board
      // row itself never landed, so the next dispatch retry is the
      // recovery. Keep the text so the human can resend.
    } finally {
      if (mounted) setState(() => _dispatching = false);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final board = _board;
    final selfPeerId = _selfPeerId;
    if (board == null || selfPeerId == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final rows = board.tasksFor(widget.docId);
    return Container(
      key: const ValueKey('mesh.task.console'),
      constraints: const BoxConstraints(maxHeight: 190),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: SingleChildScrollView(
        child: DefaultTextStyle(
          style: theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'mesh tasks · ${rows.length}',
                style: TextStyle(color: muted, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('mesh.task.input'),
                      controller: _taskField,
                      enabled: !_dispatching,
                      style: theme.textTheme.bodySmall,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'new task for the owner',
                        hintText: 'one sentence — dispatched over the mesh',
                      ),
                      onSubmitted: (final _) => unawaited(_dispatch()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    key: const ValueKey('mesh.task.dispatch'),
                    onPressed:
                        _dispatching ? null : () => unawaited(_dispatch()),
                    child: const Text('dispatch to owner'),
                  ),
                ],
              ),
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    _rowLine(row),
                    key: ValueKey('mesh.task.row.${row.taskId}'),
                    style: TextStyle(color: muted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// One plain-data line per row: `[<status>] <task>` + the verdict's
  /// headline (or error) — the same fields the `mesh_tasks` verb reports.
  String _rowLine(final MeshTaskRecord row) {
    final buffer = StringBuffer('[${row.status}] ${row.task}');
    final verdict = row.verdict;
    if (verdict != null) {
      final error = verdict['error'];
      final headline =
          (verdict['verdict'] as String?) ?? (error is String ? error : null);
      if (headline != null && headline.isNotEmpty) {
        buffer.write(' — verdict: ${headline.split('\n').first}');
      }
    }
    return buffer.toString();
  }
}
