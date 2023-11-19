part of 'data_models.dart';

@Freezed(fromJson: false, toJson: false)
class ProjectModelId with _$ProjectModelId {
  const factory ProjectModelId({
    required final String value,
  }) = _ProjectModelId;
  const ProjectModelId._();
  factory ProjectModelId.fromJson(final String value) =>
      ProjectModelId(value: value);
  static const empty = ProjectModelId(value: '');
  bool get isEmpty => value.isEmpty;
  String toJson() => value;
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
  }) = ProjectModelNote;
  factory ProjectModel.fromJson(final Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
  const ProjectModel._();
  static const titleLimit = 90;
  String get title => switch (this) {
        ProjectModelIdea(title: final titleStr) => titleStr,
        ProjectModelNote(:final note) => _getTitle(note),
      };

  @override
  String toShareString(final BuildContext context) => map(
        idea: (final value) =>
            ideaProjectToShareString(context: context, projectIdea: value),
        note: (final value) => value.note,
      );

  @override
  String toSharableTitle(final BuildContext context) => title;

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

@Freezed(fromJson: false, toJson: false)
class IdeaProjectAnswerModelId with _$IdeaProjectAnswerModelId {
  const factory IdeaProjectAnswerModelId({
    required final String value,
  }) = _IdeaProjectAnswerModelId;
  const IdeaProjectAnswerModelId._();
  factory IdeaProjectAnswerModelId.fromJson(final String value) =>
      IdeaProjectAnswerModelId(value: value);
  static const empty = IdeaProjectAnswerModelId(value: '');
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

@Freezed(fromJson: false, toJson: false)
class IdeaProjectQuestionModelId with _$IdeaProjectQuestionModelId {
  const factory IdeaProjectQuestionModelId({
    required final String value,
  }) = _IdeaProjectQuestionModelId;
  const IdeaProjectQuestionModelId._();
  factory IdeaProjectQuestionModelId.fromJson(final String value) =>
      IdeaProjectQuestionModelId(value: value);
  static const empty = IdeaProjectQuestionModelId(value: '');
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
