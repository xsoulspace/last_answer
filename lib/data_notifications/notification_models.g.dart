// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationMessageModel _$NotificationMessageModelFromJson(
  Map<String, dynamic> json,
) => _NotificationMessageModel(
  id: json['id'] as String,
  message: LocalizedTextModel.fromJson(json['message'] as Map<String, dynamic>),
  title: LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
  created: DateTime.parse(json['created'] as String),
);

Map<String, dynamic> _$NotificationMessageModelToJson(
  _NotificationMessageModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'message': instance.message,
  'title': instance.title,
  'created': instance.created.toIso8601String(),
};
