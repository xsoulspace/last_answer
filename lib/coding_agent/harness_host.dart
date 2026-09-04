import 'dart:async';
import 'dart:convert';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_inference_apple_foundation/xsoulspace_inference_apple_foundation.dart';

/// TASK B (ADR 0015) — last_answer embeds the harness as its first domain
/// host. This module owns the daemon lifecycle IN-PROCESS:
///
/// - the daemon is a real [AcpStdioServer] running [HarnessAcpBackend] over
///   an IN-MEMORY duplex channel (no stdio, no subprocess) — the same wire
///   protocol any external ACP client (Zed, pi) would speak;
/// - per-session worlds and per-workspace snapshot stores
///   (`<cwd>/.dart_tool/harnessd_store`) are owned by the backend — the
///   host never touches them (the snapshot persists beats/verdicts/budgets
///   only; the meaning tree re-derives, ADR 0023 §2);
/// - multiplayer-ready by construction (ADR 0015): the user's task input is
///   a HOST-INJECTED DECISION (`session/prompt`), and their write approvals
///   ride the EXISTING `session/request_permission` round-trip. No second
///   protocol is invented anywhere.
///
/// The backend is deny-by-default: with no permission delegate attached
/// there is NO approval path (every write is rejected), never an
/// unconditional allow.
final class HarnessHost {
  HarnessHost({required this.config});

  final HarnessHostConfig config;

  AcpClient? _client;
  final _toServer = StreamController<List<int>>();
  final _toClient = StreamController<List<int>>();
  final _permissionController = StreamController<PendingPermission>.broadcast();
  Completer<PendingPermission>? _permissionSeen;

  /// Whether the in-process daemon is running and initialized.
  bool get isRunning => _client != null && !_client!.isClosed;

  /// Every `session/request_permission` the daemon raises mid-turn (the
  /// write gate / edit approver). The UI (or the user-as-actor) answers via
  /// [PendingPermission.allow] / [PendingPermission.reject].
  Stream<PendingPermission> get permissionRequests =>
      _permissionController.stream;

  /// Starts the daemon + client handshake. Idempotent.
  Future<void> start() async {
    if (isRunning) return;
    final backend = config.buildBackend();
    final server = AcpStdioServer(
      backend: backend,
      inputStream: _toServer.stream,
      outputSink: _ChannelSink(_toClient),
    );
    // The server loop reads the in-memory stream until the host stops.
    unawaited(server.run());
    final client = AcpClient(
      agentOutput: _toClient.stream,
      agentInput: _ChannelSink(_toServer),
      permissionHandler: _handlePermission,
    );
    _client = client;
    await client.initialize();
  }

  /// Creates a session for [cwd] (the delegated workspace). Sessions are
  /// keyed per workspace by the backend: a second `session/new` for the
  /// same cwd CONTINUES the live world (and restores it from the snapshot
  /// store after a host restart).
  Future<String> newSession(final String cwd) =>
      _requireClient().newSession(cwd: cwd);

  /// Runs one prompt turn — the user's task sentence as a host-injected
  /// decision. Progress streams to [onText] (agent text chunks, including
  /// the final `verdict:` line) and [onToolCall] (tool titles).
  Future<AcpStopReason> delegateTask(
    final String sessionId,
    final String task, {
    final void Function(String delta)? onText,
    final void Function(String title)? onToolCall,
  }) async {
    final client = _requireClient();
    final result = await client.promptText(
      sessionId,
      task,
      onUpdate: (final update) => switch (update) {
        AgentMessageChunk() => _onChunk(update, onText),
        ToolCallUpdate() => onToolCall?.call(update.title ?? 'tool'),
        _ => null,
      },
    );
    return result.stopReason;
  }

  void _onChunk(
    final AgentMessageChunk update,
    final void Function(String delta)? onText,
  ) {
    final content = update.content;
    if (content is AcpTextBlock && content.text.isNotEmpty) {
      onText?.call(content.text);
    }
  }

  /// Cancels in-flight work for a session (real: aborts generation).
  void cancel(final String sessionId) => _client?.cancel(sessionId);

  /// Stops the daemon (closes both channel ends) and the client.
  Future<void> stop() async {
    final client = _client;
    _client = null;
    await client?.dispose();
    if (!_toServer.isClosed) await _toServer.close();
    if (!_toClient.isClosed) await _toClient.close();
  }

  AcpClient _requireClient() {
    final client = _client;
    if (client == null || client.isClosed) {
      throw StateError('Harness host is not running: call start() first');
    }
    return client;
  }

  /// Test visibility: completes with the NEXT pending permission request
  /// (or the one already waiting).
  Future<PendingPermission> nextPermission({
    final Duration timeout = const Duration(seconds: 60),
  }) {
    final seen = _permissionSeen;
    if (seen != null && seen.isCompleted) return seen.future;
    final completer = Completer<PendingPermission>();
    _permissionSeen = completer;
    return completer.future.timeout(timeout);
  }

  Future<AcpPermissionOutcome> _handlePermission(
    final AcpPermissionRequest request,
  ) {
    final pending = PendingPermission._(request);
    _permissionSeen?.complete(pending);
    _permissionController.add(pending);
    return pending.future;
  }
}

/// A permission request awaiting the user's (or test's) decision. Exactly
/// one answer is honored; a second call is a no-op.
final class PendingPermission {
  PendingPermission._(this.request);

  final AcpPermissionRequest request;
  final Completer<AcpPermissionOutcome> _completer =
      Completer<AcpPermissionOutcome>();

  Future<AcpPermissionOutcome> get future => _completer.future;
  bool get isAnswered => _completer.isCompleted;

  void allow() => _answer(AcpPermissionOutcome.allow);
  void reject() => _answer(AcpPermissionOutcome.reject);

  void _answer(final AcpPermissionOutcome outcome) {
    if (!_completer.isCompleted) _completer.complete(outcome);
  }
}

/// Configuration for the embedded daemon. Production default is AFM-first
/// (local, on-device); tests pass [handlerFactory] — the harness's LLM-free
/// scripted seam — or [scripted]/[meaningProfile] for the deterministic
/// mover modes. No other host surface exists.
final class HarnessHostConfig {
  const HarnessHostConfig({
    this.backend = 'apple_foundation_afm',
    this.model = 'deepseek/deepseek-v4-flash-0731',
    this.meaningProfile = false,
    this.scripted = false,
    this.handlerFactory,
  });

  /// `apple_foundation_afm` (local-first, North Star) or `open_router`.
  final String backend;
  final String model;
  final bool meaningProfile;
  final bool scripted;
  final GenerationHandler Function(ModelRouter router)? handlerFactory;

  HarnessAcpBackend buildBackend() => HarnessAcpBackend(
    backend: backend,
    model: model,
    meaningProfile: meaningProfile,
    scripted: scripted,
    handlerFactory: handlerFactory,
  );
}

/// A [StringSink] adapter that pushes utf8-encoded lines into a
/// [StreamController] — the in-memory stand-in for a subprocess pipe.
final class _ChannelSink implements StringSink {
  _ChannelSink(this._out);

  final StreamController<List<int>> _out;

  @override
  void write(final Object? obj) => _add('$obj');

  @override
  void writeln([final Object? obj = '']) => _add('$obj\n');

  @override
  void writeAll(
    final Iterable<Object?> objects, [
    final String separator = '',
  ]) => _add(objects.join(separator));

  @override
  void writeCharCode(final int charCode) => _add(String.fromCharCode(charCode));

  void _add(final String s) {
    if (!_out.isClosed) _out.add(utf8.encode(s));
  }
}
