// Agent-driven debug intents over the app shell (Wave F): the pane
// groups, the tabs, the rooms-column dock and the room selection as
// deterministic fmtk verbs. The live semantics walker drops parts of
// the shell chrome (a KNOWN framework gap — rail_sem_probe_test.dart,
// commit 06017111); these tools make live fmtk iteration deterministic
// regardless: every verb rides the shell's OWN paths through the
// [ShellDebugBridge] a mounted AppShell assigns (kDebugMode-guarded —
// a release tree carries nothing). No shell mounted = an honest named
// refusal (`shell_bridge_absent`), never a guess, never a silent no-op.
// Debug/profile only (mounted in main(), the realmChatMcpEntries lane).
import 'package:lastanswer/ui_shell/app_shell.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// The mounted shell's bridge; null while no AppShell is mounted.
ShellDebugBridge? get _bridge => ShellDebugBridge.instance;

Map<String, Object?> _fail(final String error, final String hint) =>
    <String, Object?>{'ok': false, 'error': error, 'hint': hint};

Map<String, Object?> _ok(final Map<String, Object?> data) =>
    <String, Object?>{'ok': true, ...data};

/// The absent-bridge refusal — every verb answers with it while no
/// shell is mounted (honest absence, the family's one shared refusal).
Map<String, Object?> _bridgeAbsent() => _fail(
      'shell_bridge_absent',
      'no AppShell is mounted (debug builds only; open the shell first)',
    );

/// The debug shell family, mounted next to the other entries in
/// main() (naming matches the other families: `<lane>McpEntries()`).
Set<AgentCallEntry> shellMcpEntries() => ShellMcpEntries.entries();

final class ShellMcpEntries {
  ShellMcpEntries._();
  static Set<AgentCallEntry> entries() => {
        _state(),
        _toggleDock(),
        _openTab(),
        _closeTab(),
        _splitActive(),
        _selectRoom(),
      };
}

AgentCallEntry _entry(
  final String name,
  final String description,
  final Map<String, dynamic> schema,
  final Future<Map<String, Object?>> Function(Map<String, Object?> args) run,
) => mcpToolkitTool(
      handler: (final parameters) async {
        try {
          final result = await run(parameters);
          return MCPCallResult(
            message: result['ok'] == true
                ? '$name ok.'
                : '$name refused: ${result['error'] ?? 'unknown'}',
            parameters: result,
          );
        } on Object catch (error) {
          return MCPCallResult(
            message: '$name failed: $error',
            parameters: _fail('exception', '$error'),
          );
        }
      },
      definition: MCPToolDefinition(
        name: name,
        description: description,
        inputSchema: ObjectSchema.fromMap(schema),
      ),
    );

AgentCallEntry _state() => _entry(
      'shell_state',
      'The shell layout document projection: the rooms-column dock '
      'bool, every pane group with its tab ids and focused tab, and '
      'the active group/tab. Read-only verification verb.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{},
      },
      (final args) async {
        final bridge = _bridge;
        if (bridge == null) return _bridgeAbsent();
        return _ok(bridge.state());
      },
    );

AgentCallEntry _toggleDock() => _entry(
      'shell_toggle_dock',
      'Flip + persist the rooms-column dock (the rail.actors button): '
      'chat-first projection (docked) <-> workspace projection. '
      'Returns the resulting shell state.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{},
      },
      (final args) async {
        final bridge = _bridge;
        if (bridge == null) return _bridgeAbsent();
        await bridge.toggleDock();
        return _ok(bridge.state());
      },
    );

AgentCallEntry _openTab() => _entry(
      'shell_open_tab',
      'Open (or focus) a tab by surface id through the shell ONE '
      'router: conversation ids (dm:/channel:/room:/conversations), '
      'view ids (people, boards, settings, actor:<id>, doc:<id>...). '
      'group pins a pane group; split lands the tab in its own new '
      'right-hand group. Returns the resulting shell state.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'id': <String, dynamic>{
            'type': 'string',
            'description': 'The surface id to open.',
          },
          'group': <String, dynamic>{
            'type': 'integer',
            'description': 'Force this pane group index.',
          },
          'split': <String, dynamic>{
            'type': 'boolean',
            'description': 'Open into its own new right-hand group.',
          },
        },
        'required': <String>['id'],
      },
      (final args) async {
        final bridge = _bridge;
        if (bridge == null) return _bridgeAbsent();
        final id = (args['id'] as String? ?? '').trim();
        if (id.isEmpty) return _fail('missing_parameters', 'id is required');
        final group = args['group'] is int ? args['group']! as int : null;
        final split = args['split'] == true;
        final opened = await bridge.openTab(id, group: group, split: split);
        if (!opened) {
          return _fail('open_tab_refused', 'the shell refused to open $id');
        }
        return _ok(bridge.state());
      },
    );

AgentCallEntry _closeTab() => _entry(
      'shell_close_tab',
      'Close an open tab by surface id (the docked close law applies: '
      'group 0 never empties — it lands on the world face). Refuses '
      'with unknown_tab when the id is not open.',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'id': <String, dynamic>{
            'type': 'string',
            'description': 'The surface id to close.',
          },
        },
        'required': <String>['id'],
      },
      (final args) async {
        final bridge = _bridge;
        if (bridge == null) return _bridgeAbsent();
        final id = (args['id'] as String? ?? '').trim();
        if (id.isEmpty) return _fail('missing_parameters', 'id is required');
        if (!bridge.closeTab(id)) {
          return _fail('unknown_tab', 'no open tab with id $id');
        }
        return _ok(bridge.state());
      },
    );

AgentCallEntry _splitActive() => _entry(
      'shell_split_active',
      "The strip split control: move the active group's focused tab "
      'into a new pane group to the right (the mockup law; splitting '
      'the lone world face is refused by the layout model).',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{},
      },
      (final args) async {
        final bridge = _bridge;
        if (bridge == null) return _bridgeAbsent();
        bridge.splitActive();
        return _ok(bridge.state());
      },
    );

AgentCallEntry _selectRoom() => _entry(
      'shell_select_room',
      'Select a rooms-column row by its contract key: '
      'rooms.row.dm.<actorId> | rooms.row.channel.<channelId>. '
      'Opens + focuses the conversation tab exactly like a row tap. '
      'Refuses unknown key shapes (the retired rooms.row.room.<threadId> '
      "keys refuse too — rooms live in the channel view's threads "
      'browser now).',
      const <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'rowKey': <String, dynamic>{
            'type': 'string',
            'description': 'The rooms-column row key.',
          },
        },
        'required': <String>['rowKey'],
      },
      (final args) async {
        final bridge = _bridge;
        if (bridge == null) return _bridgeAbsent();
        final rowKey = (args['rowKey'] as String? ?? '').trim();
        if (rowKey.isEmpty) {
          return _fail('missing_parameters', 'rowKey is required');
        }
        if (!bridge.selectRoom(rowKey)) {
          return _fail(
            'unknown_row',
            'rowKey must be rooms.row.{dm,channel,room}.<id> '
            "(got '$rowKey')",
          );
        }
        return _ok(bridge.state());
      },
    );
