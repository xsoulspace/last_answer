import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';

/// Wire goldens for the mesh task board (the extraction program, stage 0).
///
/// The board's wire contract is FROZEN while the domain moves into
/// `ecsly_boards` (docs/design/ecsly-boards-extraction.md §4): the
/// multiplayer gates diff these exact bytes, and old files
/// (`task_boards/<boardId>.json`) must keep restoring. A change here is a
/// consciously versioned wire decision, never a refactor side effect.
void main() {
  final base = DateTime.fromMillisecondsSinceEpoch(1751658000000, isUtc: true);

  MeshTaskBoard board() => MeshTaskBoard(
    replicaId: 'peer-alpha',
    // boardId rides the pinned default ('agent_world' — key-schemes group).
    now: () => base,
  );

  group('record wire shape (the bytes the gates diff)', () {
    test('a requested row encodes its exact field order and values', () {
      final b = board();
      final taskId = b.requestTask(
        docId: 'doc-1',
        task: 'Summarize the document',
        originPeerId: 'peer-alpha',
        originActorId: 'actor-7',
      );

      expect(taskId, 'doc-1#1751658000000:0:peer-alpha');
      final record = b.taskOf(taskId)!;
      expect(
        jsonEncode(record.toJson()),
        // Byte-exact JSON: no spaces between the pinned fragments.
        // ignore: missing_whitespace_between_adjacent_strings
        '{"taskId":"doc-1#1751658000000:0:peer-alpha","docId":"doc-1",'
        // ignore: missing_whitespace_between_adjacent_strings
        '"task":"Summarize the document","status":"requested",'
        // ignore: missing_whitespace_between_adjacent_strings
        '"originPeerId":"peer-alpha","originActorId":"actor-7",'
        '"createdAtMs":1751658000000}',
      );
    });

    test('an origin-less writer omits origin keys; verdict rides last', () {
      final b = board();
      final taskId = b.requestTask(
        docId: 'doc-2',
        task: 'Task from an older writer',
        originPeerId: 'peer-beta',
      );
      b.completeTask(taskId, verdict: {'verdict': 'PASS', 'tokens': 4242});

      final record = b.taskOf(taskId)!;
      expect(record.originActorId, isNull);
      expect(
        jsonEncode(record.toJson()),
        // Byte-exact JSON: no spaces between the pinned fragments.
        // ignore: missing_whitespace_between_adjacent_strings
        '{"taskId":"doc-2#1751658000000:0:peer-alpha","docId":"doc-2",'
        // ignore: missing_whitespace_between_adjacent_strings
        '"task":"Task from an older writer","status":"completed",'
        // ignore: missing_whitespace_between_adjacent_strings
        '"originPeerId":"peer-beta","originActorId":null,'
        '"createdAtMs":1751658000000,'
        '"verdict":{"verdict":"PASS","tokens":4242}}',
      );
    });

    test('a failure lands the error inside the verdict register', () {
      final b = board();
      final taskId = b.requestTask(
        docId: 'doc-3',
        task: 'Failing task',
        originPeerId: 'peer-alpha',
      );
      b.failTask(taskId, error: 'the session refused');

      final record = b.taskOf(taskId)!;
      expect(record.status, 'failed');
      expect(
        jsonEncode(record.toJson()),
        // Byte-exact JSON: no spaces between the pinned fragments.
        // ignore: missing_whitespace_between_adjacent_strings
        '{"taskId":"doc-3#1751658000000:0:peer-alpha","docId":"doc-3",'
        // ignore: missing_whitespace_between_adjacent_strings
        '"task":"Failing task","status":"failed",'
        '"originPeerId":"peer-alpha","originActorId":null,'
        '"createdAtMs":1751658000000,'
        '"verdict":{"error":"the session refused"}}',
      );
    });
  });

  group('key schemes', () {
    test('the default board id is agent_world', () {
      expect(MeshTaskBoard.defaultBoardId, 'agent_world');
      expect(board().boardId, 'agent_world');
    });

    test('sync keys stay task/<docId>/<localId>/task/<field>', () {
      expect(MeshTaskBoard.entityRoot, 'task/');
      final b = board();
      final taskId = b.requestTask(
        docId: 'doc-1',
        task: 'key shape probe',
        originPeerId: 'peer-alpha',
      );
      final localId = taskId.split('#').last;
      final keys = b.pendingOps
          .map((final op) => op.payload['k'])
          .toSet();
      expect(keys, {
        'task/doc-1/$localId/task/title',
        'task/doc-1/$localId/task/status',
        'task/doc-1/$localId/task/origin',
        'task/doc-1/$localId/task/createdAt',
      });
    });

    test('statuses keep the requested/running/completed/failed vocabulary',
        () {
      expect(MeshTaskBoard.statusRequested, 'requested');
      expect(MeshTaskBoard.statusRunning, 'running');
      expect(MeshTaskBoard.statusCompleted, 'completed');
      expect(MeshTaskBoard.statusFailed, 'failed');
    });
  });

  group('board file shape (task_boards/<boardId>.json)', () {
    test('top-level keys follow the receive history of the board', () {
      final b = board();
      b.requestTask(
        docId: 'doc-1',
        task: 'persist me',
        originPeerId: 'peer-alpha',
      );
      // A board that has only ISSUED ops persists its issued clock but no
      // receive floor — there is no received history yet.
      final json = b.toJson();
      expect(
        json.keys.toSet(),
        {'board_id', 'replica_id', 'world', 'issued_clock'},
      );
      expect(json['board_id'], 'agent_world');
      expect(json['replica_id'], 'peer-alpha');

      // After folding a remote op the receive floor rides the file too.
      final remote = MeshTaskBoard(
        replicaId: 'peer-beta',
        now: () => base.add(const Duration(seconds: 5)),
      );
      remote.requestTask(
        docId: 'doc-1',
        task: 'from beta',
        originPeerId: 'peer-beta',
      );
      b.applyRemote(remote.opsSince(b.versionVector));
      expect(b.toJson().keys.toSet(), contains('received_clock'));
    });

    test('a taken snapshot is remembered under the snapshot key', () {
      final b = board();
      b.requestTask(
        docId: 'doc-1',
        task: 'persist me',
        originPeerId: 'peer-alpha',
      );
      b.snapshotFor();
      expect(b.toJson().keys.toSet(), contains('snapshot'));
    });

    test('a written file restores records, clocks, and further writes', () {
      final b = board();
      final first = b.requestTask(
        docId: 'doc-1',
        task: 'one',
        originPeerId: 'peer-alpha',
      );
      b.markRunning(first, now: base.add(const Duration(seconds: 1)));
      final fileJson = b.toJson();

      final restored = MeshTaskBoard.fromJson(fileJson);
      expect(restored.boardId, 'agent_world');
      expect(restored.replicaId, 'peer-alpha');
      expect(restored.allRecords.single.taskId, first);
      expect(restored.allRecords.single.status, 'running');

      // The restored board stays a live replica: new ids stay monotonic
      // past the file's own clock, and the new record round-trips.
      final second = restored.requestTask(
        docId: 'doc-1',
        task: 'two',
        originPeerId: 'peer-alpha',
        now: base,
      );
      expect(second, isNot(first));
      // Restore folds the file's own log into the receive watermark, so
      // the rewritten file carries received_clock even though the
      // original never did — a raise-only, semantics-preserving growth.
      final rewritten = restored.toJson();
      expect(
        rewritten.keys.toSet(),
        {...fileJson.keys, 'received_clock'},
      );
      expect(
        MeshTaskBoard.fromJson(rewritten).allRecords.length,
        2,
      );
    });

    test('a compacted file restores purely from its snapshot', () {
      final b = board();
      final taskId = b.requestTask(
        docId: 'doc-1',
        task: 'compact me',
        originPeerId: 'peer-alpha',
      );
      b.compact(maxLogOps: 0);
      expect(b.pendingOps, isEmpty);

      final restored = MeshTaskBoard.fromJson(b.toJson());
      final record = restored.taskOf(taskId);
      expect(record, isNotNull);
      expect(record!.task, 'compact me');
      expect(record.status, 'requested');
    });
  });

  group('record decode tolerance', () {
    test('a malformed row reads as its defaults, not a crash', () {
      final record = MeshTaskRecord.fromJson(const {
        'taskId': 42,
        'status': null,
      });
      expect(record.taskId, '');
      expect(record.docId, '');
      expect(record.task, '');
      expect(record.status, '');
      expect(record.createdAt.millisecondsSinceEpoch, 0);
      expect(record.originPeerId, isNull);
      expect(record.verdict, isNull);
    });
  });
}
