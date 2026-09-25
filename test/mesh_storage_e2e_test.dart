import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';
import 'package:universal_storage_mesh_transport/'
    'universal_storage_mesh_transport.dart';

Future<String> _tempStore(final String tag) async {
  final dir = await Directory.systemTemp.createTemp(
    'last-answer-mesh-$tag',
  );
  addTearDown(() => dir.delete(recursive: true));
  return dir.path;
}

void main() {
  test(
    'seamless flow: main device hosts, second device joins with a '
    'code only',
    () async {
      final main = await MeshStorageService.open(
        storePath: await _tempStore('main'),
        peerId: 'device-a',
      );
      addTearDown(main.dispose);
      final advertised = await main.startHosting();
      expect(main.isHosting, isTrue);
      expect(advertised.host, isNotEmpty);
      expect(main.isConnected, isTrue);

      final code = await main.createPairingCode();

      final second = await MeshStorageService.open(
        storePath: await _tempStore('second'),
        peerId: 'device-b',
      );
      addTearDown(second.dispose);

      // Clipboard round trip may introduce whitespace/newlines.
      final peer = await second.acceptPairingCode('$code\n');
      expect(peer.peerId, 'device-a');
      expect(peer.identityKey.length, 32);
      expect(peer.endpointHints['ws'], advertised.toString());
      expect(second.isConnected, isTrue);
      expect(second.peers.map((final p) => p.peerId), contains('device-a'));

      const payload = '{"documents":[{"id":"chat","blocks":3}]}';
      await main.backup(payload);
      await second.sync();

      expect(await second.restore(), payload);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('manual relay configuration keeps working (advanced/debug)', () async {
    final relay = AddressedRelayServer(port: 0);
    final port = await relay.start();
    addTearDown(relay.dispose);
    final endpoint = Uri.parse('ws://127.0.0.1:$port');

    final a = await MeshStorageService.open(
      storePath: await _tempStore('a'),
      relayEndpoint: endpoint,
      peerId: 'device-a',
    );
    final b = await MeshStorageService.open(
      storePath: await _tempStore('b'),
      relayEndpoint: endpoint,
      peerId: 'device-b',
    );
    addTearDown(() async {
      await a.dispose();
      await b.dispose();
    });
    expect(a.isConnected, isTrue);
    expect(b.isConnected, isTrue);

    await b.registerPeer(
      peerId: 'device-a',
      displayName: 'macOS',
    );

    const payload = '{"documents":[{"id":"chat","blocks":3}]}';
    await a.backup(payload);
    await b.sync();

    expect(await b.restore(), payload);
  });

  test('pairing codes tolerate whitespace and reject garbage', () async {
    final service = await MeshStorageService.open(
      storePath: await _tempStore('solo'),
      peerId: 'device-solo',
    );
    addTearDown(service.dispose);

    expect(
      () => service.acceptPairingCode('definitely not a code'),
      throwsA(isA<FormatException>()),
    );
  });
}
