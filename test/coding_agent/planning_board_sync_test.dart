import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/planning_board_replica.dart';

/// The planning board's sync lane: the replica contract (ops, board
/// order, restore) and two-replica convergence over one exchange —
/// the MeshTaskBoard disciplines, on the card namespace.
void main() {
  final base = DateTime.fromMillisecondsSinceEpoch(1751658000000, isUtc: true);

  PlanningBoardReplica board(
    final String replicaId, {
    final DateTime Function()? now,
  }) => PlanningBoardReplica(
    replicaId: replicaId,
    boardId: 'product',
    now: now ?? () => base,
  );

  group('replica contract', () {
    test('add writes one op per field; reads project the fold', () {
      final b = board('peer-a');
      final id = b.addCard(title: 'ship the sync lane', column: 'doing');
      // title + status + column + createdAt (no rank/parent ops when
      // unranked top-level).
      expect(b.pendingOps, hasLength(4));
      final card = b.cardOf(id)!;
      expect(card.title, 'ship the sync lane');
      expect(card.status, 'requested');
      expect(card.column, 'doing');
      expect(card.rank, isEmpty);
      expect(card.parent, isEmpty);
    });

    test('placeCard reorders; unranked sorts last', () {
      final b = board('peer-a');
      final a = b.addCard(title: 'a', column: 'backlog', rank: 'b');
      final c = b.addCard(title: 'c', column: 'backlog', rank: 'd');
      final top = b.addCard(title: 'top', column: 'backlog');
      final bottom = b.addCard(title: 'bottom', column: 'backlog');
      expect(
        b.cardsForColumn('backlog').map((final card) => card.title),
        ['a', 'c', 'top', 'bottom'],
      );
      // Insert between a and c.
      b.placeCard(cardId: top, column: 'backlog', rank: 'c');
      expect(
        b.cardsForColumn('backlog').map((final card) => card.title),
        ['a', 'top', 'c', 'bottom'],
      );
      expect(b.cardOf(a)!.rank, 'b');
      expect(b.cardOf(c)!.rank, 'd');
    });

    test('settle moves the status register only', () {
      final b = board('peer-a');
      final id = b.addCard(title: 'x', column: 'doing');
      final before = b.pendingOps.length;
      b.settle(cardId: id, status: 'completed');
      expect(b.pendingOps.length, before + 1);
      expect(b.cardOf(id)!.status, 'completed');
    });

    test('children ride the parent register and read back grouped', () {
      final b = board('peer-a');
      final parent = b.addCard(title: 'plan', column: 'backlog');
      final child = b.addCard(
        title: 'step',
        column: 'backlog',
        parent: parent,
      );
      expect(b.childrenOf(parent).single.cardId, child);
      expect(b.childrenOf(child), isEmpty);
    });

    test('decomposition into a foreign column is impossible to confuse',
        () {
      final b = board('peer-a');
      final parent = b.addCard(title: 'plan', column: 'backlog');
      b.addCard(title: 'step in doing', column: 'doing', parent: parent);
      expect(b.childrenOf(parent).single.column, 'doing');
    });
  });

  group('restore + convergence', () {
    test('a written file restores cards, clocks, and further writes', () {
      final b = board('peer-a');
      final first = b.addCard(title: 'one', column: 'backlog');
      b.settle(cardId: first, status: 'completed');
      final fileJson = b.toJson();

      final restored = PlanningBoardReplica.fromJson(fileJson);
      expect(restored.boardId, 'product');
      expect(restored.allCards.single.cardId, first);
      expect(restored.allCards.single.status, 'completed');

      // Monotonic local ids past the file's own clock.
      final second = restored.addCard(title: 'two', column: 'backlog');
      expect(second, isNot(first));
      expect(
        PlanningBoardReplica.fromJson(restored.toJson()).allCards.length,
        2,
      );
    });

    test('one whole-file exchange converges two replicas', () {
      final owner = board('owner-peer');
      final peer = board(
        'device-a',
        now: () => base.add(const Duration(seconds: 1)),
      );
      peer.addCard(title: 'from the peer', column: 'backlog', rank: 'm');
      owner.addCard(title: 'from the owner', column: 'doing', rank: 'a');

      // The exchange: each side folds the other's ops (absorb order is
      // free — the kernel's LWW converges per field).
      peer.applyRemote(owner.opsSince(peer.versionVector));
      owner.applyRemote(peer.opsSince(owner.versionVector));

      expect(owner.allCards.map((final c) => c.title).toSet(),
          {'from the peer', 'from the owner'});
      expect(peer.allCards.map((final c) => c.title).toSet(),
          {'from the peer', 'from the owner'});
      expect(
        owner.allCards.map((final c) => c.status).toSet(),
        peer.allCards.map((final c) => c.status).toSet(),
      );
    });

    test('a concurrent rank edit converges per field (LWW)', () {
      final a = board('peer-a');
      final b = board('peer-b', now: () => base.add(const Duration(hours: 1)));
      final id = a.addCard(title: 'moved', column: 'backlog', rank: 'm');
      b.applyRemote(a.opsSince(b.versionVector));

      // Both move the SAME card to different ranks; the later wall
      // clock wins everywhere.
      a.placeCard(cardId: id, column: 'backlog', rank: 'aa');
      b.placeCard(cardId: id, column: 'backlog', rank: 'zz');
      a.applyRemote(b.opsSince(a.versionVector));
      b.applyRemote(a.opsSince(b.versionVector));

      expect(a.cardOf(id)!.rank, 'zz');
      expect(b.cardOf(id)!.rank, 'zz');
    });

    test('the wire JSON decodes through the record (tolerant read)', () {
      final record = PlanningCardRecord.fromJson(const {
        'cardId': 'product#x',
        'title': 42,
        'status': null,
      });
      expect(record.cardId, 'product#x');
      expect(record.title, '');
      expect(record.status, 'requested');
      expect(record.column, isEmpty);
      expect(jsonEncode(record.toJson()), contains('"createdAtMs":0'));
    });
  });
}
