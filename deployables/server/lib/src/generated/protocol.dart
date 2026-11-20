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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i3;
import 'purchase.dart' as _i4;
import 'purchases.dart' as _i5;
import 'user.dart' as _i6;
import 'package:shared_models/shared_models.dart' as _i7;
export 'purchase.dart';
export 'purchases.dart';
export 'user.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'custom_users',
      dartName: 'User',
      schema: 'public',
      module: 'server',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'custom_users_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'custom_users_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'purchases_history',
      dartName: 'PurchaseAction',
      schema: 'public',
      module: 'server',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'purchases_history_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'rewardDaysQuantity',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'purchases_history_fk_0',
          columns: ['userId'],
          referenceTable: 'custom_users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'purchases_history_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'user_purchase_info',
      dartName: 'UserPurchaseInfo',
      schema: 'public',
      module: 'server',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'user_purchase_info_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'daysOfSupporterLeft',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'isOneTimePurchased',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'subscriptionEndDate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'user_purchase_info_fk_0',
          columns: ['userId'],
          referenceTable: 'custom_users',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'user_purchase_info_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i4.PurchaseAction) {
      return _i4.PurchaseAction.fromJson(data) as T;
    }
    if (t == _i5.UserPurchaseInfo) {
      return _i5.UserPurchaseInfo.fromJson(data) as T;
    }
    if (t == _i6.User) {
      return _i6.User.fromJson(data) as T;
    }
    if (t == _i1.getType<_i4.PurchaseAction?>()) {
      return (data != null ? _i4.PurchaseAction.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.UserPurchaseInfo?>()) {
      return (data != null ? _i5.UserPurchaseInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.User?>()) {
      return (data != null ? _i6.User.fromJson(data) : null) as T;
    }
    if (t == _i7.RemoteUserModel) {
      return _i7.RemoteUserModel.fromJson(data) as T;
    }
    if (t == _i7.PurchaseActionModel) {
      return _i7.PurchaseActionModel.fromJson(data) as T;
    }
    if (t == _i1.getType<_i7.RemoteUserModel?>()) {
      return (data != null ? _i7.RemoteUserModel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.PurchaseActionModel?>()) {
      return (data != null ? _i7.PurchaseActionModel.fromJson(data) : null)
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i7.RemoteUserModel) {
      return 'RemoteUserModel';
    }
    if (data is _i7.PurchaseActionModel) {
      return 'PurchaseActionModel';
    }
    if (data is _i4.PurchaseAction) {
      return 'PurchaseAction';
    }
    if (data is _i5.UserPurchaseInfo) {
      return 'UserPurchaseInfo';
    }
    if (data is _i6.User) {
      return 'User';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'RemoteUserModel') {
      return deserialize<_i7.RemoteUserModel>(data['data']);
    }
    if (dataClassName == 'PurchaseActionModel') {
      return deserialize<_i7.PurchaseActionModel>(data['data']);
    }
    if (dataClassName == 'PurchaseAction') {
      return deserialize<_i4.PurchaseAction>(data['data']);
    }
    if (dataClassName == 'UserPurchaseInfo') {
      return deserialize<_i5.UserPurchaseInfo>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i6.User>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i3.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i4.PurchaseAction:
        return _i4.PurchaseAction.t;
      case _i5.UserPurchaseInfo:
        return _i5.UserPurchaseInfo.t;
      case _i6.User:
        return _i6.User.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'server';
}
