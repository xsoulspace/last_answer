import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lastanswer/agent_config/agent_platform_config.dart';
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

  /// Per-provider secure-store key (the settings pane writes here). The
  /// legacy OpenRouter key is read as a fallback so pre-existing setups
  /// keep working.
  static String providerKeyStoreId(String providerId) =>
      'lastanswer.agent_config.provider.$providerId.key.v1';

  Future<String?> readProviderKey(String providerId) async {
    final value = (await _secureValues.read(
      providerKeyStoreId(providerId),
    ))?.trim();
    if (value != null && value.isNotEmpty) return value;
    if (providerId == AgentPlatformConfig.openRouterId) {
      return (await _secureValues.read(_openRouterKey))?.trim();
    }
    return null;
  }

  Future<void> writeProviderKey(String providerId, String value) async {
    final key = value.trim();
    if (key.isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be blank');
    }
    await _secureValues.write(providerKeyStoreId(providerId), key);
  }

  Future<void> removeProviderKey(String providerId) async {
    await _secureValues.delete(providerKeyStoreId(providerId));
    if (providerId == AgentPlatformConfig.openRouterId) {
      await _secureValues.delete(_openRouterKey);
    }
  }

  Future<bool> consentGranted({
    required String documentId,
    required String provider,
    required String model,
    required String workspace,
  }) async =>
      (await _preferences()).getBool(
        _consentKey(documentId, provider, model, workspace),
      ) ??
      false;

  /// Whether a key is already in the secure store (UI shows stored-state,
  /// never the key itself).
  Future<bool> hasProviderKey(String providerId) async {
    final value = await readProviderKey(providerId);
    return value != null && value.isNotEmpty;
  }

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
