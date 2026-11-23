import 'dart:convert';

import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/ecs_plugins/boards/lww_replica_core.dart';
import 'package:lastanswer/ecs_plugins/boards/mesh_task_board.dart';
import 'package:lastanswer/ecs_plugins/boards/planning_board_replica.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';

/// Last Answer's [MeshSyncParticipant]s (ADR 0047 §3): the app owns the
/// content shapes; the extracted [MeshWorldSession] owns the cycle order.
///
/// All fold the same way — durable kernel ops whose VV dedupe makes
/// re-folding idempotent and delivery-order independent, so whole-file LWW
/// on the storage seam cannot desync replicas.

/// The actor roster (ADR 0007 §1): one whole file per replica under
/// `actor_rosters/`, shipped and folded like any doc replica file.
final class RosterParticipant implements MeshSyncParticipant {
  RosterParticipant(this.roster);

  static const _rosterDir = 'actor_rosters';

  final ActorRoster roster;

  @override
  Future<void> flush(final StorageService storage) async {
    await storage.saveFile(
      '$_rosterDir/${roster.replicaId}.json',
      jsonEncode(roster.toJson()),
      message: 'save actor roster ${roster.replicaId}',
    );
  }

  /// Folds durable roster ops delivered by the exchange: every peer's
  /// roster file carries its durable op log.
  @override
  Future<void> absorb(final StorageService storage) async {
    final entries = await storage.listDirectory(_rosterDir);
    for (final entry in entries) {
      if (entry.isDirectory || !entry.name.endsWith('.json')) continue;
      if (entry.name == '${roster.replicaId}.json') continue; // our own
      final raw = await storage.readFile('$_rosterDir/${entry.name}');
      if (raw == null) continue;
      final ops = _opsOfLog(raw, logKey: 'log');
      if (ops.isEmpty) continue;
      roster.applyRemote(ops);
    }
  }

  @override
  Future<void> compact(final StorageService storage) async {}
}

/// The ONE WorldSync-backed whole-file participant over the extracted
/// replica core (the merge lane's follow-up, landed 2026-11-23): both
/// board participants fold IDENTICALLY —
///
/// - whole state rides one file, flushed with the replica's own
///   byte-frozen `toJson`;
/// - absorbed SNAPSHOT FIRST (the kernel adopts only snapshots its
///   version vector does not already cover, so folding the file's op log
///   first would advance the vector past the snapshot base and silently
///   refuse the snapshot content — the only carrier of a COMPACTED peer
///   file's state);
/// - our own flush is skipped by `replica_id`;
/// - the merged state flushes back when anything changed (the exchange
///   shadowed our file with the peer's).
///
/// Domain subclasses name the path and may hook the ADR 0028-style
/// absorption window (a legacy path absorbed forever, mirrored while
/// the window stands).
abstract base class LwwBoardSyncParticipant implements MeshSyncParticipant {
  LwwBoardSyncParticipant({required this.core, required this.path});

  /// The replica whose sync seams this participant folds through. The
  /// polymorphic `toJson` keeps each replica's byte-frozen key order —
  /// this base never reshapes it.
  final LwwReplicaCore core;

  /// The single file this board ships and folds.
  final String path;

  /// The flush commit message label (the storage seam's journal line).
  String get flushLabel => 'save board ${core.boardId}';

  /// Extra files absorbed AFTER [path] — the task board's legacy path
  /// folds forever (idempotent under the version vector).
  List<String> get extraAbsorbPaths => const [];

  /// Hook: rekey a decoded absorb file in place before it folds
  /// (ADR 0028 — a pre-rename peer file carries the legacy doc id at
  /// every level). Default: none.
  void rekeyAbsorbed(final Map<Object?, Object?> json) {}

  /// Hook: the legacy mirror written after the primary flush (ADR 0028,
  /// while the absorption window stands). Default: no-op.
  Future<void> mirrorLegacy(final StorageService storage) async {}

  @override
  Future<void> flush(final StorageService storage) async {
    await storage.saveFile(
      path,
      jsonEncode(core.toJson()),
      message: flushLabel,
    );
    await mirrorLegacy(storage);
  }

  @override
  Future<void> absorb(final StorageService storage) async {
    await _absorbFile(storage, path);
    for (final extra in extraAbsorbPaths) {
      await _absorbFile(storage, extra);
    }
  }

  Future<void> _absorbFile(
    final StorageService storage,
    final String path,
  ) async {
    final raw = await storage.readFile(path);
    if (raw == null) return;
    final json = _boardJsonOf(raw);
    if (json == null) return;
    if (json['replica_id'] == core.replicaId) return; // our own flush
    rekeyAbsorbed(json);
    var changed = false;
    final snapshotJson = json['snapshot'];
    if (snapshotJson is Map &&
        core.adoptSnapshot(
          Snapshot.fromJson(Map<String, dynamic>.from(snapshotJson)),
        )) {
      changed = true;
    }
    if (core.applyRemote(_boardOpsOf(json)) > 0) changed = true;
    // The exchange shadowed our file with the peer's; write the merged
    // state back so the next pass ships it.
    if (changed) await flush(storage);
  }

  @override
  Future<void> compact(final StorageService storage) async {
    // The board owns one whole file, so the flush happens here when the
    // log actually shrank.
    if (core.compact() > 0) await flush(storage);
  }

  /// Decoded board JSON of a persisted board file; null when malformed.
  static Map<Object?, Object?>? _boardJsonOf(final String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    return decoded is Map ? decoded : null;
  }

  /// The durable op log of a persisted board JSON (inside the WorldSync
  /// state under `world`).
  static List<OpRecord> _boardOpsOf(final Map<Object?, Object?> json) {
    final world = json['world'];
    if (world is! Map) return const [];
    final log = world['log'];
    if (log is! List) return const [];
    return _opsFromList(log);
  }
}

/// The durable op log of a persisted roster JSON.
List<OpRecord> _opsOfLog(final String raw, {required final String logKey}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return const [];
  }
  if (decoded is! Map) return const [];
  final log = decoded[logKey];
  if (log is! List) return const [];
  return _opsFromList(log);
}

List<OpRecord> _opsFromList(final List<dynamic> log) => [
  for (final entry in log)
    if (entry is Map) OpRecord.fromJson(Map<String, dynamic>.from(entry)),
];

/// The mesh task board over [LwwBoardSyncParticipant]. ADR 0028 — the
/// versioned absorption window: while [kTaskBoardLegacyMirror] stands,
/// every task-board flush ALSO mirrors the merged state to the legacy
/// path with all doc ids rewritten back, so a pre-rename peer folding
/// `task_boards/agent_world.json` sees exactly the board it would have
/// seen before the rename. Retirement is an operator decision: flip in
/// a release once no pre-rename device syncs anymore.
const bool kTaskBoardLegacyMirror = true;

final class TaskBoardParticipant extends LwwBoardSyncParticipant {
  TaskBoardParticipant(this.board)
    : super(core: board, path: 'task_boards/${board.boardId}.json');

  final MeshTaskBoard board;

  @override
  String get flushLabel => 'save task board ${board.boardId}';

  /// The pre-rename board path (ADR 0028): read forever, mirrored while
  /// [kTaskBoardLegacyMirror] stands.
  static const String legacyPath =
      'task_boards/'
      '${MeshTaskBoard.legacyBoardId}.json';

  @override
  List<String> get extraAbsorbPaths => <String>[legacyPath];

  @override
  Future<void> mirrorLegacy(final StorageService storage) async {
    final windowOpen =
        kTaskBoardLegacyMirror && board.boardId != MeshTaskBoard.legacyBoardId;
    if (!windowOpen) {
      return;
    }
    // ADR 0028 — the legacy mirror: the same merged state with every
    // doc_id/board_id rewritten to the pre-rename id, so a v1 peer's
    // kernel accepts the ops it would have refused as foreign.
    final mirror = LwwReplicaCore.rekeyDocId(
      jsonDecode(jsonEncode(board.toJson())) as Map<Object?, Object?>,
      from: board.boardId,
      to: MeshTaskBoard.legacyBoardId,
    );
    await storage.saveFile(
      legacyPath,
      jsonEncode(mirror),
      message: 'mirror task board ${MeshTaskBoard.legacyBoardId}',
    );
  }

  @override
  void rekeyAbsorbed(final Map<Object?, Object?> json) {
    // ADR 0028 — the legacy path folds forever. A pre-rename peer file
    // carries the legacy doc id at every level; the rekey makes it
    // foldable before it reaches the kernel.
    LwwReplicaCore.rekeyDocId(
      json,
      from: MeshTaskBoard.legacyBoardId,
      to: board.boardId,
    );
  }
}

/// The planning board over [LwwBoardSyncParticipant]: its whole state
/// rides `planning_boards/<boardId>.json` — the same snapshot-first
/// discipline, no absorption window.
final class PlanningBoardParticipant extends LwwBoardSyncParticipant {
  PlanningBoardParticipant(this.replica)
    : super(core: replica, path: 'planning_boards/${replica.boardId}.json');

  final PlanningBoardReplica replica;

  @override
  String get flushLabel => 'save planning board ${replica.boardId}';
}
