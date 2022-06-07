// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_project_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_IdeaProjectAnswerModel _$$_IdeaProjectAnswerModelFromJson(
        Map<String, dynamic> json) =>
    _$_IdeaProjectAnswerModel(
      id: json['id'] as String,
      text: json['text'] as String,
      questionId: fromIntToString(json['question_id'] as int),
      projectId: json['project_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      ownerId: json['owner_id'] as String,
    );

Map<String, dynamic> _$$_IdeaProjectAnswerModelToJson(
        _$_IdeaProjectAnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'question_id': fromStringToInt(instance.questionId),
      'project_id': instance.projectId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'owner_id': instance.ownerId,
    };
