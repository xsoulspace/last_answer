import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

/// A scripted brain: every generate() parks a completer the test settles
/// (with a reply text or an error), so the narration phases are
/// observable mid-flight — no engine, no isolate.
final class _ScriptedBrain implements ActorBrain {
  final _pending = <Completer<String>>[];

  bool get hasPending => _pending.isNotEmpty;

  /// Settles the oldest parked generate with [text].
  void reply(final String text) => _pending.removeAt(0).complete(text);

  /// Settles the oldest parked generate with a failure.
  void failGeneration() => _pending.removeAt(0).completeError(
    const BrainGenerationFailed('boom', 'no engine in the test'),
  );

  @override
  Future<String> generate({
    required final String system,
    required final List<BrainTurn> turns,
  }) {
    final done = Completer<String>();
    _pending.add(done);
    return done.future;
  }

  @override
  String get label => 'scripted';

  @override
  String get ref => 'scripted:brain';
}

/// One narration harness: hermetic world, one bot actor whose brain is
/// scripted, the REAL dispatcher armed. The thread is opened BEFORE the
/// dispatcher seeds its cursor, so a beat said after the harness returns
/// is fresh for the wake loop (a beat inside the seed would be skipped
/// as history).
///
/// Every narration change is RECORDED through the host's `onChanged` —
/// the transient phases (thinking between registration and the
/// transcript read) live for milliseconds, too short to poll for; the
/// record misses nothing.
typedef _Harness = ({
  RealmWorld world,
  RealmBotHost host,
  _ScriptedBrain brain,
  ActorProfile actor,
  String threadId,
  List<BotNarration> seen,
});

Future<_Harness> _harness() async {
  final temp = await Directory.systemTemp.createTemp('la_bot_narration_');
  addTearDown(() => temp.delete(recursive: true));
  final world = await RealmWorld.open(rootOverride: temp.path);
  if (world == null) fail('realm world unsupported on this platform');
  const actor = ActorProfile(
    actorId: 'bot-narrate',
    displayName: 'Narrator',
    brainRef: 'scripted:brain',
  );
  final brain = _ScriptedBrain();
  final seen = <BotNarration>[];
  late final RealmBotHost host;
  host = RealmBotHost(
    world: world,
    humanActorId: 'human-tester',
    resolveOpenRouterApiKey: () => null,
    debugBrainOverride: (final _) => brain,
    onChanged: () {
      final narration = host.narrations[actor.actorId];
      if (narration == null) return;
      final last = seen.isEmpty ? null : seen.last;
      if (last != null &&
          last.state == narration.state &&
          last.detail == narration.detail) {
        return;
      }
      seen.add(narration);
    },
  );
  addTearDown(host.stopAll);
  final threadId = (await world.conversation().open(
    actor: world.authorityFor('human-tester'),
    topic: 'lab',
    participants: [actor.actorId],
  ))['threadId']! as String;
  host.syncBots([actor]);
  await _waitFor(
    () => host.debugCursor.containsKey(threadId),
    because: 'dispatcher cursor seeded',
  );
  return (
    world: world,
    host: host,
    brain: brain,
    actor: actor,
    threadId: threadId,
    seen: seen,
  );
}

Future<void> _waitFor(
  final bool Function() condition, {
  final String because = 'condition',
  final String Function()? snapshot,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timed out waiting for: $because\n${snapshot?.call() ?? ''}');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  // Wave 3A — actor activity narration: the reply cycle is VISIBLE.
  // One line per actor, driven through the REAL dispatcher over a
  // hermetic world, with only the brain scripted.
  test(
    'narration rides the reply cycle: idle → thinking → generating → '
    'listening, with the string statuses kept',
    () async {
      final (:world, :host, :brain, :actor, :threadId, :seen) =
          await _harness();
      final human = world.authorityFor('human-tester');
      final conversation = world.conversation();

      // Idle before any work: the worker exists, nothing is running.
      expect(host.narrations[actor.actorId]?.state, BotNarrationState.idle);
      expect(host.statuses[actor.actorId], 'idle');

      await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'What should we ship first?',
        addressedTo: [actor.actorId],
      );

      // The journal-plane dispatcher drains on the watch/nudge cadence,
      // not synchronously inside say — wait for the generate to park
      // before releasing it (the other tests always did).
      await _waitFor(() => brain.hasPending, because: 'generate parked');
      brain.reply('The onboarding flow, then exports.');
      await _waitFor(
        () => host.narrations[actor.actorId]?.state ==
            BotNarrationState.listening,
        because: 'listening after the reply lands',
      );
      final read = await conversation.read(actor: human, threadId: threadId);
      final beats = (read['beats']! as List).cast<Map>();
      expect(beats.last['text'], 'The onboarding flow, then exports.');
      expect(host.statuses[actor.actorId], 'listening');

      // The recorded cycle: the wake was visible as thinking (naming the
      // actor being answered), then generating (naming the thread
      // topic), then the quiet listening. Registration may interleave a
      // first listening — containsAllInOrder tolerates that.
      expect(
        [for (final narration in seen) narration.state],
        containsAllInOrder(<BotNarrationState>[
          BotNarrationState.idle,
          BotNarrationState.thinking,
          BotNarrationState.generating,
          BotNarrationState.listening,
        ]),
      );
      expect(
        seen.firstWhere(
          (narration) => narration.state == BotNarrationState.thinking,
        ).detail,
        'human-tester',
      );
      expect(
        seen.firstWhere(
          (narration) => narration.state == BotNarrationState.generating,
        ).detail,
        'lab',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'the echo guard drops a near-identical reply into droppedEcho and '
    'says nothing',
    () async {
      final (:world, :host, :brain, :actor, :threadId, :seen) =
          await _harness();
      final human = world.authorityFor('human-tester');
      final conversation = world.conversation();

      // Cycle one lands a real reply.
      await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'What should we ship first?',
        addressedTo: [actor.actorId],
      );
      await _waitFor(() => brain.hasPending, because: 'first generate parked');
      brain.reply('The onboarding flow, then exports.');
      await _waitFor(
        () => host.narrations[actor.actorId]?.state ==
            BotNarrationState.listening,
        because: 'first reply landed',
      );

      // Cycle two: the scripted reply repeats the human's beat verbatim
      // — the guard drops it, the narration says so, no beat is said.
      await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'And the export path?',
        addressedTo: [actor.actorId],
      );
      await _waitFor(
        () => brain.hasPending,
        because: 'second generate parked',
      );
      brain.reply('What should we ship first?');
      await _waitFor(
        () => host.narrations[actor.actorId]?.state ==
            BotNarrationState.droppedEcho,
        because: 'the echo guard drops the reply',
        snapshot: () =>
            'statuses=${host.statuses} narrations=${host.narrations} '
            'seen=${[for (final n in seen) '${n.state}:${n.detail}']}',
      );
      expect(host.narrations[actor.actorId]?.detail, 'echo dropped');
      expect(host.statuses[actor.actorId], 'listening');
      expect(
        [for (final narration in seen) narration.state],
        contains(BotNarrationState.droppedEcho),
      );

      final read = await conversation.read(actor: human, threadId: threadId);
      expect((read['beats']! as List).length, 3); // 2 human + 1 real reply
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'a failed generation lands on failed with the exact status',
    () async {
      final (:world, :host, :brain, :actor, :threadId, :seen) =
          await _harness();
      final human = world.authorityFor('human-tester');
      final conversation = world.conversation();

      await conversation.say(
        actor: human,
        threadId: threadId,
        text: 'Say something.',
        addressedTo: [actor.actorId],
      );
      await _waitFor(() => brain.hasPending, because: 'generate parked');
      brain.failGeneration();
      await _waitFor(
        () =>
            host.narrations[actor.actorId]?.state == BotNarrationState.failed,
        because: 'the failed generation is visible',
      );
      // First failure of the streak: the string status is 'degraded: …',
      // the narration keeps the exact string as its detail.
      expect(host.narrations[actor.actorId]?.detail, 'degraded: boom');
      expect(host.statuses[actor.actorId], 'degraded: boom');
      expect(
        [for (final narration in seen) narration.state],
        contains(BotNarrationState.failed),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
