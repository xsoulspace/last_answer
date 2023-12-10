/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class Purchases extends _i1.SerializableEntity {
  Purchases({
    this.id,
    required this.userId,
    required this.has_one_time_purchase,
    required this.subscription_end_date,
    required this.purchased_days_left,
  });

  factory Purchases.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Purchases(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      userId:
          serializationManager.deserialize<int>(jsonSerialization['userId']),
      has_one_time_purchase: serializationManager
          .deserialize<bool>(jsonSerialization['has_one_time_purchase']),
      subscription_end_date: serializationManager
          .deserialize<DateTime>(jsonSerialization['subscription_end_date']),
      purchased_days_left: serializationManager
          .deserialize<int>(jsonSerialization['purchased_days_left']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  bool has_one_time_purchase;

  DateTime subscription_end_date;

  int purchased_days_left;

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
}
