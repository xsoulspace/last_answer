import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/permission_doc_router.dart';
import 'package:lastanswer/coding_agent/product_agent_mcp_tools.dart';
import 'package:lastanswer/settings/features/live_mesh_service.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// ADR 0003 (Phase 3 core) — MCP/intent entries that let ANY agent (pi,
/// opencode, another harness) inspect and drive the agent-doc surface
/// headlessly. Same typed state the human screen renders — the UI is just
/// another projection ([AgentDocSurface.debugState]).
///
/// ADR 0009 (D1/D2) — the three doc verbs (`agent_doc_state`,
/// `agent_task_delegate`, `agent_permission_answer`) resolve their target
/// through the session REGISTRY (`HarnessSessionRegistry`, the host
/// layer's one index of live sessions — never a widget static): an
/// optional `docId` names the session exactly (doc surfaces register
/// under their mesh replica id `agent-<docId>`; the raw doc id is the
/// alias the other mesh verbs carry); absent, the ONLY live session; if
/// several are live, the FOCUSED one (device-local last interaction); if
/// still ambiguous, an error that NAMES the live sessions — never a
/// silent wrong-target answer (DESIGN §6).
///
/// Registered in debug/profile builds (see `main.dart`), next to the doc
/// and storage entries.
Set<AgentCallEntry> agentMcpEntries() => {
  ...productAgentMcpEntries(),
  mcpToolkitTool(
    handler: (parameters) async {
      try {
        final handle = _resolveSession(parameters);
        if (handle is! AgentDocHandle) {
          return MCPCallResult(
            message: 'Open the owning agent document.',
            parameters: {
              'ok': false,
              'error': 'meaning_owner_surface_required',
            },
          );
        }
        final result = await handle.meaningAction(
          parameters['action']!,
        );
        return MCPCallResult(
          message: '${result['error'] ?? 'Meaning experiment receipt'}',
          parameters: result,
        );
      } on SessionResolutionException catch (error) {
        return _resolutionError(error);
      }
    },
    definition: MCPToolDefinition(
      name: 'agent_meaning_change',
      description:
          'Preview, apply, rollback or finalize the explicitly bound greeting '
          'experiment through the owning document session.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'docId': {'type': 'string'},
          'action': {
            'type': 'string',
            'enum': ['preview', 'apply', 'rollback', 'finalize', 'status'],
          },
        },
        'required': ['action'],
        'additionalProperties': false,
      }),
    ),
  ),

  mcpToolkitTool(
    handler: (final parameters) {
      try {
        // D1 — the REGISTRY is the source of truth: the resolved handle
        // carries the state, never a widget static. A registered doc
        // surface projects the full doc state (the queue rides along);
        // any other handle (a daemon runner, a scripted seam) exposes the
        // host snapshot.
        final handle = _resolveSession(parameters);
        final snapshot = handle.state;
        final Map<String, Object?> stateJson;
        final String docId;
        final String message;
        if (handle is AgentDocHandle) {
          final state = handle.debugState;
          docId = state.docId;
          stateJson = state.toJson();
          message = _docStateMessage(state);
        } else {
          docId = snapshot.sessionId;
          stateJson = snapshot.toJson();
          final spend = snapshot.spend == null ? '' : ' · ${snapshot.spend}';
          message =
              'Session $docId (${snapshot.kind}): '
              '${snapshot.running ? 'RUNNING' : 'idle'}, '
              '${snapshot.turnCount} turn(s), '
              '${snapshot.beats.length} beat(s)$spend'
              '${snapshot.verdict == null
                  ? ''
                  : ', verdict: ${snapshot.verdict}'}'
              '${snapshot.pendingPermissionTitle == null
                  ? ''
                  : ' — the permission prompt '
                        '(${snapshot.pendingPermissionTitle}) is awaiting '
                        'an answer'}';
        }
        return MCPCallResult(
          message: message,
          parameters: {
            'ok': true,
            ...stateJson,
            // The registry truth (D1): the addressable key the handle
            // resolved under and the host-layer snapshot.
            'docId': docId,
            'registryKey': ?_registryKeyOf(handle),
            'session': snapshot.toJson(),
          },
        );
      } on SessionResolutionException catch (error) {
        // Task O — the peer SHADOW fallback: with NO live session, the
        // viewer projection (mesh_open_doc) answers as before — the peer
        // flow must not regress. With live sessions, the error NAMES them
        // (never a silent wrong-target answer, DESIGN §6).
        if (error.liveSessions.isEmpty) {
          final shadow = AgentDocSurface.shadowDoc?.toDebugState();
          if (shadow != null) {
            return MCPCallResult(
              message: _docStateMessage(shadow),
              parameters: {'ok': true, ...shadow.toJson()},
            );
          }
        }
        return _resolutionError(error);
      }
    },
    definition: MCPToolDefinition(
      name: 'agent_doc_state',
      description:
          'Get the state of the open agent doc: bound workspaces, '
          'backend, session id, running flag, pending permission title, '
          'latest verdict, the transcript tail, and the message queue '
          '(queue[]: id, text, status open/superseded/delivered, lane '
          'from→to, position, age — queued messages flush in order after '
          'the running turn lands). With several docs open, pass docId to '
          'address one exactly; absent, the focused doc resolves '
          '(ambiguity is refused with the live sessions named).',
      inputSchema: ObjectSchema.fromMap(harnessDocStateSchema),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) =>
        _sessionResult(_sessionTools.taskDelegate(parameters)),
    definition: MCPToolDefinition(
      name: 'agent_task_delegate',
      description:
          'Delegate a task sentence to the open agent doc (host-injected '
          'decision; the turn runs with the doc-bound runtime). With '
          'several docs open, pass docId to address one exactly; absent, '
          'the focused doc resolves. Returns immediately; poll '
          'agent_doc_state for progress/verdict.',
      inputSchema: ObjectSchema.fromMap(harnessTaskDelegateSchema),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final allow = HarnessSessionTools.parseAllow(
        parameters['allow'],
        acceptAliases: false,
      );
      if (allow == null) {
        return _sessionResult(
          _sessionTools.permissionAnswer(parameters, acceptAliases: false),
        );
      }
      try {
        return _sessionResult(
          _sessionTools.permissionAnswer(
            parameters,
            throwResolutionErrors: true,
            acceptAliases: false,
          ),
        );
      } on SessionResolutionException catch (error) {
        // Task O (P1) — the PEER path: with NO live session, a shadow doc
        // (mesh_open_doc) with a pending REMOTE permission answers
        // through the doc router — the answer is an op on the shared
        // `perm/<requestId>` register; the host's future completes when
        // it folds back with the next sync. With live sessions, the error
        // NAMES them (never a silent wrong-target answer).
        if (error.liveSessions.isEmpty) {
          final shadow = AgentDocSurface.shadowDoc;
          if (shadow != null) {
            final result = await shadow.answerRemotePermission(allow: allow);
            return MCPCallResult(
              message: result.message,
              parameters: {'ok': result.ok},
            );
          }
        }
        return _resolutionError(error);
      }
    },
    definition: MCPToolDefinition(
      name: 'agent_permission_answer',
      description:
          'Answer the pending permission round-trip of the open agent '
          'doc (allow = the write/edit proceeds; reject = it never '
          'lands). Deny-by-default: with no answer the write is '
          'rejected. With several docs open, pass docId to address one '
          'exactly; absent, the focused doc resolves.',
      inputSchema: ObjectSchema.fromMap(harnessPermissionAnswerSchema),
    ),
  ),
  mcpToolkitTool(
    handler: (parameters) async {
      final hook = AgentDocSurface.createMeaningExperimentHook;
      final result = hook == null
          ? <String, Object?>{'ok': false, 'error': 'meaning_entry_unavailable'}
          : await hook();
      return MCPCallResult(
        message: result['ok'] == true
            ? 'Prepared and opened reversible change experiment.'
            : '${result['error']}',
        parameters: result,
      );
    },
    definition: MCPToolDefinition(
      name: 'agent_meaning_experiment_create',
      description: 'Prepare and open the app-owned reversible change experiment.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
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
          '(literal argv, whitespace-split — e.g. "dart analyze") '
          'onto the open agent doc. '
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
      final live = StorageBackendsNotifier.instance.liveMesh;
      if (live == null) {
        return MCPCallResult(
          message:
              'The live plane is not attached on this device (mesh '
              'unconfigured, or the plane failed to open — the mesh '
              'itself keeps working).',
          parameters: {'ok': false, 'live': false},
        );
      }
      final action = parameters['action'];
      if (action == 'publish') {
        // Agents always publish (the privacy law gates HUMANS, not
        // agents — watching agents is the point of the plane).
        final requested = parameters['verb'];
        final verb = requested is String && LiveVerbs.all.contains(requested)
            ? requested
            : LiveVerbs.thinking;
        final docId = parameters['docId'] is String
            ? parameters['docId'] as String
            : null;
        final detail = parameters['detail'] is String
            ? parameters['detail'] as String
            : null;
        final peerId = StorageBackendsNotifier.instance.meshPeerId;
        await live.publish(
          LiveActor(
            actorId: 'agent-$peerId',
            displayName: 'Agent',
            isAgent: true,
            verb: verb,
            docId: docId,
            detail: detail,
            since: DateTime.now().toUtc(),
          ),
        );
        return MCPCallResult(
          message: docId == null
              ? 'Published live activity: $verb.'
              : 'Published live activity: $verb on $docId.',
          parameters: {'ok': true, 'verb': verb, 'docId': docId},
        );
      }
      final actors = live.actors;
      final summary = actors.isEmpty
          ? 'Nobody is live right now.'
          : 'Live actors: '
              '${actors.map((final a) => a.docId == null ? '${a.displayName} (${a.verb})' : '${a.displayName} (${a.verb} on ${a.docId})').join(', ')}'
              '.';
      return MCPCallResult(
        message: summary,
        parameters: {
          'ok': true,
          'live': true,
          'actors': [for (final actor in actors) actor.toJson()],
          'cursors': [
            for (final cursor in live.cursors.values) cursor.toJson(),
          ],
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'live_presence',
      description:
          'The live multiplayer picture: who is on the mesh right now '
          "and what each actor — human or agent — is doing (verb, doc "
          "focus). action=publish announces THIS agent's activity so "
          'the human and other devices can watch it work. Privacy law: '
          'human activity appears only when its device opted in to '
          'sharing; agent activity always flows.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'action': {
            'type': 'string',
            'enum': ['read', 'publish'],
            'description':
                "read (default) returns the live picture; publish "
                "announces this agent's activity.",
          },
          'verb': {
            'type': 'string',
            'enum': LiveVerbs.all,
            'description':
                'publish: what this agent is doing (default thinking).',
          },
          'docId': {
            'type': 'string',
            'description': 'publish: the doc this agent is working on.',
          },
          'detail': {
            'type': 'string',
            'description':
                'publish: short human-readable detail of the activity.',
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
        // Task O — the projection must match the live service within one
        // cycle: hosting just changed, so the open surface re-projects
        // immediately (the T3 gate diffs debugState byte-for-byte).
        StorageBackendsNotifier.onSyncCycle?.call();
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
      // Task O — presence changed: re-project the open surface now, not
      // on the next frame (the agent projection must match the live
      // service within one cycle).
      StorageBackendsNotifier.onSyncCycle?.call();
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
      // Task O — presence changed: re-project the open surface now.
      StorageBackendsNotifier.onSyncCycle?.call();
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
  mcpToolkitTool(
    handler: (final parameters) {
      // Task O (P1) — flips the owner device's remote permission routing
      // policy through the SAME state the PROFILE toggle renders (the
      // controller's `remotePermissionRouting`; the toggle's onTap calls
      // exactly this surface method — one state, many projections).
      // Service-extension transport carries values as strings.
      final raw = parameters['enabled']?.toString().toLowerCase();
      final on = raw == 'true';
      final off = raw == 'false';
      if (!on && !off) {
        return MCPCallResult(
          message: 'enabled (bool) is required.',
          parameters: {'ok': false},
        );
      }
      final surface = AgentDocSurface.debugSurface;
      if (surface == null) {
        return MCPCallResult(
          message:
              'No agent doc surface is currently open — routing is a '
              'policy of the doc session that OWNS the permissions.',
          parameters: {'ok': false},
        );
      }
      final result = surface.setRemoteRouting(enabled: on);
      return MCPCallResult(
        message: result.message,
        parameters: {
          'ok': result.ok,
          'remotePermissionRouting':
              AgentDocSurface.debugState?.remotePermissionRouting ?? false,
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'mesh_routing',
      description:
          'Enable or disable remote permission routing on the open agent '
          'doc (the PROFILE ROUTING toggle, host-injected): ON announces '
          'pending permissions as doc ops paired peers can answer '
          '(reject-first); OFF keeps answering local, byte for byte.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'enabled': {
            'type': 'boolean',
            'description': 'True to announce pending permissions as doc '
                'ops, false to answer locally only.',
          },
        },
        'required': ['enabled'],
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // Task O (P0) — the PEER opens the shared doc: a SHADOW agent doc
      // bound to the shared id — no workspace, no daemon session (the
      // peer is a viewer/answerer; the host owns the world). From here
      // the peer's agent_doc_state is an honest ok:true projection of
      // the SHARED doc id, live mesh status, and the routed permission
      // round-trips folded from the mesh.
      final docId = parameters['docId'];
      if (docId is! String || docId.isEmpty) {
        return MCPCallResult(
          message:
              'docId (string) is required — the shared agent doc id the '
              'host reported.',
          parameters: {'ok': false},
        );
      }
      final notifier = StorageBackendsNotifier.instance;
      final service = notifier.meshService;
      final store = notifier.docReplicaStore;
      if (service == null || store == null) {
        return MCPCallResult(
          message:
              'No mesh replica is live on this device — pair first '
              '(mesh_pair, or mesh_host on the main device).',
          parameters: {'ok': false, 'viewer': true, 'docId': docId},
        );
      }
      final channel = _meshChannel(docId);
      // Open the SHARED replica in this device's store: absorbRemote
      // only folds docs the store opened, so the shadow's permission
      // round-trips converge only after this.
      await store.open(NodeId(channel));
      // The shadow's status reader: the app wiring when installed, else
      // the live service directly — the projection is live either way.
      AgentDocMeshStatus statusForShadow(final String channelId) =>
          AgentDocSurface.meshWiring?.statusFor(channelId) ??
          AgentDocMeshStatus(
            hosting: service.isHosting,
            connected: service.isConnected,
            peerCount: service.peers.length,
            presenceCount: service.presence(channelId).length,
          );
      final shadow = AgentDocShadow(
        docId: docId,
        meshDocId: channel,
        router: PermissionDocRouter(
          store: store,
          docId: NodeId(channel),
          selfId: service.selfId,
        ),
        roster: notifier.actorRoster,
        statusFor: statusForShadow,
        // PLAN 6.C — the console rows ride the shadow projection (the
        // viewer READS the board; it never claims or runs requests).
        tasksFor: () {
          final board = notifier.taskBoard;
          if (board == null) return const <Map<String, Object?>>[];
          return [
            for (final record in board.tasksFor(docId))
              meshTaskRecordJson(record),
          ];
        },
      );
      AgentDocSurface.shadowDoc = shadow;
      // Presence follows the open doc (ADR 0031 §1) — the same channel
      // the host's surface rides. Idempotent with mesh_join_doc.
      await service.joinDoc(channel);
      // Task O — presence changed: re-project the open surface now.
      StorageBackendsNotifier.onSyncCycle?.call();
      final state = shadow.toDebugState();
      final mesh = state.meshStatus;
      return MCPCallResult(
        message:
            'Shadow agent doc $docId open (viewer, no workspace, no '
            'daemon session): ${mesh?.presenceCount ?? 0} present on '
            '$channel; pending remote permission: '
            '${state.pendingPermissionTitle ?? 'none'}.',
        parameters: {'ok': true, ...state.toJson()},
      );
    },
    definition: MCPToolDefinition(
      name: 'mesh_open_doc',
      description:
          'On a PAIRED peer: open the shared agent doc as a viewer shadow '
          'bound to the shared docId (no workspace, no daemon session — '
          'the host owns the world). After this, agent_doc_state returns '
          'ok with the shared docId, viewer: true, live meshStatus, and '
          'routed permissions as they fold in; agent_permission_answer '
          'answers remote pending permissions through the doc.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'docId': {
            'type': 'string',
            'description':
                'The shared agent doc id (the host surface reports it as '
                'docId).',
          },
        },
        'required': ['docId'],
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // Task O (P2) — scripted block edits as REAL doc ops: one append
      // op into the shared doc's replica (RGA text lane); the mesh sync
      // cycle ships it and every replica folds it (kernel-owned
      // convergence).
      final text = parameters['text'];
      if (text is! String || text.isEmpty) {
        return MCPCallResult(
          message: 'text (string) is required.',
          parameters: {'ok': false},
        );
      }
      final store = StorageBackendsNotifier.instance.docReplicaStore;
      if (store == null) {
        return MCPCallResult(
          message:
              'No mesh doc-replica store is live on this device — call '
              'mesh_host or mesh_pair first.',
          parameters: {'ok': false},
        );
      }
      final requested = parameters['docId'];
      final docId = requested is String && requested.isNotEmpty
          ? requested
          : AgentDocSurface.debugState?.docId ??
                AgentDocSurface.shadowDoc?.docId;
      if (docId == null) {
        return MCPCallResult(
          message:
              'docId is required (no agent doc is open or shadowed to '
              'default to).',
          parameters: {'ok': false},
        );
      }
      final channel = _meshChannel(docId);
      final rawBlock = parameters['blockId'];
      final blockId = rawBlock is String && rawBlock.isNotEmpty
          ? rawBlock
          : 'block-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
      final ops = await store.edit(NodeId(channel), (final replica) {
        final block = NodeId(blockId);
        final exists = replica.orderKeyOf(NodeId(channel), block) != null;
        return exists
            ? replica.appendText(block, text)
            : replica.addBlock(
                Block(id: block, type: BlockType.paragraph, content: text),
              );
      });
      return MCPCallResult(
        message:
            'Appended ${text.length} chars to $blockId in $channel '
            '(${ops.length} ops); the mesh sync cycle ships it.',
        parameters: {
          'ok': true,
          'docId': docId,
          'docChannel': channel,
          'blockId': blockId,
          'ops': ops.length,
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'agent_doc_edit',
      description:
          'Append text to a block of the open (or shadowed) agent doc as '
          'a REAL doc op (RGA text lane in the shared replica): the block '
          'is created when missing, appended to when present. The mesh '
          'sync cycle ships the op to peers.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'text': {'type': 'string'},
          'blockId': {
            'type': 'string',
            'description':
                'Block to append to (created when missing; defaults to a '
                'fresh block id).',
          },
          'docId': {
            'type': 'string',
            'description':
                'Agent doc id (defaults to the open or shadowed doc).',
          },
        },
        'required': ['text'],
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      // PLAN 6.C — the mesh task console, dispatch side: the task is a
      // REAL row on the shared CRDT board (kernel LWW via the mesh sync
      // substrate) — the device with the bound workspace auto-runs it
      // and writes the verdict back as board data. Read from the LIVE
      // board the app owns (StorageBackendsNotifier), never a local
      // stub — same discipline as the other mesh verbs.
      final requestedDoc = parameters['docId'];
      if (requestedDoc is! String || requestedDoc.isEmpty) {
        return MCPCallResult(
          message: 'docId (string) is required — the shared agent doc id.',
          parameters: {'ok': false},
        );
      }
      final task = parameters['task'];
      if (task is! String || task.isEmpty) {
        return MCPCallResult(
          message: 'task (string) is required.',
          parameters: {'ok': false},
        );
      }
      final notifier = StorageBackendsNotifier.instance;
      final board = notifier.taskBoard;
      if (board == null) {
        return MCPCallResult(
          message:
              'No mesh task board is attached on this device — host or '
              'pair first (mesh_host, or mesh_pair on the peer); the '
              'board mounts with the mesh replica.',
          parameters: {'ok': false},
        );
      }
      final service = notifier.meshService;
      if (service == null) {
        return MCPCallResult(
          message:
              'No mesh replica is open on this device — call mesh_host '
              'or mesh_pair first.',
          parameters: {'ok': false},
        );
      }
      // Origin actor when the OPEN doc is the target (ADR 0007: identity,
      // never authority — the same attached-actor attribution the routed
      // permission announcements carry).
      final state = AgentDocSurface.debugState;
      final originActorId = state != null && state.docId == requestedDoc
          ? state.sessionActors.values.expand((final ids) => ids).firstOrNull
          : null;
      final taskId = board.requestTask(
        docId: requestedDoc,
        task: task,
        originPeerId: service.selfId,
        originActorId: originActorId,
      );
      // One convergence cycle right away (mesh_pair's discipline: the
      // failure is NAMED data, the request itself already landed).
      var synced = true;
      try {
        await service.sync();
        StorageBackendsNotifier.onSyncCycle?.call();
      } on Exception {
        synced = false;
      }
      return MCPCallResult(
        message:
            'Requested task $taskId on board ${board.boardId} '
            '(status requested); the mesh sync cycle ships it to the '
            'device that owns the doc${synced
                ? ''
                : ' — the cycle FAILED, retry with storage_mesh_sync'}.',
        parameters: {
          'ok': true,
          'taskId': taskId,
          'boardId': board.boardId,
          'status': 'requested',
          'synced': synced,
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'mesh_task_dispatch',
      description:
          'Dispatch an agent task for a shared agent doc through the mesh '
          'task console: writes a requested row on the shared CRDT task '
          'board (origin: this device); the paired device that owns the '
          'doc (bound workspace + live harness) auto-runs it and writes '
          'the verdict back as board data. Poll mesh_tasks for the '
          'verdict.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'docId': {
            'type': 'string',
            'description': 'The shared agent doc id the task targets.',
          },
          'task': {
            'type': 'string',
            'description': 'The task sentence to run on the owner device.',
          },
        },
        'required': ['docId', 'task'],
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) {
      // PLAN 6.C — the mesh task console, read side: how the dispatching
      // peer reads statuses and verdicts. Rows come from the LIVE board
      // (empty list when the doc has none) — never a cached projection.
      final board = StorageBackendsNotifier.instance.taskBoard;
      if (board == null) {
        return MCPCallResult(
          message:
              'No mesh task board is attached on this device — host or '
              'pair first (mesh_host, or mesh_pair on the peer); the '
              'board mounts with the mesh replica.',
          parameters: {'ok': false, 'tasks': const <Never>[]},
        );
      }
      final requested = parameters['docId'];
      final docId = requested is String && requested.isNotEmpty
          ? requested
          : AgentDocSurface.debugState?.docId ??
                AgentDocSurface.shadowDoc?.docId;
      if (docId == null) {
        return MCPCallResult(
          message:
              'docId is required (no agent doc is open or shadowed to '
              'default to).',
          parameters: {'ok': false},
        );
      }
      final rows = [
        for (final record in board.tasksFor(docId)) meshTaskRecordJson(record),
      ];
      final summary = rows
          .map((final r) => '${r['taskId']}=${r['status']}')
          .join(', ');
      return MCPCallResult(
        message:
            '${rows.length} task row(s) for $docId on board '
            '${board.boardId}'
            '${rows.isEmpty ? '.' : ': $summary.'}',
        parameters: {'ok': true, 'docId': docId, 'tasks': rows},
      );
    },
    definition: MCPToolDefinition(
      name: 'mesh_tasks',
      description:
          'Read the mesh task console rows of a shared agent doc from the '
          'shared CRDT task board (taskId, task, status '
          'requested/running/completed/failed, origin, verdict): how the '
          'dispatching peer reads progress and verdicts after the owner '
          'device auto-runs a request.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'properties': {
          'docId': {
            'type': 'string',
            'description':
                'Agent doc id (defaults to the open or shadowed doc).',
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

/// ADR 0009 (D2) — the optional session selector for the doc verbs: with
/// `docId` the REGISTRY resolves that exact session (doc surfaces live
/// under their mesh replica id `agent-<docId>`; the raw doc id is the
/// alias the other mesh verbs carry); without it, the only live session,
/// else the focused one. Ambiguous/empty resolution throws
/// [SessionResolutionException] — the caller surfaces its message, which
/// NAMES the live sessions (never a silent wrong-target answer).
final _sessionTools = HarnessSessionTools(
  registry: HarnessSessionRegistry.instance,
  resolveDocAlias: _meshChannel,
  includeExceptionTypeInErrors: false,
);

SessionHandle _resolveSession(final Map<String, String> parameters) =>
    _sessionTools.resolve(parameters);

MCPCallResult _sessionResult(final Map<String, Object?> result) {
  final parameters = Map<String, Object?>.of(result);
  final message = parameters.remove('message') as String? ?? 'ok';
  return MCPCallResult(message: message, parameters: parameters);
}

/// The registry key [handle] lives under (identity lookup over the live
/// sessions — the addressable id the verb output names).
String? _registryKeyOf(final SessionHandle handle) {
  for (final entry in HarnessSessionRegistry.instance.sessions.entries) {
    if (identical(entry.value, handle)) return entry.key;
  }
  return null;
}

/// The honest resolution failure — the registry's message already NAMES
/// the live sessions (ADR 0009 D2, DESIGN §6).
MCPCallResult _resolutionError(final SessionResolutionException error) =>
    _sessionResult(
      HarnessSessionTools.resolutionError(error, includeExceptionType: false),
    );

/// The `agent_doc_state` message for a full doc projection — today's
/// shape, byte for byte.
String _docStateMessage(final AgentDocDebugState state) {
  final verdict = state.verdict == null ? '' : ', verdict: ${state.verdict}';
  final permission = state.pendingPermissionTitle == null
      ? ''
      : ' — the permission prompt (${state.pendingPermissionTitle}) is '
            'awaiting an answer; call agent_permission_answer.';
  // PLAN 9 — the queue rides the state output (ADR 0011): headless
  // drivers see the same queue the human sees (DESIGN §5/§8).
  final openQueue = state.queue
      .where((final q) => q.status == 'open')
      .toList();
  final queueNote = openQueue.isEmpty
      ? ''
      : ', ${openQueue.length} queued message(s) '
            '(steer: delivered after the running turn; JSON field '
            'queue carries position/age/status)';
  return 'Agent doc ${state.docId}: backend ${state.backend}, '
      'session ${state.sessionId ?? 'none'}, '
      '${state.running ? 'RUNNING' : 'idle'}'
      '$verdict$permission$queueNote';
}

Map<String, Object?> _emptySchema() => {
  'type': 'object',
  'properties': <String, Object?>{},
};
