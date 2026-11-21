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
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/data_journal/actor_creation.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:lastanswer/ecs_plugins/conversation/conversation_spaces.dart';

/// One hermetic chat world: a disposable home, a realm world over it,
/// and a READY service bound through the debug seams (bot dispatcher
/// off — no wake timers in tests).
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
  final roster = ActorRoster(replicaId: 'tester');
  final service = RealmChatService(
    debugWorldOverride: world,
    debugRosterOverride: roster,
    debugStartBotDispatcher: false,
  );
  await service.ensureReady();
  expect(service.isReady, isTrue, reason: service.error);
  return _Chat(temp: temp, world: world, service: service, roster: roster);
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
    // ADR 0146 W3 — rename = topic edit (one fact, one write): the
    // ROW's topic IS the channel name, and the registry mirror rode
    // the flip (no row minted for a row-built channel — the channels
    // collection stays empty, retained forever).
    final row = await chat.world.store.read('channels', design.channelId);
    expect(row, isNull, reason: 'the mirror rode the W3 flip');
    final threadRow = await chat.world.store.read('threads', design.threadId);
    expect(threadRow?['topic'], 'Art Direction');
    // ADR 0146 — BOTH spellings rename: the row-built threadId-as-id.
    expect(await chat.service.renameChannel(design.threadId, 'studio'), isTrue);
    final renamedRow = await chat.world.store.read(
      'threads',
      design.threadId,
    );
    expect(renamedRow?['topic'], 'studio');
    expect(
      chat.service.channels.map((final c) => c.name),
      <String>['general', 'studio'],
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('setChannelMembers: the row write IS the membership — add/remove '
      'round trip, human permanence, honest refusals', () async {
    final chat = await _openChat('members');
    addTearDown(chat.dispose);
    final worker = (await chat.service.createActor(
      displayName: 'Worker A',
      kind: ActorKind.model,
      brainRef: '',
    ))!;
    final peer = (await chat.service.createActor(
      displayName: 'Worker B',
      kind: ActorKind.model,
      brainRef: '',
    ))!;
    final human = chat.humanId;
    final design =
        (await chat.service.createChannel('design', memberIds: [
          worker.actorId,
        ]))!;
    // Baseline: the creation member set with the human folded in.
    expect(
      design.memberIds,
      <String>[...<String>[human, worker.actorId]..sort()],
    );

    // Success notifies, dedupes, and lands in the ROW's participants
    // (ADR 0146: participants IS the membership — the registry mirror
    // rode the W3 flip, no registry row exists).
    var notifications = 0;
    chat.service.addListener(() => notifications++);
    expect(
      await chat.service.setChannelMembers(
        channelId: design.channelId,
        memberIds: [worker.actorId, peer.actorId, worker.actorId],
      ),
      isTrue,
    );
    expect(notifications, greaterThan(0));
    final added = chat.service.channelByThreadId(design.threadId)!;
    expect(
      added.memberIds,
      <String>[...<String>[human, worker.actorId, peer.actorId]..sort()],
    );
    final threadRow = await chat.world.store.read('threads', design.threadId);
    expect(threadRow?['participants'], added.memberIds);
    expect(await chat.world.store.read('channels', design.channelId), isNull,
        reason: 'the mirror rode the W3 flip');

    // The human is PERMANENT in channels (owner law, 2026-11-18): a set
    // without the human folds them back in.
    expect(
      await chat.service.setChannelMembers(
        channelId: design.channelId,
        memberIds: <String>[peer.actorId],
      ),
      isTrue,
    );
    final minusWorker = chat.service.channelByThreadId(design.threadId)!;
    expect(minusWorker.memberIds, contains(human));
    expect(minusWorker.memberIds, isNot(contains(worker.actorId)));

    // BOTH id spellings resolve (the threadId-as-id channel).
    expect(
      await chat.service.setChannelMembers(
        channelId: design.threadId,
        memberIds: <String>[worker.actorId, peer.actorId],
      ),
      isTrue,
    );
    expect(
      chat.service.channelByThreadId(design.threadId)!.memberIds,
      <String>[...<String>[human, worker.actorId, peer.actorId]..sort()],
    );

    // An unknown id answers false — honest absence, never a throw.
    expect(
      await chat.service.setChannelMembers(
        channelId: 'channel-000000000000',
        memberIds: <String>[peer.actorId],
      ),
      isFalse,
    );

    // An empty set is legal: the human-only channel (the seed's shape).
    expect(
      await chat.service.setChannelMembers(
        channelId: design.channelId,
        memberIds: const <String>[],
      ),
      isTrue,
    );
    expect(
      chat.service.channelByThreadId(design.threadId)!.memberIds,
      <String>[human],
    );
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
    // ADR 0146 — the projection is row-built: the surviving channel's
    // id IS its threadId.
    expect(
      chat.service.channels.map((final c) => c.channelId),
      <String>[design.threadId],
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

    // The closing-never-destroys law: both thread rows survive as
    // archived history (the mirror rode the W3 flip — the registry
    // collection stays empty, retained forever), and both journal
    // threads survive OPEN (the journal is authority — the channel
    // just left the lists).
    final all = await chat.world.store.scan('threads');
    final archivedRows = all.values.where(
      (final row) => row['kind'] == 'channel' && row['archived'] == true,
    );
    expect(archivedRows, hasLength(2));
    expect(await chat.world.store.scan('channels'), isEmpty);
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
    // ADR 0146 W3 — the seed's once-law rides the ROW (the registry
    // mirror rode the flip): exactly one kind:channel row, and the
    // channels collection stays empty.
    final seededRows = (await chat.world.store.scan('threads')).values
        .where((final row) => row['kind'] == 'channel');
    expect(seededRows, hasLength(1));
    expect(await chat.world.store.scan('channels'), isEmpty);

    // A restart (fresh service, empty projections) over the same world
    // seeds nothing new — the law rides the registry, never memory.
    final restarted = await _restartService(chat);
    await restarted.ensureSeededChannel();
    expect(restarted.channels, hasLength(1));
    expect(restarted.channels.single.threadId, general.threadId);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('seed laws: an archived general is NEVER resurrected', () async {
    final chat = await _openChat('seedarchived');
    addTearDown(chat.dispose);
    await chat.service.ensureSeededChannel();
    final general = chat.service.channels.single;
    expect(await chat.service.closeChannel(general.channelId), isTrue);
    expect(chat.service.channels, isEmpty);

    // The seed verb reads the projection's HISTORY (any kind:channel
    // row, live or archived), not the live list: a world whose only
    // channel was closed stays empty.
    await chat.service.ensureSeededChannel();
    expect(chat.service.channels, isEmpty);
    // ADR 0146 W3 — the archived seed's ROW carries the flag (the
    // mirror rode the flip); compare by thread.
    final archivedRow = await chat.world.store.read(
      'threads',
      general.threadId,
    );
    expect(archivedRow?['kind'], 'channel');
    expect(archivedRow?['archived'], isTrue);

    // A restarted service agrees — no resurrection across a boot.
    final restarted = await _restartService(chat);
    await restarted.ensureSeededChannel();
    expect(restarted.channels, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test("dmThreadOf: another surface's two-member thread is never a DM "
      'reuse key; a plain DM still reuses', () async {
    final chat = await _openChat('dmreuse');
    addTearDown(chat.dispose);
    final toby = await createActorIdentity(
      roster: chat.roster,
      world: chat.world,
      displayName: 'Toby Researcher',
      kind: ActorKind.model,
      brainRef: 'local:qwen',
      role: 'research assistant',
    );

    // A machine-minted 1-member channel over {human, toby} — the
    // dogfood-leg shape (seen live: DM on cache-probe landed in
    // `dogfood-1794173922369`). It must never resolve as the DM.
    final channel = await chat.service.createChannel(
      'dogfood-1',
      memberIds: [toby.actorId],
    );
    expect(channel, isNotNull);
    expect(chat.service.dmThreadOf(toby.actorId), isNull);

    // Archiving does not resurrect the thread as a DM either — the
    // journal row survives, so the skip rides the archived set too.
    expect(await chat.service.closeChannel(channel!.channelId), isTrue);
    expect(chat.service.dmThreadOf(toby.actorId), isNull);

    // A project-sealed work thread (ADR 0129) over the same pair is
    // likewise never a DM reuse key.
    final human = chat.world.authorityFor(chat.humanId);
    final opened = await chat.world.conversation().open(
          actor: human,
          topic: 'workorder-1',
          participants: [toby.actorId],
        );
    final workThreadId = opened['threadId']! as String;
    await WorkThreadRegistry(store: chat.world.store).create(
      workThreadId: workThreadId,
      parentThreadId: workThreadId,
      projectRoot: '/tmp/la_dm_reuse',
      name: 'w',
      createdBy: chat.humanId,
    );
    await chat.service.refreshWorkThreads();
    expect(chat.service.dmThreadOf(toby.actorId), isNull);

    // With no plain DM, openDm CREATES one titled with the actor — and
    // a second open reuses it (the reuse law holds for plain DMs).
    await chat.service.openDm(toby.actorId);
    final dmId = chat.service.dmThreadOf(toby.actorId);
    expect(dmId, isNotNull);
    expect(dmId, isNot(workThreadId));
    expect(chat.service.activeThread?['topic'], 'Toby Researcher');
    await chat.service.openDm(toby.actorId);
    expect(chat.service.dmThreadOf(toby.actorId), dmId);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('ADR 0145 declared beats inference: openDm writes kind dm on the '
      'row and a DECLARED dm is the reuse key even over a registry '
      'skip; createChannel writes kind channel in the same call', () async {
    final chat = await _openChat('declare');
    addTearDown(chat.dispose);
    final toby = await createActorIdentity(
      roster: chat.roster,
      world: chat.world,
      displayName: 'Toby Researcher',
      kind: ActorKind.model,
      brainRef: 'local:qwen',
      role: 'research assistant',
    );

    // openDm DECLARES: the fresh thread's journal row carries kind dm.
    await chat.service.openDm(toby.actorId);
    final dmId = chat.service.activeThreadId!;
    final dmRow = await chat.world.store.read('threads', dmId);
    expect(dmRow?['kind'], 'dm');
    expect(chat.service.dmThreadOf(toby.actorId), dmId);

    // The pairing invariant: createChannel writes the declared kind on
    // the thread row (open then the mirror — and the mirror rode the
    // W3 flip: the collection stays empty, the row IS the pairing).
    final design = (await chat.service.createChannel('design'))!;
    final channelThreadRow = await chat.world.store.read(
      'threads',
      design.threadId,
    );
    expect(channelThreadRow?['kind'], 'channel');
    expect(await chat.world.store.scan('channels'), isEmpty);

    // The FAST PATH: a declared dm row is the DM even when its id ALSO
    // sits in the live channel registry — declared beats inference
    // (classifyThread answers dm before any set is touched; the
    // pre-kind skip would have hidden it). The registry write is the
    // honest-failure scenario's shape: a thread that opened kind dm
    // with a stray channel row over it.
    await ChannelRegistry(store: chat.world.store).create(
      name: 'stray-over-dm',
      threadId: dmId,
      memberIds: <String>[chat.humanId, toby.actorId],
    );
    // Rebuild the projections over the mutated registry (a fresh
    // service — the restart is also the honest projection path).
    // ADR 0146 W3 — reads off, the stray REGISTRY row is invisible
    // (the fallback rode the flip); the row's DECLARED kind wins and
    // the dm reuse key stands.
    final restarted = await _restartService(chat);
    expect(
      restarted.channels.map((final c) => c.threadId),
      isNot(contains(dmId)),
      reason: 'reads off: the stray registry row is honestly invisible',
    );
    expect(restarted.dmThreadOf(toby.actorId), dmId);
    // Reuse stays: a second open does not mint a duplicate.
    await restarted.openDm(toby.actorId);
    expect(restarted.activeThreadId, dmId);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('ADR 0145 projections: a declared session is watchable with its '
      'label, a sealed thread is DERIVED work (never a room), and the '
      'session verb refuses an empty label', () async {
    final chat = await _openChat('kinds');
    addTearDown(chat.dispose);
    final ada = await createActorIdentity(
      roster: chat.roster,
      world: chat.world,
      displayName: 'Ada',
      kind: ActorKind.model,
      brainRef: '',
    );
    final grace = await createActorIdentity(
      roster: chat.roster,
      world: chat.world,
      displayName: 'Grace',
      kind: ActorKind.model,
      brainRef: '',
    );
    final human = chat.world.authorityFor(chat.humanId);

    // The untyped actor↔actor room: absorption law, today's shape
    // (opened BY an actor — the human merely watches, so no dm shape).
    final opened = await chat.world.conversation().open(
          actor: chat.world.authorityFor(ada.actorId),
          topic: 'Ada ⇄ Grace',
          participants: <String>[grace.actorId],
          realmSealed: true,
        );
    final actorRoom = opened['threadId']! as String;

    // The empty label refuses with the named error — nothing opened.
    expect(await chat.service.openSession('   '), isNull);
    expect(chat.service.error, 'session_label_missing');

    // The declared session: realm-sealed (no project seal), kind on
    // the row, the human plus the normalized members.
    final session = await chat.service.openSession(
      '  smoke-run-1  ',
      memberIds: <String>[ada.actorId, '  '],
    );
    expect(session, isNotNull);
    final sessionId = session!['threadId']! as String;
    expect(session['kind'], 'session');
    final sessionRow = await chat.world.store.read('threads', sessionId);
    expect(sessionRow?['kind'], 'session');
    expect(sessionRow?['projectId'], isNull);
    expect(sessionRow?['topic'], 'smoke-run-1');
    final sessionMembers =
        (sessionRow?['participants'] as List? ?? const <Object?>[])
            .cast<String>()
            .toList()
          ..sort();
    expect(sessionMembers, <String>[ada.actorId, chat.humanId]..sort());

    // The DERIVED work row: project-sealed, UNTYPED — work is never
    // declared; the seal alone decides (here the human's own scope, so
    // the row is visible to the human's projection).
    final sealed = await chat.world.conversation().open(
          actor: human,
          topic: 'sealed work',
          participants: <String>[ada.actorId, grace.actorId],
          projectId: human.projectId,
        );
    final sealedId = sealed['threadId']! as String;
    final sealedRow = await chat.world.store.read('threads', sealedId);
    expect(sealedRow?['kind'], isNull);
    expect(sealedRow?['projectId'], human.projectId);

    await chat.service.refreshThreads();
    final roomIds = chat.service.roomThreads
        .map((final t) => t['threadId'])
        .toList();
    expect(roomIds, contains(actorRoom), reason: 'absorption: untyped room');
    expect(
      roomIds,
      contains(sessionId),
      reason: 'a declared session is a watchable machine-life room',
    );
    expect(
      roomIds,
      isNot(contains(sealedId)),
      reason: 'the seal derives work — its projection is the work card',
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('ADR 0146 W2 heal: pre-window channel rows backfill at boot '
      '(kind/icon/archived, per-field) and the heal is idempotent',
      () async {
    final chat = await _openChat('heal');
    addTearDown(chat.dispose);
    final human = chat.world.authorityFor(chat.humanId);
    // A PRE-WINDOW world: two UNTYPED thread rows (kind absent — the
    // pre-ADR 0145 shape) over registry rows, one live with an icon,
    // one archived. The first service booted on the empty world, so
    // the rows here are crafted after it and healed by the RESTART
    // below.
    final live = await chat.world.conversation().open(
          actor: human,
          topic: 'legacy-live',
          realmSealed: true,
        );
    final liveThreadId = live['threadId']! as String;
    final legacy = chat.registry;
    final liveRow = await legacy.create(
      name: 'legacy-live',
      threadId: liveThreadId,
      memberIds: <String>[chat.humanId],
      icon: 'star',
    );
    final dead = await chat.world.conversation().open(
          actor: human,
          topic: 'legacy-dead',
          realmSealed: true,
        );
    final deadThreadId = dead['threadId']! as String;
    final deadRow = await legacy.create(
      name: 'legacy-dead',
      threadId: deadThreadId,
      memberIds: <String>[chat.humanId],
    );
    expect(await legacy.archive(channelId: deadRow.channelId), isTrue);
    final preLive = await chat.world.store.read('threads', liveThreadId);
    expect(preLive?['kind'], isNull);
    expect(preLive?.containsKey('icon'), isFalse);
    expect(preLive?.containsKey('archived'), isFalse);

    // The boot heal: ensureReady runs migrateIntoRows — the rows come
    // up row-shaped and the one-projection reads see both channels
    // exactly as the registry holds them.
    final restarted = await _restartService(chat);
    expect(restarted.channels.map((final c) => c.name), <String>[
      'legacy-live',
    ], reason: 'the archived pre-window channel left the live lists');
    final healedLive = await chat.world.store.read('threads', liveThreadId);
    expect(healedLive?['kind'], 'channel');
    expect(healedLive?['icon'], 'star');
    // Never-null law: absent-means-default keys were never written.
    expect(healedLive?.containsKey('archived'), isFalse);
    final healedDead = await chat.world.store.read('threads', deadThreadId);
    expect(healedDead?['kind'], 'channel');
    expect(healedDead?['archived'], true);
    expect(healedDead?.containsKey('icon'), isFalse);

    // The healed view: the legacy channel answers with its PRESERVED
    // mint as the id (retained forever; both spellings resolve — the
    // row-built threadId spelling via threadIdForSurface below).
    final channel = restarted.channels.single;
    // ADR 0146 W3 — the preserved mint is the legacy channel's view id
    // (retained forever; resolvers accept both spellings).
    expect(channel.channelId, liveRow.channelId);
    expect(channel.icon, 'star');
    expect(
      restarted.threadIdForSurface('channel:${liveRow.channelId}'),
      liveThreadId,
    );
    // An archived pre-window channel's thread never resurfaces as a
    // room (the same resurrection guard, over the healed rows).
    expect(
      restarted.roomThreads.map((final t) => t['threadId']),
      isNot(contains(deadThreadId)),
    );

    // IDEMPOTENT: the direct second call heals 0, and the boot heal on
    // yet another restart re-projects the same view.
    expect(await legacy.migrateIntoRows(), 0);
    final twice = await _restartService(chat);
    expect(twice.channels.single.channelId, liveRow.channelId);
    expect(twice.channels.single.icon, 'star');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('ADR 0146 W3 resolver truth table: BOTH channel-id spellings '
      'resolve through the ONE resolvers — the healed legacy mint and '
      'the row-built threadId-as-id — across a restart', () async {
    final chat = await _openChat('truth');
    addTearDown(chat.dispose);
    // A ROW-BUILT channel: the id IS the threadId (the mint retired).
    final guild = (await chat.service.createChannel('guild'))!;
    final threadId = guild.threadId;
    expect(guild.channelId, threadId);
    // A LEGACY channel: a registry row over an untyped thread row,
    // healed by the restart's boot heal — the mint is PRESERVED on
    // the row and stays the legacy channel's view id.
    final human = chat.world.authorityFor(chat.humanId);
    final legacyOpen = await chat.world.conversation().open(
      actor: human,
      topic: 'legacy-guild',
      realmSealed: true,
    );
    final legacyThreadId = legacyOpen['threadId']! as String;
    final legacyRow = await chat.registry.create(
      name: 'legacy-guild',
      threadId: legacyThreadId,
      memberIds: <String>[chat.humanId],
    );
    final legacyId = legacyRow.channelId;
    expect(legacyId, isNot(legacyThreadId));

    // The row-built projection: channelId IS the threadId.
    expect(chat.service.channelByThreadId(threadId)?.channelId, threadId);
    expect(chat.service.channelByAnyId(threadId)?.channelId, threadId);
    // threadIdForSurface: the row-built spelling answers; an unknown
    // id honestly refuses.
    expect(chat.service.threadIdForSurface('channel:$threadId'), threadId);
    expect(
      chat.service.threadIdForSurface('channel:channel-000000000000'),
      isNull,
    );

    // A restart heals the legacy row: BOTH spellings resolve — the
    // preserved mint (legacy tabs and references never die) and the
    // row-built threadId ride the row.
    final restarted = await _restartService(chat);
    expect(restarted.threadIdForSurface('channel:$legacyId'), legacyThreadId);
    expect(restarted.threadIdForSurface('channel:$threadId'), threadId);
    expect(restarted.channelByAnyId(legacyId)?.threadId, legacyThreadId);
    expect(restarted.channelByAnyId(threadId)?.channelId, threadId);
    // selectChannel: both spellings select their threads.
    restarted.selectChannel(legacyId);
    expect(restarted.activeThreadId, legacyThreadId);
    restarted.selectChannel(threadId);
    expect(restarted.activeThreadId, threadId);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('ADR 0146 W3 archive: the ROW flips in one verb, both '
      'spellings archive, and thread_not_kind_channel surfaces '
      'verbatim', () async {
    final chat = await _openChat('archive');
    addTearDown(chat.dispose);
    final guild = (await chat.service.createChannel('guild'))!;
    // Archive by the ROW-BUILT spelling (the threadId): the thread
    // row's `archived: true` lands (the registry mirror rode the
    // flip — the collection stays empty).
    expect(await chat.service.closeChannel(guild.threadId), isTrue);
    final threadRow = await chat.world.store.read('threads', guild.threadId);
    expect(threadRow?['archived'], true);
    expect(await chat.world.store.scan('channels'), isEmpty);
    expect(chat.service.channels, isEmpty);
    // Closing never destroys: the thread survives OPEN.
    expect(threadRow?['closed'], false);

    // Re-archiving an archived channel stays honest idempotence (true).
    expect(await chat.service.closeChannel(guild.channelId), isTrue);

    // An id naming an existing NON-channel thread refuses with the
    // harness verb's honest name, surfaced verbatim.
    await chat.service.startThread(topic: 'Plain room');
    final plainId = chat.service.activeThreadId!;
    expect(await chat.service.closeChannel(plainId), isFalse);
    expect(chat.service.error, 'thread_not_kind_channel');
    final plainRow = await chat.world.store.read('threads', plainId);
    expect(plainRow?.containsKey('archived'), isFalse);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('ADR 0146 W3 the icon round-trip: the row key lands (a null '
      'clear REMOVES it); the registry mirror rode the flip; both '
      'spellings address the channel', () async {
    final chat = await _openChat('icon');
    addTearDown(chat.dispose);
    final design = (await chat.service.createChannel('design'))!;
    expect(
      await chat.service.setChannelIcon(
        channelId: design.threadId,
        icon: 'bug',
      ),
      isTrue,
    );
    var row = await chat.world.store.read('threads', design.threadId);
    expect(row?['icon'], 'bug');
    // The mirror rode the flip: the collection stays empty (retained
    // forever) — the row IS the icon's authority.
    expect(await chat.world.store.scan('channels'), isEmpty);
    expect(chat.service.channels.single.icon, 'bug');

    // Both spellings address the same channel (the row-built id IS
    // the threadId); a null clear removes the row key (never
    // 'icon': null).
    expect(
      await chat.service.setChannelIcon(
        channelId: design.channelId,
        icon: null,
      ),
      isTrue,
    );
    row = await chat.world.store.read('threads', design.threadId);
    expect(row?.containsKey('icon'), isFalse);
    expect(chat.service.channels.single.icon, isNull);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('ADR 0146 W3 dormancy: the fallback cache and the registry '
      'collection stay empty; the row view carries the channel', () async {
    final chat = await _openChat('dormancy');
    addTearDown(chat.dispose);
    // The boot is the dormancy gate: ensureReady ran the heal (a
    // no-op scan over the empty collection) and left the W3 flip
    // standing.
    await chat.service.ensureReady();
    final design = (await chat.service.createChannel('design'))!;

    // The flip: the LEGACY fallback cache answers EMPTY...
    expect(chat.service.registryChannels, isEmpty);
    // ...and the retained `channels` collection stays unwritten (the
    // row IS the channel — nothing mirrored, nothing deleted).
    expect(await chat.world.store.scan('channels'), isEmpty);

    // The row view still carries the channel from its own row — the
    // UI's truth never depended on the dormant registry.
    expect(chat.service.channels, hasLength(1));
    expect(chat.service.channels.single.name, 'design');
    expect(chat.service.channels.single.threadId, design.threadId);
    expect(chat.service.channels.single.channelId, design.threadId);
    expect(chat.service.channelByAnyId(design.threadId)?.name, 'design');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
