// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return Question(
    title: LocaleTitle.fromJson(json['title'] as Map<String, dynamic>),
    id: json['id'] as String,
  );
}

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'title': instance.title,
      'id': instance.id,
    };
