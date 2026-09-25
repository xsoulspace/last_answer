import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Task H — the doc replica store becomes LIVE: proving that the app's
/// mesh construction point ([StorageBackendsNotifier.ensureMeshService])
/// attaches ONE [DocReplicaStore] + [ActorRoster] to the replica, and
/// that agent-doc perm ops issued into that store actually ship through
/// the mesh sync cycle. Runs against a fake in-memory service (the
/// notifier's `meshServiceOpener` test seam) — no networking.

final _now = DateTime.utc(2026, 9, 7, 12);

/// Fake [StorageProvider]: in-memory map, sync is a recorded no-op.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    StorageBackendsNotifier.meshServiceOpener = null;
    StorageBackendsNotifier.onSyncCycle = null;
  });

  test(
    'ensureMeshService attaches a live doc replica store and actor roster; '
    'ops in the store ship through the sync cycle',
    () async {
      final provider = _FakeProvider();
      final service = MeshStorageService.forTest(
        storage: StorageService(provider),
        selfId: 'peer-1',
      );
      StorageBackendsNotifier.meshServiceOpener =
          ({
            required final String storePath,
            required final String peerId,
            final Uri? relayEndpoint,
          }) async => service;
      final notifier = StorageBackendsNotifier.instance;
      addTearDown(notifier.leaveMesh);

      await notifier.load();
      await notifier.setEnabled(StorageBackendId.mesh, value: true);
      final opened = await notifier.ensureMeshService();

      expect(identical(opened, service), isTrue);
      expect(notifier.docReplicaStore, isNotNull);
      expect(notifier.actorRoster, isNotNull);
      // attachRoster forces the roster replica id to the pairing peer id.
      expect(notifier.actorRoster!.replicaId, 'peer-1');

      // The store participates in the sync cycle: pending doc ops flush
      // into storage (one file per doc) and the roster rides along.
      const docId = NodeId('agent-doc-1');
      await notifier.docReplicaStore!.edit(
        docId,
        (final replica) => replica.addBlock(
          const Block(
            id: NodeId('b1'),
            type: BlockType.paragraph,
            content: 'streamed',
          ),
          now: _now,
        ),
      );
      notifier.actorRoster!.upsert(
        const ActorProfile(actorId: 'afm-coder', displayName: 'AFM Coder'),
      );
      await service.sync();

      expect(
        provider.files.keys,
        contains('doc_replicas/agent-doc-1.json'),
        reason: 'agent-doc ops land in a synced doc replica file',
      );
      expect(
        provider.files.keys,
        contains('actor_rosters/peer-1.json'),
        reason: 'the roster is flushed as durable kernel state',
      );
    },
  );

  test(
    'leaveMesh flushes the live store before the replica dies; a rebuilt '
    'replica re-attaches a fresh store and the same roster',
    () async {
      final provider = _FakeProvider();
      final service = MeshStorageService.forTest(
        storage: StorageService(provider),
        selfId: 'peer-2',
      );
      StorageBackendsNotifier.meshServiceOpener =
          ({
            required final String storePath,
            required final String peerId,
            final Uri? relayEndpoint,
          }) async => service;
      final notifier = StorageBackendsNotifier.instance;
      addTearDown(notifier.leaveMesh);

      await notifier.load();
      await notifier.setEnabled(StorageBackendId.mesh, value: true);
      await notifier.ensureMeshService();
      const docId = NodeId('agent-doc-2');
      await notifier.docReplicaStore!.edit(
        docId,
        (final replica) => replica.addBlock(
          const Block(
            id: NodeId('b1'),
            type: BlockType.paragraph,
            content: 'streamed',
          ),
          now: _now,
        ),
      );
      final roster = notifier.actorRoster!;

      await notifier.leaveMesh();

      // Batched persistence flushed on teardown of the replica — the ops
      // never depended on a sync being reachable.
      expect(provider.files.keys, contains('doc_replicas/agent-doc-2.json'));

      // A rebuilt replica gets a FRESH store (the old storage died with
      // the replica) and the SAME roster (durable kernel state).
      await notifier.ensureMeshService();
      expect(notifier.docReplicaStore, isNotNull);
      expect(
        identical(notifier.docReplicaStore, roster),
        isFalse,
        reason: 'the store is per-replica, the roster is not',
      );
      expect(notifier.actorRoster, same(roster));
    },
  );
}
