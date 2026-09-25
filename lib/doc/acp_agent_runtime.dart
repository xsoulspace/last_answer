import 'dart:async';
import 'dart:io';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';

/// A known desktop ACP agent and how to discover or install it.
final class AcpAgentCatalogEntry {
  const AcpAgentCatalogEntry({
    required this.id,
    required this.displayName,
    required this.commandCandidates,
    this.arguments = const [],
    this.installCommand,
    this.installHint,
  });

  final String id;
  final String displayName;
  final List<String> commandCandidates;
  final List<String> arguments;

  /// A declarative, user-approved installation command.
  ///
  /// The runtime never executes this automatically.
  final List<String>? installCommand;
  final String? installHint;
}

/// Declarative catalog for common desktop ACP clients.
final class AcpAgentCatalog {
  const AcpAgentCatalog({this.entries = defaultEntries});

  static const List<AcpAgentCatalogEntry> defaultEntries = [
    AcpAgentCatalogEntry(
      id: 'claude-code-acp',
      displayName: 'Claude Code ACP',
      commandCandidates: ['claude-code-acp'],
      installCommand: [
        'npm',
        'install',
        '-g',
        '@zed-industries/claude-code-acp',
      ],
      installHint: 'Requires Node.js and global npm access.',
    ),
    AcpAgentCatalogEntry(
      id: 'gemini',
      displayName: 'Gemini CLI',
      commandCandidates: ['gemini'],
      installCommand: ['npm', 'install', '-g', '@google/gemini-cli'],
      installHint: 'Requires Node.js and Google authentication.',
    ),
    AcpAgentCatalogEntry(
      id: 'codex',
      displayName: 'Codex CLI',
      commandCandidates: ['codex-acp', 'codex'],
      installCommand: ['npm', 'install', '-g', '@openai/codex'],
      installHint: 'Codex ACP support depends on the installed CLI version.',
    ),
  ];

  final List<AcpAgentCatalogEntry> entries;
}

/// An agent discovered on `PATH`.
final class AcpAgentInstallation {
  const AcpAgentInstallation({
    required this.entry,
    required this.path,
    this.version,
  });

  final AcpAgentCatalogEntry entry;
  final String path;
  final String? version;
}

extension AcpAgentInstallationX on AcpAgentInstallation {
  static AcpAgentInstallation localBinary({
    required String path,
    String displayName = 'Local ACP client',
    List<String> arguments = const [],
  }) => AcpAgentInstallation(
    entry: AcpAgentCatalogEntry(
      id: 'local:$path',
      displayName: displayName,
      commandCandidates: const [],
      arguments: arguments,
      installHint: 'Selected from the local filesystem.',
    ),
    path: path,
  );
}

/// Lifecycle state of the shared ACP agent process.
enum AcpRuntimeStatus { idle, starting, ready, stopped, error }

/// Configuration for a spawned ACP runtime.
final class AcpRuntimeConfig {
  const AcpRuntimeConfig({
    required this.command,
    this.arguments = const [],
    this.workingDirectory,
    this.environment,
  });

  factory AcpRuntimeConfig.fromInstallation(
    final AcpAgentInstallation installation, {
    final String? workingDirectory,
  }) => AcpRuntimeConfig(
    command: installation.path,
    arguments: installation.entry.arguments,
    workingDirectory: workingDirectory,
  );

  final String command;
  final List<String> arguments;
  final String? workingDirectory;
  final Map<String, String>? environment;
}

/// Metadata for an active ACP session.
final class AcpAgentSession {
  const AcpAgentSession({required this.id, required this.workingDirectory});

  final String id;
  final String workingDirectory;
}

/// Streaming update from an active prompt turn.
final class AcpPromptUpdate {
  const AcpPromptUpdate({this.textDelta, this.message});

  final String? textDelta;
  final String? message;
}

/// Completed prompt turn.
final class AcpPromptResult {
  const AcpPromptResult({required this.sessionId, required this.stopReason});

  final String sessionId;
  final String stopReason;
}

/// Creates or attaches an ACP client. Production code uses [AcpClient.spawn].
typedef AcpClientFactory = Future<AcpClient> Function(AcpRuntimeConfig config);

Future<AcpClient> spawnAcpClient(final AcpRuntimeConfig config) =>
    AcpClient.spawn(
      config.command,
      config.arguments,
      workingDirectory: config.workingDirectory,
      environment: config.environment,
    );

/// Discovers desktop ACP agents without executing their commands.
class AcpInstallationService {
  AcpInstallationService({
    final AcpAgentCatalog? catalog,
    this.processRunner = _runWhich,
  }) : catalog = catalog ?? const AcpAgentCatalog();

  final AcpAgentCatalog catalog;
  final Future<ProcessRunResult?> Function(String candidate) processRunner;

  Future<List<AcpAgentInstallation>> detectAll() async {
    final installations = <AcpAgentInstallation>[];
    for (final entry in catalog.entries) {
      final installation = await detect(entry);
      if (installation != null) installations.add(installation);
    }
    return installations;
  }

  Future<AcpAgentInstallation?> detect(final AcpAgentCatalogEntry entry) async {
    for (final candidate in entry.commandCandidates) {
      try {
        final result = await processRunner(candidate);
        if (result == null || result.exitCode != 0) continue;
        final path = result.stdout.trim();
        if (path.isEmpty || path.contains('\n')) continue;
        return AcpAgentInstallation(entry: entry, path: path);
      } on ProcessException {
        continue;
      }
    }
    return null;
  }

  Future<AcpAgentInstallation?> detectLocalPath(final String path) async {
    final file = File(path);
    if (!file.isAbsolute || !file.existsSync()) return null;
    if (FileSystemEntity.typeSync(path) != FileSystemEntityType.file) {
      return null;
    }
    final stat = file.statSync();
    if (!stat.modeString().contains('x')) return null;
    return AcpAgentInstallationX.localBinary(path: path);
  }
}

final class ProcessRunResult {
  const ProcessRunResult(this.exitCode, this.stdout);

  final int exitCode;
  final String stdout;
}

Future<ProcessRunResult?> _runWhich(final String candidate) async {
  final result = await Process.run('which', [candidate]);
  return ProcessRunResult(result.exitCode, '${result.stdout}');
}

/// Owns one initialized ACP client process and its sessions.
class AcpAgentRuntime {
  AcpAgentRuntime({this.clientFactory = spawnAcpClient});

  final AcpClientFactory clientFactory;

  AcpRuntimeStatus _status = AcpRuntimeStatus.idle;
  AcpClient? _client;
  Future<void>? _starting;
  Object? _error;
  final Map<String, AcpAgentSession> _sessions = {};
  String? _currentSessionId;

  AcpRuntimeStatus get status => _status;
  Object? get error => _error;
  bool get isReady => _status == AcpRuntimeStatus.ready;
  Map<String, AcpAgentSession> get sessions => Map.unmodifiable(_sessions);
  String? get currentSessionId => _currentSessionId;

  /// Starts and initializes the agent once.
  Future<void> start(final AcpRuntimeConfig config) {
    if (_status == AcpRuntimeStatus.ready ||
        _status == AcpRuntimeStatus.starting) {
      return Future.value();
    }
    if (_client != null) {
      throw StateError('A previous ACP client must be stopped before start');
    }
    _error = null;
    _status = AcpRuntimeStatus.starting;
    final future = _start(config);
    _starting = future;
    return future;
  }

  Future<void> _start(final AcpRuntimeConfig config) async {
    try {
      final client = await clientFactory(config);
      await client.initialize();
      _client = client;
      _status = AcpRuntimeStatus.ready;
    } on Object catch (error) {
      _error = error;
      _status = AcpRuntimeStatus.error;
      rethrow;
    } finally {
      _starting = null;
    }
  }

  Future<String> newSession(final String workingDirectory) async {
    final client = await _requireClient();
    final sessionId = await client.newSession(cwd: workingDirectory);
    final session = AcpAgentSession(
      id: sessionId,
      workingDirectory: workingDirectory,
    );
    _sessions[sessionId] = session;
    _currentSessionId = sessionId;
    return sessionId;
  }

  /// Switches the session used by [send] when no explicit ID is supplied.
  void switchTo(final String sessionId) {
    if (!_sessions.containsKey(sessionId)) {
      throw StateError('Unknown ACP session: $sessionId');
    }
    _currentSessionId = sessionId;
  }

  Stream<AcpPromptUpdate> send(final String prompt, {final String? sessionId}) {
    final controller = StreamController<AcpPromptUpdate>();
    unawaited(_send(prompt, sessionId ?? _currentSessionId, controller));
    return controller.stream;
  }

  Future<void> _send(
    final String prompt,
    final String? requestedSessionId,
    final StreamController<AcpPromptUpdate> controller,
  ) async {
    try {
      final client = await _requireClient();
      if (requestedSessionId == null) {
        throw StateError('No current ACP session');
      }
      await client.promptText(
        requestedSessionId,
        prompt,
        onUpdate: (update) {
          if (controller.isClosed) return;
          if (update is AgentMessageChunk) {
            final content = update.content;
            if (content is AcpTextBlock && content.text.isNotEmpty) {
              controller.add(AcpPromptUpdate(textDelta: content.text));
            }
          } else if (update is ToolCallUpdate) {
            controller.add(
              AcpPromptUpdate(message: update.title ?? update.toolCallId),
            );
          }
        },
      );
      await controller.close();
    } on Object catch (error) {
      _error = error;
      if (!controller.isClosed) {
        controller.addError(error);
        await controller.close();
      }
    }
    final client = _client;
    if ((client?.isClosed ?? false) && _status == AcpRuntimeStatus.ready) {
      _client = null;
      _status = AcpRuntimeStatus.stopped;
    }
  }

  void cancel([final String? sessionId]) {
    final id = sessionId ?? _currentSessionId;
    if (id == null) return;
    _client?.cancel(id);
  }

  Future<void> stop() async {
    final client = _client;
    _client = null;
    _sessions.clear();
    _currentSessionId = null;
    if (_status != AcpRuntimeStatus.error) _status = AcpRuntimeStatus.stopped;
    await client?.dispose();
  }

  Future<AcpClient> _requireClient() async {
    final inFlight = _starting;
    if (inFlight != null) await inFlight;
    final client = _client;
    if (client == null || client.isClosed) {
      throw StateError('ACP runtime is not ready');
    }
    if (_status != AcpRuntimeStatus.ready) {
      throw StateError('ACP runtime is not ready');
    }
    return client;
  }
}
