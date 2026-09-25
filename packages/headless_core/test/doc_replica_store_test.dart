import 'dart:convert';
import 'dart:math';

import 'package:headless_core/headless_core.dart';
import 'package:test/test.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// DocReplicaStore tests (ADR 0005 §1 — docs event-sourced over the
/// kernel, persisted through `universal_storage_interface`'s
/// [StorageService]): batched persistence, the op-exchange seams
/// (`pendingOpsSince` / `applyRemote`), two-replica convergence over
/// shuffled delivery, reconnect catch-up, and JSON persistence across a
/// restart.
const _docId = NodeId('doc-1');
final _now = DateTime.utc(2026, 9, 6, 12);
final _later = DateTime.utc(2026, 9, 6, 12, 0, 1);

/// Minimal in-memory [StorageProvider] — no I/O, counts writes so the
/// batching contract is observable, and allows injecting foreign files
/// (simulating what a mesh anti-entropy cycle leaves in storage).
final class _MemoryStorageProvider extends StorageProvider {
  final Map<String, String> files = {};
  int writeCount = 0;

  FileOperationResult _write(final String path, final String content) {
    files[path] = content;
    writeCount++;
    return FileOperationResult(path: path);
  }

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

/// Two-way delta exchange between [a] and [b] through the store seams:
/// VV diff → ops → applyRemote, optionally in shuffled delivery order.
Future<void> _exchange(
  final DocReplicaStore a,
  final DocReplicaStore b,
  final NodeId docId, {
  final Random? rng,
}) async {
  var ops = a.pendingOpsSince(
    docId,
    b.versionVectorOf(docId) ?? VersionVector.zero,
  );
  if (rng != null) ops = [...ops]..shuffle(rng);
  await b.applyRemote(docId, ops);

  var back = b.pendingOpsSince(
    docId,
    a.versionVectorOf(docId) ?? VersionVector.zero,
  );
  if (rng != null) back = [...back]..shuffle(rng);
  await a.applyRemote(docId, back);
}

void main() {
  group('DocReplicaStore', () {
    test('open births a replica on empty storage; flush persists it', () async {
      final provider = _MemoryStorageProvider();
      final store = _store(provider);
      final replica = await store.open(_docId);
      expect(replica.actorId, 'actor-a');
      expect(provider.files, isEmpty); // Nothing written yet — batched.

      await _addBlock(store, 'b1', 'hello');
      expect(provider.files, isEmpty); // Still batched.
      expect(await store.flush(), 1);
      expect(provider.files, hasLength(1));
      expect(provider.files.keys.single, 'doc_replicas/doc-1.json');
      await store.dispose();
    });

    test('edits are batched: many ops, one file write per flush', () async {
      final provider = _MemoryStorageProvider();
      final store = _store(provider);
      await _addBlock(store, 'b1', 'one');
      await _addBlock(store, 'b2', 'two');
      await store.edit(
        _docId,
        (final replica) =>
            replica.appendText(const NodeId('b1'), '!', now: _later),
      );
      expect(provider.writeCount, 0);
      await store.flush();
      expect(provider.writeCount, 1);
      expect(store.replicaOf(_docId)!.pendingOps, hasLength(7));
      await store.dispose();
    });

    test('restart: a new store instance restores the projection', () async {
      final provider = _MemoryStorageProvider();
      final first = _store(provider);
      await _addBlock(first, 'b1', 'hello');
      await first.flush();
      await first.dispose();

      final second = _store(provider);
      final replica = await second.open(_docId);
      final doc = replica.document();
      expect(doc.blocks, hasLength(1));
      expect(doc.blocks.single.id, const NodeId('b1'));
      expect(replica.blockText(const NodeId('b1')), 'hello');
      // Restored watermark keeps local ordering: new ops still issue.
      await _addBlock(second, 'b2', 'world');
      expect(
        replica.pendingOps.where((final op) => op.actorId == 'actor-a'),
        isNotEmpty,
      );
      await second.flush();
    });

    test('two stores converge on shuffled op delivery', () async {
      final a = _store(_MemoryStorageProvider());
      final b = _store(_MemoryStorageProvider(), actorId: 'actor-b');
      await a.open(_docId);
      await b.open(_docId);

      await _addBlock(a, 'a1', 'alpha');
      await _addBlock(a, 'a2', 'beta');
      await b.edit(
        _docId,
        (final replica) => replica.addBlock(
          const Block(
            id: NodeId('b1'),
            type: BlockType.paragraph,
            content: 'gamma',
          ),
          now: _now,
        ),
      );
      await a.edit(
        _docId,
        (final replica) =>
            replica.appendText(const NodeId('a1'), '!', now: _later),
      );

      // Several rounds of two-way exchange with shuffled delivery.
      final rng = Random(42);
      await _exchange(a, b, _docId, rng: rng);
      await _exchange(a, b, _docId, rng: rng);

      final docA = a.replicaOf(_docId)!.document();
      final docB = b.replicaOf(_docId)!.document();
      expect(jsonOf(docA), jsonOf(docB));
      expect(
        docA.blocks.map((final block) => block.id.value),
        containsAll(['a1', 'a2', 'b1']),
      );
      // Idempotent: re-exchanging ships nothing new.
      expect(a.pendingOpsSince(_docId, b.versionVectorOf(_docId)!), isEmpty);
      expect(b.pendingOpsSince(_docId, a.versionVectorOf(_docId)!), isEmpty);
    });

    test('reconnect catch-up: offline replica catches up', () async {
      final a = _store(_MemoryStorageProvider());
      final b = _store(_MemoryStorageProvider(), actorId: 'actor-b');
      await a.open(_docId);
      await b.open(_docId);
      await _exchange(a, b, _docId); // Both in sync, then B goes offline.

      // A keeps editing while B is unreachable (streamed text).
      await _addBlock(a, 'a1', 'streaming');
      for (var i = 0; i < 5; i++) {
        await a.edit(
          _docId,
          (final replica) =>
              replica.appendText(const NodeId('a1'), ' chunk$i', now: _later),
        );
      }

      // B reconnects and catches up through the seams.
      await _exchange(a, b, _docId);
      final docA = a.replicaOf(_docId)!.document();
      final docB = b.replicaOf(_docId)!.document();
      expect(jsonOf(docB), jsonOf(docA));
      expect(
        docB.blocks.single.content,
        'streaming chunk0 chunk1 chunk2 chunk3 chunk4',
      );
    });

    test('absorbRemote folds peer ops left in storage by mesh sync', () async {
      final providerA = _MemoryStorageProvider();
      final a = _store(providerA);
      await a.open(_docId);
      await _addBlock(a, 'a1', 'from-a');
      await a.flush();

      // B is a peer that received A's ops and edited on top; its replica
      // JSON lands in A's storage through mesh file sync (whole-file LWW).
      final storageB = _MemoryStorageProvider();
      final b = _store(storageB, actorId: 'actor-b');
      await b.open(_docId);
      await b.applyRemote(
        _docId,
        a.pendingOpsSince(_docId, VersionVector.zero),
      );
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
      await b.flush();
      providerA.files['doc_replicas/doc-1.json'] =
          storageB.files['doc_replicas/doc-1.json']!;

      final applied = await a.absorbRemote();
      expect(applied, greaterThan(0));
      final docA = a.replicaOf(_docId)!.document();
      expect(
        docA.blocks.map((final block) => block.id.value),
        containsAll(['a1', 'b1']),
      );
      expect(a.replicaOf(_docId)!.actorId, 'actor-a'); // Identity kept.
      // Idempotent: absorbing the same files again applies nothing new.
      expect(await a.absorbRemote(), 0);
      await a.dispose();
    });

    test('open derives a peer file into a local-actor replica', () async {
      final providerA = _MemoryStorageProvider();
      final storageB = _MemoryStorageProvider();
      final b = _store(storageB, actorId: 'actor-b');
      await b.open(_docId);
      await b.edit(
        _docId,
        (final replica) => replica.addBlock(
          const Block(
            id: NodeId('b1'),
            type: BlockType.paragraph,
            content: 'peer',
          ),
          now: _now,
        ),
      );
      await b.flush();
      providerA.files['doc_replicas/doc-1.json'] =
          storageB.files['doc_replicas/doc-1.json']!;

      final a = _store(providerA);
      final replica = await a.open(_docId);
      expect(replica.actorId, 'actor-a'); // NOT the file's actor.
      expect(replica.blockText(const NodeId('b1')), 'peer');
      // And the derived replica keeps issuing as its own actor.
      final ops = await _addBlock(a, 'a1', 'local');
      expect(ops.map((final op) => op.actorId), {'actor-a'});
      await a.dispose();
    });

    test('edit on an unopened doc opens it lazily', () async {
      final provider = _MemoryStorageProvider();
      final store = _store(provider);
      await _addBlock(store, 'b1', 'lazy');
      expect(store.replicaOf(_docId), isNotNull);
      await store.flush();
    });

    test('corrupt replica JSON fails loudly', () async {
      final provider = _MemoryStorageProvider()
        ..files['doc_replicas/doc-1.json'] = '{not json';
      final store = _store(provider);
      await expectLater(store.open(_docId), throwsFormatException);
    });
  });
}

/// Deterministic projection fingerprint for convergence assertions.
String jsonOf(final DocumentNode doc) => jsonEncode(doc.toJson());
