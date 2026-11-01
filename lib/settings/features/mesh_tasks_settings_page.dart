

import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';
import 'package:lastanswer/common_imports.dart';

/// ADR 0023 — mesh task observability moved into Settings: every board
/// row across docs, read-only. Dispatching stays attached to the doc
/// surfaces that own the tasks; pairing lives in the storage sheet.
class MeshTasksSettingsPage extends StatefulWidget {
  const MeshTasksSettingsPage({super.key});

  @override
  State<MeshTasksSettingsPage> createState() => _MeshTasksSettingsPageState();
}

class _MeshTasksSettingsPageState extends State<MeshTasksSettingsPage> {
  Timer? _refresh;

  @override
  void initState() {
    super.initState();
    // The board is a kernel projection, not listenable — one cheap
    // projection read per second, the console's honest polling.
    _refresh = Timer.periodic(const Duration(seconds: 1), (final _) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final board = AgentDocSurface.meshWiring?.taskBoard?.call();
    final rows = board?.allRecords ?? const <MeshTaskRecord>[];
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsMeshTasks)),
      body: SafeArea(
        child: board == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.meshTasksNoReplica,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            : rows.isEmpty
            ? Center(
                child: Text(
                  context.l10n.meshTasksEmpty,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: rows.length,
                itemBuilder: (final context, final index) {
                  final row = rows[index];
                  final verdict = row.verdict;
                  return ListTile(
                    key: ValueKey('mesh.tasks.row.${row.taskId}'),
                    dense: true,
                    title: Text(
                      '[${row.status}] ${row.task}',
                      style: theme.textTheme.bodySmall,
                    ),
                    subtitle: Text(
                      [
                        'doc ${row.docId}',
                        'from ${row.originPeerId}',
                        if (verdict != null)
                          'verdict: ${verdict['status'] ?? verdict}',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
