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

abstract class UserPurchaseInfo
    implements _i1.TableRow, _i1.ProtocolSerialization {
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
      isOneTimePurchased: jsonSerialization['isOneTimePurchased'] as bool,
      subscriptionEndDate: jsonSerialization['subscriptionEndDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['subscriptionEndDate']),
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
  _i1.Table get table => t;

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

class UserPurchaseInfoTable extends _i1.Table {
  UserPurchaseInfoTable({super.tableRelation})
      : super(tableName: 'user_purchase_info') {
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
    return session.db.find<UserPurchaseInfo>(
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
    return session.db.findFirstRow<UserPurchaseInfo>(
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
    return session.db.findById<UserPurchaseInfo>(
      id,
      transaction: transaction,
    );
  }

  Future<List<UserPurchaseInfo>> insert(
    _i1.Session session,
    List<UserPurchaseInfo> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<UserPurchaseInfo>(
      rows,
      transaction: transaction,
    );
  }

  Future<UserPurchaseInfo> insertRow(
    _i1.Session session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserPurchaseInfo>(
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
    return session.db.update<UserPurchaseInfo>(
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
    return session.db.updateRow<UserPurchaseInfo>(
      row,
      columns: columns?.call(UserPurchaseInfo.t),
      transaction: transaction,
    );
  }

  Future<List<UserPurchaseInfo>> delete(
    _i1.Session session,
    List<UserPurchaseInfo> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserPurchaseInfo>(
      rows,
      transaction: transaction,
    );
  }

  Future<UserPurchaseInfo> deleteRow(
    _i1.Session session,
    UserPurchaseInfo row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserPurchaseInfo>(
      row,
      transaction: transaction,
    );
  }

  Future<List<UserPurchaseInfo>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserPurchaseInfoTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserPurchaseInfo>(
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
    return session.db.count<UserPurchaseInfo>(
      where: where?.call(UserPurchaseInfo.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
