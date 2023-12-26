/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'purchase.dart' as _i2;
import 'purchases.dart' as _i3;
import 'user.dart' as _i4;
import 'package:shared_models/shared_models.dart' as _i5;
import 'package:serverpod_auth_client/module.dart' as _i6;
export 'purchase.dart';
export 'purchases.dart';
export 'user.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Map<Type, _i1.constructor> customConstructors = {};

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (customConstructors.containsKey(t)) {
      return customConstructors[t]!(data, this) as T;
    }
    if (t == _i2.Purchase) {
      return _i2.Purchase.fromJson(data, this) as T;
    }
    if (t == _i3.Purchases) {
      return _i3.Purchases.fromJson(data, this) as T;
    }
    if (t == _i4.User) {
      return _i4.User.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i2.Purchase?>()) {
      return (data != null ? _i2.Purchase.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i3.Purchases?>()) {
      return (data != null ? _i3.Purchases.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i4.User?>()) {
      return (data != null ? _i4.User.fromJson(data, this) : null) as T;
    }
    if (t == _i5.RemoteUserModel) {
      return _i5.RemoteUserModel.fromJson(data, this) as T;
    }
    if (t == _i5.PurchaseModel) {
      return _i5.PurchaseModel.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i5.RemoteUserModel?>()) {
      return (data != null ? _i5.RemoteUserModel.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i5.PurchaseModel?>()) {
      return (data != null ? _i5.PurchaseModel.fromJson(data, this) : null)
          as T;
    }
    try {
      return _i6.Protocol().deserialize<T>(data, t);
    } catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    String? className;
    className = _i6.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    if (data is _i5.RemoteUserModel) {
      return 'RemoteUserModel';
    }
    if (data is _i5.PurchaseModel) {
      return 'PurchaseModel';
    }
    if (data is _i2.Purchase) {
      return 'Purchase';
    }
    if (data is _i3.Purchases) {
      return 'Purchases';
    }
    if (data is _i4.User) {
      return 'User';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'].startsWith('serverpod_auth.')) {
      data['className'] = data['className'].substring(15);
      return _i6.Protocol().deserializeByClassName(data);
    }
    if (data['className'] == 'RemoteUserModel') {
      return deserialize<_i5.RemoteUserModel>(data['data']);
    }
    if (data['className'] == 'PurchaseModel') {
      return deserialize<_i5.PurchaseModel>(data['data']);
    }
    if (data['className'] == 'Purchase') {
      return deserialize<_i2.Purchase>(data['data']);
    }
    if (data['className'] == 'Purchases') {
      return deserialize<_i3.Purchases>(data['data']);
    }
    if (data['className'] == 'User') {
      return deserialize<_i4.User>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
