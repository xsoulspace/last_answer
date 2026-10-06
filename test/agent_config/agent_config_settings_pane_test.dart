import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:lastanswer/agent_config/agent_platform_config.dart';
import 'package:lastanswer/agent_config/agent_config_settings_pane.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Web parity: the pane renders identically over the prefs-backed store —
/// this is the configuration a fresh web user has (defaults, nothing
/// saved). Regression: the chat-defaults dropdowns asserted on the empty
/// initial value ("There should be exactly one item with [DropdownButton]'s
/// value") — found on web.
final class InMemoryAgentConfigPersistence implements AgentConfigPersistence {
  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String contents) async => this.contents = contents;
}

Widget _wrap(final AgentConfigStore store) => MultiProvider(
  providers: [
    ListenableProvider<AgentConfigStore>.value(value: store),
    Provider<ProviderConfigurationStore>(
      create: (_) => ProviderConfigurationStore(
        secureValues: _NoSecureStore(),
        preferences: SharedPreferences.getInstance,
      ),
    ),
  ],
  child: MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    home: const Scaffold(body: AgentConfigSettingsPane(closeOnSave: false)),
  ),
);

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'fresh config (no chat defaults) renders without dropdown assertions',
    (tester) async {
      final store = AgentConfigStore(
        persistence: InMemoryAgentConfigPersistence(),
        environment: const {},
      );
      await store.load();
      await tester.pumpWidget(_wrap(store));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('agent_config.chat.provider')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('agent_config.chat.model')),
        findsOneWidget,
      );
    },
  );

  testWidgets('editing a server row and saving persists to the store',
      (tester) async {
    final store = AgentConfigStore(
      persistence: InMemoryAgentConfigPersistence(),
      environment: const {},
    );
    await store.load();
    await tester.pumpWidget(_wrap(store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('agent_config.server.add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('agent_config.server.server-1.command')),
      'pi-acp',
    );
    await tester.tap(find.byKey(const Key('agent_config.save')));
    await tester.pumpAndSettle();

    expect(store.config.agentServers['server-1']?.command, 'pi-acp');
  });
}

final class _NoSecureStore implements SecureValueStore {
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}
