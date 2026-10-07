/// The APP intent surface — LA's user-level actions as named data over
/// the flutter mcp toolkit, published for controllers the app knows
/// NOTHING about (dependency inversion at the app level, the same law
/// the inspector obeys: verbs render as data, the host owns execution,
/// the customer is at most a user).
///
/// The contract, in three sentences: (1) LA publishes a STABLE catalog
/// of intents (`appIntentCatalog` — the `app_intents` tool) plus
/// executable entries for each; (2) any external driver — today's
/// headless gates, tomorrow's gesture controller — discovers the
/// vocabulary through `app_intents` and drives it through the entries;
/// (3) LA imports no controller package and never will: a controller
/// adapts to LA, never the reverse. Semantic grounding rides the
/// toolkit's own a11y snapshot (the labeled tree); these tools add the
/// ACTION layer over it — stable names that do not move when labels
/// are re-worded.
///
/// Registered in debug/profile builds (see `main.dart`, next to the
/// doc/mesh/storage/agent entries — the toolkit is a VM-service debug
/// channel, so intent authority never ships to a store build).
library;

import 'package:core/core.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/device_capabilities.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart';
import 'package:lastanswer/router.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// One published intent, as data — the vocabulary a controller reads.
final class AppIntentSpec {
  const AppIntentSpec({
    required this.name,
    required this.group,
    required this.summary,
  });

  /// The tool name (flat snake_case, the LA convention).
  final String name;

  /// The semantic group ('doc', 'mesh', 'storage', 'inspector', 'app').
  final String group;

  /// One human line: what the intent DOES to the app.
  final String summary;

  Map<String, Object?> toJson() => {
    'name': name,
    'group': group,
    'summary': summary,
  };
}

/// The published vocabulary. NAMESPACING LAW: only names the entries
/// below (plus the long-standing families) may appear — a controller
/// builds on this list, so renames are contract changes.
const List<AppIntentSpec> appIntentCatalog = [
  // App shell — where the user IS and what the screen focuses. The
  // catalog publishes ITSELF (a controller's first call is a tool too).
  AppIntentSpec(
    name: 'app_intents',
    group: 'app',
    summary:
        'Read this catalog: every published intent as named data '
        '(the discovery contract).',
  ),
  AppIntentSpec(
    name: 'app_navigate',
    group: 'app',
    summary:
        'Navigate the app shell (home, changelog, or an agent doc '
        'by docId).',
  ),
  AppIntentSpec(
    name: 'app_composer',
    group: 'app',
    summary:
        'Focus the agent doc composer, or submit its task sentence '
        '(the same delegate path the keyboard takes).',
  ),
  AppIntentSpec(
    name: 'app_inspector',
    group: 'app',
    summary:
        'Expand/collapse the world inspector pane and open/close '
        'its intent palette.',
  ),
  // Agent doc — the task surface.
  AppIntentSpec(
    name: 'agent_doc_state',
    group: 'doc',
    summary: 'Read the open agent doc projection (state, queue, verdict).',
  ),
  AppIntentSpec(
    name: 'agent_task_delegate',
    group: 'doc',
    summary: 'Delegate a task sentence to the focused/named agent doc.',
  ),
  AppIntentSpec(
    name: 'agent_permission_answer',
    group: 'doc',
    summary: 'Answer the pending permission (allow/reject).',
  ),
  AppIntentSpec(
    name: 'agent_doc_create',
    group: 'doc',
    summary: 'Create a new agent doc and open it.',
  ),
  AppIntentSpec(
    name: 'agent_doc_bind',
    group: 'doc',
    summary: 'Bind a workspace (and checker) onto the open agent doc.',
  ),
  AppIntentSpec(
    name: 'agent_task_guide',
    group: 'doc',
    summary: 'Feed operator guidance into a pending escalation.',
  ),
  AppIntentSpec(
    name: 'agent_doc_edit',
    group: 'doc',
    summary: 'Edit the agent doc payload as typed ops.',
  ),
  AppIntentSpec(
    name: 'doc_state',
    group: 'doc',
    summary: 'Read the doc editor state (blocks, surface).',
  ),
  AppIntentSpec(
    name: 'doc_discuss_block',
    group: 'doc',
    summary: 'Append text into the shared doc as a real op.',
  ),
  AppIntentSpec(
    name: 'doc_collapse',
    group: 'doc',
    summary: 'Collapse doc blocks to their summary state.',
  ),
  // Mesh — pairing, presence, the shared board.
  AppIntentSpec(
    name: 'mesh_host',
    group: 'mesh',
    summary: 'Host the mesh relay (main device) and get a pairing code.',
  ),
  AppIntentSpec(
    name: 'mesh_pair',
    group: 'mesh',
    summary: 'Pair with a peer via its pairing code.',
  ),
  AppIntentSpec(
    name: 'mesh_status',
    group: 'mesh',
    summary: 'Read mesh connectivity, peers and presence.',
  ),
  AppIntentSpec(
    name: 'mesh_open_doc',
    group: 'mesh',
    summary: 'Open a shared agent doc as a viewer shadow on a peer.',
  ),
  AppIntentSpec(
    name: 'mesh_join_doc',
    group: 'mesh',
    summary: 'Join a shared doc channel (presence).',
  ),
  AppIntentSpec(
    name: 'mesh_leave_doc',
    group: 'mesh',
    summary: 'Leave a shared doc channel.',
  ),
  AppIntentSpec(
    name: 'mesh_tasks',
    group: 'mesh',
    summary: 'Read the shared task board for a doc.',
  ),
  AppIntentSpec(
    name: 'mesh_task_dispatch',
    group: 'mesh',
    summary: 'Dispatch/steer tasks on the shared board.',
  ),
  AppIntentSpec(
    name: 'mesh_routing',
    group: 'mesh',
    summary: 'Toggle remote permission routing.',
  ),
  // Storage — backends and sync.
  AppIntentSpec(
    name: 'storage_state',
    group: 'storage',
    summary: 'Read the storage backend state.',
  ),
  AppIntentSpec(
    name: 'storage_select_backend',
    group: 'storage',
    summary: 'Select the storage backend.',
  ),
  AppIntentSpec(
    name: 'storage_set_path',
    group: 'storage',
    summary: 'Set the storage path.',
  ),
  AppIntentSpec(
    name: 'storage_set_primary',
    group: 'storage',
    summary: 'Set the primary backend.',
  ),
  AppIntentSpec(
    name: 'storage_set_enabled',
    group: 'storage',
    summary: 'Enable/disable a backend.',
  ),
  AppIntentSpec(
    name: 'storage_backup',
    group: 'storage',
    summary: 'Run a backup now.',
  ),
  AppIntentSpec(
    name: 'storage_restore',
    group: 'storage',
    summary: 'Restore from a backup.',
  ),
  AppIntentSpec(
    name: 'storage_mesh_sync',
    group: 'storage',
    summary: 'Run a mesh sync cycle now.',
  ),
  AppIntentSpec(
    name: 'storage_mesh_pairing_code',
    group: 'storage',
    summary: 'Get the mesh pairing code.',
  ),
  AppIntentSpec(
    name: 'storage_mesh_accept_pairing',
    group: 'storage',
    summary: 'Accept a mesh pairing code.',
  ),
  // World inspector — the read-only workbench.
  AppIntentSpec(
    name: 'world_inspector_state',
    group: 'inspector',
    summary: 'Read the world inspector projection (rule, needs, sample).',
  ),
  AppIntentSpec(
    name: 'world_inspector_seed',
    group: 'inspector',
    summary: 'Seed the deterministic scripted fixture (kind test).',
  ),
  AppIntentSpec(
    name: 'world_inspector_attach',
    group: 'inspector',
    summary: 'Attach the pane to an external harness world (read-only).',
  ),
  AppIntentSpec(
    name: 'world_inspector_detach',
    group: 'inspector',
    summary: 'Detach back to the in-process registry.',
  ),
];

/// The catalog plus the executable app-shell entries. The catalog tool
/// is the DISCOVERY half of the contract; the other three are the
/// actions the app shell owns that no doc/mesh/storage family carries
/// (where the user is, what the keyboard focus is, whether the
/// workbench is open).
Set<AgentCallEntry> appMcpEntries() => {
  mcpToolkitTool(
    handler: (final parameters) {
      final group = parameters['group'];
      final specs = group is String && group.isNotEmpty
          ? appIntentCatalog
                .where((final s) => s.group == group)
                .toList(growable: false)
          : appIntentCatalog;
      return MCPCallResult(
        message:
            '${specs.length} published intent(s)'
            '${group is String ? ' in group "$group"' : ''}. Drive each '
            'by its tool name; semantic grounding rides the toolkit '
            'a11y snapshot.',
        parameters: {
          'ok': true,
          'count': specs.length,
          'intents': [for (final s in specs) s.toJson()],
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'app_intents',
      description:
          'The app PUBLISHED intent catalog: every app-level action LA '
          'exposes to external drivers, as named data (name, group, '
          'summary). Discovery is the contract — read this before '
          'driving anything. Optional arg: group — one of app, doc, '
          'mesh, storage, inspector — to filter.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'group': {'type': 'string'},
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      final path = parameters['path'];
      if (path is! String || path.isEmpty) {
        return MCPCallResult(
          message:
              "path (string) is required — e.g. '/home', "
              "'/home/changelog', or '/home/d/<docId>'.",
          parameters: {'ok': false},
        );
      }
      final allowed = <String>{ScreenPaths.home, ScreenPaths.changelog};
      final isDocPath = RegExp(r'^/home/d/[A-Za-z0-9-]+$').hasMatch(path);
      if (!allowed.contains(path) && !isDocPath) {
        return MCPCallResult(
          message:
              "path '$path' is not a published route — try '/home', "
              "'/home/changelog', or '/home/d/<docId>'.",
          parameters: {'ok': false},
        );
      }
      try {
        appRouter.go(path);
        return MCPCallResult(
          message: "Navigated to '$path'.",
          parameters: {'ok': true, 'path': path},
        );
      } on Object catch (e) {
        return MCPCallResult(
          message:
              "Could not navigate to '$path' — the app shell is not "
              'running (${e.toString().split('\n').first}).',
          parameters: {'ok': false, 'path': path},
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'app_navigate',
      description:
          'Navigate the app shell to a published route: home, changelog, '
          'or an agent doc by docId. Honest refusal for anything else — '
          'the allowlist is the navigation contract.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description':
                "One of '/home', '/home/changelog', "
                "'/home/d/<docId>'.",
          },
        },
        'required': ['path'],
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      final action = parameters['action'] ?? 'focus';
      final surface = AgentDocSurface.debugSurface;
      if (action == 'focus') {
        if (surface == null) {
          return MCPCallResult(
            message:
                'No agent doc surface is open — open one first '
                "(app_navigate '/home/d/<docId>').",
            parameters: {'ok': false},
          );
        }
        final focused = surface.focusComposerFromIntent();
        return MCPCallResult(
          message: focused
              ? 'Composer focused — the task sentence IS the input.'
              : 'The surface went away before the composer took focus.',
          parameters: {'ok': focused, 'action': 'focus'},
        );
      }
      if (action == 'submit') {
        final text = parameters['text'];
        if (surface == null) {
          return MCPCallResult(
            message:
                'No agent doc surface is open — open one first '
                "(app_navigate '/home/d/<docId>').",
            parameters: {'ok': false},
          );
        }
        if (text is! String || text.trim().isEmpty) {
          return MCPCallResult(
            message:
                'text (string) is required for submit — the task '
                'sentence IS the input.',
            parameters: {'ok': false, 'action': 'submit'},
          );
        }
        final result = surface.delegateFromIntent(text);
        return MCPCallResult(
          message: result.message,
          parameters: {'ok': result.ok, 'action': 'submit'},
        );
      }
      return MCPCallResult(
        message: "action must be 'focus' or 'submit' (got '$action').",
        parameters: {'ok': false},
      );
    },
    definition: MCPToolDefinition(
      name: 'app_composer',
      description:
          'Focus the agent doc composer (the gesture-controller way to '
          'hand the keyboard over) or submit its task sentence through '
          'the SAME delegate path the keyboard takes. Requires an open '
          'agent doc surface.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'action': {
            'type': 'string',
            'enum': ['focus', 'submit'],
          },
          'text': {
            'type': 'string',
            'description': 'The task sentence (submit only).',
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      final action = parameters['action'] ?? 'toggle';
      final surface = WorldInspectorPane.debugSurface;
      if (surface == null) {
        return MCPCallResult(
          message:
              'No world inspector pane is mounted — it mounts under an '
              'open agent doc.',
          parameters: {'ok': false},
        );
      }
      switch (action) {
        case 'toggle':
          final expanded = surface.toggleFromIntent();
          return MCPCallResult(
            message: 'World inspector ${expanded ? 'expanded' : 'collapsed'}.',
            parameters: {'ok': true, 'expanded': expanded},
          );
        case 'expand' || 'collapse':
          final expanded = surface.toggleFromIntent(expand: action == 'expand');
          return MCPCallResult(
            message: 'World inspector ${expanded ? 'expanded' : 'collapsed'}.',
            parameters: {'ok': true, 'expanded': expanded},
          );
        case 'palette_open' || 'palette_close':
          final open = surface.paletteFromIntent(
            open: action == 'palette_open',
          );
          return MCPCallResult(
            message: 'Intent palette ${open ? 'open' : 'closed'}.',
            parameters: {'ok': true, 'paletteOpen': open},
          );
      }
      return MCPCallResult(
        message:
            'action must be one of toggle, expand, collapse, '
            "palette_open, palette_close (got '$action').",
        parameters: {'ok': false},
      );
    },
    definition: MCPToolDefinition(
      name: 'app_inspector',
      description:
          'Drive the world inspector surface: expand/collapse the pane, '
          'open/close the intent palette. The pane renders; the verbs '
          'it lists stay product-side (the read-only law) — this tool '
          'only moves the surface.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'action': {
            'type': 'string',
            'enum': [
              'toggle',
              'expand',
              'collapse',
              'palette_open',
              'palette_close',
            ],
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final snapshot = await DeviceCapabilitySnapshot.gather(
        installationService: AcpInstallationService(),
        hostedChatCredential:
            (parameters['hosted_chat_credential'] as bool?) ?? false,
      );
      return MCPCallResult(
        message:
            'This device\'s hosting capabilities, probed live '
            '(route by these facts, never by advertising).',
        parameters: {'ok': true, ...snapshot.toJson()},
      );
    },
    definition: MCPToolDefinition(
      name: 'device_capabilities',
      description:
          'What THIS device can host for the fleet: detected ACP agents, '
          'the Apple-foundation AFM lane, laya-serve reachability '
          '(probed), hosted-chat credential presence, and the LAN mesh '
          'state. Route decisions and tasks by these capability facts '
          '— transport membership alone never grants authority.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'hosted_chat_credential': {
            'type': 'boolean',
            'description':
                'Whether a hosted-model credential is resolvable on '
                'this device (the secure-store lookup is the '
                "caller's side).",
          },
        },
      }),
    ),
  ),
};
