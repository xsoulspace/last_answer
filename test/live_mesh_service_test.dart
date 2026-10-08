// The live multiplayer plane over a REAL loopback relay: agent activity
// always flows, human activity is opt-in at the source, stopping sharing
// RETRACTS what already left, and the owner's adoption gate keeps
// unpaired peers out.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/live_mesh_service.dart';
import 'package:universal_storage_mesh_transport/universal_storage_mesh_transport.dart';

Future<void> _until(final bool Function() probe) async {
  for (var i = 0; i < 500; i++) {
    if (probe()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('condition not reached within 5s');
}

LiveActor _agent(final String id, final String verb, {final String? docId}) =>
    LiveActor(
      actorId: id,
      displayName: id,
      isAgent: true,
      verb: verb,
      docId: docId,
      since: DateTime.now().toUtc(),
    );

void main() {
  test(
    'live plane: agent flows, human opt-in, retraction, adoption gate',
    () async {
      final server = AddressedRelayServer(port: 0);
      final port = await server.start();
      final endpoint = Uri.parse('ws://127.0.0.1:$port');
      addTearDown(server.dispose);

      final owner = await LiveMeshService.open(
        selfId: 'desktop',
        endpoint: endpoint,
        isOwner: true,
        pairedPeerIds: const {'phone'},
      );
      owner.host();
      addTearDown(owner.dispose);

      final peer = await LiveMeshService.open(
        selfId: 'phone',
        endpoint: endpoint,
        isOwner: false,
      );
      await peer.join(ownerId: 'desktop');
      addTearDown(peer.dispose);

      // Agent activity ALWAYS flows to the human's devices.
      await peer.publish(_agent('agent-laya', LiveVerbs.thinking));
      await _until(() => owner.actor('agent-laya') != null);
      expect(owner.actor('agent-laya')!.verb, LiveVerbs.thinking);

      // Human activity is refused AT THE SOURCE by default: nothing
      // leaves the device, so the owner never sees it.
      await peer.publish(
        LiveActor(
          actorId: 'phone-human',
          displayName: 'Antonio',
          isAgent: false,
          verb: LiveVerbs.watching,
          since: DateTime.now().toUtc(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(owner.actor('phone-human'), isNull);

      // Opt-in: the same publish flows.
      peer.shareHumanActivity = true;
      await peer.publish(
        LiveActor(
          actorId: 'phone-human',
          displayName: 'Antonio',
          isAgent: false,
          verb: LiveVerbs.watching,
          since: DateTime.now().toUtc(),
        ),
      );
      await _until(() => owner.actor('phone-human') != null);

      // The owner's own agents reach the peer through the rebroadcast —
      // and the rebroadcast carries the peer's shared human too.
      await owner.publish(
        _agent('agent-doc', LiveVerbs.editing, docId: 'doc-1'),
      );
      await _until(() => peer.actor('agent-doc') != null);
      expect(peer.actor('phone-human'), isNotNull);

      // Attention: shared human cursor reaches the owner.
      await peer.publishCursor(
        const LiveCursor(
          actorId: 'phone-human',
          docId: 'doc-1',
          anchor: 3,
          head: 9,
          isAgent: false,
        ),
      );
      await _until(() => owner.cursorOf('phone-human') != null);
      expect(owner.cursorOf('phone-human')!.head, 9);

      // Stopping sharing RETRACTS: the human entry and cursor leave BOTH
      // devices (the owner rebroadcasts the scrubbed picture); agents
      // survive everywhere.
      await peer.setSharing(false);
      await _until(() => owner.actor('phone-human') == null);
      await _until(() => peer.actor('phone-human') == null);
      await _until(() => owner.cursorOf('phone-human') == null);
      expect(owner.actor('agent-laya'), isNotNull);
      expect(peer.actor('agent-doc'), isNotNull);
      expect(owner.cursorOf('agent-doc'), isNull);
    },
  );

  test('the adoption gate closes unpaired registrations before any link',
      () async {
    final server = AddressedRelayServer(port: 0);
    final port = await server.start();
    final endpoint = Uri.parse('ws://127.0.0.1:$port');
    addTearDown(server.dispose);

    final owner = await LiveMeshService.open(
      selfId: 'desktop',
      endpoint: endpoint,
      isOwner: true,
      pairedPeerIds: const {'phone'},
    );
    owner.host();
    addTearDown(owner.dispose);

    final stranger = await LiveMeshService.open(
      selfId: 'stranger',
      endpoint: endpoint,
      isOwner: false,
    );
    addTearDown(stranger.dispose);
    await stranger.join(ownerId: 'desktop');

    // The gate closed the session: the publish lands nowhere.
    await stranger.publish(_agent('agent-evil', LiveVerbs.editing));
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(owner.actor('agent-evil'), isNull);
    expect(owner.actors, isEmpty);
  });

  test(
    'human side end to end: hooks fire, the toggle opens the gate, the '
    'far agent sees watching/typing/caret, off retracts — agents stay',
    () async {
      final server = AddressedRelayServer(port: 0);
      final port = await server.start();
      final endpoint = Uri.parse('ws://127.0.0.1:$port');
      addTearDown(server.dispose);

      final owner = await LiveMeshService.open(
        selfId: 'desktop',
        endpoint: endpoint,
        isOwner: true,
        pairedPeerIds: const {'phone'},
      );
      owner.host();
      addTearDown(owner.dispose);

      final peer = await LiveMeshService.open(
        selfId: 'phone',
        endpoint: endpoint,
        isOwner: false,
      );
      await peer.join(ownerId: 'desktop');
      addTearDown(peer.dispose);

      // An agent works on the peer's device: always visible, and it must
      // SURVIVE every human privacy toggle below.
      await peer.publish(_agent('agent-laya', LiveVerbs.thinking, docId: 'doc-1'));
      await _until(() => owner.actor('agent-laya') != null);

      // The UI hooks fire unconditionally through the publisher — but
      // with the sharing toggle OFF (the default) the gate holds: the
      // human's watching/typing never leaves the device.
      final human = HumanLivePresence(
        service: peer,
        actorId: 'phone-human',
        displayName: 'Antonio',
        activityHold: Duration.zero,
        cursorInterval: Duration.zero,
      );
      await human.noteOpen('doc-1');
      await human.noteTyping('doc-1');
      await human.noteCursor('doc-1', offset: 7);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(owner.actor('phone-human'), isNull);
      expect(owner.cursorOf('phone-human'), isNull);

      // The toggle flips: the SAME hooks now flow. Open first…
      await peer.setSharing(true);
      await human.noteOpen('doc-1');
      await _until(() => owner.actor('phone-human') != null);
      expect(owner.actor('phone-human')!.verb, LiveVerbs.watching);

      // …then typing moves the verb in place on the far end…
      await human.noteTyping('doc-1');
      await _until(() => owner.actor('phone-human')!.verb == LiveVerbs.typing);

      // …and the caret lands where the agent could read it.
      await human.noteCursor('doc-1', offset: 12);
      await _until(() => owner.cursorOf('phone-human') != null);
      expect(owner.cursorOf('phone-human')!.head, 12);
      expect(owner.cursorOf('phone-human')!.docId, 'doc-1');

      // MUTUAL visibility: the owner-side human shares too, and the peer
      // sees it through the rebroadcast — each side sees the other.
      final ownerHuman = HumanLivePresence(
        service: owner,
        actorId: 'desktop-human',
        activityHold: Duration.zero,
      );
      await owner.setSharing(true);
      await ownerHuman.noteOpen('doc-1');
      await _until(() => peer.actor('desktop-human') != null);
      expect(peer.actor('desktop-human')!.verb, LiveVerbs.watching);

      // The agent read-path never mistakes a human for an agent.
      expect(owner.actor('phone-human')!.isAgent, isFalse);
      expect(owner.actor('desktop-human')!.isAgent, isFalse);

      // Toggle OFF: the human entries and caret retract everywhere; the
      // agent survives.
      await peer.setSharing(false);
      await _until(() => owner.actor('phone-human') == null);
      await _until(() => peer.actor('phone-human') == null);
      await _until(() => owner.cursorOf('phone-human') == null);
      await _until(() => peer.cursorOf('phone-human') == null);
      expect(owner.actor('agent-laya')!.verb, LiveVerbs.thinking);
    },
  );
}
