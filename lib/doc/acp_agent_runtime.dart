import 'dart:async';
import 'dart:io';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';

export 'package:dart_acp_toolkit/dart_acp_toolkit.dart'
    show
        AcpAuthMethod,
        AcpAuthRequiredException,
        AcpRemoteError,
        AcpSessionModes,
        AcpSessionModeInfo;

/// A known desktop ACP agent and how to discover or install it.
final class AcpAgentCatalogEntry {
  const AcpAgentCatalogEntry({
    required this.id,
    required this.displayName,
    required this.commandCandidates,
    this.arguments = const [],
    this.installCommand,
    this.installHint,
    this.authHint,
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

  /// What the user runs to authenticate, for terminal-auth agents (the
  /// credentials stay in the agent's own store — Last Answer never holds
  /// them). Agents that complete OAuth over ACP answer
  /// `session/authenticate` instead and do not need this.
  final String? authHint;
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
      authHint:
          'Run `claude /login` in a terminal (Anthropic OAuth); the '
          'ACP adapter reuses the CLI credentials.',
    ),
    AcpAgentCatalogEntry(
      id: 'gemini',
      displayName: 'Gemini CLI',
      commandCandidates: ['gemini'],
      // Bare `gemini` starts the interactive TUI and never speaks ACP —
      // the protocol server rides behind this flag.
      arguments: ['--experimental-acp'],
      installCommand: ['npm', 'install', '-g', '@google/gemini-cli'],
      installHint: 'Requires Node.js and Google authentication.',
      authHint:
          'Set GEMINI_API_KEY (or run gemini once in a terminal '
          'and complete the Google OAuth sign-in); credentials stay in '
          "the CLI's own store.",
    ),
    AcpAgentCatalogEntry(
      id: 'codex',
      displayName: 'Codex CLI',
      // The ACP launcher is Zed's separate adapter package; the stock
      // `codex` binary is the interactive CLI and never speaks ACP.
      commandCandidates: ['codex-acp'],
      installCommand: ['npm', 'install', '-g', '@zed-industries/codex-acp'],
      installHint:
          'Requires Node.js and the Codex CLI installed and logged in '
          '(`codex login`).',
      authHint:
          'Run `codex login` in a terminal (ChatGPT or API key); '
          'credentials stay in the CLI config.',
    ),
    AcpAgentCatalogEntry(
      id: 'pi',
      displayName: 'Pi (pi-acp)',
      commandCandidates: ['pi-acp'],
      installCommand: ['npm', 'install', '-g', 'pi-acp'],
      installHint:
          'ACP adapter for the pi coding agent; requires Node.js and '
          "pi's own provider credentials.",
      authHint:
          'Run `pi auth <provider>` in a terminal to check or set '
          'provider credentials; they stay in the pi config store.',
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
  const AcpPromptUpdate({
    this.textDelta,
    this.message,
    this.toolStatus,
    this.planEntries,
  });

  final String? textDelta;

  /// Tool-call title (or raw id when the agent sent none).
  final String? message;

  /// Tool-call lifecycle (`pending`/`in_progress`/`completed`/`failed`) —
  /// carried alongside [message] so surfaces can show WHERE a tool is,
  /// not just that it exists.
  final String? toolStatus;

  /// Agent plan entries (`session/update` kind `plan`), replaced wholesale
  /// on every plan update.
  final List<String>? planEntries;
}

/// Completed prompt turn.
final class AcpPromptResult {
  const AcpPromptResult({required this.sessionId, required this.stopReason});

  final String sessionId;
  final String stopReason;
}

/// Creates or attaches an ACP client. Production code uses [AcpClient.spawn].
/// The permission delegate answers agent `session/request_permission` calls
/// (null = the toolkit's safe default: reject); [onStderr] observes the
/// agent's stderr lines (the pipe is drained regardless).
typedef AcpClientFactory =
    Future<AcpClient> Function(
      AcpRuntimeConfig config,
      AcpPermissionDelegate? permissionDelegate, {
      void Function(String line)? onStderr,
    });

Future<AcpClient> spawnAcpClient(
  final AcpRuntimeConfig config,
  final AcpPermissionDelegate? permissionDelegate, {
  final void Function(String line)? onStderr,
}) => AcpClient.spawn(
  config.command,
  config.arguments,
  workingDirectory: config.workingDirectory,
  environment: config.environment,
  permissionHandler: permissionDelegate,
  onStderr: onStderr,
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

/// One `session/request_permission` the agent raised mid-turn. Exactly one
/// answer is honored; a second call is a no-op. Unanswered requests hold the
/// agent's tool call until the user answers or the turn is cancelled.
final class AcpPendingPermission {
  AcpPendingPermission._(this.request);

  final AcpPermissionRequest request;
  final Completer<AcpPermissionOutcome> _completer =
      Completer<AcpPermissionOutcome>();

  bool get isAnswered => _completer.isCompleted;
  Future<AcpPermissionOutcome> get future => _completer.future;

  Future<AcpPermissionOutcome> allow() => _answer(AcpPermissionOutcome.allow);
  Future<AcpPermissionOutcome> reject() => _answer(AcpPermissionOutcome.reject);

  Future<AcpPermissionOutcome> _answer(final AcpPermissionOutcome outcome) {
    if (!_completer.isCompleted) _completer.complete(outcome);
    return _completer.future;
  }
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
  final List<AcpPendingPermission> _pendingPermissions = [];
  final _permissionController =
      StreamController<AcpPendingPermission>.broadcast();

  /// Every `session/request_permission` the agent raises mid-turn, as an
  /// awaitable pending request. UI surfaces render these in-flow and answer
  /// via [AcpPendingPermission.allow] / [AcpPendingPermission.reject].
  Stream<AcpPendingPermission> get permissionRequests =>
      _permissionController.stream;

  /// Currently unanswered requests (late subscribers read this snapshot
  /// instead of replaying the broadcast stream).
  List<AcpPendingPermission> get pendingPermissions =>
      List.unmodifiable(_pendingPermissions);

  AcpRuntimeStatus get status => _status;
  Object? get error => _error;
  bool get isReady => _status == AcpRuntimeStatus.ready;
  Map<String, AcpAgentSession> get sessions => Map.unmodifiable(_sessions);
  String? get currentSessionId => _currentSessionId;

  /// Starts and initializes the agent once. [onStderr] observes the
  /// agent's stderr lines (diagnostics only — the client drains the pipe
  /// regardless so a chatty agent cannot block on a full buffer).
  Future<void> start(
    final AcpRuntimeConfig config, {
    final void Function(String line)? onStderr,
  }) {
    if (_status == AcpRuntimeStatus.ready ||
        _status == AcpRuntimeStatus.starting) {
      return Future.value();
    }
    if (_client != null) {
      throw StateError('A previous ACP client must be stopped before start');
    }
    _error = null;
    _status = AcpRuntimeStatus.starting;
    final future = _start(config, onStderr);
    _starting = future;
    return future;
  }

  Future<void> _start(
    final AcpRuntimeConfig config, [
    final void Function(String line)? onStderr,
  ]) async {
    try {
      final client = await clientFactory(
        config,
        _handlePermission,
        onStderr: onStderr,
      );
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

  Future<AcpPermissionOutcome> _handlePermission(
    final AcpPermissionRequest request,
  ) {
    final pending = AcpPendingPermission._(request);
    _pendingPermissions.add(pending);
    _permissionController.add(pending);
    return pending.future.whenComplete(() {
      _pendingPermissions.remove(pending);
    });
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

  /// Resumes a PREVIOUS conversation (`session/load`): the agent replays
  /// its history and the session becomes this runtime's current —
  /// [send] continues the same conversation. This is the multiplayer
  /// handoff path (the session id lives on the shared chat doc) and the
  /// process-restart recovery path. Throws [AcpRemoteError] (typically
  /// -32601 for agents without the method) — callers fall back to
  /// [newSession] with their own context-reset marker.
  Future<String> resume(
    final String sessionId, {
    required final String workingDirectory,
  }) async {
    final client = await _requireClient();
    final confirmed = await client.loadSession(
      sessionId,
      cwd: workingDirectory,
    );
    final session = AcpAgentSession(
      id: confirmed,
      workingDirectory: workingDirectory,
    );
    _sessions[confirmed] = session;
    _currentSessionId = confirmed;
    return confirmed;
  }

  /// The mode set the agent advertised for [sessionId] (null when the
  /// agent does not implement session modes — the client-side permission
  /// policy still applies).
  AcpSessionModes? sessionModesOf(final String sessionId) =>
      _client?.sessionModesOf(sessionId);

  /// Switches the agent's OWN mode (`session/set_mode`) — the agent side
  /// of the codex/zed/cursor-style switcher. Client-side policy stays
  /// the enforcement layer regardless.
  Future<void> setMode(final String sessionId, final String modeId) async {
    final client = await _requireClient();
    await client.setSessionMode(sessionId, modeId);
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
              AcpPromptUpdate(
                message: update.title ?? update.toolCallId,
                toolStatus: update.status,
              ),
            );
          } else if (update is Plan) {
            controller.add(
              AcpPromptUpdate(
                planEntries: [
                  for (final entry in update.entries) entry.content,
                ],
              ),
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

  /// Answers the agent's `auth_required` over ACP (session/authenticate)
  /// with the chosen [methodId] — for agents that complete OAuth in
  /// protocol (Gemini CLI). Terminal-auth agents need their own login
  /// first; the chat surface then names the fix from the catalog hint.
  Future<void> authenticate(final String methodId) async {
    final client = await _requireClient();
    await client.authenticate(methodId);
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
