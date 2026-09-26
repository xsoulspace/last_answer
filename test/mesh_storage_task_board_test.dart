import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Mesh integration tests for the task-board seam (the roster pattern,
/// ADR 0007 §1 applied to agent task rows): the sync cycle flushes the
/// attached [MeshTaskBoard] into `task_boards/<boardId>.json` before
/// anti-entropy and folds a peer's board file after — ops path AND
/// snapshot path — plus the periodic-sync timer policy.
///
/// Everything runs against in-memory fake providers, no networking. The
/// fake provider's [StorageProvider.sync] IS the exchange point: it
/// delivers `incoming` peer files after the flush, exactly where the real
/// anti-entropy overwrites local files with the peer's replica JSON
/// (whole-file LWW).

const _boardFile = 'task_boards/agent_world.json';

/// Fake [StorageProvider]: in-memory map, sync is a recorded no-op that
/// delivers injected peer files at the exchange point.
final class _FakeProvider extends StorageProvider {
  final Map<String, String> files = {};
  final List<String> syncLog = [];

  /// Peer files the anti-entropy exchange delivers (overwriting local
  /// ones) at the next [sync].
  final Map<String, String> incoming = {};

  /// Artificial exchange latency — used to prove the periodic tick skips
  /// while a cycle is in flight.
  Duration syncDelay = Duration.zero;

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
  }) async {
    syncLog.add(files.keys.join(','));
    if (syncDelay > Duration.zero) {
      await Future<void>.delayed(syncDelay);
    }
    files.addAll(incoming);
    incoming.clear();
  }

  @override
  Future<void> dispose() async {}
}

MeshStorageService _service({
  required final String selfId,
  required final _FakeProvider provider,
}) => MeshStorageService.forTest(
  storage: StorageService(provider),
  selfId: selfId,
)..attachTaskBoard(MeshTaskBoard(replicaId: selfId));

void main() {
  test('sync flushes the board file before anti-entropy and absorbs a '
      "peer's board file (ops path)", () async {
    final providerA = _FakeProvider();
    final providerB = _FakeProvider();
    final a = _service(selfId: 'device-a', provider: providerA);
    final b = _service(selfId: 'device-b', provider: providerB);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final boardA = a.taskBoard!;
    final boardB = b.taskBoard!;

    final taskId = boardA.requestTask(
      docId: 'doc-1',
      task: 'write the report',
      originPeerId: 'device-a',
      now: DateTime.utc(2026, 9, 6, 12),
    );

    expect(providerA.files, isEmpty); // Batched — nothing written yet.
    await a.sync();

    // The board file was flushed into storage BEFORE the exchange ran.
    expect(providerA.files.keys, contains(_boardFile));
    expect(providerA.syncLog.single, contains(_boardFile));

    // The exchange delivers A's file to B (whole-file LWW).
    providerB.incoming[_boardFile] = providerA.files[_boardFile]!;
    await b.sync();

    final record = boardB.taskOf(taskId);
    expect(record, isNotNull);
    expect(record!.task, 'write the report');
    expect(record.status, MeshTaskBoard.statusRequested);
    // A remote worker sees the request; the dispatcher does not.
    expect(boardB.pendingRequestsFor('doc-1', selfPeerId: 'device-b'), [
      record,
    ]);
    expect(boardB.pendingRequestsFor('doc-1', selfPeerId: 'device-a'), isEmpty);

    // B picks the task up; A converges through the same exchange. B's
    // board state only reaches the file at its next sync (the whole-file
    // exchange carries whoever flushed last), so B syncs before the copy.
    boardB.markRunning(taskId, now: DateTime.utc(2026, 9, 6, 12, 0, 1));
    await b.sync();
    providerA.incoming[_boardFile] = providerB.files[_boardFile]!;
    await a.sync();
    expect(boardA.taskOf(taskId)!.status, MeshTaskBoard.statusRunning);
  });

  test('absorbs a compacted peer board via snapshot adoption', () async {
    final providerA = _FakeProvider();
    final providerB = _FakeProvider();
    final a = _service(selfId: 'device-a', provider: providerA);
    final b = _service(selfId: 'device-b', provider: providerB);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final boardA = a.taskBoard!;
    final boardB = b.taskBoard!;
    final first = boardA.requestTask(
      docId: 'doc-1',
      task: 'first',
      originPeerId: 'device-a',
      now: DateTime.utc(2026, 9, 6, 12),
    );

    // Ops path: B sees the request through a plain file exchange.
    await a.sync();
    providerB.incoming[_boardFile] = providerA.files[_boardFile]!;
    await b.sync();
    expect(boardB.taskOf(first)!.status, MeshTaskBoard.statusRequested);

    // A writes far past the compaction threshold (1 + 130 tasks x 4 ops =
    // 524 > 512) and finishes the first task; the periodic policy compacts
    // at the end of the cycle and flushes the compacted state.
    for (var i = 0; i < 130; i++) {
      boardA.requestTask(
        docId: 'doc-batch',
        task: 'task $i',
        originPeerId: 'device-a',
        now: DateTime.utc(2026, 9, 6, 12, 0, 1),
      );
    }
    boardA.completeTask(
      first,
      verdict: const {'tokens': 42},
      now: DateTime.utc(2026, 9, 6, 12, 0, 2),
    );
    await a.sync();

    // The flushed file now carries the state in its snapshot: the world
    // log was compacted away.
    final compacted =
        jsonDecode(providerA.files[_boardFile]!) as Map<String, dynamic>;
    expect(compacted['snapshot'], isNotNull);
    expect((compacted['world'] as Map)['log'], isEmpty);

    // B recovers through snapshot adoption — ops alone cannot carry a
    // compacted peer file.
    providerB.incoming[_boardFile] = providerA.files[_boardFile]!;
    await b.sync();

    final restoredFirst = boardB.taskOf(first)!;
    expect(restoredFirst.status, MeshTaskBoard.statusCompleted);
    expect(restoredFirst.verdict, const {'tokens': 42});
    expect(boardB.tasksFor('doc-batch'), hasLength(130));
    expect(
      boardB.tasksFor('doc-batch').map((final r) => r.taskId),
      boardA.tasksFor('doc-batch').map((final r) => r.taskId),
    );
  });

  test('periodic sync ticks run sync cycles; in-flight cycles skip '
      'ticks', () async {
    final provider = _FakeProvider()
      ..syncDelay = const Duration(milliseconds: 80);
    final service = _service(selfId: 'device-a', provider: provider);
    addTearDown(service.dispose);

    expect(service.isPeriodicSyncRunning, isFalse);
    service.startPeriodicSync(interval: const Duration(milliseconds: 15));
    expect(service.isPeriodicSyncRunning, isTrue);

    // Ticks at 15/30/45/60ms all land while the first cycle is still in
    // flight (80ms exchange) — exactly one cycle runs.
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(provider.syncLog, hasLength(1));

    await Future<void>.delayed(const Duration(milliseconds: 220));
    expect(provider.syncLog.length, greaterThanOrEqualTo(2));

    service.stopPeriodicSync();
    expect(service.isPeriodicSyncRunning, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final afterStop = provider.syncLog.length;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(provider.syncLog, hasLength(afterStop)); // No more ticks.
  });

  test('stopPeriodicSync is idempotent; dispose cancels the timer '
      'cleanly', () async {
    final provider = _FakeProvider();
    final service = _service(selfId: 'device-a', provider: provider);

    // Never started — stopping must not throw.
    expect(service.stopPeriodicSync, returnsNormally);
    expect(service.isPeriodicSyncRunning, isFalse);

    service.startPeriodicSync(interval: const Duration(milliseconds: 10));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(provider.syncLog, isNotEmpty);

    await service.dispose();
    expect(service.isPeriodicSyncRunning, isFalse);
    final afterDispose = provider.syncLog.length;
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(provider.syncLog, hasLength(afterDispose));
  });
}
