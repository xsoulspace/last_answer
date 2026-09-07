import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:lastanswer/settings/features/storage_backends_platform_stub.dart'
    if (dart.library.io) 'storage_backends_platform_io.dart'
    as platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Pluggable storage backends, in the order they are offered to the user.
enum StorageBackendId { localDb, filesystem, gitOffline, mesh, github }

/// Role this device plays in a mesh of two or more devices.
///
/// [none] — mesh not set up (or only configured manually via advanced
/// fields). [main] — hosts the relay others connect to ("main device").
/// [joined] — connected to another device's relay via pairing code.
enum MeshRole { none, main, joined }

/// Human-facing metadata for a backend.
extension StorageBackendIdX on StorageBackendId {
  String get persistedName => name;
  static StorageBackendId fromName(final String? name) =>
      StorageBackendId.values.firstWhere(
        (final b) => b.name == name,
        orElse: () => StorageBackendId.localDb,
      );

  /// Whether this backend can actually run on the current platform
  /// (web has no filesystem/processes; iOS devices cannot spawn git).
  bool get isSupportedOnPlatform => switch (this) {
    StorageBackendId.localDb ||
    StorageBackendId.github ||
    StorageBackendId.mesh => true,
    StorageBackendId.filesystem => platform.filesystemSupported(),
    StorageBackendId.gitOffline => platform.gitOfflineSupported(),
  };
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

/// State + operations for the pluggable storage backends.
///
/// Backends behave like checkboxes, not a radio: local_db is the built-in
/// live store (always on), and any number of other backends can be
/// enabled at once as replication targets — each adds a capability (an
/// extra synced copy) instead of switching away from the others. One
/// enabled backend is marked [primary]: it is the default source for
/// restores and the default destination for explicit single-target
/// operations.
class StorageBackendsNotifier extends ChangeNotifier {
  /// Singleton so MCP tools can drive storage without a widget tree.
  StorageBackendsNotifier.internal();
  static final StorageBackendsNotifier instance =
      StorageBackendsNotifier.internal();

  static const _prefsKey = 'storage_backend_config_v2';

  /// Previous single-selection schema, read only for migration.
  static const _legacyPrefsKey = 'storage_backend_config_v1';

  /// Builds the full app data payload (JSON string) for replication.
  /// Set at startup so MCP tools can back up without the widget tree.
  static Future<String> Function()? payloadBuilder;

  /// Test seam: overrides [MeshStorageService.open] so tests exercise the
  /// store/roster attach wiring without networking. Null in production.
  @visibleForTesting
  static Future<MeshStorageService> Function({
    required String storePath,
    required String peerId,
    Uri? relayEndpoint,
  })? meshServiceOpener;

  /// App wiring: called after every mesh sync cycle (Sync now, join) so
  /// projections holding routed doc state re-read the fold — a peer's
  /// permission answer arrives with the sync, and the open agent-doc
  /// surface must call [HarnessSessionController.refreshPermissions].
  /// Installed by the app shell (debug/profile builds).
  static void Function()? onSyncCycle;

  /// Applies a restored JSON payload to the live local DB.
  /// Set at startup so MCP tools can restore without the widget tree.
  static Future<void> Function(String jsonPayload)? restoreApplier;

  final Set<StorageBackendId> _enabled = {StorageBackendId.localDb};
  StorageBackendId _primary = StorageBackendId.localDb;
  String _filesystemPath = '';
  String _gitPath = '';
  String _meshStorePath = '';
  int _meshPort = 0;
  String _meshRelayEndpoint = '';
  // Mutable: the seamless flow transitions it (none → main/joined → none).
  MeshRole _meshRole = MeshRole.none;
  String _defaultPath = '';
  StorageOperationReport? _lastReport;

  /// Enabled backends (checkbox semantics). Always contains local_db.
  Set<StorageBackendId> get enabled => Set.unmodifiable(_enabled);

  /// Whether [id] is enabled. localDb is always enabled.
  bool isEnabled(final StorageBackendId id) => _enabled.contains(id);

  /// The primary backend: default source for restores and default
  /// single-target destination (local_db unless changed).
  StorageBackendId get primary => _primary;

  /// Legacy name for [primary]; kept for older MCP consumers.
  @Deprecated('Use primary instead.')
  StorageBackendId get active => _primary;

  /// Absolute folder for the filesystem backend.
  String get filesystemPath => _filesystemPath;

  /// Absolute path of the local git repository for the git backend.
  String get gitPath => _gitPath;

  /// Local mesh replica, optional IO relay port, and relay endpoint.
  String get meshStorePath => _meshStorePath;
  int get meshPort => _meshPort;
  String get meshRelayEndpoint => _meshRelayEndpoint;

  /// Seamless-setup role of this device in the mesh (see [MeshRole]).
  MeshRole get meshRole => _meshRole;

  /// Writable default location (app documents dir) suggested to users
  /// and used by agent tooling on sandboxed platforms.
  String get defaultPath => _defaultPath;

  /// Last replication/restore result.
  StorageOperationReport? get lastReport => _lastReport;

  /// Whether every enabled backend has the configuration it needs.
  bool get isConfigured => _enabled.every(isConfiguredFor);

  /// Whether [id] has the configuration it needs to operate.
  bool isConfiguredFor(final StorageBackendId id) => switch (id) {
    StorageBackendId.filesystem => _filesystemPath.isNotEmpty,
    StorageBackendId.gitOffline => _gitPath.isNotEmpty,
    // Seamless pairing (role != none) or explicit advanced fields both
    // count as "configured" for replication targets.
    StorageBackendId.mesh =>
      _meshRole != MeshRole.none ||
          (_meshStorePath.isNotEmpty && _meshRelayEndpoint.isNotEmpty),
    StorageBackendId.github || StorageBackendId.localDb => true,
  };

  Future<SharedPreferences>? _prefsFuture;
  Future<SharedPreferences> get _prefs =>
      _prefsFuture ??= SharedPreferences.getInstance();

  /// Restores persisted configuration; call once at startup.
  Future<void> load() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _enabled
        ..clear()
        ..addAll(
          ((map['enabled'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<String>()
                .map(StorageBackendIdX.fromName))
            .where(
              (final id) =>
                  id == StorageBackendId.localDb || id.isSupportedOnPlatform,
            ),
        )
        ..add(StorageBackendId.localDb);
      final persistedPrimary = StorageBackendIdX.fromName(
        map['primary'] as String?,
      );
      _primary = _enabled.contains(persistedPrimary)
          ? persistedPrimary
          : StorageBackendId.localDb;
      _filesystemPath = map['fsPath'] as String? ?? '';
      _gitPath = map['gitPath'] as String? ?? '';
      _meshStorePath = map['meshStorePath'] as String? ?? '';
      _meshPort = map['meshPort'] as int? ?? 0;
      _meshRelayEndpoint = map['meshRelayEndpoint'] as String? ?? '';
      _meshRole = MeshRole.values.firstWhere(
        (final role) => role.name == (map['meshRole'] as String?),
        orElse: () => MeshRole.none,
      );
    } else {
      await _migrateLegacy();
    }
    _defaultPath = await platform.defaultFilesystemPath();
    notifyListeners();
  }

  /// Upgrades the pre-checkbox single-selection config: the previously
  /// selected backend becomes both enabled and primary.
  Future<void> _migrateLegacy() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_legacyPrefsKey);
    if (raw == null) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final legacyActive = StorageBackendIdX.fromName(map['backend'] as String?);
    _enabled.add(legacyActive);
    _primary = legacyActive.isSupportedOnPlatform
        ? legacyActive
        : StorageBackendId.localDb;
    _filesystemPath = map['fsPath'] as String? ?? '';
    _gitPath = map['gitPath'] as String? ?? '';
    _meshStorePath = map['meshStorePath'] as String? ?? '';
    _meshPort = map['meshPort'] as int? ?? 0;
    _meshRelayEndpoint = map['meshRelayEndpoint'] as String? ?? '';
    await _persist();
  }

  /// Legacy single-selection API: enables [id] and makes it primary.
  @Deprecated('Use setEnabled + setPrimary.')
  Future<void> selectBackend(final StorageBackendId id) async {
    await setEnabled(id, value: true, makePrimary: true);
  }

  /// Toggles [id]. Disabling local_db is ignored; disabling the primary
  /// promotes the first other enabled backend in canonical order
  /// (local_db only when it is the last one standing — it is always
  /// enabled, so it must never win the promotion over a real target).
  /// When [makePrimary] is set and [value] is true, [id] also becomes the
  /// primary backend.
  Future<void> setEnabled(
    final StorageBackendId id, {
    required final bool value,
    final bool makePrimary = false,
  }) async {
    if (value && !id.isSupportedOnPlatform) {
      throw StorageBackendConfigException(
        '${id.name} is not available on this platform',
      );
    }
    if (value) {
      _enabled.add(id);
      if (makePrimary) _primary = id;
    } else {
      if (id == StorageBackendId.localDb) return;
      _enabled.remove(id);
      if (_primary == id) {
        _primary = StorageBackendId.values.firstWhere(
          (final candidate) =>
              candidate != StorageBackendId.localDb &&
              _enabled.contains(candidate),
          orElse: () => StorageBackendId.localDb,
        );
      }
    }
    await _persist();
  }

  /// Marks an enabled [id] as primary.
  Future<void> setPrimary(final StorageBackendId id) async {
    if (!_enabled.contains(id)) return;
    _primary = id;
    await _persist();
  }

  Future<void> setFilesystemPath(final String path) async {
    _filesystemPath = path.trim();
    await _persist();
    notifyListeners();
  }

  Future<void> setGitPath(final String path) async {
    _gitPath = path.trim();
    await _persist();
    notifyListeners();
  }

  Future<void> setMeshConfig({
    required final String storePath,
    required final String relayEndpoint,
    required final int port,
  }) async {
    _meshStorePath = storePath.trim();
    _meshRelayEndpoint = relayEndpoint.trim();
    _meshPort = port;
    // Advanced/debug edits rebuild the replica on next use; the hosted
    // relay of a paired main device keeps running until left.
    final service = _meshService;
    if (service != null &&
        !service.isHosting &&
        _meshRole == MeshRole.none) {
      _meshService = null;
      unawaited(service.dispose());
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await _prefs;
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'enabled': _enabled.map((final id) => id.name).toList(),
        'primary': _primary.name,
        'fsPath': _filesystemPath,
        'gitPath': _gitPath,
        'meshStorePath': _meshStorePath,
        'meshPort': _meshPort,
        'meshRelayEndpoint': _meshRelayEndpoint,
        'meshRole': _meshRole.name,
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
        if (!id.isSupportedOnPlatform) {
          throw const StorageBackendConfigException(
            'Filesystem backend is not available on this platform',
          );
        }
        if (_filesystemPath.isEmpty) {
          throw const StorageBackendConfigException(
            'Filesystem path is not set',
          );
        }
        return platform.buildFilesystemService(_filesystemPath);
      case StorageBackendId.gitOffline:
        if (!id.isSupportedOnPlatform) {
          throw const StorageBackendConfigException(
            'Git offline backend is not available on this platform',
          );
        }
        if (_gitPath.isEmpty) {
          throw const StorageBackendConfigException(
            'Git repository path is not set',
          );
        }
        return platform.buildGitOfflineService(_gitPath);
      case StorageBackendId.mesh:
        if (!id.isSupportedOnPlatform) {
          throw const StorageBackendConfigException(
            'Mesh backend is not available on this platform',
          );
        }
        // Reuse the live replica (hosted relay + paired peers included)
        // instead of opening a second, disconnected one per operation.
        return (await ensureMeshService()).storage;
      case StorageBackendId.github:
        throw const StorageBackendConfigException(
          'GitHub is driven by GithubSyncNotifier (OAuth-protected)',
        );
    }
  }

  static const _dataFile = 'last-answer-data.json';

  /// Enabled backends able to receive a replicated copy right now:
  /// excludes the built-in local_db live store and GitHub (driven by
  /// GithubSyncNotifier), keeps only supported and configured ones.
  List<StorageBackendId> get replicationTargets => _enabled
      .where(
        (final id) =>
            id != StorageBackendId.localDb &&
            id != StorageBackendId.github &&
            id.isSupportedOnPlatform &&
            isConfiguredFor(id),
      )
      .toList();

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
    } catch (e) {
      // Catch Error too: on web dart:io throws UnsupportedError.
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

  /// Replicates the app data (via [buildPayload]): to [backend] when
  /// given, otherwise to every enabled replication target at once.
  Future<StorageOperationReport> backupNow({
    final String? jsonPayload,
    final StorageBackendId? backend,
  }) async {
    final payload = jsonPayload ?? await buildPayload();
    if (backend != null) {
      return replicate(backend: backend, jsonPayload: payload);
    }
    return replicateToAll(jsonPayload: payload);
  }

  /// Replicates [jsonPayload] to every enabled replication target.
  /// Returns one report per target; [lastReport] summarizes the run.
  Future<List<StorageOperationReport>> replicateToEnabled({
    required final String jsonPayload,
  }) async {
    final reports = <StorageOperationReport>[];
    for (final target in replicationTargets) {
      reports.add(
        await replicate(backend: target, jsonPayload: jsonPayload),
      );
    }
    return reports;
  }

  /// Fan-out variant returning a single combined [StorageOperationReport].
  Future<StorageOperationReport> replicateToAll({
    required final String jsonPayload,
  }) async {
    final reports = await replicateToEnabled(jsonPayload: jsonPayload);
    final succeeded = reports.where((final r) => r.ok).toList();
    final names = reports.map((final r) => r.backend.name).join(', ');
    _lastReport = switch (reports) {
      const [] => StorageOperationReport(
        ok: true,
        backend: _primary,
        message: 'local_db is the live store; no extra copies enabled',
      ),
      _ when succeeded.length == reports.length => StorageOperationReport(
        ok: true,
        backend: _primary,
        message: 'replicated to $names',
        bytes: jsonPayload.length,
      ),
      _ => StorageOperationReport(
        ok: false,
        backend: _primary,
        message: reports
            .where((final r) => !r.ok)
            .map((final r) => '${r.backend.name}: ${r.message}')
            .join('; '),
      ),
    };
    notifyListeners();
    return _lastReport!;
  }

  /// The default restore source: the primary backend — unless it is the
  /// built-in local_db live store (which never receives replicated
  /// copies), then the first enabled, configured replication target in
  /// canonical order (falling back to local_db when none is available).
  StorageBackendId get _defaultRestoreSource {
    if (_primary != StorageBackendId.localDb) return _primary;
    return StorageBackendId.values.firstWhere(
      (final id) =>
          id != StorageBackendId.localDb &&
          _enabled.contains(id) &&
          isConfiguredFor(id),
      orElse: () => StorageBackendId.localDb,
    );
  }

  /// Reads the payload from [backend] (defaults to the primary backend,
  /// or the first configured replication target when the primary is the
  /// local_db live store) and, when it succeeds and [apply] is set,
  /// applies it to the live local DB via [restoreApplier].
  Future<StorageOperationReport> restoreNow({
    final StorageBackendId? backend,
    final bool apply = true,
  }) async {
    final source = backend ?? _defaultRestoreSource;
    final report = await restore(source);
    if (!report.ok || !apply) return report;
    final applier = restoreApplier;
    if (applier == null) {
      _lastReport = StorageOperationReport(
        ok: false,
        backend: source,
        message: 'No restore applier registered',
      );
      notifyListeners();
      return _lastReport!;
    }
    try {
      await applier(_lastPayload);
      _lastReport = StorageOperationReport(
        ok: true,
        backend: source,
        message: 'restored and applied',
        bytes: report.bytes,
      );
    } catch (e) {
      _lastReport = StorageOperationReport(
        ok: false,
        backend: source,
        message: e.toString(),
      );
    }
    notifyListeners();
    return _lastReport!;
  }

  String _lastPayload = '';

  /// Last payload read by [restore] (empty when nothing was read yet).
  String get lastPayload => _lastPayload;

  MeshStorageService? _meshService;

  /// The live replica the doc-sync seams are attached to (see
  /// [_attachMeshSeams]); tracks identity so a rebuilt replica re-attaches
  /// a fresh store instead of one bound to dead storage.
  MeshStorageService? _meshSyncService;

  /// The live doc-replica store participating in the mesh sync cycle —
  /// agent docs' permission ops land here and ship with the mesh sync
  /// cycle.
  DocReplicaStore? _docReplicaStore;

  /// The live actor roster riding the mesh as durable ops (ADR 0007 §1).
  ActorRoster? _actorRoster;

  /// The live doc-replica store (null until [ensureMeshService] ran).
  DocReplicaStore? get docReplicaStore => _docReplicaStore;

  /// The live actor roster (null before the mesh replica ever opened).
  ActorRoster? get actorRoster => _actorRoster;

  /// Stable browser-safe peer identity persisted with backend config.
  String get meshPeerId {
    final existing = _meshPeerId;
    if (existing.isNotEmpty) return existing;
    return _meshPeerId = DateTime.now().microsecondsSinceEpoch.toString();
  }

  String _meshPeerId = '';

  /// Active mesh replica, created by [ensureMeshService].
  MeshStorageService? get meshService => _meshService;

  /// Opens the mesh replica once, choosing a persistent default store
  /// location on dart:io platforms so pairing survives restarts.
  Future<MeshStorageService> ensureMeshService() async {
    if (_meshService != null) return _meshService!;
    if (_meshStorePath.isEmpty) {
      final base = await platform.defaultFilesystemPath();
      _meshStorePath = base.isEmpty
          ? 'memory:$meshPeerId'
          : '$base/last-answer-mesh';
    }
    final service =
        await (meshServiceOpener ?? MeshStorageService.open)(
          storePath: _meshStorePath,
          relayEndpoint: _meshRelayEndpoint.isEmpty
              ? null
              : Uri.tryParse(_meshRelayEndpoint),
          peerId: meshPeerId,
        );
    await _persist();
    _attachMeshSeams(service);
    _meshService = service;
    notifyListeners();
    return service;
  }

  /// Task H — the doc replica store becomes LIVE (ADR 0005 §1 Phase 5b,
  /// ADR 0007 §1): one [DocReplicaStore] over the service's storage is
  /// attached to the sync cycle (agent docs get a deterministic replica
  /// id per doc when they open one), and one [ActorRoster] rides the mesh
  /// as durable ops ([attachRoster] forces its replica id to the pairing
  /// peer id). Re-attachment on a rebuilt replica is safe: the store is
  /// rebuilt per live replica (its storage is bound to the old one); the
  /// roster survives (kernel state, re-derived from the replica files on
  /// flush/absorb).
  void _attachMeshSeams(final MeshStorageService service) {
    if (identical(_meshSyncService, service)) return;
    _meshSyncService = service;
    _docReplicaStore = DocReplicaStore(
      storage: service.storage,
      actorId: meshPeerId,
    );
    final roster = _actorRoster ??= ActorRoster(replicaId: meshPeerId);
    service
      ..attachDocSync(_docReplicaStore!)
      ..attachRoster(roster);
  }

  /// Seamless setup, step "this is my main device": hosts the relay,
  /// persists the role + advertised endpoint, enables mesh replication,
  /// and publishes the current payload so joining devices receive it.
  Future<MeshStorageService> becomeMainDevice() async {
    final service = await ensureMeshService();
    final endpoint = await service.startHosting(port: _meshPort);
    _meshRole = MeshRole.main;
    _meshRelayEndpoint = endpoint.toString();
    _enabled.add(StorageBackendId.mesh);
    if (_primary == StorageBackendId.localDb) _primary = StorageBackendId.mesh;
    await _persist();
    notifyListeners();
    return service;
  }

  /// Seamless setup, step "I have a code": verifies the pairing code,
  /// registers and connects to its peer automatically, persists role +
  /// endpoint, then pulls the main device's payload into the live DB.
  Future<StorageOperationReport> joinWithCode(final String code) async {
    final service = await ensureMeshService();
    await service.acceptPairingCode(code);
    _meshRole = MeshRole.joined;
    _meshRelayEndpoint =
        service.connectedEndpoint?.toString() ?? _meshRelayEndpoint;
    _enabled.add(StorageBackendId.mesh);
    await _persist();
    // Bring this device up to date right away: publish our copy (in
    // case it has newer local edits) and pull the peer's copy in.
    var report = await replicate(
      backend: StorageBackendId.mesh,
      jsonPayload: await buildPayload(),
    );
    if (!report.ok) return report;
    try {
      await service.sync();
      // The sync cycle may have delivered remote doc ops (a routed
      // permission answer) — projections re-read the fold.
      onSyncCycle?.call();
    } on Exception catch (error) {
      report = StorageOperationReport(
        ok: false,
        backend: StorageBackendId.mesh,
        message: error.toString(),
      );
      _lastReport = report;
      notifyListeners();
      return report;
    }
    return restoreNow(backend: StorageBackendId.mesh);
  }

  /// Leaves the mesh: stops hosting, drops the live replica and clears
  /// the seamless-setup state (manual advanced fields are preserved).
  Future<void> leaveMesh() async {
    final service = _meshService;
    _meshService = null;
    // Flush the live doc replicas BEFORE the replica dies (its storage
    // dies with it); the store re-derives from the replica files on the
    // next attach.
    await _docReplicaStore?.dispose();
    _docReplicaStore = null;
    _meshSyncService = null;
    await service?.dispose();
    _meshRole = MeshRole.none;
    await _persist();
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_docReplicaStore?.dispose());
    _docReplicaStore = null;
    _meshSyncService = null;
    unawaited(_meshService?.dispose());
    _meshService = null;
    super.dispose();
  }

  /// Snapshot for MCP tools.
  Map<String, dynamic> snapshot() {
    final service = _meshService;
    return {
      'primary': _primary.name,
      // Legacy alias for older consumers (equals primary).
      'active': _primary.name,
      'enabled': _enabled.map((final id) => id.name).toList(),
      'filesystemPath': _filesystemPath,
      'gitPath': _gitPath,
      'meshStorePath': _meshStorePath,
      'meshPort': _meshPort,
      'meshRelayEndpoint': _meshRelayEndpoint,
      'meshRole': _meshRole.name,
      'meshHosting': service?.isHosting ?? false,
      'meshConnected': service?.isConnected ?? false,
      'meshPeers': service?.peers.length ?? 0,
      if (service?.advertisedEndpoint case final Uri endpoint)
        'meshAdvertisedEndpoint': endpoint.toString(),
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
}

class StorageBackendConfigException implements Exception {
  const StorageBackendConfigException(this.message);
  final String message;

  @override
  String toString() => message;
}
