import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:headless_core/headless_core.dart' show DocReplicaStore;
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';
import 'package:lastanswer/coding_agent/world_inspector/paired_worlds.dart';
import 'package:lastanswer/settings/features/mesh_relay_host_stub.dart'
    if (dart.library.io) 'mesh_relay_host_io.dart' as relay_host;
import 'package:lastanswer/settings/features/mesh_sync_participants.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';
import 'package:universal_storage_world/universal_storage_world.dart';

/// Owns one cross-platform mesh replica, its WebSocket transport, and
/// (on dart:io platforms) the locally hosted relay of a "main device".
///
/// ADR 0047 §3: the SYNC BRAIN lives in the package now — this service is
/// the app's thin wiring around a [MeshWorldSession]: it owns the
/// app-specific halves (relay hosting, pairing with harness-world
/// announcements, the payload backup file) and adapts Last Answer's
/// durable state ([DocReplicaStore]s, [RosterParticipant], the
/// [TaskBoardParticipant]) onto the session's participant seam. Presence,
/// the sync cycle, and scheduling are the session's.
///
/// The user-facing contract is intentionally tiny:
///  - [createPairingCode] → show as QR / offer to copy.
///  - [acceptPairingCode] → verify, register the peer and connect to
///    its advertised relay automatically. No manual endpoints.
final class MeshStorageService {
  MeshStorageService._({
    required this.storage,
    required this.selfId,
    this._transport,
  }) : _session = MeshWorldSession(storage: storage, selfId: selfId) {
    // Pairing and presence funnel through ONE identity keypair: peers
    // register us by the pairing key, so presence frames must be signed
    // by that same identity (ADR 0031 §3).
    _session.identityKeyPairProvider = _ensureIdentity;
  }

  /// Production code goes through [open]; tests inject a
  /// provider-agnostic [StorageService] to exercise the doc-sync seam
  /// without networking. [identityKeyPair] pins THIS device's pairing
  /// identity keypair so presence frames are signed deterministically in
  /// tests; when omitted, one is generated on first use.
  @visibleForTesting
  MeshStorageService.forTest({
    required this.storage,
    required this.selfId,
    // Private field, named parameter: an initializing formal is impossible
    // here (private named params do not exist).
    final SimpleKeyPair? identityKeyPair,
  }) : _identityKeyPair = identityKeyPair,
       // Private field, named parameter: an initializing formal is
       // impossible here (private named params do not exist).
       // ignore: prefer_initializing_formals
       _session = MeshWorldSession(storage: storage, selfId: selfId) {
    _session.identityKeyPairProvider = _ensureIdentity;
  }

  final StorageService storage;
  final String selfId;

  /// The extracted sync brain (ADR 0047 §3): participants, pulse cycle,
  /// presence, interest. This service owns only app wiring around it.
  final MeshWorldSession _session;

  static const _dataFile = 'last-answer-data.json';

  /// Whether this platform can host a relay ("main device" capable):
  /// true wherever dart:io exists, false on web.
  static bool get canHostRelay => relay_host.canHostRelay;

  final relay_host.LocalRelayHost _relayHost = relay_host.LocalRelayHost();
  AddressedRelayClient? _transport;

  SimpleKeyPair? _identityKeyPair;
  Future<SimpleKeyPair>? _identityFuture;
  MeshPairingSession? _advertisement;

  /// Last transport failure, surfaced for status lines / debugging.
  Object? connectError;

  /// Invoked after every background sync cycle (success or failure) —
  /// the embedding app refreshes its projections from the fold here.
  void Function()? get onCycle => _session.onCycle;
  set onCycle(final void Function()? value) => _session.onCycle = value;

  // -- Presence (delegated to the session, ADR 0031 §1–2) ------------------

  /// Cadence policy for the presence sessions this service opens
  /// (ADR 0031 §5: policy-with-bounds, chosen by the embedding app).
  PresenceConfig get presenceConfig => _session.presenceConfig;
  set presenceConfig(final PresenceConfig value) =>
      _session.presenceConfig = value;

  /// Endpoint peers should use to reach this device's hosted relay.
  Uri? advertisedEndpoint;

  bool get isHosting => _relayHost.isRunning;

  bool get isConnected => _transport != null;

  /// Relay endpoint this replica is currently connected through.
  Uri? get connectedEndpoint => _transport?.endpoint;

  Iterable<MeshPeerRecord> get peers {
    final provider = storage.provider;
    return provider is MeshStorageProvider ? provider.peers : const [];
  }

  /// Opens a replica. When [relayEndpoint] is given, the transport
  /// connects eagerly; failures are recorded in [connectError] instead
  /// of blocking startup ("Sync now" / pairing retries later).
  static Future<MeshStorageService> open({
    required final String storePath,
    required final String peerId,
    final Uri? relayEndpoint,
    final String displayName = 'Last Answer',
  }) async {
    final provider = MeshStorageProvider();
    await provider.initWithConfig(
      MeshStorageConfig(
        storePath: storePath,
        peerId: peerId,
        displayName: displayName,
      ),
    );
    AddressedRelayClient? transport;
    MeshStorageService? service;
    if (relayEndpoint != null && relayEndpoint.hasScheme) {
      service = MeshStorageService._(
        storage: StorageService(provider),
        selfId: peerId,
      );
      try {
        // Bounded like [connectTo]: a stale/unreachable persisted relay
        // must not block startup on the OS TCP timeout.
        transport = await _openClient(selfId: peerId, endpoint: relayEndpoint)
            .timeout(const Duration(seconds: 5));
        service._transport = transport;
        provider.attachTransport(transport);
        service._session.attachRelayPresenceLink(transport);
      } on Exception catch (error) {
        transport = null;
        // Deferred: pairing and "Sync now" surface it to the user.
        // ignore: avoid_print
        print('mesh: relay connect failed: $error');
      }
    }
    return service ??
        MeshStorageService._(
          storage: StorageService(provider),
          selfId: peerId,
          transport: transport,
        );
  }

  static Future<AddressedRelayClient> _openClient({
    required final String selfId,
    required final Uri endpoint,
  }) async {
    final client = AddressedRelayClient(selfId: selfId, endpoint: endpoint);
    await client.openRelay();
    return client;
  }

  /// Starts this device's local fan-out relay ("main device") and
  /// connects the local replica through loopback. Returns the LAN
  /// endpoint embedded into pairing codes.
  Future<Uri> startHosting({final int port = 0}) async {
    final bindEndpoint = await _relayHost.start(port: port);
    final host = await relay_host.detectAdvertiseAddress();
    advertisedEndpoint = Uri.parse('ws://$host:${bindEndpoint.port}');
    await connectTo(bindEndpoint);
    return advertisedEndpoint!;
  }

  Future<void> stopHosting() async {
    await _relayHost.stop();
    advertisedEndpoint = null;
  }

  /// (Re)points the replica transport at [endpoint].
  Future<void> connectTo(final Uri endpoint) async {
    if (_transport != null && _transport!.endpoint == endpoint) return;
    connectError = null;
    final old = _transport;
    _transport = null;
    unawaited(old?.close());
    try {
      // Bounded: an unreachable endpoint (stale persisted relay, LAN
      // address blocked by macOS Local Network TCC for terminal-launched
      // apps) must not wedge callers for the ~75 s OS TCP timeout — it
      // degrades to the documented deferred-connect path instead.
      final client = await _openClient(selfId: selfId, endpoint: endpoint)
          .timeout(const Duration(seconds: 5));
      _transport = client;
      final provider = storage.provider;
      if (provider is MeshStorageProvider) provider.attachTransport(client);
      _session.attachRelayPresenceLink(client);
    } on Object catch (error) {
      connectError = error;
      rethrow;
    }
  }

  /// Signed pairing code advertising this device; embeds the hosted
  /// relay endpoint (or current connection endpoint) so scanners never
  /// type addresses. [applicationData] rides the SIGNED envelope as
  /// opaque payload (ADR 0072: e.g. the host's harness-world
  /// announcement) — the mesh carries it, the scanner's app reads it.
  Future<String> createPairingCode({
    final Map<String, Object?>? applicationData,
  }) async {
    final hint = (advertisedEndpoint ?? _transport?.endpoint)?.toString();
    _advertisement ??= MeshPairingSession(
      selfId: selfId,
      identityKeyPair: await _ensureIdentity(),
      transportHint: hint,
      applicationData: applicationData,
    );
    return base64Encode(await _advertisement!.createQrPayload());
  }

  /// Verifies [code], registers the peer, and auto-connects to its
  /// advertised relay. A fresh session per call, so one main device
  /// can accept several secondaries one after another.
  Future<MeshPeerRecord> acceptPairingCode(final String code) async {
    final payload = decodePairingCode(code);
    final session = MeshPairingSession(
      selfId: selfId,
      identityKeyPair: await _ensureIdentity(),
    );
    final peer = await session.acceptQrPayload(payload);
    // ADR 0072 — the verified envelope may carry the peer's harness
    // worlds (signed application data): store them in the paired-worlds
    // registry so the inspector can attach WITHOUT a filesystem scan.
    // Failures here never break the pairing itself.
    try {
      final data = peer.endpointHints['data'];
      if (data != null) {
        final decoded = jsonDecode(data);
        if (decoded is Map && decoded['worlds'] is List) {
          await PairedWorlds.storeAnnouncement(
            decoded['worlds'] as List?,
          );
        }
      }
    } on Object catch (_) {
      // A malformed announcement is a dropped convenience, not a pair
      // failure.
    }
    final provider = storage.provider;
    if (provider is! MeshStorageProvider) {
      throw StateError('Mesh service is not initialized');
    }
    await provider.registerPeer(peer);
    _registerPeerIdentityKey(peer);
    if (peer.endpointHints['ws'] case final String value?) {
      final uri = Uri.tryParse(value);
      if (uri != null &&
          uri.hasScheme &&
          (!isHosting || uri != advertisedEndpoint)) {
        await connectTo(uri);
      }
    }
    return peer;
  }

  /// Manual peer registration for advanced/debug flows.
  Future<MeshPeerRecord> registerPeer({
    required final String peerId,
    final String displayName = 'Peer',
    final List<int> identityKey = const [],
  }) async {
    final provider = storage.provider;
    if (provider is! MeshStorageProvider) {
      throw StateError('Mesh service is not initialized');
    }
    final record = MeshPeerRecord(
      peerId: peerId,
      displayName: displayName,
      identityKey: identityKey,
    );
    await provider.registerPeer(record);
    _registerPeerIdentityKey(record);
    return record;
  }

  Future<void> backup(final String jsonPayload) =>
      storage.saveFile(_dataFile, jsonPayload, message: 'mesh backup');

  Future<String?> restore() => storage.readFile(_dataFile);

  /// Registers [store] with the mesh sync cycle (ADR 0047 §3): every
  /// [sync] flushes its pending ops before anti-entropy, folds delivered
  /// state after, and compacts last. Registration only — nothing is
  /// written until the next cycle. The store's storage should be the
  /// SAME [StorageService] this service owns so flushed files actually
  /// participate in anti-entropy. This service never disposes the store.
  void attachDocSync(final DocReplicaStore store) {
    _session.attachParticipant(DocSyncParticipant(store));
  }

  /// Attaches the actor roster (ADR 0007 §1): ordinary durable kernel
  /// state that rides the mesh as a [RosterParticipant]. The roster's
  /// replica id is forced to this service's pairing peer id (ADR 0007
  /// §2). The caller keeps ownership (lifecycle, dispose).
  void attachRoster(final ActorRoster roster) {
    roster.forceReplicaId(selfId);
    _session.attachParticipant(RosterParticipant(roster));
  }

  /// Attaches the mesh task board as a [TaskBoardParticipant]; the
  /// board's replica id is fixed at construction
  /// ([MeshTaskBoard.replicaId]). The caller keeps ownership (lifecycle,
  /// dispose).
  void attachTaskBoard(final MeshTaskBoard board) {
    _taskBoard = board;
    _session.attachParticipant(TaskBoardParticipant(board));
  }

  MeshTaskBoard? _taskBoard;

  /// The live task board, null until [attachTaskBoard].
  MeshTaskBoard? get taskBoard => _taskBoard;

  /// Joins [docId]'s presence channel. Doc-scoped join is the CALLER's
  /// job (ADR 0031 §1).
  Future<void> joinDoc(final String docId) => _session.joinDoc(docId);

  /// Leaves [docId]'s presence channel (signed leave frame).
  Future<void> leaveDoc(final String docId) => _session.leaveDoc(docId);

  /// Liveness refresh on the doc's channel (ADR 0031 §5: ping on
  /// activity). Best-effort.
  Future<void> notifyPresenceActivity(final String docId) =>
      _session.notifyPresenceActivity(docId);

  /// Live presence for [docId] — the tracker fold over unexpired
  /// ephemeral ops (ADR 0029 §1, ADR 0031 §2). Agent-queryable state.
  List<MeshPresenceEntry> presence(
    final String docId, {
    final DateTime? now,
  }) => _session.presence(docId, now: now);

  /// How many inbound presence frames were dropped as named data
  /// (ADR 0031 §3).
  int get rejectedPresenceFrameCount =>
      _session.rejectedPresenceFrameCount;

  /// Every dropped presence frame with its rejection reason, oldest
  /// first.
  List<MeshFrameRejection> get presenceFrameRejections =>
      _session.presenceFrameRejections;

  /// Anti-entropy exchange with every known peer, wrapped in the
  /// participant seam. Wrapped in a timeout because an addressed relay
  /// silently drops frames addressed to offline peers; without it
  /// "Sync now" hangs.
  Future<void> sync({
    final Duration timeout = const Duration(minutes: 1),
  }) => _session.sync(timeout: timeout);

  /// Publishes what this replica wants DELIVERED (ADR 0048 §2): the
  /// interest policy is resolved immediately and re-published every
  /// cycle; null clears back to the wildcard.
  void setInterest(final InterestPolicy? policy) =>
      _session.setInterest(policy);

  // -- Periodic sync (the pulse convenience adapter; ADR 0047 §4) ----------

  /// Runs [sync] every [interval]. A tick landing while a sync cycle is
  /// still in flight is skipped, never queued — the next tick picks the
  /// work up.
  void startPeriodicSync({
    final Duration interval = const Duration(seconds: 30),
  }) => _session.startPeriodicPulse(interval: interval);

  void stopPeriodicSync() => _session.stopPeriodicPulse();

  /// Whether a periodic [sync] timer is armed ([stopPeriodicSync] and
  /// [dispose] disarm it).
  bool get isPeriodicSyncRunning => _session.isPeriodicPulseRunning;

  /// Test seam: attaches a provider-agnostic [EphemeralFrameTransport]
  /// (ADR 0031 §2 — any transport plugs in without touching the session).
  /// The caller keeps ownership of the injected transport.
  @visibleForTesting
  void attachPresenceTransport(final EphemeralFrameTransport transport) =>
      _session.attachPresenceLink(transport);

  /// Test seam: registers a peer's public identity key directly — what
  /// pairing achieves via [acceptPairingCode]/[registerPeer] — so frame
  /// authentication is exercised without a pairing round-trip.
  @visibleForTesting
  void registerPeerIdentityKey({
    required final String peerId,
    required final List<int> identityKey,
  }) => _session.registerPeerIdentityKey(
    peerId: peerId,
    identityKey: identityKey,
  );

  void _registerPeerIdentityKey(final MeshPeerRecord peer) {
    _session.registerPeerIdentityKey(
      peerId: peer.peerId,
      identityKey: peer.identityKey,
    );
  }

  Future<void> dispose() async {
    // Leave frames BEFORE the socket dies (ADR 0031 §1: leave on close;
    // a crash that skips this is covered by peers' ttl sweeps).
    await _session.dispose();
    await stopHosting();
    final transport = _transport;
    _transport = null;
    unawaited(transport?.close());
    final provider = storage.provider;
    if (provider is MeshStorageProvider) await provider.dispose();
  }

  /// Race-safe: concurrent callers share one key-generation future
  /// instead of each starting their own (and racing the assignment).
  Future<SimpleKeyPair> _ensureIdentity() {
    final existing = _identityKeyPair;
    if (existing != null) return Future<SimpleKeyPair>.value(existing);
    return _identityFuture ??= PairingService.newIdentityKeyPair()
        .then((final keyPair) {
      _identityKeyPair = keyPair;
      return keyPair;
    });
  }
}

/// Accepts base64 pairing codes with arbitrary whitespace/newlines and
/// also raw `mesh-pair/v1` payloads pasted as text.
Uint8List decodePairingCode(final String code) {
  final cleaned = code.trim().replaceAll(RegExp(r'\s+'), '');
  if (cleaned.startsWith('mesh-pair/v1')) {
    return Uint8List.fromList(utf8.encode(cleaned));
  }
  return base64Decode(cleaned);
}
