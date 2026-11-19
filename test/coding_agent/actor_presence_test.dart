// The ACTOR STATUS fold (2026-11-18): one pure derivation over the
// facts the service and the world already hold. Retirement wins over
// everything; running tasks and a live reply cycle read WORKING; the
// listening quiet reads IDLE; a failed cycle or status string reads
// FAILED; no facts at all read ABSENT — honest absence, never an
// invented state. The mark renders the verdict as one dot and NOTHING
// for retired/absent.
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/ui_chat/actor_presence.dart';
import 'package:lastanswer/data_journal/realm_bot_host.dart';

void main() {
  group('deriveActorPresence — the precedence law', () {
    test('retirement wins over every live fact', () {
      expect(
        deriveActorPresence(
          retired: true,
          botStatus: 'listening',
          narration: BotNarrationState.generating,
          runningTasks: 3,
        ),
        ActorPresenceStatus.retired,
      );
    });

    test('a running durable task reads WORKING, over any narration', () {
      expect(
        deriveActorPresence(
          botStatus: 'listening',
          narration: BotNarrationState.listening,
          runningTasks: 1,
        ),
        ActorPresenceStatus.working,
      );
      // The task exists even while the last reply cycle failed — the
      // failure line rides the narration beside the mark.
      expect(
        deriveActorPresence(
          narration: BotNarrationState.failed,
          runningTasks: 2,
        ),
        ActorPresenceStatus.working,
      );
    });

    test('a live reply cycle (thinking/generating) reads WORKING', () {
      expect(
        deriveActorPresence(narration: BotNarrationState.thinking),
        ActorPresenceStatus.working,
      );
      expect(
        deriveActorPresence(narration: BotNarrationState.generating),
        ActorPresenceStatus.working,
      );
    });

    test('a failed cycle or status string reads FAILED', () {
      expect(
        deriveActorPresence(narration: BotNarrationState.failed),
        ActorPresenceStatus.failed,
      );
      expect(
        deriveActorPresence(botStatus: 'failed: registration'),
        ActorPresenceStatus.failed,
      );
    });

    test('the quiet awake normal reads IDLE', () {
      expect(
        deriveActorPresence(botStatus: 'listening'),
        ActorPresenceStatus.idle,
      );
      expect(
        deriveActorPresence(botStatus: 'idle'),
        ActorPresenceStatus.idle,
      );
      expect(
        deriveActorPresence(narration: BotNarrationState.listening),
        ActorPresenceStatus.idle,
      );
      expect(
        deriveActorPresence(narration: BotNarrationState.idle),
        ActorPresenceStatus.idle,
      );
      // The echo guard dropped the reply — the bot is back to quiet.
      expect(
        deriveActorPresence(narration: BotNarrationState.droppedEcho),
        ActorPresenceStatus.idle,
      );
    });

    test('no foldable facts read ABSENT (humans, unknown ids)', () {
      expect(deriveActorPresence(), ActorPresenceStatus.absent);
      expect(
        deriveActorPresence(botStatus: 'stopped'),
        ActorPresenceStatus.absent,
      );
    });
  });

  group('ActorStatusMark — the dot renders the verdict', () {
    Widget mark(final ActorPresenceStatus status) => MaterialApp(
      home: Scaffold(
        body: ActorStatusMark(key: const ValueKey('mark'), status: status),
      ),
    );

    testWidgets('working/idle/failed render one colored dot', (
      final tester,
    ) async {
      Color? dotColor() {
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byKey(const ValueKey('mark')),
            matching: find.byType(Container),
          ),
        );
        return (container.decoration! as BoxDecoration).color;
      }

      await tester.pumpWidget(mark(ActorPresenceStatus.working));
      expect(
        dotColor(),
        tester
            .element(find.byKey(const ValueKey('mark')))
            .la
            .accent,
        reason: 'working rides the accent',
      );

      await tester.pumpWidget(mark(ActorPresenceStatus.idle));
      expect(dotColor(), kActorPresenceOnline);

      await tester.pumpWidget(mark(ActorPresenceStatus.failed));
      expect(
        dotColor(),
        tester
            .element(find.byKey(const ValueKey('mark')))
            .la
            .danger,
        reason: 'failed rides the danger',
      );
    });

    testWidgets('retired and absent render NOTHING (honest absence)', (
      final tester,
    ) async {
      await tester.pumpWidget(mark(ActorPresenceStatus.retired));
      expect(find.byType(Container), findsNothing);

      await tester.pumpWidget(mark(ActorPresenceStatus.absent));
      expect(find.byType(Container), findsNothing);
    });
  });
}
