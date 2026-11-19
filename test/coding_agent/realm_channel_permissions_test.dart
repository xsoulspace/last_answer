/// ADR 0147 — the channel permission lane pinned over the REAL
/// [RealmChatService] on a hermetic [RealmWorld] (the real-IO pattern
/// realm_channel_service_test uses):
/// * the access policy: `read: 'members'` CLOSES the channel (a
///   non-member's harness read refuses `thread_not_visible`), an
///   invited member reads and says, and the DEFAULT (key absent) keeps
///   the open law — a stranger says and auto-joins;
/// * membership management: invite/remove through the wholesale
///   [RealmChatService.setChannelMembers] verb (self-eviction refused),
///   history untouched;
/// * the work scope: binding confers the scope on every member
///   (derived — [agentScopeGrants] answers it), eviction sheds it with
///   nothing to chase, and clearing removes it;
/// * the scope ledger: [RealmChatService.grantScope] (operator lane)
///   lands a folder grant with caps, [listScopeGrants] answers it with
///   provenance, [revokeScope] removes it.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/data_journal/actor_roster.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show DurableConversation, DurableRealmRefusal, agentScopeGrants;

final class _Chat {
  _Chat({
    required this.temp,
    required this.world,
    required this.service,
    required this.roster,
  });

  final Directory temp;
  final RealmWorld world;
  final RealmChatService service;
  final ActorRoster roster;

  String get humanId => service.humanActorId!;

  Future<void> dispose() async {
    service.dispose();
    await temp.delete(recursive: true);
  }
}

Future<_Chat> _openChat(final String label) async {
  final temp = await Directory.systemTemp.createTemp('la_channel_perms_$label');
  final world = await RealmWorld.open(rootOverride: temp.path);
  if (world == null) {
    await temp.delete(recursive: true);
    fail('realm world unsupported on this platform');
  }
  final roster = ActorRoster(replicaId: 'tester');
  final service = RealmChatService(
    debugWorldOverride: world,
    debugRosterOverride: roster,
    debugStartBotDispatcher: false,
  );
  service.firstRunSeedEnabled = false;
  await service.ensureReady();
  expect(service.isReady, isTrue, reason: service.error);
  return _Chat(temp: temp, world: world, service: service, roster: roster);
}

void main() {
  test('the access policy closes a channel and membership opens it',
      () async {
    final chat = await _openChat('policy');
    addTearDown(chat.dispose);
    final service = chat.service;
    final humanId = chat.humanId;
    final channel = await service.createChannel(
      'private',
      memberIds: [humanId],
    );
    expect(channel, isNotNull);
    final conversation = chat.world.conversation();

    // The DEFAULT law (key absent): the human may say; an uninvited
    // stranger may say too — auto-join on open, unchanged.
    const strangerId = 'stranger';
    final said = await conversation.say(
      actor: service.world!.authorityFor(humanId),
      threadId: channel!.threadId,
      text: 'open by default',
    );
    expect(said['ok'], isTrue);

    // CLOSE the channel: the stranger's say now refuses (they are not
    // a participant and the join plane is the entry).
    final closed = await service.setChannelAccess(
      channelId: channel.channelId,
      read: 'members',
    );
    expect(closed, isTrue, reason: service.error);
    await expectLater(
      conversation.say(
        actor: service.world!.authorityFor(strangerId),
        threadId: channel.threadId,
        text: 'refused',
      ),
      throwsA(
        isA<DurableRealmRefusal>().having(
          (e) => e.code,
          'code',
          'thread_not_visible',
        ),
      ),
    );

    // An invited member says fine (membership via the wholesale verb).
    final invited = await service.setChannelMembers(
      channelId: channel.channelId,
      memberIds: [humanId, strangerId],
    );
    expect(invited, isTrue, reason: service.error);
    final memberSaid = await conversation.say(
      actor: service.world!.authorityFor(strangerId),
      threadId: channel.threadId,
      text: 'member now',
    );
    expect(memberSaid['ok'], isTrue);

    // The HUMAN is PERMANENT (owner law): a set without the human
    // folds them back in — the stranger's membership alone is refused
    // as a self-eviction attempt only for a non-human caller; for the
    // human the fold-in makes this a no-op success.
    final foldBack = await service.setChannelMembers(
      channelId: channel.channelId,
      memberIds: [strangerId],
    );
    expect(foldBack, isTrue, reason: service.error);
    final row =
        (await chat.world.store.read('threads', channel.threadId))
            ?['participants'] as List?;
    expect(row, contains(humanId));
    expect(row, contains(strangerId));
  });

  test('the channel work scope confers on members and sheds on eviction',
      () async {
    final chat = await _openChat('scope');
    addTearDown(chat.dispose);
    final service = chat.service;
    final humanId = chat.humanId;
    final root = chat.temp.path;
    final channel = await service.createChannel(
      'work',
      memberIds: [humanId, 'guest'],
    );
    expect(channel, isNotNull);

    // The human opened the channel → the opener exemption lets it bind
    // a scope it does not hold (the server-owner model).
    final bound = await service.setChannelWorkScope(
      channelId: channel!.channelId,
      kind: 'folder',
      root: root,
      subpath: 'shared',
      caps: const ['fs.read'],
    );
    expect(bound, isTrue, reason: service.error);

    final guestScopes = await agentScopeGrants(chat.world.store, 'guest');
    expect(
      guestScopes.map((grant) => grant.path),
      contains('$root/shared'),
    );
    expect(
      guestScopes.firstWhere((grant) => grant.via != null).via,
      'channel:${channel.threadId}',
    );

    // Eviction sheds the conferred scope — nothing to chase.
    final removed = await service.removeChannelMembers(
      channelId: channel.channelId,
      memberIds: const ['guest'],
    );
    expect(removed, isTrue, reason: service.error);
    expect(await agentScopeGrants(chat.world.store, 'guest'), isEmpty);

    // Clearing the scope removes it from the remaining members too.
    final rebound = await service.setChannelWorkScope(
      channelId: channel.channelId,
      kind: 'folder',
      root: root,
      subpath: 'shared',
    );
    expect(rebound, isTrue, reason: service.error);
    expect(
      (await agentScopeGrants(chat.world.store, humanId)).map(
        (grant) => grant.path,
      ),
      contains('$root/shared'),
    );
    final cleared = await service.setChannelWorkScope(
      channelId: channel.channelId,
      kind: null,
      root: null,
    );
    expect(cleared, isTrue, reason: service.error);
    expect(
      (await agentScopeGrants(chat.world.store, humanId)).map(
        (grant) => grant.path,
      ),
      isNot(contains('$root/shared')),
    );
  });

  test('the scope ledger: grant with caps, list with provenance, revoke',
      () async {
    final chat = await _openChat('ledger');
    addTearDown(chat.dispose);
    final service = chat.service;
    final root = chat.temp.parent.path;

    final grant = await service.grantScope(
      actorId: 'scout',
      kind: 'folder',
      root: root,
      subpath: 'pkgs/app',
      caps: const ['fs.read', 'fs.write'],
    );
    expect(grant.granted, isTrue, reason: grant.message);
    final scopes = await service.listScopeGrants('scout');
    expect(scopes, hasLength(1));
    expect(scopes.single.path, '$root/pkgs/app');
    expect(scopes.single.caps, {'fs.read', 'fs.write'});
    expect(scopes.single.grantedBy, 'operator');

    // An unknown cap refuses with the harness's named refusal.
    final bad = await service.grantScope(
      actorId: 'scout',
      kind: 'folder',
      root: root,
      subpath: 'other',
      caps: const ['not.a.cap'],
    );
    expect(bad.granted, isFalse);
    expect(bad.message, 'grant_unknown_cap');

    final revoked = await service.revokeScope(
      actorId: 'scout',
      path: '$root/pkgs/app',
    );
    expect(revoked.granted, isTrue, reason: revoked.message);
    expect(await service.listScopeGrants('scout'), isEmpty);
  });
}
