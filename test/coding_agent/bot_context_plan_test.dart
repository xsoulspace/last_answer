import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// 1f — the endless-participation laws (ADR 0122/0136) in the in-app
/// bot loop: the frozen head is BYTE-STABLE across dispatches (no
/// reply-target interpolation — the target rides the grounding tail),
/// the window front slides only in quantized steps (between slides the
/// transcript is a strict prefix-extension = the provider prefix cache
/// extends instead of cold-starting), the profile tiers by brain
/// grammar, and compression is announced, never silent.

/// Captures every generate() call's system head + turns, and parks the
/// reply until the test releases it.
final class _CapturingBrain implements ActorBrain {
  final systems = <String>[];
  final turnsLog = <List<BrainTurn>>[];
  final _pending = <Completer<String>>[];

  bool get hasPending => _pending.isNotEmpty;

  void reply(final String text) => _pending.removeAt(0).complete(text);

  @override
  Future<String> generate({
    required final String system,
    required final List<BrainTurn> turns,
  }) {
    systems.add(system);
    turnsLog.add(List.of(turns));
    final done = Completer<String>();
    _pending.add(done);
    return done.future;
  }

  @override
  String get label => 'capturing';

  @override
  String get ref => 'capturing:brain';
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

void main() {
  group('the profile tiers', () {
    test('local brains ride the compact tier; hosted brains the remote '
        'assumption', () {
      expect(botContextProfileFor('local:qwen').windowTokens, 32000);
      expect(
        botContextProfileFor('cast:modelscope_qwen38max').windowTokens,
        ContextProfile.defaultWindowTokens,
      );
      expect(
        botContextProfileFor('openrouter:x').windowTokens,
        ContextProfile.defaultWindowTokens,
      );
    });
  });

  group('the frozen head + the quantized window', () {
    test(
      'the head is byte-identical across dispatches by different '
      'authors, and the transcript is a prefix-extension between '
      'quantum slides',
      () async {
        final temp = await Directory.systemTemp.createTemp('la_ctxplan_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        final brain = _CapturingBrain();
        final roster = ActorRoster(replicaId: 'tester');
        final host = RealmBotHost(
          world: world,
          humanActorId: 'human-1',
          resolveOpenRouterApiKey: () => null,
          debugBrainOverride: (_) => brain,
        );
        addTearDown(host.stopAll);
        final bot = ActorProfile(
          actorId: 'bot-ctx',
          displayName: 'Ctx Bot',
          kind: ActorKind.model,
          brainRef: 'cast:test-rung',
        );
        roster.upsert(bot);
        host.syncBots(roster.all);

        final conversation = world.conversation();
        final opened = await conversation.open(
          actor: world.authorityFor('human-1'),
          topic: 'the long room',
          participants: ['bot-ctx'],
          realmSealed: true,
        );
        final threadId = opened['threadId']! as String;

        // Build history: 40 beats alternating between two humans so no
        // echo/chain guard interferes, then address the bot.
        final alice = world.authorityFor('human-1');
        final bob = world.authorityFor('bob');
        for (var i = 1; i <= 40; i++) {
          await conversation.say(
            actor: i.isEven ? bob : alice,
            threadId: threadId,
            text: 'history line $i',
          );
        }
        await conversation.say(
          actor: alice,
          threadId: threadId,
          text: 'bot-ctx — first question?',
          addressedTo: ['bot-ctx'],
        );
        await _waitFor(
          () => brain.hasPending,
          because: 'first generate parked',
        );
        brain.reply('first answer');
        await _waitFor(
          () => brain.systems.length == 1 && !brain.hasPending,
          because: 'first reply done',
        );

        // A second dispatch by a DIFFERENT author: the head must not
        // move by one byte (the old "Reply to <name>" interpolation
        // cold-started the provider cache every turn).
        await conversation.say(
          actor: bob,
          threadId: threadId,
          text: 'bot-ctx — second question?',
          addressedTo: ['bot-ctx'],
        );
        await _waitFor(
          () => brain.systems.length == 2,
          because: 'second generate parked',
        );
        expect(brain.systems[1], brain.systems[0]);
        expect(brain.systems[0], isNot(contains('bob')));
        expect(brain.systems[0], isNot(contains('human-1')));
        brain.reply('second answer');
        await _waitFor(() => !brain.hasPending, because: 'second done');

        // The grounding tail carries the reply target instead: the
        // FINAL turn names who is being answered.
        expect(brain.turnsLog[1].last.content, startsWith('bob: '));
        expect(brain.turnsLog[0].last.content, contains('first question?'));

        // The quantized window: with a tier-0 window of 24 (quantum
        // 12), overflow rounds UP to a quantum multiple — at 42 beats
        // the front sits at 24 (window = beats 25..42, 18 beats,
        // regrowing toward 24 until the next slide at overflow > 24).
        // One more beat does NOT slide it: the slide happens in
        // quantum steps, so the transcript stays a strict
        // prefix-extension between them (the cache law).
        final startFirst = quantizedWindowStart(beatCount: 42, windowBeats: 24);
        expect(startFirst, 24);
        expect(
          quantizedWindowStart(beatCount: 43, windowBeats: 24),
          startFirst,
          reason: 'no slide before the quantum boundary',
        );
        expect(
          quantizedWindowStart(beatCount: 49, windowBeats: 24),
          greaterThan(startFirst),
          reason: 'overflow past the quantum slides the front',
        );
        // The captured transcript (minus the grounding turn) starts
        // just after the quantized front.
        final firstWindowTexts = [
          for (final turn in brain.turnsLog[0].take(brain.turnsLog[0].length - 1))
          turn.content,
        ];
        expect(firstWindowTexts.first, 'history line ${startFirst + 1}');
      },
      timeout: const Timeout(Duration(minutes: 4)),
    );
  });

  group('the compression announcement', () {
    test('a stepped-down plan tells the model its viewport (never a '
        'silent squeeze)', () {
      // A tiny window with a huge transcript forces the tier down and
      // sets compressed — the grounding line then names the viewport.
      const tiny = ContextProfile(windowTokens: 200);
      final plan = ContextPlan.resolve(
        profile: tiny,
        systemChars: 400,
        promptChars: 40000,
        beatCount: 30,
      );
      expect(plan.compressed, isTrue);
      expect(plan.windowBeats, lessThan(24));
      expect(plan.toTelemetry()['compressed'], isTrue);
    });
  });
}
