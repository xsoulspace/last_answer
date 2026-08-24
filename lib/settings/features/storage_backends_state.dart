import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_storage_filesystem/universal_storage_filesystem.dart';
import 'package:universal_storage_git_offline/universal_storage_git_offline.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Pluggable storage backends, in the order they are offered to the user.
enum StorageBackendId { localDb, filesystem, gitOffline, github }

/// Human-facing metadata for a backend.
extension StorageBackendIdX on StorageBackendId {
  String get persistedName => name;
  static StorageBackendId fromName(final String? name) =>
      StorageBackendId.values.firstWhere(
        (final b) => b.name == name,
        orElse: () => StorageBackendId.localDb,
      );
}

/// Result of the last replication/restore operation (for UI and MCP).
@immutable
class StorageOperationReport {
  const StorageOperationReport({
    required this.ok,
    required this.backend,
    required this.message,
    this.bytes,
  });
  final bool ok;
  final StorageBackendId backend;
  final String message;
  final int? bytes;
}

/// State + operations for the optional storage backends.
///
/// local_db is always the live store (default). The other backends are
/// replication targets: enabling one configures it and lets the user
/// back up / restore the full data payload to it.
class StorageBackendsNotifier extends ChangeNotifier {
  /// Singleton so MCP tools can drive storage without a widget tree.
  StorageBackendsNotifier.internal();
  static final StorageBackendsNotifier instance =
      StorageBackendsNotifier.internal();

  static const _prefsKey = 'storage_backend_config_v1';

  /// Builds the full app data payload (JSON string) for replication.
  /// Set at startup so MCP tools can back up without the widget tree.
  static Future<String> Function()? payloadBuilder;

  /// Applies a restored JSON payload to the live local DB.
  /// Set at startup so MCP tools can restore without the widget tree.
  static Future<void> Function(String jsonPayload)? restoreApplier;

  StorageBackendId _active = StorageBackendId.localDb;
  String _filesystemPath = '';
  String _gitPath = '';
  String _defaultPath = '';
  StorageOperationReport? _lastReport;

  /// Currently selected backend (local_db by default).
  StorageBackendId get active => _active;

  /// Absolute folder for the filesystem backend.
  String get filesystemPath => _filesystemPath;

  /// Absolute path of the local git repository for the git backend.
  String get gitPath => _gitPath;

  /// Writable default location (app documents dir) suggested to users
  /// and used by agent tooling on sandboxed platforms.
  String get defaultPath => _defaultPath;

  /// Last replication/restore result.
  StorageOperationReport? get lastReport => _lastReport;

  bool get isConfigured {
    switch (_active) {
      case StorageBackendId.filesystem:
        return _filesystemPath.isNotEmpty;
      case StorageBackendId.gitOffline:
        return _gitPath.isNotEmpty;
      case StorageBackendId.github:
      case StorageBackendId.localDb:
        return true;
    }
  }

  Future<SharedPreferences>? _prefsFuture;
  Future<SharedPreferences> get _prefs =>
      _prefsFuture ??= SharedPreferences.getInstance();

  /// Restores persisted selection; call once at startup.
  Future<void> load() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _active = StorageBackendIdX.fromName(map['backend'] as String?);
      _filesystemPath = map['fsPath'] as String? ?? '';
      _gitPath = map['gitPath'] as String? ?? '';
    }
    try {
      final docs = await getApplicationDocumentsDirectory();
      _defaultPath = docs.path;
    } on Exception {
      _defaultPath = '';
    }
    notifyListeners();
  }

  Future<void> selectBackend(final StorageBackendId id) async {
    _active = id;
    await _persist();
  }

  Future<void> setFilesystemPath(final String path) async {
    _filesystemPath = path.trim();
    if (_active == StorageBackendId.filesystem) await _persist();
    notifyListeners();
  }

  Future<void> setGitPath(final String path) async {
    _gitPath = path.trim();
    if (_active == StorageBackendId.gitOffline) await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await _prefs;
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'backend': _active.name,
        'fsPath': _filesystemPath,
        'gitPath': _gitPath,
      }),
    );
    notifyListeners();
  }

  /// Builds a [StorageService] for a replication target, or `null` for
  /// local_db (the built-in live store).
  Future<StorageService?> buildService(final StorageBackendId id) async {
    switch (id) {
      case StorageBackendId.localDb:
        return null;
      case StorageBackendId.filesystem:
        if (_filesystemPath.isEmpty) {
          throw const StorageBackendConfigException(
            'Filesystem path is not set',
          );
        }
        final dir = Directory(_filesystemPath);
        if (!dir.existsSync()) dir.createSync(recursive: true);
        final provider = FileSystemStorageProvider();
        await provider.initWithConfig(
          FileSystemConfig(
            filePathConfig: FilePathConfig.create(
              path: dir.path,
              macOSBookmarkData: MacOSBookmark.fromDirectory(dir),
            ),
          ),
        );
        return StorageService(provider);
      case StorageBackendId.gitOffline:
        if (_gitPath.isEmpty) {
          throw const StorageBackendConfigException(
            'Git repository path is not set',
          );
        }
        final provider = OfflineGitStorageProvider(
          commitBatching: const GitCommitBatching(),
        );
        await provider.initWithConfig(
          OfflineGitConfig(
            localPath: _gitPath,
            authorName: 'Last Answer',
            authorEmail: 'sync@lastanswer.local',
          ),
        );
        return StorageService(provider);
      case StorageBackendId.github:
        throw const StorageBackendConfigException(
          'GitHub is driven by GithubSyncNotifier (OAuth-protected)',
        );
    }
  }

  static const _dataFile = 'last-answer-data.json';

  /// Replicates [jsonPayload] to the given backend.
  Future<StorageOperationReport> replicate({
    required final StorageBackendId backend,
    required final String jsonPayload,
  }) async {
    try {
      final service = await buildService(backend);
      if (service == null) {
        return StorageOperationReport(
          ok: true,
          backend: backend,
          message: 'local_db is the live store; nothing to replicate',
        );
      }
      await service.saveFile(
        _dataFile,
        jsonPayload,
        message: 'Last Answer data backup',
      );
      _lastReport = StorageOperationReport(
        ok: true,
        backend: backend,
        message: 'replicated',
        bytes: jsonPayload.length,
      );
    } on Exception catch (e) {
      _lastReport = StorageOperationReport(
        ok: false,
        backend: backend,
        message: e.toString(),
      );
    }
    notifyListeners();
    return _lastReport!;
  }

  /// Reads the payload previously replicated to [backend]; `null` if none.
  Future<StorageOperationReport> restore(final StorageBackendId backend) async {
    String? content;
    try {
      final service = await buildService(backend);
      if (service == null) {
        return StorageOperationReport(
          ok: false,
          backend: backend,
          message: 'local_db is the live store; nothing to restore from',
        );
      }
      content = await service.readFile(_dataFile);
      _lastPayload = content ?? '';
      _lastReport = StorageOperationReport(
        ok: content != null,
        backend: backend,
        message: content == null ? 'no backup found' : 'restored',
        bytes: content?.length,
      );
    } on Exception catch (e) {
      _lastReport = StorageOperationReport(
        ok: false,
        backend: backend,
        message: e.toString(),
      );
    }
    notifyListeners();
    return _lastReport!;
  }

  /// Builds a payload via [payloadBuilder] (or throws if not set).
  Future<String> buildPayload() async {
    final builder = payloadBuilder;
    if (builder == null) {
      throw const StorageBackendConfigException(
        'No payload builder registered',
      );
    }
    return builder();
  }

  /// Replicates the app data (via [buildPayload]) to [backend]
  /// (defaults to the active backend).
  Future<StorageOperationReport> backupNow({
    final String? jsonPayload,
    final StorageBackendId? backend,
  }) async {
    final payload = jsonPayload ?? await buildPayload();
    return replicate(backend: backend ?? _active, jsonPayload: payload);
  }

  /// Reads the payload from [backend] and, when it succeeds and
  /// [apply] is set, applies it to the live local DB via
  /// [restoreApplier].
  Future<StorageOperationReport> restoreNow({
    final StorageBackendId? backend,
    final bool apply = true,
  }) async {
    final report = await restore(backend ?? _active);
    if (!report.ok || !apply) return report;
    final applier = restoreApplier;
    if (applier == null) {
      _lastReport = StorageOperationReport(
        ok: false,
        backend: backend ?? _active,
        message: 'No restore applier registered',
      );
      notifyListeners();
      return _lastReport!;
    }
    try {
      await applier(_lastPayload);
      _lastReport = StorageOperationReport(
        ok: true,
        backend: backend ?? _active,
        message: 'restored and applied',
        bytes: report.bytes,
      );
    } on Exception catch (e) {
      _lastReport = StorageOperationReport(
        ok: false,
        backend: backend ?? _active,
        message: e.toString(),
      );
    }
    notifyListeners();
    return _lastReport!;
  }

  String _lastPayload = '';

  /// Last payload read by [restore] (empty when nothing was read yet).
  String get lastPayload => _lastPayload;

  /// Snapshot for MCP tools.
  Map<String, dynamic> snapshot() => {
    'active': _active.name,
    'filesystemPath': _filesystemPath,
    'gitPath': _gitPath,
    'isConfigured': isConfigured,
    'defaultPath': _defaultPath,
    if (_lastReport != null)
      'lastReport': {
        'ok': _lastReport!.ok,
        'backend': _lastReport!.backend.name,
        'message': _lastReport!.message,
        'bytes': _lastReport!.bytes,
      },
  };
}

class StorageBackendConfigException implements Exception {
  const StorageBackendConfigException(this.message);
  final String message;

  @override
  String toString() => message;
}
