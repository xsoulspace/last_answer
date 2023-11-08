// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectModelIdeaImpl _$$ProjectModelIdeaImplFromJson(
        Map<String, dynamic> json) =>
    _$ProjectModelIdeaImpl(
      id: ProjectModelId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String? ?? '',
      type: $enumDecodeNullable(_$ProjectTypesEnumMap, json['type']) ??
          ProjectTypes.idea,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) =>
                  IdeaProjectAnswerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ProjectModelIdeaImplToJson(
        _$ProjectModelIdeaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'type': _$ProjectTypesEnumMap[instance.type]!,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'answers': instance.answers,
      'runtimeType': instance.$type,
    };

const _$ProjectTypesEnumMap = {
  ProjectTypes.idea: 'idea',
  ProjectTypes.note: 'note',
  ProjectTypes.story: 'story',
};

_$ProjectModelNoteImpl _$$ProjectModelNoteImplFromJson(
        Map<String, dynamic> json) =>
    _$ProjectModelNoteImpl(
      id: ProjectModelId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      note: json['note'] as String? ?? '',
      type: $enumDecodeNullable(_$ProjectTypesEnumMap, json['type']) ??
          ProjectTypes.note,
      charactersLimit: json['charactersLimit'] as int?,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ProjectModelNoteImplToJson(
        _$ProjectModelNoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'note': instance.note,
      'type': _$ProjectTypesEnumMap[instance.type]!,
      'charactersLimit': instance.charactersLimit,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'runtimeType': instance.$type,
    };

_$IdeaProjectAnswerModelImpl _$$IdeaProjectAnswerModelImplFromJson(
        Map<String, dynamic> json) =>
    _$IdeaProjectAnswerModelImpl(
      id: IdeaProjectAnswerModelId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      question: IdeaProjectQuestionModel.fromJson(
          json['question'] as Map<String, dynamic>),
      text: json['text'] as String? ?? '',
    );

Map<String, dynamic> _$$IdeaProjectAnswerModelImplToJson(
        _$IdeaProjectAnswerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'question': instance.question,
      'text': instance.text,
    };

_$IdeaProjectQuestionModelImpl _$$IdeaProjectQuestionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$IdeaProjectQuestionModelImpl(
      id: IdeaProjectQuestionModelId.fromJson(json['id'] as String),
      title: LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$IdeaProjectQuestionModelImplToJson(
        _$IdeaProjectQuestionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

_$LocalizedTextModelImpl _$$LocalizedTextModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LocalizedTextModelImpl(
      ru: json['ru'] as String,
      en: json['en'] as String,
      it: json['it'] as String? ?? '',
      ga: json['ga'] as String? ?? '',
    );

Map<String, dynamic> _$$LocalizedTextModelImplToJson(
        _$LocalizedTextModelImpl instance) =>
    <String, dynamic>{
      'ru': instance.ru,
      'en': instance.en,
      'it': instance.it,
      'ga': instance.ga,
    };

_$AppSettingsModelImpl _$$AppSettingsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AppSettingsModelImpl();

Map<String, dynamic> _$$AppSettingsModelImplToJson(
        _$AppSettingsModelImpl instance) =>
    <String, dynamic>{};
