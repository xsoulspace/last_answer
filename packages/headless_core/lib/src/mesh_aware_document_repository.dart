import 'doc_replica_store.dart';
import 'document_node.dart';
import 'document_repository.dart';
import 'replica_document_repository.dart';

/// A [DocumentRepository] that routes to the LIVE mesh replica store when
/// one is attached (docs converge across devices over the LAN mesh), and
/// falls back to the plain local repository otherwise (pre-mesh setup,
/// web without a hosted peer).
///
/// Seeding: the first read of a doc that exists ONLY in the plain store
/// (every chat created before the mesh was enabled) imports it into the
/// replica once — one whole-node diff of kernel ops — so multiplayer
/// starts from the doc's real history instead of forking an empty twin.
/// The plain copy is then shadowed (never deleted): the replica is the
/// source of truth while the mesh is live.
///
/// The replica-store getter is a FUNCTION, not a value: the mesh comes up
/// after the provider tree builds (`ensureMeshService` on pairing).
class MeshAwareDocumentRepository implements DocumentRepository {
  MeshAwareDocumentRepository(this._plain, this._replicaStore);

  /// App-level seam for the LIVE replica store. The provider tree builds
  /// before the mesh; the shell sets this (home-screen assert block, same
  /// guard as [AgentDocSurface.meshWiring]) so every repository instance
  /// created before pairing routes to the replica once it exists. Null
  /// getter or null answer = the plain local path.
  static DocReplicaStore? Function()? replicaStoreGetter;

  final DocumentRepository _plain;
  final DocReplicaStore? Function() _replicaStore;

  ReplicaDocumentRepository _replicaRepo(final DocReplicaStore store) =>
      _replicaRepos.putIfAbsent(store, () => ReplicaDocumentRepository(store));

  final Map<DocReplicaStore, ReplicaDocumentRepository> _replicaRepos = {};

  @override
  Future<DocResult> get(final NodeId id) async {
    final store = _replicaStore();
    if (store == null) return _plain.get(id);
    final replicaRepo = _replicaRepo(store);
    final fromReplica = await replicaRepo.get(id);
    if (fromReplica is DocFound) return fromReplica;
    // Seeding path: the doc lives only in the plain store (pre-mesh
    // history) — import it into the replica once, then answer from the
    // replica so reads and writes share one source of truth.
    final plain = await _plain.get(id);
    if (plain is DocFound) {
      await replicaRepo.save(plain.node);
      return replicaRepo.get(id);
    }
    return fromReplica;
  }

  @override
  Future<void> save(final DocumentNode node) async {
    final store = _replicaStore();
    if (store == null) return _plain.save(node);
    await _replicaRepo(store).save(node);
  }

  @override
  Future<void> delete(final NodeId id) async {
    final store = _replicaStore();
    if (store == null) return _plain.delete(id);
    await _replicaRepo(store).delete(id);
  }

  @override
  Future<List<NodeId>> childrenOf(final NodeId? parentId) async {
    final store = _replicaStore();
    if (store == null) return _plain.childrenOf(parentId);
    return _replicaRepo(store).childrenOf(parentId);
  }

  @override
  Future<List<NodeId>> allIds() async {
    final store = _replicaStore();
    if (store == null) return _plain.allIds();
    return _replicaRepo(store).allIds();
  }
}
