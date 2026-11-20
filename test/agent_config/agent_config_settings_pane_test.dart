import 'package:lastanswer/common_imports.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/ui_models/agent_config/agent_config_persistence.dart';
import 'package:lastanswer/ui_models/agent_config/agent_config_settings_pane.dart';
import 'package:lastanswer/data_agents/config/provider_configuration.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Web parity: the pane renders identically over the prefs-backed store —
/// this is the configuration a fresh web user has (defaults, nothing
/// saved). ADR 0032: the pane is the AGENT SERVERS editor only — the
/// providers/chat-defaults/subscription editing moved to the Models
/// surface, so the retired chat-defaults dropdown regression test went
/// with them.
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
  child: const MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    home: Scaffold(body: AgentConfigSettingsPane(closeOnSave: false)),
  ),
);

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'fresh config renders the servers section with no save pending',
    (tester) async {
      final store = AgentConfigStore(
        persistence: InMemoryAgentConfigPersistence(),
      );
      await store.load();
      await tester.pumpWidget(_wrap(store));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('agent_config.server.add')), findsOneWidget);
      expect(find.byKey(const Key('agent_config.save')), findsOneWidget);
      // The duplicated provider/chat-defaults editing is gone (ADR 0032).
      expect(
        find.byKey(const Key('agent_config.chat.provider')),
        findsNothing,
      );
    },
  );

  testWidgets('editing a server row and saving persists to the store', (
    tester,
  ) async {
    final store = AgentConfigStore(
      persistence: InMemoryAgentConfigPersistence(),
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
