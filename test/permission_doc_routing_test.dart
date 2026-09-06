// PLAN 5c gate — remote permission routing (ADR 0005 §5): a permission
// answered from the SECOND device. Two in-memory replicas ride the D seam
// (MeshStorageService.attachDocSync + whole-file anti-entropy, fake
// provider) and the E seam (attachRoster — the roster the origin labels
// resolve through); the owner device runs the REAL embedded harness with
// the LLM-free scripted mover. No networking.
//
// The whole lifecycle is event-sourced: the request op and the answer op
// are doc data; the kernel owns ordering/dedupe; the owner's permission
// future completes when the ANSWER op folds into the doc.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/permission_doc_router.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

import 'coding_agent/scripted_write_mover.dart';

const _docId = NodeId('agent-doc');
const _docFile = 'doc_replicas/agent-doc.json';

/// Lets the controller's unawaited announcement/answer chains settle.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 30));

Future<void> _waitFor(
  final bool Function() condition,
  final String reason,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(condition(), isTrue, reason: reason);
}

/// Fake [StorageProvider]: in-memory map, sync is a recorded no-op —
/// tests copy files between providers to simulate what anti-entropy
/// delivers (the D/E seam's whole-file exchange).
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

/// One device: mesh service (D doc-sync + E roster seams) over a fake
/// provider, with its doc-replica store and roster attached.
final class _Device {
  factory _Device(final String peerId) {
    final provider = _FakeProvider();
    final service = MeshStorageService.forTest(
      storage: StorageService(provider),
      selfId: peerId,
    );
    return _Device._(peerId, provider, service);
  }

  _Device._(this.peerId, this.provider, this.service);

  final String peerId;
  final _FakeProvider provider;
  final MeshStorageService service;
  late final DocReplicaStore store = DocReplicaStore(
    storage: service.storage,
    actorId: peerId,
  );
  late final ActorRoster roster = ActorRoster(replicaId: 'placeholder');

  /// The device-side controller (scripted, LLM-free). The OWNER's runs
  /// the real harness round-trip; the PEER's only renders and answers.
  late final HarnessSessionController controller = HarnessSessionController(
    config: HarnessHostConfig(
      handlerFactory: (_) =>
          ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
    ),
    roster: roster,
  );

  Future<void> attach() async {
    service.attachDocSync(store);
    service.attachRoster(roster);
    await store.open(_docId); // the peer has the doc replica open too
    controller.attachPermissionRouter(router());
  }

  /// Copies this device's flushed files to [other]'s provider — what one
  /// anti-entropy cycle delivers — then lets [other] absorb them.
  Future<void> shipTo(final _Device other, final List<String> files) async {
    await service.sync();
    for (final file in files) {
      other.provider.files[file] = provider.files[file]!;
    }
    await other.service.sync();
  }

  PermissionDocRouter router() => PermissionDocRouter(
    store: store,
    docId: _docId,
    selfId: peerId,
  );

  Future<void> dispose() async {
    controller.dispose();
    await service.dispose();
  }
}

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp(
      'lastanswer_perm_routing',
    );
    File('${workspace.path}/main.dart').writeAsStringSync(
      "void main() { throw StateError('not implemented'); }\n",
    );
  });

  tearDown(() {
    try {
      workspace.deleteSync(recursive: true);
    } on Object {
      // best effort
    }
  });

  test('request announced → rendered remotely → answered remotely → '
      'the owner future completes with that outcome → the turn records it',
      () async {
    final owner = _Device('device-a');
    final peer = _Device('device-b');
    addTearDown(owner.dispose);
    addTearDown(peer.dispose);
    await owner.attach();
    await peer.attach();
    owner.controller.remotePermissionRouting = true;

    // The acting agent is a roster actor, synced to the peer (E seam) —
    // the origin label resolves through it (ADR 0007 §2).
    owner.roster.upsert(
      const ActorProfile(
        actorId: 'afm-coder',
        displayName: 'AFM Coder',
        role: 'coder',
      ),
    );

    final controller = owner.controller;
    await controller.createSession(workspace.path);
    controller.attachActor(controller.current!, 'afm-coder');

    // Delegate; the harness raises the write gate; the owner announces it
    // as a doc op (policy ON).
    final turn = controller.delegate('Fix main.dart so `dart run` exits 0.');
    final pending = await controller.nextPermission();
    await _waitFor(
      () => owner.store.replicaOf(_docId)!.permRequests().isNotEmpty,
      'the pending permission must be announced as a doc op',
    );
    final record = owner.store.replicaOf(_docId)!.permRequests().single;
    expect(record.isPending, isTrue);
    expect(record.title, pending.request.title);
    expect(record.originPeerId, 'device-a');
    expect(record.originActorId, 'afm-coder');

    // One anti-entropy cycle: the request (and the roster) reach the peer.
    await owner.shipTo(peer, [_docFile, 'actor_rosters/device-a.json']);

    // The peer resolves the origin through ITS roster replica.
    peer.controller.refreshPermissions();
    final remote = peer.controller.remotePermissions;
    expect(remote, hasLength(1));
    expect(remote.single.isPending, isTrue);
    expect(peer.controller.originLabelOf(remote.single), 'AFM-CODER');
    // Fallback: an unresolvable actor degrades to the device label.
    expect(
      peer.controller.originLabelOf(
        const PermRequestRecord(
          requestId: 'x',
          title: 't',
          originPeerId: 'device-a',
          createdAt: '',
          originActorId: 'unknown-actor',
        ),
      ),
      'DEVICE-A',
    );

    // The peer answers remotely — ALLOW — as an answer op.
    await peer.controller.answerRemotePermission(record.requestId,
        allow: true);
    final answered = peer.store
        .replicaOf(_docId)!
        .permRequestOf(record.requestId)!;
    expect(answered.status, PermRequestStatus.allow);
    expect(answered.responderPeerId, 'device-b');

    // The answer rides the mesh back; the OWNER's future completes from
    // the folded op — never locally.
    expect(pending.isAnswered, isFalse, reason: 'no answer op yet on A');
    await peer.shipTo(owner, [_docFile]);
    controller.refreshPermissions(); // app wiring: after every sync cycle
    expect(pending.isAnswered, isTrue);

    // The turn proceeds: the allowed write lands, the verdict surfaces.
    await turn;
    expect(controller.current!.verdictLine, contains('PASS'));
    expect(
      File('${workspace.path}/main.dart').readAsStringSync(),
      contains("print('ok')"),
    );

    // The remote answer is recorded on the turn exactly like a local one
    // — indistinguishable except by origin (ADR 0005 §5, DESIGN §5/§9).
    final logged = controller.current!.turns.last.permissions.single;
    expect(logged.allowed, isTrue);
    expect(logged.originLabel, 'DEVICE-B');

    // Both replicas converged on the same lifecycle.
    expect(
      owner.store.replicaOf(_docId)!.permRequestOf(record.requestId)?.status,
      PermRequestStatus.allow,
    );
    String renderOf(final _Device device) => device.store
        .replicaOf(_docId)!
        .permRequests()
        .map((final r) => r.toString())
        .join('|');
    expect(renderOf(owner), renderOf(peer));
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('remote REJECT path: the write never lands, the turn records '
      'reject with origin', () async {
    final owner = _Device('device-a');
    final peer = _Device('device-b');
    addTearDown(owner.dispose);
    addTearDown(peer.dispose);
    await owner.attach();
    await peer.attach();
    owner.controller.remotePermissionRouting = true;

    final controller = owner.controller;
    await controller.createSession(workspace.path);

    final turn = controller.delegate('Fix main.dart so `dart run` exits 0.');
    final pending = await controller.nextPermission();
    await _waitFor(
      () => owner.store.replicaOf(_docId)!.permRequests().isNotEmpty,
      'the pending permission must be announced as a doc op',
    );
    final requestId = owner.store
        .replicaOf(_docId)!
        .permRequests()
        .single
        .requestId;

    await owner.shipTo(peer, [_docFile]);
    peer.controller.refreshPermissions();
    expect(peer.controller.remotePermissions.single.isPending, isTrue);

    // The peer REJECTS — deny is a first-class outcome, recorded as data
    // like any other (DESIGN §4).
    await peer.controller.answerRemotePermission(requestId, allow: false);
    await peer.shipTo(owner, [_docFile]);
    controller.refreshPermissions();

    expect(pending.isAnswered, isTrue);
    await turn;
    expect(controller.current!.verdictLine, contains('FAIL'));
    expect(
      File('${workspace.path}/main.dart').readAsStringSync(),
      isNot(contains("print('ok')")),
      reason: 'a rejected write must never land',
    );
    final logged = controller.current!.turns.last.permissions.single;
    expect(logged.allowed, isFalse);
    expect(logged.originLabel, 'DEVICE-B');
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('no answer op → no completion: the owner future stays pending and '
      'cancel answers conservatively (deny)', () async {
    final owner = _Device('device-a');
    final peer = _Device('device-b');
    addTearDown(owner.dispose);
    addTearDown(peer.dispose);
    await owner.attach();
    await peer.attach();
    owner.controller.remotePermissionRouting = true;

    final controller = owner.controller;
    await controller.createSession(workspace.path);

    final turn = controller.delegate('Fix main.dart so `dart run` exits 0.');
    final pending = await controller.nextPermission();
    await _waitFor(
      () => owner.store.replicaOf(_docId)!.permRequests().isNotEmpty,
      'announced',
    );

    // The request reaches the peer, but nobody answers. A refresh must
    // NOT complete the future — deny-by-default is preserved and the
    // host's own 5-minute deadline remains the backstop.
    await owner.shipTo(peer, [_docFile]);
    await _settle();
    expect(pending.isAnswered, isFalse);
    expect(controller.pendingPermission, isNotNull);

    // The human's stop breaks the round-trip: cancel answers the routed
    // round-trip with the conservative deny, as a doc op.
    controller.cancelCurrent();
    await _waitFor(
      () =>
          owner.store.replicaOf(_docId)!.permRequests().single.status ==
          PermRequestStatus.reject,
      'cancel must route the conservative deny through the doc',
    );
    expect(pending.isAnswered, isTrue);
    await turn; // the stop broke the round-trip; the turn ends
    final logged = controller.current!.turns.last.permissions.single;
    expect(logged.allowed, isFalse);
    expect(logged.originLabel, isNull, reason: 'own deny: no origin label');
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('policy OFF (default): local answering byte-for-byte unchanged — '
      'direct completion, no perm ops, no origin label', () async {
    final owner = _Device('device-a');
    final peer = _Device('device-b');
    addTearDown(owner.dispose);
    addTearDown(peer.dispose);
    await owner.attach();
    await peer.attach();

    // The router is attached but the policy stays OFF — the pre-5c shape.
    expect(owner.controller.remotePermissionRouting, isFalse);
    final controller = owner.controller;
    await controller.createSession(workspace.path);

    final turn = controller.delegate('Fix main.dart so `dart run` exits 0.');
    final pending = await controller.nextPermission();
    await _settle();

    // Nothing was announced.
    expect(owner.store.replicaOf(_docId)!.permRequests(), isEmpty);

    // Local answering: the future completes directly, as before.
    controller.answerPermission(allow: true);
    expect(pending.isAnswered, isTrue);
    await turn;
    expect(controller.current!.verdictLine, contains('PASS'));
    final logged = controller.current!.turns.last.permissions.single;
    expect(logged.allowed, isTrue);
    expect(logged.originLabel, isNull);

    // And the doc channel stays empty end to end — the peer sees nothing.
    await owner.service.sync();
    expect(owner.store.replicaOf(_docId)!.permRequests(), isEmpty);
    expect(peer.store.replicaOf(_docId)!.permRequests(), isEmpty);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
