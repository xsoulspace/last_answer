import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/ecs_plugins/boards/lww_replica_core.dart';
import 'package:lastanswer/ecs_plugins/boards/mesh_task_board.dart';

/// Unit contract tests for [LwwReplicaCore] — the machinery
/// `MeshTaskBoard` and `PlanningBoardReplica` were collapsed onto
/// (the boards-extraction program, storage slice): the sync-key grammar
/// and entity fold, the HLC clocks (local-id monotonicity + the receive
/// floor), the restore discipline, and the snapshot/compaction windows.
///
/// The core is exercised through a minimal concrete replica; the two
/// real replicas' own suites pin their domain verbs and wire bytes on
/// top of the same shared paths.

/// A minimal concrete replica: the subclass contract of the core with
/// one namespace and no domain policy.
final class _TestReplica extends LwwReplicaCore {
  _TestReplica({
    required super.replicaId,
    super.boardId = 'test-board',
    super.now,
  });

  _TestReplica._(super.sync) : super.restored();

  /// Mirrors the real replicas' restore pattern (static-by-contract,
  /// same shape as [MeshTaskBoard.fromJson]).
  // ignore: prefer_constructors_over_static_methods
  static _TestReplica fromJson(final Map<String, Object?> json) =>
      _TestReplica._(LwwReplicaCore.restoredWorldOf(json))
        ..absorbRestoredFile(json);

  static const String _entityPrefix = 'thing/';
  static const String _component = 'thing';

  @override
  String get entityPrefix => _entityPrefix;

  @override
  String get component => _component;

  /// Writes one register (the verb the tests drive).
  void set(
    final String docId,
    final String localId,
    final String field,
    final Object? value, {
    final DateTime? now,
  }) => write(docId, localId, field, value, issueTime(now));
}

final _now = DateTime.utc(2026, 9, 6, 12);

void main() {
  group('compound ids', () {
    test('split at the LAST #; malformed shapes refuse', () {
      expect(LwwReplicaCore.splitCompoundId('doc-1#abc'), ('doc-1', 'abc'));
      expect(
        LwwReplicaCore.splitCompoundId('a/b#c#abc'),
        ('a/b#c', 'abc'),
      );
      expect(LwwReplicaCore.splitCompoundId('no-hash'), isNull);
      expect(LwwReplicaCore.splitCompoundId('#abc'), isNull);
      expect(LwwReplicaCore.splitCompoundId('doc-1#'), isNull);
    });
  });

  group('sync-key grammar', () {
    test('parseEntityKey accepts own keys, refuses foreign namespaces',
        () {
      final replica = _TestReplica(replicaId: 'peer-a');
      expect(
        replica.parseEntityKey('thing/doc-1/abc/thing/title'),
        ('doc-1', 'abc', 'title'),
      );
      // Doc ids may contain '/'; the doc/local split sits at the LAST
      // slash of the entity part.
      expect(
        replica.parseEntityKey('thing/a/b/abc/thing/title'),
        ('a/b', 'abc', 'title'),
      );
      // Foreign namespaces (the other replicas') parse as null.
      expect(replica.parseEntityKey('task/doc-1/abc/task/title'), isNull);
      expect(replica.parseEntityKey('card/b/1/card/title'), isNull);
      // Malformed shapes parse as null.
      expect(replica.parseEntityKey('thing//abc/thing/title'), isNull);
      expect(replica.parseEntityKey('thing/doc/abc/other/title'), isNull);
      expect(
        MeshTaskBoard(replicaId: 'peer-a').parseEntityKey(
          'thing/doc-1/abc/thing/title',
        ),
        isNull,
        reason: 'the task namespace must not read card/thing keys',
      );
    });

    test('foldEntityFields groups registers per entity, skipping nulls '
        'and foreign keys', () {
      final replica = _TestReplica(replicaId: 'peer-a');
      replica.set('doc-1', 'abc', 'title', 'hello', now: _now);
      replica.set('doc-1', 'abc', 'rank', 'm', now: _now);
      replica.set('doc-2', 'def', 'title', 'other', now: _now);
      final folded = replica.foldEntityFields();
      expect(folded.keys.toSet(), {'doc-1#abc', 'doc-2#def'});
      expect(folded['doc-1#abc'], {'title': 'hello', 'rank': 'm'});
    });
  });

  group('HLC clocks', () {
    test('local ids are strictly monotonic on a frozen clock and unique '
        'across replicas', () {
      final a = _TestReplica(replicaId: 'peer-a', now: () => _now);
      final b = _TestReplica(replicaId: 'peer-b', now: () => _now);
      final ids = {
        for (var i = 0; i < 20; i++)
          a.newLocalId(_now), // Frozen clock every tick.
      };
      expect(ids, hasLength(20));
      expect(ids.contains(b.newLocalId(_now)), isFalse);
    });

    test('the receive floor lifts a stale-clock write above the remote '
        'history it causally follows', () {
      final ahead = _TestReplica(replicaId: 'peer-a');
      final behind = _TestReplica(replicaId: 'peer-b');
      ahead.set(
        'doc-1',
        'abc',
        'title',
        'x',
        now: _now.add(const Duration(seconds: 10)),
      ); // Peer A's clock is 10s ahead of B's.
      behind.applyRemote(ahead.opsSince(behind.versionVector));

      // B writes with its own (stale) wall clock; the floor must lift
      // the op's HLC above A's history or the causally-later write loses.
      behind.set('doc-1', 'abc', 'title', 'y', now: _now);
      ahead.applyRemote(behind.opsSince(ahead.versionVector));
      expect(
        ahead.foldEntityFields()['doc-1#abc']?['title'],
        'y',
        reason: 'the causally-later (floored) write must win LWW',
      );
    });
  });

  group('restore discipline', () {
    test('restoredWorldOf refuses a missing world and a mismatched '
        'board id', () {
      expect(
        () => LwwReplicaCore.restoredWorldOf({'board_id': 'x'}),
        throwsArgumentError,
      );
      final board = _TestReplica(replicaId: 'peer-a');
      final json = board.toJson()..['board_id'] = 'other';
      expect(
        () => LwwReplicaCore.restoredWorldOf(json),
        throwsA(
          isA<ArgumentError>().having(
            (final e) => e.message,
            'message',
            contains('does not match the kernel doc id'),
          ),
        ),
      );
    });

    test('a compacted file restores purely from its snapshot and stays '
        'participating', () {
      final board = _TestReplica(replicaId: 'peer-a');
      board.set('doc-1', 'abc', 'title', 'first', now: _now);
      board.compact(maxLogOps: 0);
      expect(board.pendingOps, isEmpty);
      final json = board.toJson();

      final restored = _TestReplica.fromJson(json);
      expect(restored.boardId, 'test-board');
      expect(restored.replicaId, 'peer-a');
      // The snapshot is the only state carrier — and it recovers.
      expect(
        restored.foldEntityFields()['doc-1#abc']?['title'],
        'first',
      );
      expect(restored.pendingOps, isEmpty);

      // Still participating: peer ops fold in, new ids stay monotonic.
      final peer = _TestReplica(replicaId: 'peer-b');
      peer.set('doc-1', 'xyz', 'title', 'from peer', now: _now);
      expect(
        restored.applyRemote(peer.opsSince(restored.versionVector)),
        1,
      );
      expect(
        restored.foldEntityFields()['doc-1#xyz']?['title'],
        'from peer',
      );
      final renewed = restored.newLocalId(_now);
      expect(renewed, isNot('abc'));
    });

    test('a restore never lowers a watermark past the file content', () {
      final board = _TestReplica(replicaId: 'peer-a');
      board.set('doc-1', 'abc', 'title', 'x', now: _now);
      final json = board.toJson();

      final restored = _TestReplica.fromJson(json);
      // The restored receive floor (raised over the file's own log)
      // lifts a stale-clock write above a further ahead-clock op it
      // folds right after.
      final aheadPeer = _TestReplica(replicaId: 'peer-c');
      aheadPeer.set(
        'doc-1',
        'q',
        'title',
        'ahead',
        now: _now.add(const Duration(hours: 1)),
      );
      restored.applyRemote(aheadPeer.opsSince(restored.versionVector));
      restored.set('doc-1', 'q', 'title', 'mine', now: _now);
      aheadPeer.applyRemote(restored.opsSince(aheadPeer.versionVector));
      expect(
        aheadPeer.foldEntityFields()['doc-1#q']?['title'],
        'mine',
        reason: 'the floored write must win LWW on the ahead peer too',
      );
    });
  });

  group('snapshot + compaction windows', () {
    test('compaction: 0 below the threshold, 1 above', () {
      final board = _TestReplica(replicaId: 'peer-a');
      board.set('doc-1', 'abc', 'title', 'x', now: _now);
      expect(board.compact(), 0);
      for (var i = 0; i < 200; i++) {
        board.set('doc-1', 'e$i', 'title', 'x', now: _now);
      }
      expect(board.compact(maxLogOps: 100), 1);
      expect(board.pendingOps, isEmpty);
    });

    test('a taken snapshot is remembered under the snapshot key; a '
        'fresh peer needs it after compaction', () {
      final board = _TestReplica(replicaId: 'peer-a');
      board.set('doc-1', 'abc', 'title', 'x', now: _now);
      board.newLocalId(_now); // Issue one local id (ticks the clock).
      expect(board.toJson().keys.toSet(), {
        'board_id',
        'replica_id',
        'world',
        'issued_clock',
      }, reason: 'issue-only replicas persist the issued clock only');
      board.snapshotFor();
      expect(board.toJson().keys.toSet(), contains('snapshot'));

      board.compact(maxLogOps: 0);
      final fresh = _TestReplica(replicaId: 'peer-b');
      expect(fresh.applyRemote(board.opsSince(fresh.versionVector)), 0);
      expect(board.needsSnapshotFor(fresh.versionVector), isTrue);
      expect(fresh.adoptSnapshot(board.snapshotFor()), isTrue);
      expect(
        fresh.foldEntityFields()['doc-1#abc']?['title'],
        'x',
      );
    });
  });
}
