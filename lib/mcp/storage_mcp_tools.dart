import 'dart:convert';

import 'package:lastanswer/settings/features/features.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

/// MCP tool entries that let an agent drive the storage backends
/// (select backend, configure paths, replicate, restore) without any
/// UI interaction.
///
/// Registered in debug/profile builds only (see `main.dart`); the
/// service extensions appear as `ext.mcp.toolkit.storage_*` and can be
/// called via the Dart VM service (`fmtk exec --name storage_state ...`).
Set<AgentCallEntry> storageMcpEntries() => {
  mcpToolkitTool(
    handler: (final parameters) => MCPCallResult(
      message:
          'Storage backends state. '
          'Checkbox model: localDb is the always-on live store; any number '
          'of backends can be enabled at once as replication targets and '
          'one of them is primary. Backends: localDb, filesystem, '
          'gitOffline, mesh, github (driven by GitHub Sync OAuth).',
      parameters: {
        'state': {
          ...StorageBackendsNotifier.instance.snapshot(),
          'supportedBackends': StorageBackendId.values
              .where((final b) => b.isSupportedOnPlatform)
              .map((final b) => b.name)
              .toList(),
        },
      },
    ),
    definition: MCPToolDefinition(
      name: 'storage_state',
      description:
          'Get the current storage backends state: enabled backends, '
          'primary backend, configured paths and last operation report.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final notifier = StorageBackendsNotifier.instance;
      // Agent-driven seamless setup: hosting on demand so the code
      // carries a reachable relay hint. Web (no dart:io) falls back to
      // a hintless code.
      try {
        await notifier.becomeMainDevice();
      } on Object catch (error) {
        // Web (and other non-IO platforms) throw UnsupportedError —
        // an Error, not an Exception — so this must stay broad.
        if (error is! UnsupportedError) rethrow;
        await notifier.ensureMeshService();
      }
      final service = await notifier.ensureMeshService();
      final pairingCode = await service.createPairingCode();
      return MCPCallResult(
        message: service.isHosting
            ? 'Signed mesh pairing code is ready; this device hosts the '
                  'relay at ${service.advertisedEndpoint}.'
            : 'Signed mesh pairing code is ready (no hosted relay).',
        parameters: {
          'pairingCode': pairingCode,
          'advertisedEndpoint': service.advertisedEndpoint?.toString(),
          'peers': service.peers.length,
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'storage_mesh_pairing_code',
      description:
          'Create a signed mesh-pair/v1 QR pairing code for this device. '
          'Starts hosting the local relay when needed ("main device"), '
          'so the code embeds a reachable endpoint.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final code = parameters['pairingCode'] ?? '';
      if (code.isEmpty) {
        return MCPCallResult(
          message: 'pairingCode is required.',
          parameters: {'ok': false},
        );
      }
      try {
        final report = await StorageBackendsNotifier.instance.joinWithCode(
          code,
        );
        final service = await StorageBackendsNotifier.instance
            .ensureMeshService();
        final peer = service.peers.isEmpty ? null : service.peers.last;
        return MCPCallResult(
          message: report.ok
              ? 'Paired${peer == null ? '' : ' with ${peer.peerId}'} and '
                    'synced the app data (${report.message}).'
              : 'Pairing or sync failed: ${report.message}',
          parameters: {
            'ok': report.ok,
            if (peer != null) 'peerId': peer.peerId,
            if (peer != null)
              'identityKey': base64Encode(peer.identityKey),
            'report': report.message,
          },
        );
      } on FormatException catch (error) {
        return MCPCallResult(
          message: 'Invalid pairing code: $error',
          parameters: {'ok': false},
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'storage_mesh_accept_pairing',
      description:
          'Verify a signed base64 mesh-pair/v1 pairing code, connect to '
          'the peer automatically, and pull its app data into the live '
          'database.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'required': ['pairingCode'],
        'properties': {
          'pairingCode': {'type': 'string'},
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final raw = parameters['backend'] ?? '';
      final matches = StorageBackendId.values.where((final b) => b.name == raw);
      if (matches.isEmpty) {
        return MCPCallResult(
          message:
              'Unknown backend "$raw". Valid values: '
              '${StorageBackendId.values.map((final b) => b.name).join(', ')}.',
          parameters: {'ok': false},
        );
      }
      await StorageBackendsNotifier.instance.selectBackend(matches.first);
      if (!matches.first.isSupportedOnPlatform) {
        return MCPCallResult(
          message:
              '${matches.first.name} enabled and made primary, but it is '
              'NOT supported on this platform; backup/restore will fail.',
          parameters: {'ok': true, 'primary': matches.first.name},
        );
      }
      return MCPCallResult(
        message:
            '${matches.first.name} enabled and set as primary storage '
            'backend.',
        parameters: {'ok': true, 'primary': matches.first.name},
      );
    },
    definition: MCPToolDefinition(
      name: 'storage_select_backend',
      description:
          'Enable a storage backend and make it primary. '
          'Legacy single-selection tool; for multi-backend setups prefer '
          'storage_set_enabled + storage_set_primary. '
          'One of: localDb, filesystem, gitOffline, mesh, github.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'required': ['backend'],
        'properties': {
          'backend': {
            'type': 'string',
            'enum': StorageBackendId.values.map((final b) => b.name).toList(),
            'description': 'Backend to enable and mark as primary.',
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final raw = parameters['backend'] ?? '';
      final matches = StorageBackendId.values.where((final b) => b.name == raw);
      if (matches.isEmpty) {
        return MCPCallResult(
          message:
              'Unknown backend "$raw". Valid values: '
              '${StorageBackendId.values.map((final b) => b.name).join(', ')}.',
          parameters: {'ok': false},
        );
      }
      final id = matches.first;
      final value = (parameters['enabled'] ?? '') != 'false';
      try {
        await StorageBackendsNotifier.instance.setEnabled(id, value: value);
      } on StorageBackendConfigException catch (e) {
        return MCPCallResult(
          message: e.message,
          parameters: {'ok': false, 'backend': id.name, 'enabled': value},
        );
      }
      return MCPCallResult(
        message:
            '${id.name} ${value ? 'enabled' : 'disabled'}.',
        parameters: {
          'ok': true,
          'backend': id.name,
          'enabled': value,
          'enabledBackends': StorageBackendsNotifier.instance.enabled
              .map((final b) => b.name)
              .toList(),
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'storage_set_enabled',
      description:
          'Toggle a storage backend like a checkbox: enabling adds it as a '
          'replication target without disabling the others. localDb cannot '
          'be disabled.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'required': ['backend', 'enabled'],
        'properties': {
          'backend': {
            'type': 'string',
            'enum': StorageBackendId.values.map((final b) => b.name).toList(),
          },
          'enabled': {'type': 'boolean'},
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final raw = parameters['backend'] ?? '';
      final id = StorageBackendIdX.fromName(raw.isEmpty ? null : raw);
      if (id.name != raw) {
        return MCPCallResult(
          message:
              'Unknown backend "$raw". Valid values: '
              '${StorageBackendId.values.map((final b) => b.name).join(', ')}.',
          parameters: {'ok': false},
        );
      }
      final notifier = StorageBackendsNotifier.instance;
      if (!notifier.isEnabled(id)) {
        return MCPCallResult(
          message: '${id.name} is not enabled; enable it first.',
          parameters: {'ok': false, 'backend': id.name},
        );
      }
      await notifier.setPrimary(id);
      return MCPCallResult(
        message: '${id.name} is now the primary storage backend.',
        parameters: {
          'ok': true,
          'primary': notifier.primary.name,
          'enabledBackends': notifier.enabled
              .map((final b) => b.name)
              .toList(),
        },
      );
    },
    definition: MCPToolDefinition(
      name: 'storage_set_primary',
      description:
          'Mark one of the enabled backends as primary. The primary is the '
          'default source for restores.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'required': ['backend'],
        'properties': {
          'backend': {
            'type': 'string',
            'enum': StorageBackendId.values.map((final b) => b.name).toList(),
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final backend = parameters['backend'] ?? '';
      final path = parameters['path'] ?? '';
      if (path.isEmpty) {
        return MCPCallResult(
          message: 'path is required.',
          parameters: {'ok': false},
        );
      }
      switch (backend) {
        case 'filesystem':
          await StorageBackendsNotifier.instance.setFilesystemPath(path);
        case 'mesh':
          await StorageBackendsNotifier.instance.setMeshConfig(
            storePath: path,
            relayEndpoint: parameters['relayEndpoint']?.toString() ?? '',
            port: 0,
          );
        case 'gitOffline':
          await StorageBackendsNotifier.instance.setGitPath(path);
        default:
          return MCPCallResult(
            message: 'backend must be "filesystem", "mesh", or "gitOffline".',
            parameters: {'ok': false},
          );
      }
      return MCPCallResult(
        message: '$backend path set to $path.',
        parameters: {'ok': true, 'backend': backend, 'path': path},
      );
    },
    definition: MCPToolDefinition(
      name: 'storage_set_path',
      description:
          'Set the folder path for a local backend. backend must be '
          '"filesystem", "mesh", or "gitOffline"; the folder is created '
          'automatically when missing. For mesh, relayEndpoint is optional '
          '(seamless pairing hosts a relay automatically).',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'required': ['backend', 'path'],
        'properties': {
          'backend': {
            'type': 'string',
            'enum': ['filesystem', 'mesh', 'gitOffline'],
          },
          'path': {'type': 'string', 'description': 'Absolute folder path.'},
          'relayEndpoint': {
            'type': 'string',
            'description': 'Required mesh WebSocket relay URL.',
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final peerId = parameters['peerId']?.toString().trim() ?? '';
      try {
        final notifier = StorageBackendsNotifier.instance;
        final service = await notifier.ensureMeshService();
        if (peerId.isNotEmpty && !service.peers.any((p) => p.peerId == peerId)) {
          await service.registerPeer(peerId: peerId);
        }
        var payload = parameters['payload']?.toString() ?? '';
        if (payload.isEmpty) {
          payload = await notifier.buildPayload();
        }
        await service.backup(payload);
        await service.sync();
        // The sync cycle may have delivered remote doc ops — projections
        // re-read the fold.
        StorageBackendsNotifier.onSyncCycle?.call();
        final restored = await service.restore();
        return MCPCallResult(
          message:
              'Mesh synced${peerId.isEmpty ? '' : ' with $peerId'} '
              '(${restored?.length ?? 0} bytes).',
          parameters: {
            'ok': restored == payload,
            if (peerId.isNotEmpty) 'peerId': peerId,
            'bytes': restored?.length ?? 0,
          },
        );
      } on Exception catch (error) {
        return MCPCallResult(
          message: 'Mesh sync failed: $error',
          parameters: {'ok': false},
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'storage_mesh_sync',
      description:
          'Publish the app payload to the local mesh replica and run an '
          'addressed-relay sync session with every known peer. Optionally '
          'registers a remote peer id first (advanced/debug).',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'properties': {
          'peerId': {
            'type': 'string',
            'description':
                'Optional stable remote replica peer ID to register.',
          },
          'payload': {
            'type': 'string',
            'description': 'Optional JSON payload override for tests.',
          },
        },
      }),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final notifier = StorageBackendsNotifier.instance;
      final backend = _parseBackend(parameters['backend']);
      try {
        final payload = parameters['payload'];
        final report = await notifier.backupNow(
          jsonPayload: (payload == null || payload.isEmpty) ? null : payload,
          backend: backend,
        );
        return MCPCallResult(
          message: report.ok
              ? '${report.message}'
                    '${report.bytes == null ? '' : ' (${report.bytes} bytes)'}'
              : 'Backup failed: ${report.message}',
          parameters: {'ok': report.ok, 'report': report.toJson()},
        );
      } on Exception catch (e) {
        return MCPCallResult(
          message: 'Backup failed: $e',
          parameters: {'ok': false},
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'storage_backup',
      description:
          'Replicate the full app data payload. Without "backend", writes '
          'a copy to every enabled replication target; with "backend", '
          'only to that one. Uses the live app data unless an explicit '
          '"payload" JSON string is given.',
      inputSchema: ObjectSchema.fromMap(_optionalBackendSchema()),
    ),
  ),
  mcpToolkitTool(
    handler: (final parameters) async {
      final apply = (parameters['apply'] ?? '') != 'false';
      final backend = _parseBackend(parameters['backend']);
      try {
        final report = await StorageBackendsNotifier.instance.restoreNow(
          backend: backend,
          apply: apply,
        );
        final payload = StorageBackendsNotifier.instance.lastPayload;
        return MCPCallResult(
          message: report.ok
              ? (apply
                    ? 'Restored from ${report.backend.name} and applied '
                          'to the local database.'
                    : 'Read backup from ${report.backend.name} '
                          '(${report.bytes ?? 0} bytes).')
              : 'Restore failed: ${report.message}',
          parameters: {
            'ok': report.ok,
            'report': report.toJson(),
            if (!apply && payload.isNotEmpty)
              'payload': jsonDecode(payload) as Map<String, dynamic>,
          },
        );
      } on Exception catch (e) {
        return MCPCallResult(
          message: 'Restore failed: $e',
          parameters: {'ok': false},
        );
      }
    },
    definition: MCPToolDefinition(
      name: 'storage_restore',
      description:
          'Restore app data from a storage backend copy. Set "apply" to '
          '"false" to only read and return the stored payload without '
          'touching the local database.',
      inputSchema: ObjectSchema.fromMap(_optionalBackendSchema()),
    ),
  ),
};

StorageBackendId? _parseBackend(final String? raw) =>
    (raw == null || raw.isEmpty) ? null : StorageBackendIdX.fromName(raw);

Map<String, Object?> _emptySchema() => {
  'type': 'object',
  'additionalProperties': false,
  'properties': <String, Object?>{},
};

Map<String, Object?> _optionalBackendSchema() => {
  'type': 'object',
  'additionalProperties': false,
  'properties': {
    'backend': {
      'type': 'string',
      'enum': StorageBackendId.values.map((final b) => b.name).toList(),
      'description':
          'Backup: defaults to all enabled targets. Restore: defaults to '
          'the primary backend.',
    },
    'payload': {'type': 'string', 'description': 'Optional JSON payload.'},
    'apply': {
      'type': 'boolean',
      'description': 'Whether to apply to the live DB (default true).',
    },
  },
};

extension on StorageOperationReport {
  Map<String, dynamic> toJson() => {
    'ok': ok,
    'backend': backend.name,
    'message': message,
    'bytes': bytes,
  };
}
