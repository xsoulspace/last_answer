import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/mesh_storage_service.dart';

/// Task N topology repro — the REAL production topology headlessly:
///
///   host `MeshStorageService` (temp store path) + `startHosting()`
///   (real relay on loopback) + peer `MeshStorageService` WITHOUT a
///   relay endpoint → pair via `createPairingCode`/`acceptPairingCode`
///   (the production path) → peer `joinDoc(doc)` → the HOST's
///   `presence(doc)` must contain the peer.
///
/// The measured two-device run (macOS host + Chrome web peer): the peer
/// folded its own announcement (`presenceCount: 1`) while the host's
/// tracker stayed empty — the host's doc had opened BEFORE its mesh
/// replica existed, so its join was dropped by the wiring and the host
/// had NO presence session on the channel: the peer's frames reached the
/// host's link and were never folded. Presence OBSERVATION must not
/// require a local session (ADR 0031 §1: announcement stays doc-scoped;
/// the fold is observation, never announcement).
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 300));

Future<String> _tempStore(final String tag) async {
  final dir = await Directory.systemTemp.createTemp(
    'last-answer-mesh-topo-$tag',
  );
  addTearDown(() => dir.delete(recursive: true));
  return dir.path;
}

void main() {
  test(
    'peer presence announcements reach a host that never joined the doc '
    '(pair → peer joinDoc → host presence(doc) contains the peer)',
    () async {
      // -- Host: no endpoint at open, hosting started afterwards (the
      //    `mesh_host` / `becomeMainDevice` path). The host NEVER calls
      //    joinDoc — its doc opened before the replica existed.
      final host = await MeshStorageService.open(
        storePath: await _tempStore('host'),
        peerId: 'device-a',
      );
      addTearDown(host.dispose);
      await host.startHosting();
      expect(host.isHosting, isTrue);
      expect(host.isConnected, isTrue);

      // -- Peer: NO relay endpoint at open (web peer at startup).
      final peer = await MeshStorageService.open(
        storePath: await _tempStore('peer'),
        peerId: 'device-b',
      );
      addTearDown(peer.dispose);

      // -- Production pairing path (mesh_pair).
      final code = await host.createPairingCode();
      final record = await peer.acceptPairingCode(code);
      expect(record.peerId, 'device-a');
      expect(peer.isConnected, isTrue);

      // -- One convergence cycle ran by mesh_pair before any join.
      await peer.sync();

      // -- mesh_join_doc on the PEER (the host never joins).
      const doc = 'agent-doc-1';
      await peer.joinDoc(doc);

      // Let the join frames travel the relay and the async
      // verify-and-fold chains settle on the host.
      await _settle();

      // Peer folds itself locally…
      expect(
        peer.presence(doc).map((final e) => e.peerId),
        contains('device-b'),
      );
      // …and the HOST must see the peer.
      expect(
        host.presence(doc).map((final e) => e.peerId),
        contains('device-b'),
        reason: 'the host never joined the doc, but the peer announcement '
            'must still fold (observation, not announcement)',
      );
      expect(host.presenceFrameRejections, isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'regression: both devices join the doc — host sees the peer, peer '
    'sees the host',
    () async {
      final host = await MeshStorageService.open(
        storePath: await _tempStore('host'),
        peerId: 'device-a',
      );
      addTearDown(host.dispose);
      await host.startHosting();

      final peer = await MeshStorageService.open(
        storePath: await _tempStore('peer'),
        peerId: 'device-b',
      );
      addTearDown(peer.dispose);
      final code = await host.createPairingCode();
      await peer.acceptPairingCode(code);
      await peer.sync();

      const doc = 'agent-doc-1';
      await peer.joinDoc(doc);
      await host.joinDoc(doc);
      await _settle();

      expect(
        host.presence(doc).map((final e) => e.peerId),
        containsAll(['device-a', 'device-b']),
      );
      expect(
        peer.presence(doc).map((final e) => e.peerId),
        containsAll(['device-a', 'device-b']),
      );
      expect(host.presenceFrameRejections, isEmpty);
      expect(peer.presenceFrameRejections, isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
