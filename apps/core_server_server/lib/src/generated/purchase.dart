/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

class Purchase extends _i1.TableRow {
  Purchase({
    int? id,
    required this.source,
    required this.status,
    required this.purchaseDate,
    required this.expiryDate,
    required this.userId,
    required this.orderId,
    required this.productId,
  }) : super(id);

  factory Purchase.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Purchase(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      source:
          serializationManager.deserialize<String>(jsonSerialization['source']),
      status:
          serializationManager.deserialize<String>(jsonSerialization['status']),
      purchaseDate: serializationManager
          .deserialize<DateTime>(jsonSerialization['purchaseDate']),
      expiryDate: serializationManager
          .deserialize<DateTime>(jsonSerialization['expiryDate']),
      userId:
          serializationManager.deserialize<int>(jsonSerialization['userId']),
      orderId: serializationManager
          .deserialize<String>(jsonSerialization['orderId']),
      productId: serializationManager
          .deserialize<String>(jsonSerialization['productId']),
    );
  }

  static final t = PurchaseTable();

  String source;

  String status;

  DateTime purchaseDate;

  DateTime expiryDate;

  int userId;

  String orderId;

  String productId;

  @override
  String get tableName => 'purchases';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'status': status,
      'purchaseDate': purchaseDate,
      'expiryDate': expiryDate,
      'userId': userId,
      'orderId': orderId,
      'productId': productId,
    };
  }

  @override
  Map<String, dynamic> toJsonForDatabase() {
    return {
      'id': id,
      'source': source,
      'status': status,
      'purchaseDate': purchaseDate,
      'expiryDate': expiryDate,
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

  static Future<List<Purchase>> find(
    _i1.Session session, {
    PurchaseExpressionBuilder? where,
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

  static Future<Purchase?> findSingleRow(
    _i1.Session session, {
    PurchaseExpressionBuilder? where,
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

  static Future<Purchase?> findById(
    _i1.Session session,
    int id,
  ) async {
    return session.db.findById<Purchase>(id);
  }

  static Future<int> delete(
    _i1.Session session, {
    required PurchaseExpressionBuilder where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Purchase>(
      where: where(Purchase.t),
      transaction: transaction,
    );
  }

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

  static Future<int> count(
    _i1.Session session, {
    PurchaseExpressionBuilder? where,
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
}

typedef PurchaseExpressionBuilder = _i1.Expression Function(PurchaseTable);

class PurchaseTable extends _i1.Table {
  PurchaseTable() : super(tableName: 'purchases');

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  final id = _i1.ColumnInt('id');

  final source = _i1.ColumnString('source');

  final status = _i1.ColumnString('status');

  final purchaseDate = _i1.ColumnDateTime('purchaseDate');

  final expiryDate = _i1.ColumnDateTime('expiryDate');

  final userId = _i1.ColumnInt('userId');

  final orderId = _i1.ColumnString('orderId');

  final productId = _i1.ColumnString('productId');

  @override
  List<_i1.Column> get columns => [
        id,
        source,
        status,
        purchaseDate,
        expiryDate,
        userId,
        orderId,
        productId,
      ];
}

@Deprecated('Use PurchaseTable.t instead.')
PurchaseTable tPurchase = PurchaseTable();