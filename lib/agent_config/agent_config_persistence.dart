import 'package:flutter/foundation.dart';
import 'package:lastanswer/agent_config/agent_config_persistence_prefs.dart'
    if (dart.library.io) 'agent_config_persistence_io.dart'
    show createPlatformAgentConfigPersistence;
import 'package:lastanswer/agent_config/agent_platform_config.dart';

/// Where the one configuration document lives.
///
/// Native (desktop + mobile): a JSON file under the app-support directory —
/// the Zed model, user-editable by hand. Web: shared preferences (there is
/// no file system); encode/decode keeps the document identical.
abstract interface class AgentConfigPersistence {
  Future<String?> read();
  Future<void> write(String contents);
}

/// Loads, mutates and persists [AgentPlatformConfig]; notifies listeners so
/// open surfaces re-render when the file (or another surface) changes it.
final class AgentConfigStore extends ChangeNotifier {
  AgentConfigStore({
    final AgentConfigPersistence? persistence,
    this.environment = const {},
  }) : _persistence = persistence ?? createPlatformAgentConfigPersistence();

  final AgentConfigPersistence _persistence;

  /// Process environment used for `${VAR}` expansion of agent-server env
  /// values and provider key lookups. Injected by the composition root
  /// (web passes an empty map).
  final Map<String, String> environment;

  /// Expands `${VAR}` references in [raw] against [environment] (see
  /// [AgentPlatformConfig.expandEnv]).
  ({String value, List<String> missing}) expandEnv(
    final String raw, {
    final Map<String, String>? environment,
  }) => config.expandEnv(raw, environment: environment ?? this.environment);

  AgentPlatformConfig _config = AgentPlatformConfig.defaults();
  String? _lastError;
  bool _loaded = false;

  AgentPlatformConfig get config => _config;

  /// Non-null when the last load saw an unreadable document (the store keeps
  /// working on defaults and surfaces name the corruption instead of dying).
  String? get lastError => _lastError;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    try {
      final contents = await _persistence.read();
      _config = contents == null
          ? AgentPlatformConfig.defaults()
          : AgentPlatformConfig.decode(contents);
      _lastError = null;
    } on Object catch (error) {
      _config = AgentPlatformConfig.defaults();
      _lastError = error.toString();
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> save(final AgentPlatformConfig config) async {
    _config = config;
    await _persistence.write(config.encode());
    _lastError = null;
    notifyListeners();
  }

  Future<void> putAgentServer(
    final String id,
    final AgentServerConfig server,
  ) async {
    await save(
      _config.copyWith(
        agentServers: {..._config.agentServers, id: server},
      ),
    );
  }

  Future<void> removeAgentServer(final String id) async {
    final servers = {..._config.agentServers}..remove(id);
    await save(_config.copyWith(agentServers: servers));
  }

  Future<void> putProvider(final String id, final ProviderConfig provider) =>
      save(
        _config.copyWith(providers: {..._config.providers, id: provider}),
      );
}
