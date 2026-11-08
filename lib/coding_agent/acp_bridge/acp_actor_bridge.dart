/// Item 2e — the ACP external-actor bridge v1: ONE bridged agent as an
/// ORDINARY ACTOR in ONE room.
///
/// The bridge is the actor's app-hosted loop (the seat word is honest:
/// LA hosts this loop; the brainRef `acp:<agentId>` resolves to no
/// in-app brain and binds no daemon cast, so neither the bot host nor
/// the daemon claims the actor — the bridge is its ONLY voice).
///
/// Laws:
/// - Cursor law: the beat cursor seeds at the newest beat at bind time
///   — history is not work. A beat prompts the agent ONLY when it is
///   addressed to the bridge actor, authored by someone else, and its
///   beat number is past the cursor. Unaddressed beats and the bridge's
///   own beats never prompt.
/// - One turn, one beat: the prompt turn's text deltas are aggregated
///   into ONE said beat under the actor's own journal identity
///   (`world.sessionFor(actorId).say`), addressed back to the asking
///   author. Tool statuses ride as compact trailing journal lines
///   (`· tool: <name> <status>`) — the agent's own facts, never
///   invention. An empty turn says nothing (never an empty beat).
/// - Reject-first permissions: an agent `session/request_permission`
///   becomes an [InboxPermission] row in [AcpBridgeRegistry] with the
///   bridge actor's attribution, so the room's 0c interrupt card
///   renders it unchanged; the answer wires to the transport's
///   exactly-once request and REMOVES the row. A stopping bridge
///   rejects its still-open requests (an unanswered request must never
///   outlive the loop that owns it).
/// - One runtime per bridge: the transport starts lazily on the first
///   prompt turn and is reused; a failed start is named in the room as
///   the actor's own error line and retried on the next addressed beat.
/// - v1 runway (named, not silent): the cursor lives in memory only —
///   an app restart re-binds at the newest beat and does not replay
///   addressed beats said while the bridge was down; prompt turns are
///   serialized per bridge (no concurrent turns); plan entries stream
///   but are not journaled.
library;

import 'dart:async';

import 'package:lastanswer/coding_agent/acp_bridge/acp_bridge_registry.dart';
import 'package:lastanswer/coding_agent/acp_bridge/acp_bridge_transport.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';

/// The bridge's lifecycle word (observability rows read it; the runtime
/// underneath keeps its own status — this is the BRIDGE's seat).
enum AcpBridgeStatus { idle, starting, ready, error, stopped }

/// One actor ⇄ one thread ⇄ one ACP transport binding.
final class AcpActorBridge {
  AcpActorBridge({
    required this.actorId,
    required this.agentId,
    required this.threadId,
    required this.transport,
    required this.workingDirectory,
  });

  /// The bridged actor's durable world identity (the roster row created
  /// by the flow; beats are said under it).
  final String actorId;

  /// The catalog agent id (`codex`, `claude-code-acp`, `pi`, `local:…`)
  /// — the brainRef's second half.
  final String agentId;

  /// The ONE room this bridge is bound to (the DM the flow opened).
  final String threadId;

  final AcpBridgeTransport transport;

  /// The ACP session's cwd (the workspace folder the flow resolved).
  final String workingDirectory;

  /// The actor's brain binding vocabulary: `acp:<agentId>` — neither a
  /// daemon `cast:` nor an in-app brain (the defer law stays honest).
  String get brainRef => 'acp:$agentId';

  AcpBridgeStatus _status = AcpBridgeStatus.idle;
  String? _lastError;
  int _cursor = 0;
  bool _cursorSeeded = false;
  bool _running = false;
  bool _sessionReady = false;
  bool _scanning = false;
  bool _rescan = false;
  int _permissionSeq = 0;
  RealmChatService? _service;
  StreamSubscription<AcpBridgePermissionRequest>? _permissionSub;
  final List<String> _openPermissionIds = <String>[];

  /// The bridge's lifecycle word.
  AcpBridgeStatus get status => _status;

  /// The last named failure (null = none) — never a silent lie.
  String? get lastError => _lastError;

  /// Whether the loop is live (start → stop).
  bool get isRunning => _running;

  /// The beat cursor (the newest beat this bridge has judged).
  int get cursor => _cursor;

  /// Whether the bind-time cursor seed landed (the cursor law's
  /// observable half: until the seed ran, nothing is judged).
  bool get cursorSeeded => _cursorSeeded;

  /// Binds the loop to [service]: listens for journal activity, seeds
  /// the cursor at the thread's newest beat, and starts answering
  /// addressed beats. Idempotent while running.
  void start(final RealmChatService service) {
    if (_running) return;
    _running = true;
    _service = service;
    service.addListener(_onServiceChanged);
    _permissionSub = transport.permissionRequests.listen(
      _onPermissionRequest,
      onError: _onPermissionStreamError,
    );
    unawaited(_bootstrap());
  }

  /// Tears the loop down: ignores later beats, rejects + removes open
  /// permission rows, stops the transport, leaves the registry.
  Future<void> stop() async {
    if (!_running && _service == null && _status == AcpBridgeStatus.stopped) {
      return;
    }
    _running = false;
    _service?.removeListener(_onServiceChanged);
    _service = null;
    await _permissionSub?.cancel();
    _permissionSub = null;
    // Reject-first teardown: an open request never outlives its loop.
    final openRows = <InboxPermission>[
      for (final row in AcpBridgeRegistry.permissions.value)
        if (row.actorId == actorId) row,
    ];
    for (final row in openRows) {
      try {
        await row.answer(false);
      } on Object catch (error) {
        _lastError = '$error';
      }
    }
    for (final sessionId in List<String>.of(_openPermissionIds)) {
      AcpBridgeRegistry.removePermission(sessionId);
    }
    _openPermissionIds.clear();
    AcpBridgeRegistry.unregister(this);
    try {
      await transport.stop();
    } on Object catch (error) {
      _lastError = '$error';
    }
    _status = AcpBridgeStatus.stopped;
  }

  void _onServiceChanged() {
    if (!_running) return;
    unawaited(_scan());
  }

  /// Defensive: the transport's permission lane never errors in v1, but
  /// an async error on it must land as a named fact, never an unhandled
  /// zone crash.
  void _onPermissionStreamError(final Object error) {
    _lastError = '$error';
  }

  Future<void> _bootstrap() async {
    // The first scan seeds the cursor (history is not work); nothing
    // prompts until the seed lands.
    await _scan();
  }

  /// The serialized scan loop: one pass at a time; a notify during a
  /// pass marks it dirty and re-runs (beats are never dropped, never
  /// double-judged).
  Future<void> _scan() async {
    if (_scanning) {
      _rescan = true;
      return;
    }
    _scanning = true;
    try {
      do {
        _rescan = false;
        await _scanOnce();
      } while (_rescan && _running);
    } finally {
      _scanning = false;
    }
  }

  Future<void> _scanOnce() async {
    final service = _service;
    if (service == null || !_running) return;
    final beats = await service.beatsFor(threadId);
    if (!_running) return;
    if (!_cursorSeeded) {
      // Cursor law: seed at the newest beat at bind time. The seed pass
      // judges nothing — a room's history is not a work queue.
      for (final beat in beats) {
        final number = beat['beat'];
        if (number is int && number > _cursor) _cursor = number;
      }
      _cursorSeeded = true;
      return;
    }
    for (final beat in beats) {
      if (!_running) return;
      final number = beat['beat'];
      if (number is! int || number <= _cursor) continue;
      _cursor = number;
      final author = '${beat['author'] ?? ''}';
      if (author.isEmpty || author == actorId) continue; // own beat
      final addressed = (beat['addressedTo'] as List? ?? const <Object?>[])
          .cast<String>();
      if (!addressed.contains(actorId)) continue; // not for me
      final text = '${beat['text'] ?? ''}'.trim();
      if (text.isEmpty) continue; // nothing to carry
      await _runTurn(text, author);
    }
  }

  /// One prompt turn: send the beat text, aggregate the deltas, and say
  /// ONE attributed beat back (tool statuses as compact trailing lines).
  Future<void> _runTurn(final String prompt, final String author) async {
    try {
      await _ensureSession();
      final text = StringBuffer();
      final toolLines = <String>[];
      await for (final update in transport.send(prompt)) {
        if (!_running) break;
        final delta = update.textDelta;
        if (delta != null && delta.isNotEmpty) text.write(delta);
        final message = update.message;
        if (message != null && message.isNotEmpty) {
          final status = update.toolStatus ?? '';
          toolLines.add(
            status.isEmpty ? '· tool: $message' : '· tool: $message $status',
          );
        }
        // planEntries: streamed but not journaled in v1 (named runway).
      }
      final composed = <String>[
        if (text.toString().trim().isNotEmpty) text.toString().trim(),
        ...toolLines,
      ];
      if (composed.isEmpty) return; // an empty turn says nothing
      await _say(composed.join('\n'), author);
    } on Object catch (error) {
      _lastError = '$error';
      if (_status == AcpBridgeStatus.starting) _status = AcpBridgeStatus.error;
      if (!_running) return;
      // Honest attributed failure — the room sees the named error, never
      // silence after being addressed.
      await _say('· acp bridge error: $error', author);
    }
  }

  /// Lazy one-runtime-per-bridge session: start + newSession run once;
  /// a failed start retries on the next addressed beat (the error is
  /// named, never swallowed).
  Future<void> _ensureSession() async {
    if (_sessionReady) return;
    _status = AcpBridgeStatus.starting;
    await transport.start();
    await transport.newSession(workingDirectory);
    _sessionReady = true;
    _status = AcpBridgeStatus.ready;
  }

  Future<void> _say(final String text, final String author) async {
    final world = _service?.world;
    if (world == null) return; // no world: nothing said, nothing faked
    await world
        .sessionFor(actorId)
        .say(threadId, text, addressedTo: <String>[author]);
  }

  void _onPermissionRequest(final AcpBridgePermissionRequest request) {
    if (!_running) {
      // A stopped bridge rejects (reject-first law; the row would have
      // no owner).
      unawaited(request.answer(allow: false));
      return;
    }
    final sessionId = 'acp-$actorId-${++_permissionSeq}';
    _openPermissionIds.add(sessionId);
    final title = request.title.trim();
    AcpBridgeRegistry.addPermission(
      InboxPermission(
        sessionId: sessionId,
        // The agent's own request words; the kind is the fallback fact
        // when the agent sent no title (never an invented one).
        title: title.isNotEmpty ? title : 'acp: ${request.kind ?? 'request'}',
        kind: request.kind,
        since: DateTime.now().toUtc().toIso8601String(),
        actorId: actorId,
        diff: request.details,
        answer: (final allow) async {
          AcpBridgeRegistry.removePermission(sessionId);
          _openPermissionIds.remove(sessionId);
          await request.answer(allow: allow);
        },
      ),
    );
  }
}
