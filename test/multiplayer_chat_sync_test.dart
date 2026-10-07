import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Multiplayer-chat convergence proof (the recommendation this gate
/// exists for): two devices, one chat, LAN-mesh semantics — each side
/// holds its own [DocReplicaStore] over its own [MeshStorageService];
/// the sync cycle flushes replica files into the shared medium and folds
/// whatever arrived; the kernel folds the union of ops and both
/// projections converge. No real networking: the fake provider is the
/// anti-entropy medium (Wi-Fi's stand-in).
///
/// The user-facing loop proven here: device A (session owner) and device
/// B (peer) open the SAME chat doc; B composes a message and edits
/// transport metadata; A streams a checkpointed reply and claims
/// ownership; BOTH sides read the same converged transcript.

const _docId = NodeId('chat-shared');
final _now = DateTime.utc(2026, 10, 7, 12);

/// In-memory shared medium: whatever one device flushes, the other sees
/// on its next sync (whole-file exchange — the LAN mesh's semantics).
final class _SharedMedium {
  final Map<String, String> files = {};
}

final class _MeshProvider extends StorageProvider {
  _MeshProvider(this.medium);

  final _SharedMedium medium;

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
    // Whole-file exchange per path — the same last-flush-wins per file
    // the real cycle performs; convergence is carried by the OPS inside
    // the file (kernel VV dedupe), not by the file write.
    medium.files[path] = content;
    return FileOperationResult(path: path);
  }

  @override
  Future<String?> getFile(final String path) async => medium.files[path];

  @override
  Future<FileOperationResult> deleteFile(
    final String path, {
    final String? commitMessage,
  }) async {
    medium.files.remove(path);
    return FileOperationResult(path: path);
  }

  @override
  Future<List<FileEntry>> listDirectory(final String directoryPath) async {
    final prefix = '$directoryPath/';
    return [
      for (final path in medium.files.keys.where(
        (final p) => p.startsWith(prefix),
      ))
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

({MeshStorageService service, DocReplicaStore store}) _device(
  final _SharedMedium medium,
  final String peerId,
  final String actorId,
) {
  final service = MeshStorageService.forTest(
    storage: StorageService(_MeshProvider(medium)),
    selfId: peerId,
  );
  final store = DocReplicaStore(storage: service.storage, actorId: actorId);
  service.attachDocSync(store);
  return (service: service, store: store);
}

DocumentNode _withBlocks(final DocumentNode node, final List<Block> blocks) =>
    node.withBlocks(blocks);

void main() {
  test(
    'two devices converge on one chat: owner claim + peer message + '
    'checkpointed reply',
    () async {
      final medium = _SharedMedium();
      final a = _device(medium, 'peer-a', 'actor-a'); // session owner
      final b = _device(medium, 'peer-b', 'actor-b'); // composing peer

      // A creates the chat and streams a checkpointed assistant reply.
      final repoA = ReplicaDocumentRepository(a.store);
      const titleId = NodeId('$_docId:title');
      await repoA.save(
        DocumentNode(
          id: _docId,
          formatId: 'chat',
          blocks: [
            const Block(
              id: titleId,
              type: BlockType.heading,
              content: 'Fleet planning',
              level: 1,
              agentKey: 'codex',
              workspace: '/tmp/fleet',
              ownerPeerId: 'peer-a',
            ),
          ],
          createdAt: _now,
          updatedAt: _now,
        ),
      );
      var nodeA = (await repoA.get(_docId) as DocFound).node;
      nodeA = _withBlocks(nodeA, [
        ...nodeA.blocks,
        const Block(
          id: NodeId('m1'),
          type: BlockType.message,
          content: '',
          role: ChatRole.user,
        ),
        const Block(
          id: NodeId('m2'),
          type: BlockType.message,
          content: 'thin',
          role: ChatRole.assistant,
        ),
      ]);
      await repoA.save(nodeA);
      await a.service.sync(); // flush A's replica file into the medium.

      // B syncs: receives the doc, composes through its OWN repository.
      await b.service.sync();
      final repoB = ReplicaDocumentRepository(b.store);
      var nodeB = (await repoB.get(_docId) as DocFound).node;
      expect(nodeB, isNotNull, reason: 'B must see the chat after sync');
      expect(nodeB.blocks.first.ownerPeerId, 'peer-a');
      expect(
        nodeB.blocks.where((final b) => b.type == BlockType.message),
        hasLength(2),
      );

      nodeB = _withBlocks(nodeB, [
        ...nodeB.blocks,
        const Block(
          id: NodeId('m3'),
          type: BlockType.message,
          content: 'launch the second mac',
          role: ChatRole.user,
        ),
      ]);
      nodeB = nodeB.copyWith(
        blocks: [
          for (final block in nodeB.blocks)
            block.id == titleId
                ? block.copyWith(systemPrompt: 'be concise')
                : block,
        ],
      );
      await repoB.save(nodeB);
      await b.service.sync();

      // A syncs: B's message + metadata edit converge into A's view; B
      // catches up on anything of A's it had not folded yet.
      await a.service.sync();
      await b.service.sync();
      final nodeA2 = (await repoA.get(_docId) as DocFound).node;
      final nodeB2 = (await repoB.get(_docId) as DocFound).node;

      expect(
        nodeA2.blocks.map(
          (final b) => '${b.id.value}:${b.role?.name}:${b.content}',
        ),
        nodeB2.blocks.map(
          (final b) => '${b.id.value}:${b.role?.name}:${b.content}',
        ),
        reason: 'both devices must project the same converged transcript',
      );
      expect(
        nodeA2.blocks.where((final b) => b.content == 'launch the second mac'),
        hasLength(1),
      );
      expect(nodeA2.blocks.first.systemPrompt, 'be concise');
      expect(nodeA2.blocks.first.ownerPeerId, 'peer-a');

      // Checkpoint growth: A extends the assistant text; B converges
      // without duplicating the shared prefix.
      final grown = nodeA2.copyWith(
        blocks: [
          for (final block in nodeA2.blocks)
            block.id == const NodeId('m2')
                ? block.copyWith(
                    content: 'thin — expanding into the plan',
                    status: MessageStatus.streaming,
                  )
                : block,
        ],
      );
      await repoA.save(grown);
      await a.service.sync();
      await b.service.sync();
      final nodeB3 = (await repoB.get(_docId) as DocFound).node;
      expect(
        nodeB3.blocks.firstWhere((final b) => b.id == const NodeId('m2')).content,
        'thin — expanding into the plan',
      );
      await a.store.dispose();
      await b.store.dispose();
    },
  );

  test(
    'MeshAwareDocumentRepository seeds a plain-store chat into the '
    'replica on first touch, then serves the replica',
    () async {
      final medium = _SharedMedium();
      final device = _device(medium, 'peer-a', 'actor-a');
      final plain = InMemoryDocumentRepository();
      const docId = NodeId('chat-legacy');
      await plain.save(
        DocumentNode(
          id: docId,
          formatId: 'chat',
          blocks: [
            const Block(
              id: NodeId('t'),
              type: BlockType.heading,
              content: 'pre-mesh chat',
              level: 1,
            ),
            const Block(
              id: NodeId('u1'),
              type: BlockType.message,
              content: 'history from before the mesh',
              role: ChatRole.user,
            ),
          ],
          createdAt: _now,
          updatedAt: _now,
        ),
      );

      // Mesh not live yet → the plain path answers.
      DocReplicaStore? live;
      final repo = MeshAwareDocumentRepository(plain, () => live);
      expect(await repo.get(docId), isA<DocFound>());

      // Mesh goes live → the same repository routes to the replica,
      // seeding the plain history once.
      live = device.store;
      final migrated = await repo.get(docId);
      expect(migrated, isA<DocFound>());
      final node = (migrated as DocFound).node;
      expect(node.blocks, hasLength(2));
      expect(
        (await device.store.open(docId)).blockText(const NodeId('u1')),
        'history from before the mesh',
      );

      // Writes now land in the replica.
      await repo.save(
        _withBlocks(node, [
          ...node.blocks,
          const Block(
            id: NodeId('a1'),
            type: BlockType.message,
            content: 'post-mesh reply',
            role: ChatRole.assistant,
          ),
        ]),
      );
      final reread = await repo.get(docId);
      expect((reread as DocFound).node.blocks.last.content, 'post-mesh reply');
      await device.store.dispose();
    },
  );
}
