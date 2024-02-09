/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod_serialization/serverpod_serialization.dart';

abstract class PurchaseAction extends _i1.TableRow {
  PurchaseAction._({
    int? id,
    required this.userId,
    required this.type,
    required this.rewardDaysQuantity,
    required this.createdAt,
  }) : super(id);

  factory PurchaseAction({
    int? id,
    required int userId,
    required String type,
    required int rewardDaysQuantity,
    required DateTime createdAt,
  }) = _PurchaseActionImpl;

  factory PurchaseAction.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return PurchaseAction(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      userId:
          serializationManager.deserialize<int>(jsonSerialization['userId']),
      type: serializationManager.deserialize<String>(jsonSerialization['type']),
      rewardDaysQuantity: serializationManager
          .deserialize<int>(jsonSerialization['rewardDaysQuantity']),
      createdAt: serializationManager
          .deserialize<DateTime>(jsonSerialization['createdAt']),
    );
  }

  static final t = PurchaseActionTable();

  static const db = PurchaseActionRepository._();

  int userId;

  String type;

  int rewardDaysQuantity;

  DateTime createdAt;

  @override
  _i1.Table get table => t;

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
      if (id != null) 'id': id,
      'userId': userId,
      'type': type,
      'rewardDaysQuantity': rewardDaysQuantity,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  @Deprecated('Will be removed in 2.0.0')
  Map<String, dynamic> toJsonForDatabase() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'rewardDaysQuantity': rewardDaysQuantity,
      'createdAt': createdAt,
    };
  }

  @override
  Map<String, dynamic> allToJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'type': type,
      'rewardDaysQuantity': rewardDaysQuantity,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  @Deprecated('Will be removed in 2.0.0')
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
      case 'type':
        type = value;
        return;
      case 'rewardDaysQuantity':
        rewardDaysQuantity = value;
        return;
      case 'createdAt':
        createdAt = value;
        return;
      default:
        throw UnimplementedError();
    }
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.find instead.')
  static Future<List<PurchaseAction>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? limit,
    int? offset,
    _i1.Column? orderBy,
    List<_i1.Order>? orderByList,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PurchaseAction>(
      where: where != null ? where(PurchaseAction.t) : null,
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
  static Future<PurchaseAction?> findSingleRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? offset,
    _i1.Column? orderBy,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findSingleRow<PurchaseAction>(
      where: where != null ? where(PurchaseAction.t) : null,
      offset: offset,
      orderBy: orderBy,
      orderDescending: orderDescending,
      useCache: useCache,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.findById instead.')
  static Future<PurchaseAction?> findById(
    _i1.Session session,
    int id,
  ) async {
    return session.db.findById<PurchaseAction>(id);
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteWhere instead.')
  static Future<int> delete(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PurchaseActionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PurchaseAction>(
      where: where(PurchaseAction.t),
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteRow instead.')
  static Future<bool> deleteRow(
    _i1.Session session,
    PurchaseAction row, {
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
    PurchaseAction row, {
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
    PurchaseAction row, {
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
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? limit,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PurchaseAction>(
      where: where != null ? where(PurchaseAction.t) : null,
      limit: limit,
      useCache: useCache,
      transaction: transaction,
    );
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

class PurchaseActionTable extends _i1.Table {
  PurchaseActionTable({super.tableRelation})
      : super(tableName: 'purchases_history') {
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

@Deprecated('Use PurchaseActionTable.t instead.')
PurchaseActionTable tPurchaseAction = PurchaseActionTable();

class PurchaseActionInclude extends _i1.IncludeObject {
  PurchaseActionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => PurchaseAction.t;
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
  _i1.Table get table => PurchaseAction.t;
}

class PurchaseActionRepository {
  const PurchaseActionRepository._();

  Future<List<PurchaseAction>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PurchaseActionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchaseActionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.find<PurchaseAction>(
      where: where?.call(PurchaseAction.t),
      orderBy: orderBy?.call(PurchaseAction.t),
      orderByList: orderByList?.call(PurchaseAction.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<PurchaseAction?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? offset,
    _i1.OrderByBuilder<PurchaseActionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PurchaseActionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findFirstRow<PurchaseAction>(
      where: where?.call(PurchaseAction.t),
      orderBy: orderBy?.call(PurchaseAction.t),
      orderByList: orderByList?.call(PurchaseAction.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<PurchaseAction?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findById<PurchaseAction>(
      id,
      transaction: transaction,
    );
  }

  Future<List<PurchaseAction>> insert(
    _i1.Session session,
    List<PurchaseAction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insert<PurchaseAction>(
      rows,
      transaction: transaction,
    );
  }

  Future<PurchaseAction> insertRow(
    _i1.Session session,
    PurchaseAction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insertRow<PurchaseAction>(
      row,
      transaction: transaction,
    );
  }

  Future<List<PurchaseAction>> update(
    _i1.Session session,
    List<PurchaseAction> rows, {
    _i1.ColumnSelections<PurchaseActionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.update<PurchaseAction>(
      rows,
      columns: columns?.call(PurchaseAction.t),
      transaction: transaction,
    );
  }

  Future<PurchaseAction> updateRow(
    _i1.Session session,
    PurchaseAction row, {
    _i1.ColumnSelections<PurchaseActionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.updateRow<PurchaseAction>(
      row,
      columns: columns?.call(PurchaseAction.t),
      transaction: transaction,
    );
  }

  Future<List<int>> delete(
    _i1.Session session,
    List<PurchaseAction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.delete<PurchaseAction>(
      rows,
      transaction: transaction,
    );
  }

  Future<int> deleteRow(
    _i1.Session session,
    PurchaseAction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteRow<PurchaseAction>(
      row,
      transaction: transaction,
    );
  }

  Future<List<int>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PurchaseActionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteWhere<PurchaseAction>(
      where: where(PurchaseAction.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PurchaseActionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.count<PurchaseAction>(
      where: where?.call(PurchaseAction.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
