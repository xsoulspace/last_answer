// GENERATED CODE - DO NOT MODIFY BY HAND

part of pack_app;

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
