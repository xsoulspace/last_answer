/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class Purchase extends _i1.SerializableEntity {
  Purchase({
    this.id,
    this.source,
    this.status,
    this.purchase_date,
    this.expiry_date,
    required this.userId,
    this.orderId,
    this.productId,
  });

  factory Purchase.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Purchase(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      source:
          serializationManager.deserialize<int?>(jsonSerialization['source']),
      status:
          serializationManager.deserialize<int?>(jsonSerialization['status']),
      purchase_date: serializationManager
          .deserialize<DateTime?>(jsonSerialization['purchase_date']),
      expiry_date: serializationManager
          .deserialize<DateTime?>(jsonSerialization['expiry_date']),
      userId:
          serializationManager.deserialize<int>(jsonSerialization['userId']),
      orderId: serializationManager
          .deserialize<String?>(jsonSerialization['orderId']),
      productId: serializationManager
          .deserialize<String?>(jsonSerialization['productId']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int? source;

  int? status;

  DateTime? purchase_date;

  DateTime? expiry_date;

  int userId;

  String? orderId;

  String? productId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'status': status,
      'purchase_date': purchase_date,
      'expiry_date': expiry_date,
      'userId': userId,
      'orderId': orderId,
      'productId': productId,
    };
  }
}
