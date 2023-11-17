// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmojiModelImpl _$$EmojiModelImplFromJson(Map<String, dynamic> json) =>
    _$EmojiModelImpl(
      category: json['category'] as String,
      emoji: json['emoji'] as String,
      keywords: json['keywords'] as String,
    );

Map<String, dynamic> _$$EmojiModelImplToJson(_$EmojiModelImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'emoji': instance.emoji,
      'keywords': instance.keywords,
    };

_$NotificationMessageModelImpl _$$NotificationMessageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationMessageModelImpl(
      id: json['id'] as String,
      message:
          LocalizedTextModel.fromJson(json['message'] as Map<String, dynamic>),
      title: LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
      created: DateTime.parse(json['created'] as String),
    );

Map<String, dynamic> _$$NotificationMessageModelImplToJson(
        _$NotificationMessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'title': instance.title,
      'created': instance.created.toIso8601String(),
    };

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
      charactersLimit: json['charactersLimit'] as int? ?? 0,
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

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      settings: json['settings'] == null
          ? UserSettingsModel.initial
          : UserSettingsModel.fromJson(
              json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'settings': instance.settings,
    };

_$UserSettingsModelImpl _$$UserSettingsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSettingsModelImpl(
      themeMode: json['themeMode'] == null
          ? ThemeMode.system
          : _themeModeFromJson(json['themeMode'] as int?),
      isProjectsListReversed: json['isProjectsListReversed'] as bool? ?? false,
      charactersLimitForNewNotes:
          json['charactersLimitForNewNotes'] as int? ?? 0,
      locale: _localeFromJson(json['locale'] as String),
    );

Map<String, dynamic> _$$UserSettingsModelImplToJson(
        _$UserSettingsModelImpl instance) =>
    <String, dynamic>{
      'themeMode': _themeModeToJson(instance.themeMode),
      'isProjectsListReversed': instance.isProjectsListReversed,
      'charactersLimitForNewNotes': instance.charactersLimitForNewNotes,
      'locale': _localeToJson(instance.locale),
    };
