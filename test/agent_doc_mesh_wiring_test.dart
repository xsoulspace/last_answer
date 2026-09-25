import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/permission_doc_router.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';

/// Task H — the multiplayer seams are LIVE on the agent-doc surface:
///
/// - the PROFILE routing toggle (keys `coding_agent.routing.*`) attaches
///   the controller's [PermissionDocRouter] over the mesh-attached live
///   store — default OFF, local answering unchanged (DESIGN §4);
/// - presence follows doc sessions: open joins the doc's channel, close
///   leaves it (ADR 0031 §1);
/// - the mesh status + presence count are projected into
///   [AgentDocSurface.debugState] (DESIGN §5).
///
/// Everything runs against an in-memory fake provider and an in-proc
/// fake ephemeral transport — no networking.

/// Lets async chains (signing, session open, attach) settle.
Future<void> _settle(final WidgetTester tester) => tester.runAsync(
  () => Future<void>.delayed(const Duration(milliseconds: 50)),
);

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

/// In-proc fake ephemeral transport (ADR 0031 §2): starts connected and
/// records every frame THIS device sends (join/leave/ping).
final class _FakeEndpoint implements EphemeralFrameTransport {
  final _frames = StreamController<MeshEphemeralFrame>();
  final _changes = StreamController<EphemeralLinkState>.broadcast();
  final List<MeshEphemeralFrame> sent = [];

  @override
  EphemeralLinkState get connectionState => EphemeralLinkState.connected;

  @override
  Stream<MeshEphemeralFrame> get frames => _frames.stream;

  @override
  Stream<EphemeralLinkState> get connectionChanges => _changes.stream;

  @override
  Future<void> send(final MeshEphemeralFrame frame) async {
    sent.add(frame);
  }

  void dispose() {
    unawaited(_frames.close());
    unawaited(_changes.close());
  }
}

void main() {
  late _FakeProvider provider;
  late MeshStorageService service;
  late HarnessSessionController controller;
  late ProjectModelDoc doc;
  late DocReplicaStore store;
  late String replicaDocId;
  final joined = <String>[];
  final left = <String>[];

  setUp(() {
    provider = _FakeProvider();
    service = MeshStorageService.forTest(
      storage: StorageService(provider),
      selfId: 'device-b',
    );
    controller = HarnessSessionController(
      // Scripted, LLM-free: the daemon idles under the surface.
      config: HarnessHostConfig(
        handlerFactory: (_) => throw UnimplementedError(),
      ),
      roster: ActorRoster(replicaId: 'device-b'),
    );
    doc = ProjectModel.emptyAgent() as ProjectModelDoc;
    replicaDocId = 'agent-${doc.id.value}';
    store = DocReplicaStore(storage: service.storage, actorId: 'device-b');
    // What the app's ensureMeshService does for the live store: attach it
    // to the replica's sync cycle.
    service.attachDocSync(store);
    joined.clear();
    left.clear();
  });

  tearDown(() async {
    AgentDocSurface.meshWiring = null;
    controller.dispose();
    await service.dispose();
  });

  void installWiring() {
    AgentDocSurface.meshWiring = AgentDocMeshWiring(
      routerFor:
          (final docId) => PermissionDocRouter(
            store: store,
            docId: docId,
            selfId: 'device-b',
          ),
      joinDoc: (final docId) async {
        joined.add(docId);
        await service.joinDoc(docId);
      },
      leaveDoc: (final docId) async {
        left.add(docId);
        await service.leaveDoc(docId);
      },
      statusFor:
          (final docId) => AgentDocMeshStatus(
            hosting: service.isHosting,
            connected: service.isConnected,
            peerCount: service.peers.length,
            presenceCount: service.presence(docId).length,
          ),
    );
  }

  Future<void> pumpSurface(final WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(doc: doc, controller: controller),
        ),
      ),
    );
    await tester.pump();
    await _settle(tester);
    await tester.pump();
  }

  Future<void> openProfile(final WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('coding_agent.profile.toggle')));
    await tester.pump();
  }

  testWidgets(
    'ROUTING toggle: default OFF is projected; without app wiring, '
    'enabling fails honestly in-flow (no dead ends)',
    (final tester) async {
      await pumpSurface(tester);
      await openProfile(tester);

      expect(
        find.byKey(const Key('coding_agent.routing.toggle')),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(
          find.byKey(const Key('coding_agent.routing.status')),
        ).data,
        'policy off — answering stays local',
        reason: 'default OFF: local answering, nothing written',
      );
      expect(
        AgentDocSurface.debugState?.remotePermissionRouting,
        isFalse,
        reason: 'the agent projection reads the same state (DESIGN §5)',
      );

      await tester.tap(find.byKey(const Key('coding_agent.routing.toggle')));
      await tester.pump();

      expect(
        controller.remotePermissionRouting,
        isFalse,
        reason: 'without the wiring the policy cannot turn on',
      );
      expect(controller.permissionRouter, isNull);
      expect(
        find.byKey(const Key('coding_agent.routing.error')),
        findsOneWidget,
        reason: 'the failure surfaces in-flow with the cause named (§7)',
      );
    },
  );

  testWidgets(
    'ROUTING on: the controller router attaches over the mesh-attached '
    'live store with a deterministic per-doc replica id; perm ops issued '
    'there ship through the mesh sync cycle',
    (final tester) async {
      installWiring();
      await pumpSurface(tester);
      await openProfile(tester);

      await tester.tap(find.byKey(const Key('coding_agent.routing.toggle')));
      await tester.pump();
      await _settle(tester);
      await tester.pump();

      expect(controller.remotePermissionRouting, isTrue);
      final router = controller.permissionRouter;
      expect(router, isNotNull);
      expect(identical(router!.store, store), isTrue,
          reason: 'the router rides the LIVE mesh-attached store');
      expect(
        router.docId,
        NodeId(replicaDocId),
        reason: 'the replica id is deterministic per doc',
      );
      expect(
        tester.widget<Text>(
          find.byKey(const Key('coding_agent.routing.status')),
        ).data,
        'policy on — announced as doc ops',
      );
      expect(AgentDocSurface.debugState?.remotePermissionRouting, isTrue);

      // Turning it OFF restores local answering (the policy, byte for
      // byte; the router may stay attached for the next enable).
      await tester.tap(find.byKey(const Key('coding_agent.routing.toggle')));
      await tester.pump();
      expect(controller.remotePermissionRouting, isFalse);
      expect(
        tester.widget<Text>(
          find.byKey(const Key('coding_agent.routing.status')),
        ).data,
        'policy off — answering stays local',
      );
      expect(AgentDocSurface.debugState?.remotePermissionRouting, isFalse);

      // Perm ops issued on the routed doc LAND IN SYNCED DOCS: the sync
      // cycle flushes the store's pending ops into storage.
      await controller.permissionRouter!.announceRequest(
        title: 'write main.dart',
      );
      await tester.runAsync(() => service.sync());
      expect(
        provider.files.keys,
        contains('doc_replicas/$replicaDocId.json'),
      );
    },
  );

  testWidgets(
    'presence follows the doc session: open joins the doc channel (join '
    'frame out, own presence folded), close leaves it; the status '
    'projection exposes mesh status + presence count',
    (final tester) async {
      final endpoint = _FakeEndpoint();
      addTearDown(endpoint.dispose);
      service.attachPresenceTransport(endpoint);
      installWiring();

      await pumpSurface(tester);

      expect(joined, [replicaDocId],
          reason: 'the doc session joined its channel');
      await _settle(tester);
      expect(
        endpoint.sent.where(
          (final frame) =>
              frame.docId == replicaDocId &&
              frame.event == MeshEphemeralEvent.join,
        ),
        isNotEmpty,
        reason: 'the signed join frame went out over the doc channel',
      );

      // Re-read the projection (what the app wiring does after a sync
      // cycle): the presence count now includes THIS device.
      AgentDocSurface.debugSurface!.refreshAfterMeshSync();
      await tester.pump();
      final status = AgentDocSurface.debugState?.meshStatus;
      expect(status, isNotNull);
      expect(status!.presenceCount, greaterThanOrEqualTo(1));
      expect(status.hosting, isFalse);
      expect(status.connected, isFalse,
          reason: 'no relay transport attached — honest zeros where the '
              'host observes nothing');
      expect(status.peerCount, 0);
      expect(
        AgentDocSurface.debugState!.toJson()['meshStatus'],
        containsPair('presenceCount', status.presenceCount),
        reason: 'the agent reads the same status as the human (DESIGN §5)',
      );

      // Closing the doc leaves the channel.
      await tester.pumpWidget(const SizedBox.shrink());
      await _settle(tester);
      await _settle(tester);
      expect(left, [replicaDocId]);
      expect(
        endpoint.sent.where(
          (final frame) =>
              frame.docId == replicaDocId &&
              frame.event == MeshEphemeralEvent.leave,
        ),
        isNotEmpty,
        reason: 'the leave frame goes out so peers drop this device',
      );
    },
  );
}
