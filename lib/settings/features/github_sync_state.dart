import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_storage_github_api/universal_storage_github_api.dart';
// ignore: depend_on_referenced_packages -- resolved transitively via core
import 'package:universal_storage_github_oauth/universal_storage_github_oauth.dart';
// ignore: depend_on_referenced_packages -- resolved transitively via core
import 'package:universal_storage_interface/universal_storage_interface.dart'
    show GitHubApiConfig, StorageService, VcRepositoryName, VcRepositoryOwner;

/// Where the repo selection is persisted.
const _configKey = 'github_sync_config_v1';

/// Selected GitHub storage target.
@immutable
class GithubSyncSelection {
  const GithubSyncSelection({
    required this.owner,
    required this.repo,
    this.subdirectory = 'notes',
  });

  factory GithubSyncSelection.fromJson(final Map<String, dynamic> json) =>
      GithubSyncSelection(
        owner: json['owner'] as String? ?? '',
        repo: json['repo'] as String? ?? '',
        subdirectory: json['subdir'] as String? ?? 'notes',
      );

  final String owner;
  final String repo;
  final String subdirectory;

  /// Path prefix inside the repository ('' = root), normalized to have
  /// no leading/trailing slashes.
  String get prefix {
    var value = subdirectory.trim();
    while (value.startsWith('/')) {
      value = value.substring(1);
    }
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  Map<String, dynamic> toJson() => {
    'owner': owner,
    'repo': repo,
    'subdir': subdirectory,
  };
}

/// High-level state machine for GitHub sync:
/// notConnected → (device flow) → selectingRepo → ready(owner/repo/subdir).
class GithubSyncNotifier extends ChangeNotifier {
  /// Client ID of the "Last Answer Sync" GitHub App.
  // dart-define is the intended injection mechanism here; the lint targets
  // compile-time secrets, not public client IDs.
  // ignore: do_not_use_environment
  static const _clientId = String.fromEnvironment('GITHUB_OAUTH_CLIENT_ID');

  /// Whether sync can be enabled (client ID configured).
  static bool get isSupported => _clientId.isNotEmpty;

  bool _connecting = false;
  bool _connected = false;
  bool _busy = false;
  GithubSyncSelection? _selection;
  List<RepositoryInfo> _repos = const [];

  /// Whether a device flow is currently in progress.
  bool get connecting => _connecting;

  /// Whether GitHub credentials are stored.
  bool get connected => _connected;

  /// True while a network operation (auth/repo list/backup/restore) runs.
  bool get busy => _busy;

  /// Repositories available for selection (after [connect]).
  List<RepositoryInfo> get repos => _repos;

  /// Current selection, if configured.
  GithubSyncSelection? get selection => _selection;

  /// Whether a target repo is selected and sync can run.
  bool get isConfigured =>
      _connected && _selection != null && _selection!.repo.isNotEmpty;

  final _storage = SecureCredentialStorage();
  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> _prefs() =>
      _prefsFuture ??= SharedPreferences.getInstance();

  /// Restores persisted configuration and connection state on startup.
  Future<void> checkConnection(final BuildContext context) async {
    if (!isSupported) {
      _connected = false;
      notifyListeners();
      return;
    }
    try {
      final prefs = await _prefs();
      final raw = prefs.getString(_configKey);
      if (raw != null) {
        _selection = GithubSyncSelection.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      }
      _connected = await _headlessProvider.isAuthenticated();
    } on Exception {
      _connected = false;
    }
    notifyListeners();
  }

  /// Runs the device flow; [context] hosts the code dialog and snackbars.
  Future<void> connect(final BuildContext context) async {
    if (_connecting || !isSupported) return;
    _connecting = true;
    notifyListeners();
    try {
      await _providerFor(context).authenticate();
      _connected = true;
      await _loadRepos();
      // If a previous selection exists, stay ready; otherwise UI moves to
      // repo picking via [needsRepoSelection].
    } on Exception catch (e) {
      _connected = false;
      if (context.mounted) _showError(context, e.toString());
    } finally {
      _connecting = false;
      notifyListeners();
    }
  }

  /// Connects using a user-provided Personal Access Token instead of the
  /// device flow. Validates the token against the GitHub API before
  /// storing it.
  Future<bool> connectWithToken(
    final BuildContext context, {
    required final String token,
  }) async {
    if (_busy || token.trim().isEmpty) return false;
    _busy = true;
    notifyListeners();
    try {
      final trimmed = token.trim();
      // Validate before storing: GET /user with this token must succeed.
      final response = await Dio().get<Object?>(
        'https://api.github.com/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $trimmed',
            'Accept': 'application/vnd.github+json',
          },
          validateStatus: (final _) => true,
        ),
      );
      if (response.statusCode != 200) {
        throw AuthenticationException(
          'GitHub returned HTTP ${response.statusCode}',
        );
      }
      await _storage.storeCredentials(
        GitPlatform.github,
        StoredCredentials.create(accessToken: OAuthAccessToken(trimmed)),
      );
      _connected = true;
      await _loadRepos();
      return true;
    } on Exception catch (e) {
      if (context.mounted) _showError(context, e.toString());
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Clears credentials and persisted selection.
  Future<void> disconnect(final BuildContext context) async {
    await _headlessProvider.signOut();
    final prefs = await _prefs();
    await prefs.remove(_configKey);
    _connected = false;
    _selection = null;
    _repos = const [];
    notifyListeners();
  }

  bool get needsRepoSelection =>
      _connected && !_busy && (_selection == null || _repos.isEmpty);

  /// Selects (or switches to) the target repository.
  Future<void> selectRepository({
    required final String owner,
    required final String repo,
  }) async {
    _selection = GithubSyncSelection(
      owner: owner,
      repo: repo,
      subdirectory: _selection?.subdirectory ?? 'notes',
    );
    await _persistSelection();
  }

  /// Deselects the repository, returning to the picker.
  Future<void> clearSelection() async {
    if (_selection == null) return;
    final prefs = await _prefs();
    await prefs.remove(_configKey);
    _selection = null;
    notifyListeners();
  }

  /// Updates the in-repository subdirectory used for backups.
  Future<void> setSubdirectory(final String value) async {
    if (_selection == null) return;
    _selection = GithubSyncSelection(
      owner: _selection!.owner,
      repo: _selection!.repo,
      subdirectory: value,
    );
    await _persistSelection();
  }

  /// Creates a new private repository under the authenticated user.
  Future<void> createRepository({
    required final BuildContext context,
    required final String name,
  }) async {
    if (!isSupported || name.trim().isEmpty) return;
    _busy = true;
    notifyListeners();
    try {
      final service = GitHubRepositoryService(_providerFor(context));
      final info = await service.createRepository(
        CreateRepositoryRequest(name: name.trim(), isPrivate: true),
      );
      final owner = info.fullName.contains('/')
          ? info.fullName.split('/').first
          : '';
      await selectRepository(owner: owner, repo: info.name);
    } on Exception catch (e) {
      if (context.mounted) _showError(context, e.toString());
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Writes [jsonPayload] to `<subdir>/last-answer-backup.json`.
  ///
  /// Returns the commit message from GitHub or throws.
  Future<String?> backupNow(
    final BuildContext context, {
    required final String jsonPayload,
  }) async {
    final result = await _withTarget(context, (
      final service,
      final path,
    ) async {
      await service.saveFile(path, jsonPayload, message: 'Last Answer backup');
      return null;
    });
    return result as String?;
  }

  /// Reads `<subdir>/last-answer-backup.json`; returns payload JSON or
  /// `null` when the file does not exist yet.
  Future<String?> restoreNow(final BuildContext context) =>
      _withTarget(
            context,
            (final service, final path) => service.readFile(path),
          )
          as Future<String?>;

  Future<Object?> _withTarget(
    final BuildContext context,
    final Future<Object?> Function(StorageService service, String path) action,
  ) async {
    final selection = _selection;
    if (!isSupported || selection == null) return null;
    _busy = true;
    notifyListeners();
    try {
      final token = await _storage.getCredentials(GitPlatform.github);
      if (token == null || token.accessToken.isEmpty) {
        throw const AuthenticationException('Not connected to GitHub');
      }
      final provider = GitHubApiStorageProvider();
      await provider.initWithConfig(
        GitHubApiConfig(
          authToken: token.accessToken.value,
          repositoryOwner: VcRepositoryOwner(selection.owner),
          repositoryName: VcRepositoryName(selection.repo),
        ),
      );
      final service = StorageService(provider);
      final path = selection.prefix.isEmpty
          ? 'last-answer-backup.json'
          : '${selection.prefix}/last-answer-backup.json';
      return await action(service, path);
    } on Exception catch (e) {
      if (context.mounted) _showError(context, e.toString());
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Provider with the interactive device-flow UI delegate.
  GithubDeviceFlowAuthProvider _providerFor(final BuildContext context) =>
      GithubDeviceFlowAuthProvider(
        flowConfig: const GithubDeviceFlowConfig(clientId: _clientId),
        delegate: DefaultDeviceFlowDelegate(context: context),
      );

  /// Provider for non-UI operations (listing repos, checking auth); its
  /// delegate is never exercised.
  GithubDeviceFlowAuthProvider get _headlessProvider =>
      GithubDeviceFlowAuthProvider(
        flowConfig: const GithubDeviceFlowConfig(clientId: _clientId),
        delegate: const _NoUiDelegate(),
      );

  Future<void> _loadRepos() async {
    try {
      final service = GitHubRepositoryService(_headlessProvider);
      _repos = await service.getUserRepositories();
    } on Exception {
      _repos = const [];
    }
  }

  Future<void> _persistSelection() async {
    final prefs = await _prefs();
    if (_selection == null) {
      await prefs.remove(_configKey);
    } else {
      await prefs.setString(_configKey, jsonEncode(_selection!.toJson()));
    }
    notifyListeners();
  }

  void _showError(final BuildContext context, final String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('GitHub error: $message')));
  }
}

/// Delegate that never runs a flow; used for headless operations.
class _NoUiDelegate implements OAuthFlowDelegate {
  const _NoUiDelegate();

  @override
  Future<String> getAuthorizationCode(
    final Uri authorizationUrl,
    final Uri redirectUrl, {
    final String? state,
  }) => throw UnsupportedError('no UI in headless delegate');

  @override
  Future<void> handleDeviceFlow({
    required final String deviceCode,
    required final String userCode,
    required final Uri verificationUrl,
    required final int expiresIn,
    required final int interval,
    final Uri? verificationUrlComplete,
  }) => throw UnsupportedError('no UI in headless delegate');

  @override
  Future<void> onAuthorizationSuccess({
    required final String maskedToken,
    required final List<String> scopes,
  }) async {}

  @override
  Future<void> onAuthorizationError({
    required final String error,
    final String? description,
  }) async {}
}
