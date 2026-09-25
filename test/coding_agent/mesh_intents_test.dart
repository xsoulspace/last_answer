// Multiplayer device gates (docs/product/multiplayer-device-gates.md
// T2/T3 tooling) — intent tests for the `mesh_*` verbs. Every entry is
// driven through its REAL intent entry (mcp_toolkit
// `AgentCallEntry.invokeDirect`) against the LIVE mesh replica the app
// owns (`StorageBackendsNotifier.ensureMeshService`, swapped for an
// in-memory replica through the notifier's `meshServiceOpener` test
// seam) — no networking, real presence signing.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';

AgentCallEntry _entry(final String name) =>
    agentMcpEntries().firstWhere((final e) => e.name == name);

// The legacy mcpToolkitTool bridge wraps every MCPCallResult as
// AgentResult.success — the REAL ok flag is carried in data.
bool okOf(final AgentResult result) => result.data['ok'] == true;

/// Fake connected ephemeral transport: sends are recorded (never
/// delivered — single-app), the link is born connected, so
/// [MeshStorageService.joinDoc] opens a session whose LOCAL join op
/// folds into the tracker (self appears in presence).
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
/// (so the peer registry is live) plus a fake connected presence
/// transport (so doc sessions open and fold locally — no networking).
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
    endpoint?.dispose();
    endpoint = null;
  });

  /// Installs the opener seam + opens ONE in-memory replica; the verbs
  /// read it through `StorageBackendsNotifier.instance.meshService`.
  Future<MeshStorageService> openReplica({final String selfId = 'gate-a'}) {
    final ep = _FakeEndpoint();
    endpoint = ep;
    final service = _memoryService(selfId: selfId, endpoint: ep);
    StorageBackendsNotifier.meshServiceOpener =
        ({
          required storePath,
          required peerId,
          relayEndpoint,
        }) =>
            Future<MeshStorageService>.value(service);
    return service;
  }

  const debugDoc = AgentDocDebugState(
    docId: 'gate-doc',
    workspaces: [],
    backend: 'apple_foundation_afm',
  );

  group('mesh_status', () {
    test('refuses honestly when no replica is open', () async {
      final result = await _entry('mesh_status').invokeDirect(const {});
      expect(okOf(result), isFalse, reason: result.message);
      expect(result.data['hosting'], isFalse);
      expect(result.data['peerCount'], 0);
      expect(result.message, contains('mesh_host'));
    });

    test(
      'reads hosting/connection/peers/presence from the live service',
      () async {
        final service = await openReplica();
        await StorageBackendsNotifier.instance.ensureMeshService();
        AgentDocSurface.debugState = debugDoc;

        await _entry('mesh_join_doc').invokeDirect(const {});
        final result = await _entry('mesh_status').invokeDirect(const {});

        expect(okOf(result), isTrue, reason: result.message);
        expect(result.data['hosting'], isFalse);
        expect(result.data['connected'], isFalse);
        expect(result.data['endpoint'], isNull);
        expect(result.data['peerCount'], 0);
        expect(result.data['docChannel'], 'agent-gate-doc');
        // The local join folded: THIS device is present on its channel.
        expect(result.data['presenceCount'], greaterThanOrEqualTo(1));
        final presence = ((result.data['presence'] ?? const []) as List)
            .cast<Map<Object?, Object?>>()
            .map((final e) => e['peerId']);
        expect(presence, contains(service.selfId));
      },
    );
  });

  group('mesh_pair', () {
    test('refuses honestly on an EMPTY pairing payload', () async {
      // A MISSING payload is rejected by the schema itself
      // (AgentValidationException); an EMPTY one reaches the handler,
      // which must refuse with the honest message.
      final result = await _entry(
        'mesh_pair',
      ).invokeDirect({'pairingCode': ''});
      expect(okOf(result), isFalse, reason: result.message);
      expect(result.message, contains('pairingCode'));
    });

    test('rejects an invalid pairing code as named data', () async {
      await openReplica();
      await StorageBackendsNotifier.instance.ensureMeshService();

      final result = await _entry(
        'mesh_pair',
      ).invokeDirect({'pairingCode': 'definitely not a code'});

      expect(okOf(result), isFalse, reason: result.message);
      expect(result.message, contains('Invalid pairing code'));
    });

    test(
      'accepts a pasted payload, registers the peer, runs one cycle',
      () async {
        // The "main device" mints a hintless code (no relay in the unit
        // test); the joiner pastes it WITH trailing whitespace/newlines —
        // the paste tolerance the app flow relies on.
        final main = await _memoryService(
          selfId: 'gate-main',
          endpoint: _FakeEndpoint(),
        );
        addTearDown(main.dispose);
        final code = await main.createPairingCode();
        await openReplica();
        var syncCycles = 0;
        StorageBackendsNotifier.onSyncCycle = () => syncCycles++;
        await StorageBackendsNotifier.instance.ensureMeshService();

        final result = await _entry(
          'mesh_pair',
        ).invokeDirect({'pairingCode': '$code\n\n'});

        expect(okOf(result), isTrue, reason: result.message);
        expect(result.data['peerId'], 'gate-main');
        expect(result.data['synced'], isTrue);
        // The convergence cycle ran and projections were refreshed.
        expect(syncCycles, 1);
        expect(
          StorageBackendsNotifier.instance.meshService!.peers
              .map((final p) => p.peerId),
          contains('gate-main'),
        );
      },
    );
  });

  group('mesh_join_doc / mesh_leave_doc', () {
    test('refuses honestly when no replica is open', () async {
      AgentDocSurface.debugState = debugDoc;
      final result = await _entry('mesh_join_doc').invokeDirect(const {});
      expect(okOf(result), isFalse, reason: result.message);
      expect(result.message, contains('mesh_host'));
    });

    test('requires a doc id when no agent doc surface is open', () async {
      await openReplica();
      await StorageBackendsNotifier.instance.ensureMeshService();

      final result = await _entry('mesh_join_doc').invokeDirect(const {});

      expect(okOf(result), isFalse, reason: result.message);
      expect(result.message, contains('docId'));
    });

    test(
      'joins the deterministic channel (self present), then leaves',
      () async {
        await openReplica();
        await StorageBackendsNotifier.instance.ensureMeshService();
        AgentDocSurface.debugState = debugDoc;

        final joined = await _entry('mesh_join_doc').invokeDirect(const {});
        expect(okOf(joined), isTrue, reason: joined.message);
        // The channel matches the doc surface's mesh doc id exactly —
        // agent verbs and the human flow ride ONE channel.
        expect(joined.data['docChannel'], 'agent-gate-doc');
        expect(joined.data['presenceCount'], greaterThanOrEqualTo(1));

        final left = await _entry('mesh_leave_doc').invokeDirect(const {});
        expect(okOf(left), isTrue, reason: left.message);
        expect(left.data['docChannel'], 'agent-gate-doc');
        // The leave dropped the local entry (peers drop on the frame OR
        // the ttl sweep; the local fold is immediate).
        final status = await _entry('mesh_status').invokeDirect(
          const {'docId': 'gate-doc'},
        );
        expect(okOf(status), isTrue);
        expect(status.data['presenceCount'], 0);
      },
    );

    test('explicit docId overrides the open-surface default', () async {
      await openReplica();
      await StorageBackendsNotifier.instance.ensureMeshService();
      AgentDocSurface.debugState = debugDoc;

      final result = await _entry(
        'mesh_join_doc',
      ).invokeDirect({'docId': 'other-doc'});

      expect(okOf(result), isTrue, reason: result.message);
      expect(result.data['docId'], 'other-doc');
      expect(result.data['docChannel'], 'agent-other-doc');
    });
  });
}
