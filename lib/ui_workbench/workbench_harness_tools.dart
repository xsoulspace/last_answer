import 'dart:convert';

import 'package:headless_core/headless_core.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart'
    show ObjectSchema, PrimitiveSchema, PrimitiveType, SchemaProperty;

/// Explicitly shared block scope. It contains no copy of the rest of a project.
final class SharedWorkbenchScope {
  const SharedWorkbenchScope({
    required this.project,
    required this.block,
    required this.content,
  });
  final String project;
  final String block;
  final String content;
}

/// The complete admitted menu for a shared document investigation.
final sharedWorkbenchToolNames = Set<ToolName>.unmodifiable(const [
  ToolName('workbench_shared_scope'),
  ToolName('workbench_propose_rewrite'),
]);

/// Installed on an existing harness host through extraToolsWithContext. The
/// bound actor can inspect the shared block and propose a rewrite; adoption
/// stays with the human. No model calls, scheduling or acceptance happen here.
List<ToolDef> workbenchHarnessTools(
  WorkbenchOwner owner,
  SharedWorkbenchScope scope,
  HostToolExtensionContext context,
) {
  bool authorized() => context.isCurrent && context.isCallerBound;

  Future<String> current() async {
    if (!authorized()) {
      throw const WorkbenchRefusal('workbench_task_not_bound');
    }
    final node = await owner.read(scope.project);
    if (!authorized()) {
      throw const WorkbenchRefusal('workbench_task_not_bound');
    }
    if (node.blockById(NodeId(scope.block))?.content != scope.content) {
      throw const WorkbenchRefusal('shared_scope_stale');
    }
    return workRevision(node);
  }

  return [
    ToolDef(
      name: const ToolName('workbench_shared_scope'),
      description:
          'Read only the article block explicitly shared by its human.',
      execute: (_) async {
        await current();
        return jsonEncode({
          'project': scope.project,
          'block': scope.block,
          'content': scope.content,
          'task': context.taskId,
        });
      },
    ),
    ToolDef(
      name: const ToolName('workbench_propose_rewrite'),
      description:
          'Stage an attributed rewrite for the shared block. Never adopts it.',
      argsSchema: const SchemaBundle(
        root: ObjectSchema(
          name: 'Rewrite',
          properties: [
            SchemaProperty(
              name: 'text',
              schema: PrimitiveSchema(type: PrimitiveType.string),
            ),
            SchemaProperty(
              name: 'reason',
              schema: PrimitiveSchema(type: PrimitiveType.string),
            ),
          ],
        ),
      ),
      execute: (args) async {
        await current();
        final parameters = args is Map
            ? Map<String, Object?>.from(args)
            : const <String, Object?>{};
        final text = parameters['text'];
        final reason = parameters['reason'];
        if (text is! String || reason is! String || reason.trim().isEmpty) {
          throw const WorkbenchRefusal('rewrite_arguments_required');
        }
        final key = 'docs/workbench-${Uri.encodeComponent(scope.project)}.json';
        if (!context.fileLocks.claim(key, context.editOwner)) {
          throw const WorkbenchRefusal('workbench_proposal_claim_conflict');
        }
        try {
          final revision = await current();
          final proposal = await owner.propose(
            project: scope.project,
            actor: 'task:${context.taskId}',
            intent: reason,
            operation: 'rewrite_block',
            arguments: {'block': scope.block, 'text': text},
            origin: 'harness_actor',
            expectedRevision: revision,
            authorizationStillValid: authorized,
          );
          await owner.addKnowledge(
            scope.project,
            kind: KnowledgeKind.suggestion,
            text: reason,
            actor: 'task:${context.taskId}',
            object: scope.block,
            discussion: context.taskId,
          );
          return jsonEncode({
            'ok': true,
            'proposal': proposal,
            'status': 'staged',
            'accepted': false,
          });
        } finally {
          context.fileLocks.release(key, context.editOwner);
        }
      },
    ),
  ];
}
