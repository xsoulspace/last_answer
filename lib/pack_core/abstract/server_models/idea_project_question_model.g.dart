// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_project_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_IdeaProjectQuestionModel _$$_IdeaProjectQuestionModelFromJson(
  final Map<String, dynamic> json,
) =>
    _$_IdeaProjectQuestionModel(
      id: fromIntToString(json['id'] as int),
      title: json['title'] as String,
    );

Map<String, dynamic> _$$_IdeaProjectQuestionModelToJson(
  final _$_IdeaProjectQuestionModel instance,
) =>
    <String, dynamic>{
      'id': fromStringToInt(instance.id),
      'title': instance.title,
    };
