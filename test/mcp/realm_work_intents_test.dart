/// ADR 0129 — the work-thread intents, pinned at the handler level:
/// `realm_chat_spawn_work` and `realm_project_access` driven through
/// their REAL entries (`realmChatMcpEntries()` +
/// AgentCallEntry.invokeDirect — the same contract the app-intent suite
/// holds) against a hermetic [RealmChatService]. The refusal shapes are
/// the contract: `project_not_granted` carries the grants list and the
/// next move; every honest absence names itself.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_mcp_tools.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

AgentCallEntry _entry(final String name) =>
    realmChatMcpEntries().firstWhere((final e) => e.name == name);

// The legacy mcpToolkitTool bridge wraps every MCPCallResult as
// AgentResult.success — the REAL ok flag is carried in data.
bool _okOf(final AgentResult result) => result.data['ok'] == true;

/// One hermetic room: the service registers itself in
/// [RealmChatService.debugInstances], which is where the intent
/// handlers resolve `_service` (first live instance).
final class _Room {
  _Room({
    required this.temp,
    required this.world,
    required this.service,
    required this.parentThreadId,
    required this.repoPath,
  });

  final Directory temp;
  final RealmWorld world;
  final RealmChatService service;
  final String parentThreadId;
  final String repoPath;

  String get humanId => service.humanActorId!;

  Future<void> dispose() async {
    service.dispose();
    await temp.delete(recursive: true);
  }
}

Future<_Room> _openRoom(final String label) async {
  final temp = await Directory.systemTemp.createTemp('la_work_int_$label');
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
  expect(
    RealmChatService.debugInstances.first,
    same(service),
    reason: 'the intent handlers drive THIS instance',
  );
  await service.startThread(
    topic: 'Parent room',
    participants: const <String>['worker-a'],
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
    repoPath: repo.path,
  );
}

void main() {
  test('with no live service both intents refuse honestly', () async {
    expect(RealmChatService.debugInstances, isEmpty);
    final spawn = await _entry(
      'realm_chat_spawn_work',
    ).invokeDirect(const {'project': '/some/repo'});
    expect(_okOf(spawn), isFalse);
    expect(spawn.data['error'], 'no_service');
    final access = await _entry(
      'realm_project_access',
    ).invokeDirect(const {'action': 'list'});
    expect(_okOf(access), isFalse);
    expect(access.data['error'], 'no_service');
  });

  test('realm_chat_spawn_work refuses project_not_granted with the grants '
      'list and the next move', () async {
    final room = await _openRoom('refuse');
    addTearDown(room.dispose);

    final result = await _entry('realm_chat_spawn_work').invokeDirect({
      'project': room.repoPath,
      'text': 'fix the thing',
      'members': 'worker-a',
      'parentThreadId': room.parentThreadId,
    });
    expect(_okOf(result), isFalse);
    expect(result.data['error'], 'project_not_granted');
    expect(result.data['project'], room.repoPath);
    expect(result.data['grants'], isA<List>());
    expect(result.data['grants'], isNot(contains(room.repoPath)));
    expect(result.message, contains('project_not_granted'));
    expect(result.data['hint'], contains('realm_project_access'));
    // Nothing landed.
    expect(await room.world.store.scan('work_threads'), isEmpty);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('realm_project_access grant unblocks the spawn; a second spawn '
      'reuses and forwards', () async {
    final room = await _openRoom('grant');
    addTearDown(room.dispose);

    // Grant with no explicit actor → the human.
    final grant = await _entry('realm_project_access').invokeDirect({
      'action': 'grant',
      'project': room.repoPath,
    });
    expect(_okOf(grant), isTrue, reason: grant.message);
    expect(grant.data['actor'], room.humanId);

    final list = await _entry(
      'realm_project_access',
    ).invokeDirect(const {'action': 'list'});
    expect(_okOf(list), isTrue, reason: list.message);
    expect(
      (list.data['grants']! as List).cast<String>(),
      contains(room.repoPath),
    );

    final spawn = await _entry('realm_chat_spawn_work').invokeDirect({
      'project': room.repoPath,
      'text': 'please triage the failing test',
      'members': 'worker-a',
      'parentThreadId': room.parentThreadId,
    });
    expect(_okOf(spawn), isTrue, reason: spawn.message);
    expect(spawn.data['reused'], false);
    expect(spawn.data['project'], room.repoPath);
    expect(spawn.data['parentThreadId'], room.parentThreadId);
    expect(spawn.data['orderBeat'], 1);
    final workThreadId = spawn.data['workThreadId']! as String;

    // The seal is journal truth (the daemon's workRoot read).
    final row = await room.world.store.read('threads', workThreadId);
    expect(row?['projectId'], room.repoPath);

    // The reuse law through the intent: same thread, order forwarded.
    final again = await _entry('realm_chat_spawn_work').invokeDirect({
      'project': room.repoPath,
      'text': 'and the second thing',
      'parentThreadId': room.parentThreadId,
    });
    expect(_okOf(again), isTrue, reason: again.message);
    expect(again.data['workThreadId'], workThreadId);
    expect(again.data['reused'], true);
    expect(again.data['orderBeat'], 2);

    final beats = await room.world.projection.beatsOfThread(workThreadId);
    expect(beats, hasLength(2));
    expect(beats.first['author'], room.humanId);
    expect(beats.first['text'], 'please triage the failing test');
    expect(
      (beats.first['addressedTo']! as List).cast<String>(),
      contains('worker-a'),
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('realm_chat_spawn_work defaults the parent to the active thread '
      'and refuses honestly without one', () async {
    final room = await _openRoom('defaultparent');
    addTearDown(room.dispose);
    await room.service.grantAccess(room.humanId, room.repoPath);

    final spawn = await _entry(
      'realm_chat_spawn_work',
    ).invokeDirect({'project': room.repoPath});
    expect(_okOf(spawn), isTrue, reason: spawn.message);
    expect(spawn.data['parentThreadId'], room.parentThreadId);

    // No active thread and no parentThreadId → a named refusal.
    room.service.clearActiveThread();
    final orphan = await _entry(
      'realm_chat_spawn_work',
    ).invokeDirect({'project': room.repoPath});
    expect(_okOf(orphan), isFalse);
    expect(orphan.data['error'], 'no_parent_thread');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('realm_project_access request + pending are honest per action',
      () async {
    final room = await _openRoom('pending');
    addTearDown(room.dispose);
    await room.world.registerActor('worker-a', displayName: 'Worker A');

    final requested = await _entry('realm_project_access').invokeDirect({
      'action': 'request',
      'actor': 'worker-a',
      'project': room.repoPath,
    });
    expect(_okOf(requested), isTrue, reason: requested.message);
    expect(requested.data['state'], 'pending');
    expect(requested.data['actor'], 'worker-a');

    final pending = await _entry(
      'realm_project_access',
    ).invokeDirect(const {'action': 'pending'});
    expect(_okOf(pending), isTrue, reason: pending.message);
    final rows = (pending.data['requests']! as List).cast<Map>();
    expect(rows, hasLength(1));
    expect(rows.single['actorId'], 'worker-a');
    expect(rows.single['projectId'], room.repoPath);
    expect(rows.single['state'], 'pending');

    // A grant without a project is a named refusal.
    final noProject = await _entry(
      'realm_project_access',
    ).invokeDirect(const {'action': 'grant'});
    expect(_okOf(noProject), isFalse);
    expect(noProject.data['hint'], contains('project is required'));

    // An unknown action refuses at the schema enum OR at the handler —
    // either way the message names the allowed moves.
    Object? refusal;
    try {
      final bad = await _entry('realm_project_access').invokeDirect(
        const {'action': 'frobnicate'},
      );
      expect(_okOf(bad), isFalse);
      final data = bad.data;
      refusal = '${bad.message}${data['hint'] ?? ''}${data['error'] ?? ''}';
    } on Object catch (error) {
      refusal = error.toString();
    }
    expect(refusal, contains('grant'), reason: 'names the allowed actions');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
