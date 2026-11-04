import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/planning_board_replica.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Mesh integration tests for the planning-board seam (the boards
/// program's sync lane — the task-board pattern applied to planning
/// cards): the sync cycle flushes the attached
/// [PlanningBoardReplica] into `planning_boards/<boardId>.json` before
/// anti-entropy and folds a peer's board file after — ops path AND
/// snapshot path.
///
/// Everything runs against in-memory fake providers, no networking.
const _boardFile = 'planning_boards/product.json';

/// Fake [StorageProvider]: in-memory map; sync delivers injected peer
/// files at the exchange point (whole-file LWW).
final class _FakeProvider extends StorageProvider {
  final Map<String, String> files = {};

  /// Peer files the anti-entropy exchange delivers at the next [sync].
  final Map<String, String> incoming = {};

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
    files.addAll(incoming);
    incoming.clear();
  }

  @override
  Future<void> dispose() async {}
}

MeshStorageService _service({
  required final String selfId,
  required final _FakeProvider provider,
}) {
  final service = MeshStorageService.forTest(
    storage: StorageService(provider),
    selfId: selfId,
  );
  service.attachPlanningBoard(PlanningBoardReplica(replicaId: selfId));
  return service;
}

void main() {
  test('sync flushes the board file and folds a peer board (ops path)',
      () async {
    final providerA = _FakeProvider();
    final providerB = _FakeProvider();
    final a = _service(selfId: 'device-a', provider: providerA);
    final b = _service(selfId: 'device-b', provider: providerB);
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    final boardA = a.planningBoard!;
    final boardB = b.planningBoard!;
    boardA.addCard(title: 'from a', column: 'backlog', rank: 'm');
    boardB.addCard(title: 'from b', column: 'doing', rank: 'a');

    // A flushes, the exchange hands A's file to B, B folds it.
    await a.sync();
    providerB.incoming.addAll(providerA.files);
    await b.sync();

    expect(boardB.cardOf(boardA.allCards.single.cardId)!.title, 'from a');
    expect(providerB.files.keys, contains(_boardFile));
  });

  test('a compacted peer file converges through the snapshot path',
      () async {
    final providerA = _FakeProvider();
    final providerB = _FakeProvider();
    final a = _service(selfId: 'device-a', provider: providerA);
    final b = _service(selfId: 'device-b', provider: providerB);
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    final boardA = a.planningBoard!;
    final boardB = b.planningBoard!;
    final id = boardA.addCard(title: 'compact me', column: 'backlog');
    boardA.compact(maxLogOps: 0); // the snapshot IS the state carrier

    await a.sync();
    providerB.incoming.addAll(providerA.files);
    await b.sync();

    expect(boardB.cardOf(id)!.title, 'compact me');
    expect(boardB.pendingOps, isEmpty);
  });

  test('one exchange converges both boards two ways', () async {
    final providerA = _FakeProvider();
    final providerB = _FakeProvider();
    final a = _service(selfId: 'device-a', provider: providerA);
    final b = _service(selfId: 'device-b', provider: providerB);
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    final boardA = a.planningBoard!;
    final boardB = b.planningBoard!;
    boardA.addCard(title: 'from a', column: 'backlog', rank: 'm');
    boardB.addCard(title: 'from b', column: 'backlog', rank: 'n');

    await a.sync();
    providerB.incoming.addAll(providerA.files);
    await b.sync(); // B folds A, then ships the merged file back
    providerA.incoming.addAll(providerB.files);
    await a.sync();

    final aTitles = boardA.allCards.map((final c) => c.title).toSet();
    final bTitles = boardB.allCards.map((final c) => c.title).toSet();
    expect(aTitles, {'from a', 'from b'});
    expect(aTitles, bTitles);
    expect(boardA.allCards.length, boardB.allCards.length);
  });
}
