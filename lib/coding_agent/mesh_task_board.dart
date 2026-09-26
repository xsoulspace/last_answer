/// The mesh task board: durable agent-task rows riding the mesh exactly
/// like the actor roster (ADR 0007 §1) — kernel ops under a whole-file
/// exchange (`task_boards/<boardId>.json`), never a hand merge.
///
/// One board = ONE [WorldSync] replica (kernel `ConvergenceDoc`, LWW map,
/// ADR 0011) whose doc id is the [MeshTaskBoard.boardId]. Every task field
/// is one keyed register, written through `WorldSync.applyDelta` (one op
/// per field change — a status change writes ONLY the status field):
///
/// - entity key: `task/<docId>/<taskLocalId>`, component `task`;
/// - fields: `title` (task text), `status`
///   (`requested`/`running`/`completed`/`failed`), `origin` (JSON
///   `{peerId, actorId}` of the dispatcher), `createdAt` (epoch ms int),
///   `verdict` (JSON map, written by complete/fail).
///
/// Reads go through `WorldSync.projection.componentValue` (values are
/// JSON-encoded strings — decoded by the projection).
///
/// Task rows are immutable data honestly: replicas converge per FIELD by
/// the kernel's LWW, so a concurrent `completed` and `running` status
/// write lands on the highest HLC everywhere — there is no lifecycle
/// enforcement, only last-writer-wins registers (callers gate).
///
/// Task ids: `<docId>#<taskLocalId>`. `taskLocalId` is HLC-derived from a
/// board-level own-actor clock ([Hlc.tick] per request): unique per board
/// (strictly monotonic, even on a frozen wall clock), unique across boards
/// (the actor id is embedded), deterministic, and monotonic across
/// restarts (persisted under `toJson`'s `issued_clock` key). Doc ids must
/// not contain `#` (task ids split at the LAST `#`).
///
/// HLC receive-watermark floor: `WorldSync` folds ops and adopts
/// snapshots but never ticks on receive (`ConvergenceDoc` has no
/// `lastIssued` passthrough in `applyDelta`, and `adoptSnapshot` does not
/// absorb `snapshot.createdAt`) — unlike `DocReplica`, which maintains a
/// receive watermark via the kernel's `lastIssued` seam. The gap: a local
/// write issued after folding a remote op with an ahead wall clock would
/// carry a LOWER HLC and lose LWW to the causally-older remote write.
/// This board closes the gap itself (the ecsly repo is not patched): it
/// keeps the high-water HLC of everything received (remote ops in
/// [applyRemote], `snapshot.createdAt` in [adoptSnapshot], the restored
/// log) and floors the `now` handed to `applyDelta` strictly above that
/// watermark's wall clock (`Hlc.tick` is monotonic in
/// `max(now, previous)`, so a wall clock strictly above every received
/// op's wall wins regardless of counters). Persisted under
/// `received_clock`.
library;

import 'package:collection/collection.dart';
import 'package:ecsly_world_sync/ecsly_world_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';

/// Immutable read record projected from the board fold.
///
/// A snapshot of one task row's LWW registers at read time — editing a
/// task means issuing new field ops ([MeshTaskBoard.markRunning] and
/// friends), never mutating a record.
@immutable
final class MeshTaskRecord {
  const MeshTaskRecord({
    required this.taskId,
    required this.docId,
    required this.task,
    required this.status,
    required this.createdAt,
    this.originPeerId,
    this.originActorId,
    this.verdict,
  });

  /// Tolerant read: a malformed field reads as its default (DESIGN §6) —
  /// the ops stay on the board for inspection.
  // Static-by-contract (the mesh task board's public API surface); the
  // lint's constructor suggestion would change the agreed shape.
  // ignore: prefer_constructors_over_static_methods
  static MeshTaskRecord fromJson(final Map<String, Object?> json) {
    final taskId = json['taskId'];
    final docId = json['docId'];
    final task = json['task'];
    final status = json['status'];
    final createdAt = json['createdAtMs'];
    final originPeerId = json['originPeerId'];
    final originActorId = json['originActorId'];
    final verdict = json['verdict'];
    return MeshTaskRecord(
      taskId: taskId is String ? taskId : '',
      docId: docId is String ? docId : '',
      task: task is String ? task : '',
      status: status is String ? status : '',
      createdAt: createdAt is int
          ? DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true)
          : DateTime.fromMillisecondsSinceEpoch(0),
      originPeerId: originPeerId is String ? originPeerId : null,
      originActorId: originActorId is String ? originActorId : null,
      verdict: verdict is Map ? Map<String, Object?>.from(verdict) : null,
    );
  }

  /// `<docId>#<taskLocalId>` — unique per board and across boards.
  final String taskId;

  /// Raw agent doc id (no `agent-` prefix).
  final String docId;

  /// Task text.
  final String task;

  /// `requested` | `running` | `completed` | `failed`.
  final String status;

  /// Mesh peer id of the dispatcher; null when the origin register is
  /// missing (older writer).
  final String? originPeerId;
  final String? originActorId;

  final DateTime createdAt;

  /// `{verdict, tokens, decisions, error, ...}` — merged across writers
  /// by the dispatcher's discipline; LWW wins per key.
  final Map<String, Object?>? verdict;

  Map<String, Object?> toJson() => {
    'taskId': taskId,
    'docId': docId,
    'task': task,
    'status': status,
    'originPeerId': originPeerId,
    'originActorId': originActorId,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
    if (verdict != null) 'verdict': verdict,
  };

  @override
  String toString() =>
      'MeshTaskRecord($taskId, $status, ${createdAt.toIso8601String()})';

  /// Value equality — records are immutable data projected from the fold;
  /// two records with identical fields ARE the same row.
  @override
  bool operator ==(final Object other) =>
      other is MeshTaskRecord &&
      other.taskId == taskId &&
      other.docId == docId &&
      other.task == task &&
      other.status == status &&
      other.originPeerId == originPeerId &&
      other.originActorId == originActorId &&
      other.createdAt == createdAt &&
      const MapEquality().equals(other.verdict, verdict);

  @override
  int get hashCode => Object.hash(
    taskId,
    docId,
    task,
    status,
    originPeerId,
    originActorId,
    createdAt,
    const MapEquality().hash(verdict),
  );
}

/// One shared task board over [WorldSync]; see the library doc for the
/// wire format, id discipline, restore semantics, and the HLC floor.
final class MeshTaskBoard {
  /// Creates a board replica owned by [replicaId] (the mesh peer id).
  MeshTaskBoard({
    required final String replicaId,
    final String boardId = defaultBoardId,
    final DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       // The kernel doc id IS the board id: ops and snapshots are
       // docId-scoped by the kernel, so replicas of one board converge and
       // replicas of different boards never mix.
       _sync = WorldSync(actorId: replicaId, docId: boardId);

  /// Restores a board previously written by [toJson] and keeps it
  /// participating (sync seams stay live).
  ///
  /// Restore order — the proven `DocReplica` semantics
  /// (`packages/headless_core/lib/src/doc_replica.dart`):
  ///
  /// 1. `WorldSync.fromJson` restores the kernel doc. VERIFIED against the
  ///    kernel source: `ConvergenceDoc.fromJson` does NOT re-fold the log
  ///    — the folded `state` is restored as-is (authoritative) and the
  ///    `log` is restored purely for delta shipping. So no snapshot/ops
  ///    reordering is needed here.
  /// 2. The `snapshot` entry (when present) is adopted. The kernel adopts
  ///    only snapshots carrying events the restored doc has not seen, so
  ///    for a self-consistent file this merely re-arms the snapshot cache
  ///    (and the HLC floor); for a compacted file the snapshot IS the
  ///    state carrier and this is what recovers the tasks.
  /// 3. Clocks are recomputed raise-only: `issued_clock` (task-id
  ///    monotonicity), `received_clock` (LWW causality floor), every op in
  ///    the restored log, and the adopted snapshot's `createdAt` — a
  ///    restore never lowers a watermark past the file's own content.
  factory MeshTaskBoard.fromJson(final Map<String, Object?> json) {
    final worldJson = json['world'];
    if (worldJson is! Map) {
      throw ArgumentError.value(json, 'json', 'missing world state');
    }
    final sync = WorldSync.fromJson(Map<String, dynamic>.from(worldJson));
    final board = MeshTaskBoard._(sync);
    final boardId = json['board_id'];
    if (boardId is String && boardId != sync.docId) {
      throw ArgumentError.value(
        boardId,
        'board_id',
        'does not match the kernel doc id ${sync.docId}',
      );
    }
    final snapshotJson = json['snapshot'];
    if (snapshotJson is Map) {
      board.adoptSnapshot(
        Snapshot.fromJson(Map<String, dynamic>.from(snapshotJson)),
      );
    }
    // Raise-only clock recomputation over everything the file carries.
    final issued = _hlcOf(json['issued_clock']);
    if (issued != null) board._raiseIssued(issued);
    final received = _hlcOf(json['received_clock']);
    if (received != null) board._absorbReceived(received);
    for (final op in sync.pendingOps) {
      board._absorbReceived(op.hlc);
      if (op.actorId == board.replicaId) board._raiseIssued(op.hlc);
    }
    return board;
  }

  MeshTaskBoard._(this._sync, {final DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// Default board id (and kernel doc id).
  static const String defaultBoardId = 'agent_world';

  static const String _entityPrefix = 'task/';
  static const String _component = 'task';
  static const String _fieldTitle = 'title';
  static const String _fieldStatus = 'status';
  static const String _fieldOrigin = 'origin';
  static const String _fieldCreatedAt = 'createdAt';
  static const String _fieldVerdict = 'verdict';

  /// Task lifecycle statuses (LWW registers — see the library doc).
  static const String statusRequested = 'requested';
  static const String statusRunning = 'running';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';

  final WorldSync _sync;
  final DateTime Function() _now;

  /// Highest HLC this board has causally RECEIVED (remote ops, adopted
  /// snapshots, restored log) — the receive-watermark floor. The actor is
  /// kept verbatim: this watermark is only ever read for its wall clock
  /// (`_issueTime`), never issued from.
  Hlc? _receivedWatermark;

  /// This board's own-actor HLC, ticked per [requestTask] to derive
  /// task-local ids. Never absorbs a foreign actor.
  Hlc? _issuedClock;

  /// Snapshot most recently taken or adopted — persisted under the
  /// `snapshot` key so restores keep serving lagging peers across
  /// restarts (the `DocReplica` durable-cache discipline).
  Snapshot? _lastSnapshot;

  String get boardId => _sync.docId;
  String get replicaId => _sync.actorId;

  // ---------------------------------------------------------------------------
  // Reads (through the WorldSync projection — never a side state)
  // ---------------------------------------------------------------------------

  /// All tasks of [docId], sorted by `createdAt` then `taskId` —
  /// deterministic on every replica.
  List<MeshTaskRecord> tasksFor(final String docId) => _sorted(
    _allRecords().where((final record) => record.docId == docId).toList(),
  );

  /// Tasks of [docId] still waiting for a worker: status `requested` and
  /// not dispatched by [selfPeerId] (a dispatcher never picks up its own
  /// request). Same deterministic order as [tasksFor].
  List<MeshTaskRecord> pendingRequestsFor(
    final String docId, {
    final String? selfPeerId,
  }) => tasksFor(docId)
      .where(
        (final record) =>
            record.status == statusRequested &&
            record.originPeerId != selfPeerId,
      )
      .toList();

  /// The folded record for [taskId]; null when absent or malformed.
  MeshTaskRecord? taskOf(final String taskId) {
    final parsed = _splitTaskId(taskId);
    if (parsed == null) return null;
    return _recordOf(parsed.$1, parsed.$2);
  }

  // ---------------------------------------------------------------------------
  // Local writes (one op per field change)
  // ---------------------------------------------------------------------------

  /// Announces a task for [docId] and returns its id; the row starts in
  /// status `requested` with [originPeerId]/[originActorId] as the
  /// dispatcher of record.
  String requestTask({
    required final String docId,
    required final String task,
    required final String originPeerId,
    final String? originActorId,
    final DateTime? now,
  }) {
    if (docId.isEmpty) {
      throw ArgumentError.value(docId, 'docId', 'must not be empty');
    }
    if (task.isEmpty) {
      throw ArgumentError.value(task, 'task', 'must not be empty');
    }
    if (originPeerId.isEmpty) {
      throw ArgumentError.value(
        originPeerId,
        'originPeerId',
        'must not be empty',
      );
    }
    final at = _issueTime(now);
    final localId = _newTaskLocalId(at);
    _write(docId, localId, _fieldTitle, task, at);
    _write(docId, localId, _fieldStatus, statusRequested, at);
    _write(docId, localId, _fieldOrigin, {
      'peerId': originPeerId,
      'actorId': ?originActorId,
    }, at);
    _write(docId, localId, _fieldCreatedAt, at.millisecondsSinceEpoch, at);
    return _taskIdOf(docId, localId);
  }

  /// Moves [taskId] to `running` (one status op). Throws [StateError]
  /// when the task is absent — there is nothing to mark. Transitions are
  /// not otherwise enforced: statuses are LWW registers (library doc).
  void markRunning(final String taskId, {final DateTime? now}) =>
      _writeStatus(taskId, statusRunning, now);

  /// Moves [taskId] to `completed`, merging [verdict] over any existing
  /// verdict register (one op per field actually written).
  void completeTask(
    final String taskId, {
    final Map<String, Object?>? verdict,
    final DateTime? now,
  }) {
    _writeStatus(taskId, statusCompleted, now);
    _mergeVerdict(taskId, verdict, now: now);
  }

  /// Moves [taskId] to `failed`; [error] lands inside the verdict
  /// register (merged over existing values and [verdict]).
  void failTask(
    final String taskId, {
    final String? error,
    final Map<String, Object?>? verdict,
    final DateTime? now,
  }) {
    _writeStatus(taskId, statusFailed, now);
    _mergeVerdict(taskId, verdict, error: error, now: now);
  }

  // ---------------------------------------------------------------------------
  // Sync seams (kernel-backed via WorldSync)
  // ---------------------------------------------------------------------------

  VersionVector get versionVector => _sync.vv;

  /// Ops this board holds that [remoteVv] has not observed.
  List<OpRecord> opsSince(final VersionVector remoteVv) =>
      _sync.opsFor(remoteVv);

  /// Folds remote ops (idempotent, order-free — kernel contract) and
  /// raises the receive-watermark floor above every delivered op so later
  /// local writes win LWW over what they causally follow. Returns how
  /// many ops were newly applied.
  int applyRemote(final Iterable<OpRecord> ops) {
    final applied = _sync.applyRemote(ops);
    if (applied > 0) {
      for (final op in ops) {
        _absorbReceived(op.hlc);
      }
    }
    return applied;
  }

  /// True when [remoteVv] is fully covered but this board's log was
  /// compacted — the caller must ship [snapshotFor] instead.
  bool needsSnapshotFor(final VersionVector remoteVv) =>
      _sync.needsSnapshotFor(remoteVv);

  /// The current state as a snapshot at this board's watermark; remembered
  /// for [toJson] (the durable snapshot cache).
  Snapshot snapshotFor() {
    final snapshot = _sync.snapshotFor();
    _lastSnapshot = snapshot;
    return snapshot;
  }

  /// Adopts [snapshot] when it carries unseen events (safe and idempotent
  /// per the kernel contract); local pending ops beyond the snapshot base
  /// are kept and re-folded by the kernel. The snapshot's `createdAt` is
  /// absorbed into the HLC floor so later local writes order after the
  /// snapshot content. The offered snapshot is remembered for [toJson]
  /// even when refused (refusal proves full coverage — the `DocReplica`
  /// discipline).
  bool adoptSnapshot(final Snapshot snapshot) {
    final adopted = _sync.adoptSnapshot(snapshot);
    _lastSnapshot = snapshot;
    if (!adopted) return false;
    _absorbReceived(snapshot.createdAt);
    return true;
  }

  /// Compacts when the WorldSync log exceeds [maxLogOps]: the current
  /// state becomes the snapshot and the log is truncated (the periodic
  /// policy — cheap, fires only above the threshold). Returns 1 when
  /// compacted, else 0.
  int compact({final int maxLogOps = 512}) {
    if (_sync.pendingOps.length <= maxLogOps) return 0;
    _sync.compact();
    _lastSnapshot = _sync.snapshotFor();
    return 1;
  }

  /// Full durable op log (for the whole-file flush/absorb exchange).
  List<OpRecord> get pendingOps => _sync.pendingOps;

  /// Full serialization for durable local persistence: the WorldSync
  /// state, the snapshot cache when one was taken/adopted, board
  /// metadata, and both HLC clocks (task-id monotonicity + receive floor).
  Map<String, Object?> toJson() => {
    'board_id': boardId,
    'replica_id': replicaId,
    'world': _sync.toJson(),
    if (_lastSnapshot != null) 'snapshot': _lastSnapshot!.toJson(),
    if (_issuedClock != null) 'issued_clock': _issuedClock!.toJson(),
    if (_receivedWatermark != null)
      'received_clock': _receivedWatermark!.toJson(),
  };

  // ---------------------------------------------------------------------------
  // Internals: keys and records
  // ---------------------------------------------------------------------------

  static String _entityKey(final String docId, final String localId) =>
      '$entityRoot$docId/$localId';

  /// Key root: `task/<docId>/<taskLocalId>` with component `task` — the
  /// full sync key is `<entity>/<component>/<field>`.
  static const String entityRoot = _entityPrefix;

  static String _taskIdOf(final String docId, final String localId) =>
      '$docId#$localId';

  /// Splits `<docId>#<taskLocalId>` at the LAST `#` (doc ids must not
  /// contain `#`); null when malformed.
  static (String, String)? _splitTaskId(final String taskId) {
    final hash = taskId.lastIndexOf('#');
    if (hash <= 0 || hash == taskId.length - 1) return null;
    return (taskId.substring(0, hash), taskId.substring(hash + 1));
  }

  /// Parses a sync key `task/<docId>/<taskLocalId>/task/<field>`. The
  /// doc/local split sits at the last `/` of the entity part, so doc ids
  /// may contain `/` but task-local ids may not.
  static (String, String, String)? _parseKey(final String key) {
    if (!key.startsWith(_entityPrefix)) return null;
    final rest = key.substring(_entityPrefix.length);
    const componentSeparator = '/$_component/';
    final componentStart = rest.lastIndexOf(componentSeparator);
    if (componentStart < 0) return null;
    final field = rest.substring(componentStart + componentSeparator.length);
    final entity = rest.substring(0, componentStart);
    final slash = entity.lastIndexOf('/');
    if (slash <= 0 || slash == entity.length - 1) return null;
    return (entity.substring(0, slash), entity.substring(slash + 1), field);
  }

  /// Rebuilds every task row from the projection. Required fields
  /// (`title`, `status`, `createdAt`) must all be present; a partially
  /// folded row reads as absent (DESIGN §6).
  List<MeshTaskRecord> _allRecords() {
    final projection = _sync.projection;
    final fieldsByTask = <String, Map<String, Object?>>{};
    projection.values.forEach((final key, final value) {
      final parsed = _parseKey(key);
      if (parsed == null || value == null) return;
      final (docId, localId, field) = parsed;
      fieldsByTask.putIfAbsent(
        _taskIdOf(docId, localId),
        () => <String, Object?>{},
      )[field] = value;
    });
    final records = <MeshTaskRecord>[];
    for (final entry in fieldsByTask.entries) {
      final fields = entry.value;
      final title = fields[_fieldTitle];
      final status = fields[_fieldStatus];
      final createdAt = fields[_fieldCreatedAt];
      if (title is! String || status is! String || createdAt is! int) continue;
      final taskId = entry.key;
      final docId = taskId.substring(0, taskId.lastIndexOf('#'));
      final origin = fields[_fieldOrigin];
      final verdict = fields[_fieldVerdict];
      records.add(
        MeshTaskRecord(
          taskId: taskId,
          docId: docId,
          task: title,
          status: status,
          originPeerId: origin is Map && origin['peerId'] is String
              ? origin['peerId'] as String
              : null,
          originActorId: origin is Map && origin['actorId'] is String
              ? origin['actorId'] as String
              : null,
          // Epoch ms is zone-free; read back as UTC for determinism.
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            createdAt,
            isUtc: true,
          ),
          verdict: verdict is Map ? Map<String, Object?>.from(verdict) : null,
        ),
      );
    }
    return _sorted(records);
  }

  MeshTaskRecord? _recordOf(final String docId, final String localId) {
    for (final record in _allRecords()) {
      if (record.taskId == _taskIdOf(docId, localId)) return record;
    }
    return null;
  }

  static List<MeshTaskRecord> _sorted(final List<MeshTaskRecord> records) =>
      records..sort((final a, final b) {
        final byTime = a.createdAt.compareTo(b.createdAt);
        return byTime != 0 ? byTime : a.taskId.compareTo(b.taskId);
      });

  // ---------------------------------------------------------------------------
  // Internals: writes
  // ---------------------------------------------------------------------------

  void _write(
    final String docId,
    final String localId,
    final String field,
    final Object? value,
    final DateTime at,
  ) {
    _sync.applyDelta(
      ComponentDelta(
        entityKey: _entityKey(docId, localId),
        component: _component,
        field: field,
        value: value,
      ),
      at,
    );
  }

  void _writeStatus(
    final String taskId,
    final String status,
    final DateTime? now,
  ) {
    final parsed = _splitTaskId(taskId);
    if (parsed == null) {
      throw ArgumentError.value(
        taskId,
        'taskId',
        'expected <docId>#<taskLocalId>',
      );
    }
    if (_recordOf(parsed.$1, parsed.$2) == null) {
      throw StateError('task $taskId is not on this board (absent)');
    }
    _write(parsed.$1, parsed.$2, _fieldStatus, status, _issueTime(now));
  }

  void _mergeVerdict(
    final String taskId,
    final Map<String, Object?>? verdict, {
    final String? error,
    final DateTime? now,
  }) {
    if (verdict == null && error == null) return;
    final parsed = _splitTaskId(taskId);
    if (parsed == null) return; // Shape already validated by _writeStatus.
    final merged = <String, Object?>{
      ...?_recordOf(parsed.$1, parsed.$2)?.verdict,
      ...?verdict,
      'error': ?error,
    };
    _write(parsed.$1, parsed.$2, _fieldVerdict, merged, _issueTime(now));
  }

  // ---------------------------------------------------------------------------
  // Internals: clocks (task ids + the HLC receive floor; see library doc)
  // ---------------------------------------------------------------------------

  /// The wall clock handed to `applyDelta`, floored strictly above every
  /// received op's wall clock. `Hlc.tick` is monotonic in
  /// `max(now, previous)`, so the issued op's HLC lands strictly above
  /// the whole received history — the causality the kernel's `applyLocal`
  /// cannot see (it only tracks this replica's own entry).
  DateTime _issueTime(final DateTime? now) {
    final real = (now ?? _now()).millisecondsSinceEpoch;
    final watermark = _receivedWatermark;
    if (watermark != null && real <= watermark.wallMillis) {
      return DateTime.fromMillisecondsSinceEpoch(watermark.wallMillis + 1);
    }
    return DateTime.fromMillisecondsSinceEpoch(real);
  }

  /// Next HLC-derived task-local id (`wall:counter:actor`): strictly
  /// monotonic per board even on a frozen wall clock.
  String _newTaskLocalId(final DateTime at) {
    final current = _issuedClock ?? Hlc.zero(replicaId);
    final next = current.tick(at);
    _issuedClock = next;
    return '${next.wallMillis}:${next.counter}:${next.actorId}';
  }

  void _raiseIssued(final Hlc hlc) {
    final current = _issuedClock;
    if (current != null && current >= hlc) return;
    _issuedClock = hlc;
  }

  void _absorbReceived(final Hlc remote) {
    final current = _receivedWatermark;
    if (current != null && current >= remote) return;
    _receivedWatermark = remote;
  }

  static Hlc? _hlcOf(final Object? raw) =>
      raw is Map ? Hlc.fromJson(Map<String, dynamic>.from(raw)) : null;
}
