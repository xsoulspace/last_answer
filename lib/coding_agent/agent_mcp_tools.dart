import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// ADR 0003 (Phase 3 core) — MCP/intent entries that let ANY agent (pi,
/// opencode, another harness) inspect and drive the agent-doc surface
/// headlessly. Same typed state the human screen renders — the UI is just
/// another projection ([AgentDocSurface.debugState]).
///
/// Registered in debug/profile builds (see `main.dart`), next to the doc
/// and storage entries.
Set<AgentCallEntry> agentMcpEntries() => {
  mcpToolkitTool(
    handler: (final parameters) {
      final state = AgentDocSurface.debugState;
      if (state == null) {
        return MCPCallResult(
          message: 'No agent doc surface is currently open.',
          parameters: {'ok': false},
        );
      }
      final verdict = state.verdict == null
          ? ''
          : ', verdict: ${state.verdict}';
      final permission = state.pendingPermissionTitle == null
          ? ''
          : ' — the permission prompt (${state.pendingPermissionTitle}) is '
                'awaiting an answer; call agent_permission_answer.';
      return MCPCallResult(
        message:
            'Agent doc ${state.docId}: backend ${state.backend}, '
            'session ${state.sessionId ?? 'none'}, '
            '${state.running ? 'RUNNING' : 'idle'}'
            '$verdict$permission',
        parameters: {'ok': true, ...state.toJson()},
      );
    },
    definition: MCPToolDefinition(
      name: 'agent_doc_state',
      description:
          'Get the state of the open agent doc: bound workspaces, '
          'backend, session id, running flag, pending permission title, '
          'latest verdict, and the transcript tail.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      final task = parameters['task'];
      if (task == null || task.isEmpty) {
        return MCPCallResult(
          message: 'task (string) is required.',
          parameters: {'ok': false},
        );
      }
      final surface = AgentDocSurface.debugSurface;
      if (surface == null) {
        return MCPCallResult(
          message: 'No agent doc surface is currently open.',
          parameters: {'ok': false},
        );
      }
      final result = surface.delegateFromIntent(task);
      return MCPCallResult(
        message: result.message,
        parameters: {'ok': result.ok},
      );
    },
    definition: MCPToolDefinition(
      name: 'agent_task_delegate',
      description:
          'Delegate a task sentence to the open agent doc (host-injected '
          'decision; the turn runs with the doc-bound runtime). Returns '
          'immediately; poll agent_doc_state for progress/verdict.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'task': {'type': 'string'},
        },
        'required': ['task'],
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      // Service-extension transport carries values as strings.
      final rawAllow = parameters['allow']?.toLowerCase();
      final allow = rawAllow == 'true';
      final rejected = rawAllow == 'false';
      if (!allow && !rejected) {
        return MCPCallResult(
          message: 'allow (bool) is required.',
          parameters: {'ok': false},
        );
      }
      final surface = AgentDocSurface.debugSurface;
      if (surface == null) {
        return MCPCallResult(
          message: 'No agent doc surface is currently open.',
          parameters: {'ok': false},
        );
      }
      final result = surface.answerPermissionFromIntent(allow: allow);
      return MCPCallResult(
        message: result.message,
        parameters: {'ok': result.ok},
      );
    },
    definition: MCPToolDefinition(
      name: 'agent_permission_answer',
      description:
          'Answer the pending permission round-trip of the open agent '
          'doc (allow = the write/edit proceeds; reject = it never '
          'lands). Deny-by-default: with no answer the write is '
          'rejected.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'allow': {'type': 'boolean'},
        },
        'required': ['allow'],
      }),
    ),
  ),
};

Map<String, Object?> _emptySchema() => {
  'type': 'object',
  'properties': <String, Object?>{},
};
