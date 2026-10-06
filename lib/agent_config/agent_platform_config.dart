/// Zed-style single-file configuration for agent runtimes and providers.
///
/// One declarative JSON document (`agent_config.json`) where any person can
/// register ACP agent servers (`command`/`args`/`env`), declare hosted
/// inference providers (which env var carries the API key, base URL, model
/// list), and pick chat defaults — the same shape Zed spells in
/// `settings.json` under `agent_servers`. The settings pane edits the SAME
/// document, so file and UI never diverge.
///
/// Secrets are deliberately NOT stored here: provider API keys live in the
/// platform secure store (entered in the UI) or in an environment variable
/// named by [ProviderConfig.apiKeyEnv] — never in a file that may be synced
/// or shared.
library;

import 'dart:convert';

/// One registered ACP agent server (Zed's `agent_servers` entry).
final class AgentServerConfig {
  const AgentServerConfig({
    required this.command,
    this.displayName,
    this.args = const [],
    this.env = const {},
  });

  factory AgentServerConfig.fromJson(final Map<String, dynamic> json) =>
      AgentServerConfig(
        command: _nonEmptyString(json['command']) ?? '',
        displayName: _nonEmptyString(json['displayName']),
        args: _stringList(json['args']),
        env: _stringMap(json['env']),
      );

  /// Executable to spawn (absolute path, or a name resolved on `PATH`).
  final String command;

  /// Human label shown in pickers; defaults to the registry key.
  final String? displayName;

  final List<String> args;

  /// Extra environment for the agent process. Values support
  /// `${VAR}` expansion from the process environment.
  final Map<String, String> env;

  Map<String, dynamic> toJson() => {
    'command': command,
    if (displayName != null) 'displayName': displayName,
    if (args.isNotEmpty) 'args': args,
    if (env.isNotEmpty) 'env': env,
  };

  AgentServerConfig copyWith({
    final String? command,
    final String? displayName,
    final List<String>? args,
    final Map<String, String>? env,
  }) => AgentServerConfig(
    command: command ?? this.command,
    displayName: displayName ?? this.displayName,
    args: args ?? this.args,
    env: env ?? this.env,
  );
}

/// One hosted inference provider (chat-completions compatible).
final class ProviderConfig {
  const ProviderConfig({
    this.apiKeyEnv = '',
    this.baseUrl = '',
    this.models = const [],
    this.defaultModel = '',
  });

  factory ProviderConfig.fromJson(final Map<String, dynamic> json) =>
      ProviderConfig(
        apiKeyEnv: _nonEmptyString(json['apiKeyEnv']) ?? '',
        baseUrl: _nonEmptyString(json['baseUrl']) ?? '',
        models: _stringList(json['models']),
        defaultModel: _nonEmptyString(json['defaultModel']) ?? '',
      );

  /// Environment variable carrying the API key at runtime
  /// (e.g. `OPENROUTER_API_KEY`). Empty = secure-store key only.
  final String apiKeyEnv;

  final String baseUrl;
  final List<String> models;

  /// Preferred model of this provider; empty = first of [models].
  final String defaultModel;

  Map<String, dynamic> toJson() => {
    if (apiKeyEnv.isNotEmpty) 'apiKeyEnv': apiKeyEnv,
    if (baseUrl.isNotEmpty) 'baseUrl': baseUrl,
    if (models.isNotEmpty) 'models': models,
    if (defaultModel.isNotEmpty) 'defaultModel': defaultModel,
  };

  ProviderConfig copyWith({
    final String? apiKeyEnv,
    final String? baseUrl,
    final List<String>? models,
    final String? defaultModel,
  }) => ProviderConfig(
    apiKeyEnv: apiKeyEnv ?? this.apiKeyEnv,
    baseUrl: baseUrl ?? this.baseUrl,
    models: models ?? this.models,
    defaultModel: defaultModel ?? this.defaultModel,
  );
}

/// Chat-surface defaults applied to NEW conversations (a chat document may
/// override provider/model/system prompt per doc).
final class ChatConfig {
  const ChatConfig({
    this.defaultProvider = '',
    this.defaultModel = '',
    this.systemPrompt = '',
  });

  factory ChatConfig.fromJson(final Map<String, dynamic> json) => ChatConfig(
    defaultProvider: _nonEmptyString(json['defaultProvider']) ?? '',
    defaultModel: _nonEmptyString(json['defaultModel']) ?? '',
    systemPrompt: json['systemPrompt'] is String
        ? json['systemPrompt'] as String
        : '',
  );

  /// Registry key in [AgentPlatformConfig.providers]; empty = none.
  final String defaultProvider;
  final String defaultModel;
  final String systemPrompt;

  Map<String, dynamic> toJson() => {
    if (defaultProvider.isNotEmpty) 'defaultProvider': defaultProvider,
    if (defaultModel.isNotEmpty) 'defaultModel': defaultModel,
    if (systemPrompt.isNotEmpty) 'systemPrompt': systemPrompt,
  };

  ChatConfig copyWith({
    final String? defaultProvider,
    final String? defaultModel,
    final String? systemPrompt,
  }) => ChatConfig(
    defaultProvider: defaultProvider ?? this.defaultProvider,
    defaultModel: defaultModel ?? this.defaultModel,
    systemPrompt: systemPrompt ?? this.systemPrompt,
  );
}

/// The whole configuration document.
final class AgentPlatformConfig {
  const AgentPlatformConfig({
    this.version = currentVersion,
    this.agentServers = const {},
    this.providers = const {},
    this.chat = const ChatConfig(),
  });

  factory AgentPlatformConfig.fromJson(final Map<String, dynamic> json) {
    final version = json['version'] is int
        ? json['version'] as int
        : currentVersion;
    final servers = <String, AgentServerConfig>{};
    final rawServers = json['agentServers'];
    if (rawServers is Map) {
      rawServers.forEach((final key, final value) {
        if (value is Map) {
          servers['$key'] = AgentServerConfig.fromJson(
            value.cast<String, dynamic>(),
          );
        }
      });
    }
    final providers = <String, ProviderConfig>{};
    final rawProviders = json['providers'];
    if (rawProviders is Map) {
      rawProviders.forEach((final key, final value) {
        if (value is Map) {
          providers['$key'] = ProviderConfig.fromJson(
            value.cast<String, dynamic>(),
          );
        }
      });
    }
    return AgentPlatformConfig(
      version: version,
      agentServers: servers,
      providers: providers,
      chat: json['chat'] is Map
          ? ChatConfig.fromJson((json['chat'] as Map).cast<String, dynamic>())
          : const ChatConfig(),
    );
  }

  factory AgentPlatformConfig.decode(final String contents) {
    if (contents.trim().isEmpty) return AgentPlatformConfig.defaults();
    final decoded = jsonDecode(contents);
    if (decoded is Map<String, dynamic>) {
      return AgentPlatformConfig.fromJson(decoded);
    }
    if (decoded is Map) {
      return AgentPlatformConfig.fromJson(
        decoded.cast<String, dynamic>(),
      );
    }
    throw const FormatException('agent config must be a JSON object');
  }

  /// Factory defaults: the hosted OpenRouter provider lane exists, no agent
  /// servers registered (the built-in catalog covers the known CLIs).
  factory AgentPlatformConfig.defaults() => const AgentPlatformConfig(
    providers: {openRouterId: ProviderConfig(apiKeyEnv: 'OPENROUTER_API_KEY')},
  );

  /// Known hosted provider registry keys and their factory defaults.
  static const String openRouterId = 'open_router';

  static const int currentVersion = 1;

  final int version;
  final Map<String, AgentServerConfig> agentServers;
  final Map<String, ProviderConfig> providers;
  final ChatConfig chat;

  Map<String, dynamic> toJson() => {
    'version': version,
    if (agentServers.isNotEmpty)
      'agentServers': {
        for (final entry in agentServers.entries)
          entry.key: entry.value.toJson(),
      },
    if (providers.isNotEmpty)
      'providers': {
        for (final entry in providers.entries)
          entry.key: entry.value.toJson(),
      },
    'chat': chat.toJson(),
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Expands `${VAR}` references against [environment]. Unknown variables
  /// expand to the empty string and are reported as [missing] so surfaces
  /// can name the fix ("set OPENROUTER_API_KEY").
  ({String value, List<String> missing}) expandEnv(
    final String raw, {
    final Map<String, String> environment = const {},
  }) {
    final missing = <String>[];
    final value = raw.replaceAllMapped(_envPattern, (final match) {
      final name = match.group(1) ?? '';
      final resolved = environment[name];
      if (resolved == null) missing.add(name);
      return resolved ?? '';
    });
    return (value: value, missing: missing);
  }

  AgentPlatformConfig copyWith({
    final Map<String, AgentServerConfig>? agentServers,
    final Map<String, ProviderConfig>? providers,
    final ChatConfig? chat,
  }) => AgentPlatformConfig(
    version: version,
    agentServers: agentServers ?? this.agentServers,
    providers: providers ?? this.providers,
    chat: chat ?? this.chat,
  );
}

final RegExp _envPattern = RegExp(r'\$\{([A-Za-z_][A-Za-z0-9_]*)\}');

String? _nonEmptyString(final Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

List<String> _stringList(final Object? value) => value is List
    ? [for (final item in value) if (item is String && item.isNotEmpty) item]
    : const [];

Map<String, String> _stringMap(final Object? value) => value is Map
    ? {
      for (final entry in value.entries)
        if (entry.value is String) '${entry.key}': entry.value as String,
    }
    : const {};
