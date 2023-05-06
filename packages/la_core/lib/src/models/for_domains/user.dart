// ignore_for_file: invalid_annotation_target

part of '../models.dart';

@freezed
class UserModelId with _$UserModelId {
  const factory UserModelId({
    required final String value,
  }) = _UserModelId;
  factory UserModelId.fromJson(final String value) => UserModelId(value: value);
  static String toStringJson(final UserModelId obj) => obj.value;
}

@immutable
@Freezed()
class UserModel with _$UserModel {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory UserModel({
    @JsonKey(
      fromJson: UserModelId.fromJson,
      toJson: UserModelId.toStringJson,
    )
        required final UserModelId id,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final SubscriptionModel subscription,
  }) = _UserModel;
  const UserModel._();
  factory UserModel.fromJson(final Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  @useResult
  UserPermissionsModel get permissions =>
      UserPermissionsModel.fromSubscription(subscription);
}

@immutable
@Freezed()
class SubscriptionModel with _$SubscriptionModel {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory SubscriptionModel({
    @Default(0) final int paidDaysLeft,
  }) = _SubscriptionModel;
  factory SubscriptionModel.fromJson(final Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
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
