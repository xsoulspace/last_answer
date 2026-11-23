/// The planning board replica: durable board/plan content riding the
/// mesh exactly like the task board (the boards program's sync lane) —
/// kernel ops under a whole-file exchange
/// (`planning_boards/<boardId>.json`), never a hand merge.
///
/// One board = ONE [WorldSync] replica (kernel `ConvergenceDoc`, LWW
/// map, ADR 0011) whose doc id is the board id, through the shared
/// [LwwReplicaCore] (key/HLC-clock/absorb machinery, restore discipline,
/// sync seams — the exact `MeshTaskBoard` discipline; see the core's
/// library doc for the causality reasoning). Every card field is one
/// keyed register, one op per field change:
///
/// - entity key: `card/<boardId>/<cardLocalId>`, component `card`;
/// - fields: `title`, `status` (the canonical [BoardTaskStatus]
///   vocabulary from `package:ecsly_boards`), `column`, `rank`
///   (lexicographic, the package's fractional-indexing discipline),
///   `parent` (the full parent card key, '' when top-level),
///   `createdAt` (epoch ms int).
///
/// Task ids/keys: `<boardId>#<cardLocalId>`, HLC-derived (per-board
/// issued clock, receive-watermark floor). Card ids must not contain
/// `#`-less local ids (ids split at the LAST `#`).
///
/// The MODEL vocabulary (statuses, rank ordering) lives in
/// `package:ecsly_boards`; this replica is the durable wire store —
/// the projection the unified boards view renders.
library;

import 'package:ecsly_world_sync/ecsly_world_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/ecs_plugins/boards/lww_replica_core.dart';

/// Immutable read record projected from the planning board's fold.
@immutable
final class PlanningCardRecord {
  const PlanningCardRecord({
    required this.cardId,
    required this.boardId,
    required this.title,
    required this.status,
    required this.column,
    required this.rank,
    required this.parent,
    required this.createdAt,
  });

  /// Tolerant read: a malformed field reads as its default (DESIGN §6).
  // Static-by-contract (the planning board's public API surface).
  // ignore: prefer_constructors_over_static_methods
  static PlanningCardRecord fromJson(final Map<String, Object?> json) {
    final cardId = json['cardId'];
    final boardId = json['boardId'];
    final title = json['title'];
    final status = json['status'];
    final column = json['column'];
    final rank = json['rank'];
    final parent = json['parent'];
    final createdAtMs = json['createdAtMs'];
    return PlanningCardRecord(
      cardId: cardId is String ? cardId : '',
      boardId: boardId is String ? boardId : '',
      title: title is String ? title : '',
      status: status is String ? status : 'requested',
      column: column is String ? column : '',
      rank: rank is String ? rank : '',
      parent: parent is String ? parent : '',
      createdAt: createdAtMs is int
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMs, isUtc: true)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String cardId;

  /// Board id (the kernel doc id).
  final String boardId;
  final String title;

  /// The canonical `BoardTaskStatus` name.
  final String status;
  final String column;

  /// Lexicographic rank within the column; '' = unranked (sorts last).
  final String rank;

  /// The parent card's full key ('' = top-level).
  final String parent;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'cardId': cardId,
    'boardId': boardId,
    'title': title,
    'status': status,
    'column': column,
    'rank': rank,
    'parent': parent,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
  };

  @override
  String toString() =>
      'PlanningCardRecord($cardId, $status, $column, $rank)';

  @override
  bool operator ==(final Object other) =>
      other is PlanningCardRecord &&
      other.cardId == cardId &&
      other.boardId == boardId &&
      other.title == title &&
      other.status == status &&
      other.column == column &&
      other.rank == rank &&
      other.parent == parent &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    cardId,
    boardId,
    title,
    status,
    column,
    rank,
    parent,
    createdAt,
  );
}

/// One shared planning board over [WorldSync]; see the library doc and
/// [LwwReplicaCore] for the shared machinery.
final class PlanningBoardReplica extends LwwReplicaCore {
  /// Creates a replica owned by [replicaId] (the mesh peer id).
  PlanningBoardReplica({
    required super.replicaId,
    super.boardId = defaultBoardId,
    super.now,
  });

  /// Restores a replica previously written by [toJson] — the shared
  /// [LwwReplicaCore] restore discipline (kernel state as-is, snapshot
  /// adopted, clocks recomputed raise-only; see
  /// [LwwReplicaCore.absorbRestoredFile]).
  factory PlanningBoardReplica.fromJson(final Map<String, Object?> json) =>
      PlanningBoardReplica._(LwwReplicaCore.restoredWorldOf(json))
        ..absorbRestoredFile(json);

  PlanningBoardReplica._(super.sync) : super.restored();

  /// Default board id (and kernel doc id).
  static const String defaultBoardId = 'product';

  static const String _entityPrefix = 'card/';
  static const String _component = 'card';
  static const String _fieldTitle = 'title';
  static const String _fieldStatus = 'status';
  static const String _fieldColumn = 'column';
  static const String _fieldRank = 'rank';
  static const String _fieldParent = 'parent';
  static const String _fieldCreatedAt = 'createdAt';

  @override
  String get entityPrefix => _entityPrefix;

  @override
  String get component => _component;

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  /// Every card of [column] in board order — rank (unranked last),
  /// then createdAt, then cardId: deterministic on every replica.
  List<PlanningCardRecord> cardsForColumn(final String column) => _sorted(
    _allRecords()
        .where((final record) => record.column == column)
        .toList(),
  );

  /// Every card on the board, same deterministic order.
  List<PlanningCardRecord> get allCards => _sorted(_allRecords());

  /// The folded record for [cardId]; null when absent.
  PlanningCardRecord? cardOf(final String cardId) {
    for (final record in _allRecords()) {
      if (record.cardId == cardId) return record;
    }
    return null;
  }

  /// The children of [parentKey] in board order (rank, then time).
  List<PlanningCardRecord> childrenOf(final String parentKey) => _sorted(
    _allRecords().where((final record) => record.parent == parentKey).toList(),
  );

  // ---------------------------------------------------------------------------
  // Local writes (one op per field change)
  // ---------------------------------------------------------------------------

  /// Adds a card and returns its id. [rank] '' = unranked (sorts
  /// last); [parent] '' = top-level.
  String addCard({
    required final String title,
    required final String column,
    final String status = 'requested',
    final String rank = '',
    final String parent = '',
    final DateTime? now,
  }) {
    if (title.isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be empty');
    }
    final at = issueTime(now);
    final localId = newLocalId(at);
    write(boardId, localId, _fieldTitle, title, at);
    write(boardId, localId, _fieldStatus, status, at);
    write(boardId, localId, _fieldColumn, column, at);
    if (rank.isNotEmpty) {
      write(boardId, localId, _fieldRank, rank, at);
    }
    if (parent.isNotEmpty) {
      write(boardId, localId, _fieldParent, parent, at);
    }
    write(boardId, localId, _fieldCreatedAt, at.millisecondsSinceEpoch, at);
    return _cardIdOf(localId);
  }

  /// Places a card: column and/or rank (the reorder op). Throws
  /// [StateError] when the card is absent — there is nothing to move.
  void placeCard({
    required final String cardId,
    final String? column,
    final String? rank,
    final DateTime? now,
  }) {
    final localId = _requireLocalId(cardId);
    final at = issueTime(now);
    if (column != null) {
      write(boardId, localId, _fieldColumn, column, at);
    }
    if (rank != null) {
      write(boardId, localId, _fieldRank, rank, at);
    }
  }

  /// Settles a card to [status] (one status op).
  void settle({
    required final String cardId,
    required final String status,
    final DateTime? now,
  }) {
    final localId = _requireLocalId(cardId);
    write(boardId, localId, _fieldStatus, status, issueTime(now));
  }

  // ---------------------------------------------------------------------------
  // Internals (the card namespace over the shared core)
  // ---------------------------------------------------------------------------

  String _cardIdOf(final String localId) => '$boardId#$localId';

  /// The local id of [cardId], refusing malformed ids and absent cards
  /// with the same honesty: there is nothing to write.
  String _requireLocalId(final String cardId) {
    final localId = LwwReplicaCore.splitCompoundId(cardId)?.$2;
    if (localId == null || _recordOf(localId) == null) {
      throw StateError('card $cardId is not on this board (absent)');
    }
    return localId;
  }

  List<PlanningCardRecord> _allRecords() {
    final fieldsByCard = foldEntityFields();
    final records = <PlanningCardRecord>[];
    for (final entry in fieldsByCard.entries) {
      final fields = entry.value;
      final title = fields[_fieldTitle];
      final createdAt = fields[_fieldCreatedAt];
      if (title is! String || createdAt is! int) continue;
      final cardId = entry.key;
      records.add(
        PlanningCardRecord(
          cardId: cardId,
          boardId: cardId.substring(0, cardId.lastIndexOf('#')),
          title: title,
          status: fields[_fieldStatus] is String
              ? fields[_fieldStatus]! as String
              : 'requested',
          column: fields[_fieldColumn] is String
              ? fields[_fieldColumn]! as String
              : '',
          rank: fields[_fieldRank] is String ? fields[_fieldRank]! as String : '',
          parent: fields[_fieldParent] is String
              ? fields[_fieldParent]! as String
              : '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
        ),
      );
    }
    return _sorted(records);
  }

  PlanningCardRecord? _recordOf(final String localId) {
    for (final record in _allRecords()) {
      if (record.cardId == _cardIdOf(localId)) return record;
    }
    return null;
  }

  static List<PlanningCardRecord> _sorted(
    final List<PlanningCardRecord> records,
  ) => records..sort((final a, final b) {
    // Unranked sorts last (the column view's law).
    if ((a.rank.isEmpty) != (b.rank.isEmpty)) {
      return a.rank.isEmpty ? 1 : -1;
    }
    final byRank = a.rank.compareTo(b.rank);
    if (byRank != 0) return byRank;
    final byTime = a.createdAt.compareTo(b.createdAt);
    if (byTime != 0) return byTime;
    return a.cardId.compareTo(b.cardId);
  });
}
