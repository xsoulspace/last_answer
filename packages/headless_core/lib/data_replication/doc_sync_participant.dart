import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';

import 'doc_replica_store.dart';

/// A [DocReplicaStore] riding the mesh (ADR 0047 §3): its batched flush
/// ships the latest replica state before anti-entropy; [absorbRemote]
/// folds what the exchange delivered; compaction follows the store's own
/// policy. The app-side [MeshSyncParticipant] implementations (roster,
/// boards) own the other content shapes; this one is the document lane
/// and lives beside the store it flushes.
final class DocSyncParticipant implements MeshSyncParticipant {
  const DocSyncParticipant(this.store);

  final DocReplicaStore store;

  @override
  Future<void> flush(final StorageService storage) => store.flush();

  @override
  Future<void> absorb(final StorageService storage) => store.absorbRemote();

  @override
  Future<void> compact(final StorageService storage) => store.compactAll();
}
