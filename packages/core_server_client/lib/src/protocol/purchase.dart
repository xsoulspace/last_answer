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

abstract class PurchaseAction implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  String type;

  int rewardDaysQuantity;

  DateTime createdAt;

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
