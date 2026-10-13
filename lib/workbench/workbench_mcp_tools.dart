import 'dart:convert';

import 'package:lastanswer/workbench/workbench_screen.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:universal_automation_interface/universal_automation_interface.dart';

Set<AgentCallEntry> workbenchMcpEntries() => {
  mcpToolkitTool(
    handler: (_) {
      final endpoint = WorkbenchScreen.endpoint;
      return MCPCallResult(
        message: endpoint == null ? 'Open Workbench first.' : 'Workbench state',
        parameters: endpoint == null
            ? {'ok': false, 'error': 'workbench_not_open'}
            : {'ok': true, ...endpoint.state()},
      );
    },
    definition: MCPToolDefinition(
      name: 'workbench_state',
      description:
          'Read the selected project, proposals, behaviour and recorded observations.',
      inputSchema: ObjectSchema.fromMap({'type': 'object', 'properties': {}}),
    ),
  ),
  mcpToolkitTool(
    handler: (args) async {
      final endpoint = WorkbenchScreen.endpoint;
      if (endpoint == null) {
        return MCPCallResult(
          message: 'Open Workbench first.',
          parameters: {'ok': false, 'error': 'workbench_not_open'},
        );
      }
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
          parameters: result,
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
