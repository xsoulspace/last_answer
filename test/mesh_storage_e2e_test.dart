import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/mesh_relay_io.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';

void main() {
  test('paired relay sessions converge deterministic app payloads', () async {
    final relay = AddressedRelayServer(port: 0);
    final port = await relay.start();
    addTearDown(relay.dispose);
    final endpoint = Uri.parse('ws://127.0.0.1:$port');

    final a = await MeshStorageService.open(
      storePath: ':memory:a',
      relayEndpoint: endpoint,
      peerId: 'device-a',
    );
    final b = await MeshStorageService.open(
      storePath: ':memory:b',
      relayEndpoint: endpoint,
      peerId: 'device-b',
    );
    addTearDown(() async {
      await a.dispose();
      await b.dispose();
    });

    await b.addPeer(peerId: 'device-a', displayName: 'macOS');
    await a.addPeer(peerId: 'device-b', displayName: 'web');

    const payload = '{"documents":[{"id":"chat","blocks":3}]}';
    await a.backup(payload);
    await b.sync();

    expect(await b.restore(), payload);
  });

  test('signed QR pairing registers identity-bearing peers', () async {
    final relay = AddressedRelayServer(port: 0);
    final port = await relay.start();
    addTearDown(relay.dispose);
    final endpoint = Uri.parse('ws://127.0.0.1:$port');

    final a = await MeshStorageService.open(
      storePath: ':memory:a',
      relayEndpoint: endpoint,
      peerId: 'device-a',
      connectToRelay: false,
    );
    final b = await MeshStorageService.open(
      storePath: ':memory:b',
      relayEndpoint: endpoint,
      peerId: 'device-b',
      connectToRelay: false,
    );
    addTearDown(() async {
      await a.dispose();
      await b.dispose();
    });

    final qrPayload = await a.createQrPayload();
    final peer = await b.acceptQrPayload(qrPayload);
    expect(peer.peerId, 'device-a');
    expect(peer.identityKey, isNotEmpty);
    expect(peer.identityKey.length, 32);
  });
}
