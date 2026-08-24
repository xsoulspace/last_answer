import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:universal_storage_mesh/universal_storage_mesh.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';

/// Owns one cross-platform mesh replica and WebSocket transport.
final class MeshStorageService {
  MeshStorageService._(this.storage, this.transport, {required this.selfId});

  final StorageService storage;
  final AddressedRelayClient transport;
  final String selfId;

  SimpleKeyPair? _identityKeyPair;
  MeshPairingSession? _pairingSession;

  static const _dataFile = 'last-answer-data.json';

  /// Creates a browser-compatible replica. On IO, [relay] is the local
  /// fan-out relay; on web it remains null and clients connect to a remote
  /// relay endpoint.
  static Future<MeshStorageService> open({
    required final String storePath,
    required final Uri relayEndpoint,
    required final String peerId,
    final String displayName = 'Last Answer',
    final bool connectToRelay = true,
  }) async {
    final provider = MeshStorageProvider();
    await provider.initWithConfig(
      MeshStorageConfig(
        storePath: storePath,
        peerId: peerId,
        displayName: displayName,
      ),
    );
    final transport = AddressedRelayClient(
      selfId: peerId,
      endpoint: relayEndpoint,
    );
    if (connectToRelay) await transport.openRelay();
    provider.attachTransport(transport);
    return MeshStorageService._(
      StorageService(provider),
      transport,
      selfId: peerId,
    );
  }

  /// Starts a signed pairing exchange for QR display.
  Future<MeshPairingSession> startQrPairing() async {
    _identityKeyPair ??= await PairingService.newIdentityKeyPair();
    return _pairingSession ??= MeshPairingSession(
      selfId: selfId,
      identityKeyPair: _identityKeyPair!,
    );
  }

  Future<Uint8List> createQrPayload() async {
    final session = await startQrPairing();
    return session.createQrPayload();
  }

  Future<void> addPeer({
    required final String peerId,
    final String displayName = 'Peer',
    final List<int> identityKey = const [],
  }) async {
    final provider = storage.provider;
    if (provider is! MeshStorageProvider) {
      throw StateError('Mesh service is not initialized');
    }
    await provider.registerPeer(
      MeshPeerRecord(
        peerId: peerId,
        displayName: displayName,
        identityKey: identityKey,
      ),
    );
  }

  Future<MeshPeerRecord> acceptQrPayload(final Uint8List qrPayload) async {
    final provider = storage.provider;
    if (provider is! MeshStorageProvider) {
      throw StateError('Mesh service is not initialized');
    }
    final session = await startQrPairing();
    final peer = await session.acceptQrPayload(qrPayload);
    await provider.registerPeer(peer);
    return peer;
  }

  Future<void> backup(final String jsonPayload) =>
      storage.saveFile(_dataFile, jsonPayload, message: 'mesh backup');

  Future<String?> restore() => storage.readFile(_dataFile);

  Future<void> sync() => storage.syncRemote();

  Future<void> dispose() async {
    final provider = storage.provider;
    if (provider is MeshStorageProvider) await provider.dispose();
    await transport.close();
  }
}
