// ignore_for_file: invalid_annotation_target

part of 'models.dart';

enum PurchasePaymentProvider { googlePlay, appStore }

enum OneTimePurchaseStatus { pending, completed, cancelled }

enum SubscriptionStatus { pending, active, expired }

enum ProductType { subscription, oneTime }

enum PurchasePeriod { oneTime, monthly, yearly }

enum IAPId {
  @JsonValue('pro_one_time_purchase')
  // 'last_answer_annual_subscription_2022',
  // 'last_answer_monthly_subscription_2022',
  proOneTimePurchase('pro_one_time_purchase', productType: ProductType.oneTime);

  const IAPId(this.id, {required this.productType});
  factory IAPId.byId(final String id) {
    final maybeId = IAPId.values.firstWhereOrNull((final e) => e.id == id);
    if (maybeId == null) {
      throw ArgumentError.value('$id is not a known product');
    }
    return maybeId;
  }
  final String id;
  final ProductType productType;
  static final ids = IAPId.values.map((final e) => e.id).toSet();
}

@Freezed()
class PurchaseRequestDtoModel with _$PurchaseRequestDtoModel {
  const factory PurchaseRequestDtoModel({
    required final IAPId productId,
    required final PurchasePaymentProvider provider,
    required final ProductType type,
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

@Freezed(unionKey: 'type')
class PurchaseModel with _$PurchaseModel {
  const factory PurchaseModel.oneTime({
    @Default(IAPId.proOneTimePurchase) final IAPId productId,
    @Default(PurchasePaymentProvider.googlePlay)
    final PurchasePaymentProvider paymentProvider,
    @Default('') final String originalTransactionID,
    final DateTime? purchasedAt,

    /// can contain symbol, so it's not double
    @Default('') final String price,
    @Default(PurchasePeriod.monthly) final PurchasePeriod period,
    @Default(PurchaseAttributesModel.empty)
    final PurchaseAttributesModel attributes,
    final DateTime? willExpireAt,
    @Default(UserModelId.empty) final UserModelId userId,
    @Default(ProductType.oneTime) final ProductType type,
    @Default(OneTimePurchaseStatus.pending) final OneTimePurchaseStatus status,
  }) = PurchaseModelOneTime;
  const factory PurchaseModel.subscription({
    @Default(IAPId.proOneTimePurchase) final IAPId productId,
    @Default(PurchasePaymentProvider.googlePlay)
    final PurchasePaymentProvider paymentProvider,
    @Default('') final String originalTransactionID,
    final DateTime? purchasedAt,

    /// can contain symbol, so it's not double
    @Default('') final String price,
    @Default(PurchasePeriod.monthly) final PurchasePeriod period,
    @Default(PurchaseAttributesModel.empty)
    final PurchaseAttributesModel attributes,
    final DateTime? willExpireAt,
    @Default(UserModelId.empty) final UserModelId userId,
    @Default(ProductType.subscription) final ProductType type,
    @Default(SubscriptionStatus.pending) final SubscriptionStatus status,
  }) = PurchaseModelSubscription;
  const PurchaseModel._();
  factory PurchaseModel.fromJson(
    final Map<String, dynamic> json,
    // ignore: avoid_unused_constructor_parameters
    final SerializationManager serializationManager,
  ) =>
      PurchaseModel.fromRawJson(json);
  factory PurchaseModel.fromRawJson(
    final Map<String, dynamic> json,
  ) =>
      _$PurchaseModelFromJson(json);

  static const empty = PurchaseModel.oneTime();
  String get id => '${paymentProvider.name}_$originalTransactionID';
  bool get isEmpty => originalTransactionID.isEmpty;
  bool get isNotEmpty => originalTransactionID.isNotEmpty;
  bool isActive() {
    if (isOneTime) return true;
    final willExpireAt = this.willExpireAt;
    if (willExpireAt == null) {
      assert(false, 'expiryDateTime cannot be null for subscription');
      return false;
    }
    return willExpireAt.isAfter(DateTime.now()) == true;
  }

  bool get isYearly => period == PurchasePeriod.yearly;
  bool get isMonthly => period == PurchasePeriod.monthly;
  bool get isOneTime =>
      period == PurchasePeriod.oneTime && type == ProductType.oneTime;
}

@freezed
class PurchaseAttributesModel with _$PurchaseAttributesModel {
  const factory PurchaseAttributesModel({
    @Default(false) final bool isCancelled,
    @Default(UserModelId.empty) final UserModelId customerId,
  }) = _PurchaseAttributesModel;
  factory PurchaseAttributesModel.fromJson(final Map<String, dynamic> json) =>
      _$PurchaseAttributesModelFromJson(json);

  static const empty = PurchaseAttributesModel();
}
