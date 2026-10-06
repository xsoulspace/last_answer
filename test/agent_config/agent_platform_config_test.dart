import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/agent_config/agent_platform_config.dart';

void main() {
  group('AgentPlatformConfig JSON', () {
    test('round-trips servers, providers, and chat defaults', () {
      const config = AgentPlatformConfig(
        agentServers: {
          'pi': AgentServerConfig(
            command: 'pi-acp',
            displayName: 'Pi',
            args: ['--flag'],
            env: {'PI_KEY': 'secret'},
          ),
        },
        providers: {
          'open_router': ProviderConfig(
            apiKeyEnv: 'OPENROUTER_API_KEY',
            baseUrl: 'https://openrouter.ai/api/v1',
            models: ['a/b', 'c/d'],
            defaultModel: 'a/b',
          ),
        },
        chat: ChatConfig(
          defaultProvider: 'open_router',
          defaultModel: 'a/b',
          systemPrompt: 'be brief',
        ),
      );
      final decoded = AgentPlatformConfig.decode(config.encode());
      expect(decoded.agentServers['pi']?.command, 'pi-acp');
      expect(decoded.agentServers['pi']?.displayName, 'Pi');
      expect(decoded.agentServers['pi']?.args, ['--flag']);
      expect(decoded.agentServers['pi']?.env['PI_KEY'], 'secret');
      expect(decoded.providers['open_router']?.models, ['a/b', 'c/d']);
      expect(decoded.chat.defaultModel, 'a/b');
      expect(decoded.chat.systemPrompt, 'be brief');
    });

    test('defaults expose the open_router provider lane', () {
      final defaults = AgentPlatformConfig.defaults();
      expect(
        defaults.providers[AgentPlatformConfig.openRouterId]?.apiKeyEnv,
        'OPENROUTER_API_KEY',
      );
      expect(defaults.agentServers, isEmpty);
    });

    test('empty document decodes to defaults shape, not a crash', () {
      final decoded = AgentPlatformConfig.decode('');
      expect(decoded.agentServers, isEmpty);
      expect(decoded.version, AgentPlatformConfig.currentVersion);
    });

    test('malformed entries are skipped, valid ones kept', () {
      final decoded = AgentPlatformConfig.decode(
        '{"version":1,"agentServers":{"bad":[1,2],"good":{"command":"x"}},'
        '"providers":{"p":{"models":["m",42]}}}',
      );
      expect(decoded.agentServers.keys, ['good']);
      expect(decoded.providers['p']?.models, ['m']);
    });

    test('non-object document throws a named error', () {
      expect(
        () => AgentPlatformConfig.decode('[1,2]'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('expandEnv', () {
    test('expands references and reports missing names', () {
      final config = AgentPlatformConfig.defaults();
      final expanded = config.expandEnv(
        r'key=${A_KEY} tail ${B_KEY}',
        environment: {'A_KEY': 'a1'},
      );
      expect(expanded.value, 'key=a1 tail ');
      expect(expanded.missing, ['B_KEY']);
    });

    test('leaves plain values untouched', () {
      final config = AgentPlatformConfig.defaults();
      final expanded = config.expandEnv('plain', environment: {});
      expect(expanded.value, 'plain');
      expect(expanded.missing, isEmpty);
    });
  });
}
