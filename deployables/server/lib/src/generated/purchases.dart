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

abstract class UserPurchaseInfo
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserPurchaseInfo._({
    this.id,
    required this.daysOfSupporterLeft,
    required this.isOneTimePurchased,
    this.subscriptionEndDate,
    required this.userId,
  });

  factory UserPurchaseInfo({
    int? id,
    required int daysOfSupporterLeft,
    required bool isOneTimePurchased,
    DateTime? subscriptionEndDate,
    required int userId,
  }) = _UserPurchaseInfoImpl;

  factory UserPurchaseInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserPurchaseInfo(
      id: jsonSerialization['id'] as int?,
      daysOfSupporterLeft: jsonSerialization['daysOfSupporterLeft'] as int,
      isOneTimePurchased: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isOneTimePurchased'],
      ),
      subscriptionEndDate: jsonSerialization['subscriptionEndDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['subscriptionEndDate'],
            ),
      userId: jsonSerialization['userId'] as int,
    );
  }

  static final t = UserPurchaseInfoTable();

  static const db = UserPurchaseInfoRepository._();

  @override
  int? id;

  int daysOfSupporterLeft;

  bool isOneTimePurchased;

  DateTime? subscriptionEndDate;

  int userId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserPurchaseInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserPurchaseInfo copyWith({
    int? id,
    int? daysOfSupporterLeft,
    bool? isOneTimePurchased,
    DateTime? subscriptionEndDate,
    int? userId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserPurchaseInfo',
      if (id != null) 'id': id,
      'daysOfSupporterLeft': daysOfSupporterLeft,
      'isOneTimePurchased': isOneTimePurchased,
      if (subscriptionEndDate != null)
        'subscriptionEndDate': subscriptionEndDate?.toJson(),
      'userId': userId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserPurchaseInfo',
      if (id != null) 'id': id,
      'daysOfSupporterLeft': daysOfSupporterLeft,
      'isOneTimePurchased': isOneTimePurchased,
      if (subscriptionEndDate != null)
        'subscriptionEndDate': subscriptionEndDate?.toJson(),
      'userId': userId,
    };
  }

  static UserPurchaseInfoInclude include() {
    return UserPurchaseInfoInclude._();
  }

  static UserPurchaseInfoIncludeList includeList({
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserPurchaseInfoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserPurchaseInfoTable>? orderByList,
    UserPurchaseInfoInclude? include,
  }) {
    return UserPurchaseInfoIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserPurchaseInfo.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserPurchaseInfo.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserPurchaseInfoImpl extends UserPurchaseInfo {
  _UserPurchaseInfoImpl({
    int? id,
    required int daysOfSupporterLeft,
    required bool isOneTimePurchased,
    DateTime? subscriptionEndDate,
    required int userId,
  }) : super._(
         id: id,
         daysOfSupporterLeft: daysOfSupporterLeft,
         isOneTimePurchased: isOneTimePurchased,
         subscriptionEndDate: subscriptionEndDate,
         userId: userId,
       );

  /// Returns a shallow copy of this [UserPurchaseInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserPurchaseInfo copyWith({
    Object? id = _Undefined,
    int? daysOfSupporterLeft,
    bool? isOneTimePurchased,
    Object? subscriptionEndDate = _Undefined,
    int? userId,
  }) {
    return UserPurchaseInfo(
      id: id is int? ? id : this.id,
      daysOfSupporterLeft: daysOfSupporterLeft ?? this.daysOfSupporterLeft,
      isOneTimePurchased: isOneTimePurchased ?? this.isOneTimePurchased,
      subscriptionEndDate: subscriptionEndDate is DateTime?
          ? subscriptionEndDate
          : this.subscriptionEndDate,
      userId: userId ?? this.userId,
    );
  }
}

class UserPurchaseInfoUpdateTable
    extends _i1.UpdateTable<UserPurchaseInfoTable> {
  UserPurchaseInfoUpdateTable(super.table);

  _i1.ColumnValue<int, int> daysOfSupporterLeft(int value) => _i1.ColumnValue(
    table.daysOfSupporterLeft,
    value,
  );

  _i1.ColumnValue<bool, bool> isOneTimePurchased(bool value) => _i1.ColumnValue(
    table.isOneTimePurchased,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> subscriptionEndDate(DateTime? value) =>
      _i1.ColumnValue(
        table.subscriptionEndDate,
        value,
      );

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );
}

class UserPurchaseInfoTable extends _i1.Table<int?> {
  UserPurchaseInfoTable({super.tableRelation})
    : super(tableName: 'user_purchase_info') {
    updateTable = UserPurchaseInfoUpdateTable(this);
    daysOfSupporterLeft = _i1.ColumnInt(
      'daysOfSupporterLeft',
      this,
    );
    isOneTimePurchased = _i1.ColumnBool(
      'isOneTimePurchased',
      this,
    );
    subscriptionEndDate = _i1.ColumnDateTime(
      'subscriptionEndDate',
      this,
    );
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
  }

  late final UserPurchaseInfoUpdateTable updateTable;

  late final _i1.ColumnInt daysOfSupporterLeft;

  late final _i1.ColumnBool isOneTimePurchased;

  late final _i1.ColumnDateTime subscriptionEndDate;

  late final _i1.ColumnInt userId;

  @override
  List<_i1.Column> get columns => [
    id,
    daysOfSupporterLeft,
    isOneTimePurchased,
    subscriptionEndDate,
    userId,
  ];
}

class UserPurchaseInfoInclude extends _i1.IncludeObject {
  UserPurchaseInfoInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserPurchaseInfo.t;
}

class UserPurchaseInfoIncludeList extends _i1.IncludeList {
  UserPurchaseInfoIncludeList._({
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserPurchaseInfo.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserPurchaseInfo.t;
}

class UserPurchaseInfoRepository {
  const UserPurchaseInfoRepository._();

  /// Returns a list of [UserPurchaseInfo]s matching the given query parameters.
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
  Future<List<UserPurchaseInfo>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserPurchaseInfoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserPurchaseInfoTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserPurchaseInfo>(
      where: where?.call(UserPurchaseInfo.t),
      orderBy: orderBy?.call(UserPurchaseInfo.t),
      orderByList: orderByList?.call(UserPurchaseInfo.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserPurchaseInfo] matching the given query parameters.
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
  Future<UserPurchaseInfo?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserPurchaseInfoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserPurchaseInfoTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserPurchaseInfo>(
      where: where?.call(UserPurchaseInfo.t),
      orderBy: orderBy?.call(UserPurchaseInfo.t),
      orderByList: orderByList?.call(UserPurchaseInfo.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserPurchaseInfo] by its [id] or null if no such row exists.
  Future<UserPurchaseInfo?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserPurchaseInfo>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserPurchaseInfo]s in the list and returns the inserted rows.
  ///
  /// The returned [UserPurchaseInfo]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserPurchaseInfo>> insert(
    _i1.DatabaseSession session,
    List<UserPurchaseInfo> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserPurchaseInfo>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserPurchaseInfo] and returns the inserted row.
  ///
  /// The returned [UserPurchaseInfo] will have its `id` field set.
  Future<UserPurchaseInfo> insertRow(
    _i1.DatabaseSession session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserPurchaseInfo>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserPurchaseInfo]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserPurchaseInfo>> update(
    _i1.DatabaseSession session,
    List<UserPurchaseInfo> rows, {
    _i1.ColumnSelections<UserPurchaseInfoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserPurchaseInfo>(
      rows,
      columns: columns?.call(UserPurchaseInfo.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserPurchaseInfo]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserPurchaseInfo> updateRow(
    _i1.DatabaseSession session,
    UserPurchaseInfo row, {
    _i1.ColumnSelections<UserPurchaseInfoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserPurchaseInfo>(
      row,
      columns: columns?.call(UserPurchaseInfo.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserPurchaseInfo] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserPurchaseInfo?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<UserPurchaseInfoUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserPurchaseInfo>(
      id,
      columnValues: columnValues(UserPurchaseInfo.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserPurchaseInfo]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserPurchaseInfo>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserPurchaseInfoUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<UserPurchaseInfoTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserPurchaseInfoTable>? orderBy,
    _i1.OrderByListBuilder<UserPurchaseInfoTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserPurchaseInfo>(
      columnValues: columnValues(UserPurchaseInfo.t.updateTable),
      where: where(UserPurchaseInfo.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserPurchaseInfo.t),
      orderByList: orderByList?.call(UserPurchaseInfo.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserPurchaseInfo]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserPurchaseInfo>> delete(
    _i1.DatabaseSession session,
    List<UserPurchaseInfo> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserPurchaseInfo>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserPurchaseInfo].
  Future<UserPurchaseInfo> deleteRow(
    _i1.DatabaseSession session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserPurchaseInfo>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserPurchaseInfo>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserPurchaseInfoTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserPurchaseInfo>(
      where: where(UserPurchaseInfo.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserPurchaseInfo>(
      where: where?.call(UserPurchaseInfo.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserPurchaseInfo] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserPurchaseInfoTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserPurchaseInfo>(
      where: where(UserPurchaseInfo.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
