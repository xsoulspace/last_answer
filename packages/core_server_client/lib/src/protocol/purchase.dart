/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Purchase extends _i1.SerializableEntity {
  Purchase._({
    this.id,
    this.source,
    this.status,
    this.purchaseDate,
    this.expiryDate,
    required this.daysBought,
    required this.userId,
    this.orderId,
    this.productId,
  });

  factory Purchase({
    int? id,
    int? source,
    int? status,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    required int daysBought,
    required int userId,
    String? orderId,
    String? productId,
  }) = _PurchaseImpl;

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
      purchaseDate: serializationManager
          .deserialize<DateTime?>(jsonSerialization['purchaseDate']),
      expiryDate: serializationManager
          .deserialize<DateTime?>(jsonSerialization['expiryDate']),
      daysBought: serializationManager
          .deserialize<int>(jsonSerialization['daysBought']),
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

  DateTime? purchaseDate;

  DateTime? expiryDate;

  int daysBought;

  int userId;

  String? orderId;

  String? productId;

  Purchase copyWith({
    int? id,
    int? source,
    int? status,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    int? daysBought,
    int? userId,
    String? orderId,
    String? productId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (purchaseDate != null) 'purchaseDate': purchaseDate,
      if (expiryDate != null) 'expiryDate': expiryDate,
      'daysBought': daysBought,
      'userId': userId,
      if (orderId != null) 'orderId': orderId,
      if (productId != null) 'productId': productId,
    };
  }
}

class _Undefined {}

class _PurchaseImpl extends Purchase {
  _PurchaseImpl({
    int? id,
    int? source,
    int? status,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    required int daysBought,
    required int userId,
    String? orderId,
    String? productId,
  }) : super._(
          id: id,
          source: source,
          status: status,
          purchaseDate: purchaseDate,
          expiryDate: expiryDate,
          daysBought: daysBought,
          userId: userId,
          orderId: orderId,
          productId: productId,
        );

  @override
  Purchase copyWith({
    Object? id = _Undefined,
    Object? source = _Undefined,
    Object? status = _Undefined,
    Object? purchaseDate = _Undefined,
    Object? expiryDate = _Undefined,
    int? daysBought,
    int? userId,
    Object? orderId = _Undefined,
    Object? productId = _Undefined,
  }) {
    return Purchase(
      id: id is int? ? id : this.id,
      source: source is int? ? source : this.source,
      status: status is int? ? status : this.status,
      purchaseDate:
          purchaseDate is DateTime? ? purchaseDate : this.purchaseDate,
      expiryDate: expiryDate is DateTime? ? expiryDate : this.expiryDate,
      daysBought: daysBought ?? this.daysBought,
      userId: userId ?? this.userId,
      orderId: orderId is String? ? orderId : this.orderId,
      productId: productId is String? ? productId : this.productId,
    );
  }
}
