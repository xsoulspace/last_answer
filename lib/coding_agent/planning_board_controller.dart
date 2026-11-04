/// The planning board controller: the view's facade over the
/// [PlanningBoardReplica] — the mesh-synced durable store (the boards
/// program's sync lane). Ops write replica ops (one per field);
/// reads project the fold in board order.
///
/// Storage law: the replica rides the mesh cycle exactly like the task
/// board (`planning_boards/<boardId>.json`, snapshot-first absorb);
/// `package:ecsly_boards` remains the MODEL — the canonical status
/// vocabulary and the fractional-rank discipline ([rankBetween]) this
/// controller composes.
///
/// A controller without an injected replica owns a fresh in-memory one
/// (session-scoped; it persists once it rides a mesh cycle).
library;

import 'package:ecsly_boards/ecsly_boards.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/coding_agent/planning_board_replica.dart';

/// The default columns a new board shows. Free-form strings — the UI
/// names lanes, the model carries them.
const List<String> kDefaultBoardColumns = <String>['backlog', 'doing', 'done'];

/// One board's facade: spawn, place, decompose, settle.
final class PlanningBoardController extends ChangeNotifier {
  PlanningBoardController({
    PlanningBoardReplica? replica,
    this.columns = kDefaultBoardColumns,
  }) : replica = replica ?? PlanningBoardReplica(replicaId: 'local');

  /// The durable replica (authority + wire).
  final PlanningBoardReplica replica;

  final List<String> columns;

  /// Every card of [column] in board order (rank, then createdAt).
  List<PlanningCardRecord> cardsOf(final String column) =>
      replica.cardsForColumn(column);

  /// Every card on the board.
  List<PlanningCardRecord> get allCards => replica.allCards;

  /// Adds one card to the END of [column]; returns its id.
  String addCard({required final String title, required final String column}) {
    final last = replica.cardsForColumn(column).lastOrNull;
    final lastRank = last == null || last.rank.isEmpty ? null : last.rank;
    final id = replica.addCard(
      title: title,
      column: column,
      rank: rankBetween(lastRank, null),
    );
    notifyListeners();
    return id;
  }

  /// Moves a card to [column], inserted AFTER [afterKey] (null → the
  /// top of the column). Returns false when the card is absent.
  bool moveCard({
    required final String cardId,
    required final String column,
    final String? afterKey,
  }) {
    final columnCards = replica.cardsForColumn(column);
    final index = afterKey == null
        ? null
        : columnCards.indexWhere((final card) => card.cardId == afterKey);
    String? rankOf(final PlanningCardRecord card) =>
        card.rank.isEmpty ? null : card.rank;
    final before = index == null ? null : rankOf(columnCards[index]);
    final after = index == null
        ? (columnCards.firstOrNull == null
              ? null
              : rankOf(columnCards.first))
        : (index + 1 < columnCards.length
              ? rankOf(columnCards[index + 1])
              : null);
    replica.placeCard(
      cardId: cardId,
      column: column,
      rank: rankBetween(before, after),
    );
    notifyListeners();
    return true;
  }

  /// Decomposes [parentCardId]: adds ranked children (appended in
  /// order) in the parent's column.
  List<String> addChildren({
    required final String parentCardId,
    required final List<String> childTitles,
  }) {
    final parent = replica.cardOf(parentCardId);
    if (parent == null) return const [];
    final ids = <String>[];
    for (final title in childTitles) {
      final column = parent.column.isEmpty ? columns.first : parent.column;
      final last = replica.cardsForColumn(column).lastOrNull;
      final lastRank = last == null || last.rank.isEmpty ? null : last.rank;
      ids.add(
        replica.addCard(
          title: title,
          column: column,
          rank: rankBetween(lastRank, null),
          parent: parentCardId,
        ),
      );
    }
    notifyListeners();
    return ids;
  }

  /// Settles a card in the canonical vocabulary (done = completed).
  void settle({
    required final String cardId,
    required final BoardTaskStatus status,
  }) {
    replica.settle(cardId: cardId, status: status.name);
    notifyListeners();
  }
}
