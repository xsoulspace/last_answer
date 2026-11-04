/// The planning board controller: a session-scoped planning World over
/// the `ecsly_boards` ontology — the product face of the boards
/// program (stage 4).
///
/// Storage law, stated honestly: this first landing is LOCAL-FIRST
/// ONLY — the World lives in memory, `package:ecsly_boards` is the
/// model, and the cross-device sync lane (a convergence replica per
/// board, the way `MeshTaskBoard` rides the mesh) is the NEXT program.
/// Nothing here reaches for a server.
///
/// Vocabulary law: planning cards use the SAME canonical
/// [BoardTaskStatus] and the SAME substrate as delegation rows — plans
/// are parent cards with ranked children (`orderedChildren`), never a
/// parallel model.
library;

import 'package:ecsly/ecsly.dart';
import 'package:ecsly_boards/ecsly_boards.dart';
import 'package:flutter/foundation.dart';

/// The default columns a new board shows. Free-form strings — the UI
/// names lanes, the ontology carries them.
const List<String> kDefaultBoardColumns = <String>['backlog', 'doing', 'done'];

/// One board's working model: spawn, place, decompose, settle — each
/// op through the package's substrate, notifications for the view.
final class PlanningBoardController extends ChangeNotifier {
  PlanningBoardController({
    this.boardId = 'product',
    this.columns = kDefaultBoardColumns,
  }) : _world = World()..addPlugin(const BoardsPlugin());

  final World _world;
  final String boardId;
  final List<String> columns;

  int _counter = 0;

  /// Every card of [column] in board order (rank, then createdAt).
  List<BoardCardView> cardsOf(final String column) => cardsOfColumn(
    _world,
    board: boardId,
    column: column,
  );

  /// Adds one card to the END of [column]; returns its key.
  String addCard({required final String title, required final String column}) {
    final key = 'card/$boardId/${_counter++}';
    final last = cardsOf(column).lastOrNull;
    spawnCard(
      _world,
      key: key,
      board: boardId,
      title: title,
      status: BoardTaskStatus.requested,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      column: column,
      rank: rankBetween(last?.rank, null),
    );
    _world.flush();
    notifyListeners();
    return key;
  }

  /// Moves a card to [column], inserted AFTER [afterKey] (null → the
  /// top of the column). Returns false when the card is absent.
  bool moveCard({
    required final String key,
    required final String column,
    final String? afterKey,
  }) {
    final columnCards = cardsOf(column);
    final index = afterKey == null
        ? null
        : columnCards.indexWhere((final card) => card.key == afterKey);
    final before = index == null ? null : columnCards[index].rank;
    final after = index == null
        ? columnCards.firstOrNull?.rank
        : (index + 1 < columnCards.length ? columnCards[index + 1].rank : null);
    final placed = placeCard(
      _world,
      key,
      column: column,
      rank: rankBetween(before, after),
    );
    if (placed) {
      _world.flush();
      notifyListeners();
    }
    return placed;
  }

  /// Decomposes [parentKey]: adds ranked children (appended in
  /// order) — the package's `decompose` does the graph write.
  List<String> addChildren({
    required final String parentKey,
    required final List<String> childTitles,
  }) {
    final parent = cardOf(_world, parentKey);
    if (parent == null) return const [];
    final keys = <String>[];
    for (final title in childTitles) {
      final key = 'card/$boardId/${_counter++}';
      decompose(
        _world,
        parent.entity,
        [
          CardSpec(
            key: key,
            board: boardId,
            title: title,
            createdAtMs: DateTime.now().millisecondsSinceEpoch,
          ),
        ],
      );
      final targetColumn = parent.column ?? columns.first;
      placeCard(
        _world,
        key,
        column: targetColumn,
        rank: rankBetween(cardsOf(targetColumn).lastOrNull?.rank, null),
      );
      keys.add(key);
    }
    _world.flush();
    notifyListeners();
    return keys;
  }

  /// Settles a card in the canonical vocabulary (done = completed).
  void settle({
    required final String key,
    required final BoardTaskStatus status,
  }) {
    if (settleCard(_world, key, to: status)) {
      _world.flush();
      notifyListeners();
    }
  }
}
