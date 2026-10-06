/// oka endless-loop driver (ADR-0035): last_answer's real domain engine
/// (headless_core) as a long-lived process for the patch-continue /
/// patch-reset-continue loop.
///
/// Boot creates ONE DocReplicaStore, opens a document and edits it — that
/// state is the hold probe: it must never change across patches or resets.
/// Two patchable units exercise the loop:
/// - `fractional_order`: `fractionalBetween('a', null)` flips b -> c -> b
/// - `doc_replica_store`: the ctor default `dir` flips doc_replicas ->
///   doc_replicas_live -> doc_replicas
///
/// `--serve` keeps the isolate alive; every tick prints all three labels
/// from the SAME boot instances.
library;

import 'dart:async';

import 'package:headless_core/headless_core.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

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

/// Boot state: created once, mutated once, then FROZEN as the hold probe.
final DocReplicaStore bootStore = DocReplicaStore(
  storage: StorageService(_NoopStorageProvider()),
  actorId: 'oka-endless',
);
const NodeId bootDocId = NodeId('endless-doc');
int bootOpCount = -1;

Future<void> _bootState() async {
  await bootStore.edit(
    bootDocId,
    (replica) => replica.createNode(),
  );
  bootOpCount = bootStore
      .replicaOf(bootDocId)!
      .pendingOpsSince(VersionVector())
      .length;
}

String orderLabel() =>
    'order: fractionalBetween(a, null) = "${fractionalBetween('a', null)}"';

String storeLabel() {
  final store = DocReplicaStore(
    storage: StorageService(_NoopStorageProvider()),
    actorId: 'oka-endless',
  );
  return 'store: dir="${store.dir}"';
}

/// The hold probe: boot-derived state that survives every patch.
String stateLabel() => 'state: doc=${bootDocId.value} '
    'ops=$bootOpCount replicaOpen=${bootStore.replicaOf(bootDocId) != null}';

Future<void> main(List<String> args) async {
  await _bootState();
  // ignore: avoid_print
  print('[endless] boot: ${orderLabel()} | ${storeLabel()} | ${stateLabel()}');
  if (args.contains('--serve')) {
    var tick = 0;
    Timer.periodic(const Duration(seconds: 2), (_) {
      // ignore: avoid_print
      print('[endless] tick ${tick++}: ${orderLabel()} | ${storeLabel()} '
          '| ${stateLabel()}');
    });
  }
}
