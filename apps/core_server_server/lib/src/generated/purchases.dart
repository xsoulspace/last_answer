/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class Purchases extends _i1.TableRow {
  Purchases._({
    int? id,
    required this.purchasedDaysLeft,
    required this.hasOneTimePurchase,
    this.subscriptionEndDate,
    required this.userId,
  }) : super(id);

  factory Purchases({
    int? id,
    required int purchasedDaysLeft,
    required bool hasOneTimePurchase,
    DateTime? subscriptionEndDate,
    required int userId,
  }) = _PurchasesImpl;

  factory Purchases.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Purchases(
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

  static final t = PurchasesTable();

  static const db = PurchasesRepository._();

  int purchasedDaysLeft;

  bool hasOneTimePurchase;

  DateTime? subscriptionEndDate;

  int userId;

  @override
  _i1.Table get table => t;

  Purchases copyWith({
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
  static Future<List<Purchases>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchasesTable>? where,
    int? limit,
    int? offset,
    _i1.Column? orderBy,
    List<_i1.Order>? orderByList,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Purchases>(
      where: where != null ? where(Purchases.t) : null,
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
  static Future<Purchases?> findSingleRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchasesTable>? where,
    int? offset,
    _i1.Column? orderBy,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findSingleRow<Purchases>(
      where: where != null ? where(Purchases.t) : null,
      offset: offset,
      orderBy: orderBy,
      orderDescending: orderDescending,
      useCache: useCache,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.findById instead.')
  static Future<Purchases?> findById(
    _i1.Session session,
    int id,
  ) async {
    return session.db.findById<Purchases>(id);
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteWhere instead.')
  static Future<int> delete(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PurchasesTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Purchases>(
      where: where(Purchases.t),
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteRow instead.')
  static Future<bool> deleteRow(
    _i1.Session session,
    Purchases row, {
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
    Purchases row, {
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
    Purchases row, {
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
    _i1.WhereExpressionBuilder<PurchasesTable>? where,
    int? limit,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Purchases>(
      where: where != null ? where(Purchases.t) : null,
      limit: limit,
      useCache: useCache,
      transaction: transaction,
    );
  }

  static PurchasesInclude include() {
    return PurchasesInclude._();
  }

  static PurchasesIncludeList includeList({
    _i1.WhereExpressionBuilder<PurchasesTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PurchasesTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchasesTable>? orderByList,
    PurchasesInclude? include,
  }) {
    return PurchasesIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Purchases.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Purchases.t),
      include: include,
    );
  }
}

class _Undefined {}

class _PurchasesImpl extends Purchases {
  _PurchasesImpl({
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
  Purchases copyWith({
    Object? id = _Undefined,
    int? purchasedDaysLeft,
    bool? hasOneTimePurchase,
    Object? subscriptionEndDate = _Undefined,
    int? userId,
  }) {
    return Purchases(
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

class PurchasesTable extends _i1.Table {
  PurchasesTable({super.tableRelation})
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

@Deprecated('Use PurchasesTable.t instead.')
PurchasesTable tPurchases = PurchasesTable();

class PurchasesInclude extends _i1.IncludeObject {
  PurchasesInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => Purchases.t;
}

class PurchasesIncludeList extends _i1.IncludeList {
  PurchasesIncludeList._({
    _i1.WhereExpressionBuilder<PurchasesTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Purchases.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table get table => Purchases.t;
}

class PurchasesRepository {
  const PurchasesRepository._();

  Future<List<Purchases>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchasesTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PurchasesTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchasesTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.find<Purchases>(
      where: where?.call(Purchases.t),
      orderBy: orderBy?.call(Purchases.t),
      orderByList: orderByList?.call(Purchases.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Purchases?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchasesTable>? where,
    int? offset,
    _i1.OrderByBuilder<PurchasesTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchasesTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findFirstRow<Purchases>(
      where: where?.call(Purchases.t),
      orderBy: orderBy?.call(Purchases.t),
      orderByList: orderByList?.call(Purchases.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Purchases?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findById<Purchases>(
      id,
      transaction: transaction,
    );
  }

  Future<List<Purchases>> insert(
    _i1.Session session,
    List<Purchases> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insert<Purchases>(
      rows,
      transaction: transaction,
    );
  }

  Future<Purchases> insertRow(
    _i1.Session session,
    Purchases row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insertRow<Purchases>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Purchases>> update(
    _i1.Session session,
    List<Purchases> rows, {
    _i1.ColumnSelections<PurchasesTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.update<Purchases>(
      rows,
      columns: columns?.call(Purchases.t),
      transaction: transaction,
    );
  }

  Future<Purchases> updateRow(
    _i1.Session session,
    Purchases row, {
    _i1.ColumnSelections<PurchasesTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.updateRow<Purchases>(
      row,
      columns: columns?.call(Purchases.t),
      transaction: transaction,
    );
  }

  Future<List<int>> delete(
    _i1.Session session,
    List<Purchases> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.delete<Purchases>(
      rows,
      transaction: transaction,
    );
  }

  Future<int> deleteRow(
    _i1.Session session,
    Purchases row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteRow<Purchases>(
      row,
      transaction: transaction,
    );
  }

  Future<List<int>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PurchasesTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteWhere<Purchases>(
      where: where(Purchases.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchasesTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.count<Purchases>(
      where: where?.call(Purchases.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
