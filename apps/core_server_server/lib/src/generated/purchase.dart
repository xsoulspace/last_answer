/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class Purchase extends _i1.TableRow {
  Purchase._({
    int? id,
    this.source,
    this.status,
    this.purchaseDate,
    this.expiryDate,
    required this.daysBought,
    required this.userId,
    this.orderId,
    this.productId,
  }) : super(id);

  factory Purchase({
    int? id,
    int? source,
    int? status,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    required int daysBought,
    required int userId,
    String? orderId,
    String? productId,
  }) = _PurchaseImpl;

  factory Purchase.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Purchase(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      source:
          serializationManager.deserialize<int?>(jsonSerialization['source']),
      status:
          serializationManager.deserialize<int?>(jsonSerialization['status']),
      purchaseDate: serializationManager
          .deserialize<DateTime?>(jsonSerialization['purchaseDate']),
      expiryDate: serializationManager
          .deserialize<DateTime?>(jsonSerialization['expiryDate']),
      daysBought: serializationManager
          .deserialize<int>(jsonSerialization['daysBought']),
      userId:
          serializationManager.deserialize<int>(jsonSerialization['userId']),
      orderId: serializationManager
          .deserialize<String?>(jsonSerialization['orderId']),
      productId: serializationManager
          .deserialize<String?>(jsonSerialization['productId']),
    );
  }

  static final t = PurchaseTable();

  static const db = PurchaseRepository._();

  int? source;

  int? status;

  DateTime? purchaseDate;

  DateTime? expiryDate;

  int daysBought;

  int userId;

  String? orderId;

  String? productId;

  @override
  _i1.Table get table => t;

  Purchase copyWith({
    int? id,
    int? source,
    int? status,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    int? daysBought,
    int? userId,
    String? orderId,
    String? productId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (purchaseDate != null) 'purchaseDate': purchaseDate,
      if (expiryDate != null) 'expiryDate': expiryDate,
      'daysBought': daysBought,
      'userId': userId,
      if (orderId != null) 'orderId': orderId,
      if (productId != null) 'productId': productId,
    };
  }

  @override
  @Deprecated('Will be removed in 2.0.0')
  Map<String, dynamic> toJsonForDatabase() {
    return {
      'id': id,
      'source': source,
      'status': status,
      'purchaseDate': purchaseDate,
      'expiryDate': expiryDate,
      'daysBought': daysBought,
      'userId': userId,
      'orderId': orderId,
      'productId': productId,
    };
  }

  @override
  Map<String, dynamic> allToJson() {
    return {
      'id': id,
      'source': source,
      'status': status,
      'purchaseDate': purchaseDate,
      'expiryDate': expiryDate,
      'daysBought': daysBought,
      'userId': userId,
      'orderId': orderId,
      'productId': productId,
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
      case 'source':
        source = value;
        return;
      case 'status':
        status = value;
        return;
      case 'purchaseDate':
        purchaseDate = value;
        return;
      case 'expiryDate':
        expiryDate = value;
        return;
      case 'daysBought':
        daysBought = value;
        return;
      case 'userId':
        userId = value;
        return;
      case 'orderId':
        orderId = value;
        return;
      case 'productId':
        productId = value;
        return;
      default:
        throw UnimplementedError();
    }
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.find instead.')
  static Future<List<Purchase>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _i1.Column? orderBy,
    List<_i1.Order>? orderByList,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Purchase>(
      where: where != null ? where(Purchase.t) : null,
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
  static Future<Purchase?> findSingleRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseTable>? where,
    int? offset,
    _i1.Column? orderBy,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findSingleRow<Purchase>(
      where: where != null ? where(Purchase.t) : null,
      offset: offset,
      orderBy: orderBy,
      orderDescending: orderDescending,
      useCache: useCache,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.findById instead.')
  static Future<Purchase?> findById(
    _i1.Session session,
    int id,
  ) async {
    return session.db.findById<Purchase>(id);
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteWhere instead.')
  static Future<int> delete(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PurchaseTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Purchase>(
      where: where(Purchase.t),
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteRow instead.')
  static Future<bool> deleteRow(
    _i1.Session session,
    Purchase row, {
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
    Purchase row, {
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
    Purchase row, {
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
    _i1.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Purchase>(
      where: where != null ? where(Purchase.t) : null,
      limit: limit,
      useCache: useCache,
      transaction: transaction,
    );
  }

  static PurchaseInclude include() {
    return PurchaseInclude._();
  }

  static PurchaseIncludeList includeList({
    _i1.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PurchaseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchaseTable>? orderByList,
    PurchaseInclude? include,
  }) {
    return PurchaseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Purchase.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Purchase.t),
      include: include,
    );
  }
}

class _Undefined {}

class _PurchaseImpl extends Purchase {
  _PurchaseImpl({
    int? id,
    int? source,
    int? status,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    required int daysBought,
    required int userId,
    String? orderId,
    String? productId,
  }) : super._(
          id: id,
          source: source,
          status: status,
          purchaseDate: purchaseDate,
          expiryDate: expiryDate,
          daysBought: daysBought,
          userId: userId,
          orderId: orderId,
          productId: productId,
        );

  @override
  Purchase copyWith({
    Object? id = _Undefined,
    Object? source = _Undefined,
    Object? status = _Undefined,
    Object? purchaseDate = _Undefined,
    Object? expiryDate = _Undefined,
    int? daysBought,
    int? userId,
    Object? orderId = _Undefined,
    Object? productId = _Undefined,
  }) {
    return Purchase(
      id: id is int? ? id : this.id,
      source: source is int? ? source : this.source,
      status: status is int? ? status : this.status,
      purchaseDate:
          purchaseDate is DateTime? ? purchaseDate : this.purchaseDate,
      expiryDate: expiryDate is DateTime? ? expiryDate : this.expiryDate,
      daysBought: daysBought ?? this.daysBought,
      userId: userId ?? this.userId,
      orderId: orderId is String? ? orderId : this.orderId,
      productId: productId is String? ? productId : this.productId,
    );
  }
}

class PurchaseTable extends _i1.Table {
  PurchaseTable({super.tableRelation}) : super(tableName: 'purchases_history') {
    source = _i1.ColumnInt(
      'source',
      this,
    );
    status = _i1.ColumnInt(
      'status',
      this,
    );
    purchaseDate = _i1.ColumnDateTime(
      'purchaseDate',
      this,
    );
    expiryDate = _i1.ColumnDateTime(
      'expiryDate',
      this,
    );
    daysBought = _i1.ColumnInt(
      'daysBought',
      this,
    );
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    orderId = _i1.ColumnString(
      'orderId',
      this,
    );
    productId = _i1.ColumnString(
      'productId',
      this,
    );
  }

  late final _i1.ColumnInt source;

  late final _i1.ColumnInt status;

  late final _i1.ColumnDateTime purchaseDate;

  late final _i1.ColumnDateTime expiryDate;

  late final _i1.ColumnInt daysBought;

  late final _i1.ColumnInt userId;

  late final _i1.ColumnString orderId;

  late final _i1.ColumnString productId;

  @override
  List<_i1.Column> get columns => [
        id,
        source,
        status,
        purchaseDate,
        expiryDate,
        daysBought,
        userId,
        orderId,
        productId,
      ];
}

@Deprecated('Use PurchaseTable.t instead.')
PurchaseTable tPurchase = PurchaseTable();

class PurchaseInclude extends _i1.IncludeObject {
  PurchaseInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => Purchase.t;
}

class PurchaseIncludeList extends _i1.IncludeList {
  PurchaseIncludeList._({
    _i1.WhereExpressionBuilder<PurchaseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Purchase.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table get table => Purchase.t;
}

class PurchaseRepository {
  const PurchaseRepository._();

  Future<List<Purchase>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PurchaseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchaseTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.find<Purchase>(
      where: where?.call(Purchase.t),
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Purchase?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseTable>? where,
    int? offset,
    _i1.OrderByBuilder<PurchaseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchaseTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findFirstRow<Purchase>(
      where: where?.call(Purchase.t),
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Purchase?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findById<Purchase>(
      id,
      transaction: transaction,
    );
  }

  Future<List<Purchase>> insert(
    _i1.Session session,
    List<Purchase> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insert<Purchase>(
      rows,
      transaction: transaction,
    );
  }

  Future<Purchase> insertRow(
    _i1.Session session,
    Purchase row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insertRow<Purchase>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Purchase>> update(
    _i1.Session session,
    List<Purchase> rows, {
    _i1.ColumnSelections<PurchaseTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.update<Purchase>(
      rows,
      columns: columns?.call(Purchase.t),
      transaction: transaction,
    );
  }

  Future<Purchase> updateRow(
    _i1.Session session,
    Purchase row, {
    _i1.ColumnSelections<PurchaseTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.updateRow<Purchase>(
      row,
      columns: columns?.call(Purchase.t),
      transaction: transaction,
    );
  }

  Future<List<int>> delete(
    _i1.Session session,
    List<Purchase> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.delete<Purchase>(
      rows,
      transaction: transaction,
    );
  }

  Future<int> deleteRow(
    _i1.Session session,
    Purchase row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteRow<Purchase>(
      row,
      transaction: transaction,
    );
  }

  Future<List<int>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PurchaseTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteWhere<Purchase>(
      where: where(Purchase.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.count<Purchase>(
      where: where?.call(Purchase.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
