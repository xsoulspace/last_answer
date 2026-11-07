/// LaWorldFeed (1a) — the cursor fold that keeps [LaWorld] honest:
/// cold start scans the five UI collections to current state (the
/// TailFold pattern's `foldAll` leg), then every journal append rides
/// `changesSince(cursor)` deltas on the store's watch (the daemon
/// dispatcher's own pattern — the watch event is a HINT, the cursor
/// re-read is the truth). One drained batch = one [LaWorld.commitBatch]
/// = one flush + one selector notification.
///
/// The projection law (ADR 0138 D1): reads only — the feed NEVER
/// writes the journal. A replaced journal generation (`offsetInvalid`)
/// clears the world and refolds from zero — rebuild-on-shrink, never
/// partial trust (the TailFold coherence law).
library;

import 'dart:async';

import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart'
    show ActorTelemetry;
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/la_world/la_world_components.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// The journal collections LaWorld folds. Anything else in the journal
/// is ignored, exactly as the harness projection's closed switch does.
const laWorldCollections = <String>{
  'threads',
  'thread_reads',
  'durable_tasks',
  'tool_loop_telemetry',
  'realm_actors',
};

/// The cursor-fed fold from the realm journal into [LaWorld].
final class LaWorldFeed {
  LaWorldFeed({
    required this.store,
    required this.laWorld,
    required this.humanActorId,
  });

  final RealmControlStore store;
  final LaWorld laWorld;

  /// The signed-in human — the read receipts of anyone else are not
  /// this UI's unread counts. A getter because the service resolves
  /// the stable identity asynchronously.
  final String Function() humanActorId;

  int _cursor = 0;
  bool _draining = false;
  bool _rerun = false;
  bool _stopped = false;
  StreamSubscription<void>? _watchSub;

  /// Diagnostics: cold folds and delta batches applied.
  int coldFolds = 0;
  int batches = 0;

  /// Cold start (full scans + cursor at the journal end), then rides
  /// the store's watch. Idempotent-ish: a second start is a no-op
  /// while running.
  Future<void> start({
    Duration pollInterval = const Duration(milliseconds: 400),
  }) async {
    if (_watchSub != null) return;
    await _coldFold();
    if (_stopped) return;
    _watchSub = store.watch(pollInterval: pollInterval).listen(
      (_) => unawaited(drain()),
      onError: (Object e) {
        // The watch is a hint; a failed poll never loses data — the
        // next event (or a manual drain) re-reads the exact tail.
      },
    );
    // Drain whatever landed between the cold fold and the listen.
    unawaited(drain());
  }

  void stop() {
    _stopped = true;
    unawaited(_watchSub?.cancel() ?? Future<void>.value());
    _watchSub = null;
  }

  Future<void> _coldFold() async {
    final threads = await store.scan('threads');
    final reads = await store.scan('thread_reads');
    final tasks = await store.scan('durable_tasks');
    final telemetry = await store.scan('tool_loop_telemetry');
    final actors = await store.scan('realm_actors');
    for (final row in threads.values) {
      final room = roomRowOf(row);
      if (room != null) laWorld.putRoom(room);
    }
    reads.values.forEach(_applyReceipt);
    for (final entry in tasks.entries) {
      final task = taskRowOf(entry.key, row: entry.value);
      if (task != null) laWorld.putTask(task);
    }
    for (final row in telemetry.values) {
      final parsed = telemetryRowOf(row);
      if (parsed != null) laWorld.putTelemetry(parsed);
    }
    for (final row in actors.values) {
      final actor = actorRowOf(row);
      if (actor != null) laWorld.putActor(actor);
    }
    _cursor = store.journalLength();
    coldFolds++;
    laWorld.commitBatch();
  }

  /// One drain-to-empty pass with a re-entrance guard (an append that
  /// lands mid-drain sets [_rerun]; the pass repeats — correctness
  /// never relies on the watch hint).
  Future<void> drain() async {
    if (_draining || _stopped) {
      _rerun = true;
      return;
    }
    _draining = true;
    try {
      do {
        _rerun = false;
        while (!_stopped) {
          final RealmControlChanges changes;
          try {
            changes = await store.changesSince(_cursor);
          } on RealmControlStoreException catch (error) {
            if (error.code != RealmControlStoreCode.offsetInvalid) rethrow;
            // A replaced generation: clear and refold from zero (the
            // TailFold rebuild-on-shrink law — never partial trust).
            await _refoldFromScratch();
            break;
          }
          if (changes.isEmpty) break;
          var applied = 0;
          for (final record in changes.records) {
            for (final mutation in record.mutations) {
              if (!laWorldCollections.contains(mutation.collection)) {
                continue;
              }
              if (mutation.isRemove) {
                laWorld.removeRow(mutation.collection, mutation.key);
              } else if (mutation.value != null) {
                _applyPut(
                  mutation.collection,
                  mutation.key,
                  mutation.value!,
                );
              }
              applied++;
            }
          }
          _cursor = changes.newByteOffset;
          if (applied > 0) {
            batches++;
            laWorld.commitBatch();
          }
        }
      } while (_rerun && !_stopped);
    } finally {
      _draining = false;
    }
  }

  Future<void> _refoldFromScratch() async {
    // Clearing the world: despawn every indexed entity, drop indexes,
    // then cold-fold again (cursor reset happens inside).
    for (final entry in laWorld.roomSnapshots()) {
      laWorld.removeRow('threads', entry.threadId);
    }
    for (final entry in laWorld.taskSnapshots()) {
      laWorld.removeRow('durable_tasks', entry.taskId);
    }
    for (final entry in laWorld.actorSnapshots()) {
      laWorld.removeRow('realm_actors', entry.actorId);
    }
    _cursor = 0;
    await _coldFold();
  }

  void _applyPut(
    final String collection,
    final String key,
    final Map<String, Object?> value,
  ) {
    switch (collection) {
      case 'threads':
        final room = roomRowOf(value);
        if (room != null) laWorld.putRoom(room);
      case 'thread_reads':
        _applyReceipt(value);
      case 'durable_tasks':
        final task = taskRowOf(key, row: value);
        if (task != null) laWorld.putTask(task);
      case 'tool_loop_telemetry':
        final parsed = telemetryRowOf(value);
        if (parsed != null) laWorld.putTelemetry(parsed);
      case 'realm_actors':
        final actor = actorRowOf(value);
        if (actor != null) laWorld.putActor(actor);
    }
  }

  void _applyReceipt(final Map<String, Object?> row) {
    if ('${row['actorId'] ?? ''}' != humanActorId()) return;
    final threadId = '${row['threadId'] ?? ''}';
    if (threadId.isEmpty) return;
    final beat = row['lastReadBeat'];
    if (beat is! int) return;
    laWorld.putRoomReceipt(threadId, beat);
  }

  // ---- row parsers (the journal shape is the contract) ----

  static RoomRow? roomRowOf(final Map<String, Object?> row) {
    final threadId = '${row['threadId'] ?? ''}';
    if (threadId.isEmpty) return null;
    return RoomRow(
      threadId: threadId,
      topic: '${row['topic'] ?? ''}',
      closed: row['closed'] == true,
      participants:
          (row['participants'] as List? ?? const <Object?>[])
              .cast<String>()
              .toList(),
      lastBeat: (row['lastBeat'] as num?)?.toInt() ?? 0,
      createdAt: '${row['createdAt'] ?? ''}',
      lastBeatAt: row['lastBeatAt'] as String?,
      lastBeatAuthor: row['lastBeatAuthor'] as String?,
      lastBeatText: row['lastBeatText'] as String?,
      realmSealed: row['projectId'] == null,
    );
  }

  static TaskRow? taskRowOf(
    final String key, {
    required final Map<String, Object?> row,
  }) {
    final state = '${row['state'] ?? ''}';
    if (state.isEmpty) return null;
    final payload = row['payload'] is Map
        ? Map<String, Object?>.from(row['payload']! as Map)
        : const <String, Object?>{};
    final terminal = row['terminal'];
    final terminalMap = terminal is Map
        ? Map<String, Object?>.from(terminal)
        : const <String, Object?>{};
    final result = terminalMap['result'];
    final resultMap = result is Map
        ? Map<String, Object?>.from(result)
        : const <String, Object?>{};
    return TaskRow(
      taskId: '${row['taskId'] ?? key}',
      state: state,
      sentence: '${payload['prompt'] ?? ''}',
      modelId:
          (row['model'] as String?) ?? (payload['declaredModelId'] as String?),
      addressees:
          (payload['addressees'] as List? ?? const <Object?>[])
              .cast<String>()
              .toList(),
      terminal: terminalMap.isNotEmpty,
      summary:
          (resultMap['summary'] as String?) ??
          (terminalMap['reason'] as String?),
      at:
          (row['settledAt'] as String?) ??
          (row['startedAt'] as String?) ??
          (row['admittedAt'] as String?),
    );
  }

  static TelemetryRow? telemetryRowOf(final Map<String, Object?> row) {
    final actorId = '${row['actorId'] ?? ''}';
    if (actorId.isEmpty) return null;
    return TelemetryRow(
      actorId: actorId,
      telemetry: ActorTelemetry(
        actorId: actorId,
        rounds: (row['rounds'] as num?)?.toInt() ?? 0,
        promptTokens: (row['promptTokens'] as num?)?.toInt() ?? 0,
        cachedTokens: (row['cachedTokens'] as num?)?.toInt() ?? 0,
        toolCalls: (row['toolCalls'] as num?)?.toInt() ?? 0,
        completionTokens: (row['completionTokens'] as num?)?.toInt() ?? 0,
        promptChars: (row['promptChars'] as num?)?.toInt() ?? 0,
        appliedWrites: (row['appliedWrites'] as num?)?.toInt() ?? 0,
        stalled: row['stalled'] == true,
        at: row['at'] as String?,
      ),
    );
  }

  static ActorRow? actorRowOf(final Map<String, Object?> row) {
    final actorId = '${row['actorId'] ?? ''}';
    if (actorId.isEmpty) return null;
    return ActorRow(
      actorId: actorId,
      displayName: '${row['displayName'] ?? ''}',
      actorKind: '${row['actorKind'] ?? ''}',
      brainRef: '${row['brainRef'] ?? ''}',
      brainCast: '${row['brainCast'] ?? ''}',
      role: '${row['role'] ?? ''}',
      serves:
          (row['serves'] as List? ?? const <Object?>[]).cast<String>().toList(),
    );
  }
}
