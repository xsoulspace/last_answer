// ignore_for_file: invalid_annotation_target

part of 'models.dart';

@freezed
class RemoteUserModel with _$RemoteUserModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RemoteUserModel({
    @Default(UserModelId.empty) final UserModelId id,
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
  bool get isNotEmpty => !isEmpty;
}

@freezed
class PurchasesModel with _$PurchasesModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PurchasesModel({
    /// If user purchased the app for one time
    /// he should have all access indefinitely
    ///
    /// Priority one to develop.
    @Default(false) final bool isOneTimePurchased,

    /// If user purchased the app for subscription
    /// then he should have access until the end of subscription
    final DateTime? subscriptionEndDate,

    /// If user purchased certain amount of days
    /// then he should have access until [daysOfSupporterLeft] > 0
    @Default(0) final int daysOfSupporterLeft,

    /// Summary of any supporter days that user had.
    /// This is a sum of all [daysOfSupporterLeft] or
    /// received by subscription [subscriptionEndDate] that
    /// was used.
    @Default(0) final int supporterDaysCount,
  }) = _PurchasesModel;
  factory PurchasesModel.fromJson(final Map<String, dynamic> json) =>
      _$PurchasesModelFromJson(json);
  const PurchasesModel._();
  static const empty = PurchasesModel();
  bool get hasActiveSubscription =>
      subscriptionEndDate != null &&
      subscriptionEndDate?.isAfter(DateTime.now()) == true;
  bool get isActive =>
      isOneTimePurchased || hasActiveSubscription || daysOfSupporterLeft > 0;
  PurchasesModel mergeWith(final PurchasesModel other) {
    final thisDate = subscriptionEndDate;
    final otherDate = other.subscriptionEndDate;
    final DateTime? newDate;
    if (otherDate != null) {
      if (thisDate != null) {
        newDate = thisDate.isAfter(otherDate) ? thisDate : otherDate;
      } else {
        newDate = otherDate;
      }
    } else {
      newDate = thisDate;
    }

    return PurchasesModel(
      isOneTimePurchased: isOneTimePurchased || other.isOneTimePurchased,
      subscriptionEndDate: newDate,
      daysOfSupporterLeft: daysOfSupporterLeft + other.daysOfSupporterLeft,
      supporterDaysCount: supporterDaysCount + other.supporterDaysCount,
    );
  }
}
