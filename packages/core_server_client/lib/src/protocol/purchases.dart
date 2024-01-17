/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Purchases extends _i1.SerializableEntity {
  Purchases._({
    this.id,
    required this.purchasedDaysLeft,
    required this.hasOneTimePurchase,
    this.subscriptionEndDate,
    required this.userId,
  });

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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int purchasedDaysLeft;

  bool hasOneTimePurchase;

  DateTime? subscriptionEndDate;

  int userId;

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
