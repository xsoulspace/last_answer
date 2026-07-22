// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationMessageModel _$NotificationMessageModelFromJson(
  Map<String, dynamic> json,
) => _NotificationMessageModel(
  id: json['id'] as String,
  message: LocalizedTextModel.fromJson(json['message'] as Map<String, dynamic>),
  title: LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
  created: DateTime.parse(json['created'] as String),
);

Map<String, dynamic> _$NotificationMessageModelToJson(
  _NotificationMessageModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'message': instance.message,
  'title': instance.title,
  'created': instance.created.toIso8601String(),
};

_DocBlockModel _$DocBlockModelFromJson(Map<String, dynamic> json) =>
    _DocBlockModel(
      id: DocBlockId.fromJson(json['id'] as String),
      type: $enumDecode(_$DocBlockTypeEnumMap, json['type']),
      content: json['content'] as String? ?? '',
      level: (json['level'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DocBlockModelToJson(_DocBlockModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$DocBlockTypeEnumMap[instance.type]!,
      'content': instance.content,
      'level': instance.level,
    };

const _$DocBlockTypeEnumMap = {
  DocBlockType.heading: 'heading',
  DocBlockType.paragraph: 'paragraph',
  DocBlockType.list: 'list',
};

_DocThreadMessageModel _$DocThreadMessageModelFromJson(
  Map<String, dynamic> json,
) => _DocThreadMessageModel(
  content: json['content'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  authorId: json['authorId'] as String? ?? '',
  authorName: json['authorName'] as String? ?? '',
);

Map<String, dynamic> _$DocThreadMessageModelToJson(
  _DocThreadMessageModel instance,
) => <String, dynamic>{
  'content': instance.content,
  'timestamp': instance.timestamp.toIso8601String(),
  'authorId': instance.authorId,
  'authorName': instance.authorName,
};

_DocThreadModel _$DocThreadModelFromJson(Map<String, dynamic> json) =>
    _DocThreadModel(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DocThreadMessageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DocThreadModelToJson(_DocThreadModel instance) =>
    <String, dynamic>{'messages': instance.messages};

ProjectModelIdea _$ProjectModelIdeaFromJson(Map<String, dynamic> json) =>
    ProjectModelIdea(
      id: ProjectModelId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String? ?? '',
      type:
          $enumDecodeNullable(_$ProjectTypesEnumMap, json['type']) ??
          ProjectTypes.idea,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map(
                (e) =>
                    IdeaProjectAnswerModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      draftAnswer: json['draftAnswer'] == null
          ? null
          : IdeaProjectAnswerModel.fromJson(
              json['draftAnswer'] as Map<String, dynamic>,
            ),
      tagsIds:
          (json['tagsIds'] as List<dynamic>?)
              ?.map((e) => ProjectTagModelId.fromJson(e as String))
              .toList() ??
          const [],
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ProjectModelIdeaToJson(ProjectModelIdea instance) =>
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
  ProjectTypes.doc: 'doc',
};

ProjectModelNote _$ProjectModelNoteFromJson(Map<String, dynamic> json) =>
    ProjectModelNote(
      id: ProjectModelId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      note: json['note'] as String? ?? '',
      type:
          $enumDecodeNullable(_$ProjectTypesEnumMap, json['type']) ??
          ProjectTypes.note,
      charactersLimit: (json['charactersLimit'] as num?)?.toInt() ?? 0,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      tagsIds:
          (json['tagsIds'] as List<dynamic>?)
              ?.map((e) => ProjectTagModelId.fromJson(e as String))
              .toList() ??
          const [],
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ProjectModelNoteToJson(ProjectModelNote instance) =>
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

ProjectModelChangelog _$ProjectModelChangelogFromJson(
  Map<String, dynamic> json,
) => ProjectModelChangelog(
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  title: json['title'] == null
      ? LocalizedTextModel.empty
      : LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
  id: json['id'] == null
      ? ProjectModelId.systemChangelog
      : ProjectModelId.fromJson(json['id'] as String),
  type:
      $enumDecodeNullable(_$ProjectTypesEnumMap, json['type']) ??
      ProjectTypes.systemChangelog,
  tagsIds:
      (json['tagsIds'] as List<dynamic>?)
          ?.map((e) => ProjectTagModelId.fromJson(e as String))
          .toList() ??
      const [],
  archivedAt: json['archivedAt'] == null
      ? null
      : DateTime.parse(json['archivedAt'] as String),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ProjectModelChangelogToJson(
  ProjectModelChangelog instance,
) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'title': instance.title,
  'id': instance.id,
  'type': _$ProjectTypesEnumMap[instance.type]!,
  'tagsIds': instance.tagsIds,
  'archivedAt': instance.archivedAt?.toIso8601String(),
  'runtimeType': instance.$type,
};

ProjectModelDoc _$ProjectModelDocFromJson(Map<String, dynamic> json) =>
    ProjectModelDoc(
      id: ProjectModelId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      docKind: $enumDecode(_$DocKindEnumMap, json['docKind']),
      title: json['title'] as String? ?? '',
      type:
          $enumDecodeNullable(_$ProjectTypesEnumMap, json['type']) ??
          ProjectTypes.doc,
      tagsIds:
          (json['tagsIds'] as List<dynamic>?)
              ?.map((e) => ProjectTagModelId.fromJson(e as String))
              .toList() ??
          const [],
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      blocks:
          (json['blocks'] as List<dynamic>?)
              ?.map((e) => DocBlockModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      threads: json['threads'] == null
          ? const {}
          : threadsFromJsonMap(json['threads'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ProjectModelDocToJson(ProjectModelDoc instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'docKind': _$DocKindEnumMap[instance.docKind]!,
      'title': instance.title,
      'type': _$ProjectTypesEnumMap[instance.type]!,
      'tagsIds': instance.tagsIds,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'blocks': instance.blocks,
      'threads': threadsToJsonMap(instance.threads),
      'runtimeType': instance.$type,
    };

const _$DocKindEnumMap = {DocKind.gdd: 'gdd', DocKind.prd: 'prd'};

_IdeaProjectAnswerModel _$IdeaProjectAnswerModelFromJson(
  Map<String, dynamic> json,
) => _IdeaProjectAnswerModel(
  id: IdeaProjectAnswerModelId.fromJson(json['id'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  question: IdeaProjectQuestionModel.fromJson(
    json['question'] as Map<String, dynamic>,
  ),
  text: json['text'] as String? ?? '',
);

Map<String, dynamic> _$IdeaProjectAnswerModelToJson(
  _IdeaProjectAnswerModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'question': instance.question,
  'text': instance.text,
};

_IdeaProjectQuestionModel _$IdeaProjectQuestionModelFromJson(
  Map<String, dynamic> json,
) => _IdeaProjectQuestionModel(
  id: IdeaProjectQuestionModelId.fromJson(json['id'] as String),
  title: LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IdeaProjectQuestionModelToJson(
  _IdeaProjectQuestionModel instance,
) => <String, dynamic>{'id': instance.id, 'title': instance.title};

_LocalizedTextModel _$LocalizedTextModelFromJson(Map<String, dynamic> json) =>
    _LocalizedTextModel(
      ru: json['ru'] as String,
      en: json['en'] as String? ?? '',
      it: json['it'] as String? ?? '',
      ga: json['ga'] as String? ?? '',
    );

Map<String, dynamic> _$LocalizedTextModelToJson(_LocalizedTextModel instance) =>
    <String, dynamic>{
      'ru': instance.ru,
      'en': instance.en,
      'it': instance.it,
      'ga': instance.ga,
    };

_ProjectTagModel _$ProjectTagModelFromJson(Map<String, dynamic> json) =>
    _ProjectTagModel(
      id: ProjectTagModelId.fromJson(json['id'] as String),
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$ProjectTagModelToJson(_ProjectTagModel instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};

_DbSaveModel _$DbSaveModelFromJson(Map<String, dynamic> json) => _DbSaveModel(
  version:
      $enumDecodeNullable(_$DbSaveVersionEnumMap, json['version']) ??
      DbSaveVersion.v1,
  projects:
      (json['projects'] as List<dynamic>?)
          ?.map(ProjectModel.fromJson)
          .toList() ??
      const [],
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => ProjectTagModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DbSaveModelToJson(_DbSaveModel instance) =>
    <String, dynamic>{
      'version': _$DbSaveVersionEnumMap[instance.version]!,
      'projects': instance.projects,
      'tags': instance.tags,
    };

const _$DbSaveVersionEnumMap = {DbSaveVersion.v1: 'v1'};

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  settings: json['settings'] == null
      ? UserSettingsModel.initial
      : UserSettingsModel.fromJson(json['settings'] as Map<String, dynamic>),
  localDbVersion:
      $enumDecodeNullable(_$LocalDbVersionEnumMap, json['localDbVersion']) ??
      LocalDbVersion.newestVersion,
  hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'settings': instance.settings,
      'localDbVersion': _$LocalDbVersionEnumMap[instance.localDbVersion]!,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
    };

const _$LocalDbVersionEnumMap = {
  LocalDbVersion.v3_16: 'v3_16',
  LocalDbVersion.v3_17: 'v3_17',
  LocalDbVersion.v4: 'v4',
};

_UserSettingsModel _$UserSettingsModelFromJson(Map<String, dynamic> json) =>
    _UserSettingsModel(
      themeMode: json['themeMode'] == null
          ? ThemeMode.system
          : _themeModeFromJson((json['themeMode'] as num?)?.toInt()),
      isProjectsListReversed: json['isProjectsListReversed'] as bool? ?? true,
      charactersLimitForNewNotes:
          (json['charactersLimitForNewNotes'] as num?)?.toInt() ?? 0,
      locale: _localeFromJson(json['locale'] as String),
      useTimestampForBackupFilename:
          json['useTimestampForBackupFilename'] as bool? ?? true,
      isSocialNetworksRestricted:
          json['isSocialNetworksRestricted'] as bool? ?? true,
    );

Map<String, dynamic> _$UserSettingsModelToJson(_UserSettingsModel instance) =>
    <String, dynamic>{
      'themeMode': _themeModeToJson(instance.themeMode),
      'isProjectsListReversed': instance.isProjectsListReversed,
      'charactersLimitForNewNotes': instance.charactersLimitForNewNotes,
      'locale': _localeToJson(instance.locale),
      'useTimestampForBackupFilename': instance.useTimestampForBackupFilename,
      'isSocialNetworksRestricted': instance.isSocialNetworksRestricted,
    };
