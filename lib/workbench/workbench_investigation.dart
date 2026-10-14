import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/workbench/workbench_harness_tools.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// Existing agent-doc runtime is a conversation projection over a shared block.
/// The installed tools expose that scope, not the private project's whole body.
class WorkbenchInvestigation extends StatefulWidget {
  const WorkbenchInvestigation({
    required this.owner,
    required this.scope,
    super.key,
  });
  final hc.WorkbenchOwner owner;
  final SharedWorkbenchScope scope;
  @override
  State<WorkbenchInvestigation> createState() => _WorkbenchInvestigationState();
}

class _WorkbenchInvestigationState extends State<WorkbenchInvestigation> {
  ProjectModelDoc? document;
  String? error;
  String? admission;
  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    try {
      final projects = context.read<ProjectsRepository>();
      final support = await getApplicationSupportDirectory();
      final workspace = Directory(
        '${support.path}/workbench_sessions/${Uri.encodeComponent(widget.scope.project)}',
      );
      await workspace.create(recursive: true);
      final id =
          'workbench-investigation-${widget.scope.project}-${widget.scope.block}';
      final existing = await widget.owner.repository.get(hc.NodeId(id));
      if (existing is hc.DocError) {
        throw StateError('investigation_storage_unavailable');
      }
      final now = DateTime.now().toUtc();
      if (existing is hc.DocNotFound) {
        await widget.owner.repository.save(
          hc.DocumentNode(
            id: hc.NodeId(id),
            createdAt: now,
            updatedAt: now,
            kind: 'workbench_conversation',
            formatId: DocFormatIds.agent,
            blocks: [
              hc.Block(
                id: hc.NodeId('$id-scope'),
                type: hc.BlockType.paragraph,
                content: widget.scope.content,
              ),
            ],
          ),
        );
      }
      final saved = await projects.getById(id: ProjectModelId(id));
      if (saved != null && saved is! ProjectModelDoc) {
        throw StateError('investigation_identity_collision');
      }
      final restored = saved as ProjectModelDoc?;
      final prepared =
          restored ??
          ProjectModelDoc(
            id: ProjectModelId(id),
            createdAt: now,
            updatedAt: now,
            title: 'Investigate selected work',
            formatId: DocFormatIds.agent,
            agent: AgentDocModel(workspaces: [workspace.path]),
          );
      if (restored == null) await projects.put(project: prepared);
      if (!mounted) return;
      setState(() => document = prepared);
    } on Object catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(child: Text('Investigation unavailable: $error'));
    }
    final doc = document;
    if (doc == null) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        TextButton(
          onPressed: () {
            final result =
                HarnessSessionTools(
                  registry: HarnessSessionRegistry.instance,
                ).taskDelegate({
                  'sessionId': 'agent-${doc.id.value}',
                  'task':
                      'Investigate the explicitly shared article block using workbench_shared_scope. Propose an improved version with workbench_propose_rewrite, explaining evidence and uncertainty. Do not adopt it.',
                });
            setState(() => admission = '${result['message'] ?? result}');
          },
          child: const Text('Investigate shared block'),
        ),
        if (admission != null) Text(admission!),
        Expanded(
          child: AgentDocSurface(
            doc: doc,
            config: HarnessHostConfig(
              actorToolNames: sharedWorkbenchToolNames,
              extraToolsWithContext: (context) =>
                  workbenchHarnessTools(widget.owner, widget.scope, context),
            ),
            onDocChanged: (updated) {
              document = updated;
              context.read<ProjectsNotifier>().updateEditingProject(updated);
            },
          ),
        ),
      ],
    );
  }
}
