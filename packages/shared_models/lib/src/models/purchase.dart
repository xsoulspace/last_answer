// ignore_for_file: invalid_annotation_target

part of 'models.dart';

enum PurchasePaymentProvider { googlePlay, appStore }

enum OneTimePurchaseStatus { pending, completed, cancelled }

enum SubscriptionStatus { pending, active, expired }

enum PurchasePeriod { oneTime, monthly, yearly }

enum AdVideoLengthType { s, m, l }

enum IAPId {
  // 'last_answer_annual_subscription_2022',
  // 'last_answer_monthly_subscription_2022',
  @JsonValue('pro_one_time_purchase')
  proOneTimePurchase(
    'pro_one_time_purchase',
    productType: PurchaseType.oneTimePurchase,
  );

  const IAPId(this.id, {required this.productType});
  factory IAPId.byId(final String id) {
    final maybeId = IAPId.values.firstWhereOrNull((final e) => e.id == id);
    if (maybeId == null) {
      throw ArgumentError.value('$id is not a known product');
    }
    return maybeId;
  }
  final String id;
  final PurchaseType productType;
  static final ids = IAPId.values.map((final e) => e.id).toSet();
}

@Freezed()
class PurchaseRequestDtoModel with _$PurchaseRequestDtoModel {
  const factory PurchaseRequestDtoModel({
    required final IAPId productId,
    required final PurchasePaymentProvider provider,
    required final PurchaseType type,
  }) = _PurchaseRequestDtoModel;
  factory PurchaseRequestDtoModel.fromJson(
    final Map<String, dynamic> json,
    // ignore: avoid_unused_constructor_parameters
    final SerializationManager serializationManager,
  ) =>
      PurchaseRequestDtoModel.fromRawJson(json);
  factory PurchaseRequestDtoModel.fromRawJson(
    final Map<String, dynamic> json,
  ) =>
      _$PurchaseRequestDtoModelFromJson(json);
  const PurchaseRequestDtoModel._();
}

enum PurchaseType { videoAward, subscription, oneTimePurchase }

@Freezed(unionKey: 'type')
class PurchaseActionModel with _$PurchaseActionModel {
  @FreezedUnionValue('videoAward')
  const factory PurchaseActionModel.videoAward({
    @Default(UserModelId.empty) final UserModelId userId,
    @Default(PurchaseType.videoAward) final PurchaseType type,
    @Default(0) final int rewardDaysQuantity,
    final DateTime? createdAt,
  }) = PurchaseActionModelVideoAward;
  const PurchaseActionModel._();
  factory PurchaseActionModel.fromJson(final Map<String, dynamic> json) =>
      PurchaseActionModel.fromRawJson(json);
  factory PurchaseActionModel.fromRawJson(
    final Map<String, dynamic> json,
  ) =>
      _$PurchaseActionModelFromJson(json);

  static const empty = PurchaseActionModel.videoAward();
  String get id => '${userId.value}_${createdAt?.millisecondsSinceEpoch}';
  bool get isEmpty => userId.isEmpty || createdAt == null;
  bool get isNotEmpty => !isEmpty;
}
