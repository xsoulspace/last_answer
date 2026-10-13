import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-IO persistence (web): the same document, stored as a JSON string in
/// shared preferences. There is no file system to edit by hand — the
/// settings pane is the editor.
final class PrefsAgentConfigPersistence implements AgentConfigPersistence {
  PrefsAgentConfigPersistence({
    Future<SharedPreferences>? preferences,
    String? storageKey,
  }) : _preferences = preferences ?? SharedPreferences.getInstance(),
       _key = storageKey ?? key;

  static const key = 'lastanswer.agent_config.json.v1';

  final Future<SharedPreferences> _preferences;
  final String _key;

  @override
  Future<String?> read() async => (await _preferences).getString(_key);

  @override
  Future<void> write(final String contents) async {
    await (await _preferences).setString(_key, contents);
  }
}

AgentConfigPersistence createPlatformAgentConfigPersistence({
  String documentName = 'agent_config.json',
}) => PrefsAgentConfigPersistence(storageKey: 'lastanswer.$documentName.v1');
