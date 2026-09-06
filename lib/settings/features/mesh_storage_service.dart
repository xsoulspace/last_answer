import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/settings/features/mesh_relay_host_stub.dart'
    if (dart.library.io) 'mesh_relay_host_io.dart' as relay_host;
import 'package:universal_storage_convergence/universal_storage_convergence.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';

/// Owns one cross-platform mesh replica, its WebSocket transport, and
/// (on dart:io platforms) the locally hosted relay of a "main device".
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
  });

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
  }) :
        // ignore: prefer_initializing_formals
        _identityKeyPair = identityKeyPair;

  final StorageService storage;
  final String selfId;

  static const _dataFile = 'last-answer-data.json';

  /// Doc-replica stores participating in the sync cycle (ADR 0005 §1
  /// Phase 5b): attached via [attachDocSync]; [sync] flushes their pending
  /// ops into storage before anti-entropy and absorbs remote doc data
  /// after. The caller keeps ownership (lifecycle, dispose).
  final List<DocReplicaStore> _docSyncs = [];

  /// Whether this platform can host a relay ("main device" capable):
  /// true wherever dart:io exists, false on web.
  static bool get canHostRelay => relay_host.canHostRelay;

  final relay_host.LocalRelayHost _relayHost = relay_host.LocalRelayHost();
  AddressedRelayClient? _transport;

  SimpleKeyPair? _identityKeyPair;
  MeshPairingSession? _advertisement;

  /// Last transport failure, surfaced for status lines / debugging.
  Object? connectError;

  // -- Presence over the shared relay connection (ADR 0031 §1–2) ----------

  /// Cadence policy for the presence sessions this service opens
  /// (ADR 0031 §5: policy-with-bounds, chosen by the embedding app —
  /// constructor-level, never a free knob). Document viewing is the
  /// default here, so `background`.
  PresenceConfig presenceConfig = PresenceConfig.background;

  final Map<String, MeshPresenceSession> _presenceSessions = {};

  /// Docs the CALLER asked to join (ADR 0031 §1: presence is doc-scoped;
  /// the service never decides which docs are open). Re-opened whenever
  /// the presence link (re)connects.
  final Set<String> _presenceDocs = {};
  MeshPresenceTracker? _presenceTracker;
  MeshFrameAuthenticator? _presenceAuthenticator;
  EphemeralFrameTransport? _presenceTransport;
  AddressedRelayEphemeralTransport? _relayPresenceTransport;
  StreamSubscription<EphemeralLinkState>? _presenceLinkSub;
  var _ownsPresenceTransport = false;

  // -- Roster riding the mesh as durable ops (ADR 0007 §1) ---------------

  /// Directory under storage holding one roster file per replica
  /// (whole-file, like the doc-sync seam's replica files).
  static const _rosterDir = 'actor_rosters';

  ActorRoster? _roster;

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
        transport = await _openClient(selfId: peerId, endpoint: relayEndpoint);
        provider.attachTransport(transport);
        service._attachRelayPresenceLink(transport);
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
      final client = await _openClient(selfId: selfId, endpoint: endpoint);
      _transport = client;
      final provider = storage.provider;
      if (provider is MeshStorageProvider) provider.attachTransport(client);
      _attachRelayPresenceLink(client);
    } on Object catch (error) {
      connectError = error;
      rethrow;
    }
  }

  /// Signed pairing code advertising this device; embeds the hosted
  /// relay endpoint (or current connection endpoint) so scanners never
  /// type addresses.
  Future<String> createPairingCode() async {
    final hint = (advertisedEndpoint ?? _transport?.endpoint)?.toString();
    _advertisement ??= MeshPairingSession(
      selfId: selfId,
      identityKeyPair: await _ensureIdentity(),
      transportHint: hint,
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

  /// Registers [store] with the mesh sync cycle. Every [sync] then:
  ///
  /// 1. flushes the store's pending doc ops into storage (batched; one
  ///    file per doc) so anti-entropy ships the latest replica state;
  /// 2. runs the provider's anti-entropy exchange (peer files may be
  ///    overwritten with a peer's replica JSON — whole-file LWW);
  /// 3. calls [DocReplicaStore.absorbRemote] so the local replicas fold
  ///    any ops the exchange delivered. Convergence rests on the kernel
  ///    (VV dedupe + order-independent fold), not on file ordering; the
  ///    next cycle's flush rewrites shadowed files with the merged log.
  ///
  /// Registration only — nothing is written until the next [sync]. The
  /// store's storage should be the SAME [StorageService] this service
  /// owns (or one backed by the same provider) so flushed files actually
  /// participate in anti-entropy. This service never disposes the store.
  void attachDocSync(final DocReplicaStore store) {
    _docSyncs.add(store);
  }

  /// Attaches the actor roster (ADR 0007 §1): ordinary durable kernel
  /// state that rides the mesh — [sync] flushes its pending ops into
  /// storage before anti-entropy and folds durable roster ops delivered
  /// by the exchange after. The roster's replica id is forced to this
  /// service's pairing peer id (ADR 0007 §2) — callers may have built it
  /// with a placeholder id. The caller keeps ownership (lifecycle,
  /// dispose); this service never disposes it.
  void attachRoster(final ActorRoster roster) {
    roster.forceReplicaId(selfId);
    _roster = roster;
  }

  /// Joins [docId]'s presence channel. Doc-scoped join is the CALLER's
  /// job (ADR 0031 §1): the service never decides which docs are open.
  /// When the presence link is up, the join frame goes out immediately;
  /// otherwise the doc stays queued and joins on the next (re)connect.
  Future<void> joinDoc(final String docId) async {
    _presenceDocs.add(docId);
    final transport = _presenceTransport;
    if (transport != null &&
        transport.connectionState == EphemeralLinkState.connected) {
      await _openPresenceSessions();
    }
  }

  /// Leaves [docId]'s presence channel: a signed leave frame goes out so
  /// peers drop this peer immediately (ADR 0031 §1).
  Future<void> leaveDoc(final String docId) async {
    _presenceDocs.remove(docId);
    final session = _presenceSessions.remove(docId);
    if (session != null) await _closePresenceSession(session);
  }

  /// Liveness refresh on the doc's channel (ADR 0031 §5: ping on
  /// activity). Best-effort: a dead link swallows the ping — peers'
  /// ttl sweeps are the crash backstop.
  Future<void> notifyPresenceActivity(final String docId) async {
    final session = _presenceSessions[docId];
    if (session == null) return;
    try {
      await session.notifyActivity();
    } on Object {
      // Link down mid-ping: presence is observation, never durability.
    }
  }

  /// Live presence for [docId] — the tracker fold over unexpired
  /// ephemeral ops (ADR 0029 §1, ADR 0031 §2). Agent-queryable state,
  /// not UI state: "who is here" right now.
  List<MeshPresenceEntry> presence(
    final String docId, {
    final DateTime? now,
  }) => _presenceTracker?.presence(docId, now: now) ?? const [];

  /// How many inbound presence frames were dropped as named data
  /// (ADR 0031 §3) across every open doc session.
  int get rejectedPresenceFrameCount => _presenceSessions.values
      .fold(0, (final n, final session) => n + session.rejectedFrameCount);

  /// Every dropped presence frame with its rejection reason, oldest
  /// first, across every open doc session.
  List<MeshFrameRejection> get presenceFrameRejections => [
    for (final session in _presenceSessions.values) ...session.rejections,
  ];

  /// Anti-entropy exchange with every known peer, wrapped in the doc-sync
  /// seam above: attached [DocReplicaStore]s flush before the exchange
  /// and absorb remote doc data after.
  ///
  /// Wrapped in a timeout because an addressed relay silently drops
  /// frames addressed to offline peers; without it "Sync now" hangs.
  Future<void> sync({
    final Duration timeout = const Duration(minutes: 1),
  }) async {
    await _syncCycle().timeout(timeout);
  }

  Future<void> _syncCycle() async {
    for (final store in _docSyncs) {
      await store.flush();
    }
    await _flushRoster();
    await storage.syncRemote();
    for (final store in _docSyncs) {
      await store.absorbRemote();
    }
    await _absorbRoster();
  }

  // -- Presence link management (ADR 0031 §1–2) ---------------------------

  /// Owns the presence channel over the relay client's connection: one
  /// adapter, one tracker, one authenticator — shared by every doc
  /// session (sessions filter frames by [MeshPresenceSession.docId]).
  void _attachRelayPresenceLink(final AddressedRelayClient client) {
    _startPresenceLink(
      AddressedRelayEphemeralTransport(client: client),
      ownedByService: true,
    );
  }

  /// Test seam: attaches a provider-agnostic [EphemeralFrameTransport]
  /// (ADR 0031 §2 — any transport plugs in without touching the session)
  /// so presence wiring is exercised without networking. The caller
  /// keeps ownership of the injected transport.
  @visibleForTesting
  void attachPresenceTransport(final EphemeralFrameTransport transport) {
    _startPresenceLink(transport, ownedByService: false);
  }

  void _startPresenceLink(
    final EphemeralFrameTransport transport, {
    required final bool ownedByService,
  }) {
    unawaited(_stopPresenceLink(sendLeaves: false));
    _presenceTracker ??= MeshPresenceTracker(actorId: selfId);
    _presenceAuthenticator ??= MeshFrameAuthenticator();
    _seedAuthenticatorFromPeers();
    _presenceTransport = transport;
    _ownsPresenceTransport = ownedByService;
    _relayPresenceTransport =
        ownedByService && transport is AddressedRelayEphemeralTransport
            ? transport
            : null;
    _presenceLinkSub = transport.connectionChanges.listen(
      _onPresenceLinkChanged,
    );
    if (transport.connectionState == EphemeralLinkState.connected) {
      unawaited(_openPresenceSessions());
    }
  }

  void _onPresenceLinkChanged(final EphemeralLinkState state) {
    switch (state) {
      case EphemeralLinkState.connected:
        // Re-join the docs the caller asked for; the link came back.
        unawaited(_openPresenceSessions());
      case EphemeralLinkState.disconnected:
        // Stop join/ping/leave lifecycle with the link; pings stop
        // immediately and peers expire this peer via their ttl sweep.
        _closeAllPresenceSessions();
    }
  }

  Future<void> _openPresenceSessions() async {
    final transport = _presenceTransport;
    final authenticator = _presenceAuthenticator;
    if (transport == null || authenticator == null) return;
    final signer = MeshFrameSigner(identityKeyPair: await _ensureIdentity());
    for (final docId in _presenceDocs) {
      if (_presenceSessions.containsKey(docId)) continue;
      final session = MeshPresenceSession(
        transport: transport,
        tracker: _presenceTracker!,
        docId: docId,
        presenceConfig: presenceConfig,
        signer: signer,
        authenticator: authenticator,
      );
      _presenceSessions[docId] = session;
      await session.open();
    }
  }

  void _closeAllPresenceSessions() {
    final sessions = List.of(_presenceSessions.values);
    _presenceSessions.clear();
    for (final session in sessions) {
      unawaited(_closePresenceSession(session));
    }
  }

  Future<void> _closePresenceSession(final MeshPresenceSession session) async {
    try {
      await session.close(); // leave frame; best-effort
    } on Object {
      // Link died mid-leave: peers' ttl sweeps are the backstop
      // (ADR 0031 §1).
    }
  }

  Future<void> _stopPresenceLink({required final bool sendLeaves}) async {
    await _presenceLinkSub?.cancel();
    _presenceLinkSub = null;
    if (sendLeaves) {
      final sessions = List.of(_presenceSessions.values);
      _presenceSessions.clear();
      for (final session in sessions) {
        await _closePresenceSession(session);
      }
    } else {
      _presenceSessions.clear();
    }
    final relayTransport = _relayPresenceTransport;
    _relayPresenceTransport = null;
    if (_ownsPresenceTransport && relayTransport != null) {
      unawaited(relayTransport.dispose());
    }
    _presenceTransport = null;
    _ownsPresenceTransport = false;
  }

  // -- Peer frame authentication (ADR 0031 §3) ----------------------------

  /// Registers [peer]'s public identity key in the frame authenticator.
  /// Peers recorded WITHOUT key bytes stay sync-only: their frames are
  /// rejected as unauthenticated named data, never folded.
  void _registerPeerIdentityKey(final MeshPeerRecord peer) {
    if (peer.identityKey.isEmpty) return;
    _presenceAuthenticator ??= MeshFrameAuthenticator();
    _presenceAuthenticator!.registerIdentityKey(
      peerId: peer.peerId,
      identityKey: peer.identityKey,
    );
  }

  void _seedAuthenticatorFromPeers() {
    final authenticator = _presenceAuthenticator;
    if (authenticator == null) return;
    peers.forEach(_registerPeerIdentityKey);
  }

  /// Test seam: registers a peer's public identity key directly — what
  /// pairing achieves via [acceptPairingCode]/[registerPeer] — so frame
  /// authentication is exercised without a pairing round-trip.
  @visibleForTesting
  void registerPeerIdentityKey({
    required final String peerId,
    required final List<int> identityKey,
  }) => _registerPeerIdentityKey(
    MeshPeerRecord(peerId: peerId, displayName: peerId, identityKey: identityKey),
  );

  // -- Roster over storage (ADR 0007 §1, same pattern as the doc-sync
  //    seam) --------------------------------------------------------------

  /// Flushes the roster's durable state (including its pending ops) into
  /// one whole file — what anti-entropy ships, exactly like a doc
  /// replica file.
  Future<void> _flushRoster() async {
    final roster = _roster;
    if (roster == null) return;
    await storage.saveFile(
      '$_rosterDir/${roster.replicaId}.json',
      jsonEncode(roster.toJson()),
      message: 'save actor roster ${roster.replicaId}',
    );
  }

  /// Folds durable roster ops delivered by the exchange: every peer's
  /// roster file carries its durable op log; the kernel's VV dedupe makes
  /// re-folding idempotent and delivery-order independent, so whole-file
  /// LWW cannot desync replicas.
  Future<void> _absorbRoster() async {
    final roster = _roster;
    if (roster == null) return;
    final entries = await storage.listDirectory(_rosterDir);
    for (final entry in entries) {
      if (entry.isDirectory || !entry.name.endsWith('.json')) continue;
      if (entry.name == '${roster.replicaId}.json') continue; // our own
      final raw = await storage.readFile('$_rosterDir/${entry.name}');
      if (raw == null) continue;
      final ops = _rosterOpsOf(raw);
      if (ops.isEmpty) continue;
      roster.applyRemote(ops);
    }
  }

  /// The durable op log of a persisted roster JSON.
  static List<OpRecord> _rosterOpsOf(final String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const [];
    }
    if (decoded is! Map) return const [];
    final log = decoded['log'];
    if (log is! List) return const [];
    return [
      for (final entry in log)
        if (entry is Map) OpRecord.fromJson(Map<String, dynamic>.from(entry)),
    ];
  }

  Future<void> dispose() async {
    // Leave frames BEFORE the socket dies (ADR 0031 §1: leave on close;
    // a crash that skips this is covered by peers' ttl sweeps).
    await _stopPresenceLink(sendLeaves: true);
    await stopHosting();
    final transport = _transport;
    _transport = null;
    unawaited(transport?.close());
    final provider = storage.provider;
    if (provider is MeshStorageProvider) await provider.dispose();
  }

  Future<SimpleKeyPair> _ensureIdentity() async =>
      _identityKeyPair ??= await PairingService.newIdentityKeyPair();
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
