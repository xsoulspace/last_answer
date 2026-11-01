// WAVE 4W — `RealmChatService.beatsFor`: the additive per-thread beats
// read the miniwindow peek polls. Over a hermetic world (real store IO
// — the `RealmWorld.open(rootOverride:)` pattern): oldest→newest
// ordering, the bounded limit, named empty reads (unknown thread,
// not-ready service) and the never-notify contract that keeps the
// peek's poll loop quiet.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

void main() {
  group('RealmChatService.beatsFor', () {
    test(
      'reads one thread oldest→newest; unknown reads empty; never notifies',
      () async {
        final temp = await Directory.systemTemp.createTemp('la_beats_for_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        final service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        final toby = (await service.createActor(
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
          role: 'researcher',
        ))!;
        await service.startThread(
          topic: 'Beats peek',
          participants: <String>[toby.actorId],
        );
        final threadId = service.activeThreadId!;
        await service.say('first');
        await service.say('second');
        await service.say('third');

        final beats = await service.beatsFor(threadId);
        expect(
          beats.map((beat) => beat['text']).toList(),
          ['first', 'second', 'third'],
          reason: 'oldest first, newest last — the peek renders in order',
        );
        expect(
          beats.last['beat']! as int,
          greaterThan(beats.first['beat']! as int),
        );
        // Every beat carries the fields the peek renders.
        for (final beat in beats) {
          expect(beat['author'], service.humanActorId);
          expect(beat['at'], isA<String>());
        }

        // An unknown thread reads as an empty list — never a throw.
        expect(await service.beatsFor('no-such-thread'), isEmpty);

        // The read never notifies: a notifying read would loop its
        // pollers (the peek listens to the service AND polls it).
        var notifications = 0;
        void listener() => notifications++;
        service.addListener(listener);
        await service.beatsFor(threadId);
        service.removeListener(listener);
        expect(notifications, 0);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'the read is bounded to beatsForLimit beats',
      () async {
        final temp = await Directory.systemTemp.createTemp('la_beats_for_');
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
          topic: 'bounded',
          participants: const <String>[],
        );
        final threadId = opened['threadId']! as String;
        for (var i = 1; i <= RealmChatService.beatsForLimit + 5; i++) {
          await conversation.say(
            actor: human,
            threadId: threadId,
            text: 'beat $i',
          );
        }

        final beats = await service.beatsFor(threadId);
        expect(beats, hasLength(RealmChatService.beatsForLimit));
        expect(beats.last['beat']! as int, RealmChatService.beatsForLimit);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test('a not-ready service reads empty without throwing', () async {
      final service = RealmChatService(debugStartBotDispatcher: false);
      addTearDown(service.dispose);
      expect(service.isReady, isFalse);
      expect(await service.beatsFor('anything'), isEmpty);
    });
  });
}
