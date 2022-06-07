// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'union_project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteProjectModel _$$NoteProjectModelFromJson(
  final Map<String, dynamic> json,
) =>
    _$NoteProjectModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool,
      projectType: json['project_type'],
      ownerId: json['owner_id'],
      folderId: json['folder_id'],
      charactersLimit: json['characters_limit'] as int?,
      note: json['note'] as String,
      $type: json['runtime_type'] as String?,
    );

Map<String, dynamic> _$$NoteProjectModelToJson(
  final _$NoteProjectModel instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_completed': instance.isCompleted,
      'project_type': instance.projectType,
      'owner_id': instance.ownerId,
      'folder_id': instance.folderId,
      'characters_limit': instance.charactersLimit,
      'note': instance.note,
      'runtime_type': instance.$type,
    };

_$IdeaProjectModel _$$IdeaProjectModelFromJson(
  final Map<String, dynamic> json,
) =>
    _$IdeaProjectModel(
      id: json['id'],
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool,
      projectType: json['project_type'],
      ownerId: json['owner_id'],
      folderId: json['folder_id'],
      newAnswerText: json['new_answer_text'] as String,
      newQuestionId: json['new_question_id'],
      $type: json['runtime_type'] as String?,
    );

Map<String, dynamic> _$$IdeaProjectModelToJson(
  final _$IdeaProjectModel instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_completed': instance.isCompleted,
      'project_type': instance.projectType,
      'owner_id': instance.ownerId,
      'folder_id': instance.folderId,
      'new_answer_text': instance.newAnswerText,
      'new_question_id': instance.newQuestionId,
      'runtime_type': instance.$type,
    };
