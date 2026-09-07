import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
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
          "Send escalation guidance for the open agent doc's LAST ended "
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
  mcpToolkitTool(
    handler: (final parameters) {
      // Multiplayer gates (docs/product/multiplayer-device-gates.md T2/T3)
      // — read from the LIVE mesh replica the app owns
      // (StorageBackendsNotifier.ensureMeshService); never a UI scrape.
      // The doc channel matches the doc surface's deterministic mesh id
      // ('agent-<docId>'), so an agent reads the same presence the
      // surface joins on open.
      final service = StorageBackendsNotifier.instance.meshService;
      if (service == null) {
        return MCPCallResult(
          message:
              'No mesh replica is open on this device — call mesh_host '
              '(main device) or mesh_pair (joining device) first.',
          parameters: {
            'ok': false,
            'hosting': false,
            'connected': false,
            'peerCount': 0,
          },
        );
      }
      final requested = parameters['docId'];
      final docId = requested is String && requested.isNotEmpty
          ? requested
          : AgentDocSurface.debugState?.docId;
      final channel = docId == null ? null : _meshChannel(docId);
      final presence = channel == null
          ? const <Never>[]
          : service.presence(channel);
      final presenceCount = channel == null ? null : presence.length;
      final presenceJson = channel == null
          ? null
          : [
              for (final entry in presence)
                {
                  'peerId': entry.peerId,
                  'lastEvent': entry.lastEvent.name,
                  'expiresAt': entry.expiresAt.toIso8601String(),
                },
            ];
      final endpoint =
          service.advertisedEndpoint ?? service.connectedEndpoint;
      return MCPCallResult(
        message:
            'Mesh: ${service.isHosting ? 'HOSTING' : 'joined'}, '
            '${service.isConnected ? 'connected' : 'NOT connected'}'
            '${endpoint == null ? '' : ' via $endpoint'}; '
            '${service.peers.length} peer(s)'
            '${service.connectError == null
                ? ''
                : '; last connect error: ${service.connectError}'}'
            '${channel == null
                ? ''
                : '; ${presence.length} present on $channel'}.',
        parameters: {
          'ok': true,
          'hosting': service.isHosting,
          'connected': service.isConnected,
          'connectError': ?service.connectError?.toString(),
          if (endpoint != null) 'endpoint': endpoint.toString(),
          'peerCount': service.peers.length,
          'peers': [for (final peer in service.peers) peer.peerId],
          'docChannel': ?channel,
          'presenceCount': ?presenceCount,
          'presence': ?presenceJson,
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'mesh_status',
      description:
          'Read the live mesh status of this device: hosting (relay '
          'running), connected (transport up), endpoint, registered peer '
          'count, and — when a doc id is known (the open agent doc by '
          'default, or the explicit docId) — the live presence entries on '
          'the doc channel (agent-<docId>).',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'docId': {
            'type': 'string',
            'description':
                'Agent doc id whose presence channel to read '
                '(defaults to the open agent doc).',
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // The app's own main-device path (seamless setup step "this is my
      // main device"): hosts the relay, persists the role + advertised
      // endpoint, enables mesh replication. Web (no dart:io) cannot
      // host — the failure is reported as named data, never swallowed.
      final notifier = StorageBackendsNotifier.instance;
      final service = await notifier.ensureMeshService();
      try {
        await notifier.becomeMainDevice();
      } on Object catch (error) {
        // Web (and other non-IO platforms) throw UnsupportedError — an
        // Error, not an Exception — so this must stay broad.
        if (error is! UnsupportedError) rethrow;
        return MCPCallResult(
          message:
              'This platform cannot host the relay (no dart:io): '
              '${error.message}',
          parameters: {'ok': false, 'hosting': false},
        );
      }
      try {
        final pairingCode = await service.createPairingCode();
        return MCPCallResult(
          message:
              'Hosting the relay at ${service.advertisedEndpoint}; a '
              'signed pairing code is ready — paste it into the peer '
              '(mesh_pair or the join-with-code flow).',
          parameters: {
            'ok': true,
            'hosting': service.isHosting,
            'endpoint': service.advertisedEndpoint?.toString(),
            'pairingCode': pairingCode,
          },
        );
      } on Object catch (error) {
        return MCPCallResult(
          message: 'Hosting started but the pairing code failed: $error',
          parameters: {
            'ok': false,
            'hosting': service.isHosting,
            'endpoint': service.advertisedEndpoint?.toString(),
          },
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'mesh_host',
      description:
          'Start hosting the mesh relay on this device (the "main '
          'device" role) and produce a signed mesh-pair/v1 pairing code. '
          'Returns the LAN endpoint and the pairing payload the peer '
          'pastes (mesh_pair). Requires dart:io (macOS/desktop, not '
          'web).',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // The paste path (the QR scan itself stays human): the payload the
      // main device printed (or its QR encodes) is accepted verbatim —
      // base64 with arbitrary whitespace or raw mesh-pair/v1 text.
      final code = parameters['pairingCode'];
      if (code is! String || code.isEmpty) {
        return MCPCallResult(
          message:
              'pairingCode (the pasted mesh-pair/v1 payload) is '
              'required.',
          parameters: {'ok': false},
        );
      }
      final notifier = StorageBackendsNotifier.instance;
      final service = await notifier.ensureMeshService();
      try {
        final peer = await service.acceptPairingCode(code);
        // One convergence cycle right after joining: flush + absorb so
        // the joiner\'s doc replicas and roster meet the peer\'s state
        // (best-effort — a failed first sync is reported, pairing stays).
        var synced = true;
        try {
          await service.sync();
          StorageBackendsNotifier.onSyncCycle?.call();
        } on Exception {
          synced = false;
        }
        return MCPCallResult(
          message:
              'Paired with ${peer.peerId}'
              '${service.isConnected
                  ? ' and connected to its relay'
                  : ' (relay NOT connected)'}; '
              'convergence ${synced
                  ? 'cycle ran'
                  : 'cycle FAILED — retry with storage_mesh_sync'}.',
          parameters: {
            'ok': true,
            'peerId': peer.peerId,
            'connected': service.isConnected,
            'endpoint': service.connectedEndpoint?.toString(),
            'synced': synced,
          },
        );
      } on FormatException catch (error) {
        return MCPCallResult(
          message: 'Invalid pairing code: $error',
          parameters: {'ok': false},
        );
      } on Object catch (error) {
        return MCPCallResult(
          message: 'Pairing failed: $error',
          parameters: {'ok': false},
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'mesh_pair',
      description:
          'Accept a pasted mesh pairing payload (base64 or raw '
          'mesh-pair/v1 text — the paste path of a QR scan): verifies '
          'it, '
          'registers the peer, connects to its advertised relay '
          'automatically, and runs one convergence cycle.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'pairingCode': {
            'type': 'string',
            'description': 'The pairing payload as pasted (whitespace '
                'and newlines tolerated).',
          },
        },
        'required': ['pairingCode'],
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // Doc-scoped presence (ADR 0031 §1): the channel is the doc
      // surface\'s deterministic mesh id (agent-<docId>), so an agent
      // joins the exact channel the open doc\'s surface already rides.
      final service = StorageBackendsNotifier.instance.meshService;
      if (service == null) {
        return MCPCallResult(
          message:
              'No mesh replica is open on this device — call mesh_host '
              'or mesh_pair first.',
          parameters: {'ok': false},
        );
      }
      final requested = parameters['docId'];
      final docId = requested is String && requested.isNotEmpty
          ? requested
          : AgentDocSurface.debugState?.docId;
      if (docId == null) {
        return MCPCallResult(
          message:
              'docId is required (no agent doc surface is open to '
              'default to).',
          parameters: {'ok': false},
        );
      }
      final channel = _meshChannel(docId);
      await service.joinDoc(channel);
      final presence = service.presence(channel);
      return MCPCallResult(
        message:
            'Joined $channel; ${presence.length} present '
            '(self included: '
            '[${presence.map((final e) => e.peerId).join(', ')}]).',
        parameters: {
          'ok': true,
          'docId': docId,
          'docChannel': channel,
          'presenceCount': presence.length,
          'presence': [for (final entry in presence) entry.peerId],
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'mesh_join_doc',
      description:
          'Join the doc-scoped presence channel (agent-<docId>) of the '
          'open agent doc (or the explicit docId): announces the '
          'presence of THIS device to peers and receives theirs.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'docId': {
            'type': 'string',
            'description':
                'Agent doc id (defaults to the open agent doc).',
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // The signed leave frame goes out immediately so peers drop this
      // device without waiting for the ttl sweep (ADR 0031 §1).
      final service = StorageBackendsNotifier.instance.meshService;
      if (service == null) {
        return MCPCallResult(
          message:
              'No mesh replica is open on this device (nothing to '
              'leave).',
          parameters: {'ok': false},
        );
      }
      final requested = parameters['docId'];
      final docId = requested is String && requested.isNotEmpty
          ? requested
          : AgentDocSurface.debugState?.docId;
      if (docId == null) {
        return MCPCallResult(
          message:
              'docId is required (no agent doc surface is open to '
              'default to).',
          parameters: {'ok': false},
        );
      }
      final channel = _meshChannel(docId);
      await service.leaveDoc(channel);
      return MCPCallResult(
        message: 'Left $channel (leave frame sent).',
        parameters: {'ok': true, 'docId': docId, 'docChannel': channel},
      );
    },
    definition: MCPToolDefinition(
      name: 'mesh_leave_doc',
      description:
          'Leave the doc-scoped presence channel (agent-<docId>) of the '
          'open agent doc (or the explicit docId): a signed leave frame '
          'is sent so peers drop this device immediately.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'docId': {
            'type': 'string',
            'description':
                'Agent doc id (defaults to the open agent doc).',
          },
        },
      }),
    ),
  ),
};

/// The doc presence channel id — MUST match the doc surface's
/// deterministic mesh doc id (`AgentDocSurface` joins `agent-<docId>`
/// on open), so agent verbs and the human flow ride ONE channel.
String _meshChannel(final String docId) => 'agent-$docId';

Map<String, Object?> _emptySchema() => {
  'type': 'object',
  'properties': <String, Object?>{},
};
