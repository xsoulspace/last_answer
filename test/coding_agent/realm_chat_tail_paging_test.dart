// Plane convergence (2026-11-07) — the endless-room read laws over the
// journal plane: tail-first paging (an endless thread lives at its
// tail, never frozen at its head), position-preserving backward pages,
// read receipts as the unread spine, and the read-cost fixture that
// stands in for load testing (a 10k-beat room folds and pages without
// re-materializing).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

void main() {
  group('the tail-paging law', () {
    test(
      'a 300-beat room opens at its tail, pages backward, and keeps the '
      'loaded tail stable',
      () async {
        final temp = await Directory.systemTemp.createTemp('la_tail_page_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        final service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        final human = world.authorityFor(service.humanActorId!);
        final conversation = world.conversation();
        final opened = await conversation.open(
          actor: human,
          topic: 'endless room',
          // Realm-sealed like every LA room: visible to every actor.
          realmSealed: true,
        );
        final threadId = opened['threadId']! as String;
        for (var i = 1; i <= 300; i++) {
          await conversation.say(
            actor: human,
            threadId: threadId,
            text: 'beat $i',
          );
        }

        service.selectThread(threadId);
        await _waitFor(() => service.beats.isNotEmpty);
        // The first view is the NEWEST page — the head-freeze bug is
        // the thing this law exists to never regress into.
        expect(service.beats, hasLength(RealmChatService.tailPageSize));
        expect(service.beats.last['text'], 'beat 300');
        expect(
          service.beats.first['text'],
          'beat ${301 - RealmChatService.tailPageSize}',
        );
        expect(service.hasOlderBeats, isTrue);

        // Backward page: prepend-only — the loaded tail never moves,
        // so the surface keeps its scroll position.
        final tailBefore = service.beats.last['text'];
        await service.loadOlderBeats();
        expect(service.beats, hasLength(2 * RealmChatService.tailPageSize));
        expect(service.beats.last['text'], tailBefore);
        expect(service.beats.first['text'], isNot('beat 1'));

        await service.loadOlderBeats();
        expect(service.beats, hasLength(300));
        expect(service.beats.first['text'], 'beat 1');
        expect(service.hasOlderBeats, isFalse);
        // A third page on an exhausted history is a quiet no-op.
        await service.loadOlderBeats();
        expect(service.beats, hasLength(300));

        // Reading IS the receipt (ADR 0124): the human's cursor sits at
        // the newest beat, so the room counts as seen.
        final inbox = await conversation.inbox(actor: human);
        final unread =
            (inbox['unreadByThread']! as Map).cast<String, int>()[threadId];
        expect(unread ?? 0, 0);
      },
      timeout: const Timeout(Duration(minutes: 4)),
    );
  });

  group('the read-cost fixture (stands in for load testing)', () {
    test(
      'a 10k-beat room folds once and pages from memory — no '
      're-materialization per read',
      () async {
        final temp = await Directory.systemTemp.createTemp('la_read_cost_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        final human = world.authorityFor('human-bench');
        final conversation = world.conversation();
        final opened = await conversation.open(
          actor: human,
          topic: 'the long room',
          realmSealed: true,
        );
        final threadId = opened['threadId']! as String;
        // Seed 10k beats as batched journal transactions — the exact
        // row shape `say` writes (the journal is the authority; the
        // fixture's job is the READ cost, not the write path).
        for (var batch = 0; batch < 100; batch++) {
          await world.store.transact((tx) {
            for (var j = 1; j <= 100; j++) {
              final i = batch * 100 + j;
              tx.put('thread_beats', '$threadId#$i', <String, Object?>{
                'threadId': threadId,
                'beat': i,
                'author': 'human-bench',
                'conversationId': 'lastanswer',
                'text': 'beat $i',
                'at': '2026-11-07T00:00:${(i % 60).toString().padLeft(2, '0')}.000Z',
                'addressedTo': <String>[],
              });
            }
            final row = tx.get('threads', threadId);
            if (row != null) {
              tx.put('threads', threadId, <String, Object?>{
                ...row,
                'lastBeat': (batch + 1) * 100,
              });
            }
            return null;
          });
        }

        final projection = world.projection;
        final fold = Stopwatch()..start();
        final all = await projection.beatsOfThread(threadId);
        fold.stop();
        expect(all, hasLength(10000));
        // The cold fold reads the whole journal tail once. Generous
        // bound: this is a regression tripwire, not a benchmark.
        expect(
          fold.elapsed,
          lessThan(const Duration(seconds: 20)),
          reason: 'cold fold took ${fold.elapsed}',
        );

        // Warm tail pages are memory slices: three consecutive reads
        // cost milliseconds, never a re-scan.
        final warm = Stopwatch()..start();
        for (var page = 0; page < 3; page++) {
          final slice = all.sublist(all.length - 128 * (page + 1));
          expect(slice.last['text'], 'beat 10000');
        }
        final refresh = await projection.beatsOfThread(threadId);
        warm.stop();
        expect(refresh, hasLength(10000));
        expect(
          warm.elapsed,
          lessThan(const Duration(seconds: 2)),
          reason: 'warm reads took ${warm.elapsed}',
        );
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );
  });
}

Future<void> _waitFor(
  final bool Function() condition, {
  final String because = 'condition',
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timed out waiting for: $because');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
