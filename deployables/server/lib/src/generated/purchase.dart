/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod/serverpod.dart' as _i1;

abstract class PurchaseAction
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PurchaseAction._({
    this.id,
    required this.userId,
    required this.type,
    required this.rewardDaysQuantity,
    required this.createdAt,
  });

  factory PurchaseAction({
    int? id,
    required int userId,
    required String type,
    required int rewardDaysQuantity,
    required DateTime createdAt,
  }) = _PurchaseActionImpl;

  factory PurchaseAction.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseAction(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      type: jsonSerialization['type'] as String,
      rewardDaysQuantity: jsonSerialization['rewardDaysQuantity'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PurchaseActionTable();

  static const db = PurchaseActionRepository._();

  @override
  int? id;

  int userId;

  String type;

  int rewardDaysQuantity;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PurchaseAction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PurchaseAction copyWith({
    int? id,
    int? userId,
    String? type,
    int? rewardDaysQuantity,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PurchaseAction',
      if (id != null) 'id': id,
      'userId': userId,
      'type': type,
      'rewardDaysQuantity': rewardDaysQuantity,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PurchaseAction',
      if (id != null) 'id': id,
      'userId': userId,
      'type': type,
      'rewardDaysQuantity': rewardDaysQuantity,
      'createdAt': createdAt.toJson(),
    };
  }

  static PurchaseActionInclude include() {
    return PurchaseActionInclude._();
  }

  static PurchaseActionIncludeList includeList({
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PurchaseActionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchaseActionTable>? orderByList,
    PurchaseActionInclude? include,
  }) {
    return PurchaseActionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseAction.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PurchaseAction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseActionImpl extends PurchaseAction {
  _PurchaseActionImpl({
    int? id,
    required int userId,
    required String type,
    required int rewardDaysQuantity,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         type: type,
         rewardDaysQuantity: rewardDaysQuantity,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PurchaseAction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PurchaseAction copyWith({
    Object? id = _Undefined,
    int? userId,
    String? type,
    int? rewardDaysQuantity,
    DateTime? createdAt,
  }) {
    return PurchaseAction(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      rewardDaysQuantity: rewardDaysQuantity ?? this.rewardDaysQuantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PurchaseActionUpdateTable extends _i1.UpdateTable<PurchaseActionTable> {
  PurchaseActionUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> type(String value) => _i1.ColumnValue(
    table.type,
    value,
  );

  _i1.ColumnValue<int, int> rewardDaysQuantity(int value) => _i1.ColumnValue(
    table.rewardDaysQuantity,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class PurchaseActionTable extends _i1.Table<int?> {
  PurchaseActionTable({super.tableRelation})
    : super(tableName: 'purchases_history') {
    updateTable = PurchaseActionUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    type = _i1.ColumnString(
      'type',
      this,
    );
    rewardDaysQuantity = _i1.ColumnInt(
      'rewardDaysQuantity',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PurchaseActionUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  late final _i1.ColumnString type;

  late final _i1.ColumnInt rewardDaysQuantity;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    type,
    rewardDaysQuantity,
    createdAt,
  ];
}

class PurchaseActionInclude extends _i1.IncludeObject {
  PurchaseActionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PurchaseAction.t;
}

class PurchaseActionIncludeList extends _i1.IncludeList {
  PurchaseActionIncludeList._({
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PurchaseAction.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PurchaseAction.t;
}

class PurchaseActionRepository {
  const PurchaseActionRepository._();

  /// Returns a list of [PurchaseAction]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<PurchaseAction>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PurchaseActionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchaseActionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PurchaseAction>(
      where: where?.call(PurchaseAction.t),
      orderBy: orderBy?.call(PurchaseAction.t),
      orderByList: orderByList?.call(PurchaseAction.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PurchaseAction] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<PurchaseAction?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? offset,
    _i1.OrderByBuilder<PurchaseActionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchaseActionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PurchaseAction>(
      where: where?.call(PurchaseAction.t),
      orderBy: orderBy?.call(PurchaseAction.t),
      orderByList: orderByList?.call(PurchaseAction.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PurchaseAction] by its [id] or null if no such row exists.
  Future<PurchaseAction?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PurchaseAction>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PurchaseAction]s in the list and returns the inserted rows.
  ///
  /// The returned [PurchaseAction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PurchaseAction>> insert(
    _i1.DatabaseSession session,
    List<PurchaseAction> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PurchaseAction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PurchaseAction] and returns the inserted row.
  ///
  /// The returned [PurchaseAction] will have its `id` field set.
  Future<PurchaseAction> insertRow(
    _i1.DatabaseSession session,
    PurchaseAction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PurchaseAction>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseAction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PurchaseAction>> update(
    _i1.DatabaseSession session,
    List<PurchaseAction> rows, {
    _i1.ColumnSelections<PurchaseActionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PurchaseAction>(
      rows,
      columns: columns?.call(PurchaseAction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PurchaseAction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PurchaseAction> updateRow(
    _i1.DatabaseSession session,
    PurchaseAction row, {
    _i1.ColumnSelections<PurchaseActionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PurchaseAction>(
      row,
      columns: columns?.call(PurchaseAction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PurchaseAction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PurchaseAction?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PurchaseActionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PurchaseAction>(
      id,
      columnValues: columnValues(PurchaseAction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseAction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PurchaseAction>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PurchaseActionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PurchaseActionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PurchaseActionTable>? orderBy,
    _i1.OrderByListBuilder<PurchaseActionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PurchaseAction>(
      columnValues: columnValues(PurchaseAction.t.updateTable),
      where: where(PurchaseAction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseAction.t),
      orderByList: orderByList?.call(PurchaseAction.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PurchaseAction]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PurchaseAction>> delete(
    _i1.DatabaseSession session,
    List<PurchaseAction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PurchaseAction>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PurchaseAction].
  Future<PurchaseAction> deleteRow(
    _i1.DatabaseSession session,
    PurchaseAction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PurchaseAction>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PurchaseAction>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PurchaseActionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PurchaseAction>(
      where: where(PurchaseAction.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PurchaseAction>(
      where: where?.call(PurchaseAction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PurchaseAction] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PurchaseActionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PurchaseAction>(
      where: where(PurchaseAction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
