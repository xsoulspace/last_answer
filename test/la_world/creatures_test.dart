import 'package:ecsly_flutter/ecsly_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart'
    show ActorTelemetry;
import 'package:lastanswer/la_world/creatures.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/la_world/la_world_components.dart';
import 'package:lastanswer/ui/creature_mark.dart';

/// 3d — the creature layer's laws: species are deterministic identity,
/// moods are DERIVED from honest facts (never invented), the derivation
/// re-runs on the projection's own write paths and on refreshCreatures,
/// creature state never rides a per-frame notification (the selector
/// discipline), and the mark is static under reduced motion with its
/// Semantics contract key.
void main() {
  group('species determinism (identity never drifts)', () {
    test('the same id always picks the same species', () {
      expect(speciesOf('scout'), speciesOf('scout'));
      expect(speciesOf('toby'), speciesOf('toby'));
      expect(blinkSeedOf('scout'), blinkSeedOf('scout'));
    });

    test('species stay inside the six identicon families and spread', () {
      final seen = <CreatureSpecies>{};
      for (var i = 0; i < 60; i++) {
        final species = speciesOf('actor-$i');
        expect(CreatureSpecies.values, contains(species));
        seen.add(species);
      }
      expect(seen.length, greaterThan(1), reason: 'the hash spreads families');
    });

    test('the world creature is a stable identity too', () {
      expect(speciesOf(kWorldCreatureId), speciesOf(kWorldCreatureId));
    });
  });

  group('THE DERIVE LAW (world truth, never decorative fiction)', () {
    test('quiet facts derive calm', () {
      final derived = deriveCreatureMood();
      expect(derived.mood, CreatureMood.calm);
      expect(derived.cause, 'quiet');
      // A listening bot and an echo drop are the quiet normal.
      expect(
        deriveCreatureMood(narrationState: 'listening').mood,
        CreatureMood.calm,
      );
      expect(
        deriveCreatureMood(narrationState: 'droppedEcho').mood,
        CreatureMood.calm,
      );
    });

    test('the loop says thinking/generating → focused', () {
      expect(
        deriveCreatureMood(narrationState: 'thinking').mood,
        CreatureMood.focused,
      );
      expect(
        deriveCreatureMood(narrationState: 'generating').mood,
        CreatureMood.focused,
      );
      // A running addressed task is the journal's own fact.
      expect(deriveCreatureMood(runningTasks: 2).mood, CreatureMood.focused);
    });

    test('stalled telemetry → worried, outranking the busy facts', () {
      expect(
        deriveCreatureMood(telemetryStalled: true).mood,
        CreatureMood.worried,
      );
      expect(
        deriveCreatureMood(telemetryStalled: true, runningTasks: 1).mood,
        CreatureMood.worried,
      );
    });

    test('a failed cycle → sad, outranking the stall', () {
      expect(
        deriveCreatureMood(narrationState: 'failed').mood,
        CreatureMood.sad,
      );
      expect(
        deriveCreatureMood(
          narrationState: 'failed',
          telemetryStalled: true,
        ).mood,
        CreatureMood.sad,
      );
    });

    test('a recent succeeded terminal → celebrating', () {
      expect(
        deriveCreatureMood(recentlySucceeded: true).mood,
        CreatureMood.celebrating,
      );
      // …but the busy and distressed facts outrank the party.
      expect(
        deriveCreatureMood(recentlySucceeded: true, runningTasks: 1).mood,
        CreatureMood.focused,
      );
    });

    test('the daemon down → asleep, outranking EVERYTHING', () {
      expect(
        deriveCreatureMood(
          daemonAsleep: true,
          narrationState: 'failed',
          telemetryStalled: true,
          runningTasks: 3,
        ).mood,
        CreatureMood.asleep,
      );
      expect(deriveCreatureMood(daemonAsleep: true).cause, 'daemon-down');
    });

    test('the celebration window is honest about time', () {
      final now = DateTime.utc(2026, 11, 8, 12);
      final fresh = now.subtract(const Duration(minutes: 2)).toIso8601String();
      final old = now.subtract(const Duration(hours: 3)).toIso8601String();
      final future = now.add(const Duration(minutes: 2)).toIso8601String();
      expect(succeededRecently(fresh, now), isTrue);
      expect(succeededRecently(old, now), isFalse);
      expect(succeededRecently(future, now), isFalse);
      expect(succeededRecently(null, now), isFalse);
      expect(succeededRecently('', now), isFalse);
      expect(succeededRecently('not-a-timestamp', now), isFalse);
    });
  });

  group('LaWorld: creature state rides the projection, not a frame loop', () {
    late LaWorld laWorld;

    setUp(() => laWorld = LaWorld(humanActorId: () => 'human-1'));
    tearDown(() => laWorld.dispose());

    ActorTelemetry telemetry({final bool stalled = false}) => ActorTelemetry(
      actorId: 'scout',
      rounds: 1,
      promptTokens: 10,
      cachedTokens: 0,
      stalled: stalled,
    );

    test('a new actor spawns calm; an unknown actor reads calm', () {
      laWorld.putActor(ActorRow(actorId: 'scout', displayName: 'Scout'));
      expect(laWorld.moodOf('scout'), CreatureMood.calm);
      expect(laWorld.moodCauseOf('scout'), 'quiet');
      expect(laWorld.moodOf('nobody'), CreatureMood.calm);
      expect(laWorld.moodCauseOf('nobody'), 'unknown');
    });

    test('a running addressed task focuses the actor on put', () {
      laWorld.putActor(ActorRow(actorId: 'scout'));
      laWorld
        ..putTask(
          TaskRow(
            taskId: 't-1',
            state: 'started',
            addressees: const ['scout'],
          ),
        )
        ..commitBatch();
      expect(laWorld.moodOf('scout'), CreatureMood.focused);
      expect(laWorld.moodCauseOf('scout'), 'tasks-running');
      // A task addressed to someone else never leaks into this mood.
      laWorld.putTask(
        TaskRow(taskId: 't-2', state: 'started', addressees: const ['toby']),
      );
      expect(laWorld.moodOf('scout'), CreatureMood.focused);
    });

    test('a settled PASS celebrates, then the window closes to calm', () {
      laWorld.putActor(ActorRow(actorId: 'scout'));
      laWorld.putTask(
        TaskRow(
          taskId: 't-1',
          state: 'succeeded',
          terminal: true,
          addressees: const ['scout'],
          at: DateTime.now().toIso8601String(),
        ),
      );
      expect(laWorld.moodOf('scout'), CreatureMood.celebrating);
      // An OLD success is history, not a party.
      laWorld.putTask(
        TaskRow(
          taskId: 't-1',
          state: 'succeeded',
          terminal: true,
          addressees: const ['scout'],
          at: DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        ),
      );
      expect(laWorld.moodOf('scout'), CreatureMood.calm);
    });

    test('stalled telemetry worries the actor on put', () {
      laWorld.putActor(ActorRow(actorId: 'scout'));
      laWorld.putTelemetry(
        TelemetryRow(actorId: 'scout', telemetry: telemetry()),
      );
      expect(laWorld.moodOf('scout'), CreatureMood.calm);
      laWorld.putTelemetry(
        TelemetryRow(
          actorId: 'scout',
          telemetry: ActorTelemetry(
            actorId: 'scout',
            rounds: 2,
            promptTokens: 10,
            cachedTokens: 0,
            stalled: true,
            at: '2026-11-08T12:00:00Z',
          ),
        ),
      );
      expect(laWorld.moodOf('scout'), CreatureMood.worried);
    });

    test('refreshCreatures folds the in-memory facts and retains them', () {
      laWorld.putActor(ActorRow(actorId: 'scout'));
      laWorld.refreshCreatures(narrationStates: const {'scout': 'failed'});
      expect(laWorld.moodOf('scout'), CreatureMood.sad);
      expect(laWorld.moodCauseOf('scout'), 'narration-failed');
      // A later journal row re-derives WITH the retained narration.
      laWorld.putTask(
        TaskRow(taskId: 't-1', state: 'started', addressees: const ['scout']),
      );
      expect(laWorld.moodOf('scout'), CreatureMood.sad);
      // The daemon fact outranks everything, and null keeps the last
      // reported fact (honest absence never invents a state).
      laWorld.refreshCreatures(daemonAsleep: true);
      expect(laWorld.moodOf('scout'), CreatureMood.asleep);
      laWorld.refreshCreatures();
      expect(laWorld.moodOf('scout'), CreatureMood.asleep);
      laWorld.refreshCreatures(daemonAsleep: false);
      expect(laWorld.moodOf('scout'), CreatureMood.sad);
    });

    test('a removed actor row takes its creature with it', () {
      laWorld.putActor(ActorRow(actorId: 'scout'));
      laWorld.refreshCreatures(narrationStates: const {'scout': 'failed'});
      expect(laWorld.moodOf('scout'), CreatureMood.sad);
      laWorld.removeRow('realm_actors', 'scout');
      expect(laWorld.moodCauseOf('scout'), 'unknown');
    });

    testWidgets(
      'creature state NEVER rides a per-frame notification: an '
      'unread selector does not rebuild when moods move',
      (final tester) async {
        var builds = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: EcsWorldSelector<Map<String, int>>(
              world: laWorld.world,
              controller: laWorld.controller,
              select: (world) => laWorld.unreadByThread(),
              equals: (a, b) =>
                  a.length == b.length &&
                  a.entries.every((e) => b[e.key] == e.value),
              builder: (context, value) {
                builds++;
                return Text('unread:${value.length}');
              },
            ),
          ),
        );
        expect(builds, 1);

        // Actors, tasks, telemetry and mood refreshes with NO commit:
        // nothing notifies, nothing rebuilds.
        laWorld
          ..putActor(ActorRow(actorId: 'scout'))
          ..putTask(
            TaskRow(
              taskId: 't-1',
              state: 'started',
              addressees: const ['scout'],
            ),
          )
          ..refreshCreatures(narrationStates: const {'scout': 'failed'})
          ..putTelemetry(
            TelemetryRow(actorId: 'scout', telemetry: telemetry()),
          );
        await tester.pump();
        expect(builds, 1, reason: 'creature state is silent on the wire');

        // Even a committed batch that moves MOODS but not the unread
        // selection rebuilds nothing (the equality gate rules).
        laWorld.commitBatch();
        await tester.pump();
        expect(builds, 1);
        expect(laWorld.moodOf('scout'), CreatureMood.sad);
      },
    );
  });

  group('CreatureMark: static under reduced motion, contract intact', () {
    testWidgets('disableAnimations renders the static pose with NO '
        'scheduled frames, and carries the Semantics contract', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: CreatureMark(
                actorId: 'scout',
                mood: CreatureMood.celebrating,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // The contract: key + Semantics label are `creature.<actorId>`,
      // the mood word rides the hint (English contract vocabulary).
      expect(find.byKey(const ValueKey('creature.scout')), findsOneWidget);
      final semantics = tester.widget<Semantics>(
        find.byKey(const ValueKey('creature.scout')),
      );
      expect(semantics.properties.label, 'creature.scout');
      expect(semantics.properties.hint, 'celebrating');
      // The motion-free truth: no ticker, no frame requests — the pose
      // alone carries the state.
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('an awake creature under motion ticks; a sleeping one '
        'never does', (final tester) async {
      Widget wrap(final CreatureMood mood) => MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: CreatureMark(actorId: 'scout', mood: mood)),
        ),
      );
      await tester.pumpWidget(wrap(CreatureMood.calm));
      await tester.pump();
      expect(
        tester.binding.hasScheduledFrame,
        isTrue,
        reason: 'the calm blink is the one living loop',
      );

      await tester.pumpWidget(wrap(CreatureMood.asleep));
      await tester.pump();
      expect(
        tester.binding.hasScheduledFrame,
        isFalse,
        reason: 'a sleeping creature is pure posture — no frames',
      );
      // Dispose the tree so no ticker outlives the test.
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
