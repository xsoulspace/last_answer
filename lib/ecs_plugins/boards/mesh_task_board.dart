/// The mesh task board: durable agent-task rows riding the mesh exactly
/// like the actor roster (ADR 0007 §1) — kernel ops under a whole-file
/// exchange (`task_boards/<boardId>.json`), never a hand merge.
///
/// One board = ONE [WorldSync] replica (kernel `ConvergenceDoc`, LWW
/// map, ADR 0011) whose doc id is the [MeshTaskBoard.boardId], through
/// the shared [LwwReplicaCore] (key/HLC-clock/absorb machinery, restore
/// discipline, sync seams — see that library doc for the causality
/// reasoning). Task fields are one keyed register each:
///
/// - entity key: `task/<docId>/<taskLocalId>`, component `task`;
/// - fields: `title` (task text), `status`
///   (`requested`/`running`/`completed`/`failed`), `origin` (JSON
///   `{peerId, actorId}` of the dispatcher), `createdAt` (epoch ms int),
///   `verdict` (JSON map, written by complete/fail).
///
/// Task ids: `<docId>#<taskLocalId>`. `taskLocalId` is HLC-derived from
/// the board-level own-actor clock: unique per board (strictly
/// monotonic, even on a frozen wall clock), unique across boards (the
/// actor id is embedded), deterministic, and monotonic across restarts
/// (persisted under `toJson`'s `issued_clock` key). Doc ids must not
/// contain `#` (task ids split at the LAST `#`).
library;

import 'package:collection/collection.dart';
import 'package:ecsly_world_sync/ecsly_world_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/ecs_plugins/boards/lww_replica_core.dart';
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
/// wire format and id discipline, [LwwReplicaCore] for the shared
/// restore semantics, HLC floor, and sync seams.
final class MeshTaskBoard extends LwwReplicaCore {
  /// Creates a board replica owned by [replicaId] (the mesh peer id).
  MeshTaskBoard({
    required super.replicaId,
    super.boardId = defaultBoardId,
    super.now,
  });

  /// Restores a board previously written by [toJson] and keeps it
  /// participating (sync seams stay live) — the shared [LwwReplicaCore]
  /// restore discipline (kernel state as-is, snapshot adopted, clocks
  /// recomputed raise-only; see [LwwReplicaCore.absorbRestoredFile]).
  factory MeshTaskBoard.fromJson(final Map<String, Object?> json) =>
      MeshTaskBoard._(LwwReplicaCore.restoredWorldOf(json))
        ..absorbRestoredFile(json);

  MeshTaskBoard._(super.sync) : super.restored();

  /// Default board id (and kernel doc id). Renamed from the demo-era
  /// `agent_world` through the versioned absorption window (ADR 0028):
  /// the old id survives as [legacyBoardId] — absorbed forever, mirrored
  /// while the migration window stands.
  static const String defaultBoardId = 'main';

  /// The pre-rename board id (ADR 0028). Files carrying it at any
  /// `doc_id`/`board_id` level are rewritten by [rekeyDocId] before they
  /// reach the kernel, which refuses foreign doc ids.
  static const String legacyBoardId = 'agent_world';

  /// Rewrites a board file between replica doc ids in place (ADR 0028).
  ///
  /// The replica doc id rides flat `doc_id` fields at every level of the
  /// persisted shape — each log op ([OpRecord.toJson], where the op id is
  /// derived as `docId#hlc#wall#counter#actor`), the adopted snapshot, the
  /// convergence doc — plus the envelope's `board_id`. The kernel drops
  /// ops whose `doc_id` differs from the replica's own, so a file must be
  /// rewritten BEFORE it folds; entity keys are untouched (they embed the
  /// TASK's document id, which is independent of the board id). Only
  /// exact-match values on the two known keys are rewritten, and the
  /// rewrite is idempotent under the version vector — re-absorbing the
  /// same file folds nothing new.
  static Map<Object?, Object?> rekeyDocId(
    final Map<Object?, Object?> json, {
    required final String from,
    required final String to,
  }) {
    if (from == to) return json;
    void walk(final Object? node) {
      if (node is Map) {
        node.forEach((final key, final value) {
          if ((key == 'board_id' || key == 'doc_id') && value == from) {
            node[key] = to;
          } else {
            walk(value);
          }
        });
      } else if (node is List) {
        node.forEach(walk);
      }
    }

    walk(json);
    return json;
  }

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

  @override
  String get entityPrefix => _entityPrefix;

  @override
  String get component => _component;

  /// Key root: `task/<docId>/<taskLocalId>` with component `task` — the
  /// full sync key is `<entity>/<component>/<field>`.
  static const String entityRoot = _entityPrefix;

  // ---------------------------------------------------------------------------
  // Reads (through the WorldSync projection — never a side state)
  // ---------------------------------------------------------------------------

  /// All tasks of [docId], sorted by `createdAt` then `taskId` —
  /// deterministic on every replica.
  List<MeshTaskRecord> tasksFor(final String docId) => _sorted(
    _allRecords().where((final record) => record.docId == docId).toList(),
  );

  /// Every task on the board across docs, same deterministic order —
  /// the Settings observability view (ADR 0023) reads this.
  List<MeshTaskRecord> get allRecords => _sorted(_allRecords());

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
    final parsed = LwwReplicaCore.splitCompoundId(taskId);
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
    final at = issueTime(now);
    final localId = newLocalId(at);
    write(docId, localId, _fieldTitle, task, at);
    write(docId, localId, _fieldStatus, statusRequested, at);
    write(docId, localId, _fieldOrigin, {
      'peerId': originPeerId,
      'actorId': ?originActorId,
    }, at);
    write(docId, localId, _fieldCreatedAt, at.millisecondsSinceEpoch, at);
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
  // Internals: keys and records
  // ---------------------------------------------------------------------------

  static String _taskIdOf(final String docId, final String localId) =>
      '$docId#$localId';

  /// Rebuilds every task row from the projection. Required fields
  /// (`title`, `status`, `createdAt`) must all be present; a partially
  /// folded row reads as absent (DESIGN §6).
  List<MeshTaskRecord> _allRecords() {
    final fieldsByTask = foldEntityFields();
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

  void _writeStatus(
    final String taskId,
    final String status,
    final DateTime? now,
  ) {
    final parsed = LwwReplicaCore.splitCompoundId(taskId);
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
    write(parsed.$1, parsed.$2, _fieldStatus, status, issueTime(now));
  }

  void _mergeVerdict(
    final String taskId,
    final Map<String, Object?>? verdict, {
    final String? error,
    final DateTime? now,
  }) {
    if (verdict == null && error == null) return;
    final parsed = LwwReplicaCore.splitCompoundId(taskId);
    if (parsed == null) return; // Shape already validated by _writeStatus.
    final merged = <String, Object?>{
      ...?_recordOf(parsed.$1, parsed.$2)?.verdict,
      ...?verdict,
      'error': ?error,
    };
    write(parsed.$1, parsed.$2, _fieldVerdict, merged, issueTime(now));
  }
}
