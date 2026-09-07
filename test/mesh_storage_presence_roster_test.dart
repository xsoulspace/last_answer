import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';

/// PLAN 5c wiring tests: roster + presence ride [MeshStorageService]
/// (ADR 0031 §1–4, ADR 0007 §1–2).
///
/// Everything runs against in-memory storage and an in-proc fake
/// ephemeral-frame hub — no networking. Roster sync is exercised through
/// the same whole-file exchange the D doc-sync seam uses (fake provider,
/// tests copy peer files to simulate what anti-entropy delivers);
/// presence is exercised through the service's test-transport seam with
/// real Ed25519 signing.

const _docId = 'doc-1';

/// Lets async signing/verification chains and cross-endpoint delivery
/// settle.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 30));

/// Fake [StorageProvider]: in-memory map, sync is a recorded no-op, and
/// tests inject "remote" files to simulate what anti-entropy delivers.
final class _FakeProvider extends StorageProvider {
  final Map<String, String> files = {};
  final List<String> syncLog = [];

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
  }) async {
    syncLog.add(files.keys.join(','));
  }

  @override
  Future<void> dispose() async {}
}

/// In-proc fake ephemeral transport pair-hub (ADR 0031 §2: any transport
/// plugs in without touching the session). [send] fans out to every other
/// endpoint, mirroring the relay's broadcast; endpoints can simulate
/// connection loss and recovery.
final class _FakeEndpoint implements EphemeralFrameTransport {
  _FakeEndpoint(this.peerId, this._hub);

  final String peerId;
  final _FakeHub _hub;
  final _frames = StreamController<MeshEphemeralFrame>();
  final _changes = StreamController<EphemeralLinkState>.broadcast();
  final List<MeshEphemeralFrame> sent = [];
  var _state = EphemeralLinkState.connected;

  @override
  EphemeralLinkState get connectionState => _state;

  @override
  Stream<EphemeralLinkState> get connectionChanges => _changes.stream;

  @override
  Stream<MeshEphemeralFrame> get frames => _frames.stream;

  @override
  Future<void> send(final MeshEphemeralFrame frame) async {
    sent.add(frame);
    _hub._deliverFrom(peerId, frame);
  }

  void _receive(final MeshEphemeralFrame frame) {
    _frames.add(frame);
  }

  void disconnect() {
    _state = EphemeralLinkState.disconnected;
    _changes.add(_state);
  }

  void reconnect() {
    _state = EphemeralLinkState.connected;
    _changes.add(_state);
  }

  /// Never awaited: a listener-less single-subscription controller's
  /// close future does not complete.
  void dispose() {
    unawaited(_frames.close());
    unawaited(_changes.close());
  }
}

final class _FakeHub {
  final Map<String, _FakeEndpoint> _endpoints = {};

  _FakeEndpoint endpoint(final String peerId) => _endpoints.putIfAbsent(
    peerId,
    () => _FakeEndpoint(peerId, this),
  );

  void _deliverFrom(final String from, final MeshEphemeralFrame frame) {
    for (final endpoint in _endpoints.values) {
      if (endpoint.peerId != from) endpoint._receive(frame);
    }
  }
}

final _keyPairs = <String, SimpleKeyPair>{};

Future<SimpleKeyPair> _keyPairOf(final String peerId) async =>
    _keyPairs[peerId] ??= await PairingService.newIdentityKeyPair();

Future<List<int>> _publicKeyOf(final String peerId) async =>
    (await (await _keyPairOf(peerId)).extractPublicKey()).bytes;

Future<MeshStorageService> _service({
  required final String selfId,
  required final _FakeProvider provider,
}) async => MeshStorageService.forTest(
  storage: StorageService(provider),
  selfId: selfId,
  identityKeyPair: await _keyPairOf(selfId),
);

/// Cross-registers both devices' identity keys, as pairing would
/// (ADR 0031 §3: registration is a pairing outcome).
Future<void> _knowsEachOther(
  final MeshStorageService a,
  final MeshStorageService b,
) async {
  a.registerPeerIdentityKey(
    peerId: b.selfId,
    identityKey: await _publicKeyOf(b.selfId),
  );
  b.registerPeerIdentityKey(
    peerId: a.selfId,
    identityKey: await _publicKeyOf(a.selfId),
  );
}

void main() {
  tearDown(() {
    for (final endpoint in _endpointsUnderTest) {
      endpoint.dispose();
    }
  });

  test('attachRoster forces the roster replica id to the pairing peer id',
      () async {
    final service = await _service(
      selfId: 'device-a',
      provider: _FakeProvider(),
    );
    addTearDown(service.dispose);
    final roster = ActorRoster(replicaId: 'placeholder')
      ..upsert(const ActorProfile(actorId: 'afm', displayName: 'AFM'));
    service.attachRoster(roster);
    // ADR 0007 §2: the roster's replica id IS the pairing peer id; the
    // placeholder is replaced at attach time WITHOUT losing state.
    expect(roster.replicaId, 'device-a');
    expect(roster.get('afm')?.displayName, 'AFM');
  });

  test('roster syncs as durable ops between two services and converges '
      '(shuffled delivery)', () async {
    final providerA = _FakeProvider();
    final providerB = _FakeProvider();
    final a = await _service(selfId: 'device-a', provider: providerA);
    final b = await _service(selfId: 'device-b', provider: providerB);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final rosterA = ActorRoster(replicaId: 'placeholder');
    final rosterB = ActorRoster(replicaId: 'placeholder');
    a.attachRoster(rosterA);
    b.attachRoster(rosterB);
    rosterA.upsert(
      const ActorProfile(actorId: 'afm', displayName: 'AFM Coder'),
    );
    rosterB.upsert(
      const ActorProfile(actorId: 'pi', displayName: 'pi', role: 'reviewer'),
    );

    String fileOf(final String peerId) =>
        'actor_rosters/$peerId.json';

    // Shuffled delivery: each side flushes, the other absorbs — and the
    // Shuffled delivery: copies alternate directions across cycles, and
    // later hops carry each side's MERGED log. Convergence rests on the
    // kernel (VV dedupe + order-free fold), not file ordering.
    await a.sync(); // A flushes its roster file.
    providerB.files[fileOf('device-a')] =
        providerA.files[fileOf('device-a')]!; // A's ops reach B.
    await b.sync(); // B flushes, then absorbs A's ops.
    providerA.files[fileOf('device-b')] =
        providerB.files[fileOf('device-b')]!; // B's (merged) file → A.
    await a.sync(); // A absorbs B's merged log.
    providerB.files[fileOf('device-a')] =
        providerA.files[fileOf('device-a')]!; // A's merged file → B.
    await b.sync();
    await a.sync(); // One extra cycle both ways: nothing changes.
    providerA.files[fileOf('device-b')] =
        providerB.files[fileOf('device-b')]!;
    await a.sync();

    List<String> namesOf(final ActorRoster roster) =>
        roster.all.map((final p) => '${p.actorId}:${p.displayName}').toList();
    expect(namesOf(rosterA), containsAll(<String>['afm:AFM Coder', 'pi:pi']));
    expect(namesOf(rosterB), containsAll(<String>['afm:AFM Coder', 'pi:pi']));
    expect(namesOf(rosterA), namesOf(rosterB)); // Converged identically.
    expect(rosterB.get('pi')?.role, 'reviewer');
  });

  test('roster tombstones propagate as durable ops', () async {
    final providerA = _FakeProvider();
    final providerB = _FakeProvider();
    final a = await _service(selfId: 'device-a', provider: providerA);
    final b = await _service(selfId: 'device-b', provider: providerB);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final rosterA = ActorRoster(replicaId: 'device-a');
    final rosterB = ActorRoster(replicaId: 'device-b');
    a.attachRoster(rosterA);
    b.attachRoster(rosterB);
    rosterA.upsert(const ActorProfile(actorId: 'afm', displayName: 'AFM'));
    await a.sync();
    providerB.files['actor_rosters/device-a.json'] =
        providerA.files['actor_rosters/device-a.json']!;
    await b.sync();
    expect(rosterB.contains('afm'), isTrue);

    expect(rosterA.remove('afm'), isTrue);
    await a.sync();
    providerB.files['actor_rosters/device-a.json'] =
        providerA.files['actor_rosters/device-a.json']!;
    await b.sync();
    expect(rosterB.contains('afm'), isFalse); // Tombstone won.
  });

  test('presence join/ping/leave between two signed services — '
      'folds agree on both sides', () async {
    final hub = _FakeHub();
    final endpointA = hub.endpoint('device-a');
    final endpointB = hub.endpoint('device-b');
    _endpointsUnderTest
      ..add(endpointA)
      ..add(endpointB);
    final a = await _service(
      selfId: 'device-a',
      provider: _FakeProvider(),
    );
    final b = await _service(
      selfId: 'device-b',
      provider: _FakeProvider(),
    );
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    await _knowsEachOther(a, b);
    a.attachPresenceTransport(endpointA);
    b.attachPresenceTransport(endpointB);

    await a.joinDoc(_docId); // A joins before B's session exists: frames
    await b.joinDoc(_docId); // buffer until the peer listens.
    await a.notifyPresenceActivity(_docId);
    await b.notifyPresenceActivity(_docId);
    await _settle();

    Set<String> foldOf(final MeshStorageService service) =>
        service.presence(_docId).map((final entry) => entry.peerId).toSet();
    expect(foldOf(a), {'device-a', 'device-b'});
    expect(foldOf(b), {'device-a', 'device-b'});
    // Every observed frame verified against the registered peer key.
    expect(a.rejectedPresenceFrameCount, 0);
    expect(b.rejectedPresenceFrameCount, 0);

    await a.leaveDoc(_docId);
    await _settle();
    expect(foldOf(a), {'device-b'}); // Leave tombstoned locally too.
    expect(foldOf(b), {'device-b'}); // Peer dropped immediately.
  });

  test('unknown peer TOFU-binds on first signed frame; unsigned and '
      'key-mismatched frames are rejected as named data', () async {
    final hub = _FakeHub();
    final endpointB = hub.endpoint('device-b');
    final endpointC = hub.endpoint('device-c');
    _endpointsUnderTest
      ..add(endpointB)
      ..add(endpointC);
    final b = await _service(
      selfId: 'device-b',
      provider: _FakeProvider(),
    );
    // device-c signs with its own keypair; b has never seen the key.
    // Relay-owned TOFU (ADR 0031 §3 v1) binds peerId → key on the first
    // VERIFIED frame and registers the peer — the asymmetric-pairing
    // deadlock fix (history.md, squad 4 / task M).
    final c = await _service(
      selfId: 'device-c',
      provider: _FakeProvider(),
    );
    addTearDown(b.dispose);
    addTearDown(c.dispose);
    b.attachPresenceTransport(endpointB);
    c.attachPresenceTransport(endpointC);
    await b.joinDoc(_docId);
    await c.joinDoc(_docId);
    await _settle();

    // c's first signed frame: TOFU-bound, folded, no rejection.
    expect(
      b.presence(_docId).map((final entry) => entry.peerId),
      containsAll(['device-b', 'device-c']),
    );
    expect(b.rejectedPresenceFrameCount, 0);

    // An UNSIGNED ghost frame injected raw: dropped for a named reason.
    final ghost = MeshPresenceTracker(actorId: 'device-ghost');
    final unsigned = ghost.announce(
      docId: _docId,
      event: MeshEphemeralEvent.join,
    );
    endpointB._receive(unsigned);
    await _settle();
    expect(b.rejectedPresenceFrameCount, 1);
    expect(
      b.presenceFrameRejections.last.reason,
      MeshFrameRejectionReason.unsigned,
    );
    expect(
      b.presence(_docId).map((final entry) => entry.peerId),
      isNot(contains('device-ghost')),
    );

    // A frame claiming device-c but signed by a DIFFERENT key: the pin
    // holds — rejected, c's presence entry unchanged (TOFU never
    // overwrites a pin).
    final rogue = MeshPresenceTracker(actorId: 'device-c');
    final rogueFrame = rogue.announce(
      docId: _docId,
      event: MeshEphemeralEvent.join,
    );
    final rogueSigner = MeshFrameSigner(
      identityKeyPair: await _keyPairOf('device-c-rogue'),
    );
    endpointB._receive(await rogueSigner.sign(rogueFrame));
    await _settle();
    expect(b.rejectedPresenceFrameCount, 2);
    expect(
      b.presenceFrameRejections.last.reason,
      MeshFrameRejectionReason.unauthenticated,
    );
    expect(
      b.presence(_docId).map((final entry) => entry.peerId),
      contains('device-c'),
    );
  });

  test('connection loss stops pings; reconnect re-joins', () async {
    final hub = _FakeHub();
    final endpointA = hub.endpoint('device-a');
    final endpointB = hub.endpoint('device-b');
    _endpointsUnderTest
      ..add(endpointA)
      ..add(endpointB);
    final a = await _service(
      selfId: 'device-a',
      provider: _FakeProvider(),
    );
    final b = await _service(
      selfId: 'device-b',
      provider: _FakeProvider(),
    );
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    await _knowsEachOther(a, b);
    a.attachPresenceTransport(endpointA);
    b.attachPresenceTransport(endpointB);
    await a.joinDoc(_docId);
    await b.joinDoc(_docId);
    await _settle();
    expect(
      b.presence(_docId).map((final entry) => entry.peerId),
      containsAll(['device-a', 'device-b']),
    );

    endpointA.disconnect(); // The link drops.
    await _settle(); // A's session tears down (best-effort leave).
    final framesAfterLoss = endpointA.sent.length;
    await a.notifyPresenceActivity(_docId); // Must be a no-op now.
    await _settle();
    expect(endpointA.sent.length, framesAfterLoss); // Pings stopped.

    endpointA.reconnect(); // The link comes back: lifecycle resumes.
    await _settle();
    expect(
      a.presence(_docId).map((final entry) => entry.peerId).toSet(),
      {'device-a', 'device-b'},
    );
  });

  test('dispose leaves gracefully — a leave frame goes out', () async {
    final hub = _FakeHub();
    final endpointA = hub.endpoint('device-a');
    final endpointB = hub.endpoint('device-b');
    _endpointsUnderTest
      ..add(endpointA)
      ..add(endpointB);
    final a = await _service(
      selfId: 'device-a',
      provider: _FakeProvider(),
    );
    final b = await _service(
      selfId: 'device-b',
      provider: _FakeProvider(),
    );
    addTearDown(b.dispose);
    await _knowsEachOther(a, b);
    a.attachPresenceTransport(endpointA);
    b.attachPresenceTransport(endpointB);
    await a.joinDoc(_docId);
    await b.joinDoc(_docId);
    await _settle();

    final sentBefore = endpointA.sent.length;
    await a.dispose();
    expect(endpointA.sent.length, greaterThan(sentBefore));
    expect(endpointA.sent.last.event, MeshEphemeralEvent.leave);
    expect(endpointA.sent.last.fromPeerId, 'device-a');
    await _settle();
    expect(
      b.presence(_docId).map((final entry) => entry.peerId),
      isNot(contains('device-a')),
    );
  });
}

/// Endpoints registered by the currently running test, disposed in
/// [main]'s tearDown.
final _endpointsUnderTest = <_FakeEndpoint>{};
