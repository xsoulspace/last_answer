part of 'data_models.dart';

extension type const ProjectModelId(String value) {
  factory ProjectModelId.fromJson(final String value) => ProjectModelId(value);
  factory ProjectModelId.generate() => ProjectModelId(createId());
  static const empty = ProjectModelId('');
  static const systemChangelog = ProjectModelId('changelog');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
}

enum ProjectTypes {
  idea,
  note,
  systemChangelog,
}

@freezed
sealed class ProjectModel with _$ProjectModel implements Sharable, Archivable {
  @Implements<Archivable>()
  @Implements<Sharable>()
  const factory ProjectModel.idea({
    required final ProjectModelId id,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    @Default('') final String title,
    @Default(ProjectTypes.idea) final ProjectTypes type,
    final DateTime? archivedAt,
    @Default([]) final List<IdeaProjectAnswerModel> answers,
    final IdeaProjectAnswerModel? draftAnswer,
    @Default([]) final List<ProjectTagModelId> tagsIds,
  }) = ProjectModelIdea;
  @Implements<Archivable>()
  @Implements<Sharable>()
  const factory ProjectModel.note({
    required final ProjectModelId id,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    @Default('') final String note,
    @Default(ProjectTypes.note) final ProjectTypes type,
    @Default(0) final int charactersLimit,
    final DateTime? archivedAt,
    @Default([]) final List<ProjectTagModelId> tagsIds,
  }) = ProjectModelNote;

  /// keeps only position of system changelog whithout any content
  @Implements<Sharable>()
  const factory ProjectModel.changelog({
    required final DateTime createdAt,
    required final DateTime updatedAt,
    @Default(LocalizedTextModel.empty) final LocalizedTextModel title,
    @Default(ProjectModelId.systemChangelog) final ProjectModelId id,
    @Default(ProjectTypes.systemChangelog) final ProjectTypes type,
    @Default([]) final List<ProjectTagModelId> tagsIds,
  }) = ProjectModelChangelog;
  factory ProjectModel.fromJson(final dynamic json) =>
      _$ProjectModelFromJson(json as Map<String, dynamic>);
  const ProjectModel._();
  static ProjectModelChangelog getSystemChangelogFromNotifications({
    required final ProjectModelChangelog project,
    required final List<NotificationMessageModel> notifications,
  }) {
    final newest = notifications.first;
    final oldest = notifications.last;

    return ProjectModelChangelog(
      createdAt: oldest.created,
      title: newest.title,
      updatedAt: project.updatedAt.isAfter(newest.created)
          ? project.updatedAt
          : newest.created,
    );
  }

  static const titleLimit = 90;
  String getTitle(final BuildContext context) => switch (this) {
        ProjectModelIdea(title: final titleStr) => titleStr,
        ProjectModelNote(:final note) => _getTitle(note),
        ProjectModelChangelog(:final title) =>
          _getTitle(title.localize(context)),
      };

  @override
  String toShareString(final BuildContext context) => map(
        idea: (final value) =>
            ideaProjectToShareString(context: context, projectIdea: value),
        note: (final value) => value.note,

        /// maybe share newest changelog, but not sure
        changelog: (final value) => '',
      );

  @override
  String toSharableTitle(final BuildContext context) => getTitle(context);

  static final emptyNote = ProjectModelNote(
    id: ProjectModelId.empty,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  static final emptyIdea = ProjectModelIdea(
    id: ProjectModelId.empty,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

String _getTitle(
  final String text, {
  final int titleLimit = ProjectModel.titleLimit,
}) {
  if (text.length <= titleLimit) return text;

  return text.substring(0, titleLimit);
}

extension type const IdeaProjectAnswerModelId(String value) {
  factory IdeaProjectAnswerModelId.fromJson(final String value) =>
      IdeaProjectAnswerModelId(value);
  factory IdeaProjectAnswerModelId.generate() =>
      IdeaProjectAnswerModelId(createId());
  static const empty = IdeaProjectAnswerModelId('');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
}

@freezed
class IdeaProjectAnswerModel with _$IdeaProjectAnswerModel implements Sharable {
  const factory IdeaProjectAnswerModel({
    required final IdeaProjectAnswerModelId id,
    required final DateTime createdAt,
    required final IdeaProjectQuestionModel question,
    @Default('') final String text,
  }) = _IdeaProjectAnswerModel;
  const IdeaProjectAnswerModel._();
  factory IdeaProjectAnswerModel.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectAnswerModelFromJson(json);
  String get title => _getTitle(text, titleLimit: 50);
  @override
  String toSharableTitle(final BuildContext context) => title;
  @override
  String toShareString(final BuildContext context) =>
      '${question.toShareString(context)} \n $text';
}

extension type const IdeaProjectQuestionModelId(String value) {
  factory IdeaProjectQuestionModelId.fromJson(final String value) =>
      IdeaProjectQuestionModelId(value);
  factory IdeaProjectQuestionModelId.generate() =>
      IdeaProjectQuestionModelId(createId());
  static const empty = IdeaProjectQuestionModelId('');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
}

@freezed
class IdeaProjectQuestionModel
    with _$IdeaProjectQuestionModel
    implements Sharable {
  const factory IdeaProjectQuestionModel({
    required final IdeaProjectQuestionModelId id,
    required final LocalizedTextModel title,
  }) = _IdeaProjectQuestionModel;
  const IdeaProjectQuestionModel._();
  factory IdeaProjectQuestionModel.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectQuestionModelFromJson(json);
  @override
  String toShareString(final BuildContext context) => title.localize(context);
  @override
  String toSharableTitle(final BuildContext context) =>
      _getTitle(title.localize(context));
}

@freezed
class LocalizedTextModel with _$LocalizedTextModel {
  const factory LocalizedTextModel({
    required final String ru,
    required final String en,
    @Default('') final String it,
    @Default('') final String ga,
  }) = _LocalizedTextModel;
  factory LocalizedTextModel.fromJson(final Map<String, dynamic> json) =>
      _$LocalizedTextModelFromJson(json);
  const LocalizedTextModel._();
  static const empty = LocalizedTextModel(en: '', ru: '');

  /// If any new [Languages] added, add this to [values]
  Map<LanguageName, String?> get values => {
        Locales.ru.languageCode: ru,
        Locales.en.languageCode: en,
        Locales.it.languageCode: it,
        // Locales.ga.languageCode: ga,
      };

  String localize(final BuildContext context) =>
      _getByLanguage(context.locale.languageCode);
  String _getByLanguage(final String languageCode) =>
      values[languageCode] ?? ''.useWhenEmpty(en);
}

String getLanguageCode(final LanguageName language) {
  String lang = language;
  if (language.contains('_')) {
    lang = language.split('_').first;
  }

  return lang;
}

String ideaProjectToShareString({
  required final ProjectModelIdea projectIdea,
  required final BuildContext context,
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
  factory ProjectTagModelId.fromJson(final String json) =>
      ProjectTagModelId(json);
  static const empty = ProjectTagModelId('');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
}

@freezed
class ProjectTagModel with _$ProjectTagModel {
  const factory ProjectTagModel({
    required final ProjectTagModelId id,
    @Default('') final String title,
  }) = _ProjectTagModel;
  factory ProjectTagModel.fromJson(final Map<String, dynamic> json) =>
      _$ProjectTagModelFromJson(json);
  const ProjectTagModel._();
  static const empty = ProjectTagModel(id: ProjectTagModelId.empty);
  bool get isEmpty => id.isEmpty;
}
