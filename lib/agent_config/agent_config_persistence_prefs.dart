import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-IO persistence (web): the same document, stored as a JSON string in
/// shared preferences. There is no file system to edit by hand — the
/// settings pane is the editor.
final class PrefsAgentConfigPersistence implements AgentConfigPersistence {
  PrefsAgentConfigPersistence({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  static const key = 'lastanswer.agent_config.json.v1';

  final Future<SharedPreferences> _preferences;

  @override
  Future<String?> read() async =>
      (await _preferences).getString(key);

  @override
  Future<void> write(final String contents) async {
    await (await _preferences).setString(key, contents);
  }
}

AgentConfigPersistence createPlatformAgentConfigPersistence() =>
    PrefsAgentConfigPersistence();
