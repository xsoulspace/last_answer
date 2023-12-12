// ignore_for_file: invalid_annotation_target

part of 'models.dart';

@freezed
class RemoteUserModel with _$RemoteUserModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RemoteUserModel({
    @Default(UserModelId.empty) final UserModelId id,
    @Default(PurchasesModel.empty) final PurchasesModel purchases,
  }) = _RemoteUserModel;
  factory RemoteUserModel.fromRawJson(final Map<String, dynamic> json) =>
      _$RemoteUserModelFromJson(json);
  factory RemoteUserModel.fromJson(
    final Map<String, dynamic> json,
    // ignore: avoid_unused_constructor_parameters
    final SerializationManager serializationManager,
  ) =>
      _$RemoteUserModelFromJson(json);
  const RemoteUserModel._();
  static const empty = RemoteUserModel();
  bool get isEmpty => id.isEmpty;
}

@freezed
class PurchasesModel with _$PurchasesModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PurchasesModel({
    /// If user purchased the app for one time
    /// he should have all access indefinitely
    ///
    /// Priority one to develop.
    @Default(false) final bool hasOneTimePurchase,

    /// If user purchased the app for subscription
    /// then he should have access until the end of subscription
    final DateTime? subscriptionEndDate,

    /// If user purchased certain amount of days
    /// then he should have access until [purchasedDaysLeft] > 0
    @Default(0) final int purchasedDaysLeft,
  }) = _PurchasesModel;
  factory PurchasesModel.fromJson(final Map<String, dynamic> json) =>
      _$PurchasesModelFromJson(json);
  const PurchasesModel._();
  static const empty = PurchasesModel();
  bool get hasSubscription =>
      subscriptionEndDate != null &&
      subscriptionEndDate?.isAfter(DateTime.now()) == true;
  bool get isPurchased =>
      hasOneTimePurchase || hasSubscription || purchasedDaysLeft > 0;
}
