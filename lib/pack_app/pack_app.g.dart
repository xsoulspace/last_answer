// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_app.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppRouteParameters _$AppRouteParametersFromJson(Map<String, dynamic> json) =>
    AppRouteParameters(
      noteId: json['noteId'] as String?,
      ideaId: json['ideaId'] as String?,
      answerId: json['answerId'] as String?,
    );

Map<String, dynamic> _$AppRouteParametersToJson(AppRouteParameters instance) =>
    <String, dynamic>{
      'noteId': instance.noteId,
      'ideaId': instance.ideaId,
      'answerId': instance.answerId,
    };

NotificationMessage _$NotificationMessageFromJson(Map<String, dynamic> json) =>
    NotificationMessage(
      id: json['id'] as String,
      message: LocalizedText.fromJson(json['message'] as Map<String, dynamic>),
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      created: DateTime.parse(json['created'] as String),
    );
