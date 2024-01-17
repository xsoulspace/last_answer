/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class UserPurchaseInfo extends _i1.TableRow {
  UserPurchaseInfo._({
    int? id,
    required this.purchasedDaysLeft,
    required this.hasOneTimePurchase,
    this.subscriptionEndDate,
    required this.userId,
  }) : super(id);

  factory UserPurchaseInfo({
    int? id,
    required int purchasedDaysLeft,
    required bool hasOneTimePurchase,
    DateTime? subscriptionEndDate,
    required int userId,
  }) = _UserPurchaseInfoImpl;

  factory UserPurchaseInfo.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return UserPurchaseInfo(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      purchasedDaysLeft: serializationManager
          .deserialize<int>(jsonSerialization['purchasedDaysLeft']),
      hasOneTimePurchase: serializationManager
          .deserialize<bool>(jsonSerialization['hasOneTimePurchase']),
      subscriptionEndDate: serializationManager
          .deserialize<DateTime?>(jsonSerialization['subscriptionEndDate']),
      userId:
          serializationManager.deserialize<int>(jsonSerialization['userId']),
    );
  }

  static final t = UserPurchaseInfoTable();

  static const db = UserPurchaseInfoRepository._();

  int purchasedDaysLeft;

  bool hasOneTimePurchase;

  DateTime? subscriptionEndDate;

  int userId;

  @override
  _i1.Table get table => t;

  UserPurchaseInfo copyWith({
    int? id,
    int? purchasedDaysLeft,
    bool? hasOneTimePurchase,
    DateTime? subscriptionEndDate,
    int? userId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'purchasedDaysLeft': purchasedDaysLeft,
      'hasOneTimePurchase': hasOneTimePurchase,
      if (subscriptionEndDate != null)
        'subscriptionEndDate': subscriptionEndDate,
      'userId': userId,
    };
  }

  @override
  @Deprecated('Will be removed in 2.0.0')
  Map<String, dynamic> toJsonForDatabase() {
    return {
      'id': id,
      'purchasedDaysLeft': purchasedDaysLeft,
      'hasOneTimePurchase': hasOneTimePurchase,
      'subscriptionEndDate': subscriptionEndDate,
      'userId': userId,
    };
  }

  @override
  Map<String, dynamic> allToJson() {
    return {
      'id': id,
      'purchasedDaysLeft': purchasedDaysLeft,
      'hasOneTimePurchase': hasOneTimePurchase,
      'subscriptionEndDate': subscriptionEndDate,
      'userId': userId,
    };
  }

  @override
  void setColumn(
    String columnName,
    value,
  ) {
    switch (columnName) {
      case 'id':
        id = value;
        return;
      case 'purchasedDaysLeft':
        purchasedDaysLeft = value;
        return;
      case 'hasOneTimePurchase':
        hasOneTimePurchase = value;
        return;
      case 'subscriptionEndDate':
        subscriptionEndDate = value;
        return;
      case 'userId':
        userId = value;
        return;
      default:
        throw UnimplementedError();
    }
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.find instead.')
  static Future<List<UserPurchaseInfo>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? limit,
    int? offset,
    _i1.Column? orderBy,
    List<_i1.Order>? orderByList,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<UserPurchaseInfo>(
      where: where != null ? where(UserPurchaseInfo.t) : null,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      orderByList: orderByList,
      orderDescending: orderDescending,
      useCache: useCache,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.findRow instead.')
  static Future<UserPurchaseInfo?> findSingleRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? offset,
    _i1.Column? orderBy,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findSingleRow<UserPurchaseInfo>(
      where: where != null ? where(UserPurchaseInfo.t) : null,
      offset: offset,
      orderBy: orderBy,
      orderDescending: orderDescending,
      useCache: useCache,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.findById instead.')
  static Future<UserPurchaseInfo?> findById(
    _i1.Session session,
    int id,
  ) async {
    return session.db.findById<UserPurchaseInfo>(id);
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteWhere instead.')
  static Future<int> delete(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserPurchaseInfoTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserPurchaseInfo>(
      where: where(UserPurchaseInfo.t),
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteRow instead.')
  static Future<bool> deleteRow(
    _i1.Session session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow(
      row,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.update instead.')
  static Future<bool> update(
    _i1.Session session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.update(
      row,
      transaction: transaction,
    );
  }

  @Deprecated(
      'Will be removed in 2.0.0. Use: db.insert instead. Important note: In db.insert, the object you pass in is no longer modified, instead a new copy with the added row is returned which contains the inserted id.')
  static Future<void> insert(
    _i1.Session session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert(
      row,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.count instead.')
  static Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? limit,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserPurchaseInfo>(
      where: where != null ? where(UserPurchaseInfo.t) : null,
      limit: limit,
      useCache: useCache,
      transaction: transaction,
    );
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
}

class _Undefined {}

class _UserPurchaseInfoImpl extends UserPurchaseInfo {
  _UserPurchaseInfoImpl({
    int? id,
    required int purchasedDaysLeft,
    required bool hasOneTimePurchase,
    DateTime? subscriptionEndDate,
    required int userId,
  }) : super._(
          id: id,
          purchasedDaysLeft: purchasedDaysLeft,
          hasOneTimePurchase: hasOneTimePurchase,
          subscriptionEndDate: subscriptionEndDate,
          userId: userId,
        );

  @override
  UserPurchaseInfo copyWith({
    Object? id = _Undefined,
    int? purchasedDaysLeft,
    bool? hasOneTimePurchase,
    Object? subscriptionEndDate = _Undefined,
    int? userId,
  }) {
    return UserPurchaseInfo(
      id: id is int? ? id : this.id,
      purchasedDaysLeft: purchasedDaysLeft ?? this.purchasedDaysLeft,
      hasOneTimePurchase: hasOneTimePurchase ?? this.hasOneTimePurchase,
      subscriptionEndDate: subscriptionEndDate is DateTime?
          ? subscriptionEndDate
          : this.subscriptionEndDate,
      userId: userId ?? this.userId,
    );
  }
}

class UserPurchaseInfoTable extends _i1.Table {
  UserPurchaseInfoTable({super.tableRelation})
      : super(tableName: 'user_purchase_info') {
    purchasedDaysLeft = _i1.ColumnInt(
      'purchasedDaysLeft',
      this,
    );
    hasOneTimePurchase = _i1.ColumnBool(
      'hasOneTimePurchase',
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

  late final _i1.ColumnInt purchasedDaysLeft;

  late final _i1.ColumnBool hasOneTimePurchase;

  late final _i1.ColumnDateTime subscriptionEndDate;

  late final _i1.ColumnInt userId;

  @override
  List<_i1.Column> get columns => [
        id,
        purchasedDaysLeft,
        hasOneTimePurchase,
        subscriptionEndDate,
        userId,
      ];
}

@Deprecated('Use UserPurchaseInfoTable.t instead.')
UserPurchaseInfoTable tUserPurchaseInfo = UserPurchaseInfoTable();

class UserPurchaseInfoInclude extends _i1.IncludeObject {
  UserPurchaseInfoInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => UserPurchaseInfo.t;
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
  _i1.Table get table => UserPurchaseInfo.t;
}

class UserPurchaseInfoRepository {
  const UserPurchaseInfoRepository._();

  Future<List<UserPurchaseInfo>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserPurchaseInfoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserPurchaseInfoTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.find<UserPurchaseInfo>(
      where: where?.call(UserPurchaseInfo.t),
      orderBy: orderBy?.call(UserPurchaseInfo.t),
      orderByList: orderByList?.call(UserPurchaseInfo.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<UserPurchaseInfo?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserPurchaseInfoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserPurchaseInfoTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findFirstRow<UserPurchaseInfo>(
      where: where?.call(UserPurchaseInfo.t),
      orderBy: orderBy?.call(UserPurchaseInfo.t),
      orderByList: orderByList?.call(UserPurchaseInfo.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<UserPurchaseInfo?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findById<UserPurchaseInfo>(
      id,
      transaction: transaction,
    );
  }

  Future<List<UserPurchaseInfo>> insert(
    _i1.Session session,
    List<UserPurchaseInfo> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insert<UserPurchaseInfo>(
      rows,
      transaction: transaction,
    );
  }

  Future<UserPurchaseInfo> insertRow(
    _i1.Session session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insertRow<UserPurchaseInfo>(
      row,
      transaction: transaction,
    );
  }

  Future<List<UserPurchaseInfo>> update(
    _i1.Session session,
    List<UserPurchaseInfo> rows, {
    _i1.ColumnSelections<UserPurchaseInfoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.update<UserPurchaseInfo>(
      rows,
      columns: columns?.call(UserPurchaseInfo.t),
      transaction: transaction,
    );
  }

  Future<UserPurchaseInfo> updateRow(
    _i1.Session session,
    UserPurchaseInfo row, {
    _i1.ColumnSelections<UserPurchaseInfoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.updateRow<UserPurchaseInfo>(
      row,
      columns: columns?.call(UserPurchaseInfo.t),
      transaction: transaction,
    );
  }

  Future<List<int>> delete(
    _i1.Session session,
    List<UserPurchaseInfo> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.delete<UserPurchaseInfo>(
      rows,
      transaction: transaction,
    );
  }

  Future<int> deleteRow(
    _i1.Session session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteRow<UserPurchaseInfo>(
      row,
      transaction: transaction,
    );
  }

  Future<List<int>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserPurchaseInfoTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteWhere<UserPurchaseInfo>(
      where: where(UserPurchaseInfo.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserPurchaseInfoTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.count<UserPurchaseInfo>(
      where: where?.call(UserPurchaseInfo.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
