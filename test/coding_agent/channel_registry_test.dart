import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

void main() {
  // ADR 0024 — the `channels` collection: named threads registered in
  // the realm's ONE control store, existing before anyone speaks.
  //
  // NOTE on skipped service-level tests: RealmChatService cannot run
  // hermetically today — `ensureReady()` reaches the production realm
  // store singleton (`RealmWorld.open()` with no override) and
  // `StorageBackendsNotifier.instance`, so DM reuse, channel-name
  // refusal, and `beatPreviews` are covered by this registry suite only
  // on the durable half. A hermetic service seam (root override +
  // roster injection) is the follow-up that unlocks them.
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
}
