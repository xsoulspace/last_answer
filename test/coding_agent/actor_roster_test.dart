// ADR 0007 — the actor roster: stable, user-scoped, shareable actor
// identities as ordinary durable kernel state.
//
// Gate (PLAN Phase 5): roster CRUD + JSON persistence round-trip;
// two-replica convergence via kernel ops with SHUFFLED delivery (the
// kernel contract: arrival order never affects the fold); the sync seams
// (pendingOps / applyRemote / opsSince / version vector) exposed without
// wiring them — the mesh layer attaches later without an API change.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';

DateTime _at(final int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis);

ActorProfile _profile(
  final String id, {
  final String name = 'afm coder',
  final ActorKind kind = ActorKind.model,
  final String brain = 'afm-3',
  final String role = 'coder',
}) => ActorProfile(
  actorId: id,
  displayName: name,
  kind: kind,
  brainRef: brain,
  role: role,
);

void main() {
  group('roster CRUD', () {
    test('upsert → get → all (deterministic order) → remove', () {
      final roster = ActorRoster(replicaId: 'device')
        ..upsert(_profile('pi', brain: '', role: ''))
        ..upsert(_profile('afm-coder'));
      expect(roster.length, 2);
      expect(roster.contains('afm-coder'), isTrue);
      expect(roster.get('afm-coder')!.kind, ActorKind.model);
      expect(roster.get('afm-coder')!.brainRef, 'afm-3');

      // Deterministic order: by name, then id — small multiples render
      // identically on every replica.
      expect(
        roster.all.map((final a) => a.actorId).toList(),
        ['afm-coder', 'pi'],
      );

      // Upsert over the same id is an edit, not a duplicate.
      roster.upsert(_profile('pi', name: 'pi', role: 'reviewer'));
      expect(roster.length, 2);
      expect(roster.get('pi')!.role, 'reviewer');

      // Remove tombstones; removing an unknown id is a no-op.
      expect(roster.remove('pi'), isTrue);
      expect(roster.remove('pi'), isFalse);
      expect(roster.contains('pi'), isFalse);
      expect(roster.get('pi'), isNull);
      expect(roster.length, 1);
    });

    test('rejects empty ids and names', () {
      final roster = ActorRoster(replicaId: 'device');
      // An invalid profile throws before any op is issued (assertion in
      // debug builds, ArgumentError in the action path otherwise).
      expect(
        () => roster.upsert(_profile('', name: 'x')),
        throwsA(isA<Error>()),
      );
      expect(
        () => roster.upsert(_profile('x', name: ' ')),
        throwsA(isA<Error>()),
      );
      expect(roster.isEmpty, isTrue,
          reason: 'refused edits issued no kernel ops');
    });

    test('newActorId: slug of the name, de-duplicated against live ids',
        () {
      final roster = ActorRoster(replicaId: 'device');
      expect(roster.newActorId('AFM Coder'), 'afm-coder');
      roster.upsert(_profile('afm-coder'));
      expect(roster.newActorId('AFM Coder'), 'afm-coder-2');
      expect(roster.newActorId('AFM Coder!'), 'afm-coder-2');
      expect(roster.newActorId('  —  '), 'actor',
          reason: 'an empty slug falls back');
      expect(roster.newActorId('a very long display name indeed'),
          'a-very-long-display-name', reason: 'slug capped at 24 chars');
    });

    test('gutter label vocabulary (DESIGN §9): small-caps name, '
        'dash-joined, capped at a word boundary', () {
      expect(actorGutterLabel('afm coder'), 'AFM-CODER');
      expect(actorGutterLabel('pi'), 'PI');
      expect(actorGutterLabel('apple foundation model'), 'APPLE',
          reason: 'capped at the last word that still fits');
      expect(actorGutterLabel('supercalifragilistic'), 'SUPERCALIFRA',
          reason: 'a single over-long word is hard-capped at 12');
      expect(actorGutterLabel('  '), 'ACTOR',
          reason: 'honest absence, never a blank gutter cell');
    });
  });

  group('JSON persistence round-trip', () {
    test('toJson → fromJson restores the full folded state and log', () {
      final roster = ActorRoster(replicaId: 'device')
        ..upsert(_profile('afm-coder'), now: _at(1000))
        ..upsert(_profile('pi', name: 'pi'), now: _at(2000))
        ..remove('pi', now: _at(3000));

      final restored = ActorRoster.fromJson(roster.toJson());
      expect(restored.docId, roster.docId);
      expect(restored.replicaId, roster.replicaId);
      expect(restored.toJson(), roster.toJson(),
          reason: 'the round-trip is lossless');
      expect(restored.all, roster.all);
      expect(restored.pendingOps.length, roster.pendingOps.length);
    });

    test('a restored roster keeps its monotonic HLC watermark', () {
      final roster = ActorRoster(replicaId: 'device')
        ..upsert(_profile('afm-coder'), now: _at(1000));
      final opsBefore = roster.pendingOps.length;
      final watermarkBefore = roster.versionVector['device'];

      final restored = ActorRoster.fromJson(roster.toJson())
        // A REGRESSED wall clock (500 < 1000) must still postdate the
        // restored watermark — the monotonicity guard survives restarts.
        ..upsert(
          _profile('afm-coder', role: 'reviewer'),
          now: _at(500),
        );
      expect(restored.pendingOps.length, opsBefore + 1);
      expect(
        restored.versionVector['device']! > watermarkBefore!,
        isTrue,
        reason: 'the new op strictly postdates the restored watermark',
      );

      // The continuation op is an ordinary kernel op for other replicas.
      final peer = ActorRoster(replicaId: 'peer')
        ..applyRemote(restored.pendingOps);
      expect(peer.get('afm-coder')!.role, 'reviewer');
    });
  });

  group('two-replica convergence (kernel ops)', () {
    test('shuffled delivery converges; duplicates are idempotent', () {
      ActorRoster replicaA() => ActorRoster(replicaId: 'replica-a')
        ..upsert(_profile('afm-coder'), now: _at(1000))
        ..upsert(
          _profile(
            'pi',
            name: 'pi',
            kind: ActorKind.agent,
            brain: '',
            role: '',
          ),
          now: _at(2000),
        );
      ActorRoster replicaB() => ActorRoster(replicaId: 'replica-b')
        ..upsert(
          _profile(
            'anton',
            name: 'anton',
            kind: ActorKind.human,
            brain: '',
            role: 'operator',
          ),
          now: _at(3000),
        );

      // Fresh replicas per permutation; ops exchanged BOTH ways in
      // deterministic shuffled orders — the fold must not care about
      // arrival order (kernel contract).
      for (final (permutation, seed) in [(0, 1), (1, 7), (2, 42)]) {
        final a = replicaA();
        final b = replicaB();
        final aOps = a.pendingOps;
        final bOps = b.pendingOps;

        final aShuffled = List.of(aOps)..shuffle(Random(seed));
        final bShuffled =
            permutation == 2 ? bOps.reversed.toList() : List.of(bOps)
              ..shuffle(Random(seed + 1));

        expect(b.applyRemote(aShuffled), aOps.length,
            reason: 'all of A ops are new to B (permutation $permutation)');
        expect(a.applyRemote(bShuffled), bOps.length,
            reason: 'all of B ops are new to A (permutation $permutation)');

        expect(b.all, a.all, reason: 'converged (permutation $permutation)');
        expect(b.toJson()['state'], a.toJson()['state']);

        // Re-delivery is a no-op (dedupe by op id).
        expect(a.applyRemote(aOps), 0);
        expect(b.applyRemote(bOps), 0);
      }
    });

    test('last writer wins, regardless of delivery order', () {
      final a = ActorRoster(replicaId: 'replica-a');
      final b = ActorRoster(replicaId: 'replica-b');

      a.upsert(_profile('afm-coder', name: 'old name'), now: _at(1000));
      b.upsert(_profile('afm-coder', name: 'new name'), now: _at(2000));

      final aOps = a.pendingOps;
      final bOps = b.pendingOps;
      b.applyRemote(aOps);
      a.applyRemote(bOps);
      expect(a.get('afm-coder')!.displayName, 'new name');
      expect(b.get('afm-coder')!.displayName, 'new name');

      // A tombstone beats an older write and propagates: the kernel keeps
      // the delete winning so it reaches replicas that never saw the
      // value.
      final c = ActorRoster(replicaId: 'replica-c')
        ..upsert(_profile('pi'), now: _at(5000));
      expect(a.remove('pi', now: _at(100)), isFalse,
          reason: 'A does not know pi yet — no tombstone, no op');
      a.applyRemote(c.pendingOps);
      expect(a.contains('pi'), isTrue);
      a.remove('pi', now: _at(6000));
      final tombstone = a.opsSince(c.versionVector).last;
      c.applyRemote([tombstone]);
      expect(c.contains('pi'), isFalse);
    });

    test('sync seams: version vectors gate the delta; nothing is wired '
        'to a transport (the mesh attaches without API change)', () {
      final a = ActorRoster(replicaId: 'replica-a');
      final b = ActorRoster(replicaId: 'replica-b');

      a.upsert(_profile('afm-coder'), now: _at(1000));
      // B pulls exactly what it has not observed.
      final delta = a.opsSince(b.versionVector);
      expect(delta, hasLength(1));
      b.applyRemote(delta);
      expect(a.opsSince(b.versionVector), isEmpty,
          reason: 'B is fully caught up');

      a.upsert(_profile('afm-coder', role: 'lead'), now: _at(2000));
      expect(a.opsSince(b.versionVector), hasLength(1));
      expect(a.pendingOps, hasLength(2), reason: 'durable log, not compacted');

      // Snapshot path: a lagging replica catches up through
      // snapshotFor/adoptSnapshot (what compaction would force).
      expect(b.adoptSnapshot(a.snapshotFor()), isTrue);
      expect(b.get('afm-coder')!.role, 'lead');
      expect(b.needsSnapshotFor(VersionVector.zero), isTrue,
          reason: 'the adopted snapshot reset the log — a zero-vector peer '
              'must be served content, not ops');
    });
  });

  group('session registry projection (ADR 0006 → 0007)', () {
    test('session actors resolve ids through the roster; unknown ids '
        'attach but render as nothing', () {
      final controller = HarnessSessionController(
        config: const HarnessHostConfig(),
      );
      addTearDown(controller.dispose);

      final view = HarnessSessionView(id: 's1', cwd: '/tmp/w');
      expect(view.actorIds, isEmpty);

      controller.attachActor(view, 'afm-coder');
      expect(view.actorIds, ['afm-coder']);
      expect(view.actors(controller.roster), isEmpty,
          reason: 'the id is data-first; the roster does not know it yet');

      controller.roster.upsert(_profile('afm-coder'), now: _at(1000));
      expect(view.actors(controller.roster).single.actorId, 'afm-coder',
          reason: 'a late-arriving profile lights the row up');

      controller.attachActor(view, 'afm-coder');
      expect(view.actorIds, hasLength(1), reason: 'attach is idempotent');

      controller.detachActor(view, 'afm-coder');
      expect(view.actorIds, isEmpty);
    });
  });
}
