/// LaWorld (1a) — Last Answer's ONE in-process ecsly World: the
/// reactive read model over the realm journal.
///
/// The projection law (ADR 0138 D1): the journal is the authority; this
/// World is a projection, fed by cursor deltas ([LaWorldFeed]), never
/// written back. It replaces the polling read model surface-by-surface:
/// rows arrive as component mutations, one `commitBatch` flushes the
/// command queue and notifies through the [EcsController], and
/// `EcsWorldSelector` rebuilds ONLY the widgets whose selection
/// actually changed (record snapshots + elementwise equality).
///
/// The creature layer (3d) grows on the same entities: Species/Mood/
/// Blink components attach to [ActorRow] entities and fixed-step
/// systems animate them — one world, two read disciplines (UI
/// selectors, simulation systems).
library;

import 'package:ecsly_flutter/ecsly_flutter.dart';
import 'package:lastanswer/la_world/la_world_components.dart';

/// The reactive projection world. Owns the ecsly [World], its Flutter
/// binding ([EcsController]) and the row indexes (component-object
/// refs keyed by journal identity — the World is the store, the index
/// is the read path).
final class LaWorld {
  LaWorld({required this.humanActorId}) {
    world.components
      ..registerObjectComponent<RoomRow>()
      ..registerObjectComponent<TaskRow>()
      ..registerObjectComponent<TelemetryRow>()
      ..registerObjectComponent<ActorRow>();
  }

  final World world = World();
  late final EcsController controller = EcsController(world: world);

  /// The signed-in human — unread counts are a MEMBER's fact (the
  /// Discord law): a room the human is not a participant of never
  /// badges, whatever its lastBeat says. A getter because the service
  /// resolves the stable identity asynchronously.
  final String Function() humanActorId;

  int _unreadOf(final RoomRow room) =>
      room.participants.contains(humanActorId()) ? room.unread : 0;

  /// Journal identity → entity/row indexes (`<collection>/<key>`).
  final Map<String, Entity> _entities = {};
  final Map<String, RoomRow> _rooms = {};
  final Map<String, TaskRow> _tasks = {};
  final Map<String, TelemetryRow> _telemetry = {};
  final Map<String, ActorRow> _actors = {};

  /// Monotonic batch counter — the coarse "did anything change" fact
  /// for tests and diagnostics (selector equality stays per-snapshot).
  int get batchRevision => _batchRevision;
  int _batchRevision = 0;

  // ---- the feed's write surface (projection-internal) ----

  /// Upserts one room row (a `threads` put).
  void putRoom(final RoomRow row) {
    final existing = _rooms[row.threadId];
    if (existing != null) {
      existing
        ..topic = row.topic
        ..closed = row.closed
        ..participants = row.participants
        ..lastBeat = row.lastBeat
        ..createdAt = row.createdAt
        ..lastBeatAt = row.lastBeatAt
        ..lastBeatAuthor = row.lastBeatAuthor
        ..lastBeatText = row.lastBeatText
        ..realmSealed = row.realmSealed;
      return;
    }
    final entity = world.spawnComponents([row]);
    _entities['threads/${row.threadId}'] = entity;
    _rooms[row.threadId] = row;
  }

  /// Applies the human's read receipt for one room (`thread_reads`).
  void putRoomReceipt(final String threadId, final int lastReadBeat) {
    final room = _rooms[threadId];
    if (room == null) return;
    if (lastReadBeat > room.lastReadBeat) room.lastReadBeat = lastReadBeat;
  }

  /// Upserts one task row (a `durable_tasks` put).
  void putTask(final TaskRow row) {
    final existing = _tasks[row.taskId];
    if (existing != null) {
      existing
        ..state = row.state
        ..sentence = row.sentence
        ..modelId = row.modelId
        ..addressees = row.addressees
        ..terminal = row.terminal
        ..summary = row.summary
        ..at = row.at;
      return;
    }
    final entity = world.spawnComponents([row]);
    _entities['durable_tasks/${row.taskId}'] = entity;
    _tasks[row.taskId] = row;
  }

  /// Keeps the NEWEST telemetry row per actor (the journal keeps them
  /// all; the projection is the per-actor latest — the Models view's
  /// law, now reactive).
  void putTelemetry(final TelemetryRow row) {
    final existing = _telemetry[row.actorId];
    if (existing != null) {
      final prior = existing.telemetry.at ?? '';
      final next = row.telemetry.at ?? '';
      if (next.compareTo(prior) < 0) return;
      existing.telemetry = row.telemetry;
      return;
    }
    final entity = world.spawnComponents([row]);
    _entities['tool_loop_telemetry/${row.actorId}'] = entity;
    _telemetry[row.actorId] = row;
  }

  /// Upserts one actor row (a `realm_actors` put).
  void putActor(final ActorRow row) {
    final existing = _actors[row.actorId];
    if (existing != null) {
      existing
        ..displayName = row.displayName
        ..actorKind = row.actorKind
        ..brainRef = row.brainRef
        ..brainCast = row.brainCast
        ..role = row.role
        ..serves = row.serves;
      return;
    }
    final entity = world.spawnComponents([row]);
    _entities['realm_actors/${row.actorId}'] = entity;
    _actors[row.actorId] = row;
  }

  /// Removes one row (a journal remove — compaction or deletion).
  void removeRow(final String collection, final String key) {
    final id = '$collection/$key';
    final entity = _entities.remove(id);
    switch (collection) {
      case 'threads':
        _rooms.remove(key);
      case 'durable_tasks':
        _tasks.remove(key);
      case 'tool_loop_telemetry':
        // Telemetry indexes by ACTOR, not by row key (tl-<micros>);
        // a remove of one historical row never drops the latest.
        break;
      case 'realm_actors':
        _actors.remove(key);
    }
    if (entity != null) world.despawnEntity(entity);
  }

  /// Ends one drained batch: flushes the command queue (spawns and
  /// despawns land) and notifies the selectors. Called by the feed —
  /// never per row.
  void commitBatch() {
    _batchRevision++;
    controller.notifyWorldChanged();
  }

  // ---- the UI's read surface (selector snapshots) ----

  /// Every room, most recent activity first (the rail/list law).
  List<RoomSnapshot> roomSnapshots() {
    final rooms = _rooms.values.toList()
      ..sort((a, b) {
        final left = a.lastBeatAt ?? a.createdAt;
        final right = b.lastBeatAt ?? b.createdAt;
        return right.compareTo(left);
      });
    return [
      for (final room in rooms)
        (
          threadId: room.threadId,
          topic: room.topic,
          closed: room.closed,
          lastBeat: room.lastBeat,
          unread: _unreadOf(room),
          participants: room.participants.length,
          realmSealed: room.realmSealed,
          activity: room.lastBeatAt ?? room.createdAt,
        ),
    ];
  }

  /// threadId → unread count (the rail badge's whole need).
  Map<String, int> unreadByThread() => <String, int>{
    for (final room in _rooms.values)
      if (_unreadOf(room) > 0) room.threadId: _unreadOf(room),
  };

  /// ONE room's human receipt fact (the 1g "N new" divider's need):
  /// the member-gated unread plus the raw last-read beat — the divider
  /// captures these at room entry, because reading IS the receipt
  /// (ADR 0124) and the projection advances the moment the tail loads.
  /// Null when the projection does not know the room (honest absence).
  ({int lastReadBeat, int unread})? roomReceipt(final String threadId) {
    final room = _rooms[threadId];
    if (room == null) return null;
    return (lastReadBeat: room.lastReadBeat, unread: _unreadOf(room));
  }

  /// Every task, running first then most recent (the inbox law).
  List<TaskSnapshot> taskSnapshots() {
    final tasks = _tasks.values.toList()
      ..sort((a, b) {
        if (a.terminal != b.terminal) return a.terminal ? 1 : -1;
        return (b.at ?? '').compareTo(a.at ?? '');
      });
    return [
      for (final task in tasks)
        (
          taskId: task.taskId,
          state: task.state,
          sentence: task.sentence,
          modelId: task.modelId ?? '',
          addressees: task.addressees.join(','),
          terminal: task.terminal,
          summary: task.summary ?? '',
          at: task.at ?? '',
        ),
    ];
  }

  /// The newest telemetry per actor.
  Map<String, TelemetryRow> telemetryByActor() =>
      Map<String, TelemetryRow>.unmodifiable(_telemetry);

  /// Every registered actor.
  List<ActorSnapshot> actorSnapshots() => [
    for (final actor in _actors.values)
      (
        actorId: actor.actorId,
        displayName: actor.displayName,
        actorKind: actor.actorKind,
        brainRef: actor.brainRef,
        brainCast: actor.brainCast,
        role: actor.role,
      ),
  ];

  /// Releases the world and controller (app teardown / hermetic tests).
  void dispose() {
    controller.dispose();
  }
}
