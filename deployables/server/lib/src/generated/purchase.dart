/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class PurchaseAction
    implements _i1.TableRow, _i1.ProtocolSerialization {
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
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
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
  Map<String, dynamic> toJsonForProtocol() {
    return {
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
    return session.db.find<PurchaseAction>(
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
    return session.db.findFirstRow<PurchaseAction>(
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
    return session.db.findById<PurchaseAction>(
      id,
      transaction: transaction,
    );
  }

  Future<List<PurchaseAction>> insert(
    _i1.Session session,
    List<PurchaseAction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PurchaseAction>(
      rows,
      transaction: transaction,
    );
  }

  Future<PurchaseAction> insertRow(
    _i1.Session session,
    PurchaseAction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PurchaseAction>(
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
    return session.db.update<PurchaseAction>(
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
    return session.db.updateRow<PurchaseAction>(
      row,
      columns: columns?.call(PurchaseAction.t),
      transaction: transaction,
    );
  }

  Future<List<PurchaseAction>> delete(
    _i1.Session session,
    List<PurchaseAction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PurchaseAction>(
      rows,
      transaction: transaction,
    );
  }

  Future<PurchaseAction> deleteRow(
    _i1.Session session,
    PurchaseAction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PurchaseAction>(
      row,
      transaction: transaction,
    );
  }

  Future<List<PurchaseAction>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PurchaseActionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PurchaseAction>(
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
    return session.db.count<PurchaseAction>(
      where: where?.call(PurchaseAction.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
