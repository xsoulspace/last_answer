// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'union_project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteProjectModel _$$NoteProjectModelFromJson(Map<String, dynamic> json) =>
    _$NoteProjectModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool,
      projectType: $enumDecode(_$ProjectTypeEnumMap, json['project_type']),
      ownerId: json['owner_id'] as String,
      folderId: json['folder_id'] as String,
      charactersLimit: json['characters_limit'] as int?,
      note: json['note'] as String,
      $type: json['runtime_type'] as String?,
    );

Map<String, dynamic> _$$NoteProjectModelToJson(_$NoteProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_completed': instance.isCompleted,
      'project_type': _$ProjectTypeEnumMap[instance.projectType],
      'owner_id': instance.ownerId,
      'folder_id': instance.folderId,
      'characters_limit': instance.charactersLimit,
      'note': instance.note,
      'runtime_type': instance.$type,
    };

const _$ProjectTypeEnumMap = {
  ProjectType.idea: 'idea',
  ProjectType.note: 'note',
  ProjectType.story: 'story',
};

_$IdeaProjectModel _$$IdeaProjectModelFromJson(Map<String, dynamic> json) =>
    _$IdeaProjectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool,
      projectType: $enumDecode(_$ProjectTypeEnumMap, json['project_type']),
      ownerId: json['owner_id'] as String,
      folderId: json['folder_id'] as String,
      newAnswerText: json['new_answer_text'] as String,
      newQuestionId: fromIntToString(json['new_question_id'] as int),
      $type: json['runtime_type'] as String?,
    );

Map<String, dynamic> _$$IdeaProjectModelToJson(_$IdeaProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_completed': instance.isCompleted,
      'project_type': _$ProjectTypeEnumMap[instance.projectType],
      'owner_id': instance.ownerId,
      'folder_id': instance.folderId,
      'new_answer_text': instance.newAnswerText,
      'new_question_id': fromStringToInt(instance.newQuestionId),
      'runtime_type': instance.$type,
    };
