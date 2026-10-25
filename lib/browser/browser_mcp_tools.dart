import 'package:lastanswer/browser/browser_windows.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// Debug toolkit projection of the same browser controls as the visible UI.
Set<AgentCallEntry> browserMcpEntries() => {
  mcpToolkitTool(
    handler: (args) async => MCPCallResult(
      message:
          'Browser window operation; dispatch is not page acceptance.',
      parameters: await BrowserWindows.act(
        action: args['action'] ?? 'list',
        windowId: args['windowId'],
        address: args['address'],
      ),
    ),
    definition: MCPToolDefinition(
      name: 'browser_window',
      description:
          'List mounted browser windows or use their navigation controls. '
          'Select windowId when multiple windows exist. Only HTTP/HTTPS addresses '
          'navigate; no app capability bridge is granted to pages.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'action': {
            'type': 'string',
            'enum': ['list', 'navigate', 'back', 'forward', 'reload'],
          },
          'windowId': {'type': 'string'},
          'address': {'type': 'string'},
        },
        'additionalProperties': false,
      }),
    ),
  ),
};
