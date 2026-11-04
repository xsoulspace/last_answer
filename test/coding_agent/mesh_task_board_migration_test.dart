import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';
import 'package:lastanswer/settings/features/mesh_sync_participants.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// ADR 0028 — the versioned absorption window that renamed the mesh task
/// board off the demo-era `agent_world` onto `main`.
///
/// The contract, each pinned by a test:
/// - the replica doc id rides flat `doc_id` fields at every level of a
///   persisted file (ops, snapshot, convergence doc) plus `board_id`, and
///   the kernel refuses ops whose `doc_id` differs from its own — so a
///   legacy file is rewritten before it folds ([MeshTaskBoard.rekeyDocId]);
/// - absorbing the legacy path works forever, including a COMPACTED v1
///   file whose only state carrier is its (rewritten) snapshot;
/// - while [kTaskBoardLegacyMirror] stands, every flush also mirrors the
///   merged state back with doc ids rewritten to the legacy id, so a
///   pre-rename peer keeps converging;
/// - the whole window is idempotent — re-absorbing the same file folds
///   nothing new.
///
/// Everything runs against in-memory fake providers, no networking.

const _canonicalFile = 'task_boards/main.json';
const _legacyFile = TaskBoardParticipant.legacyPath;

final class _FakeProvider extends StorageProvider {
  final Map<String, String> files = {};

  @override
  Future<void> initWithConfig(final StorageConfig config) async {}

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<FileOperationResult> createFile(
    final String path,
    final String content, {
    final String? commitMessage,
  }) async => _write(path, content);

  @override
  Future<FileOperationResult> updateFile(
    final String path,
    final String content, {
    final String? commitMessage,
  }) async => _write(path, content);

  FileOperationResult _write(final String path, final String content) {
    files[path] = content;
    return FileOperationResult(path: path);
  }

  @override
  Future<String?> getFile(final String path) async => files[path];

  @override
  Future<FileOperationResult> deleteFile(
    final String path, {
    final String? commitMessage,
  }) async {
    files.remove(path);
    return FileOperationResult(path: path);
  }

  @override
  Future<List<FileEntry>> listDirectory(final String directoryPath) async {
    final prefix = '$directoryPath/';
    return [
      for (final path in files.keys.where((final p) => p.startsWith(prefix)))
        FileEntry(name: path.substring(prefix.length), isDirectory: false),
    ];
  }

  @override
  Future<void> restore(final String path, {final String? versionId}) async {}

  @override
  bool get supportsSync => true;

  @override
  Future<void> sync({
    final String? pullMergeStrategy,
    final String? pushConflictStrategy,
  }) async {}

  @override
  Future<void> dispose() async {}
}

MeshTaskBoard _v1Board(final String replicaId) => MeshTaskBoard(
  replicaId: replicaId,
  boardId: MeshTaskBoard.legacyBoardId,
  now: () => DateTime.utc(2026, 9, 6, 12),
);

MeshTaskBoard _v2Board(final String replicaId) => MeshTaskBoard(
  replicaId: replicaId,
  now: () => DateTime.utc(2026, 9, 6, 12),
);

void main() {
  test('rekeyDocId rewrites only exact doc_id/board_id matches, at depth', () {
    final json = <Object?, Object?>{
      'board_id': 'agent_world',
      'replica_id': 'peer-a',
      'world': {
        'doc_id': 'agent_world',
        'log': [
          {
            'doc_id': 'agent_world',
            'hlc': {'actorId': 'peer-a'},
            // Entity keys embed the TASK's doc id — never rewritten.
            'payload': {'entityKey': 'task/doc-1/abc'},
          },
          {
            'doc_id': 'agent_world',
            'hlc': {'actorId': 'peer-a'},
            'payload': {'entityKey': 'task/agent_world/xyz'},
          },
        ],
      },
      'snapshot': <Object?, Object?>{
        'doc_id': 'agent_world',
        'base_vv': <String, Object?>{},
      },
    };
    MeshTaskBoard.rekeyDocId(json, from: 'agent_world', to: 'main');
    expect(json['board_id'], 'main');
    final world = json['world']! as Map<Object?, Object?>;
    expect(world['doc_id'], 'main');
    final log = world['log']! as List<Object?>;
    expect((log[0]! as Map)['doc_id'], 'main');
    expect((log[1]! as Map)['doc_id'], 'main');
    expect(
      ((log[0]! as Map)['payload']! as Map)['entityKey'],
      'task/doc-1/abc',
    );
    // An entity key that merely CONTAINS the legacy id is left alone.
    expect(
      ((log[1]! as Map)['payload']! as Map)['entityKey'],
      'task/agent_world/xyz',
    );
    expect((json['snapshot']! as Map)['doc_id'], 'main');
    expect(json['replica_id'], 'peer-a');
    // Idempotent.
    MeshTaskBoard.rekeyDocId(json, from: 'agent_world', to: 'main');
    expect(json['board_id'], 'main');
  });

  test('a v1 board file folds into the canonical replica through the rewrite',
      () async {
    final provider = _FakeProvider();
    final storage = StorageService(provider);
    addTearDown(provider.dispose);

    final v1 = _v1Board('peer-a')
      ..requestTask(
        docId: 'doc-1',
        task: 'born under agent_world',
        originPeerId: 'peer-a',
      );
    final taskId = v1.allRecords.single.taskId;
    v1.markRunning(taskId, now: DateTime.utc(2026, 9, 6, 12, 0, 1));
    provider.files[_legacyFile] = jsonEncode(v1.toJson());

    final v2 = _v2Board('peer-b')
      ..requestTask(
        docId: 'doc-1',
        task: 'born under main',
        originPeerId: 'peer-b',
      );
    final participant = TaskBoardParticipant(v2);
    await participant.absorb(storage);

    expect(v2.allRecords.map((final r) => r.task), unorderedEquals([
      'born under agent_world',
      'born under main',
    ]));
    final migrated = v2.taskOf(taskId);
    expect(migrated, isNotNull);
    expect(migrated!.status, MeshTaskBoard.statusRunning);
    // The rewrite landed before the kernel: no foreign-doc refusal, and
    // the absorb wrote the merged state back to the canonical file.
    expect(provider.files.keys, contains(_canonicalFile));
  });

  test('a compacted v1 file folds purely through its rewritten snapshot',
      () async {
    final provider = _FakeProvider();
    final storage = StorageService(provider);
    addTearDown(provider.dispose);

    final v1 = _v1Board('peer-a')
      ..requestTask(
        docId: 'doc-1',
        task: 'snapshot-carried state',
        originPeerId: 'peer-a',
      )
      ..compact(maxLogOps: 0);
    final json = v1.toJson();
    expect((json['world']! as Map)['log'], isEmpty);
    provider.files[_legacyFile] = jsonEncode(json);

    final v2 = _v2Board('peer-b');
    await TaskBoardParticipant(v2).absorb(storage);

    expect(v2.allRecords.single.task, 'snapshot-carried state');
    expect(v2.allRecords.single.status, MeshTaskBoard.statusRequested);
  });

  test('flush mirrors the canonical state to the legacy path with legacy ids',
      () async {
    final provider = _FakeProvider();
    final storage = StorageService(provider);
    addTearDown(provider.dispose);

    final v2 = _v2Board('peer-a')
      ..requestTask(
        docId: 'doc-1',
        task: 'mirrored back',
        originPeerId: 'peer-a',
      );
    await TaskBoardParticipant(v2).flush(storage);

    expect(provider.files.keys, containsAll([_canonicalFile, _legacyFile]));
    final canonical =
        jsonDecode(provider.files[_canonicalFile]!) as Map<Object?, Object?>;
    expect(canonical['board_id'], 'main');
    final mirror =
        jsonDecode(provider.files[_legacyFile]!) as Map<Object?, Object?>;
    expect(mirror['board_id'], MeshTaskBoard.legacyBoardId);
    expect((mirror['world']! as Map)['doc_id'], MeshTaskBoard.legacyBoardId);
    // Every op carries the legacy doc id — one op per field, all rewritten.
    final mirrorLog = (mirror['world']! as Map)['log']! as List<Object?>;
    expect(mirrorLog, isNotEmpty);
    for (final op in mirrorLog) {
      expect((op! as Map)['doc_id'], MeshTaskBoard.legacyBoardId);
    }
    // Same payload, same HLCs — only the doc id differs, so a v1 kernel
    // accepts the ops it would have refused as foreign.
    final canonicalLog = (canonical['world']! as Map)['log']! as List<Object?>;
    expect(
      [for (final op in mirrorLog) (op! as Map)['hlc']],
      [for (final op in canonicalLog) (op! as Map)['hlc']],
    );
    expect(
      [for (final op in mirrorLog) (op! as Map)['payload']],
      [for (final op in canonicalLog) (op! as Map)['payload']],
    );
  });

  test('a v1 replica converges with a v2 replica through the mirror',
      () async {
    final provider = _FakeProvider();
    final storage = StorageService(provider);
    addTearDown(provider.dispose);

    final v2 = _v2Board('device-new');
    final taskId = v2.requestTask(
      docId: 'doc-1',
      task: 'cross-version convergence',
      originPeerId: 'device-new',
    );
    await TaskBoardParticipant(v2).flush(storage);

    // The v1 peer folds the legacy path — the only file it knows.
    final v1 = _v1Board('device-old');
    final v1Participant = TaskBoardParticipant(v1);
    await v1Participant.absorb(storage);
    expect(v1.taskOf(taskId)!.task, 'cross-version convergence');

    // The v1 peer answers (runs the task); its state rides its own flush
    // (which IS the legacy path for a v1-shaped board) and the v2 peer
    // absorbs it back — full round trip, mixed versions.
    v1.markRunning(taskId, now: DateTime.utc(2026, 9, 6, 12, 0, 1));
    await v1Participant.flush(storage);
    await TaskBoardParticipant(v2).absorb(storage);
    expect(v2.taskOf(taskId)!.status, MeshTaskBoard.statusRunning);
  });

  test('re-absorbing the same legacy file folds nothing new', () async {
    final provider = _FakeProvider();
    final storage = StorageService(provider);
    addTearDown(provider.dispose);

    final v1 = _v1Board('peer-a')
      ..requestTask(
        docId: 'doc-1',
        task: 'once only',
        originPeerId: 'peer-a',
      );
    provider.files[_legacyFile] = jsonEncode(v1.toJson());

    final v2 = _v2Board('peer-b');
    final participant = TaskBoardParticipant(v2);
    await participant.absorb(storage);
    final opsAfterFirst = v2.pendingOps.length;
    final recordsAfterFirst = v2.allRecords.length;

    await participant.absorb(storage);
    expect(v2.pendingOps.length, opsAfterFirst);
    expect(v2.allRecords.length, recordsAfterFirst);
  });
}
