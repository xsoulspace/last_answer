import 'dart:async';

import 'package:flutter/material.dart';
import 'package:universal_storage_github_oauth/universal_storage_github_oauth.dart';

/// Notifier managing the GitHub connection state for sync.
///
/// Uses the OAuth device flow (see `universal_storage_github_oauth`):
/// works uniformly on all platforms without redirect plumbing. The
/// client ID is injected at build time:
/// `--dart-define=GITHUB_OAUTH_CLIENT_ID=Iv1.xxxx`.
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

  /// Whether a device flow is currently in progress.
  bool get connecting => _connecting;

  /// Whether GitHub credentials are stored.
  bool get connected => _connected;

  GithubDeviceFlowAuthProvider _providerFor(final BuildContext context) =>
      GithubDeviceFlowAuthProvider(
        flowConfig: const GithubDeviceFlowConfig(clientId: _clientId),
        // Credentials are persisted by SecureCredentialStorage, so each
        // operation may use its own provider instance; the delegate is
        // only exercised during [connect].
        delegate: DefaultDeviceFlowDelegate(context: context),
      );

  Future<bool> _isAuthenticated(final BuildContext context) =>
      _providerFor(context).isAuthenticated();

  /// Refreshes the connection state.
  Future<void> checkConnection(final BuildContext context) async {
    if (!isSupported) {
      _connected = false;
    } else {
      _connected = await _isAuthenticated(context);
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
    } on Exception catch (e) {
      _connected = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not connect GitHub: $e')),
        );
      }
    } finally {
      _connecting = false;
      notifyListeners();
    }
  }

  /// Clears stored credentials.
  Future<void> disconnect(final BuildContext context) async {
    await _providerFor(context).signOut();
    _connected = false;
    notifyListeners();
  }
}
