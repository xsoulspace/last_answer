import 'package:ecsly_flutter/ecsly_flutter.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/la_world/la_world_components.dart';
import 'package:lastanswer/la_world/la_world_feed.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// 1a — LaWorld: the journal folds into the in-process ecsly World
/// (cold scans + cursor deltas), the UI reads record snapshots through
/// selector-scoped rebuilds, and the projection NEVER writes back.
void main() {
  late Directory temp;
  late RealmControlStore store;
  late LaWorld laWorld;
  late LaWorldFeed feed;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('la_world_');
    final dir = Directory('${temp.path}/coordination');
    await dir.create(recursive: true);
    store = RealmControlStore(dir);
    laWorld = LaWorld(humanActorId: () => 'human-1');
    feed = LaWorldFeed(
      store: store,
      laWorld: laWorld,
      humanActorId: () => 'human-1',
    );
  });

  tearDown(() async {
    feed.stop();
    laWorld.dispose();
    await temp.delete(recursive: true);
  });

  Future<void> seedBasics() async {
    await store.transact((tx) {
      tx
        ..put('threads', 'thread-a', <String, Object?>{
          'threadId': 'thread-a',
          'projectId': null,
          'topic': 'the lounge',
          'createdBy': 'human-1',
          'createdAt': '2026-11-07T10:00:00Z',
          'closed': false,
          'participants': ['human-1', 'scout'],
          'lastBeat': 5,
        })
        ..put('threads', 'thread-b', <String, Object?>{
          'threadId': 'thread-b',
          'projectId': '/some/project',
          'topic': 'sealed room',
          'createdBy': 'scout',
          'createdAt': '2026-11-07T09:00:00Z',
          'closed': false,
          'participants': ['scout'],
          'lastBeat': 2,
        })
        ..put('thread_reads', 'human-1@thread-a', <String, Object?>{
          'actorId': 'human-1',
          'threadId': 'thread-a',
          'lastReadBeat': 3,
          'at': '2026-11-07T10:05:00Z',
        })
        ..put('thread_reads', 'scout@thread-a', <String, Object?>{
          'actorId': 'scout',
          'threadId': 'thread-a',
          'lastReadBeat': 0,
        })
        ..put('durable_tasks', 'task-1', <String, Object?>{
          'taskId': 'task-1',
          'state': 'started',
          'model': 'modelscope_qwen38max',
          'admittedAt': '2026-11-07T10:01:00Z',
          'startedAt': '2026-11-07T10:01:05Z',
          'payload': <String, Object?>{
            'prompt': 'fix the frozen-head bug',
            'addressees': ['scout'],
          },
        })
        ..put('tool_loop_telemetry', 'tl-old', <String, Object?>{
          'actorId': 'scout',
          'rounds': 2,
          'toolCalls': 3,
          'appliedWrites': 1,
          'promptTokens': 1000,
          'cachedTokens': 100,
          'completionTokens': 50,
          'stalled': false,
          'at': '2026-11-07T09:00:00Z',
        })
        ..put('tool_loop_telemetry', 'tl-new', <String, Object?>{
          'actorId': 'scout',
          'rounds': 7,
          'toolCalls': 12,
          'appliedWrites': 4,
          'promptTokens': 2000,
          'cachedTokens': 1680,
          'completionTokens': 200,
          'stalled': false,
          'at': '2026-11-07T10:02:00Z',
        })
        ..put('realm_actors', 'scout', <String, Object?>{
          'actorId': 'scout',
          'displayName': 'Scout',
          'actorKind': 'model',
          'brainCast': 'modelscope_qwen38max',
          'serves': ['conversation'],
        });
      return null;
    });
  }

  group('the cursor fold', () {
    test('cold start folds current state; deltas ride the cursor', () async {
      await seedBasics();
      await feed.start();

      // Rooms: both threads, activity-sorted (thread-a is newer).
      final rooms = laWorld.roomSnapshots();
      expect(rooms.map((r) => r.threadId).toList(), ['thread-a', 'thread-b']);
      final lounge = rooms.first;
      expect(lounge.topic, 'the lounge');
      expect(lounge.realmSealed, isTrue, reason: 'projectId null = realm room');
      expect(rooms.last.realmSealed, isFalse);

      // Unread = the Discord-law count from the HUMAN's receipt only
      // (scout's receipt is not this UI's business).
      expect(lounge.unread, 2);
      expect(laWorld.unreadByThread(), <String, int>{'thread-a': 2});

      // Tasks: the journal's own words, never invented.
      final tasks = laWorld.taskSnapshots();
      expect(tasks.single.taskId, 'task-1');
      expect(tasks.single.sentence, 'fix the frozen-head bug');
      expect(tasks.single.state, 'started');
      expect(tasks.single.modelId, 'modelscope_qwen38max');
      expect(tasks.single.addressees, 'scout');
      expect(tasks.single.terminal, isFalse);

      // Telemetry: newest per actor with the full row.
      final scout = laWorld.telemetryByActor()['scout']!.telemetry;
      expect(scout.rounds, 7);
      expect(scout.toolCalls, 12);
      expect(scout.appliedWrites, 4);
      expect(scout.cacheHitRate, closeTo(0.84, 0.001));

      // Actors.
      expect(laWorld.actorSnapshots().single.displayName, 'Scout');

      // A delta: new append folds through the cursor, one batch.
      final before = laWorld.batchRevision;
      await store.transact((tx) {
        tx.put('threads', 'thread-a', <String, Object?>{
          'threadId': 'thread-a',
          'projectId': null,
          'topic': 'the lounge',
          'createdBy': 'human-1',
          'createdAt': '2026-11-07T10:00:00Z',
          'closed': false,
          'participants': ['human-1', 'scout'],
          'lastBeat': 6,
        });
        return null;
      });
      await feed.drain();
      expect(laWorld.batchRevision, greaterThan(before));
      final updated = laWorld.roomSnapshots().first;
      expect(updated.lastBeat, 6);
      expect(updated.unread, 3);
    });

    test('a receipt advance drops the unread count reactively', () async {
      await seedBasics();
      await feed.start();
      expect(laWorld.unreadByThread()['thread-a'], 2);
      await store.transact((tx) {
        tx.put('thread_reads', 'human-1@thread-a', <String, Object?>{
          'actorId': 'human-1',
          'threadId': 'thread-a',
          'lastReadBeat': 5,
        });
        return null;
      });
      await feed.drain();
      expect(laWorld.unreadByThread().containsKey('thread-a'), isFalse);
      // Receipts never regress.
      await store.transact((tx) {
        tx.put('thread_reads', 'human-1@thread-a', <String, Object?>{
          'actorId': 'human-1',
          'threadId': 'thread-a',
          'lastReadBeat': 1,
        });
        return null;
      });
      await feed.drain();
      expect(laWorld.unreadByThread().containsKey('thread-a'), isFalse);
    });

    test('a terminal task settles with the journal summary', () async {
      await seedBasics();
      await feed.start();
      await store.transact((tx) {
        tx.put('durable_tasks', 'task-1', <String, Object?>{
          'taskId': 'task-1',
          'state': 'succeeded',
          'model': 'modelscope_qwen38max',
          'settledAt': '2026-11-07T10:30:00Z',
          'payload': <String, Object?>{
            'prompt': 'fix the frozen-head bug',
            'addressees': ['scout'],
          },
          'terminal': <String, Object?>{
            'state': 'succeeded',
            'at': '2026-11-07T10:30:00Z',
            'result': <String, Object?>{'summary': 'fixed; tests green'},
          },
        });
        return null;
      });
      await feed.drain();
      final task = laWorld.taskSnapshots().single;
      expect(task.terminal, isTrue);
      expect(task.state, 'succeeded');
      expect(task.summary, 'fixed; tests green');
      expect(task.at, '2026-11-07T10:30:00Z');
    });

    test('collections outside the closed set are ignored', () async {
      await seedBasics();
      await feed.start();
      final before = laWorld.batchRevision;
      await store.transact((tx) {
        tx.put('some_other_collection', 'x', <String, Object?>{'a': 1});
        return null;
      });
      await feed.drain();
      expect(laWorld.batchRevision, before, reason: 'no rows, no batch');
    });
  });

  group('the selector discipline', () {
    testWidgets(
      'an unchanged selection rebuilds nothing; a changed one '
      'rebuilds exactly its subscriber',
      (final tester) async {
        var builds = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: EcsWorldSelector<Map<String, int>>(
              world: laWorld.world,
              controller: laWorld.controller,
              select: (world) => laWorld.unreadByThread(),
              equals: mapEquals,
              builder: (context, value) {
                builds++;
                return Text(
                  'unread:${value.values.fold(0, (a, b) => a + b)}',
                  textDirection: TextDirection.ltr,
                );
              },
            ),
          ),
        );
        expect(builds, 1);
        expect(find.text('unread:0'), findsOneWidget);

        // A batch that does not change THIS selection: no rebuild.
        laWorld
          ..putTask(
            TaskRow(taskId: 'task-x', state: 'queued', sentence: 'other work'),
          )
          ..commitBatch();
        await tester.pump();
        expect(builds, 1, reason: 'selector-scoped: tasks ≠ unread');

        // A batch that does: exactly one rebuild with the new value.
        laWorld
          ..putRoom(
            RoomRow(
              threadId: 'thread-n',
              topic: 'new room',
              lastBeat: 4,
              participants: const ['human-1'],
            ),
          )
          ..commitBatch();
        await tester.pump();
        expect(builds, 2);
        expect(find.text('unread:4'), findsOneWidget);

        // Re-putting the SAME room state: selection unchanged, no
        // rebuild (the equality gate, not the notification, rules).
        laWorld
          ..putRoom(
            RoomRow(
              threadId: 'thread-n',
              topic: 'new room',
              lastBeat: 4,
              participants: const ['human-1'],
            ),
          )
          ..commitBatch();
        await tester.pump();
        expect(builds, 2);
      },
    );
  });
}
