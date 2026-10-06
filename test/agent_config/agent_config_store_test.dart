import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:lastanswer/agent_config/agent_platform_config.dart';

final class InMemoryAgentConfigPersistence
    implements AgentConfigPersistence {
  String? contents;
  int writes = 0;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String contents) async {
    writes++;
    this.contents = contents;
  }
}

void main() {
  group('AgentConfigStore', () {
    test('load on an empty store yields defaults', () async {
      final persistence = InMemoryAgentConfigPersistence();
      final store = AgentConfigStore(
        persistence: persistence,
      );
      await store.load();
      expect(store.isLoaded, isTrue);
      expect(store.lastError, isNull);
      expect(
        store.config.providers.containsKey(AgentPlatformConfig.openRouterId),
        isTrue,
      );
    });

    test('save persists the document and notifies listeners', () async {
      final persistence = InMemoryAgentConfigPersistence();
      final store = AgentConfigStore(
        persistence: persistence,
      );
      await store.load();
      var notified = 0;
      store.addListener(() => notified++);
      await store.putAgentServer(
        'pi',
        const AgentServerConfig(command: 'pi-acp'),
      );
      expect(notified, 1);
      expect(persistence.writes, 1);
      expect(persistence.contents, contains('pi-acp'));
      expect(store.config.agentServers['pi']?.command, 'pi-acp');
    });

    test('corrupt document falls back to defaults with a named error',
        () async {
      final persistence = InMemoryAgentConfigPersistence()
        ..contents = '{not json';
      final store = AgentConfigStore(
        persistence: persistence,
      );
      await store.load();
      expect(store.lastError, isNotNull);
      expect(
        store.config.providers.containsKey(AgentPlatformConfig.openRouterId),
        isTrue,
      );
      // A later save repairs the document and clears the error.
      await store.putProvider(
        'open_router',
        const ProviderConfig(apiKeyEnv: 'OPENROUTER_API_KEY'),
      );
      expect(store.lastError, isNull);
    });

    test('removeAgentServer drops the entry', () async {
      final store = AgentConfigStore(
        persistence: InMemoryAgentConfigPersistence(),
      );
      await store.load();
      await store.putAgentServer(
        'x',
        const AgentServerConfig(command: 'x'),
      );
      await store.removeAgentServer('x');
      expect(store.config.agentServers, isEmpty);
    });
  });
}
