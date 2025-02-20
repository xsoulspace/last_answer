// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      draftAnswer: json['draftAnswer'] == null
          ? null
          : IdeaProjectAnswerModel.fromJson(
              json['draftAnswer'] as Map<String, dynamic>),
      tagsIds: (json['tagsIds'] as List<dynamic>?)
              ?.map((e) => ProjectTagModelId.fromJson(e as String))
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
      'draftAnswer': instance.draftAnswer,
      'tagsIds': instance.tagsIds,
      'runtimeType': instance.$type,
    };

const _$ProjectTypesEnumMap = {
  ProjectTypes.idea: 'idea',
  ProjectTypes.note: 'note',
  ProjectTypes.systemChangelog: 'systemChangelog',
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
      tagsIds: (json['tagsIds'] as List<dynamic>?)
              ?.map((e) => ProjectTagModelId.fromJson(e as String))
              .toList() ??
          const [],
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
      'tagsIds': instance.tagsIds,
      'runtimeType': instance.$type,
    };

_$ProjectModelChangelogImpl _$$ProjectModelChangelogImplFromJson(
        Map<String, dynamic> json) =>
    _$ProjectModelChangelogImpl(
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] == null
          ? LocalizedTextModel.empty
          : LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
      id: json['id'] == null
          ? ProjectModelId.systemChangelog
          : ProjectModelId.fromJson(json['id'] as String),
      type: $enumDecodeNullable(_$ProjectTypesEnumMap, json['type']) ??
          ProjectTypes.systemChangelog,
      tagsIds: (json['tagsIds'] as List<dynamic>?)
              ?.map((e) => ProjectTagModelId.fromJson(e as String))
              .toList() ??
          const [],
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ProjectModelChangelogImplToJson(
        _$ProjectModelChangelogImpl instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'id': instance.id,
      'type': _$ProjectTypesEnumMap[instance.type]!,
      'tagsIds': instance.tagsIds,
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

_$ProjectTagModelImpl _$$ProjectTagModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ProjectTagModelImpl(
      id: ProjectTagModelId.fromJson(json['id'] as String),
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$$ProjectTagModelImplToJson(
        _$ProjectTagModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

_$DbSaveModelImpl _$$DbSaveModelImplFromJson(Map<String, dynamic> json) =>
    _$DbSaveModelImpl(
      version: $enumDecodeNullable(_$DbSaveVersionEnumMap, json['version']) ??
          DbSaveVersion.v1,
      projects: (json['projects'] as List<dynamic>?)
              ?.map(ProjectModel.fromJson)
              .toList() ??
          const [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => ProjectTagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DbSaveModelImplToJson(_$DbSaveModelImpl instance) =>
    <String, dynamic>{
      'version': _$DbSaveVersionEnumMap[instance.version]!,
      'projects': instance.projects,
      'tags': instance.tags,
    };

const _$DbSaveVersionEnumMap = {
  DbSaveVersion.v1: 'v1',
};

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      settings: json['settings'] == null
          ? UserSettingsModel.initial
          : UserSettingsModel.fromJson(
              json['settings'] as Map<String, dynamic>),
      localDbVersion: $enumDecodeNullable(
              _$LocalDbVersionEnumMap, json['localDbVersion']) ??
          LocalDbVersion.newestVersion,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'settings': instance.settings,
      'localDbVersion': _$LocalDbVersionEnumMap[instance.localDbVersion]!,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
    };

const _$LocalDbVersionEnumMap = {
  LocalDbVersion.v3_16: 'v3_16',
  LocalDbVersion.v3_17: 'v3_17',
};

_$UserSettingsModelImpl _$$UserSettingsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSettingsModelImpl(
      themeMode: json['themeMode'] == null
          ? ThemeMode.system
          : _themeModeFromJson(json['themeMode'] as int?),
      isProjectsListReversed: json['isProjectsListReversed'] as bool? ?? true,
      charactersLimitForNewNotes:
          json['charactersLimitForNewNotes'] as int? ?? 0,
      locale: _localeFromJson(json['locale'] as String),
      useTimestampForBackupFilename:
          json['useTimestampForBackupFilename'] as bool? ?? true,
      isSocialNetworksRestricted:
          json['isSocialNetworksRestricted'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserSettingsModelImplToJson(
        _$UserSettingsModelImpl instance) =>
    <String, dynamic>{
      'themeMode': _themeModeToJson(instance.themeMode),
      'isProjectsListReversed': instance.isProjectsListReversed,
      'charactersLimitForNewNotes': instance.charactersLimitForNewNotes,
      'locale': _localeToJson(instance.locale),
      'useTimestampForBackupFilename': instance.useTimestampForBackupFilename,
      'isSocialNetworksRestricted': instance.isSocialNetworksRestricted,
    };
