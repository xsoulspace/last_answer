// GENERATED CODE - DO NOT MODIFY BY HAND

part of pack_app;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationMessage _$NotificationMessageFromJson(Map<String, dynamic> json) =>
    NotificationMessage(
      id: json['id'] as String,
      message: json['message'] as String,
      created: json['created'] as String,
    );

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
