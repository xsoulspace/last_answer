import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';

/// Unit contract tests for [MeshTaskBoard]: the op-mapping discipline
/// (one LWW op per field change), two-board convergence, the HLC
/// receive-watermark floor, snapshot recovery, and restore semantics for
/// compacted files.
///
/// No storage and no mesh here — the sync seams are exercised end-to-end
/// in `test/mesh_storage_task_board_test.dart`.

final _now = DateTime.utc(2026, 9, 6, 12);
final _later = DateTime.utc(2026, 9, 6, 12, 0, 1);
final _laterStill = DateTime.utc(2026, 9, 6, 12, 0, 2);

void main() {
  test('requestTask projects a requested row; pendingRequestsFor filters '
      'by dispatcher', () {
    final board = MeshTaskBoard(replicaId: 'device-a');
    final taskId = board.requestTask(
      docId: 'doc-1',
      task: 'refactor the parser',
      originPeerId: 'device-a',
      originActorId: 'afm-coder',
      now: _now,
    );

    expect(taskId, startsWith('doc-1#'));
    final record = board.taskOf(taskId)!;
    expect(record.taskId, taskId);
    expect(record.docId, 'doc-1');
    expect(record.task, 'refactor the parser');
    expect(record.status, MeshTaskBoard.statusRequested);
    expect(record.originPeerId, 'device-a');
    expect(record.originActorId, 'afm-coder');
    expect(record.createdAt, _now);
    expect(record.verdict, isNull);
    expect(board.tasksFor('doc-1'), [record]);
    expect(board.tasksFor('other-doc'), isEmpty);

    // A remote worker sees the request; the dispatcher does not pick up
    // its own.
    expect(board.pendingRequestsFor('doc-1', selfPeerId: 'device-b'), [record]);
    expect(board.pendingRequestsFor('doc-1', selfPeerId: 'device-a'), isEmpty);
  });

  test('lifecycle writes touch only the intended fields (one op per '
      'field change)', () {
    final board = MeshTaskBoard(replicaId: 'device-a');
    final id = board.requestTask(
      docId: 'doc-1',
      task: 'a',
      originPeerId: 'device-a',
      now: _now,
    );
    expect(board.pendingOps, hasLength(4)); // title, status, origin, createdAt

    board.markRunning(id, now: _later);
    expect(board.pendingOps, hasLength(5)); // status only
    expect(board.taskOf(id)!.status, MeshTaskBoard.statusRunning);

    board.completeTask(id, verdict: const {'tokens': 5}, now: _laterStill);
    expect(board.pendingOps, hasLength(7)); // status + verdict
    final done = board.taskOf(id)!;
    expect(done.status, MeshTaskBoard.statusCompleted);
    expect(done.verdict, const {'tokens': 5});

    final id2 = board.requestTask(
      docId: 'doc-1',
      task: 'b',
      originPeerId: 'device-a',
      now: _laterStill,
    );
    board.failTask(id2, error: 'boom', now: _laterStill);
    expect(board.pendingOps, hasLength(7 + 4 + 2)); // status + verdict
    final failed = board.taskOf(id2)!;
    expect(failed.status, MeshTaskBoard.statusFailed);
    expect(failed.verdict, const {'error': 'boom'});

    // failTask merges the error into an existing verdict.
    board.failTask(
      id2,
      error: 'late',
      verdict: const {'attempt': 2},
      now: _laterStill,
    );
    expect(board.taskOf(id2)!.verdict, const {'error': 'late', 'attempt': 2});
  });

  test('marking an absent or malformed task id fails loudly', () {
    final board = MeshTaskBoard(replicaId: 'device-a');
    expect(() => board.markRunning('no-hash'), throwsArgumentError);
    expect(() => board.markRunning('doc-1#unknown'), throwsStateError);
    expect(
      () => board.requestTask(docId: '', task: 'a', originPeerId: 'device-a'),
      throwsArgumentError,
    );
  });

  test('op exchange converges two boards; the later status write wins '
      'everywhere (LWW per field)', () {
    final a = MeshTaskBoard(replicaId: 'device-a');
    final b = MeshTaskBoard(replicaId: 'device-b');
    final id = a.requestTask(
      docId: 'doc-1',
      task: 'x',
      originPeerId: 'device-a',
      now: _now,
    );
    expect(b.applyRemote(a.opsSince(b.versionVector)), 4);
    expect(b.taskOf(id)!.status, MeshTaskBoard.statusRequested);

    b.markRunning(id, now: _later);
    expect(a.applyRemote(b.opsSince(a.versionVector)), 1);

    // Concurrent terminal writes: b's fail lands one second later, so it
    // wins the status register on BOTH boards; a's verdict write is
    // shadowed by b's later verdict write on the same register.
    a.completeTask(id, verdict: const {'tokens': 5}, now: _laterStill);
    b.failTask(
      id,
      error: 'boom',
      now: _laterStill.add(const Duration(seconds: 1)),
    );
    a.applyRemote(b.opsSince(a.versionVector));
    b.applyRemote(a.opsSince(b.versionVector));

    for (final board in [a, b]) {
      final record = board.taskOf(id)!;
      expect(
        record.status,
        MeshTaskBoard.statusFailed,
        reason: board.replicaId,
      );
      expect(record.verdict, const {'error': 'boom'}, reason: board.replicaId);
    }
    expect(
      a.tasksFor('doc-1').map((final r) => r.toJson()),
      b.tasksFor('doc-1').map((final r) => r.toJson()),
    );
  });

  test('HLC receive floor: a local write after folding ahead-of-clock '
      'remote ops still wins LWW', () {
    final ahead = _now.add(const Duration(seconds: 10));
    final a = MeshTaskBoard(replicaId: 'device-a');
    final b = MeshTaskBoard(replicaId: 'device-b');
    final id = a.requestTask(
      docId: 'doc-1',
      task: 'x',
      originPeerId: 'device-a',
      now: ahead, // Peer A's clock is 10s ahead of B's.
    );
    b.applyRemote(a.opsSince(b.versionVector));

    // B writes with its own (stale) wall clock; the receive floor must
    // lift the op above A's history or the causally-later write loses.
    b.markRunning(id, now: _now);
    expect(b.taskOf(id)!.status, MeshTaskBoard.statusRunning);

    // And the win propagates: A folds B's op and agrees.
    a.applyRemote(b.opsSince(a.versionVector));
    expect(a.taskOf(id)!.status, MeshTaskBoard.statusRunning);
  });

  test('compaction: 0 below the threshold, 1 above; tasks survive in the '
      'snapshot', () {
    final board = MeshTaskBoard(replicaId: 'device-a');
    final first = board.requestTask(
      docId: 'doc-1',
      task: 'first',
      originPeerId: 'device-a',
      now: _now,
    );
    expect(board.compact(), 0); // 4 ops — below the threshold.
    expect(board.pendingOps, isNotEmpty);

    // 130 more requests x 4 ops = 520 — above 512.
    for (var i = 0; i < 130; i++) {
      board.requestTask(
        docId: 'doc-batch',
        task: 'task $i',
        originPeerId: 'device-a',
        now: _later,
      );
    }
    expect(board.compact(), 1);
    expect(board.pendingOps, isEmpty);
    expect(board.taskOf(first)!.task, 'first');
    expect(board.tasksFor('doc-batch'), hasLength(130));

    // A compacted board serves lagging peers via its snapshot only.
    final fresh = MeshTaskBoard(replicaId: 'device-b');
    expect(fresh.applyRemote(board.opsSince(fresh.versionVector)), 0);
    expect(board.needsSnapshotFor(fresh.versionVector), isTrue);
    expect(fresh.adoptSnapshot(board.snapshotFor()), isTrue);
    expect(fresh.taskOf(first)!.task, 'first');
    expect(fresh.tasksFor('doc-batch'), hasLength(130));
  });

  test('fromJson restores a compacted board (snapshot-first) and keeps it '
      'participating', () {
    final board = MeshTaskBoard(replicaId: 'device-a');
    final first = board.requestTask(
      docId: 'doc-1',
      task: 'first',
      originPeerId: 'device-a',
      now: _now,
    );
    board.markRunning(first, now: _later);
    for (var i = 0; i < 130; i++) {
      board.requestTask(
        docId: 'doc-batch',
        task: 'task $i',
        originPeerId: 'device-a',
        now: _later,
      );
    }
    board.compact();
    final json = board.toJson();
    expect(json['snapshot'], isNotNull, reason: 'compaction took a snapshot');

    final restored = MeshTaskBoard.fromJson(json);
    expect(restored.replicaId, 'device-a');
    expect(restored.boardId, board.boardId);
    expect(restored.taskOf(first)!.status, MeshTaskBoard.statusRunning);
    expect(restored.tasksFor('doc-batch'), hasLength(130));
    expect(restored.pendingOps, isEmpty);

    // Still participating: new peer ops fold in, new local ids never
    // collide with pre-restore ones, and the receive floor survives.
    final peer = MeshTaskBoard(replicaId: 'device-b');
    final peerTask = peer.requestTask(
      docId: 'doc-1',
      task: 'from peer',
      originPeerId: 'device-b',
      now: _later,
    );
    expect(restored.applyRemote(peer.opsSince(restored.versionVector)), 4);
    expect(restored.taskOf(peerTask)!.task, 'from peer');

    final renewed = restored.requestTask(
      docId: 'doc-1',
      task: 'after restore',
      originPeerId: 'device-a',
      now: _later,
    );
    expect(renewed, isNot(first));
    expect(restored.taskOf(renewed)!.task, 'after restore');

    // The restored board still beats a stale-clock write on its own
    // state: the restored receive floor lifts the write above the peer
    // ops it just folded (peer's clock is ahead of `now` below).
    final aheadPeer = MeshTaskBoard(replicaId: 'device-c');
    final aheadTask = aheadPeer.requestTask(
      docId: 'doc-1',
      task: 'ahead',
      originPeerId: 'device-c',
      now: _now.add(const Duration(hours: 1)),
    );
    restored.applyRemote(aheadPeer.opsSince(restored.versionVector));
    restored.markRunning(aheadTask, now: _later);
    expect(restored.taskOf(aheadTask)!.status, MeshTaskBoard.statusRunning);
  });

  test('task-local ids are unique across requests and across boards with '
      'the same frozen clock', () {
    final board = MeshTaskBoard(replicaId: 'device-a', now: () => _now);
    final ids = {
      for (var i = 0; i < 50; i++)
        board.requestTask(
          docId: 'doc-1',
          task: 't $i',
          originPeerId: 'device-a',
        ),
    };
    expect(ids, hasLength(50));

    // Same frozen clock, different replica: the actor id in the HLC keeps
    // ids disjoint.
    final other = MeshTaskBoard(replicaId: 'device-b', now: () => _now);
    final otherId = other.requestTask(
      docId: 'doc-1',
      task: 't',
      originPeerId: 'device-b',
    );
    expect(ids.contains(otherId), isFalse);
  });

  test('records round-trip through JSON', () {
    final board = MeshTaskBoard(replicaId: 'device-a');
    final id = board.requestTask(
      docId: 'doc-1',
      task: 'x',
      originPeerId: 'device-a',
      originActorId: 'afm',
      now: _now,
    );
    board.failTask(id, error: 'boom', verdict: const {'tokens': 3}, now: _now);
    final roundTrip = MeshTaskRecord.fromJson(board.taskOf(id)!.toJson());
    expect(roundTrip.toJson(), board.taskOf(id)!.toJson());
  });

  test('tasksFor is deterministic: createdAt then taskId', () {
    final board = MeshTaskBoard(replicaId: 'device-a');
    final b = board.requestTask(
      docId: 'doc-1',
      task: 'b',
      originPeerId: 'device-a',
      now: _now,
    );
    final a = board.requestTask(
      docId: 'doc-1',
      task: 'a',
      originPeerId: 'device-a',
      now: _now,
    );
    final c = board.requestTask(
      docId: 'doc-1',
      task: 'c',
      originPeerId: 'device-a',
      now: _later,
    );
    // a and b share createdAt, so the taskId tiebreak orders them (b's
    // id carries the lower counter); c's later createdAt sorts last.
    expect(board.tasksFor('doc-1').map((final r) => r.taskId), [b, a, c]);
  });
}
