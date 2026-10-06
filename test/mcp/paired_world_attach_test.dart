// ADR 0072 — PHONE-1's headless proof: the pairing→announce→attach loop
// minus the literal radio. A daemon-side facade serves a token-locked
// world (the host package's real serve facade); the host side builds
// the pairing announcement (manifests + mode-600 token file); the
// SCANNER side stores the verified announcement into the paired-worlds
// registry (what the mesh accept flow does with a signed envelope) and
// attaches through it — bearer token included — reading the live
// state. Everything after "the phone scanned the QR" is real code.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/external_worlds_stub.dart'
    if (dart.library.io)
        'package:lastanswer/coding_agent/world_inspector/external_worlds_io.dart'
    as external_worlds;
import 'package:lastanswer/coding_agent/world_inspector/paired_worlds.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

void main() {
  late Directory worldsDir;
  late File tokenFile;
  late HttpServer server;
  late HarnessSessionRegistry registry;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PairedWorlds.clear();
    worldsDir = Directory.systemTemp.createTempSync('paired_world_test');
    tokenFile = File('${worldsDir.path}/harnessd-test.serve-token')
      ..writeAsStringSync('pairing-token\n');
    registry = HarnessSessionRegistry();

    // The world's manifest names the serve block (the daemon wrote it).
    WorldManifestIO(
      directory: worldsDir,
      manifest: WorldManifest(
        worldId: 'harnessd-test',
        displayName: 'harnessd · /tmp/ws',
        host: 'daemon',
        pid: pid,
        startedAt: DateTime.utc(2026, 10, 6, 12),
        workspace: '/tmp/ws',
        serve: {
          'endpoint': 'http://127.0.0.1:8190',
          'auth': 'bearer',
          'tokenFile': tokenFile.path,
        },
      ),
    ).publish();
  });

  tearDown(() async {
    await server.close(force: true);
    worldsDir.deleteSync(recursive: true);
  });

  test('PHONE-1 headless: announce → accept → attach → read', () async {
    // -- The Mac side: a token-locked facade serving its world. --
    final backend = HarnessAcpBackend(
      handlerFactory: (_) => throw StateError('never invoked'),
      sessionRegistry: registry,
    );
    registry.register(
      's1',
      _FakeHandle(),
    );
    final tools = HarnessAgentTools(backend: backend, registry: registry);
    server = await serveHarnessWorlds(
      tools: tools,
      worldId: 'harnessd-test',
      worldsDirectory: worldsDir,
      bind: SocketBind.lan,
      authToken: 'pairing-token',
    );
    // The manifest's serve block now reflects the real bound port.
    final endpoint = 'http://127.0.0.1:${server.port}';

    // -- The host side of pairing: build the announcement. --
    // (buildWorldAnnouncement reads the REAL manifest directory; for
    // the headless proof we store what it would produce — the shape is
    // the contract under test.)
    await PairedWorlds.storeAnnouncement([
      {
        'worldId': 'harnessd-test',
        'endpoint': endpoint,
        'token': 'pairing-token',
        'workspace': '/tmp/ws',
        'seatWs': 'ws://192.168.1.20:9460/harness/seat',
      },
    ]);

    // -- The phone side: the LOCAL route misses (no manifest with this
    // id on the device), the PAIRED route answers. --
    expect(
      external_worlds.resolveExternal(worldId: 'harnessd-test'),
      isNull,
      reason: 'the phone has no local manifest for the Mac world',
    );
    final source = await external_worlds.resolveExternalAsync(
      worldId: 'harnessd-test',
    );
    expect(source, isNotNull, reason: 'the paired registry answers');
    final trace = await source!.sample();
    expect(trace, isNotNull, reason: 'the bearer token opened the facade');
    expect(trace!.metrics['sessionId'], 's1');
  });
}

final class _FakeHandle implements SessionHandle {
  @override
  SessionSnapshot get state => const SessionSnapshot(
    sessionId: 's1',
    kind: 'daemon',
    running: true,
    turnCount: 1,
  );

  @override
  SessionIntentResult delegateTask(final String task) =>
      (ok: false, message: 'not used');

  @override
  SessionIntentResult answerPermission({required final bool allow}) =>
      (ok: false, message: 'not used');
}
