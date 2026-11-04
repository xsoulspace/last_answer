/// The planning board replica: durable board/plan content riding the
/// mesh exactly like the task board (the boards program's sync lane) —
/// kernel ops under a whole-file exchange
/// (`planning_boards/<boardId>.json`), never a hand merge.
///
/// One board = ONE [WorldSync] replica (kernel `ConvergenceDoc`, LWW
/// map, ADR 0011) whose doc id is the board id. Every card field is
/// one keyed register, one op per field change:
///
/// - entity key: `card/<boardId>/<cardLocalId>`, component `card`;
/// - fields: `title`, `status` (the canonical [BoardTaskStatus]
///   vocabulary from `package:ecsly_boards`), `column`, `rank`
///   (lexicographic, the package's fractional-indexing discipline),
///   `parent` (the full parent card key, '' when top-level),
///   `createdAt` (epoch ms int).
///
/// Task ids/keys: `<boardId>#<cardLocalId>`. `cardLocalId` is
/// HLC-derived (per-board issued clock, receive-watermark floor) — the
/// exact discipline of [MeshTaskBoard], see its library doc for the
/// causality reasoning. Card ids must not contain `#`-less local ids
/// (ids split at the LAST `#`).
///
/// The MODEL vocabulary (statuses, rank ordering) lives in
/// `package:ecsly_boards`; this replica is the durable wire store —
/// the projection the unified boards view renders.
library;

import 'package:collection/collection.dart';
import 'package:ecsly_world_sync/ecsly_world_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_storage_convergence/universal_storage_convergence.dart';

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

/// One shared planning board over [WorldSync]; see the library doc.
final class PlanningBoardReplica {
  /// Creates a replica owned by [replicaId] (the mesh peer id).
  PlanningBoardReplica({
    required final String replicaId,
    final String boardId = defaultBoardId,
    final DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       _sync = WorldSync(actorId: replicaId, docId: boardId);

  /// Restores a replica previously written by [toJson] — the proven
  /// restore discipline (kernel state as-is, snapshot adopted, clocks
  /// recomputed raise-only); see [MeshTaskBoard.fromJson].
  factory PlanningBoardReplica.fromJson(final Map<String, Object?> json) {
    final worldJson = json['world'];
    if (worldJson is! Map) {
      throw ArgumentError.value(json, 'json', 'missing world state');
    }
    final sync = WorldSync.fromJson(Map<String, dynamic>.from(worldJson));
    final replica = PlanningBoardReplica._(sync);
    final boardId = json['board_id'];
    if (boardId is String && boardId != sync.docId) {
      throw ArgumentError.value(
        boardId,
        'board_id',
        'does not match the kernel doc id ${sync.docId}',
      );
    }
    final snapshotJson = json['snapshot'];
    if (snapshotJson is Map) {
      replica.adoptSnapshot(
        Snapshot.fromJson(Map<String, dynamic>.from(snapshotJson)),
      );
    }
    final issued = _hlcOf(json['issued_clock']);
    if (issued != null) replica._raiseIssued(issued);
    final received = _hlcOf(json['received_clock']);
    if (received != null) replica._absorbReceived(received);
    for (final op in sync.pendingOps) {
      replica._absorbReceived(op.hlc);
      if (op.actorId == replica.replicaId) replica._raiseIssued(op.hlc);
    }
    return replica;
  }

  PlanningBoardReplica._(this._sync, {final DateTime Function()? now})
    : _now = now ?? DateTime.now;

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

  final WorldSync _sync;
  final DateTime Function() _now;

  /// Receive-watermark floor (HLC causality; see library doc).
  Hlc? _receivedWatermark;

  /// This replica's own-actor HLC, ticked per [addCard].
  Hlc? _issuedClock;

  /// Snapshot most recently taken or adopted — persisted under the
  /// `snapshot` key so restores keep serving lagging peers across
  /// restarts (the durable-cache discipline; for a COMPACTED file the
  /// snapshot is the only state carrier).
  Snapshot? _lastSnapshot;

  String get boardId => _sync.docId;
  String get replicaId => _sync.actorId;

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
    final at = _issueTime(now);
    final localId = _newCardLocalId(at);
    _write(boardId, localId, _fieldTitle, title, at);
    _write(boardId, localId, _fieldStatus, status, at);
    _write(boardId, localId, _fieldColumn, column, at);
    if (rank.isNotEmpty) {
      _write(boardId, localId, _fieldRank, rank, at);
    }
    if (parent.isNotEmpty) {
      _write(boardId, localId, _fieldParent, parent, at);
    }
    _write(boardId, localId, _fieldCreatedAt, at.millisecondsSinceEpoch, at);
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
    final at = _issueTime(now);
    if (column != null) {
      _write(boardId, localId, _fieldColumn, column, at);
    }
    if (rank != null) {
      _write(boardId, localId, _fieldRank, rank, at);
    }
  }

  /// Settles a card to [status] (one status op).
  void settle({
    required final String cardId,
    required final String status,
    final DateTime? now,
  }) {
    final localId = _requireLocalId(cardId);
    _write(boardId, localId, _fieldStatus, status, _issueTime(now));
  }

  /// The local id of [cardId], refusing malformed ids and absent cards
  /// with the same honesty: there is nothing to write.
  String _requireLocalId(final String cardId) {
    final localId = _localIdOf(cardId);
    if (localId == null || _recordOf(localId) == null) {
      throw StateError('card $cardId is not on this board (absent)');
    }
    return localId;
  }

  // ---------------------------------------------------------------------------
  // Sync seams (kernel-backed via WorldSync — the MeshTaskBoard seams)
  // ---------------------------------------------------------------------------

  VersionVector get versionVector => _sync.vv;

  List<OpRecord> opsSince(final VersionVector remoteVv) =>
      _sync.opsFor(remoteVv);

  int applyRemote(final Iterable<OpRecord> ops) {
    final applied = _sync.applyRemote(ops);
    if (applied > 0) {
      for (final op in ops) {
        _absorbReceived(op.hlc);
      }
    }
    return applied;
  }

  bool needsSnapshotFor(final VersionVector remoteVv) =>
      _sync.needsSnapshotFor(remoteVv);

  Snapshot snapshotFor() {
    final snapshot = _sync.snapshotFor();
    _lastSnapshot = snapshot;
    return snapshot;
  }

  bool adoptSnapshot(final Snapshot snapshot) {
    final adopted = _sync.adoptSnapshot(snapshot);
    _lastSnapshot = snapshot;
    if (!adopted) return false;
    _absorbReceived(snapshot.createdAt);
    return true;
  }

  int compact({final int maxLogOps = 512}) {
    if (_sync.pendingOps.length <= maxLogOps) return 0;
    _sync.compact();
    _lastSnapshot = _sync.snapshotFor();
    return 1;
  }

  List<OpRecord> get pendingOps => _sync.pendingOps;

  /// Full serialization for durable local persistence — the same file
  /// shape as the task board.
  Map<String, Object?> toJson() => {
    'board_id': boardId,
    'replica_id': replicaId,
    'world': _sync.toJson(),
    if (_lastSnapshot != null) 'snapshot': _lastSnapshot!.toJson(),
    if (_issuedClock != null) 'issued_clock': _issuedClock!.toJson(),
    if (_receivedWatermark != null)
      'received_clock': _receivedWatermark!.toJson(),
  };

  // ---------------------------------------------------------------------------
  // Internals (mirrors of MeshTaskBoard's key/clock machinery)
  // ---------------------------------------------------------------------------

  static String _entityKey(final String boardId, final String localId) =>
      '$_entityPrefix$boardId/$localId';

  String _cardIdOf(final String localId) => '$boardId#$localId';

  /// `<boardId>#<cardLocalId>` split at the LAST `#`; null malformed.
  static String? _localIdOf(final String cardId) {
    final hash = cardId.lastIndexOf('#');
    if (hash <= 0 || hash == cardId.length - 1) return null;
    return cardId.substring(hash + 1);
  }

  List<PlanningCardRecord> _allRecords() {
    final projection = _sync.projection;
    final fieldsByCard = <String, Map<String, Object?>>{};
    projection.values.forEach((final key, final value) {
      if (!key.startsWith(_entityPrefix) || value == null) return;
      final rest = key.substring(_entityPrefix.length);
      const componentSeparator = '/$_component/';
      final componentStart = rest.lastIndexOf(componentSeparator);
      if (componentStart < 0) return;
      final field = rest.substring(componentStart + componentSeparator.length);
      final entity = rest.substring(0, componentStart);
      final slash = entity.lastIndexOf('/');
      if (slash <= 0 || slash == entity.length - 1) return;
      final board = entity.substring(0, slash);
      final localId = entity.substring(slash + 1);
      fieldsByCard.putIfAbsent(
        '$board#$localId',
        () => <String, Object?>{},
      )[field] = value;
    });
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
              ? fields[_fieldStatus] as String
              : 'requested',
          column: fields[_fieldColumn] is String
              ? fields[_fieldColumn] as String
              : '',
          rank: fields[_fieldRank] is String ? fields[_fieldRank] as String : '',
          parent: fields[_fieldParent] is String
              ? fields[_fieldParent] as String
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

  void _write(
    final String boardId,
    final String localId,
    final String field,
    final Object? value,
    final DateTime at,
  ) {
    _sync.applyDelta(
      ComponentDelta(
        entityKey: _entityKey(boardId, localId),
        component: _component,
        field: field,
        value: value,
      ),
      at,
    );
  }

  DateTime _issueTime(final DateTime? now) {
    final real = (now ?? _now()).millisecondsSinceEpoch;
    final watermark = _receivedWatermark;
    if (watermark != null && real <= watermark.wallMillis) {
      return DateTime.fromMillisecondsSinceEpoch(watermark.wallMillis + 1);
    }
    return DateTime.fromMillisecondsSinceEpoch(real);
  }

  String _newCardLocalId(final DateTime at) {
    final current = _issuedClock ?? Hlc.zero(replicaId);
    final next = current.tick(at);
    _issuedClock = next;
    return '${next.wallMillis}:${next.counter}:${next.actorId}';
  }

  void _raiseIssued(final Hlc hlc) {
    final current = _issuedClock;
    if (current != null && current >= hlc) return;
    _issuedClock = hlc;
  }

  void _absorbReceived(final Hlc remote) {
    final current = _receivedWatermark;
    if (current != null && current >= remote) return;
    _receivedWatermark = remote;
  }

  static Hlc? _hlcOf(final Object? raw) =>
      raw is Map ? Hlc.fromJson(Map<String, dynamic>.from(raw)) : null;
}
