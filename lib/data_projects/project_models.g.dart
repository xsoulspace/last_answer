// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorldBindingModel _$WorldBindingModelFromJson(Map<String, dynamic> json) =>
    _WorldBindingModel(
      worldId: json['worldId'] as String,
      endpoint: json['endpoint'] as String,
      displayName: json['displayName'] as String? ?? '',
      workspace: json['workspace'] as String? ?? '',
    );

Map<String, dynamic> _$WorldBindingModelToJson(_WorldBindingModel instance) =>
    <String, dynamic>{
      'worldId': instance.worldId,
      'endpoint': instance.endpoint,
      'displayName': instance.displayName,
      'workspace': instance.workspace,
    };

_AgentDocModel _$AgentDocModelFromJson(Map<String, dynamic> json) =>
    _AgentDocModel(
      workspaces:
          (json['workspaces'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      backend: json['backend'] as String? ?? 'apple_foundation_afm',
      externalAcpServer: json['externalAcpServer'] as String? ?? '',
      checkCommand:
          (json['checkCommand'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      worldBinding: json['worldBinding'] == null
          ? null
          : WorldBindingModel.fromJson(
              json['worldBinding'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AgentDocModelToJson(_AgentDocModel instance) =>
    <String, dynamic>{
      'workspaces': instance.workspaces,
      'backend': instance.backend,
      'externalAcpServer': instance.externalAcpServer,
      'checkCommand': instance.checkCommand,
      'worldBinding': instance.worldBinding,
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

_AnchorSpanModel _$AnchorSpanModelFromJson(Map<String, dynamic> json) =>
    _AnchorSpanModel(
      blockId: DocBlockId.fromJson(json['blockId'] as String),
      prefixHash: json['prefixHash'] as String?,
      suffixHash: json['suffixHash'] as String?,
    );

Map<String, dynamic> _$AnchorSpanModelToJson(_AnchorSpanModel instance) =>
    <String, dynamic>{
      'blockId': instance.blockId,
      'prefixHash': instance.prefixHash,
      'suffixHash': instance.suffixHash,
    };

_NoteAssetModel _$NoteAssetModelFromJson(Map<String, dynamic> json) =>
    _NoteAssetModel(
      id: json['id'] as String,
      path: json['path'] as String,
      mime: json['mime'] as String? ?? 'image/png',
      alt: json['alt'] as String? ?? '',
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NoteAssetModelToJson(_NoteAssetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'mime': instance.mime,
      'alt': instance.alt,
      'width': instance.width,
      'height': instance.height,
      'bytes': instance.bytes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

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
      assets:
          (json['assets'] as List<dynamic>?)
              ?.map((e) => NoteAssetModel.fromJson(e as Map<String, dynamic>))
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
      'assets': instance.assets,
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

ProjectModelDoc _$ProjectModelDocFromJson(
  Map<String, dynamic> json,
) => ProjectModelDoc(
  id: ProjectModelId.fromJson(json['id'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  formatId: json['formatId'] as String? ?? '',
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
  parentDocId: json['parentDocId'] == null
      ? null
      : ProjectModelId.fromJson(json['parentDocId'] as String),
  anchorSpan: json['anchorSpan'] == null
      ? null
      : AnchorSpanModel.fromJson(json['anchorSpan'] as Map<String, dynamic>),
  spanSnapshot: json['spanSnapshot'] as String? ?? '',
  agent: json['agent'] == null
      ? null
      : AgentDocModel.fromJson(json['agent'] as Map<String, dynamic>),
  status:
      $enumDecodeNullable(_$DocStatusEnumMap, json['status']) ?? DocStatus.open,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ProjectModelDocToJson(ProjectModelDoc instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'formatId': instance.formatId,
      'title': instance.title,
      'type': _$ProjectTypesEnumMap[instance.type]!,
      'tagsIds': instance.tagsIds,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'blocks': instance.blocks,
      'parentDocId': instance.parentDocId,
      'anchorSpan': instance.anchorSpan,
      'spanSnapshot': instance.spanSnapshot,
      'agent': instance.agent,
      'status': _$DocStatusEnumMap[instance.status]!,
      'runtimeType': instance.$type,
    };

const _$DocStatusEnumMap = {
  DocStatus.open: 'open',
  DocStatus.collapsed: 'collapsed',
};

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
