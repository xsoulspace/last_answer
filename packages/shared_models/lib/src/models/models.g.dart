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
    );

Map<String, dynamic> _$$RemoteUserModelImplToJson(
        _$RemoteUserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

_$PurchasesModelImpl _$$PurchasesModelImplFromJson(Map<String, dynamic> json) =>
    _$PurchasesModelImpl(
      isOneTimePurchased: json['is_one_time_purchased'] as bool? ?? false,
      subscriptionEndDate: json['subscription_end_date'] == null
          ? null
          : DateTime.parse(json['subscription_end_date'] as String),
      daysOfSupporterLeft: json['days_of_supporter_left'] as int? ?? 0,
      supporterDaysCount: json['supporter_days_count'] as int? ?? 0,
      usedDaysCount: json['used_days_count'] as int? ?? 0,
    );

Map<String, dynamic> _$$PurchasesModelImplToJson(
        _$PurchasesModelImpl instance) =>
    <String, dynamic>{
      'is_one_time_purchased': instance.isOneTimePurchased,
      'subscription_end_date': instance.subscriptionEndDate?.toIso8601String(),
      'days_of_supporter_left': instance.daysOfSupporterLeft,
      'supporter_days_count': instance.supporterDaysCount,
      'used_days_count': instance.usedDaysCount,
    };

_$AdsStateModelImpl _$$AdsStateModelImplFromJson(Map<String, dynamic> json) =>
    _$AdsStateModelImpl(
      lastDateWhenAdRewardReceived: json['lastDateWhenAdRewardReceived'] == null
          ? null
          : DateTime.parse(json['lastDateWhenAdRewardReceived'] as String),
    );

Map<String, dynamic> _$$AdsStateModelImplToJson(_$AdsStateModelImpl instance) =>
    <String, dynamic>{
      'lastDateWhenAdRewardReceived':
          instance.lastDateWhenAdRewardReceived?.toIso8601String(),
    };
