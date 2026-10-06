import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:lastanswer/agent_config/agent_platform_config.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/doc/chat_inference_resolver.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _MapSecureStore implements SecureValueStore {
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async =>
      _values[key] = value;
}

final class InMemoryAgentConfigPersistence
    implements AgentConfigPersistence {
  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String contents) async => this.contents = contents;
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<ChatInferenceResolver> buildResolver({
    required AgentPlatformConfig config,
    String? secureKey,
    Map<String, String> environment = const {},
  }) async {
    final persistence = InMemoryAgentConfigPersistence()..contents = null;
    final store = AgentConfigStore(
      persistence: persistence,
      environment: environment,
    );
    await store.save(config);
    final secure = _MapSecureStore();
    if (secureKey != null) {
      await secure.write(
        ProviderConfigurationStore.providerKeyStoreId('open_router'),
        secureKey,
      );
    }
    return ChatInferenceResolver(
      configStore: store,
      providerKeys: ProviderConfigurationStore(
        secureValues: secure,
        preferences: SharedPreferences.getInstance,
      ),
    );
  }

  test('missing key resolves as missingCredential (env consulted)', () async {
    final resolver = await buildResolver(
      config: AgentPlatformConfig.defaults(),
    );
    final resolution = await resolver.resolve(
      documentId: 'doc-1',
      providerId: 'open_router',
      model: 'test/model',
    );
    expect(resolution.readiness, HostedChatReadiness.missingCredential);

    // The env var named by the provider config supplies the key.
    final withEnv = await buildResolver(
      config: AgentPlatformConfig.defaults(),
      environment: const {'OPENROUTER_API_KEY': 'env-key'},
    );
    // Consent has not been granted — the env key gets us to consent gate.
    final second = await withEnv.resolve(
      documentId: 'doc-1',
      providerId: 'open_router',
      model: 'test/model',
    );
    expect(second.readiness, HostedChatReadiness.consentRequired);
  });

  test('unknown provider id is a named error, never a guess', () async {
    final resolver = await buildResolver(
      config: AgentPlatformConfig.defaults(),
    );
    await expectLater(
      resolver.resolve(
        documentId: 'doc-1',
        providerId: 'nope',
        model: 'm',
      ),
      throwsStateError,
    );
  });

  test('defaultTarget derives from config with model fallback', () async {
    final persistence = InMemoryAgentConfigPersistence()..contents = null;
    final store = AgentConfigStore(
      persistence: persistence,
    );
    await store.save(
      const AgentPlatformConfig(
        providers: {
          'open_router': ProviderConfig(
            apiKeyEnv: 'OPENROUTER_API_KEY',
            models: ['m1', 'm2'],
          ),
        },
        chat: ChatConfig(defaultProvider: 'open_router'),
      ),
    );
    final resolver = ChatInferenceResolver(
      configStore: store,
      providerKeys: ProviderConfigurationStore(
        secureValues: _MapSecureStore(),
        preferences: SharedPreferences.getInstance,
      ),
    );
    final target = resolver.defaultTarget();
    expect(target?.providerId, 'open_router');
    expect(target?.model, 'm1');

    final empty = ChatInferenceResolver(
      configStore: AgentConfigStore(
        persistence: InMemoryAgentConfigPersistence(),
      ),
      providerKeys: ProviderConfigurationStore(
        secureValues: _MapSecureStore(),
        preferences: SharedPreferences.getInstance,
      ),
    );
    expect(empty.defaultTarget(), isNull);
  });
}
