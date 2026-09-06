import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Attach-seam tests for [MeshStorageService.attachDocSync] (PLAN 5b):
/// the sync cycle flushes attached [DocReplicaStore]s before anti-entropy
/// and absorbs remote doc data after — exercised here against a fake
/// in-memory provider, no real networking.

const _docId = NodeId('doc-1');
final _now = DateTime.utc(2026, 9, 6, 12);

/// Fake [StorageProvider]: in-memory map, sync is a recorded no-op, and
/// tests inject "remote" files to simulate what anti-entropy delivers.
final class _FakeProvider extends StorageProvider {
  final Map<String, String> files = {};
  final List<String> syncLog = []; // 'flush' markers by the service, etc.

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
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test('sync flushes pending doc ops into storage before anti-entropy',
      () async {
    final provider = _FakeProvider();
    final service = MeshStorageService.forTest(
      storage: StorageService(provider),
      selfId: 'device-a',
    );
    final store = DocReplicaStore(
      storage: service.storage,
      actorId: 'actor-a',
    );
    service.attachDocSync(store);
    await store.open(_docId);
    await store.edit(
      _docId,
      (final replica) => replica.addBlock(
        const Block(
          id: NodeId('b1'),
          type: BlockType.paragraph,
          content: 'streamed',
        ),
        now: _now,
      ),
    );
    expect(provider.files, isEmpty); // Batched — nothing written yet.

    await service.sync();

    // The replica file was flushed into storage and the provider's sync
    // (anti-entropy) ran AFTER the flush landed.
    expect(provider.syncLog, hasLength(1));
    expect(
      provider.syncLog.single,
      contains('doc_replicas/doc-1.json'),
    );
    final replica = store.replicaOf(_docId)!;
    expect(replica.blockText(const NodeId('b1')), 'streamed');
    await store.dispose();
  });

  test('sync absorbs remote doc data delivered by anti-entropy', () async {
    final provider = _FakeProvider();
    final service = MeshStorageService.forTest(
      storage: StorageService(provider),
      selfId: 'device-a',
    );
    final store = DocReplicaStore(
      storage: service.storage,
      actorId: 'actor-a',
    );
    service.attachDocSync(store);
    await store.open(_docId);
    await service.sync(); // First cycle: flush of the (empty) replica.

    // A peer's replica JSON lands in storage — what the mesh exchange
    // leaves behind (whole-file LWW over the per-doc replica file).
    final peerProvider = _FakeProvider();
    final peer = DocReplicaStore(
      storage: StorageService(peerProvider),
      actorId: 'actor-b',
    );
    await peer.open(_docId);
    await peer.edit(
      _docId,
      (final replica) => replica.addBlock(
        const Block(
          id: NodeId('pb1'),
          type: BlockType.paragraph,
          content: 'from-peer',
        ),
        now: _now,
      ),
    );
    await peer.flush();
    provider.files['doc_replicas/doc-1.json'] =
        peerProvider.files['doc_replicas/doc-1.json']!;

    await service.sync();

    expect(store.replicaOf(_docId)!.blockText(const NodeId('pb1')),
        'from-peer');
    expect(store.replicaOf(_docId)!.actorId, 'actor-a'); // Identity kept.
    await store.dispose();
  });

  test('multiple stores flush and absorb in one cycle', () async {
    final provider = _FakeProvider();
    final service = MeshStorageService.forTest(
      storage: StorageService(provider),
      selfId: 'device-a',
    );
    final storeA = DocReplicaStore(
      storage: service.storage,
      actorId: 'actor-a',
    );
    final storeB = DocReplicaStore(
      storage: service.storage,
      actorId: 'actor-b',
    );
    service
      ..attachDocSync(storeA)
      ..attachDocSync(storeB);
    await storeA.open(const NodeId('doc-a'));
    await storeB.open(const NodeId('doc-b'));
    await storeA.edit(
      const NodeId('doc-a'),
      (final replica) => replica.addBlock(
        const Block(
          id: NodeId('ba1'),
          type: BlockType.paragraph,
          content: 'a',
        ),
        now: _now,
      ),
    );
    await storeB.edit(
      const NodeId('doc-b'),
      (final replica) => replica.addBlock(
        const Block(
          id: NodeId('bb1'),
          type: BlockType.paragraph,
          content: 'b',
        ),
        now: _now,
      ),
    );
    await service.sync();
    expect(provider.files, contains('doc_replicas/doc-a.json'));
    expect(provider.files, contains('doc_replicas/doc-b.json'));
    await storeA.dispose();
    await storeB.dispose();
  });
}
