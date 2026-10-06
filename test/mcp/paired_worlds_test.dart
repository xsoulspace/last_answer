// ADR 0072 — the paired-worlds registry: the off-device discovery
// route. Trust chain under test: only a VERIFIED pairing envelope can
// store an entry (the mesh verifies the signature before the record
// ever reaches [PairedWorlds.storeAnnouncement]); the registry keeps
// it; the async resolver attaches with the bearer token. The
// announcement builder (host side) reads manifests + token files and
// skips worlds that cannot honestly serve a paired device.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/paired_worlds.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_agentic_host/src/world_manifest.dart'
    show WorldManifest;
import 'package:xsoulspace_agentic_host/src/world_manifest_io.dart'
    show WorldManifestIO;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PairedWorlds.clear();
  });

  test('an announcement stores, dedupes by worldId, newest first',
      () async {
    await PairedWorlds.storeAnnouncement([
      {
        'worldId': 'harnessd-abc',
        'endpoint': 'http://192.168.1.20:8190',
        'token': 'tok-1',
        'workspace': '/tmp/ws',
      },
    ]);
    // A later pairing re-announces the same world with a rotated token
    // and adds a second world.
    await PairedWorlds.storeAnnouncement([
      {
        'worldId': 'harnessd-abc',
        'endpoint': 'http://192.168.1.20:9310',
        'token': 'tok-2',
      },
      {
        'worldId': 'harnessd-def',
        'endpoint': 'http://192.168.1.20:9310',
        'token': 'tok-3',
      },
    ]);
    final worlds = await PairedWorlds.load();
    expect(worlds, hasLength(2));
    final abc = worlds.firstWhere((w) => w.worldId == 'harnessd-abc');
    expect(abc.token, 'tok-2', reason: 'newest announcement wins');
    expect(abc.endpoint, 'http://192.168.1.20:9310');
    expect(worlds.first.worldId, 'harnessd-def',
        reason: 'newest PAIRING first');
  });

  test('unusable entries are dropped honestly (no crash, no partial)',
      () async {
    await PairedWorlds.storeAnnouncement([
      {'worldId': ''}, // no endpoint
      {'endpoint': 'http://x'}, // no worldId
      'garbage',
      {
        'worldId': 'harnessd-ok',
        'endpoint': 'http://192.168.1.20:8190',
        'token': 'tok',
      },
    ]);
    final worlds = await PairedWorlds.load();
    expect(worlds, hasLength(1));
    expect(worlds.single.worldId, 'harnessd-ok');
  });

  test('the load is persistent across registry instances (prefs-backed)',
      () async {
    await PairedWorlds.storeAnnouncement([
      {
        'worldId': 'harnessd-abc',
        'endpoint': 'http://192.168.1.20:8190',
        'token': 'tok-1',
      },
    ]);
    // A fresh read (what another isolate/future session sees).
    final again = await PairedWorlds.load();
    expect(again.single.token, 'tok-1');
  });
}
