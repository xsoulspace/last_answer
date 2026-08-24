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
      message: 'Storage backends state. '
          'Backends: localDb (default live store), filesystem, gitOffline, '
          'github (driven by GitHub Sync OAuth).',
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
      description: 'Get the current storage backends state: active backend, '
          'configured paths and last operation report.',
      inputSchema: ObjectSchema.fromMap(_emptySchema()),
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
              '${matches.first.name} selected, but it is NOT supported on '
              'this platform; backup/restore will fail.',
          parameters: {'ok': true, 'active': matches.first.name},
        );
      }
      return MCPCallResult(
        message: 'Active storage backend set to ${matches.first.name}.',
        parameters: {'ok': true, 'active': matches.first.name},
      );
    },
    definition: MCPToolDefinition(
      name: 'storage_select_backend',
      description: 'Select the active storage backend. '
          'One of: localDb, filesystem, gitOffline, github.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'required': ['backend'],
        'properties': {
          'backend': {
            'type': 'string',
            'enum': StorageBackendId.values.map((final b) => b.name).toList(),
            'description': 'Backend to activate.',
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
        case 'gitOffline':
          await StorageBackendsNotifier.instance.setGitPath(path);
        default:
          return MCPCallResult(
            message: 'backend must be "filesystem" or "gitOffline".',
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
          'Set the folder path for a local backend. '
          'backend must be "filesystem" or "gitOffline"; the folder is '
          'created automatically when missing.',
      inputSchema: ObjectSchema.fromMap({
        'type': 'object',
        'additionalProperties': false,
        'required': ['backend', 'path'],
        'properties': {
          'backend': {
            'type': 'string',
            'enum': ['filesystem', 'gitOffline'],
          },
          'path': {'type': 'string', 'description': 'Absolute folder path.'},
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
              ? 'Replicated to ${report.backend.name} '
                  '(${report.bytes ?? 0} bytes).'
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
          'Replicate the full app data payload to a storage backend. '
          'Uses the active backend unless "backend" is given; uses the '
          'live app data unless an explicit "payload" JSON string is given.',
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
      'description': 'Defaults to the currently active backend.',
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
