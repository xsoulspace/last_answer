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
      type: $enumDecode(_$PurchaseTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$PurchaseRequestDtoModelImplToJson(
        _$PurchaseRequestDtoModelImpl instance) =>
    <String, dynamic>{
      'productId': _$IAPIdEnumMap[instance.productId]!,
      'provider': _$PurchasePaymentProviderEnumMap[instance.provider]!,
      'type': _$PurchaseTypeEnumMap[instance.type]!,
    };

const _$IAPIdEnumMap = {
  IAPId.proOneTimePurchase: 'pro_one_time_purchase',
};

const _$PurchasePaymentProviderEnumMap = {
  PurchasePaymentProvider.googlePlay: 'googlePlay',
  PurchasePaymentProvider.appStore: 'appStore',
};

const _$PurchaseTypeEnumMap = {
  PurchaseType.videoAward: 'videoAward',
  PurchaseType.subscription: 'subscription',
  PurchaseType.oneTimePurchase: 'oneTimePurchase',
};

_$PurchaseActionModelVideoAwardImpl
    _$$PurchaseActionModelVideoAwardImplFromJson(Map<String, dynamic> json) =>
        _$PurchaseActionModelVideoAwardImpl(
          userId: json['userId'] == null
              ? UserModelId.empty
              : UserModelId.fromJson(json['userId']),
          type: $enumDecodeNullable(_$PurchaseTypeEnumMap, json['type']) ??
              PurchaseType.videoAward,
          rewardDaysQuantity: json['rewardDaysQuantity'] as int? ?? 0,
          createdAt: json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
        );

Map<String, dynamic> _$$PurchaseActionModelVideoAwardImplToJson(
        _$PurchaseActionModelVideoAwardImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'type': _$PurchaseTypeEnumMap[instance.type]!,
      'rewardDaysQuantity': instance.rewardDaysQuantity,
      'createdAt': instance.createdAt?.toIso8601String(),
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
          ? PurchaseActionModel.empty
          : PurchaseActionModel.fromRawJson(
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
