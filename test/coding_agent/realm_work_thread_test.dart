/// ADR 0129 — the work-thread spawn laws, pinned over the REAL
/// [RealmChatService] on a hermetic [RealmWorld] (the runAsync-style
/// real-IO pattern the room and ACP-bridge tests use):
/// * the spawn SEALS: the journal `threads` row of the work thread
///   carries projectId == the project root (the daemon's dispatch reads
///   it as the actor's fs workRoot), and the realm-sealed parent is
///   untouched;
/// * the REUSE law: one work thread per (parent, project) — a second
///   spawn returns the same thread with reused == true and mints no
///   second row, even under a double-send;
/// * the FORWARD law: the order lands as exactly ONE human beat in the
///   WORK thread, addressed to the members; the parent room never sees
///   the order text (the registry link is the parent's only knowledge);
/// * the HONEST-REFUSAL law: an ungranted project refuses with the
///   typed `project_not_granted` result carrying the current grants —
///   then the host's REAL `grantProjectAccess` against the hermetic
///   world home unblocks the spawn;
/// * the management verbs stay thin over the host's canonical
///   functions (request/pending/list/grant).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// One hermetic room: a world, a service, a realm-sealed parent thread
/// with two invited members, the human's id, and a repo-shaped project
/// root to delegate work into.
final class _Room {
  _Room({
    required this.temp,
    required this.world,
    required this.service,
    required this.parentThreadId,
    required this.humanId,
    required this.repoPath,
  });

  final Directory temp;
  final RealmWorld world;
  final RealmChatService service;
  final String parentThreadId;
  final String humanId;
  final String repoPath;

  Future<void> dispose() async {
    service.dispose();
    await temp.delete(recursive: true);
  }
}

Future<_Room> _openRoom(final String label) async {
  final temp = await Directory.systemTemp.createTemp('la_work_spawn_$label');
  final world = await RealmWorld.open(rootOverride: temp.path);
  if (world == null) {
    await temp.delete(recursive: true);
    fail('realm world unsupported on this platform');
  }
  final service = RealmChatService(
    debugWorldOverride: world,
    debugRosterOverride: ActorRoster(replicaId: 'tester'),
    debugStartBotDispatcher: false,
  );
  await service.ensureReady();
  expect(service.isReady, isTrue, reason: service.error);
  await service.startThread(
    topic: 'Parent room',
    participants: const <String>['worker-a', 'worker-b'],
  );
  final parentThreadId = service.activeThreadId;
  if (parentThreadId == null) fail('no parent thread');
  final repo = Directory('${temp.path}/repo');
  await repo.create();
  return _Room(
    temp: temp,
    world: world,
    service: service,
    parentThreadId: parentThreadId,
    humanId: service.humanActorId!,
    repoPath: repo.path,
  );
}

void main() {
  test('spawn seals the work thread to the project; the realm-sealed '
      'parent is untouched', () async {
    final room = await _openRoom('seal');
    addTearDown(room.dispose);
    // Sealing to a real repo requires the ADR 0129 grant first.
    final grant = await room.service.grantAccess(room.humanId, room.repoPath);
    expect(grant.granted, isTrue, reason: grant.message);

    final spawn = await room.service.spawnWorkThread(
      parentThreadId: room.parentThreadId,
      projectRoot: room.repoPath,
      memberIds: const <String>['worker-a'],
    );
    expect(spawn.isSpawned, isTrue, reason: spawn.message);
    expect(spawn.reused, isFalse);
    expect(spawn.refusal, isNull);
    final link = spawn.workThread!;

    // The journal row carries the seal — the daemon's dispatch reads
    // `projectId` as the actor's filesystem workRoot.
    final row = await room.world.store.read('threads', link.workThreadId);
    expect(row?['projectId'], room.repoPath);
    expect(row?['projectRoot'], room.repoPath);
    expect(row?['topic'], 'repo', reason: 'default name = last path segment');
    expect(row?['closed'], false);
    expect(
      row?['participants'],
      containsAll(<String>[room.humanId, 'worker-a']),
    );

    // The realm-sealed parent stays conversation-only (no project).
    final parentRow = await room.world.store.read(
      'threads',
      room.parentThreadId,
    );
    expect(parentRow?['projectId'], isNull);
    expect(parentRow?['closed'], false);

    // The registry link and the service projection agree; the granted
    // seal makes the work thread visible to the human's own thread list
    // (ADR 0121 visibility law).
    expect(link.parentThreadId, room.parentThreadId);
    expect(link.projectRoot, room.repoPath);
    expect(link.createdBy, room.humanId);
    expect(
      room.service
          .workThreadsOf(room.parentThreadId)
          .map((final l) => l.workThreadId),
      <String>[link.workThreadId],
    );
    expect(
      room.service.threads.any(
        (final thread) => thread['threadId'] == link.workThreadId,
      ),
      isTrue,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('an ungranted project refuses with typed evidence; the host grant '
      'unblocks the spawn', () async {
    final room = await _openRoom('grant');
    addTearDown(room.dispose);

    final spawn = await room.service.spawnWorkThread(
      parentThreadId: room.parentThreadId,
      projectRoot: room.repoPath,
      memberIds: const <String>['worker-a'],
      orderText: 'please triage the failing test',
    );
    // The honest-refusal law: the absence is NAMED, carries the current
    // grants, and never escapes as an exception.
    expect(spawn.isSpawned, isFalse);
    expect(spawn.refusal, 'project_not_granted');
    expect(spawn.requestedProject, room.repoPath);
    expect(spawn.grants, isNot(contains(room.repoPath)));
    expect(spawn.grants, contains(room.world.root),
        reason: 'the app-support scope accrues; the repo does not');
    // Nothing landed: no registry row, no order beat anywhere.
    expect(await room.world.store.scan('work_threads'), isEmpty);
    final parentBeats = await room.world.projection.beatsOfThread(
      room.parentThreadId,
    );
    expect(parentBeats, isEmpty);

    // The REAL host function (what `ecsai --grant` runs) against the
    // hermetic world home: `<override>/world` is the parent of the
    // store's `coordination` directory, so the grant writes the SAME
    // journal the service reads.
    final message = await grantProjectAccess(
      worldHome: room.world.root,
      actor: room.humanId,
      projectRoot: room.repoPath,
    );
    expect(message, startsWith('granted:'));
    expect(
      await room.service.listGrants(room.humanId),
      contains(room.repoPath),
    );

    final second = await room.service.spawnWorkThread(
      parentThreadId: room.parentThreadId,
      projectRoot: room.repoPath,
      memberIds: const <String>['worker-a'],
      orderText: 'please triage the failing test',
    );
    expect(second.isSpawned, isTrue, reason: second.message);
    expect(second.reused, isFalse);
    expect(second.refusal, isNull);
    expect(second.orderBeat, 1);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('the reuse law: one work thread per (parent, project), reused '
      'forever after', () async {
    final room = await _openRoom('reuse');
    addTearDown(room.dispose);
    await room.service.grantAccess(room.humanId, room.repoPath);

    final first = await room.service.spawnWorkThread(
      parentThreadId: room.parentThreadId,
      projectRoot: room.repoPath,
    );
    expect(first.isSpawned, isTrue, reason: first.message);
    final second = await room.service.spawnWorkThread(
      parentThreadId: room.parentThreadId,
      projectRoot: room.repoPath,
      memberIds: const <String>['worker-a'],
      orderText: 'a later order',
    );
    expect(second.reused, isTrue);
    expect(second.workThread!.workThreadId, first.workThread!.workThreadId);
    // Reuse changes where the thread comes from, never whether the
    // order lands.
    expect(second.orderBeat, 1);

    // Exactly ONE threads row sealed to the repo, ONE registry row.
    final threads = await room.world.store.scan('threads');
    expect(
      threads.values.where(
        (final row) => row['projectId'] == room.repoPath,
      ),
      hasLength(1),
    );
    expect((await room.world.store.scan('work_threads')).values, hasLength(1));
    expect(room.service.workThreads, hasLength(1));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('a double-send cannot mint two threads (per-key serialization)',
      () async {
    final room = await _openRoom('race');
    addTearDown(room.dispose);
    await room.service.grantAccess(room.humanId, room.repoPath);

    final results = await Future.wait([
      room.service.spawnWorkThread(
        parentThreadId: room.parentThreadId,
        projectRoot: room.repoPath,
        memberIds: const <String>['worker-a'],
        orderText: 'order one',
      ),
      room.service.spawnWorkThread(
        parentThreadId: room.parentThreadId,
        projectRoot: room.repoPath,
        memberIds: const <String>['worker-a'],
        orderText: 'order two',
      ),
    ]);
    final ids = results
        .map((final result) => result.workThread!.workThreadId)
        .toSet();
    expect(ids, hasLength(1), reason: 'both spawns answer the same thread');
    expect(results.where((final result) => result.reused), hasLength(1));
    expect((await room.world.store.scan('work_threads')).values, hasLength(1));
    // Both orders landed — one beat each, in the one thread.
    final beats = await room.world.projection.beatsOfThread(ids.single);
    expect(beats, hasLength(2));
    expect(
      beats.map((final beat) => beat['text']),
      containsAll(<String>['order one', 'order two']),
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('a different project or a different parent gets its own work '
      'thread', () async {
    final room = await _openRoom('distinct');
    addTearDown(room.dispose);
    final repo2 = Directory('${room.temp.path}/repo2');
    await repo2.create();
    await room.service.grantAccess(room.humanId, room.repoPath);
    await room.service.grantAccess(room.humanId, repo2.path);

    final a = await room.service.spawnWorkThread(
      parentThreadId: room.parentThreadId,
      projectRoot: room.repoPath,
    );
    final b = await room.service.spawnWorkThread(
      parentThreadId: room.parentThreadId,
      projectRoot: repo2.path,
    );
    expect(b.workThread!.workThreadId, isNot(a.workThread!.workThreadId));
    expect(b.reused, isFalse);

    // The same project from ANOTHER parent room is a distinct thread.
    await room.service.startThread(topic: 'Other room');
    final parent2 = room.service.activeThreadId!;
    final c = await room.service.spawnWorkThread(
      parentThreadId: parent2,
      projectRoot: room.repoPath,
    );
    expect(c.workThread!.workThreadId, isNot(a.workThread!.workThreadId));
    expect(c.reused, isFalse);

    expect(room.service.workThreads, hasLength(3));
    expect(room.service.workThreadsOf(room.parentThreadId), hasLength(2));
    expect(room.service.workThreadsOf(parent2), hasLength(1));
    expect(
      await room.service.listGrants(room.humanId),
      containsAll(<String>[room.repoPath, repo2.path]),
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('the forward law: ONE addressed human beat in the work thread; '
      'the parent never sees the order text', () async {
    final room = await _openRoom('forward');
    addTearDown(room.dispose);
    await room.service.grantAccess(room.humanId, room.repoPath);

    const order = 'triage the failing widget test and report back';
    final spawn = await room.service.spawnWorkThread(
      parentThreadId: room.parentThreadId,
      projectRoot: room.repoPath,
      memberIds: const <String>['worker-a', 'worker-b'],
      orderText: order,
    );
    expect(spawn.isSpawned, isTrue, reason: spawn.message);
    expect(spawn.orderBeat, 1);

    final beats = await room.world.projection.beatsOfThread(
      spawn.workThread!.workThreadId,
    );
    expect(beats, hasLength(1), reason: 'one order = one beat');
    final beat = beats.single;
    expect(beat['author'], room.humanId);
    expect(beat['text'], order);
    expect(
      (beat['addressedTo']! as List).cast<String>(),
      containsAll(<String>['worker-a', 'worker-b']),
    );

    // The parent room does NOT get the order text — the link (the
    // registry row) is all the parent ever carries.
    final parentBeats = await room.world.projection.beatsOfThread(
      room.parentThreadId,
    );
    expect(
      parentBeats.where((final b) => '${b['text']}'.contains(order)),
      isEmpty,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('an unknown parent is a named refusal, never a link into the void',
      () async {
    final room = await _openRoom('noparent');
    addTearDown(room.dispose);
    await room.service.grantAccess(room.humanId, room.repoPath);
    final spawn = await room.service.spawnWorkThread(
      parentThreadId: 'thread-doesnotexist',
      projectRoot: room.repoPath,
    );
    expect(spawn.isSpawned, isFalse);
    expect(spawn.refusal, 'parent_thread_missing');
    expect(await room.world.store.scan('work_threads'), isEmpty);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('management verbs stay thin over the host functions: request, '
      'pending, list, grant', () async {
    final room = await _openRoom('access');
    addTearDown(room.dispose);
    // A durable actor row (the host grant writes grants onto durable
    // rows; an actor without one is honestly refused).
    await room.world.registerActor('worker-a', displayName: 'Worker A');

    // requestAccess → the host's pending row, verbatim.
    final requested = await room.service.requestAccess(
      'worker-a',
      room.repoPath,
    );
    expect(requested['ok'], true);
    expect(requested['state'], 'pending');
    expect(requested['requested'], room.repoPath);

    // pendingAccessRequests scans the SAME host-written collection.
    final pending = await room.service.pendingAccessRequests();
    expect(pending, hasLength(1));
    expect(pending.single['actorId'], 'worker-a');
    expect(pending.single['projectId'], room.repoPath);
    expect(pending.single['state'], 'pending');

    // Not granted yet — the request is not the grant.
    expect(
      await room.service.listGrants('worker-a'),
      isNot(contains(room.repoPath)),
    );

    // grantAccess (the in-process `ecsai --grant` twin) flips the
    // pending row and lands on the durable grant set; the VERIFY
    // re-read is what makes the outcome honest.
    final grant = await room.service.grantAccess('worker-a', room.repoPath);
    expect(grant.granted, isTrue, reason: grant.message);
    expect(
      await room.service.listGrants('worker-a'),
      contains(room.repoPath),
    );
    expect(await room.service.pendingAccessRequests(), isEmpty);

    // An actor with no durable row is honestly refused by the host —
    // never a silent no-op dressed as success.
    final ghost = await room.service.grantAccess('ghost-actor', room.repoPath);
    expect(ghost.granted, isFalse);
    expect(ghost.message, contains('no durable row'));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
