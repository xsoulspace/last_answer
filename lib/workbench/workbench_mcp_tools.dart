import 'dart:convert';

import 'package:lastanswer/workbench/workbench_screen.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:universal_automation_interface/universal_automation_interface.dart';

WorkbenchEndpoint? _resolve(String? viewerId) => viewerId == null
    ? WorkbenchScreen.endpoint
    : WorkbenchScreen.endpoints[viewerId];

MCPCallResult _unavailable(String? viewerId) => MCPCallResult(
  message: 'Select a mounted workbench viewerId.',
  parameters: {
    'ok': false,
    'error': viewerId != null
        ? 'workbench_view_unknown'
        : WorkbenchScreen.endpoints.isEmpty
        ? 'workbench_not_open'
        : 'workbench_view_ambiguous',
    'views': [
      for (final entry in WorkbenchScreen.endpoints.entries)
        {'viewerId': entry.key, 'project': entry.value.state()['project']},
    ],
  },
);

Set<AgentCallEntry> workbenchMcpEntries() => {
  mcpToolkitTool(
    handler: (args) {
      final viewerId = args['viewerId'];
      final endpoint = _resolve(viewerId);
      if (endpoint == null) return _unavailable(viewerId);
      return MCPCallResult(
        message: 'Workbench state',
        parameters: {'ok': true, ...endpoint.state()},
      );
    },
    definition: MCPToolDefinition(
      name: 'workbench_state',
      description:
          'Read the selected project, proposals, behaviour and recorded observations.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'viewerId': {'type': 'string'},
        },
        'additionalProperties': false,
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (args) async {
      final viewerId = args['viewerId'];
      final endpoint = _resolve(viewerId);
      if (endpoint == null) return _unavailable(viewerId);
      try {
        final payload = args['arguments'] == null
            ? <String, dynamic>{}
            : jsonDecode(args['arguments']!) as Map<String, dynamic>;
        payload['project'] = args['project'];
        final result = await endpoint.act(
          args['action']!,
          payload,
          InteractionOrigin.semanticAgent,
        );
        return MCPCallResult(
          message: '${result['error'] ?? 'Workbench operation'}',
          parameters: {'viewerId': endpoint.state()['viewerId'], ...result},
        );
      } on Object catch (e) {
        return MCPCallResult(
          message: '$e',
          parameters: {'ok': false, 'error': '$e'},
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'workbench_action',
      description:
          'Invoke the same workbench operation as visible controls. Invocation grants no harness authority.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'viewerId': {'type': 'string'},
          'project': {'type': 'string'},
          'action': {
            'type': 'string',
            'enum': [
              'open',
              'select',
              'project',
              'propose',
              'adopt',
              'reject',
              'undo',
              'reapply',
              'leave',
              'reopen',
              'cancel',
              'interaction',
            ],
          },
          'arguments': {
            'type': 'string',
            'description': 'JSON operation arguments',
          },
        },
        'required': ['action', 'project'],
        'additionalProperties': false,
      }),
    ),
  ),
};
