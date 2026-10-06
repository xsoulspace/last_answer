/// oka kernel-lane driver (ADR-0032 G2.5-real / G3-real).
///
/// Real-app probe over the `lastanswer` workspace. Root uses the document
/// model + fractional ordering; unit A is `headless_core`'s replica engine
/// (`doc_replica.dart`); unit B is its persistence seam
/// (`doc_replica_store.dart`) — B imports A, so the partition must order A
/// before B, and both share root libraries (`document_node`,
/// `universal_storage_convergence`).
///
/// `--serve` keeps the process alive so a delta dill can be pushed into it
/// (G3-real); every patchable label printed here comes from REAL module code
/// (a ctor default in `doc_replica_store.dart`, the fractional-order policy).
import 'dart:async';
import 'dart:io';

import 'package:headless_core/headless_core.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Minimal StorageProvider fake — the driver never touches real storage, it
/// only needs `DocReplicaStore` to construct over a `StorageService`.
class _NoopStorageProvider extends StorageProvider {
  @override
  Future<void> initWithConfig(StorageConfig config) async {}

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<FileOperationResult> createFile(
    String path,
    String content, {
    String? commitMessage,
  }) async => throw UnimplementedError();

  @override
  Future<String?> getFile(String path) async => null;

  @override
  Future<FileOperationResult> updateFile(
    String path,
    String content, {
    String? commitMessage,
  }) async => throw UnimplementedError();

  @override
  Future<FileOperationResult> deleteFile(
    String path, {
    String? commitMessage,
  }) async => throw UnimplementedError();

  @override
  Future<List<FileEntry>> listDirectory(String directoryPath) async => const [];

  @override
  Future<void> restore(String path, {String? versionId}) async {}

  @override
  Future<void> sync({
    String? pullMergeStrategy,
    String? pushConflictStrategy,
  }) async {}

  @override
  Future<void> dispose() async {}
}

String rootLabel() {
  final between = fractionalBetween('a', null) ?? '<null>';
  return 'root: fractionalBetween(a, null) = "$between"';
}

String replicaLabel() {
  final replica = DocReplica(
    nodeId: const NodeId('oka-driver-doc'),
    actorId: 'oka-driver',
  );
  return 'unitA(doc_replica): doc=${replica.nodeId.value} '
      'actor=${replica.actorId}';
}

String storeLabel() {
  final store = DocReplicaStore(
    storage: StorageService(_NoopStorageProvider()),
    actorId: 'oka-driver',
  );
  return 'unitB(doc_replica_store): dir="${store.dir}"';
}

Future<void> main(List<String> args) async {
  stdout.writeln('[driver] ${rootLabel()}');
  stdout.writeln('[driver] ${replicaLabel()}');
  stdout.writeln('[driver] ${storeLabel()}');
  if (args.contains('--serve')) {
    var tick = 0;
    Timer.periodic(const Duration(seconds: 2), (_) {
      stdout.writeln('[driver] tick $tick store.dir='
          '${DocReplicaStore(storage: StorageService(_NoopStorageProvider()), actorId: 'oka-driver').dir}');
      tick++;
    });
  }
}
