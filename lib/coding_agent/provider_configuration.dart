import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local configuration for a hosted coding provider. Document payloads
/// deliberately never carry credentials or cloud-transmission consent.
abstract interface class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

final class FlutterSecureValueStore implements SecureValueStore {
  FlutterSecureValueStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

enum HostedDispatchReadiness { ready, missingCredential, consentRequired }

final class HostedDispatchConfiguration {
  const HostedDispatchConfiguration._(this.readiness, {this.apiKey});

  const HostedDispatchConfiguration.ready(String apiKey)
    : this._(HostedDispatchReadiness.ready, apiKey: apiKey);
  const HostedDispatchConfiguration.missingCredential()
    : this._(HostedDispatchReadiness.missingCredential);
  const HostedDispatchConfiguration.consentRequired()
    : this._(HostedDispatchReadiness.consentRequired);

  final HostedDispatchReadiness readiness;
  final String? apiKey;
}

/// A consent is scoped to the exact local document, provider/model and
/// workspace destination. A copied/imported document on another device has no
/// matching local record and must ask again.
final class ProviderConfigurationStore {
  ProviderConfigurationStore({
    Future<SharedPreferences> Function()? preferences,
    SecureValueStore? secureValues,
  }) : _preferences = preferences ?? SharedPreferences.getInstance,
       _secureValues = secureValues ?? FlutterSecureValueStore();

  static const _openRouterKey = 'lastanswer.coding_agent.open_router.key.v1';
  static const _consentPrefix = 'lastanswer.coding_agent.hosted_consent.v1.';

  final Future<SharedPreferences> Function() _preferences;
  final SecureValueStore _secureValues;

  Future<bool> get hasOpenRouterCredential async =>
      (await _secureValues.read(_openRouterKey))?.trim().isNotEmpty ?? false;

  Future<void> replaceOpenRouterCredential(String value) async {
    final key = value.trim();
    if (key.isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be blank');
    }
    await _secureValues.write(_openRouterKey, key);
  }

  Future<void> removeOpenRouterCredential() =>
      _secureValues.delete(_openRouterKey);

  Future<void> grantHostedConsent({
    required String documentId,
    required String provider,
    required String model,
    required String workspace,
  }) async {
    await (await _preferences()).setBool(
      _consentKey(documentId, provider, model, workspace),
      true,
    );
  }

  Future<void> revokeHostedConsent({
    required String documentId,
    required String provider,
    required String model,
    required String workspace,
  }) async {
    await (await _preferences()).remove(
      _consentKey(documentId, provider, model, workspace),
    );
  }

  Future<HostedDispatchConfiguration> resolveOpenRouter({
    required String documentId,
    required String model,
    required String workspace,
  }) async {
    final key = (await _secureValues.read(_openRouterKey))?.trim();
    if (key == null || key.isEmpty) {
      return const HostedDispatchConfiguration.missingCredential();
    }
    final consent =
        (await _preferences()).getBool(
          _consentKey(documentId, 'open_router', model, workspace),
        ) ??
        false;
    return consent
        ? HostedDispatchConfiguration.ready(key)
        : const HostedDispatchConfiguration.consentRequired();
  }

  String _consentKey(
    String documentId,
    String provider,
    String model,
    String workspace,
  ) =>
      '$_consentPrefix${Uri.encodeComponent(documentId)}.'
      '${Uri.encodeComponent(provider)}.${Uri.encodeComponent(model)}.'
      '${Uri.encodeComponent(workspace)}';
}
