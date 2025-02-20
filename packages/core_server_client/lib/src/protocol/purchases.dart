/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class UserPurchaseInfo implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int daysOfSupporterLeft;

  bool isOneTimePurchased;

  DateTime? subscriptionEndDate;

  int userId;

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
