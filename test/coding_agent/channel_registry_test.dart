import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

void main() {
  // ADR 0024 — the `channels` collection: named threads registered in
  // the realm's ONE control store, existing before anyone speaks.
  //
  // This suite pins the DUMB durable half (round-trip, archive/rename
  // mechanics, tolerant decode, durability). The policy half (name
  // refusals, close/seed laws, roomThreads hiding) rides the hermetic
  // service seam in realm_channel_service_test.dart.
  test('channel records round-trip through the realm store', () async {
    final temp = await Directory.systemTemp.createTemp('la_channel_reg_');
    addTearDown(() => temp.delete(recursive: true));
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) fail('realm world unsupported on this platform');
    final registry = ChannelRegistry(store: world.store);

    final first = await registry.create(
      name: 'design-crit',
      threadId: 'thread-aaaaaaaaaaaa',
      memberIds: ['human-test-device', ' bot-1 ', 'bot-1'],
    );
    // channelId: 'channel-' + the DurableConversation minting style —
    // 12 secure random bytes rendered as 24 hex chars (the task brief's
    // "12 hex chars" was a miscount of the harness's generate(12); the
    // binding clause is "same minting style as DurableConversation").
    expect(
      RegExp(r'^channel-[0-9a-f]{24}$').hasMatch(first.channelId),
      isTrue,
      reason: 'channelId should be channel- + DurableConversation-style '
          'hex, got ${first.channelId}',
    );
    expect(first.name, 'design-crit');
    expect(first.threadId, 'thread-aaaaaaaaaaaa');
    // Member ids normalize: trimmed, deduped, sorted.
    expect(first.memberIds, <String>['bot-1', 'human-test-device']);
    expect(first.createdAt, isNotEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 5));
    final second = await registry.create(
      name: 'ops',
      threadId: 'thread-bbbbbbbbbbbb',
      memberIds: const <String>['human-test-device'],
    );

    // list() is sorted by createdAt, oldest first.
    final listed = await registry.list();
    expect(
      listed.map((channel) => channel.channelId).toList(),
      <String>[first.channelId, second.channelId],
    );

    expect((await registry.byThreadId('thread-aaaaaaaaaaaa'))?.name,
        'design-crit');
    expect(await registry.byThreadId('thread-missing'), isNull);
    expect(
      (await registry.byId(second.channelId))?.threadId,
      'thread-bbbbbbbbbbbb',
    );
    expect(await registry.byId('channel-000000000000'), isNull);

    // Durable: a fresh registry over the same store sees the records —
    // the channel existed before anyone spoke in its thread.
    final reopened = ChannelRegistry(store: world.store);
    final reopenedList = await reopened.list();
    expect(reopenedList, hasLength(2));
    expect((await reopened.byId(first.channelId))?.name, 'design-crit');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('archive leaves the live list; the row survives in the history',
      () async {
    final temp = await Directory.systemTemp.createTemp('la_channel_reg_');
    addTearDown(() => temp.delete(recursive: true));
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) fail('realm world unsupported on this platform');
    final registry = ChannelRegistry(store: world.store);

    final first = await registry.create(
      name: 'design-crit',
      threadId: 'thread-aaaaaaaaaaaa',
      memberIds: const <String>['human-test-device'],
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final second = await registry.create(
      name: 'ops',
      threadId: 'thread-bbbbbbbbbbbb',
      memberIds: const <String>['human-test-device'],
    );

    expect(await registry.archive(channelId: second.channelId), isTrue);
    // An unknown id answers false — never a silent success.
    expect(await registry.archive(channelId: 'channel-000000000000'), isFalse);

    // The default list() is the LIVE list...
    final live = await registry.list();
    expect(live.map((final c) => c.channelId), <String>[first.channelId]);
    // ...includeArchived reads the whole history, still oldest first.
    final all = await registry.list(includeArchived: true);
    expect(
      all.map((final c) => c.channelId),
      <String>[first.channelId, second.channelId],
    );
    expect(all.first.archived, isFalse);
    expect(all.last.archived, isTrue);

    // The archived row keeps every field — nothing is destroyed.
    final archived = await registry.byId(second.channelId);
    expect(archived?.name, 'ops');
    expect(archived?.threadId, 'thread-bbbbbbbbbbbb');
    expect(archived?.createdAt, second.createdAt);
    expect(archived?.archived, isTrue);

    // byThreadId answers for LIVE channels only.
    expect(await registry.byThreadId('thread-bbbbbbbbbbbb'), isNull);
    expect(
      (await registry.byThreadId('thread-aaaaaaaaaaaa'))?.name,
      'design-crit',
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('rename writes the trimmed name and preserves every other field '
      'verbatim; an unknown id is null', () async {
    final temp = await Directory.systemTemp.createTemp('la_channel_reg_');
    addTearDown(() => temp.delete(recursive: true));
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) fail('realm world unsupported on this platform');
    final registry = ChannelRegistry(store: world.store);

    final created = await registry.create(
      name: 'design-crit',
      threadId: 'thread-aaaaaaaaaaaa',
      memberIds: const <String>['human-test-device', 'bot-1'],
    );

    final renamed = await registry.rename(
      channelId: created.channelId,
      name: '  Art Direction  ',
    );
    expect(renamed?.name, 'Art Direction', reason: 'names are trimmed');
    expect(renamed?.channelId, created.channelId);
    expect(renamed?.threadId, created.threadId);
    expect(renamed?.memberIds, created.memberIds);
    expect(renamed?.createdAt, created.createdAt);
    expect(renamed?.archived, isFalse);

    // Durable: the raw row carries the new name and the SAME other
    // fields — the registry is dumb, it rewrites exactly one field.
    final raw = await world.store.read('channels', created.channelId);
    expect(raw?['name'], 'Art Direction');
    expect(raw?['threadId'], 'thread-aaaaaaaaaaaa');
    expect(raw?['memberIds'], <String>['bot-1', 'human-test-device']);
    expect(raw?['createdAt'], created.createdAt);
    expect(raw?['archived'], false);

    // An unknown id answers null — honest absence, no policy here.
    expect(
      await registry.rename(channelId: 'channel-000000000000', name: 'x'),
      isNull,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('archived decodes tolerantly; toRecord and create always write it',
      () async {
    final temp = await Directory.systemTemp.createTemp('la_channel_reg_');
    addTearDown(() => temp.delete(recursive: true));
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) fail('realm world unsupported on this platform');
    final registry = ChannelRegistry(store: world.store);

    // Rows from before the field existed carry no `archived` key; a
    // corrupt non-bool value is not a truth either — both read false.
    await world.store.transact((final tx) {
      tx
        ..put('channels', 'channel-legacy000001', <String, Object?>{
          'channelId': 'channel-legacy000001',
          'name': 'legacy',
          'threadId': 'thread-legacy000001',
          'memberIds': <String>['human-test-device'],
          'createdAt': '2026-01-01T00:00:00.000Z',
        })
        ..put('channels', 'channel-legacy000002', <String, Object?>{
          'channelId': 'channel-legacy000002',
          'name': 'weird',
          'threadId': 'thread-legacy000002',
          'memberIds': <String>['human-test-device'],
          'createdAt': '2026-01-02T00:00:00.000Z',
          'archived': 'yes',
        });
    });
    expect((await registry.byId('channel-legacy000001'))?.archived, isFalse);
    expect((await registry.byId('channel-legacy000002'))?.archived, isFalse);
    // Both stay in the live list — tolerant decode, never tolerant loss.
    expect(await registry.list(), hasLength(2));

    // The const constructor defaults the flag (old callers keep
    // compiling) and toRecord ALWAYS writes it.
    const info = ChannelInfo(
      channelId: 'channel-x',
      name: 'x',
      threadId: 'thread-x',
      memberIds: <String>[],
      createdAt: '2026-01-01T00:00:00.000Z',
    );
    expect(info.archived, isFalse);
    expect(info.toRecord()['archived'], false);

    // A freshly created row lands with the field present.
    final fresh = await registry.create(
      name: 'fresh',
      threadId: 'thread-fresh0000001',
      memberIds: const <String>['human-test-device'],
    );
    final raw = await world.store.read('channels', fresh.channelId);
    expect(raw?['archived'], false);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('rename and archive survive a reopen of the same store', () async {
    final temp = await Directory.systemTemp.createTemp('la_channel_reg_');
    addTearDown(() => temp.delete(recursive: true));
    final first = await RealmWorld.open(rootOverride: temp.path);
    if (first == null) fail('realm world unsupported on this platform');
    final registry = ChannelRegistry(store: first.store);
    final kept = await registry.create(
      name: 'design-crit',
      threadId: 'thread-aaaaaaaaaaaa',
      memberIds: const <String>['human-test-device'],
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final closed = await registry.create(
      name: 'ops',
      threadId: 'thread-bbbbbbbbbbbb',
      memberIds: const <String>['human-test-device'],
    );
    await registry.rename(channelId: kept.channelId, name: 'art');
    await registry.archive(channelId: closed.channelId);

    // A fresh world over the SAME directory (a restart, not a singleton
    // reuse) sees exactly the landed state.
    final second = await RealmWorld.open(rootOverride: temp.path);
    if (second == null) fail('realm world unsupported on this platform');
    final reopened = ChannelRegistry(store: second.store);
    final live = await reopened.list();
    expect(live, hasLength(1));
    expect(live.single.channelId, kept.channelId);
    expect(live.single.name, 'art');
    final all = await reopened.list(includeArchived: true);
    expect(all, hasLength(2));
    expect((await reopened.byId(closed.channelId))?.archived, isTrue);
    expect((await reopened.byId(closed.channelId))?.name, 'ops');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
