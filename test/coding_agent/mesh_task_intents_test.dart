// PLAN 6.C — the mesh task console, driven through its REAL intent
// entries (mcp_toolkit `AgentCallEntry.invokeDirect`):
//
// - `mesh_task_dispatch` (the PEER): writes a requested row on the shared
//   CRDT task board; one anti-entropy exchange lands it on the owner
//   device's board;
// - the HOST surface auto-run: a remote request becomes a REAL delegated
//   turn on the owner's live harness (the scripted mover — LLM-free, the
//   `permission_doc_routing_test` pattern) and the verdict is written
//   back as board data that converges to the peer;
// - honest failure: an unrunnable request is FAILED with a named error,
//   never silently dropped;
// - viewer shadow safety: the `mesh_open_doc` shadow READS the rows and
//   never claims or runs a request;
// - named refusals when no board is attached.
//
// Two devices in one process, the file-shipping shape of
// `permission_doc_routing_test.dart`: fake providers, whole-file copy
// simulates what one anti-entropy cycle delivers. The app singleton
// (`StorageBackendsNotifier`) plays the DISPATCHING peer; the owner
// device is a local service + board wired into the doc surface through
// the `AgentDocMeshWiring` closures (the same seams home_screen installs).
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';
import 'package:lastanswer/coding_agent/permission_doc_router.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

import 'scripted_write_mover.dart';

AgentCallEntry _entry(final String name) =>
    agentMcpEntries().firstWhere((final e) => e.name == name);

/// The legacy mcpToolkitTool bridge wraps every MCPCallResult as
/// AgentResult.success — the REAL ok flag is carried in data.
bool okOf(final AgentResult result) => result.data['ok'] == true;

/// Lets unawaited board/claim chains settle.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 30));

Future<void> _waitFor(
  final bool Function() condition,
  final String reason,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  expect(condition(), isTrue, reason: reason);
}

/// Fake [StorageProvider]: in-memory map, sync is a recorded no-op —
/// tests copy files between providers to simulate what anti-entropy
/// delivers (the whole-file exchange).
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

/// The owner device: a mesh service with the task board attached over a
/// fake provider (the app-side board mounts through the notifier's own
/// seams; this one backs the HOST surface via the wiring closures).
final class _OwnerDevice {
  _OwnerDevice(final String peerId)
    : provider = _FakeProvider(),
      peerId = peerId {
    service = MeshStorageService.forTest(
      storage: StorageService(provider),
      selfId: peerId,
    );
    board = MeshTaskBoard(replicaId: peerId);
    service.attachTaskBoard(board);
  }

  final String peerId;
  final _FakeProvider provider;
  late final MeshStorageService service;
  late final MeshTaskBoard board;

  Future<void> dispose() => service.dispose();
}

/// Opens the app-side device (the DISPATCHING peer) through the
/// notifier's `meshServiceOpener` seam: a REAL service over a fake
/// provider; the notifier attaches its own board + doc seams.
Future<MeshStorageService> _openAppDevice({final String selfId = 'gate-peer'}) {
  final provider = _FakeProvider();
  final service = MeshStorageService.forTest(
    storage: StorageService(provider),
    selfId: selfId,
  );
  StorageBackendsNotifier.meshServiceOpener =
      ({
        required storePath,
        required peerId,
        relayEndpoint,
      }) => Future<MeshStorageService>.value(service);
  return StorageBackendsNotifier.instance.ensureMeshService();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // The production wiring line home_screen installs: after every sync
    // cycle the open surface re-reads the fold (and polls the console).
    StorageBackendsNotifier.onSyncCycle = () =>
        AgentDocSurface.debugSurface?.refreshAfterMeshSync();
  });

  tearDown(() async {
    await StorageBackendsNotifier.instance.leaveMesh();
    StorageBackendsNotifier.meshServiceOpener = null;
    StorageBackendsNotifier.onSyncCycle = null;
    AgentDocSurface.debugState = null;
    AgentDocSurface.debugSurface = null;
    AgentDocSurface.shadowDoc = null;
    AgentDocSurface.meshWiring = null;
  });

  group('mesh_task_dispatch / mesh_tasks (verbs)', () {
    test('refuse honestly when no board is attached', () async {
      final dispatch = await _entry('mesh_task_dispatch').invokeDirect({
        'docId': 'gate-doc',
        'task': 'Fix the thing',
      });
      expect(okOf(dispatch), isFalse, reason: dispatch.message);
      expect(dispatch.message, contains('task board'));

      final tasks = await _entry('mesh_tasks').invokeDirect({
        'docId': 'gate-doc',
      });
      expect(okOf(tasks), isFalse, reason: tasks.message);
      expect(tasks.message, contains('task board'));
      // The refusal carries the honest empty rows — never a throw.
      expect(tasks.data['tasks'], isEmpty);
    });

    test('mesh_tasks requires a doc id when nothing is open', () async {
      // The board is attached, but no agent doc is open or shadowed —
      // the verb refuses instead of guessing a target.
      await _openAppDevice();
      final tasks = await _entry('mesh_tasks').invokeDirect(const {});
      expect(okOf(tasks), isFalse, reason: tasks.message);
      expect(tasks.message, contains('docId'));
    });

    test(
      'writes a requested row (origin THIS device); one exchange lands '
      'it on the owner board; mesh_tasks reads it back',
      () async {
        final appService = await _openAppDevice();
        final owner = _OwnerDevice('gate-owner');
        addTearDown(owner.dispose);

        final dispatch = await _entry('mesh_task_dispatch').invokeDirect({
          'docId': 'gate-doc',
          'task': 'Fix the parser',
        });
        expect(okOf(dispatch), isTrue, reason: dispatch.message);
        final taskId = dispatch.data['taskId']! as String;
        expect(taskId, contains('gate-doc'));
        expect(dispatch.data['status'], 'requested');
        expect(dispatch.data['boardId']! as String, isNotEmpty);
        expect(dispatch.data['synced'], isTrue);

        // The app's own board carries the row with honest origin data.
        final appBoard = StorageBackendsNotifier.instance.taskBoard!;
        final local = appBoard.taskOf(taskId);
        expect(local, isNotNull);
        expect(local!.status, 'requested');
        expect(local.originPeerId, 'gate-peer');
        expect(local.task, 'Fix the parser');

        // One sync cycle flushed the board file into storage (the
        // service seam), then one anti-entropy fold — what the
        // whole-file exchange delivers — lands the request on the
        // OWNER board.
        await appService.sync();
        expect(
          (appService.storage.provider as _FakeProvider).files,
          contains('task_boards/agent_world.json'),
        );
        owner.board.applyRemote(appBoard.opsSince(owner.board.versionVector));
        expect(
          owner.board
              .pendingRequestsFor('gate-doc', selfPeerId: 'gate-owner')
              .map((final r) => r.taskId),
          contains(taskId),
          reason: 'the owner device must see the remote request as pending',
        );

        // mesh_tasks reads the rows back through the verb.
        final read = await _entry('mesh_tasks').invokeDirect({
          'docId': 'gate-doc',
        });
        expect(okOf(read), isTrue, reason: read.message);
        final rows = (read.data['tasks']! as List).cast<Map>();
        expect(rows, hasLength(1));
        expect(rows.single['taskId'], taskId);
        expect(rows.single['status'], 'requested');
        expect(rows.single['originPeerId'], 'gate-peer');
      },
    );
  });

  group('host auto-run (PLAN 6.C)', () {
    testWidgets(
      'peer request → sync → host surface auto-runs the scripted turn → '
      'the verdict converges to the peer board',
      (final tester) async {
        final owner = _OwnerDevice('device-b');
        addTearDown(owner.dispose);
        final controller = HarnessSessionController(
          config: HarnessHostConfig(
            handlerFactory: (_) => ScriptedWriteMover(
              'main.dart',
              "void main() { print('ok'); }\n",
            ),
          ),
        );
        addTearDown(controller.dispose);
        AgentDocSurface.meshWiring = AgentDocMeshWiring(
          routerFor:
              (final docId) => PermissionDocRouter(
                store: DocReplicaStore(
                  storage: owner.service.storage,
                  actorId: owner.peerId,
                ),
                docId: docId,
                selfId: owner.peerId,
              ),
          joinDoc: (_) async {},
          leaveDoc: (_) async {},
          statusFor: (_) => const AgentDocMeshStatus(),
          taskBoard: () => owner.board,
          selfPeerId: () => owner.peerId,
        );

        // All real async (the embedded harness, the verbs, the sync
        // cycles) runs inside `runAsync` — the widget tree itself stays
        // on the test frames. The scratch workspace is created
        // SYNCHRONOUSLY: dart:io futures never settle in the FakeAsync
        // zone outside `runAsync`.
        await tester.runAsync(() async {
          final workspace = Directory.systemTemp.createTempSync(
            'lastanswer_task_console',
          );
          addTearDown(() {
            try {
              workspace.deleteSync(recursive: true);
            } on Object {
              // best effort
            }
          });
          File(
            '${workspace.path}/main.dart',
          ).writeAsStringSync("void main() { throw StateError('no'); }\n");

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

          final docId = AgentDocSurface.debugState!.docId;

          // The host binds the scratch workspace through the REAL verb
          // (host-injected decision — never a form fill).
          final bind = await _entry('agent_doc_bind').invokeDirect({
            'workspace': workspace.path,
          });
          expect(okOf(bind), isTrue, reason: bind.message);

          // The PEER (app singleton) dispatches through the REAL verb.
          final appService = await _openAppDevice(selfId: 'device-a');
          final appBoard = StorageBackendsNotifier.instance.taskBoard!;
          final dispatch = await _entry('mesh_task_dispatch').invokeDirect({
            'docId': docId,
            'task': 'Fix main.dart so `dart run` exits 0.',
          });
          expect(okOf(dispatch), isTrue, reason: dispatch.message);
          final taskId = dispatch.data['taskId']! as String;

          // One sync cycle (flush + absorb on the peer), then one
          // anti-entropy fold — what the whole-file exchange delivers —
          // and the request sits on the owner board.
          await appService.sync();
          owner.board.applyRemote(
            appBoard.opsSince(owner.board.versionVector),
          );
          expect(owner.board.taskOf(taskId)!.status, 'requested');

          // The production wiring line: the sync cycle re-reads the
          // fold — the HOST surface claims the request and delegates.
          StorageBackendsNotifier.onSyncCycle?.call();

          // The scripted turn raises the write gate mid-turn; the host
          // side answers it (the same ALLOW mechanics as the perm gate).
          await controller.nextPermission();
          controller.answerPermission(allow: true);

          // The auto-run completes the task with the REAL turn outcome.
          await _waitFor(
            () => owner.board.taskOf(taskId)!.status == 'completed',
            'the host auto-run must complete the board task',
          );
          final record = owner.board.taskOf(taskId)!;
          expect(record.verdict?['verdict'], contains('PASS'));
          expect(record.verdict?['stopReason'], 'endTurn');
          expect(
            File('${workspace.path}/main.dart').readAsStringSync(),
            contains("print('ok')"),
            reason: 'the auto-run ran the REAL delegated turn',
          );

          // The verdict rides the mesh back; the PEER board converges.
          appBoard.applyRemote(owner.board.opsSince(appBoard.versionVector));

          final peerRecord = appBoard.taskOf(taskId)!;
          expect(peerRecord.status, 'completed');
          expect(peerRecord.verdict?['verdict'], contains('PASS'));

          // The peer reads the verdict through the verb.
          final read = await _entry('mesh_tasks').invokeDirect({
            'docId': docId,
          });
          expect(okOf(read), isTrue, reason: read.message);
          final rows = (read.data['tasks']! as List).cast<Map>();
          expect(
            rows.singleWhere((final r) => r['taskId'] == taskId)['status'],
            'completed',
          );

          // The host projection carries the console rows too (the
          // gate/agent-readable surface).
          final projected =
              (AgentDocSurface.debugState!.toJson()['tasks']! as List)
                  .cast<Map<String, Object?>>();
          expect(
            projected.singleWhere((final r) => r['taskId'] == taskId)['status'],
            'completed',
            reason: 'the host projection must expose the converged row',
          );
        });
        await tester.pump();
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    testWidgets(
      'honest failure: an unrunnable request (no bound workspace) is '
      'FAILED with a named error that reaches the peer board',
      (final tester) async {
        final owner = _OwnerDevice('device-b');
        addTearDown(owner.dispose);
        final controller = HarnessSessionController(
          // The daemon is never started: no session can exist without a
          // bound workspace — the auto-run must refuse before that.
          config: const HarnessHostConfig(handlerFactory: _throwingFactory),
        );
        addTearDown(controller.dispose);
        AgentDocSurface.meshWiring = AgentDocMeshWiring(
          routerFor: (final docId) => throw UnimplementedError(),
          joinDoc: (_) async {},
          leaveDoc: (_) async {},
          statusFor: (_) => const AgentDocMeshStatus(),
          taskBoard: () => owner.board,
          selfPeerId: () => owner.peerId,
        );
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

        await tester.runAsync(() async {
          final docId = AgentDocSurface.debugState!.docId;

          final appService = await _openAppDevice(selfId: 'device-a');
          final appBoard = StorageBackendsNotifier.instance.taskBoard!;
          final dispatch = await _entry('mesh_task_dispatch').invokeDirect({
            'docId': docId,
            'task': 'Fix main.dart so `dart run` exits 0.',
          });
          expect(okOf(dispatch), isTrue, reason: dispatch.message);
          final taskId = dispatch.data['taskId']! as String;

          await appService.sync();
          owner.board.applyRemote(appBoard.opsSince(owner.board.versionVector));

          StorageBackendsNotifier.onSyncCycle?.call();
          await _waitFor(
            () => owner.board.taskOf(taskId)!.status == 'failed',
            'the auto-run must FAIL the request (never silently drop it)',
          );
          final record = owner.board.taskOf(taskId)!;
          expect(record.verdict?['error'], contains('workspace'));

          // The named failure converges to the peer board.
          appBoard.applyRemote(owner.board.opsSince(appBoard.versionVector));
          final peerRecord = appBoard.taskOf(taskId)!;
          expect(peerRecord.status, 'failed');
          expect(peerRecord.verdict?['error'], contains('workspace'));
        });
        await tester.pump();
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    testWidgets(
      'autoRunRemoteTasks: false — the surface never claims a request',
      (final tester) async {
        final owner = _OwnerDevice('device-b');
        addTearDown(owner.dispose);
        final controller = HarnessSessionController(
          config: const HarnessHostConfig(handlerFactory: _throwingFactory),
        );
        addTearDown(controller.dispose);
        AgentDocSurface.meshWiring = AgentDocMeshWiring(
          routerFor: (final docId) => throw UnimplementedError(),
          joinDoc: (_) async {},
          leaveDoc: (_) async {},
          statusFor: (_) => const AgentDocMeshStatus(),
          taskBoard: () => owner.board,
          selfPeerId: () => owner.peerId,
          autoRunRemoteTasks: false,
        );
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

        await tester.runAsync(() async {
          final docId = AgentDocSurface.debugState!.docId;
          final taskId = owner.board.requestTask(
            docId: docId,
            task: 'Fix the thing',
            originPeerId: 'device-a',
          );
          StorageBackendsNotifier.onSyncCycle?.call();
          await _settle();
          expect(
            owner.board.taskOf(taskId)!.status,
            'requested',
            reason: 'the disabled flag must keep the request unclaimed',
          );
        });
        await tester.pump();
      },
    );
  });

  group('viewer shadow safety (PLAN 6.C)', () {
    test(
      'the mesh_open_doc shadow READS the console rows and never '
      'claims or runs a request',
      () async {
        final appService = await _openAppDevice();
        final appBoard = StorageBackendsNotifier.instance.taskBoard!;
        // A remote request sits on THIS device's board (what the owner
        // device dispatched and shipped).
        final taskId = appBoard.requestTask(
          docId: 'gate-doc',
          task: 'Fix the thing',
          originPeerId: 'gate-owner',
        );

        // The peer opens the shared doc as a viewer shadow (the REAL
        // verb) — no workspace, no daemon session, no controller.
        final opened = await _entry('mesh_open_doc').invokeDirect({
          'docId': 'gate-doc',
        });
        expect(okOf(opened), isTrue, reason: opened.message);

        // Sync cycles fire; the shadow path must never touch the row.
        await appService.sync();
        StorageBackendsNotifier.onSyncCycle?.call();
        await _settle();
        expect(appBoard.taskOf(taskId)!.status, 'requested');

        // The shadow READS the rows (the projection), never writes them.
        final state = AgentDocSurface.shadowDoc!.toDebugState();
        expect(state.viewer, isTrue);
        final rows = state.tasks;
        expect(rows.map((final r) => r['taskId']), contains(taskId));
        expect(
          rows.singleWhere((final r) => r['taskId'] == taskId)['status'],
          'requested',
        );

        // One more cycle: still untouched — no delegation was attempted.
        StorageBackendsNotifier.onSyncCycle?.call();
        await _settle();
        expect(appBoard.taskOf(taskId)!.status, 'requested');
      },
    );
  });
}

GenerationHandler _throwingFactory(final ModelRouter router) =>
    throw UnimplementedError();
