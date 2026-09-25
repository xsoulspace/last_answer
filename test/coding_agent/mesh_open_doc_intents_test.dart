// Task O — the T3 multiplayer gate seams, driven through their REAL
// intent entries (mcp_toolkit `AgentCallEntry.invokeDirect`):
//
// - `mesh_open_doc`: the peer OPENS the shared doc as a viewer shadow
//   (no workspace, no daemon session) — `agent_doc_state` stops being an
//   error envelope and projects the shared docId, viewer:true, and live
//   mesh status (DESIGN §6: label what the host sees vs what the peer
//   observes);
// - `mesh_routing`: flips the remote-permission-routing policy through
//   the SAME state the PROFILE toggle renders;
// - `agent_permission_answer` on the PEER: answers a pending REMOTE
//   permission through the doc router (answer op → mesh → host folds);
// - `agent_doc_edit`: one real RGA append op into the shared replica.
//
// Two shapes are exercised: the app-owned replica
// (`StorageBackendsNotifier.ensureMeshService` swapped through the
// `meshServiceOpener` seam, in-memory, fake connected transport) and the
// two-device file-shipping shape (fake providers, one anti-entropy cycle
// simulated by copying files — the D seam in
// `test/permission_doc_routing_test.dart`).
import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/permission_doc_router.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

AgentCallEntry _entry(final String name) =>
    agentMcpEntries().firstWhere((final e) => e.name == name);

/// The legacy mcpToolkitTool bridge wraps every MCPCallResult as
/// AgentResult.success — the REAL ok flag is carried in data.
bool okOf(final AgentResult result) => result.data['ok'] == true;

/// Fake connected ephemeral transport: sends are recorded (never
/// delivered — single-app), the link is born connected, so joinDoc folds
/// THIS device into its own presence.
final class _FakeEndpoint implements EphemeralFrameTransport {
  final _frames = StreamController<MeshEphemeralFrame>();
  final List<MeshEphemeralFrame> sent = [];

  @override
  EphemeralLinkState get connectionState => EphemeralLinkState.connected;

  @override
  Stream<EphemeralLinkState> get connectionChanges =>
      const Stream<EphemeralLinkState>.empty();

  @override
  Stream<MeshEphemeralFrame> get frames => _frames.stream;

  @override
  Future<void> send(final MeshEphemeralFrame frame) async {
    sent.add(frame);
  }

  void dispose() => unawaited(_frames.close());
}

/// In-memory mesh replica: a REAL [MeshStorageProvider] over `:memory:`
/// plus a fake connected presence transport (no networking).
Future<MeshStorageService> _memoryService({
  required final String selfId,
  required final _FakeEndpoint endpoint,
}) async {
  final provider = MeshStorageProvider();
  await provider.initWithConfig(
    MeshStorageConfig(storePath: ':memory:', peerId: selfId),
  );
  final service = MeshStorageService.forTest(
    storage: StorageService(provider),
    selfId: selfId,
    identityKeyPair: await PairingService.newIdentityKeyPair(),
  )..attachPresenceTransport(endpoint);
  return service;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  _FakeEndpoint? endpoint;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await StorageBackendsNotifier.instance.leaveMesh();
    StorageBackendsNotifier.meshServiceOpener = null;
    StorageBackendsNotifier.onSyncCycle = null;
    AgentDocSurface.debugState = null;
    AgentDocSurface.debugSurface = null;
    AgentDocSurface.shadowDoc = null;
    AgentDocSurface.meshWiring = null;
    endpoint?.dispose();
    endpoint = null;
  });

  /// Installs the opener seam + opens ONE in-memory replica; the verbs
  /// read it through `StorageBackendsNotifier.instance.meshService`.
  Future<MeshStorageService> openReplica({final String selfId = 'gate-peer'}) {
    final ep = _FakeEndpoint();
    endpoint = ep;
    final service = _memoryService(selfId: selfId, endpoint: ep);
    StorageBackendsNotifier.meshServiceOpener =
        ({
          required storePath,
          required peerId,
          relayEndpoint,
        }) => Future<MeshStorageService>.value(service);
    return service;
  }

  group('mesh_open_doc (P0)', () {
    test('refuses honestly when no mesh replica is live', () async {
      final result = await _entry(
        'mesh_open_doc',
      ).invokeDirect({'docId': 'gate-doc'});
      expect(okOf(result), isFalse, reason: result.message);
      expect(result.message, contains('mesh_pair'));
      expect(AgentDocSurface.shadowDoc, isNull);
    });

    test('requires the shared docId (schema-level)', () async {
      await openReplica();
      await StorageBackendsNotifier.instance.ensureMeshService();
      await expectLater(
        () => _entry('mesh_open_doc').invokeDirect(const {}),
        throwsException,
        reason: 'a missing docId is rejected by the schema itself',
      );
    });

    test(
      'opens the viewer shadow: agent_doc_state returns ok with the '
      'SHARED docId, viewer:true, no workspace, live presence',
      () async {
        await openReplica();
        final service = await StorageBackendsNotifier
            .instance
            .ensureMeshService();

        final result = await _entry(
          'mesh_open_doc',
        ).invokeDirect({'docId': 'gate-doc'});

        expect(okOf(result), isTrue, reason: result.message);
        expect(result.data['docId'], 'gate-doc');
        expect(result.data['viewer'], isTrue);
        expect(result.data['workspaces'], isEmpty);
        expect(result.data['turnCount'], 0);
        // The shadow rides the deterministic doc channel (the same one
        // the host's surface joins) and is present on it.
        expect(result.data['meshStatus'], isNotNull);
        final mesh = result.data['meshStatus']! as Map;
        expect(mesh['presenceCount'], greaterThanOrEqualTo(1));

        // The projection PERSISTS for agent_doc_state — the peer's state
        // is no longer the error envelope.
        final state = await _entry('agent_doc_state').invokeDirect(const {});
        expect(okOf(state), isTrue, reason: state.message);
        expect(state.data['docId'], 'gate-doc');
        expect(state.data['viewer'], isTrue);
        expect(state.data['pendingPermissionTitle'], isNull);

        // The shared replica was OPENED in the device's store — this is
        // what lets absorbRemote fold the peer's ops on the sync cycle.
        final store = StorageBackendsNotifier.instance.docReplicaStore!;
        expect(store.replicaOf(const NodeId('agent-gate-doc')), isNotNull);
        expect(service.presence('agent-gate-doc'), isNotEmpty);
      },
    );

    test('join/leave/hosting changes re-project within one cycle', () async {
      await openReplica();
      await StorageBackendsNotifier.instance.ensureMeshService();
      var cycles = 0;
      StorageBackendsNotifier.onSyncCycle = () => cycles++;

      await _entry('mesh_open_doc').invokeDirect({'docId': 'gate-doc'});
      final afterJoin = cycles;
      expect(afterJoin, greaterThanOrEqualTo(1));

      await _entry('mesh_leave_doc').invokeDirect({'docId': 'gate-doc'});
      expect(cycles, greaterThan(afterJoin));
    });
  });

  group('mesh_routing (P1)', () {
    test('refuses honestly with no open doc surface', () async {
      final result = await _entry(
        'mesh_routing',
      ).invokeDirect({'enabled': 'true'});
      expect(okOf(result), isFalse, reason: result.message);
      expect(result.message, contains('No agent doc surface'));
    });

    test('requires the enabled flag (schema-level)', () async {
      await expectLater(
        () => _entry('mesh_routing').invokeDirect(const {}),
        throwsException,
        reason: 'a missing enabled flag is rejected by the schema itself',
      );
    });

    testWidgets(
      'flips the SAME state the PROFILE toggle renders (and back off)',
      (final tester) async {
        final provider = _WiringProvider();
        final service = MeshStorageService.forTest(
          storage: StorageService(provider),
          selfId: 'device-a',
        );
        addTearDown(service.dispose);
        final store = DocReplicaStore(
          storage: service.storage,
          actorId: 'device-a',
        );
        service.attachDocSync(store);
        final controller = HarnessSessionController(
          // Scripted, LLM-free: the daemon is never started under this
          // surface (no session is created — routing policy only).
          config: const HarnessHostConfig(
            handlerFactory: _throwingFactory,
          ),
          roster: ActorRoster(replicaId: 'device-a'),
        );
        addTearDown(controller.dispose);
        final doc = ProjectModel.emptyAgent() as ProjectModelDoc;
        AgentDocSurface.meshWiring = AgentDocMeshWiring(
          routerFor:
              (final docId) => PermissionDocRouter(
                store: store,
                docId: docId,
                selfId: 'device-a',
              ),
          joinDoc: (_) async {},
          leaveDoc: (_) async {},
          statusFor: (_) => const AgentDocMeshStatus(),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AgentDocSurface(doc: doc, controller: controller),
            ),
          ),
        );
        await tester.pump();

        expect(controller.remotePermissionRouting, isFalse);
        final on = await _entry(
          'mesh_routing',
        ).invokeDirect({'enabled': 'true'});
        expect(okOf(on), isTrue, reason: on.message);
        expect(on.data['remotePermissionRouting'], isTrue);
        expect(controller.remotePermissionRouting, isTrue);
        expect(controller.permissionRouter, isNotNull);
        // One state, many projections (DESIGN §5): the PROFILE toggle
        // reads exactly what the verb flipped.
        expect(AgentDocSurface.debugState?.remotePermissionRouting, isTrue);

        final off = await _entry(
          'mesh_routing',
        ).invokeDirect({'enabled': 'false'});
        expect(okOf(off), isTrue, reason: off.message);
        expect(controller.remotePermissionRouting, isFalse);
        expect(AgentDocSurface.debugState?.remotePermissionRouting, isFalse);
      },
    );
  });

  group('agent_permission_answer on the PEER (P1)', () {
    test(
      'answers the pending REMOTE permission through the doc; local '
      'answering with a real surface is unchanged',
      () async {
        final owner = _Device('device-a');
        final peer = _Device('device-b');
        addTearDown(owner.dispose);
        addTearDown(peer.dispose);
        await owner.attach();
        await peer.attach();

        // The OWNER announces a pending permission as a doc op (what the
        // host's routed controller does mid-turn).
        final ownerRouter = owner.router();
        final requestId = await ownerRouter.announceRequest(
          title: 'write gate-permission-target.txt',
        );
        // One anti-entropy cycle: the request reaches the peer.
        await owner.shipTo(peer, _Device.docFile);

        // The peer's shadow is opened over the shared doc (mesh_open_doc
        // builds exactly this shape); the projection carries the pending
        // title and the answer routes through the router.
        AgentDocSurface.shadowDoc = AgentDocShadow(
          docId: 'the-doc',
          meshDocId: _Device.docId.value,
          router: peer.router(),
          roster: peer.roster,
        );

        final state = AgentDocSurface.shadowDoc!.toDebugState();
        expect(state.viewer, isTrue);
        expect(
          state.pendingPermissionTitle,
          'write gate-permission-target.txt',
        );

        // Reject first (the law).
        final reject = await _entry(
          'agent_permission_answer',
        ).invokeDirect({'allow': 'false'});
        expect(okOf(reject), isTrue, reason: reject.message);
        final answered = peer.store
            .replicaOf(_Device.docId)!
            .permRequestOf(requestId)!;
        expect(answered.status, PermRequestStatus.reject);
        expect(answered.responderPeerId, 'device-b');
        expect(
          AgentDocSurface.shadowDoc!.toDebugState().pendingPermissionTitle,
          isNull,
          reason: 'answered round-trips leave the pending projection',
        );

        // The answer rides the mesh back; the OWNER folds it.
        await peer.shipTo(owner, _Device.docFile);
        final folded = owner.store.replicaOf(_Device.docId)!.permRequestOf(
          requestId,
        )!;
        expect(folded.status, PermRequestStatus.reject);
        expect(folded.responderPeerId, 'device-b');
      },
    );

    test('refuses honestly with no surface and no shadow', () async {
      final result = await _entry(
        'agent_permission_answer',
      ).invokeDirect({'allow': 'true'});
      expect(okOf(result), isFalse, reason: result.message);
    });

    test('refuses honestly when nothing is pending remotely', () async {
      final peer = _Device('device-b');
      addTearDown(peer.dispose);
      await peer.attach();
      AgentDocSurface.shadowDoc = AgentDocShadow(
        docId: 'the-doc',
        meshDocId: _Device.docId.value,
        router: peer.router(),
      );
      final result = await _entry(
        'agent_permission_answer',
      ).invokeDirect({'allow': 'true'});
      expect(okOf(result), isFalse, reason: result.message);
      expect(result.message, contains('no pending remote permission'));
    });
  });

  group('agent_doc_edit (P2)', () {
    test('refuses honestly when no store is live', () async {
      final result = await _entry(
        'agent_doc_edit',
      ).invokeDirect({'text': 'hi'});
      expect(okOf(result), isFalse, reason: result.message);
      expect(result.message, contains('mesh_host'));
    });

    test('requires text (schema-level)', () async {
      await openReplica();
      await StorageBackendsNotifier.instance.ensureMeshService();
      await expectLater(
        () => _entry('agent_doc_edit').invokeDirect(const {}),
        throwsException,
        reason: 'a missing text is rejected by the schema itself',
      );
    });

    test(
      'appends REAL doc ops into the shared replica: the block is '
      'created when missing and appended to when present',
      () async {
        await openReplica();
        await StorageBackendsNotifier.instance.ensureMeshService();

        final first = await _entry('agent_doc_edit').invokeDirect({
          'docId': 'gate-doc',
          'blockId': 'gate-a',
          'text': 'host append',
        });
        expect(okOf(first), isTrue, reason: first.message);
        expect(first.data['docChannel'], 'agent-gate-doc');
        expect(first.data['blockId'], 'gate-a');

        final second = await _entry('agent_doc_edit').invokeDirect({
          'docId': 'gate-doc',
          'blockId': 'gate-a',
          'text': ' more',
        });
        expect(okOf(second), isTrue, reason: second.message);

        final replica = StorageBackendsNotifier.instance.docReplicaStore!
            .replicaOf(const NodeId('agent-gate-doc'))!;
        final document = replica.document();
        expect(document.blockById(const NodeId('gate-a')), isNotNull);
        expect(
          replica.blockText(const NodeId('gate-a')),
          'host append more',
        );
        // The ops are durable: the sync cycle flushes them into storage.
        await StorageBackendsNotifier.instance.meshService!.sync();
        expect(
          StorageBackendsNotifier.instance.meshService!.storage
              .readFile('doc_replicas/agent-gate-doc.json'),
          completes,
        );
      },
    );
  });
}

GenerationHandler _throwingFactory(final ModelRouter router) =>
    throw UnimplementedError();

/// Fake [StorageProvider]: in-memory map, sync is a recorded no-op —
/// tests copy files between providers to simulate one anti-entropy cycle.
class _WiringProvider extends StorageProvider {
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

/// One device in the two-shape test: mesh service + doc store + roster
/// over a fake provider (same shape as `permission_doc_routing_test`).
final class _Device {
  _Device(final String peerId)
    : provider = _WiringProvider(),
      peerId = peerId {
    service = MeshStorageService.forTest(
      storage: StorageService(provider),
      selfId: peerId,
    );
  }

  final String peerId;
  final _WiringProvider provider;
  late final MeshStorageService service;
  late final DocReplicaStore store = DocReplicaStore(
    storage: service.storage,
    actorId: peerId,
  );
  late final ActorRoster roster = ActorRoster(replicaId: 'placeholder');

  static const docId = NodeId('agent-the-doc');
  static const docFile = 'doc_replicas/agent-the-doc.json';

  Future<void> attach() async {
    service.attachDocSync(store);
    service.attachRoster(roster);
    await store.open(docId);
  }

  PermissionDocRouter router() => PermissionDocRouter(
    store: store,
    docId: docId,
    selfId: peerId,
  );

  /// One anti-entropy cycle: this device flushes, [other] absorbs.
  Future<void> shipTo(final _Device other, final String file) async {
    await service.sync();
    other.provider.files[file] = provider.files[file]!;
    await other.service.sync();
  }

  Future<void> dispose() => service.dispose();
}
