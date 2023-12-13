/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

class Purchases extends _i1.TableRow {
  Purchases({
    int? id,
    required this.userId,
    this.has_one_time_purchase,
    this.subscription_end_date,
    this.purchased_days_left,
  }) : super(id);

  factory Purchases.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Purchases(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      userId:
          serializationManager.deserialize<int>(jsonSerialization['userId']),
      has_one_time_purchase: serializationManager
          .deserialize<bool?>(jsonSerialization['has_one_time_purchase']),
      subscription_end_date: serializationManager
          .deserialize<DateTime?>(jsonSerialization['subscription_end_date']),
      purchased_days_left: serializationManager
          .deserialize<int?>(jsonSerialization['purchased_days_left']),
    );
  }

  static final t = PurchasesTable();

  int userId;

  bool? has_one_time_purchase;

  DateTime? subscription_end_date;

  int? purchased_days_left;

  @override
  String get tableName => 'custom_user_purchases';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'has_one_time_purchase': has_one_time_purchase,
      'subscription_end_date': subscription_end_date,
      'purchased_days_left': purchased_days_left,
    };
  }

  @override
  Map<String, dynamic> toJsonForDatabase() {
    return {
      'id': id,
      'userId': userId,
      'has_one_time_purchase': has_one_time_purchase,
      'subscription_end_date': subscription_end_date,
      'purchased_days_left': purchased_days_left,
    };
  }

  @override
  Map<String, dynamic> allToJson() {
    return {
      'id': id,
      'userId': userId,
      'has_one_time_purchase': has_one_time_purchase,
      'subscription_end_date': subscription_end_date,
      'purchased_days_left': purchased_days_left,
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
      case 'userId':
        userId = value;
        return;
      case 'has_one_time_purchase':
        has_one_time_purchase = value;
        return;
      case 'subscription_end_date':
        subscription_end_date = value;
        return;
      case 'purchased_days_left':
        purchased_days_left = value;
        return;
      default:
        throw UnimplementedError();
    }
  }

  static Future<List<Purchases>> find(
    _i1.Session session, {
    PurchasesExpressionBuilder? where,
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

  static Future<Purchases?> findSingleRow(
    _i1.Session session, {
    PurchasesExpressionBuilder? where,
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

  static Future<Purchases?> findById(
    _i1.Session session,
    int id,
  ) async {
    return session.db.findById<Purchases>(id);
  }

  static Future<int> delete(
    _i1.Session session, {
    required PurchasesExpressionBuilder where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Purchases>(
      where: where(Purchases.t),
      transaction: transaction,
    );
  }

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

  static Future<int> count(
    _i1.Session session, {
    PurchasesExpressionBuilder? where,
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
}

typedef PurchasesExpressionBuilder = _i1.Expression Function(PurchasesTable);

class PurchasesTable extends _i1.Table {
  PurchasesTable() : super(tableName: 'custom_user_purchases');

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  final id = _i1.ColumnInt('id');

  final userId = _i1.ColumnInt('userId');

  final has_one_time_purchase = _i1.ColumnBool('has_one_time_purchase');

  final subscription_end_date = _i1.ColumnDateTime('subscription_end_date');

  final purchased_days_left = _i1.ColumnInt('purchased_days_left');

  @override
  List<_i1.Column> get columns => [
        id,
        userId,
        has_one_time_purchase,
        subscription_end_date,
        purchased_days_left,
      ];
}

@Deprecated('Use PurchasesTable.t instead.')
PurchasesTable tPurchases = PurchasesTable();
