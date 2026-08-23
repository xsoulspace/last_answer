// MANUAL e2e check of the device flow against REAL GitHub endpoints using
// the configured client ID. Prints a one-time code; a human completes the
// authorization in a browser while the test polls.
//
// Run:
//   GITHUB_E2E=1 flutter test test/github_device_flow_real_test.dart \
//     --dart-define-from-file=configs/envs/prod.json --timeout 600s
//
// Skipped automatically unless GITHUB_E2E=1 is set (it requires a human
// at the browser and hits real network).
//
// Note: GitHub App user tokens start with `ghu_` (OAuth apps: `gho_`).
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:universal_storage_github_oauth/universal_storage_github_oauth.dart';
import 'package:universal_storage_oauth/universal_storage_oauth.dart';

class _MemoryStorage implements CredentialStorage {
  final Map<GitPlatform, StoredCredentials> _store = {};

  @override
  Future<void> clearAllCredentials() async => _store.clear();

  @override
  Future<void> clearCredentials(final GitPlatform platform) async =>
      _store.remove(platform);

  @override
  Future<bool> hasCredentials(final GitPlatform platform) async =>
      _store.containsKey(platform);

  @override
  Future<StoredCredentials?> getCredentials(final GitPlatform platform) async =>
      _store[platform];

  @override
  Future<void> storeCredentials(
    final GitPlatform platform,
    final StoredCredentials credentials,
  ) async => _store[platform] = credentials;
}

class _PrintingDelegate implements OAuthFlowDelegate {
  @override
  Future<String> getAuthorizationCode(
    final Uri a,
    final Uri r, {
    final String? state,
  }) => throw UnimplementedError();

  @override
  Future<void> handleDeviceFlow({
    required final String deviceCode,
    required final String userCode,
    required final Uri verificationUrl,
    required final int expiresIn,
    required final int interval,
    final Uri? verificationUrlComplete,
  }) async {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('════════════════════════════════════════════');
    // ignore: avoid_print
    print('OPEN:  $verificationUrl');
    // ignore: avoid_print
    print('CODE:  $userCode');
    // ignore: avoid_print
    print('(expires in ${expiresIn ~/ 60} min — waiting for you…)');
    // ignore: avoid_print
    print('════════════════════════════════════════════');
  }

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

void main() {
  test('e2e: real GitHub device flow → token → current user', () async {
    if (Platform.environment['GITHUB_E2E'] != '1') {
      // ignore: avoid_print
      print('skipped: set GITHUB_E2E=1 to run this manual check');
      return;
    }
    const clientId = String.fromEnvironment('GITHUB_OAUTH_CLIENT_ID');
    expect(clientId, isNotEmpty, reason: 'pass --dart-define-from-file=configs/envs/prod.json');

    final provider = GithubDeviceFlowAuthProvider(
      flowConfig: const GithubDeviceFlowConfig(clientId: clientId),
      delegate: _PrintingDelegate(),
      storage: _MemoryStorage(),
    );

    await provider.signOut(); // start clean

    final result = await provider.authenticate().timeout(
      const Duration(minutes: 9),
      onTimeout: () => throw Exception('timed out waiting for authorization'),
    );

    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('✅ TOKEN OBTAINED (masked): '
        '${result.credentials?.accessToken.safeRepresentation}');
    // ignore: avoid_print
    print('✅ USER: ${result.user?.login} (${result.user?.email})');

    expect(await provider.isAuthenticated(), isTrue);
    expect(result.user?.login, isNotEmpty);
    expect(result.credentials?.accessToken.value, anyOf(startsWith('gho_'), startsWith('ghu_')));

    await provider.signOut();
    // ignore: avoid_print
    print('✅ SIGN OUT OK (credentials cleared)');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
