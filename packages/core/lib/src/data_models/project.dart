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

/// Lifecycle of a document node: `open` while being worked on; `collapsed`
/// once its conclusion is applied to the head span. Collapsed nodes are
/// archived, never deleted.
enum DocStatus { open, collapsed }

/// Known format ids. Any other value is a user-installed format template.
abstract final class DocFormatIds {
  static const chat = 'chat';

  /// Agents in docs (ADR 0003): a document bound to one or more workspaces
  /// where humans and agents work the same task surface.
  static const agent = 'agent';
}

/// Agent-doc payload (ADR 0003 — Agents live in docs, Phase 1).
///
/// Doc data (mesh-synced, shareable): the workspace set the doc binds to,
/// the default backend for its runtime bindings, and an optional workspace
/// oracle override (the product equivalent of the CLI's `--check`). World
/// snapshots and the meaning tree are NEVER here — they stay device-local
/// under the workspace (`<workspace>/.dart_tool/harnessd_store/`).
@freezed
sealed class AgentDocModel with _$AgentDocModel {
  const factory AgentDocModel({
    @Default([]) List<String> workspaces,
    @Default('apple_foundation_afm') String backend,

    /// Explicit verification command overriding the workspace convention
    /// (D8): the same escape hatch the CLI spells `--check`. Empty = the
    /// workspace convention decides.
    @Default([]) List<String> checkCommand,
  }) = _AgentDocModel;

  factory AgentDocModel.fromJson(Map<String, dynamic> json) =>
      _$AgentDocModelFromJson(json);
}

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

@freezed
abstract class AnchorSpanModel with _$AnchorSpanModel {
  const factory AnchorSpanModel({
    required DocBlockId blockId,
    String? prefixHash,
    String? suffixHash,
  }) = _AnchorSpanModel;
  factory AnchorSpanModel.fromJson(Map<String, dynamic> json) =>
      _$AnchorSpanModelFromJson(json);
}

@freezed
sealed class ProjectModel with _$ProjectModel implements Sharable, Archivable {
  factory ProjectModel.emptyChat() => ProjectModel.doc(
    id: ProjectModelId.generate(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    formatId: DocFormatIds.chat,
  );

  /// ADR 0003 — Agents live in docs: a new agent doc binds to no workspace
  /// yet; the first session pins it (Phase 1).
  factory ProjectModel.emptyAgent() => ProjectModel.doc(
    id: ProjectModelId.generate(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    formatId: DocFormatIds.agent,
    agent: const AgentDocModel(),
  );
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

    /// Format template id ([DocFormatIds] or custom). Empty = generic doc.
    @Default('') String formatId,
    @Default('') String title,
    @Default(ProjectTypes.doc) ProjectTypes type,
    @Default([]) List<ProjectTagModelId> tagsIds,
    DateTime? archivedAt,
    @Default([]) List<DocBlockModel> blocks,

    /// Parent document when this node is a discussion opened on a span.
    ProjectModelId? parentDocId,

    /// Span this node anchors to in [parentDocId].
    AnchorSpanModel? anchorSpan,

    /// Snapshot of the anchored text at creation ("history note").
    @Default('') String spanSnapshot,

    /// Agent-doc payload (ADR 0003). Null for every other doc format.
    AgentDocModel? agent,
    @Default(DocStatus.open) DocStatus status,
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
}

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
