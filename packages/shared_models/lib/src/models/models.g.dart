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
    );

Map<String, dynamic> _$$PurchasesModelImplToJson(
        _$PurchasesModelImpl instance) =>
    <String, dynamic>{
      'has_one_time_purchase': instance.hasOneTimePurchase,
      'subscription_end_date': instance.subscriptionEndDate?.toIso8601String(),
      'purchased_days_left': instance.purchasedDaysLeft,
    };
