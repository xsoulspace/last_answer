import 'package:lastanswer/doc/doc_view.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// MCP tool entries that let an agent inspect and drive the recursive
/// document editor (ADR 0001) without any UI interaction.
///
/// Registered in debug/profile builds only (see `main.dart`).
/// The current [DocViewState] is published by `DocView` itself through
/// `debugDocState` whenever it rebuilds.
Set<AgentCallEntry> docMcpEntries() => {
  mcpToolkitTool(
    handler: (final parameters) {
      final state = DocView.debugDocState;
      if (state == null) {
        return MCPCallResult(
          message: 'No document is currently open.',
          parameters: {'ok': false},
        );
      }
      return MCPCallResult(
        message:
            'Current document path depth: ${state.depth}. '
            'Root doc id: ${state.rootDocId}. Current node id: '
            '${state.currentDocId}, status: ${state.status}.',
        parameters: {'ok': true, ...state.toJson()},
      );
    },
    definition: MCPToolDefinition(
      name: 'doc_state',
      description:
          'Get the state of the open recursive document: the '
          'breadcrumb path (root → current node), each node id/status, and '
          'the blocks of the current node with their anchored discussion '
          'children counts.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final index = int.tryParse('${parameters['blockIndex']}');
      if (index == null) {
        return MCPCallResult(
          message: 'blockIndex (int) is required.',
          parameters: {'ok': false},
        );
      }
      final state = DocView.debugDocState;
      if (state == null) {
        return MCPCallResult(
          message: 'No document is currently open.',
          parameters: {'ok': false},
        );
      }
      final childId = await state.discussBlock(index);
      return MCPCallResult(
        message: childId == null
            ? 'blockIndex $index is out of range '
                  '(0..${state.blockCount - 1}).'
            : 'Discussion child created and opened for block $index '
                  '(id: $childId).',
        parameters: {'ok': childId != null, 'childDocId': childId},
      );
    },
    definition: MCPToolDefinition(
      name: 'doc_discuss_block',
      description:
          'Create a discussion child document anchored to the block '
          'at blockIndex of the currently open document node, and dive into '
          'it (same as pressing "Discuss" in the UI).',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'required': ['blockIndex'],
        'properties': {
          'blockIndex': {
            'type': 'integer',
            'description': 'Zero-based index of the block to discuss.',
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final state = DocView.debugDocState;
      if (state == null) {
        return MCPCallResult(
          message: 'No document is currently open.',
          parameters: {'ok': false},
        );
      }
      final rewrite = (parameters['rewrite'] as bool?) == true;
      final collapsed = await state.collapseCurrent(
        rewriteFromDiscussion: rewrite,
      );
      return MCPCallResult(
        message: collapsed
            ? 'Discussion collapsed (archived); climbed up to the parent.'
            : 'Nothing to collapse: the root document cannot be collapsed.',
        parameters: {'ok': collapsed},
      );
    },
    definition: MCPToolDefinition(
      name: 'doc_collapse',
      description:
          'Collapse the currently open discussion node: mark it as '
          'collapsed (archived) and climb back to its parent document. '
          'Set "rewrite" to rewrite the parent head span from this '
          'discussion before collapsing (agent conclusion → head).',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'properties': {
          'rewrite': {
            'type': 'boolean',
            'description':
                'Rewrite the parent head span from this discussion '
                'before collapsing (default false).',
          },
        },
      }),
    ),
  ),
};

Map<String, Object?> _emptySchema() => {
  'type': 'object',
  'additionalProperties': false,
  'properties': <String, Object?>{},
};
