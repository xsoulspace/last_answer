import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _MemorySecureValues implements SecureValueStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  late _MemorySecureValues secureValues;
  late ProviderConfigurationStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    secureValues = _MemorySecureValues();
    store = ProviderConfigurationStore(
      preferences: SharedPreferences.getInstance,
      secureValues: secureValues,
    );
  });

  test('hosted dispatch requires a local credential before consent', () async {
    final result = await store.resolveOpenRouter(
      documentId: 'doc-a',
      model: 'model-a',
      workspace: '/tmp/a',
    );

    expect(result.readiness, HostedDispatchReadiness.missingCredential);
    expect(secureValues.values.values, isEmpty);
  });

  test('consent is bound to document, provider/model and workspace', () async {
    await store.replaceOpenRouterCredential(' private-key ');
    await store.grantHostedConsent(
      documentId: 'doc-a',
      provider: 'open_router',
      model: 'model-a',
      workspace: '/tmp/a',
    );

    final accepted = await store.resolveOpenRouter(
      documentId: 'doc-a',
      model: 'model-a',
      workspace: '/tmp/a',
    );
    final changedModel = await store.resolveOpenRouter(
      documentId: 'doc-a',
      model: 'model-b',
      workspace: '/tmp/a',
    );
    final copiedDocument = await store.resolveOpenRouter(
      documentId: 'doc-b',
      model: 'model-a',
      workspace: '/tmp/a',
    );

    expect(accepted.readiness, HostedDispatchReadiness.ready);
    expect(accepted.apiKey, 'private-key');
    expect(changedModel.readiness, HostedDispatchReadiness.consentRequired);
    expect(copiedDocument.readiness, HostedDispatchReadiness.consentRequired);
  });

  test('credential removal makes a prior consent unusable', () async {
    await store.replaceOpenRouterCredential('private-key');
    await store.grantHostedConsent(
      documentId: 'doc-a',
      provider: 'open_router',
      model: 'model-a',
      workspace: '/tmp/a',
    );
    await store.removeOpenRouterCredential();

    final result = await store.resolveOpenRouter(
      documentId: 'doc-a',
      model: 'model-a',
      workspace: '/tmp/a',
    );
    expect(result.readiness, HostedDispatchReadiness.missingCredential);
  });
}
