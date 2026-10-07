import 'package:lastanswer/coding_agent/world_inspector/external_worlds_stub.dart'
    if (dart.library.io)
        'package:lastanswer/coding_agent/world_inspector/external_worlds_io.dart'
    as external_worlds;
import 'package:lastanswer/coding_agent/world_inspector/scripted_session_handle.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// Debug/profile MCP entries for the world inspector pane (registered in
/// `main.dart` inside `assert(() {})`, next to the doc and storage
/// entries) — headless drivers and agents read and seed the SAME pane the
/// human sees (product DESIGN §5: one state, many projections; §8: the
/// debugState projection is the agent contract).
///
/// - `world_inspector_state` — the pane's status rule + sample as data
///   ([WorldInspectorPane.lastProjection]) plus the registry's live
///   sessions; names the addressable registry keys.
/// - `world_inspector_seed` — registers [seedScriptedSessions] into the
///   session registry (kind `test`) and focuses the worker. SCRIPTED
///   FIXTURE, debug builds only: the output says so, and pane/verb output
///   never reads a seeded session as a live run (DESIGN §6).
Set<AgentCallEntry> worldInspectorMcpEntries() => {
  mcpToolkitTool(
    handler: (final parameters) {
      final projection = WorldInspectorPane.lastProjection;
      final sessions = [
        for (final entry
            in HarnessSessionRegistry.instance.sessions.entries)
          {
            'id': entry.key,
            ...entry.value.state.toJson(),
          },
      ];
      if (projection == null) {
        return MCPCallResult(
          message:
              'No world inspector pane is open (it mounts under an agent '
              'doc). Live sessions: ${sessions.length}.',
          parameters: {'ok': sessions.isNotEmpty, 'sessions': sessions},
        );
      }
      final pending = projection.sessions
          .where((final s) => s.pendingPermission != null)
          .length;
      final external = WorldInspectorPane.externalOverride.value != null;
      return MCPCallResult(
        message:
            'World inspector: ${projection.summary}'
            '${pending > 0 ? ' — answer via the doc surface verb '
                  'agent_permission_answer' : ''}'
            '${external ? ' (EXTERNAL world attached — read-only)' : ''}.',
        parameters: {
          'ok': true,
          'external': external,
          ...projection.toJson(),
          'sessions': sessions,
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'world_inspector_state',
      description:
          'Read the world inspector pane under the open agent doc: the '
          'status rule (live sessions, running, pending permissions), the '
          'inspector sample (rows, sampled session), and every live '
          'registry session with its beats. Equal reader of the pane the '
          'human sees — never a widget scrape.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // ATTACH to an external harness world (the daemon a ZCode/Codex
      // seat spawned): manifest scan → PAIRED registry (ADR 0072) →
      // http facade only. Read-only by
      // construction — the pane lists no verbs for an external source;
      // operation rides the client's own harnessd MCP seat (ADR 0040).
      final rawWorldId = parameters['worldId'];
      final worldId = rawWorldId is String ? rawWorldId : null;
      final source = await WorldInspectorPane.resolveExternal(
        worldId: worldId,
      );
      if (source == null) {
        WorldInspectorPane.externalOverride.value = null;
        final live = [
          for (final m in external_worlds.liveWorlds())
            {'worldId': m.worldId, 'workspace': m.workspace},
        ];
        final paired = await external_worlds.pairedWorldsJson();
        return MCPCallResult(
          message:
              'No attachable external world. Live manifests: $live. '
              'Paired worlds (ADR 0072): $paired. An attach needs the '
              "daemon's http facade — arm it with "
              'HARNESS_SERVE_PORT=<port> on the seat wrapper '
              '(harnessd --serve; HARNESS_SERVE_BIND=lan for a paired '
              'device). Spawning a new daemon is never an attach. '
              'Read-only either way.',
          parameters: {'ok': false, 'live': live, 'paired': paired},
        );
      }
      WorldInspectorPane.externalOverride.value = source;
      return MCPCallResult(
        message:
            'Attached the world inspector to the external harness '
            'world (http facade, read-only). The pane re-samples within '
            '~$_pollMs ms; world_inspector_attach with worldId absent '
            're-scans; set externalOverride to null to detach (verb: '
            'world_inspector_detach).',
        parameters: {'ok': true, 'external': true},
      );
    },
    definition: MCPToolDefinition(
      name: 'world_inspector_attach',
      description:
          'DEBUG ONLY — point the world inspector pane at an EXTERNAL '
          'harness world (the harnessd a ZCode/Codex seat spawned): '
          'scans ~/.xsoulspace/worlds manifests and attaches through the '
          'http serve facade (arg: worldId, optional). Read-only — no '
          'daemon is spawned and no verb executes externally. Needs the '
          'facade armed (HARNESS_SERVE_PORT on the seat wrapper).',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'worldId': {'type': 'string'},
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      WorldInspectorPane.externalOverride.value = null;
      return MCPCallResult(
        message: 'Detached — the pane samples the in-process registry '
            'again within ~$_pollMs ms.',
        parameters: {'ok': true, 'external': false},
      );
    },
    definition: MCPToolDefinition(
      name: 'world_inspector_detach',
      description:
          'DEBUG ONLY — detach the world inspector pane from an external '
          'harness world and return to the in-process session registry.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // ADR 0072 §5 — the PHONE side of the seat rung: reads the paired
      // registry (the announcement the signed pairing carried), requests
      // the seat in-app, and drives agent_doc_state over the channel.
      // DEBUG ONLY (the toolkit is a VM-service debug channel).
      // Args win; absent → the paired registry's first world answers
      // (host/port/token from the SIGNED announcement).
      final rawHost = parameters['host'];
      final rawPort = parameters['port'];
      final rawToken = parameters['token'];
      String? host = rawHost is String ? rawHost : null;
      // Switch-case promotion (the ternary form fights this analyzer
      // across the dynamic map boundary — measured).
      int? port = rawPort == null ? null : int.tryParse(rawPort);
      String? token = rawToken is String ? rawToken : null;
      if (host == null || port == null || (token == null || token.isEmpty)) {
        final paired = await external_worlds.pairedWorldsJson();
        if (paired.isEmpty) {
          return MCPCallResult(
            message:
                'No paired worlds — pair first (storage_mesh_pairing_code '
                'on the host, storage_mesh_accept_pairing here).',
            parameters: {'ok': false, 'paired': paired},
          );
        }
        final world = paired.first;
        // The announcement shape: {worldId, endpoint, token, seatWs?}.
        final seatWs = world['seatWs'];
        final t = world['token'];
        if (seatWs is! String ||
            seatWs.isEmpty ||
            t is! String ||
            t.isEmpty) {
          return MCPCallResult(
            message:
                'The paired world announces no usable seat channel — arm '
                'the daemon with --seat-ws (ADR 0072 §5).',
            parameters: {'ok': false, 'paired': paired},
          );
        }
        final uri = Uri.tryParse(seatWs);
        if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
          return MCPCallResult(
            message: 'Bad seatWs endpoint in the announcement: $seatWs',
            parameters: {'ok': false},
          );
        }
        host = uri.host;
        port = uri.port;
        token = t;
      }
      final seatHost = host;
      final seatPort = port;
      final seatToken = token;
      if (seatHost.isEmpty || seatPort <= 0 || seatToken.isEmpty) {
        return MCPCallResult(
          message: 'Seat endpoint incomplete after resolution.',
          parameters: {'ok': false},
        );
      }
      final rawActor = parameters['actor'];
      final actor = rawActor is String ? rawActor : 'phone-1';
      final client = HarnessSeatWsClient(
        host: seatHost,
        port: seatPort,
        token: seatToken,
      );
      try {
        final seat = await client
          .requestSeat(actor: actor)
          .timeout(const Duration(seconds: 15));
        final state = await client
            .callTool('agent_doc_state', <String, Object?>{})
            .timeout(const Duration(seconds: 30));
        return MCPCallResult(
          message:
              'Seat granted (allowlist: ${seat.tools.toList()..sort()}); '
              'agent_doc_state over the seat channel: '
              'ok=${state['ok']} docId=${state['docId']}.',
          parameters: {
            'ok': true,
            'allowlist': seat.tools.toList()..sort(),
            'state': state,
          },
        );
      } on Object catch (e) {
        return MCPCallResult(
          message: 'Seat channel failed: ${e.toString().split('\n').first}',
          parameters: {'ok': false},
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'world_inspector_seat_probe',
      description:
          'DEBUG ONLY — the paired-device seat rung (ADR 0072 §5): '
          "request this device's seat from the host seat channel and "
          'drive agent_doc_state over it. Args optional when a paired '
          'world is announced: host, port, token, actor.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'host': {'type': 'string'},
          'port': {'type': 'integer'},
          'token': {'type': 'string'},
          'actor': {'type': 'string'},
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      final registry = HarnessSessionRegistry.instance;
      final seeded = seedScriptedSessions();
      for (final entry in registry.sessions.entries) {
        if (entry.key.startsWith('seed-')) {
          registry.unregister(entry.key, entry.value);
        }
      }
      for (final entry in seeded.entries) {
        registry.register(entry.key, entry.value);
      }
      registry.focused = 'seed-worker';
      return MCPCallResult(
        message:
            'Seeded ${seeded.length} scripted sessions '
            '(${seeded.keys.join(', ')}) and focused seed-worker. '
            'Scripted fixture — no real actors ran; the world inspector '
            'pane samples them within ~$_pollMs ms.',
        parameters: {
          'ok': true,
          'seeded': [
            for (final entry in seeded.entries)
              {
                'id': entry.key,
                'running': entry.value.state.running,
                'beats': entry.value.state.beats.length,
                'pendingPermission':
                    entry.value.state.pendingPermissionTitle,
              },
          ],
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'world_inspector_seed',
      description:
          'DEBUG ONLY — replace the seed- session fixtures with the '
          'deterministic scripted pair (a RUNNING worker with a tool-beat '
          'trail; an idle planner with verdict/spend and a pending '
          'permission) and focus the worker, so the world inspector pane '
          'and its bands can be exercised without a provider or daemon. '
          'Never reads as a live run.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
};

const int _pollMs = 500;

Map<String, Object?> _emptySchema() => {
  'type': 'object',
  'properties': <String, Object?>{},
};
