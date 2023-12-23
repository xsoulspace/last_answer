// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmojiModelImpl _$$EmojiModelImplFromJson(Map<String, dynamic> json) =>
    _$EmojiModelImpl(
      category: json['category'] as String,
      emoji: json['emoji'] as String,
      keywords: json['keywords'] as String,
    );

Map<String, dynamic> _$$EmojiModelImplToJson(_$EmojiModelImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'emoji': instance.emoji,
      'keywords': instance.keywords,
    };

_$PurchaseRequestDtoModelImpl _$$PurchaseRequestDtoModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseRequestDtoModelImpl(
      productId: ProductModelId.fromRawJson(json['productId']),
      provider: PurchasePaymentProvider.fromRawJson(json['provider']),
      type: $enumDecode(_$ProductTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$PurchaseRequestDtoModelImplToJson(
        _$PurchaseRequestDtoModelImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'provider': _$PurchasePaymentProviderEnumMap[instance.provider]!,
      'type': _$ProductTypeEnumMap[instance.type]!,
    };

const _$ProductTypeEnumMap = {
  ProductType.subscription: 'subscription',
  ProductType.oneTime: 'oneTime',
};

const _$PurchasePaymentProviderEnumMap = {
  PurchasePaymentProvider.googlePlay: 'googlePlay',
  PurchasePaymentProvider.appStore: 'appStore',
};

_$PurchaseModelImpl _$$PurchaseModelImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseModelImpl(
      productId: json['productId'] == null
          ? ProductModelId.empty
          : ProductModelId.fromRawJson(json['productId']),
      paymentProvider: json['paymentProvider'] == null
          ? PurchasePaymentProvider.googlePlay
          : PurchasePaymentProvider.fromRawJson(json['paymentProvider']),
      originalTransactionID: json['originalTransactionID'] as String? ?? '',
      price: json['price'] as String? ?? '',
      period: $enumDecodeNullable(_$PurchasePeriodEnumMap, json['period']) ??
          PurchasePeriod.monthly,
      attributes: json['attributes'] == null
          ? PurchaseAttributesModel.empty
          : PurchaseAttributesModel.fromJson(
              json['attributes'] as Map<String, dynamic>),
      willExpireAt: json['willExpireAt'] == null
          ? null
          : DateTime.parse(json['willExpireAt'] as String),
    );

Map<String, dynamic> _$$PurchaseModelImplToJson(_$PurchaseModelImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'paymentProvider':
          _$PurchasePaymentProviderEnumMap[instance.paymentProvider]!,
      'originalTransactionID': instance.originalTransactionID,
      'price': instance.price,
      'period': _$PurchasePeriodEnumMap[instance.period]!,
      'attributes': instance.attributes,
      'willExpireAt': instance.willExpireAt?.toIso8601String(),
    };

const _$PurchasePeriodEnumMap = {
  PurchasePeriod.oneTime: 'oneTime',
  PurchasePeriod.monthly: 'monthly',
  PurchasePeriod.yearly: 'yearly',
};

_$PurchaseAttributesModelImpl _$$PurchaseAttributesModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseAttributesModelImpl(
      isCancelled: json['isCancelled'] as bool? ?? false,
      customerId: json['customerId'] == null
          ? UserModelId.empty
          : UserModelId.fromJson(json['customerId']),
    );

Map<String, dynamic> _$$PurchaseAttributesModelImplToJson(
        _$PurchaseAttributesModelImpl instance) =>
    <String, dynamic>{
      'isCancelled': instance.isCancelled,
      'customerId': instance.customerId,
    };

_$RemoteUserModelImpl _$$RemoteUserModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RemoteUserModelImpl(
      id: json['id'] == null
          ? UserModelId.empty
          : UserModelId.fromJson(json['id']),
      purchases: json['purchases'] == null
          ? PurchasesModel.empty
          : PurchasesModel.fromJson(json['purchases'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$RemoteUserModelImplToJson(
        _$RemoteUserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchases': instance.purchases,
    };

_$PurchasesModelImpl _$$PurchasesModelImplFromJson(Map<String, dynamic> json) =>
    _$PurchasesModelImpl(
      hasOneTimePurchase: json['has_one_time_purchase'] as bool? ?? false,
      subscriptionEndDate: json['subscription_end_date'] == null
          ? null
          : DateTime.parse(json['subscription_end_date'] as String),
      purchasedDaysLeft: json['purchased_days_left'] as int? ?? 0,
      activePurchase: json['active_purchase'] == null
          ? PurchaseModel.empty
          : PurchaseModel.fromRawJson(
              json['active_purchase'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PurchasesModelImplToJson(
        _$PurchasesModelImpl instance) =>
    <String, dynamic>{
      'has_one_time_purchase': instance.hasOneTimePurchase,
      'subscription_end_date': instance.subscriptionEndDate?.toIso8601String(),
      'purchased_days_left': instance.purchasedDaysLeft,
      'active_purchase': instance.activePurchase,
    };
