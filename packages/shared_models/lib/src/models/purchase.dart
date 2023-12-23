// ignore_for_file: invalid_annotation_target

part of 'models.dart';

enum PurchasePaymentProvider {
  googlePlay,
  appStore;

  factory PurchasePaymentProvider.fromJson(
    final dynamic json,
    // ignore: avoid_unused_constructor_parameters
    final SerializationManager serializationManager,
  ) =>
      PurchasePaymentProvider.values.byName(json);
}

enum PurchasePeriod {
  oneTime,
  monthly,
  yearly,
}

/// use for [PurchaseModel.id]
@Freezed(fromJson: false, toJson: false)
class ProductModelId with _$ProductModelId {
  const factory ProductModelId({
    required final String value,
  }) = _ProductModelId;
  const ProductModelId._();
  factory ProductModelId.fromJson(
    final dynamic value,
    // ignore: avoid_unused_constructor_parameters
    final SerializationManager serializationManager,
  ) =>
      ProductModelId.fromRawJson(value);
  factory ProductModelId.fromRawJson(
    final dynamic value,
  ) =>
      ProductModelId(value: '$value');

  static const empty = ProductModelId(value: '');
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
  String toJson() => value;
  int toInt() => int.parse(value);
}

@freezed
class PurchaseModel with _$PurchaseModel {
  const factory PurchaseModel({
    @JsonKey(fromJson: ProductModelId.fromRawJson)
    @Default(ProductModelId.empty)
    final ProductModelId productId,
    @Default(PurchasePaymentProvider.googlePlay)
    final PurchasePaymentProvider paymentProvider,
    @Default('') final String originalTransactionID,

    /// can contain symbol, so it's not double
    @Default('') final String price,
    @Default(PurchasePeriod.monthly) final PurchasePeriod period,
    @Default(PurchaseAttributesModel.empty)
    final PurchaseAttributesModel attributes,
    final DateTime? willExpireAt,
  }) = _PurchaseModel;
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
  static const empty = PurchaseModel();
  bool get isEmpty => productId.isEmpty;
  bool get isNotEmpty => productId.isNotEmpty;
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
  bool get isOneTime => period == PurchasePeriod.oneTime;
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
