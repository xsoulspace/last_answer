import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_creation.dart';
import 'package:lastanswer/coding_agent/realm_chat/kernel_conversation.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

Future<Directory> _hermeticHome() async {
  final temp = await Directory.systemTemp.createTemp('la_realm_chat_');
  return temp;
}

void main() {
  // ADR 0023 — the world chat substrate over a hermetic store: actor
  // identity creation (the shared human/actor mechanism) and the
  // durable `thread` verbs the chat surface projects.
  test(
    'create actor identity, open thread, say, read, close',
    () async {
      final temp = await Directory.systemTemp.createTemp('la_realm_chat_');
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      if (world == null) fail('realm world unsupported on this platform');

      final roster = ActorRoster(replicaId: 'test-device');
      final bot = await createActorIdentity(
        roster: roster,
        world: world,
        displayName: 'Toby Researcher',
        kind: ActorKind.model,
        brainRef: 'local:qwen',
        role: 'research assistant',
      );
      expect(bot.actorId, startsWith('toby-researcher'));
      expect(roster.get(bot.actorId)?.brainRef, 'local:qwen');

      final human = world.authorityFor('human-test-device');
      await world.registerActor(human.actor);
      final conversation = world.conversation();

      final opened = await conversation.open(
        actor: human,
        topic: 'First conversation',
        participants: [bot.actorId],
      );
      final threadId = opened['threadId']! as String;

      final said = await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'Hello, Toby — introduce yourself in one sentence.',
        addressedTo: [bot.actorId],
      );
      expect(said['ok'], true);
      expect(said['beat'], 1);

      final read = await conversation.read(
        actor: human,
        threadId: threadId,
      );
      expect(read['ok'], true);
      final beats = (read['beats']! as List).cast<Map>();
      expect(beats, hasLength(1));
      expect(beats.single['author'], human.actor);
      expect(beats.single['text'], contains('introduce yourself'));
      expect(
        (read['participants']! as List).cast<String>(),
        containsAll([human.actor, bot.actorId]),
      );

      // The bot's own authority sees the thread (project-sealed to the
      // same project) and can wait on beats addressed to it.
      final botSession = await conversation.wait(
        actor: world.authorityFor(bot.actorId),
        timeoutMs: 1000,
      );
      expect(botSession['timedOut'], false);
      final botBeats = (botSession['beats']! as List).cast<Map>();
      expect(botBeats, hasLength(1));
      expect(botBeats.single['beat'], 1);

      final closed = await conversation.close(actor: human, threadId: threadId);
      expect(closed['ok'], true);
      // The verb library THROWS refusals (the seat serves them as bounce
      // maps); a closed thread refuses says with the named code.
      await expectLater(
        conversation.say(
          actor: human,
          threadId: threadId,
          text: 'after close',
        ),
        throwsA(
          isA<DurableRealmRefusal>().having(
            (refusal) => refusal.code,
            'code',
            'thread_closed',
          ),
        ),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('overlong beat text lands VERBATIM (ADR 0138 D5 write law)', () async {
    final temp = await Directory.systemTemp.createTemp('la_realm_chat_');
    addTearDown(() => temp.delete(recursive: true));
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) fail('realm world unsupported on this platform');
    final human = world.authorityFor('human-test-device');
    final conversation = world.conversation();
    final opened = await conversation.open(actor: human, topic: 'bounds');
    // The write path is unconditional: any size lands verbatim — size
    // is a READ problem (budgeted views + zoom routes), never a write
    // clamp. The kernel plane's 8192-byte refusal is retired with it.
    final text = 'x' * 9000;
    final said = await conversation.say(
      actor: human,
      threadId: opened['threadId']! as String,
      text: text,
    );
    expect(said['beat'], 1);
    final read = await conversation.read(
      actor: human,
      threadId: opened['threadId']! as String,
    );
    final beats = (read['beats']! as List).cast<Map>();
    expect(beats.single['text'], text);
  });

  test(
    'journal threads: exact map shapes, project authorization, close',
    () async {
      final temp = await _hermeticHome();
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      if (world == null) fail('realm world unsupported on this platform');
      final human = world.authorityFor('human-test-device');
      final outsider = world.authorityFor('human-outsider');
      final conversation = world.conversation();

      final opened = await conversation.open(
        actor: human,
        topic: 'Shapes',
        participants: ['human-guest'],
      );
      expect(opened['ok'], true);
      final threadId = opened['threadId']! as String;
      expect(threadId, startsWith('thread-'));
      expect(opened['topic'], 'Shapes');
      expect(
        (opened['participants']! as List).cast<String>(),
        containsAll(['human-test-device', 'human-guest']),
      );

      final said = await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'first beat',
        addressedTo: ['human-guest'],
      );
      expect(said['ok'], true);
      expect(said['threadId'], threadId);
      expect(said['beat'], 1);
      expect(said['addressedTo'], ['human-guest']);

      final read = await conversation.read(
        actor: human,
        threadId: threadId,
      );
      expect(read['ok'], true);
      expect(read['threadId'], threadId);
      expect(read['topic'], 'Shapes');
      expect(read['closed'], false);
      expect(read['lastBeat'], 1);
      expect(read['hasMore'], false);
      final beats = (read['beats']! as List).cast<Map>();
      expect(beats, hasLength(1));
      final beat = beats.single;
      // Journal `read` beats omit the per-beat threadId (implicit in
      // the request — the harness verb shape); the raw projection rows
      // the UI and the dispatcher drain consume carry it.
      expect(beat.containsKey('threadId'), isFalse);
      expect(beat['beat'], 1);
      expect(beat['author'], 'human-test-device');
      expect(beat['text'], 'first beat');
      expect(beat['at'], isA<String>());
      expect(DateTime.tryParse(beat['at']! as String), isNotNull);
      expect(beat['addressedTo'], ['human-guest']);
      // Saying auto-joins — the author is a participant afterwards.
      expect(
        (read['participants']! as List).cast<String>(),
        contains('human-test-device'),
      );

      // The journal list carries the ROW fields; the preview triple is
      // a read-model concern (the service computes it from the folded
      // beats — plane convergence 2026-11-07).
      final listing = await conversation.list(actor: human);
      expect(listing['ok'], true);
      expect(listing['total'], 1);
      final threads = (listing['threads']! as List).cast<Map>();
      expect(threads, hasLength(1));
      final thread = threads.single;
      expect(thread['threadId'], threadId);
      expect(thread['topic'], 'Shapes');
      expect(thread['createdBy'], 'human-test-device');
      expect(thread['createdAt'], isA<String>());
      expect(thread['closed'], false);
      expect(thread['lastBeat'], 1);
      expect(
        (thread['participants']! as List).cast<String>(),
        containsAll(['human-test-device', 'human-guest']),
      );

      // Authorization is PROJECT law on the journal plane (ADR 0121):
      // an authority from ANOTHER project sees nothing on every verb.
      const foreign = ProfileActorAuthority(
        actor: 'human-foreign',
        conversationId: 'lastanswer',
        actorReference: 'persistent-entity:realm-actor:human-foreign',
        projectId: '/somewhere/else',
        projectRoot: '/somewhere/else',
      );
      for (final verb in [
        () => conversation.read(actor: foreign, threadId: threadId),
        () => conversation.say(
          actor: foreign,
          threadId: threadId,
          text: 'intrusion',
        ),
        () => conversation.close(actor: foreign, threadId: threadId),
        () => conversation.wait(
          actor: foreign,
          threadId: threadId,
          timeoutMs: 10,
        ),
      ]) {
        await expectLater(
          verb(),
          throwsA(
            isA<DurableRealmRefusal>().having(
              (refusal) => refusal.code,
              'code',
              'thread_not_visible',
            ),
          ),
        );
      }

      // A same-project NON-participant is visible (conversation is
      // actor-equal, never membership-gated): reading works, closing
      // stays participant-gated, and saying AUTO-JOINS.
      final beforeJoin = await conversation.read(
        actor: outsider,
        threadId: threadId,
      );
      expect(beforeJoin['ok'], true);
      await expectLater(
        conversation.close(actor: outsider, threadId: threadId),
        throwsA(
          isA<DurableRealmRefusal>().having(
            (refusal) => refusal.code,
            'code',
            'thread_close_not_participant',
          ),
        ),
      );
      await conversation.say(
        actor: outsider,
        threadId: threadId,
        text: 'joining by acting',
      );
      final afterJoin = await conversation.read(
        actor: human,
        threadId: threadId,
      );
      expect(
        (afterJoin['participants']! as List).cast<String>(),
        contains('human-outsider'),
      );

      final closed = await conversation.close(
        actor: human,
        threadId: threadId,
      );
      expect(closed['ok'], true);
      expect(closed['threadId'], threadId);
      expect(closed['closed'], true);
      await expectLater(
        conversation.say(
          actor: human,
          threadId: threadId,
          text: 'after close',
        ),
        throwsA(
          isA<DurableRealmRefusal>().having(
            (refusal) => refusal.code,
            'code',
            'thread_closed',
          ),
        ),
      );
      // The closed flag reaches the list projection.
      final afterClose = await conversation.list(actor: human);
      final closedThread = (afterClose['threads']! as List).cast<Map>().single;
      expect(closedThread['closed'], true);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'wait parks on replica changes and wakes on a beat from another '
    'authority; times out with the journal shape',
    () async {
      final temp = await _hermeticHome();
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      if (world == null) fail('realm world unsupported on this platform');
      final human = world.authorityFor('human-test-device');
      final bot = world.authorityFor('bot-9f');
      final conversation = world.conversation();
      final opened = await conversation.open(
        actor: human,
        topic: 'door knock',
        participants: ['bot-9f'],
      );
      final threadId = opened['threadId']! as String;

      // The listener parks BEFORE the say: waking proves the ride is
      // notification-driven, not a poll that re-scans until timeout.
      final parked = conversation.wait(
        actor: bot,
        timeoutMs: 15000,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'knock knock',
        addressedTo: ['bot-9f'],
      );
      final wakeWatch = Stopwatch()..start();
      final woke = await parked;
      expect(woke['timedOut'], false);
      expect(wakeWatch.elapsed, lessThan(const Duration(seconds: 5)));
      final wokeBeats = (woke['beats']! as List).cast<Map>();
      expect(wokeBeats, hasLength(1));
      expect(wokeBeats.single['threadId'], threadId);
      expect(wokeBeats.single['beat'], 1);
      expect(wokeBeats.single['author'], 'human-test-device');
      expect(woke['lastBeat'], isNull);
      expect(woke['lastBeatByThread'], <String, int>{threadId: 1});

      // Cursor semantics: passing the cursor back yields nothing new,
      // and a beat NOT addressed to me neither wakes me nor advances
      // my cursor past it.
      await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'to nobody in particular',
      );
      final quiet = await conversation.wait(
        actor: bot,
        afterByThread: {threadId: 1},
        timeoutMs: 250,
      );
      expect(quiet['timedOut'], true);
      expect(quiet['beats']! as List, isEmpty);
      expect(quiet['lastBeatByThread'], <String, int>{threadId: 1});

      // A non-addressing filter keeps the cursor while an addressed
      // beat beyond it arrives.
      await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'for you',
        addressedTo: ['bot-9f'],
      );
      final knock = await conversation.wait(
        actor: bot,
        afterByThread: {threadId: 1},
        timeoutMs: 5000,
      );
      expect(knock['timedOut'], false);
      final knockBeats = (knock['beats']! as List).cast<Map>();
      expect(knockBeats, hasLength(1));
      expect(knockBeats.single['beat'], 3);
      expect(knock['lastBeatByThread'], <String, int>{threadId: 3});
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'restart persistence: a reopened world lists and reads the beats',
    () async {
      final temp = await _hermeticHome();
      addTearDown(() => temp.delete(recursive: true));
      final first = await RealmWorld.open(rootOverride: temp.path);
      if (first == null) fail('realm world unsupported on this platform');
      final human = first.authorityFor('human-test-device');
      const threadTopic = 'survives restarts';
      final opened = await first.conversation().open(
        actor: human,
        topic: threadTopic,
        participants: ['bot-9f'],
      );
      final threadId = opened['threadId']! as String;
      await first.conversation().say(
        actor: human,
        threadId: threadId,
        text: 'written before the restart',
        addressedTo: ['bot-9f'],
      );

      // A fresh world over the SAME directory (a restart, not a
      // singleton reuse) sees the thread and its beats. (The preview
      // triple is a service read-model concern, not a journal row
      // field — the row carries the `lastBeat` counter.)
      final second = await RealmWorld.open(rootOverride: temp.path);
      final listing = await second!.conversation().list(actor: human);
      final threads = (listing['threads']! as List).cast<Map>();
      expect(threads, hasLength(1));
      expect(threads.single['threadId'], threadId);
      expect(threads.single['lastBeat'], 1);
      final read = await second.conversation().read(
        actor: human,
        threadId: threadId,
      );
      final beats = (read['beats']! as List).cast<Map>();
      expect(beats, hasLength(1));
      expect(beats.single['text'], 'written before the restart');
      // And the thread keeps accepting beats after the reopen.
      final said = await second.conversation().say(
        actor: human,
        threadId: threadId,
        text: 'written after the restart',
      );
      expect(said['beat'], 2);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'journal-native threads are already home: no kernel seeding, direct '
    'reads, numbering continues, reopen is idempotent',
    () async {
      final temp = await _hermeticHome();
      addTearDown(() => temp.delete(recursive: true));
      const scopeRoot = 'world';
      final store = RealmControlStore(
        Directory('${temp.path}/$scopeRoot/coordination'),
      );
      // A legacy journal thread with two beats, exactly the shape
      // DurableConversation wrote (projectRoot = the LA project scope).
      await store.transact((tx) {
        tx
          ..put('threads', 'thread-legacy0001', <String, Object?>{
            'threadId': 'thread-legacy0001',
            'projectId': '${temp.path}/$scopeRoot',
            'projectRoot': '${temp.path}/$scopeRoot',
            'topic': 'legacy thread',
            'createdBy': 'human-test-device',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'closed': false,
            'participants': ['human-test-device', 'bot-9f'],
            'lastBeat': 2,
          })
          ..put('thread_beats', 'thread-legacy0001#1', <String, Object?>{
            'threadId': 'thread-legacy0001',
            'beat': 1,
            'author': 'human-test-device',
            'docId': 'lastanswer',
            'text': 'legacy first',
            'at': '2026-01-01T00:00:01.000Z',
            'addressedTo': <String>['bot-9f'],
          })
          ..put('thread_beats', 'thread-legacy0001#2', <String, Object?>{
            'threadId': 'thread-legacy0001',
            'beat': 2,
            'author': 'bot-9f',
            'docId': 'realm-actor',
            'text': 'legacy second',
            'at': '2026-01-01T00:00:02.000Z',
            'addressedTo': <String>[],
          });
      });

      final world = await RealmWorld.open(rootOverride: temp.path);
      if (world == null) fail('realm world unsupported on this platform');
      final human = world.authorityFor('human-test-device');
      final conversation = world.conversation();

      // Plane convergence (2026-11-07): the journal IS the beat plane
      // (ADR 0138 D1) — these records are not "legacy" anymore, they
      // are home. Nothing seeds a kernel doc; the thread lists and
      // reads directly off the fold.
      final listing = await conversation.list(actor: human);
      final threads = (listing['threads']! as List).cast<Map>();
      expect(threads, hasLength(1));
      expect(threads.single['topic'], 'legacy thread');
      expect(threads.single['lastBeat'], 2);
      final read = await conversation.read(
        actor: human,
        threadId: 'thread-legacy0001',
      );
      final beats = (read['beats']! as List).cast<Map>();
      expect(beats, hasLength(2));
      expect(beats[0]['beat'], 1);
      expect(beats[0]['text'], 'legacy first');
      expect(beats[0]['addressedTo'], ['bot-9f']);
      expect(beats[1]['beat'], 2);
      expect(beats[1]['author'], 'bot-9f');

      // New beats continue the numbering on the same plane.
      final said = await conversation.say(
        actor: human,
        threadId: 'thread-legacy0001',
        text: 'after convergence',
      );
      expect(said['beat'], 3);

      // Reopening is idempotent — and the kernel archive stays empty:
      // no replica file is ever seeded for a journal-native thread.
      final again = await RealmWorld.open(rootOverride: temp.path);
      final reread = await again!.conversation().read(
        actor: human,
        threadId: 'thread-legacy0001',
      );
      expect(reread['beats']! as List, hasLength(3));
      expect(
        File('${temp.path}/threads/thread-legacy0001.json').existsSync(),
        isFalse,
      );
      final journalRow = await store.read('threads', 'thread-legacy0001');
      expect(journalRow, isNotNull);
      expect(journalRow!['lastBeat'], 3);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'sessionFor: the drop-in actor session facade (authority, register, '
    'say) over the kernel conversation',
    () async {
      final temp = await _hermeticHome();
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      if (world == null) fail('realm world unsupported on this platform');
      final human = world.authorityFor('human-test-device');
      final conversation = world.conversation();
      final opened = await conversation.open(
        actor: human,
        topic: 'facade',
        participants: ['bot-9f'],
      );
      final threadId = opened['threadId']! as String;

      final session = world.sessionFor('bot-9f');
      expect(session.authority.actor, 'bot-9f');
      expect(session.authority.projectRoot, world.root);

      await session.register(serves: const ['conversation']);
      final record = await world.store.read('realm_actors', 'bot-9f');
      expect(record, isNotNull);
      expect(
        (record!['serves']! as List).cast<String>(),
        contains('conversation'),
      );

      final beat = await session.say(threadId, 'from the facade',
          addressedTo: const ['human-test-device']);
      expect(beat, 1);
      final read = await conversation.read(
        actor: human,
        threadId: threadId,
      );
      final beats = (read['beats']! as List).cast<Map>();
      expect(beats.single['author'], 'bot-9f');
      expect(beats.single['text'], 'from the facade');
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'healJournalHumanIdentity substitutes per-launch human ids with the '
    'stable one in the journal rows, so the human keeps its own history',
    () async {
      final temp = await _hermeticHome();
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      if (world == null) fail('realm world unsupported on this platform');
      final staleHuman = world.authorityFor('human-1793337269742932');
      final conversation = world.conversation();
      final opened = await conversation.open(
        actor: staleHuman,
        topic: 'legacy lab',
        participants: ['bot-heal'],
      );
      final threadId = opened['threadId']! as String;

      // Journal visibility is PROJECT law (ADR 0121), not participant
      // law: the stable human — the same project authority — sees the
      // room even before the heal. What the stale id breaks is
      // membership and addressing: the participants still name a dead
      // per-launch id.
      final stableHuman = world.authorityFor('human-1793338232211325');
      final before = await conversation.read(
        actor: stableHuman,
        threadId: threadId,
      );
      expect(
        (before['participants']! as List).cast<String>(),
        contains('human-1793337269742932'),
      );

      final healed = await world.healJournalHumanIdentity(
        stableActorId: 'human-1793338232211325',
      );
      expect(healed, 1);

      // Healed: the row's participant register carries the substitution.
      final read = await conversation.read(
        actor: stableHuman,
        threadId: threadId,
      );
      final healedParticipants = (read['participants']! as List)
          .cast<String>();
      expect(healedParticipants, contains('human-1793338232211325'));
      expect(
        healedParticipants,
        isNot(contains('human-1793337269742932')),
      );

      // Idempotent: a second heal is a no-op.
      final again = await world.healJournalHumanIdentity(
        stableActorId: 'human-1793338232211325',
      );
      expect(again, 0);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'hermetic worlds persist threads in the journal under '
    '<override>/world/coordination — no kernel replica files',
    () async {
      final temp = await _hermeticHome();
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      if (world == null) fail('realm world unsupported on this platform');
      final human = world.authorityFor('human-test-device');
      final conversation = world.conversation();
      final opened = await conversation.open(actor: human, topic: 'homing');
      final threadId = opened['threadId']! as String;
      await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'written into the journal',
      );

      // The journal is the beat plane (ADR 0138 D1): the durable home
      // is the coordination store's append log, and a new thread never
      // materializes a kernel replica file.
      expect(
        File(
          '${temp.path}/world/coordination/$realmControlJournalFileName',
        ).existsSync(),
        isTrue,
      );
      expect(
        File('${temp.path}/threads/$threadId.json').existsSync(),
        isFalse,
      );

      // A reopen over the same override reads the beats back.
      final second = await RealmWorld.open(rootOverride: temp.path);
      final read = await second!.conversation().read(
        actor: human,
        threadId: threadId,
      );
      final beats = (read['beats']! as List).cast<Map>();
      expect(beats, hasLength(1));
      expect(beats.single['text'], 'written into the journal');
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'kernel archive export: indexed threads AND file-only orphans land '
    'in the journal realm-sealed, idempotently',
    () async {
      final temp = await _hermeticHome();
      addTearDown(() => temp.delete(recursive: true));
      final world = await RealmWorld.open(rootOverride: temp.path);
      if (world == null) fail('realm world unsupported on this platform');
      final human = world.authorityFor('human-test-device');

      // An archived thread through the kernel verbs (the retired plane
      // still writes its archive), plus a FILE-ONLY orphan: a replica
      // whose index record never committed (the crash-window case the
      // doc-as-truth law covers).
      final archived = await world.kernel.open(
        actor: human,
        topic: 'archive room',
        participants: ['bot-9f'],
      );
      final archivedId = archived['threadId']! as String;
      await world.kernel.say(
        actor: human,
        threadId: archivedId,
        text: 'archived beat',
        addressedTo: ['bot-9f'],
      );
      final orphan = await world.kernel.open(actor: human, topic: 'orphan');
      final orphanId = orphan['threadId']! as String;
      await world.kernel.say(
        actor: human,
        threadId: orphanId,
        text: 'orphan beat',
      );
      await world.store.transact((tx) {
        tx.remove('thread_index', orphanId);
        return null;
      });

      // The export carries BOTH into the journal — realm-sealed, so
      // every actor of the realm sees the rooms.
      final exported = await world.exportKernelThreads();
      expect(exported, 2);
      for (final id in [archivedId, orphanId]) {
        final row = await world.store.read('threads', id);
        expect(row, isNotNull, reason: 'exported: $id');
        expect(row!['projectId'], isNull, reason: 'realm-sealed: $id');
        expect(row['lastBeat'], 1);
        final read = await world.conversation().read(
          actor: human,
          threadId: id,
        );
        final beats = (read['beats']! as List).cast<Map>();
        expect(beats.single['author'], 'human-test-device');
      }
      final archivedRow = await world.store.read('threads', archivedId);
      expect(
        (archivedRow!['participants']! as List).cast<String>(),
        containsAll(['human-test-device', 'bot-9f']),
      );

      // Idempotent: a second export skips both (the journal already
      // carries everything the archive counted).
      expect(await world.exportKernelThreads(), 0);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'realm home adoption: legacy in-scope replicas are copied into '
    '<deviceHome>/.xsoulspace/worlds/<realm id>/project/lastanswer/threads',
    () async {
      final temp = await _hermeticHome();
      final deviceHome = await _hermeticHome();
      addTearDown(() async {
        RealmWorld.debugDeviceHome = null;
        await temp.delete(recursive: true);
        await deviceHome.delete(recursive: true);
      });
      RealmWorld.debugDeviceHome = deviceHome.path;

      // The realm-shaped homes resolve under the pinned device home.
      final storeDir = Directory(RealmWorld.realmControlStorePath());
      await storeDir.create(recursive: true);
      final store = RealmControlStore(storeDir);
      final threadsHome = RealmWorld.realmThreadsHome();
      expect(
        threadsHome,
        '${deviceHome.path}/.xsoulspace/worlds/local/'
        'project/lastanswer/threads',
      );

      // Legacy layout: one live thread under the in-scope home
      // (<root>/threads) — exactly where the old code persisted it.
      final scopeRoot = '${temp.path}/world';
      ProfileActorAuthority humanActor() => ProfileActorAuthority(
        actor: 'human-test-device',
        conversationId: 'lastanswer',
        actorReference: 'persistent-entity:realm-actor:human-test-device',
        projectId: scopeRoot,
        projectRoot: scopeRoot,
      );
      final legacy = await KernelConversation.load(
        store: store,
        root: scopeRoot,
        threadsHome: '$scopeRoot/threads',
      );
      final opened = await legacy.open(
        actor: humanActor(),
        topic: 'survives the move',
      );
      final threadId = opened['threadId']! as String;
      await legacy.say(
        actor: humanActor(),
        threadId: threadId,
        text: 'written in the old home',
      );
      await legacy.dispose();

      // Realm-shaped reopen: the replica is ADOPTED into the realm
      // project area — copied, never moved.
      final adopted = await KernelConversation.load(
        store: store,
        root: scopeRoot,
        threadsHome: threadsHome,
      );
      expect(File('$threadsHome/$threadId.json').existsSync(), isTrue);
      expect(File('$scopeRoot/threads/$threadId.json').existsSync(), isTrue);
      final read = await adopted.read(actor: humanActor(), threadId: threadId);
      final beats = (read['beats']! as List).cast<Map>();
      expect(beats, hasLength(1));
      expect(beats.single['text'], 'written in the old home');

      // Idempotent: a reopen adopts nothing anew (the old copy is never
      // re-copied over the live one) and the thread keeps working from
      // its new home.
      final again = await KernelConversation.load(
        store: store,
        root: scopeRoot,
        threadsHome: threadsHome,
      );
      final newHomeFiles = Directory(
        threadsHome,
      ).listSync().whereType<File>().toList();
      expect(newHomeFiles, hasLength(1));
      final said = await again.say(
        actor: humanActor(),
        threadId: threadId,
        text: 'written in the new home',
      );
      expect(said['beat'], 2);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
