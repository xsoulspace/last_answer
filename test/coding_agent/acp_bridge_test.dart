/// Item 2e — the ACP external-actor bridge v1, pinned over the REAL
/// [RealmChatService] on a hermetic [RealmWorld] (the runAsync-style
/// real-IO pattern the room tests use). The transport is scripted: a
/// beat becomes a prompt, the streamed deltas land as ONE attributed
/// beat, permissions surface as 0c rows, and stop() tears down clean.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/acp_bridge/acp_actor_bridge.dart';
import 'package:lastanswer/coding_agent/acp_bridge/acp_bridge_registry.dart';
import 'package:lastanswer/coding_agent/acp_bridge/acp_bridge_transport.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart';

/// A scripted [AcpBridgeTransport]: records prompts, replays queued
/// update scripts per turn, and lets the test emit permission requests.
final class _ScriptedTransport implements AcpBridgeTransport {
  final List<String> prompts = <String>[];
  final List<List<AcpPromptUpdate>> _script = <List<AcpPromptUpdate>>[];
  final List<AcpBridgePermissionRequest> _pending =
      <AcpBridgePermissionRequest>[];
  final StreamController<AcpBridgePermissionRequest> _permissions =
      StreamController<AcpBridgePermissionRequest>.broadcast();

  bool started = false;
  bool stopped = false;
  String? workingDirectory;
  Object? nextError;

  void scriptReply(final List<AcpPromptUpdate> updates) => _script.add(updates);

  void emitPermission(final AcpBridgePermissionRequest request) {
    _pending.add(request);
    _permissions.add(request);
  }

  @override
  Future<void> start() {
    started = true;
    return Future<void>.value();
  }

  @override
  Future<String> newSession(final String workingDirectory) {
    this.workingDirectory = workingDirectory;
    return Future<String>.value('scripted-session');
  }

  @override
  Stream<AcpPromptUpdate> send(final String prompt) {
    prompts.add(prompt);
    final updates = _script.isEmpty
        ? const <AcpPromptUpdate>[]
        : _script.removeAt(0);
    final error = nextError;
    nextError = null;
    final controller = StreamController<AcpPromptUpdate>();
    scheduleMicrotask(() {
      for (final update in updates) {
        controller.add(update);
      }
      if (error != null) controller.addError(error);
      unawaited(controller.close());
    });
    return controller.stream;
  }

  @override
  Stream<AcpBridgePermissionRequest> get permissionRequests =>
      _permissions.stream;

  @override
  List<AcpBridgePermissionRequest> get pendingPermissions =>
      List<AcpBridgePermissionRequest>.unmodifiable(_pending);

  @override
  Future<void> stop() {
    stopped = true;
    return Future<void>.value();
  }

  Future<void> dispose() async {
    await _permissions.close();
  }
}

/// One hermetic room: a world, a service, the bridged agent actor, its
/// DM thread, and the human's id.
final class _Room {
  _Room({
    required this.temp,
    required this.world,
    required this.service,
    required this.bridgeActor,
    required this.threadId,
    required this.humanId,
  });

  final Directory temp;
  final RealmWorld world;
  final RealmChatService service;
  final ActorProfile bridgeActor;
  final String threadId;
  final String humanId;

  Future<void> dispose() async {
    service.dispose();
    await temp.delete(recursive: true);
  }
}

Future<_Room> _openRoom(final String label) async {
  final temp = await Directory.systemTemp.createTemp('la_acp_bridge_$label');
  final opened = await RealmWorld.open(rootOverride: temp.path);
  if (opened == null) {
    await temp.delete(recursive: true);
    fail('realm world unsupported on this platform');
  }
  final service = RealmChatService(
    debugWorldOverride: opened,
    debugRosterOverride: ActorRoster(replicaId: 'tester'),
    debugStartBotDispatcher: false,
  );
  await service.ensureReady();
  final bridgeActor =
      (await service.createActor(
        displayName: 'Codex (bridged)',
        kind: ActorKind.agent,
        brainRef: 'acp:codex',
        role: 'acp bridge',
      ))!;
  await service.openDm(bridgeActor.actorId);
  final threadId = service.dmThreadOf(bridgeActor.actorId);
  if (threadId == null) fail('no DM thread for the bridged actor');
  return _Room(
    temp: temp,
    world: opened,
    service: service,
    bridgeActor: bridgeActor,
    threadId: threadId,
    humanId: service.humanActorId!,
  );
}

AcpActorBridge _startBridge(
  final _Room room,
  final _ScriptedTransport transport,
) {
  final bridge = AcpActorBridge(
    actorId: room.bridgeActor.actorId,
    agentId: 'codex',
    threadId: room.threadId,
    workingDirectory: room.temp.path,
    transport: transport,
  );
  AcpBridgeRegistry.register(bridge);
  bridge.start(room.service);
  return bridge;
}

/// Polls with real delays until [done] is true (plain `test()` runs real
/// async — no fake clock to pump).
Future<void> _settle(
  final bool Function() done, {
  final String reason = 'condition',
  // 20s, not 8s: these conditions poll real async chains (journal read +
  // service notify + bridge scan) with no fake clock to pump, and the
  // full-suite parallel load stretches them well past 8s (the observed
  // cursor-seed flake). A longer deadline only delays the give-up point;
  // it never changes a passing run.
  final Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!done()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timed out waiting for $reason');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

Future<List<Map<String, Object?>>> _beatsUntil(
  final _Room room,
  final bool Function(List<Map<String, Object?>>) done, {
  final Duration timeout = const Duration(seconds: 8),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    final beats = await room.service.beatsFor(room.threadId);
    if (done(beats)) return beats;
    if (DateTime.now().isAfter(deadline)) return beats;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  tearDown(() => AcpBridgeRegistry.debugReset());

  // (a) An addressed beat becomes exactly ONE prompt; the streamed deltas
  // land as ONE attributed beat (author = the bridge actor, addressedTo =
  // the human), tool statuses as a compact trailing line.
  test('addressed beat -> one prompt -> one attributed beat', () async {
    final room = await _openRoom('a');
    addTearDown(room.dispose);
    final transport = _ScriptedTransport();
    addTearDown(transport.dispose);
    transport.scriptReply(const <AcpPromptUpdate>[
      AcpPromptUpdate(textDelta: 'Hello'),
      AcpPromptUpdate(textDelta: ', world'),
      AcpPromptUpdate(message: 'shell', toolStatus: 'completed'),
    ]);
    final bridge = _startBridge(room, transport);
    addTearDown(bridge.stop);
    await _settle(() => bridge.cursorSeeded, reason: 'cursor seed');

    await room.service.say('please greet');

    final beats = await _beatsUntil(room, (final b) => b.length >= 2);
    expect(transport.prompts, <String>['please greet']);
    expect(transport.started, isTrue);
    expect(transport.workingDirectory, room.temp.path);
    expect(beats, hasLength(greaterThanOrEqualTo(2)));
    final reply = beats.last;
    expect(reply['author'], room.bridgeActor.actorId);
    expect(
      (reply['addressedTo']! as List).cast<String>(),
      <String>[room.humanId],
    );
    expect(reply['text'], 'Hello, world\n· tool: shell completed');

    // The bridge's OWN reply beat never re-prompts (no loop): after the
    // journal watch settles, exactly one prompt was sent.
    await _settle(
      () => bridge.cursor >= (beats.last['beat']! as int),
      reason: 'cursor past own reply',
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(transport.prompts, hasLength(1));
  }, timeout: const Timeout(Duration(minutes: 2)));

  // (b) Unaddressed beats and the bridge's own beats never prompt (the
  // cursor law judges them and moves on).
  test('unaddressed and own beats never prompt', () async {
    final room = await _openRoom('b');
    addTearDown(room.dispose);
    final transport = _ScriptedTransport();
    addTearDown(transport.dispose);
    final bridge = _startBridge(room, transport);
    addTearDown(bridge.stop);
    await _settle(() => bridge.cursorSeeded, reason: 'cursor seed');

    // An unaddressed beat (journal plane, no addressee): the bridge scans
    // it, advances the cursor, and does NOT prompt.
    final unaddressed = await room.world
        .sessionFor(room.humanId)
        .say(room.threadId, 'thinking out loud');
    await _settle(
      () => bridge.cursor >= unaddressed,
      reason: 'cursor past unaddressed beat',
    );
    expect(transport.prompts, isEmpty);

    // A beat authored by the bridge actor itself: skipped by author.
    final own = await room.world
        .sessionFor(room.bridgeActor.actorId)
        .say(room.threadId, 'self note', addressedTo: <String>[room.humanId]);
    await _settle(() => bridge.cursor >= own, reason: 'cursor past own beat');
    expect(transport.prompts, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 2)));

  // (c) A permission request surfaces as an InboxPermission row with the
  // actor attribution; answer(true/false) resolves the transport request
  // exactly once and removes the row.
  test('permission surfaces attributed, answers once', () async {
    final room = await _openRoom('c');
    addTearDown(room.dispose);
    final transport = _ScriptedTransport();
    addTearDown(transport.dispose);
    final bridge = _startBridge(room, transport);
    addTearDown(bridge.stop);
    await _settle(() => bridge.cursorSeeded, reason: 'cursor seed');

    final outcomes = <bool>[];
    final request = AcpBridgePermissionRequest(
      title: 'Codex (bridged) wants to edit foo.dart',
      kind: 'edit',
      details: '@@ -1 +1 @@',
      onAnswer: (final allow) {
        outcomes.add(allow);
        return Future<void>.value();
      },
    );
    transport.emitPermission(request);

    await _settle(
      () => AcpBridgeRegistry.permissions.value.isNotEmpty,
      reason: 'permission row',
    );
    final row = AcpBridgeRegistry.permissions.value.single;
    expect(row.actorId, room.bridgeActor.actorId);
    expect(row.sessionId, startsWith('acp-'));
    expect(row.title, contains('wants to edit foo.dart'));
    expect(row.diff, '@@ -1 +1 @@');

    await row.answer(true);
    expect(outcomes, <bool>[true]);
    expect(request.isAnswered, isTrue);
    expect(AcpBridgeRegistry.permissions.value, isEmpty);

    // A second answer is a no-op (exactly-once under the request).
    await row.answer(false);
    expect(outcomes, <bool>[true]);
  }, timeout: const Timeout(Duration(minutes: 2)));

  // (d) stop() rejects + removes open rows, stops the transport, and
  // ignores later addressed beats.
  test('stop removes rows, rejects open, ignores later', () async {
    final room = await _openRoom('d');
    addTearDown(room.dispose);
    final transport = _ScriptedTransport();
    addTearDown(transport.dispose);
    final bridge = _startBridge(room, transport);
    await _settle(() => bridge.cursorSeeded, reason: 'cursor seed');

    final outcomes = <bool>[];
    final request = AcpBridgePermissionRequest(
      title: 'edit',
      onAnswer: (final allow) {
        outcomes.add(allow);
        return Future<void>.value();
      },
    );
    transport.emitPermission(request);
    await _settle(
      () => AcpBridgeRegistry.permissions.value.isNotEmpty,
      reason: 'permission row',
    );

    await bridge.stop();
    expect(AcpBridgeRegistry.permissions.value, isEmpty);
    expect(outcomes, <bool>[false]); // reject-first on teardown
    expect(transport.stopped, isTrue);
    expect(AcpBridgeRegistry.bridges.value, isNot(contains(bridge)));

    // A later addressed beat is ignored (the listener is gone).
    await room.service.say('are you still there?');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(transport.prompts, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 2)));

  // (e) The desktop gate's pure helper.
  test('acpBridgeAvailability names the desktop + detection facts', () {
    expect(
      acpBridgeAvailability(<String>['codex'], 'macos'),
      AcpBridgeAvailability.available,
    );
    expect(
      acpBridgeAvailability(<String>['pi'], 'linux'),
      AcpBridgeAvailability.available,
    );
    expect(
      acpBridgeAvailability(<String>['codex'], 'windows'),
      AcpBridgeAvailability.available,
    );
    expect(
      acpBridgeAvailability(const <String>[], 'macos'),
      AcpBridgeAvailability.noAgentsDetected,
    );
    expect(
      acpBridgeAvailability(const <String>[], 'windows'),
      AcpBridgeAvailability.noAgentsDetected,
    );
    expect(
      acpBridgeAvailability(<String>['codex'], 'ios'),
      AcpBridgeAvailability.unsupportedPlatform,
    );
    expect(
      acpBridgeAvailability(<String>['codex'], 'android'),
      AcpBridgeAvailability.unsupportedPlatform,
    );
  });
}
