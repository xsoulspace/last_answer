// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdsStateModel _$AdsStateModelFromJson(Map<String, dynamic> json) =>
    _AdsStateModel(
      lastDateWhenAdRewardReceived: json['lastDateWhenAdRewardReceived'] == null
          ? null
          : DateTime.parse(json['lastDateWhenAdRewardReceived'] as String),
    );

Map<String, dynamic> _$AdsStateModelToJson(_AdsStateModel instance) =>
    <String, dynamic>{
      'lastDateWhenAdRewardReceived': instance.lastDateWhenAdRewardReceived
          ?.toIso8601String(),
    };
