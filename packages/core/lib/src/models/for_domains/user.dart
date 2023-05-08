// ignore_for_file: invalid_annotation_target, prefer_constructors_over_static_methods

part of '../models.dart';

@freezed
class UserModelId with _$UserModelId {
  const factory UserModelId.local({
    required final String value,
  }) = UserModelLocalId;
  const factory UserModelId.remote({
    required final String value,
  }) = UserModelRemoteId;
  const UserModelId._();
  static UserModelLocalId create() =>
      UserModelLocalId(value: IdCreator.create());
  static String toStringJson(final UserModelId obj) => obj.value;
  static UserModelLocalId localFromJson(final String value) =>
      UserModelLocalId(value: value);
  static UserModelRemoteId remoteFromJson(final String value) =>
      UserModelRemoteId(value: value);
  static const remoteEmpty = UserModelRemoteId(value: '');
  static const localEmpty = UserModelLocalId(value: '');
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
}

@immutable
@Freezed()
class UserModel with _$UserModel {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory UserModel({
    @JsonKey(
      fromJson: UserModelId.localFromJson,
      toJson: UserModelId.toStringJson,
    )
        required final UserModelLocalId localId,
    @JsonKey(
      fromJson: UserModelId.remoteFromJson,
      toJson: UserModelId.toStringJson,
    )
        required final UserModelRemoteId remoteId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final SubscriptionModel subscription,
  }) = _UserModel;
  const UserModel._();
  factory UserModel.fromJson(final Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  factory UserModel.fromFirestore(
    final DocumentSnapshot<Map<String, dynamic>> snapshot,
    // ignore: avoid_unused_constructor_parameters
    final SnapshotOptions? options,
  ) {
    final json = snapshot.data()!;
    return UserModel.fromJson(json);
  }
  static Map<String, Object?> toFirestore(
    final UserModel value,
    final SetOptions? options,
  ) =>
      value.toJson();
  @useResult
  UserPermissionsModel get permissions =>
      UserPermissionsModel.fromSubscription(subscription);
  static final empty = UserModel(
    createdAt: DateTime.now(),
    localId: UserModelId.localEmpty,
    remoteId: UserModelId.remoteEmpty,
    subscription: SubscriptionModel.empty,
    updatedAt: DateTime.now(),
  );
}

@immutable
@Freezed()
class SubscriptionModel with _$SubscriptionModel {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory SubscriptionModel({
    @Default(0) final int paidDaysLeft,
    final DateTime? updatedAt,
  }) = _SubscriptionModel;
  factory SubscriptionModel.fromJson(final Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
  static const empty = SubscriptionModel();
}

@immutable
@Freezed()
class UserPermissionsModel with _$UserPermissionsModel {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory UserPermissionsModel({
    @Default(false) final bool shouldBeSynced,
    @Default(5) final int tagLimit,
  }) = _UserPermissionsModel;
  factory UserPermissionsModel.fromJson(final Map<String, dynamic> json) =>
      _$UserPermissionsModelFromJson(json);
  factory UserPermissionsModel.fromSubscription(
    final SubscriptionModel subscription,
  ) =>
      subscription.paidDaysLeft > 0 ? paidAccess : freeAccess;
  static const freeAccess = UserPermissionsModel();
  static const paidAccess = UserPermissionsModel(
    shouldBeSynced: true,
    tagLimit: 50,
  );
}
