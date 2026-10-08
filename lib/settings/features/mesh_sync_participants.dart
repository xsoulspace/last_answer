import 'dart:convert';

import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';

/// Last Answer's [MeshSyncParticipant]s (ADR 0047 §3): the app owns the
/// content shapes; the extracted [MeshWorldSession] owns the cycle order.
///
/// All three fold the same way — durable kernel ops whose VV dedupe makes
/// re-folding idempotent and delivery-order independent, so whole-file LWW
/// on the storage seam cannot desync replicas.

/// A [DocReplicaStore] riding the mesh: its batched flush ships the
/// latest replica state before anti-entropy; [absorbRemote] folds what the
/// exchange delivered; compaction follows the store's own policy.
final class DocSyncParticipant implements MeshSyncParticipant {
  const DocSyncParticipant(this.store);

  final DocReplicaStore store;

  @override
  Future<void> flush(final StorageService storage) => store.flush();

  @override
  Future<void> absorb(final StorageService storage) => store.absorbRemote();

  @override
  Future<void> compact(final StorageService storage) =>
      store.compactAll();
}

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

/// The mesh task board (WorldSync-backed): its whole state rides
/// `task_boards/<boardId>.json`, folded SNAPSHOT FIRST — the kernel
/// adopts only snapshots its version vector does not already cover, so
/// folding the file's op log first would advance the vector past the
/// snapshot base and silently refuse the snapshot content (the only
/// carrier of a COMPACTED peer file's state).
final class TaskBoardParticipant implements MeshSyncParticipant {
  TaskBoardParticipant(this.board) : path = 'task_boards/${board.boardId}.json';

  final MeshTaskBoard board;

  /// The single file this board ships and folds.
  final String path;

  @override
  Future<void> flush(final StorageService storage) async {
    await storage.saveFile(
      path,
      jsonEncode(board.toJson()),
      message: 'save task board ${board.boardId}',
    );
  }

  @override
  Future<void> absorb(final StorageService storage) async {
    final raw = await storage.readFile(path);
    if (raw == null) return;
    final json = _boardJsonOf(raw);
    if (json == null) return;
    if (json['replica_id'] == board.replicaId) return; // our own flush
    var changed = false;
    final snapshotJson = json['snapshot'];
    if (snapshotJson is Map &&
        board.adoptSnapshot(
          Snapshot.fromJson(Map<String, dynamic>.from(snapshotJson)),
        )) {
      changed = true;
    }
    if (board.applyRemote(_boardOpsOf(json)) > 0) changed = true;
    // The exchange shadowed our file with the peer's; write the merged
    // state back so the next pass ships it.
    if (changed) await flush(storage);
  }

  @override
  Future<void> compact(final StorageService storage) async {
    // The board owns one whole file, so the flush happens here when the
    // log actually shrank.
    if (board.compact() > 0) await flush(storage);
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
