/// ADR 0024 — the channel-management policy lane and the first-run
/// seed, pinned over the REAL [RealmChatService] on a hermetic
/// [RealmWorld] (the real-IO pattern realm_work_thread_test uses):
/// * [RealmChatService.renameChannel] walks createChannel's lane —
///   `channel_name_empty` and `channel_name_taken` (case-insensitive,
///   against any OTHER live channel) named refusals; success notifies,
///   projects the trimmed name, and lands durably;
/// * [RealmChatService.closeChannel] archives WITHOUT destroying: the
///   registry row and the journal thread survive (the journal is
///   authority — closing never destroys anything), the channel leaves
///   the lists, and the active selection is released only when it was
///   the closed channel's thread;
/// * [RealmChatService.roomThreads] never resurrects an archived
///   channel's thread as a "room";
/// * the seed laws: [RealmChatService.ensureReady] NEVER seeds
///   implicitly (hermetic fixtures stay empty), an empty world gets a
///   selected 'general' exactly once (idempotent, restart-safe), and an
///   archived 'general' is never resurrected.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

/// One hermetic chat world: a disposable home, a realm world over it,
/// and a READY service bound through the debug seams (bot dispatcher
/// off — no wake timers in tests).
final class _Chat {
  _Chat({required this.temp, required this.world, required this.service});

  final Directory temp;
  final RealmWorld world;
  final RealmChatService service;

  String get humanId => service.humanActorId!;

  ChannelRegistry get registry => ChannelRegistry(store: world.store);

  Future<void> dispose() async {
    service.dispose();
    await temp.delete(recursive: true);
  }
}

Future<_Chat> _openChat(final String label) async {
  final temp = await Directory.systemTemp.createTemp('la_channel_svc_$label');
  final world = await RealmWorld.open(rootOverride: temp.path);
  if (world == null) {
    await temp.delete(recursive: true);
    fail('realm world unsupported on this platform');
  }
  final service = RealmChatService(
    debugWorldOverride: world,
    debugRosterOverride: ActorRoster(replicaId: 'tester'),
    debugStartBotDispatcher: false,
  );
  await service.ensureReady();
  expect(service.isReady, isTrue, reason: service.error);
  return _Chat(temp: temp, world: world, service: service);
}

/// A fresh service over the SAME world (an app restart without a store
/// reopen): the seed laws must ride the registry, never memory.
Future<RealmChatService> _restartService(final _Chat chat) async {
  final restarted = RealmChatService(
    debugWorldOverride: chat.world,
    debugRosterOverride: ActorRoster(replicaId: 'tester'),
    debugStartBotDispatcher: false,
  );
  addTearDown(restarted.dispose);
  await restarted.ensureReady();
  expect(restarted.isReady, isTrue, reason: restarted.error);
  return restarted;
}

void main() {
  test('renameChannel: the createChannel policy lane — named refusals, '
      'notified persistent success', () async {
    final chat = await _openChat('rename');
    addTearDown(chat.dispose);
    final general = await chat.service.createChannel('general');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final design = await chat.service.createChannel('design');
    expect(general, isNotNull);
    expect(design, isNotNull);

    // An empty trimmed name refuses with the lane's named error.
    expect(
      await chat.service.renameChannel(design!.channelId, '   '),
      isFalse,
    );
    expect(chat.service.error, 'channel_name_empty');

    // A case-insensitive duplicate against any OTHER live channel
    // refuses with the lane's named error.
    expect(
      await chat.service.renameChannel(design.channelId, 'GENERAL'),
      isFalse,
    );
    expect(chat.service.error, 'channel_name_taken');

    // The same name as ITSELF is no duplicate — the check excludes self.
    expect(
      await chat.service.renameChannel(design.channelId, 'design'),
      isTrue,
    );

    // An unknown channel answers false — honest absence, never a throw.
    expect(
      await chat.service.renameChannel('channel-000000000000', 'whatever'),
      isFalse,
    );

    // Success: trimmed, notified, projected, durable — and every other
    // field verbatim.
    var notifications = 0;
    chat.service.addListener(() => notifications++);
    expect(
      await chat.service.renameChannel(design.channelId, '  Art Direction '),
      isTrue,
    );
    expect(notifications, greaterThan(0));
    expect(
      chat.service.channels.map((final c) => c.name),
      <String>['general', 'Art Direction'],
    );
    final row = await chat.world.store.read('channels', design.channelId);
    expect(row?['name'], 'Art Direction');
    expect(row?['threadId'], design.threadId);
    expect(row?['createdAt'], design.createdAt);
    // The channel's journal thread keeps its ORIGINAL topic — the
    // journal is authority; LA never rewrites its rows.
    final threadRow = await chat.world.store.read('threads', design.threadId);
    expect(threadRow?['topic'], 'design');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('closeChannel: archives without destroying; the selection '
      "releases only for the closed channel's own thread", () async {
    final chat = await _openChat('close');
    addTearDown(chat.dispose);
    final general = (await chat.service.createChannel('general'))!;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final design = (await chat.service.createChannel('design'))!;

    // A plain group thread (three participants — a watchable "room") to
    // keep the selection law observable.
    await chat.service.startThread(
      topic: 'Group room',
      participants: const <String>['worker-a', 'worker-b'],
    );
    final groupThreadId = chat.service.activeThreadId!;

    // Closing a channel whose thread is NOT active keeps the selection.
    expect(await chat.service.closeChannel(general.channelId), isTrue);
    expect(
      chat.service.activeThreadId,
      groupThreadId,
      reason: "only the closed channel's own thread releases the selection",
    );
    expect(
      chat.service.channels.map((final c) => c.channelId),
      <String>[design.channelId],
    );

    // Closing the SELECTED channel clears the selection.
    chat.service.selectChannel(design.channelId);
    expect(chat.service.activeThreadId, design.threadId);
    expect(await chat.service.closeChannel(design.channelId), isTrue);
    expect(chat.service.activeThreadId, isNull);
    expect(chat.service.channels, isEmpty);

    // An unknown id answers false — honest absence, never a throw.
    expect(
      await chat.service.closeChannel('channel-000000000000'),
      isFalse,
    );

    // The closing-never-destroys law: both registry rows survive as
    // archived history, and both journal threads survive OPEN (the
    // journal is authority — the channel just left the lists).
    final all = await chat.registry.list(includeArchived: true);
    expect(all, hasLength(2));
    expect(all.every((final c) => c.archived), isTrue);
    for (final threadId in <String>[general.threadId, design.threadId]) {
      final row = await chat.world.store.read('threads', threadId);
      expect(row, isNotNull, reason: 'the journal thread survives');
      expect(row?['closed'], false);
    }
    // The thread projection still carries the archived channel's thread
    // (it is open); only the ROOM list must hide it.
    expect(
      chat.service.threads.any((final t) => t['threadId'] == design.threadId),
      isTrue,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test("roomThreads never resurrects an archived channel's thread as a "
      'room', () async {
    final chat = await _openChat('rooms');
    addTearDown(chat.dispose);
    await chat.service.ensureSeededChannel();
    final general = chat.service.channels.single;
    await chat.service.startThread(
      topic: 'Group room',
      participants: const <String>['worker-a', 'worker-b'],
    );
    final groupThreadId = chat.service.activeThreadId!;

    // A LIVE channel is not a room; the plain group thread is.
    expect(
      chat.service.roomThreads.map((final t) => t['threadId']),
      <String>[groupThreadId],
    );

    // After the close, the human-only channel thread (ONE participant —
    // no DM shape, no live channel) must not leak into the rooms.
    expect(await chat.service.closeChannel(general.channelId), isTrue);
    expect(
      chat.service.roomThreads.map((final t) => t['threadId']),
      <String>[groupThreadId],
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('seed laws: never inside ensureReady; an empty world gets a '
      'selected general exactly once', () async {
    final chat = await _openChat('seed');
    addTearDown(chat.dispose);

    // ensureReady NEVER seeds implicitly — hermetic fixtures stay empty
    // until the shell asks.
    expect(chat.service.channels, isEmpty);

    // A world that never had a channel gets 'general', human-only and
    // selected (the createChannel lane's success half).
    await chat.service.ensureSeededChannel();
    expect(chat.service.channels, hasLength(1));
    final general = chat.service.channels.single;
    expect(general.name, 'general');
    expect(general.name, RealmChatService.seededChannelName);
    expect(general.memberIds, <String>[chat.humanId]);
    expect(
      chat.service.activeThreadId,
      general.threadId,
      reason: 'the seed selects its channel',
    );

    // Idempotent: the second call is a no-op (one row, same id).
    await chat.service.ensureSeededChannel();
    expect(chat.service.channels, hasLength(1));
    expect(chat.service.channels.single.channelId, general.channelId);
    expect(
      await chat.registry.list(includeArchived: true),
      hasLength(1),
    );

    // A restart (fresh service, empty projections) over the same world
    // seeds nothing new — the law rides the registry, never memory.
    final restarted = await _restartService(chat);
    await restarted.ensureSeededChannel();
    expect(restarted.channels, hasLength(1));
    expect(restarted.channels.single.channelId, general.channelId);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('seed laws: an archived general is NEVER resurrected', () async {
    final chat = await _openChat('seedarchived');
    addTearDown(chat.dispose);
    await chat.service.ensureSeededChannel();
    final general = chat.service.channels.single;
    expect(await chat.service.closeChannel(general.channelId), isTrue);
    expect(chat.service.channels, isEmpty);

    // The seed verb reads the HISTORY (includeArchived), not the live
    // list: a world whose only channel was closed stays empty.
    await chat.service.ensureSeededChannel();
    expect(chat.service.channels, isEmpty);
    final all = await chat.registry.list(includeArchived: true);
    expect(all, hasLength(1));
    expect(all.single.channelId, general.channelId);
    expect(all.single.archived, isTrue);

    // A restarted service agrees — no resurrection across a boot.
    final restarted = await _restartService(chat);
    await restarted.ensureSeededChannel();
    expect(restarted.channels, isEmpty);
    expect(
      await chat.registry.list(includeArchived: true),
      hasLength(1),
    );
  }, timeout: const Timeout(Duration(minutes: 2)));
}
