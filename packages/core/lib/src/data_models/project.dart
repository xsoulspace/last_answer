part of 'data_models.dart';

extension type const ProjectModelId(String value) {
  factory ProjectModelId.fromJson(String value) => ProjectModelId(value);
  factory ProjectModelId.generate() => ProjectModelId(createId());
  static const empty = ProjectModelId('');
  static const systemChangelog = ProjectModelId('changelog');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
}

enum ProjectTypes { idea, note, systemChangelog, doc }

/// Kind of document: GDD (Game Design) or PRD (Product Requirements).
enum DocKind { gdd, prd }

extension type const DocBlockId(String value) {
  factory DocBlockId.fromJson(String value) => DocBlockId(value);
  factory DocBlockId.generate() => DocBlockId(createId());
  String toJson() => value;
}

enum DocBlockType { heading, paragraph, list }

@freezed
abstract class DocBlockModel with _$DocBlockModel {
  const factory DocBlockModel({
    required DocBlockId id,
    required DocBlockType type,
    @Default('') String content,
    int? level,
  }) = _DocBlockModel;
  factory DocBlockModel.fromJson(Map<String, dynamic> json) =>
      _$DocBlockModelFromJson(json);
}

Map<SpanId, DocThreadModel> threadsFromJsonMap(Map<String, dynamic> json) =>
    json.map(
      (key, value) =>
          MapEntry(SpanId.fromJson(key), DocThreadModel.fromJson(value)),
    );
Map<String, dynamic> threadsToJsonMap(Map<SpanId, DocThreadModel> map) =>
    map.map((key, value) => MapEntry(key.value, value.toJson()));

/// Identifies a span for threading: "blockId" (whole block) or "blockId:start:end".
extension type const SpanId(String value) {
  factory SpanId.fromJson(String value) => SpanId(value);
  String toJson() => value;
  static SpanId forBlock(DocBlockId blockId) => SpanId(blockId.value);
  static SpanId forRange(DocBlockId blockId, int start, int end) =>
      SpanId('${blockId.value}:$start:$end');
}

@freezed
abstract class DocThreadMessageModel with _$DocThreadMessageModel {
  const factory DocThreadMessageModel({
    required String content,
    required DateTime timestamp,
    @Default('') String authorId,
    @Default('') String authorName,
  }) = _DocThreadMessageModel;
  factory DocThreadMessageModel.fromJson(Map<String, dynamic> json) =>
      _$DocThreadMessageModelFromJson(json);
}

@freezed
abstract class DocThreadModel with _$DocThreadModel {
  const factory DocThreadModel({
    @Default([]) List<DocThreadMessageModel> messages,
  }) = _DocThreadModel;
  factory DocThreadModel.fromJson(Map<String, dynamic> json) =>
      _$DocThreadModelFromJson(json);
}

@freezed
sealed class ProjectModel with _$ProjectModel implements Sharable, Archivable {
  @Implements<Archivable>()
  @Implements<Sharable>()
  const factory ProjectModel.idea({
    required ProjectModelId id,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String title,
    @Default(ProjectTypes.idea) ProjectTypes type,
    DateTime? archivedAt,
    @Default([]) List<IdeaProjectAnswerModel> answers,
    IdeaProjectAnswerModel? draftAnswer,
    @Default([]) List<ProjectTagModelId> tagsIds,
  }) = ProjectModelIdea;
  @Implements<Archivable>()
  @Implements<Sharable>()
  const factory ProjectModel.note({
    required ProjectModelId id,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String note,
    @Default(ProjectTypes.note) ProjectTypes type,
    @Default(0) int charactersLimit,
    DateTime? archivedAt,
    @Default([]) List<ProjectTagModelId> tagsIds,
  }) = ProjectModelNote;

  /// keeps only position of system changelog whithout any content
  @Implements<Sharable>()
  @Implements<Archivable>()
  const factory ProjectModel.changelog({
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(LocalizedTextModel.empty) LocalizedTextModel title,
    @Default(ProjectModelId.systemChangelog) ProjectModelId id,
    @Default(ProjectTypes.systemChangelog) ProjectTypes type,
    @Default([]) List<ProjectTagModelId> tagsIds,
    DateTime? archivedAt,
  }) = ProjectModelChangelog;
  @Implements<Archivable>()
  @Implements<Sharable>()
  const factory ProjectModel.doc({
    required ProjectModelId id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DocKind docKind,
    @Default('') String title,
    @Default(ProjectTypes.doc) ProjectTypes type,
    @Default([]) List<ProjectTagModelId> tagsIds,
    DateTime? archivedAt,
    @Default([]) List<DocBlockModel> blocks,
    @JsonKey(fromJson: threadsFromJsonMap, toJson: threadsToJsonMap)
    @Default({})
    Map<SpanId, DocThreadModel> threads,
  }) = ProjectModelDoc;
  factory ProjectModel.fromJson(dynamic json) =>
      _$ProjectModelFromJson(json as Map<String, dynamic>);
  const ProjectModel._();
  factory ProjectModel.getSystemChangelogFromNotifications({
    required List<NotificationMessageModel> notifications,
  }) {
    final newest = notifications.first;
    final oldest = notifications.last;

    return ProjectModelChangelog(
      createdAt: oldest.created,
      title: newest.title,
      updatedAt: newest.created,
    );
  }

  static const titleLimit = 90;
  String getTitle(BuildContext context) => switch (this) {
    ProjectModelIdea(title: final titleStr) => titleStr,
    ProjectModelNote(:final note) => _getTitle(note),
    ProjectModelChangelog(:final title) => _getTitle(title.localize(context)),
    ProjectModelDoc(:final title) => title.isEmpty ? 'Untitled' : title,
  };

  @override
  String toShareString(BuildContext context) => map(
    idea: (value) =>
        ideaProjectToShareString(context: context, projectIdea: value),
    note: (value) => value.note,
    changelog: (value) => '',
    doc: (value) => value.blocks
        .map((b) => b.content)
        .where((s) => s.isNotEmpty)
        .join('\n'),
  );

  @override
  String toSharableTitle(BuildContext context) => getTitle(context);

  static ProjectModelNote emptyNote = ProjectModelNote(
    id: ProjectModelId.empty,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  static ProjectModelIdea emptyIdea = ProjectModelIdea(
    id: ProjectModelId.empty,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static ProjectModel emptyGdd() => ProjectModel.doc(
    id: ProjectModelId.generate(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    docKind: DocKind.gdd,
    blocks: defaultGddTemplate(),
  );
  static ProjectModel emptyPrd() => ProjectModel.doc(
    id: ProjectModelId.generate(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    docKind: DocKind.prd,
    blocks: defaultPrdTemplate(),
  );
}

List<DocBlockModel> defaultGddTemplate() => [
  DocBlockModel(
    id: DocBlockId.generate(),
    type: DocBlockType.heading,
    content: 'Overview',
    level: 1,
  ),
  DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
  DocBlockModel(
    id: DocBlockId.generate(),
    type: DocBlockType.heading,
    content: 'Gameplay',
    level: 1,
  ),
  DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
  DocBlockModel(
    id: DocBlockId.generate(),
    type: DocBlockType.heading,
    content: 'Art',
    level: 1,
  ),
  DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
  DocBlockModel(
    id: DocBlockId.generate(),
    type: DocBlockType.heading,
    content: 'Tech',
    level: 1,
  ),
  DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
];

List<DocBlockModel> defaultPrdTemplate() => [
  DocBlockModel(
    id: DocBlockId.generate(),
    type: DocBlockType.heading,
    content: 'Problem',
    level: 1,
  ),
  DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
  DocBlockModel(
    id: DocBlockId.generate(),
    type: DocBlockType.heading,
    content: 'Users',
    level: 1,
  ),
  DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
  DocBlockModel(
    id: DocBlockId.generate(),
    type: DocBlockType.heading,
    content: 'Requirements',
    level: 1,
  ),
  DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
  DocBlockModel(
    id: DocBlockId.generate(),
    type: DocBlockType.heading,
    content: 'Success Metrics',
    level: 1,
  ),
  DocBlockModel(id: DocBlockId.generate(), type: DocBlockType.paragraph),
];

String _getTitle(String text, {int titleLimit = ProjectModel.titleLimit}) {
  if (text.length <= titleLimit) return text;

  return text.substring(0, titleLimit);
}

extension type const IdeaProjectAnswerModelId(String value) {
  factory IdeaProjectAnswerModelId.fromJson(String value) =>
      IdeaProjectAnswerModelId(value);
  factory IdeaProjectAnswerModelId.generate() =>
      IdeaProjectAnswerModelId(createId());
  static const empty = IdeaProjectAnswerModelId('');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
}

@freezed
abstract class IdeaProjectAnswerModel
    with _$IdeaProjectAnswerModel
    implements Sharable {
  const factory IdeaProjectAnswerModel({
    required IdeaProjectAnswerModelId id,
    required DateTime createdAt,
    required IdeaProjectQuestionModel question,
    @Default('') String text,
  }) = _IdeaProjectAnswerModel;
  const IdeaProjectAnswerModel._();
  factory IdeaProjectAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$IdeaProjectAnswerModelFromJson(json);
  String get title => _getTitle(text, titleLimit: 50);
  @override
  String toSharableTitle(BuildContext context) => title;
  @override
  String toShareString(BuildContext context) =>
      '${question.toShareString(context)} \n $text';
}

extension type const IdeaProjectQuestionModelId(String value) {
  factory IdeaProjectQuestionModelId.fromJson(String value) =>
      IdeaProjectQuestionModelId(value);
  factory IdeaProjectQuestionModelId.generate() =>
      IdeaProjectQuestionModelId(createId());
  static const empty = IdeaProjectQuestionModelId('');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
}

@freezed
abstract class IdeaProjectQuestionModel
    with _$IdeaProjectQuestionModel
    implements Sharable {
  const factory IdeaProjectQuestionModel({
    required IdeaProjectQuestionModelId id,
    required LocalizedTextModel title,
  }) = _IdeaProjectQuestionModel;
  const IdeaProjectQuestionModel._();
  factory IdeaProjectQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$IdeaProjectQuestionModelFromJson(json);
  @override
  String toShareString(BuildContext context) => title.localize(context);
  @override
  String toSharableTitle(BuildContext context) =>
      _getTitle(title.localize(context));
}

@freezed
abstract class LocalizedTextModel with _$LocalizedTextModel {
  const factory LocalizedTextModel({
    required String ru,
    @Default('') String en,
    @Default('') String it,
    @Default('') String ga,
  }) = _LocalizedTextModel;
  factory LocalizedTextModel.fromJson(Map<String, dynamic> json) =>
      _$LocalizedTextModelFromJson(json);
  const LocalizedTextModel._();
  static const empty = LocalizedTextModel(ru: '');

  /// If any new [Languages] added, add this to [values]
  Map<LanguageName, String?> get values => {
    Locales.ru.languageCode: ru,
    Locales.en.languageCode: en,
    Locales.it.languageCode: it,
    // Locales.ga.languageCode: ga,
  };

  String localize(BuildContext context) =>
      _getByLanguage(context.locale.languageCode);
  String _getByLanguage(String languageCode) =>
      values[languageCode] ?? ''.whenEmptyUse(en);
}

String getLanguageCode(LanguageName language) {
  String lang = language;
  if (language.contains('_')) {
    lang = language.split('_').first;
  }

  return lang;
}

String ideaProjectToShareString({
  required ProjectModelIdea projectIdea,
  required BuildContext context,
}) {
  final buffer = StringBuffer('${projectIdea.title} \n');
  final resolvedAnswers = projectIdea.answers;
  for (final answer in resolvedAnswers) {
    buffer.writeln(answer.toShareString(context));
  }

  return buffer.toString();
}

extension type const ProjectTagModelId(String value) {
  factory ProjectTagModelId.generate() => ProjectTagModelId(createId());
  factory ProjectTagModelId.fromJson(String json) => ProjectTagModelId(json);
  static const empty = ProjectTagModelId('');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
}

@freezed
abstract class ProjectTagModel with _$ProjectTagModel {
  const factory ProjectTagModel({
    required ProjectTagModelId id,
    @Default('') String title,
  }) = _ProjectTagModel;
  factory ProjectTagModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectTagModelFromJson(json);
  const ProjectTagModel._();
  static const empty = ProjectTagModel(id: ProjectTagModelId.empty);
  bool get isEmpty => id.isEmpty;
}
