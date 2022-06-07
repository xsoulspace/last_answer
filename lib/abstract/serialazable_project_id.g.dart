// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serialazable_project_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableProjectId _$SerializableProjectIdFromJson(
        Map<String, dynamic> json) =>
    SerializableProjectId(
      id: json['id'] as String,
      type: $enumDecode(_$ProjectTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$SerializableProjectIdToJson(
        SerializableProjectId instance) =>
    <String, dynamic>{
      'type': _$ProjectTypeEnumMap[instance.type],
      'id': instance.id,
    };

const _$ProjectTypeEnumMap = {
  ProjectType.idea: 'idea',
  ProjectType.note: 'note',
  ProjectType.story: 'story',
};
