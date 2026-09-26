import 'dart:convert';

import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Snapshot-aware sync tests (kernel compaction contract, ADR 0011 §1):
/// `DocReplica` snapshot passthroughs, snapshot-carrying persistence, the
/// store's snapshot-aware [DocReplicaStore.absorbRemote] (the 5.G3 gate —
/// a compacted peer file recovers a fresh store), `compactAll` policy,
/// and two-replica convergence across compaction.
const _docId = NodeId('doc-1');
final _now = DateTime.utc(2026, 9, 6, 12);
final _later = DateTime.utc(2026, 9, 6, 12, 0, 1);

final class _MemoryStorageProvider extends StorageProvider {
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
    final prefix = '${directoryPath.endsWith('/')
        ? directoryPath.substring(0, directoryPath.length - 1)
        : directoryPath}/';
    final names = files.keys
        .where((final path) => path.startsWith(prefix))
        .map((final path) => path.substring(prefix.length))
        .toList()
      ..sort();
    return [
      for (final name in names) FileEntry(name: name, isDirectory: false),
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

  FileOperationResult _write(final String path, final String content) {
    files[path] = content;
    return FileOperationResult(path: path);
  }
}

DocReplicaStore _store(
  final _MemoryStorageProvider provider, {
  final String actorId = 'actor-a',
}) => DocReplicaStore(storage: StorageService(provider), actorId: actorId);

Future<List<OpRecord>> _addBlock(
  final DocReplicaStore store,
  final String blockId,
  final String content,
) => store.edit(
  _docId,
  (final replica) => replica.addBlock(
    Block(id: NodeId(blockId), type: BlockType.paragraph, content: content),
    now: _now,
  ),
);

/// Two-way VV-diff exchange between [a] and [b] through the store seams.
Future<void> _exchange(final DocReplicaStore a, final DocReplicaStore b) async {
  await b.applyRemote(
    _docId,
    a.pendingOpsSince(_docId, b.versionVectorOf(_docId) ?? VersionVector.zero),
  );
  await a.applyRemote(
    _docId,
    b.pendingOpsSince(_docId, a.versionVectorOf(_docId) ?? VersionVector.zero),
  );
}

/// Drops [replica]'s serialized JSON into [provider] storage — simulates
/// a mesh file exchange of a peer's flushed replica file (a store-flushed
/// file goes out through `flush`/`compactAll`; out-of-band `compact()`
/// calls are persisted the same way by the caller).
void _putFile(final _MemoryStorageProvider provider, final DocReplica replica) {
  provider.files['doc_replicas/${replica.nodeId.value}.json'] =
      jsonEncode(replica.toJson());
}

/// Deterministic projection fingerprint for convergence assertions.
String jsonOf(final DocumentNode doc) => jsonEncode(doc.toJson());

void main() {
  group('DocReplica snapshot passthroughs', () {
    test('compact retires the log; a lagging peer recovers via the snapshot',
        () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..addBlock(_para('a1', 'from-a'), now: _now);
      final inSync = _replica('device-b')
        ..applyRemote(a.pendingOps, now: _later);

      // Peers that ops can still serve: no snapshot needed.
      expect(a.needsSnapshotFor(inSync.versionVector), isFalse);
      expect(a.needsSnapshotFor(VersionVector.zero), isFalse);

      final logLength = a.pendingOps.length;
      expect(a.compact(), logLength);
      expect(a.pendingOps, isEmpty);
      // The log is gone under the peers: only a snapshot can recover one
      // that does not already hold the pre-compaction ops; a covered peer
      // needs nothing.
      expect(a.needsSnapshotFor(VersionVector.zero), isTrue);
      expect(a.needsSnapshotFor(inSync.versionVector), isFalse);

      final snapshot = a.snapshotFor();
      final lagging = _replica('device-c');
      expect(lagging.adoptSnapshot(snapshot), isTrue);
      expect(lagging.document(), a.document());
      // Idempotent: the same snapshot carries no unseen events anymore.
      expect(lagging.adoptSnapshot(snapshot), isFalse);

      // The watermark absorbed the snapshot's createdAt: local ops issued
      // afterwards order strictly after the snapshot content.
      final ops = lagging.addBlock(_para('c1', 'mine'), now: _now);
      expect(ops, isNotEmpty);
      for (final op in ops) {
        expect(op.hlc > snapshot.createdAt, isTrue, reason: '${op.hlc}');
      }
    });

    test('local pending ops beyond the snapshot base survive adoption', () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..addBlock(_para('a1', 'from-a'), now: _now);
      final snapshot = a.snapshotFor();

      // b issues local ops it has never synced, THEN adopts the older
      // remote snapshot.
      final b = _replica('device-b');
      final localOps = b.addBlock(_para('b1', 'from-b'), now: _now);
      expect(b.pendingOps, localOps);
      expect(b.adoptSnapshot(snapshot), isTrue);

      // Local ops re-folded on top of the snapshot state: merge of both.
      expect(
        b.document().blocks.map((final block) => block.id.value),
        containsAll(['a1', 'b1']),
      );
      expect(b.blockText(const NodeId('a1')), 'from-a');
      expect(b.blockText(const NodeId('b1')), 'from-b');
      // Local ops are still pending delta-shipping beyond the base.
      expect(b.pendingOps.map((final op) => op.opId), containsAll([
        for (final op in localOps) op.opId,
      ]));

      // A third replica folding both sides' ops lands on b's projection.
      final c = _replica('device-c')
        ..applyRemote(a.pendingOps, now: _later)
        ..applyRemote(b.pendingOps, now: _later);
      expect(jsonOf(c.document()), jsonOf(b.document()));
    });
  });

  group('DocReplica snapshot persistence', () {
    test('toJson carries the snapshot; fromJson restores state and watermark',
        () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..addBlock(_para('b1', 'Body'), now: _now);
      expect(a.compact(), greaterThan(0));
      final createdAt = a.snapshotFor().createdAt;

      final json =
          jsonDecode(jsonEncode(a.toJson())) as Map<String, dynamic>;
      expect(json.containsKey('snapshot'), isTrue);

      final restored = DocReplica.fromJson(json);
      expect(restored.document(), a.document());
      expect(restored.pendingOps, isEmpty);
      // The snapshot cache re-arms across a restore, so the file keeps
      // carrying it (a same-actor file's VV already covers the snapshot
      // base — the kernel refuses a state adoption but the cache holds).
      expect(restored.toJson().containsKey('snapshot'), isTrue);
      // A restored compacted replica can only serve snapshots.
      expect(restored.needsSnapshotFor(VersionVector.zero), isTrue);

      // HLC watermark >= snapshot.createdAt: a local op issued after the
      // restore with the same wall clock orders strictly after it.
      final ops = restored.appendText(const NodeId('b1'), '!', now: _now);
      expect(ops, hasLength(1));
      expect(ops.single.hlc > createdAt, isTrue, reason: '${ops.single.hlc}');

      // And the restored replica still serves lagging peers.
      final peer = _replica('device-b');
      expect(peer.adoptSnapshot(restored.snapshotFor()), isTrue);
      expect(jsonOf(peer.document()), jsonOf(restored.document()));
    });

    test('old-format JSON without a snapshot key restores as before', () {
      final a = _replica('device-a')
        ..createNode(now: _now)
        ..addBlock(_para('b1', 'Body'), now: _now)
        ..compact();

      final json = jsonDecode(jsonEncode(a.toJson())) as Map<String, dynamic>
        ..remove('snapshot');
      final restored = DocReplica.fromJson(json);
      expect(restored.document(), a.document());
      expect(restored.toJson().containsKey('snapshot'), isFalse);
      // The kernel doc's own state still serves snapshots on demand.
      expect(restored.needsSnapshotFor(VersionVector.zero), isTrue);
      final peer = _replica('device-b');
      expect(peer.adoptSnapshot(restored.snapshotFor()), isTrue);
      expect(jsonOf(peer.document()), jsonOf(restored.document()));
    });

    test('store restart: open restores a compacted replica with its snapshot',
        () async {
      final provider = _MemoryStorageProvider();
      final first = _store(provider);
      await first.open(_docId);
      await _addBlock(first, 'b1', 'hello');
      first.replicaOf(_docId)!.compact();
      _putFile(provider, first.replicaOf(_docId)!);

      final second = _store(provider);
      final replica = await second.open(_docId);
      expect(replica.actorId, 'actor-a');
      expect(replica.blockText(const NodeId('b1')), 'hello');
      expect(replica.pendingOps, isEmpty);
      expect(replica.needsSnapshotFor(VersionVector.zero), isTrue);
      // The restored watermark keeps local ops issuing.
      final ops = await second.edit(
        _docId,
        (final r) => r.appendText(const NodeId('b1'), '!', now: _later),
      );
      expect(ops, isNotEmpty);
      expect(replica.blockText(const NodeId('b1')), 'hello!');
      await second.dispose();
    });

    test('open derives a compacted peer file through its snapshot', () async {
      final providerA = _MemoryStorageProvider();
      final a = _store(providerA);
      await a.open(_docId);
      await _addBlock(a, 'b1', 'peer');
      a.replicaOf(_docId)!.compact();

      // A's compacted file lands in B's empty storage; B's actor differs,
      // so open re-derives — from the snapshot, since the log is empty.
      final providerB = _MemoryStorageProvider();
      _putFile(providerB, a.replicaOf(_docId)!);
      final b = _store(providerB, actorId: 'actor-b');
      final replica = await b.open(_docId);
      expect(replica.actorId, 'actor-b'); // NOT the file's actor.
      expect(replica.blockText(const NodeId('b1')), 'peer');
      // And the derived replica keeps issuing as its own actor.
      final ops = await _addBlock(b, 'a1', 'local');
      expect(ops.map((final op) => op.actorId), {'actor-b'});
      await b.dispose();
    });
  });

  group('DocReplicaStore snapshot-aware absorb', () {
    test('compacted peer file recovers a fresh store through absorbRemote',
        () async {
      final providerA = _MemoryStorageProvider();
      final a = _store(providerA);
      await a.open(_docId);
      await _addBlock(a, 'a1', 'from-a');
      await a.flush();

      // B converges with A through ordinary op exchange, then A compacts.
      final storageB = _MemoryStorageProvider();
      final b = _store(storageB, actorId: 'actor-b');
      await b.open(_docId);
      await b.applyRemote(
        _docId,
        a.pendingOpsSince(_docId, VersionVector.zero),
      );
      expect(
        jsonOf(b.replicaOf(_docId)!.document()),
        jsonOf(a.replicaOf(_docId)!.document()),
      );
      final replicaA = a.replicaOf(_docId)!;
      expect(replicaA.compact(), greaterThan(0));
      expect(a.needsSnapshotFor(_docId, VersionVector.zero), isTrue);

      // A's compacted file (state only under `snapshot`) lands in fresh
      // C's storage via mesh file exchange. C has opened the (unknown)
      // doc: an empty replica, no ops to fold anywhere.
      final providerC = _MemoryStorageProvider();
      final c = _store(providerC, actorId: 'actor-c');
      await c.open(_docId);
      expect(c.replicaOf(_docId)!.document().blocks, isEmpty);
      _putFile(providerC, replicaA);

      final applied = await c.absorbRemote();
      expect(applied, 0); // Nothing to fold — the snapshot carried it all.
      expect(
        jsonOf(c.replicaOf(_docId)!.document()),
        jsonOf(replicaA.document()),
      );
      expect(c.replicaOf(_docId)!.blockText(const NodeId('a1')), 'from-a');
      await c.flush();
      final persisted =
          jsonDecode(providerC.files['doc_replicas/doc-1.json']!)
              as Map<String, dynamic>;
      expect(persisted.containsKey('snapshot'), isTrue);
      // Restart keeps the recovered projection.
      final reopened = _store(providerC, actorId: 'actor-c');
      expect(
        (await reopened.open(_docId)).blockText(const NodeId('a1')),
        'from-a',
      );
      await reopened.dispose();
    });

    test('absorbRemote folds tail ops on top of an adopted snapshot',
        () async {
      final providerA = _MemoryStorageProvider();
      final a = _store(providerA);
      await a.open(_docId);
      await _addBlock(a, 'a1', 'from-a');
      a.replicaOf(_docId)!.compact();
      await _addBlock(a, 'a2', 'tail'); // Post-compaction edits.

      final providerC = _MemoryStorageProvider();
      final c = _store(providerC, actorId: 'actor-c');
      await c.open(_docId);
      _putFile(providerC, a.replicaOf(_docId)!);

      final applied = await c.absorbRemote();
      expect(applied, greaterThan(0)); // The a2 tail ops folded...
      expect(
        jsonOf(c.replicaOf(_docId)!.document()),
        jsonOf(a.replicaOf(_docId)!.document()),
      );
      expect(
        c.replicaOf(_docId)!.document().blocks.map((b) => b.id.value),
        containsAll(['a1', 'a2']), // ...and the snapshot carried a1.
      );
      await c.flush();

      // Idempotent: absorbing the same file again adopts nothing and
      // leaves nothing dirty.
      expect(await c.absorbRemote(), 0);
      expect(await c.flush(), 0);
      await c.dispose();
    });

    test('compactAll compacts only above-threshold replicas; idempotent',
        () async {
      final provider = _MemoryStorageProvider();
      final store = _store(provider);
      await store.open(_docId);
      await _addBlock(store, 'b1', 'seed');
      for (var i = 0; i < 12; i++) {
        await store.edit(
          _docId,
          (final r) => r.appendText(
            const NodeId('b1'),
            ' chunk$i',
            now: _later,
          ),
        );
      }
      // A second doc stays under the threshold.
      const otherId = NodeId('doc-2');
      await store.edit(
        otherId,
        (final r) => r.addBlock(
          const Block(
            id: NodeId('small'),
            type: BlockType.paragraph,
            content: 'tiny',
          ),
          now: _now,
        ),
      );

      expect(await store.compactAll(maxLogOps: 10), 1);
      final compacted = store.replicaOf(_docId)!;
      expect(compacted.pendingOps, isEmpty);
      expect(
        compacted.blockText(const NodeId('b1')),
        'seed chunk0 chunk1 chunk2 chunk3 chunk4 chunk5 chunk6 chunk7 '
        'chunk8 chunk9 chunk10 chunk11',
      );
      expect(store.replicaOf(otherId)!.pendingOps, isNotEmpty);
      final persistedDoc1 =
          jsonDecode(provider.files['doc_replicas/doc-1.json']!)
              as Map<String, dynamic>;
      expect(persistedDoc1.containsKey('snapshot'), isTrue);

      // Idempotent: a compacted log no longer exceeds the threshold.
      expect(await store.compactAll(maxLogOps: 10), 0);
      // Restart restores the compacted projection.
      final second = _store(provider);
      final replica = await second.open(_docId);
      expect(replica.pendingOps, isEmpty);
      expect(replica.blockText(const NodeId('b1')), compacted
          .blockText(const NodeId('b1')));
      await second.dispose();
    });
  });

  group('convergence across compaction', () {
    test('VV-diff exchange still converges after one side compacts',
        () async {
      final a = _store(_MemoryStorageProvider());
      final b = _store(_MemoryStorageProvider(), actorId: 'actor-b');
      await a.open(_docId);
      await b.open(_docId);
      await _addBlock(a, 'a1', 'one');
      await _exchange(a, b);

      // A compacts while B holds everything so far; both keep editing.
      a.replicaOf(_docId)!.compact();
      await _addBlock(a, 'a2', 'two');
      await b.edit(
        _docId,
        (final replica) => replica.addBlock(
          const Block(
            id: NodeId('b1'),
            type: BlockType.paragraph,
            content: 'from-b',
          ),
          now: _now,
        ),
      );
      await _exchange(a, b);
      await _exchange(a, b);

      expect(
        jsonOf(a.replicaOf(_docId)!.document()),
        jsonOf(b.replicaOf(_docId)!.document()),
      );
      expect(
        a.replicaOf(_docId)!
            .document()
            .blocks
            .map((final block) => block.id.value),
        containsAll(['a1', 'a2', 'b1']),
      );
      // Idempotent: re-exchange ships nothing new.
      expect(
        a.pendingOpsSince(_docId, b.versionVectorOf(_docId)!),
        isEmpty,
      );
      expect(
        b.pendingOpsSince(_docId, a.versionVectorOf(_docId)!),
        isEmpty,
      );
    });

    test('compacted side serves the snapshot to a lagging peer via the seam',
        () async {
      final a = _store(_MemoryStorageProvider());
      final b = _store(_MemoryStorageProvider(), actorId: 'actor-b');
      await a.open(_docId);
      await b.open(_docId);
      await _addBlock(a, 'a1', 'from-a');

      // B never heard about a1; A compacts before the reconnect.
      a.replicaOf(_docId)!.compact();
      expect(
        a.needsSnapshotFor(
          _docId,
          b.versionVectorOf(_docId) ?? VersionVector.zero,
        ),
        isTrue,
      );

      // The mesh layer ships the snapshot; B adopts it through the seam.
      final snapshot = a.snapshotFor(_docId);
      expect(snapshot, isNotNull);
      expect(b.adoptSnapshot(_docId, snapshot!), isTrue);
      expect(b.replicaOf(_docId)!.blockText(const NodeId('a1')), 'from-a');
      expect(await b.flush(), 1); // Adoption marked B dirty.
      expect(b.adoptSnapshot(_docId, snapshot), isFalse); // Idempotent.

      // Post-compaction ops flow as usual and the pair converges.
      await _addBlock(a, 'a2', 'tail');
      await _exchange(a, b);
      expect(
        jsonOf(a.replicaOf(_docId)!.document()),
        jsonOf(b.replicaOf(_docId)!.document()),
      );
      await a.dispose();
      await b.dispose();
    });
  });
}

DocReplica _replica(final String actorId) =>
    DocReplica(nodeId: _docId, actorId: actorId);

Block _para(final String id, final String content) =>
    Block(id: NodeId(id), type: BlockType.paragraph, content: content);
