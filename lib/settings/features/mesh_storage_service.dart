import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:lastanswer/settings/features/mesh_relay_host_stub.dart'
    if (dart.library.io) 'mesh_relay_host_io.dart' as relay_host;
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

  final StorageService storage;
  final String selfId;

  static const _dataFile = 'last-answer-data.json';

  /// Whether this platform can host a relay ("main device" capable):
  /// true wherever dart:io exists, false on web.
  static bool get canHostRelay => relay_host.canHostRelay;

  final relay_host.LocalRelayHost _relayHost = relay_host.LocalRelayHost();
  AddressedRelayClient? _transport;

  SimpleKeyPair? _identityKeyPair;
  MeshPairingSession? _advertisement;

  /// Last transport failure, surfaced for status lines / debugging.
  Object? connectError;

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
    if (relayEndpoint != null && relayEndpoint.hasScheme) {
      try {
        transport = await _openClient(selfId: peerId, endpoint: relayEndpoint);
        provider.attachTransport(transport);
      } on Exception catch (error) {
        transport = null;
        // Deferred: pairing and "Sync now" surface it to the user.
        // ignore: avoid_print
        print('mesh: relay connect failed: $error');
      }
    }
    return MeshStorageService._(
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
    return record;
  }

  Future<void> backup(final String jsonPayload) =>
      storage.saveFile(_dataFile, jsonPayload, message: 'mesh backup');

  Future<String?> restore() => storage.readFile(_dataFile);

  /// Anti-entropy exchange with every known peer.
  ///
  /// Wrapped in a timeout because an addressed relay silently drops
  /// frames addressed to offline peers; without it "Sync now" hangs.
  Future<void> sync({final Duration timeout = const Duration(minutes: 1)}) =>
      storage.syncRemote().timeout(timeout);

  Future<void> dispose() async {
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
