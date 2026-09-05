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
  mcpToolkitTool(
    handler: (final parameters) {
      // R9.a — create + open routes through the app's own path (the
      // OpenedProjectNotifier.createAgentProject equivalent), installed by
      // the app shell in debug/profile builds. Returns the new docId so a
      // headless driver can address the doc it just created.
      final hook = AgentDocSurface.createAgentProjectHook;
      if (hook == null) {
        return MCPCallResult(
          message:
              'agent_doc_create is not wired in this build (the app shell '
              'installs it in debug/profile builds only).',
          parameters: {'ok': false},
        );
      }
      final doc = hook();
      return MCPCallResult(
        message:
            'created and opened agent doc ${doc.id.value}. It binds to no '
            'workspace yet — call agent_doc_bind (poll agent_doc_state '
            'until the surface reports this docId).',
        parameters: {'ok': true, 'docId': doc.id.value},
      );
    },
    definition: MCPToolDefinition(
      name: 'agent_doc_create',
      description:
          'Create a NEW agent doc and open it (create + open in one verb). '
          'Returns the docId. The doc binds to no workspace yet; bind one '
          'with agent_doc_bind — never by filling the SETUP fields '
          '(semantic fills bypass persistence).',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      // R9.a — bind workspace (+ optional check override) DIRECTLY onto
      // the open doc payload. Measured Phase-1.5 finding: a semantic form
      // fill never fires controller listeners, so binding MUST be an
      // intent, never a field fill.
      final workspace = parameters['workspace'];
      if (workspace == null || workspace.isEmpty) {
        return MCPCallResult(
          message: 'workspace (absolute path) is required.',
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
      final result = surface.bindFromIntent(
        workspace: workspace,
        check: parameters['check'],
      );
      return MCPCallResult(
        message: result.message,
        parameters: {'ok': result.ok},
      );
    },
    definition: MCPToolDefinition(
      name: 'agent_doc_bind',
      description:
          'Bind a workspace (absolute path) and an optional check override '
          '(literal argv, whitespace-split — e.g. "dart '
          'tool/agent_fixture/main.dart") onto the open agent doc. '
          'Persists into the syncable doc payload; NEVER a form fill.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'workspace': {'type': 'string'},
          'check': {'type': 'string'},
        },
        'required': ['workspace'],
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      // R9.a — escalation guidance as a host-injected decision on the
      // open doc's last turn: first-class grid state (GUIDE row + composer
      // pre-fill), then the continuation turn is delegated. Monotonic:
      // one guidance per ended turn.
      final guidance = parameters['guidance'];
      if (guidance == null || guidance.isEmpty) {
        return MCPCallResult(
          message: 'guidance (string) is required.',
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
      final result = surface.guideFromIntent(guidance);
      return MCPCallResult(
        message: result.message,
        parameters: {'ok': result.ok},
      );
    },
    definition: MCPToolDefinition(
      name: 'agent_task_guide',
      description:
          'Send escalation guidance for the open agent doc\'s LAST ended '
          'turn (the continuation after a FAIL). Host-injected decision, '
          'monotonic — one guidance per turn; the continuation turn is '
          'delegated immediately and the guidance lands on the grid.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'guidance': {'type': 'string'},
        },
        'required': ['guidance'],
      }),
    ),
  ),
};

Map<String, Object?> _emptySchema() => {
  'type': 'object',
  'properties': <String, Object?>{},
};
