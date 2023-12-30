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
      productId: $enumDecode(_$IAPIdEnumMap, json['productId']),
      provider: $enumDecode(_$PurchasePaymentProviderEnumMap, json['provider']),
      type: $enumDecode(_$ProductTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$PurchaseRequestDtoModelImplToJson(
        _$PurchaseRequestDtoModelImpl instance) =>
    <String, dynamic>{
      'productId': _$IAPIdEnumMap[instance.productId]!,
      'provider': _$PurchasePaymentProviderEnumMap[instance.provider]!,
      'type': _$ProductTypeEnumMap[instance.type]!,
    };

const _$IAPIdEnumMap = {
  IAPId.proOneTimePurchase: 'pro_one_time_purchase',
};

const _$PurchasePaymentProviderEnumMap = {
  PurchasePaymentProvider.googlePlay: 'googlePlay',
  PurchasePaymentProvider.appStore: 'appStore',
};

const _$ProductTypeEnumMap = {
  ProductType.subscription: 'subscription',
  ProductType.oneTime: 'oneTime',
};

_$PurchaseModelOneTimeImpl _$$PurchaseModelOneTimeImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseModelOneTimeImpl(
      productId: $enumDecodeNullable(_$IAPIdEnumMap, json['productId']) ??
          IAPId.proOneTimePurchase,
      paymentProvider: $enumDecodeNullable(
              _$PurchasePaymentProviderEnumMap, json['paymentProvider']) ??
          PurchasePaymentProvider.googlePlay,
      originalTransactionID: json['originalTransactionID'] as String? ?? '',
      purchasedAt: json['purchasedAt'] == null
          ? null
          : DateTime.parse(json['purchasedAt'] as String),
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
      userId: json['userId'] == null
          ? UserModelId.empty
          : UserModelId.fromJson(json['userId']),
      type: $enumDecodeNullable(_$ProductTypeEnumMap, json['type']) ??
          ProductType.oneTime,
      status:
          $enumDecodeNullable(_$OneTimePurchaseStatusEnumMap, json['status']) ??
              OneTimePurchaseStatus.pending,
    );

Map<String, dynamic> _$$PurchaseModelOneTimeImplToJson(
        _$PurchaseModelOneTimeImpl instance) =>
    <String, dynamic>{
      'productId': _$IAPIdEnumMap[instance.productId]!,
      'paymentProvider':
          _$PurchasePaymentProviderEnumMap[instance.paymentProvider]!,
      'originalTransactionID': instance.originalTransactionID,
      'purchasedAt': instance.purchasedAt?.toIso8601String(),
      'price': instance.price,
      'period': _$PurchasePeriodEnumMap[instance.period]!,
      'attributes': instance.attributes,
      'willExpireAt': instance.willExpireAt?.toIso8601String(),
      'userId': instance.userId,
      'type': _$ProductTypeEnumMap[instance.type]!,
      'status': _$OneTimePurchaseStatusEnumMap[instance.status]!,
    };

const _$PurchasePeriodEnumMap = {
  PurchasePeriod.oneTime: 'oneTime',
  PurchasePeriod.monthly: 'monthly',
  PurchasePeriod.yearly: 'yearly',
};

const _$OneTimePurchaseStatusEnumMap = {
  OneTimePurchaseStatus.pending: 'pending',
  OneTimePurchaseStatus.completed: 'completed',
  OneTimePurchaseStatus.cancelled: 'cancelled',
};

_$PurchaseModelSubscriptionImpl _$$PurchaseModelSubscriptionImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseModelSubscriptionImpl(
      productId: $enumDecodeNullable(_$IAPIdEnumMap, json['productId']) ??
          IAPId.proOneTimePurchase,
      paymentProvider: $enumDecodeNullable(
              _$PurchasePaymentProviderEnumMap, json['paymentProvider']) ??
          PurchasePaymentProvider.googlePlay,
      originalTransactionID: json['originalTransactionID'] as String? ?? '',
      purchasedAt: json['purchasedAt'] == null
          ? null
          : DateTime.parse(json['purchasedAt'] as String),
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
      userId: json['userId'] == null
          ? UserModelId.empty
          : UserModelId.fromJson(json['userId']),
      type: $enumDecodeNullable(_$ProductTypeEnumMap, json['type']) ??
          ProductType.subscription,
      status:
          $enumDecodeNullable(_$SubscriptionStatusEnumMap, json['status']) ??
              SubscriptionStatus.pending,
    );

Map<String, dynamic> _$$PurchaseModelSubscriptionImplToJson(
        _$PurchaseModelSubscriptionImpl instance) =>
    <String, dynamic>{
      'productId': _$IAPIdEnumMap[instance.productId]!,
      'paymentProvider':
          _$PurchasePaymentProviderEnumMap[instance.paymentProvider]!,
      'originalTransactionID': instance.originalTransactionID,
      'purchasedAt': instance.purchasedAt?.toIso8601String(),
      'price': instance.price,
      'period': _$PurchasePeriodEnumMap[instance.period]!,
      'attributes': instance.attributes,
      'willExpireAt': instance.willExpireAt?.toIso8601String(),
      'userId': instance.userId,
      'type': _$ProductTypeEnumMap[instance.type]!,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.pending: 'pending',
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.expired: 'expired',
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
