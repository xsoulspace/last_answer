// PLAN 5c — the peer-side surface gate (DESIGN §9): remote permission
// requests render IN-FLOW as PERM rows with an origin label in the
// gutter, same reject-first ordering as local requests, answerable
// through the REAL widget keys — no modals, no separate pane. The
// decision is recorded as doc data (the answer op).
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

const _docId = NodeId('agent-doc');

/// Lets the surface's async chains (ensureStarted, answer op) settle.
Future<void> _settle(final WidgetTester tester) => tester.runAsync(
  () => Future<void>.delayed(const Duration(milliseconds: 30)),
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

void main() {
  late _FakeProvider provider;
  late MeshStorageService service;
  late DocReplicaStore store;
  late ActorRoster roster;
  late HarnessSessionController controller;

  setUp(() async {
    provider = _FakeProvider();
    service = MeshStorageService.forTest(
      storage: StorageService(provider),
      selfId: 'device-b',
    );
    store = DocReplicaStore(storage: service.storage, actorId: 'device-b');
    roster = ActorRoster(replicaId: 'device-b');
    controller = HarnessSessionController(
      // Scripted, LLM-free: the peer device never delegates; the daemon
      // just idles under the surface (the surface always starts it).
      config: HarnessHostConfig(
        handlerFactory: (_) => throw UnimplementedError(),
      ),
      roster: roster,
    );
    service
      ..attachDocSync(store)
      ..attachRoster(roster);
    await store.open(_docId);
    // The acting agent, resolved through the roster replica (the mesh
    // synced it from the owner — E seam; here it is pre-seeded).
    roster.upsert(
      const ActorProfile(actorId: 'afm-coder', displayName: 'AFM Coder'),
    );
    controller.attachPermissionRouter(
      PermissionDocRouter(store: store, docId: _docId, selfId: 'device-b'),
    );
    // A pending permission announced by the OWNER device (device-a) — the
    // op as it arrives through the doc replica.
    await store.edit(
      _docId,
      (final replica) => replica.announcePermRequest(
        requestId: 'perm-1',
        title: 'write main.dart',
        originPeerId: 'device-a',
        originActorId: 'afm-coder',
      ),
    );
  });

  tearDown(() async {
    controller.dispose();
    await service.dispose();
  });

  Future<void> pumpSurface(final WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(
            doc: ProjectModel.emptyAgent() as ProjectModelDoc,
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pump();
    await _settle(tester);
    // The app wiring refreshes after every mesh sync cycle; the remote
    // row is already in the fold here.
    controller.refreshPermissions();
    await tester.pump();
  }

  testWidgets(
    'a remote pending permission renders in-flow: PERM row, origin label '
    'in the gutter (roster-resolved), reject-first ordering',
    (final tester) async {
      await pumpSurface(tester);

      expect(
        find.byKey(const Key('coding_agent.perm.perm-1')),
        findsOneWidget,
        reason: 'the remote request renders in the flow',
      );
      expect(
        find.byKey(const Key('coding_agent.perm.perm-1.origin')),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(
          find.byKey(const Key('coding_agent.perm.perm-1.origin')),
        ).data,
        'AFM-CODER',
        reason: 'the gutter label resolves through the roster (DESIGN §9)',
      );
      expect(find.textContaining('write main.dart'), findsWidgets);
      expect(find.textContaining('awaiting…'), findsWidgets);

      // Same reject-first ordering as the local row (ADR 0005 §5): the
      // deny action comes first on the grid.
      final rejectRect = tester.getRect(
        find.byKey(const Key('coding_agent.perm.perm-1.reject')),
      );
      final allowRect = tester.getRect(
        find.byKey(const Key('coding_agent.perm.perm-1.allow')),
      );
      expect(rejectRect.left, lessThan(allowRect.left));
    },
  );

  testWidgets(
    'answering through the real key records the decision as data — the '
    'row keeps the outcome visible, the actions go away',
    (final tester) async {
      await pumpSurface(tester);

      await tester.tap(
        find.byKey(const Key('coding_agent.perm.perm-1.allow')),
      );
      await tester.pump();
      await _settle(tester);
      await tester.pump();

      final record = store.replicaOf(_docId)!.permRequestOf('perm-1')!;
      expect(
        record.status,
        PermRequestStatus.allow,
        reason: 'the answer is a doc op — recorded as data',
      );
      expect(record.responderPeerId, 'device-b');

      // One state, many projections (DESIGN §5): the row shows the
      // outcome, no actions remain.
      expect(find.textContaining('→  allow'), findsWidgets);
      expect(
        find.byKey(const Key('coding_agent.perm.perm-1.allow')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('coding_agent.perm.perm-1.reject')),
        findsNothing,
      );
      expect(
        controller.remotePermissions.single.status,
        PermRequestStatus.allow,
        reason: 'the agent projection reads the same state',
      );
    },
  );
  testWidgets(
    'an answered remote request keeps the decision visible — the outcome '
    'renders, the actions do not come back',
    (final tester) async {
      await store.edit(
        _docId,
        (final replica) => replica.answerPermRequest(
          requestId: 'perm-1',
          allow: false,
          responderPeerId: 'device-b',
        ),
      );
      await pumpSurface(tester);

      // The row renders with the recorded outcome (data, never dropped —
      // DESIGN §4) and no actions.
      expect(find.byKey(const Key('coding_agent.perm.perm-1')), findsOneWidget);
      expect(find.textContaining('→  reject'), findsWidgets);
      expect(
        find.byKey(const Key('coding_agent.perm.perm-1.allow')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('coding_agent.perm.perm-1.reject')),
        findsNothing,
      );
    },
  );
}
