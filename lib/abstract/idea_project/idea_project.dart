// ignore_for_file: overridden_fields

part of abstract;

@HiveType(typeId: HiveBoxesIds.ideaProject)
class IdeaProject extends BasicProject<IdeaProjectModel> with EquatableMixin {
  IdeaProject({
    required final super.id,
    required final super.title,
    required final super.createdAt,
    this.newAnswerText = '',
    this.folder,
    this.newQuestion,
    @Deprecated('use getAnswers instead') this.answers,
    final bool? isToDelete,
    final DateTime? updatedAt,
    final super.isCompleted = defaultProjectIsCompleted,
  })  : isToDelete = isToDelete ?? defaultProjectIsDeleted,
        super(
          updatedAt: updatedAt ?? createdAt,
          folder: folder,
          type: ProjectType.idea,
        );

  static Future<IdeaProject> fromModel({
    required final IdeaProjectModel model,
    required final BuildContext context,
  }) async {
    final foldersNotifier = context.read<ProjectFoldersNotifier>();
    final folder = foldersNotifier.state[model.folderId]!;
    final questionsNotifier = context.read<IdeaProjectQuestionsNotifier>();
    final question = questionsNotifier.state[model.newQuestionId];

    return create(
      context: context,
      title: model.title,
      folder: folder,
      createdAt: model.createdAt,
      id: model.id,
      isCompleted: model.isCompleted,
      newAnswerText: model.newAnswerText,
      newQuestion: question,
      updatedAt: model.updatedAt,
    );
  }

  // ignore: long-parameter-list
  static Future<IdeaProject> create({
    required final String title,
    required final ProjectFolder folder,
    required final BuildContext context,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? id,
    final bool isCompleted = defaultProjectIsCompleted,
    final String newAnswerText = '',
    final IdeaProjectQuestion? newQuestion,
  }) async {
    final created = dateTimeNowUtc();
    final idea = IdeaProject(
      updatedAt: updatedAt ?? created,
      createdAt: createdAt ?? created,
      folder: folder,
      isCompleted: isCompleted,
      newAnswerText: newAnswerText,
      newQuestion: newQuestion,
      id: id ?? createId(),
      title: title,
    );
    final ideaBox =
        await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);
    await ideaBox.put(idea.id, idea);
    context.read<IdeaProjectsNotifier>().put(key: idea.id, value: idea);
    folder.addProject(idea);

    return idea;
  }

  @Deprecated('use getAnswers instead')
  @HiveField(projectLatestFieldHiveId + 1)
  HiveList<IdeaProjectAnswer>? answers;

  /// keeps latest written text from [AnswerCreator]
  @HiveField(projectLatestFieldHiveId + 2)
  String newAnswerText;

  /// keeps latest selected [IdeaProjectQuestion] from [AnswerCreator]
  @HiveField(projectLatestFieldHiveId + 3)
  IdeaProjectQuestion? newQuestion;

  @override
  @HiveField(projectLatestFieldHiveId + 4)
  ProjectFolder? folder;

  @override
  @HiveField(projectLatestFieldHiveId + 5)
  bool isToDelete;
  Iterable<IdeaProjectAnswer> getAnswers(final BuildContext context) {
    final answersNotifier = context.read<IdeaProjectAnswersNotifier>();

    return answersNotifier.getAllByIdea(ideaId: id);
  }

  @override
  String toShareString(final BuildContext context) {
    final buffer = StringBuffer('$title \n');
    final answers = getAnswers(context);
    for (final answer in answers) {
      buffer.writeln(answer.toShareString(context));
    }

    return buffer.toString();
  }

  @override
  List get props => [id];

  @override
  bool? get stringify => true;

  @override
  IdeaProjectModel toModel({required final UserModel user}) {
    return IdeaProjectModel(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      projectType: type,
      userId: user.id,
      isCompleted: isCompleted,
      folderId: folder!.id,
      newAnswerText: newAnswerText,
      newQuestionId: newQuestion?.id,
      title: title,
    );
  }

  @override
  Future<void> deleteWithRelatives({
    required final BuildContext context,
  }) async {
    context.read<IdeaProjectsNotifier>().remove(key: key);
    final answers = getAnswers(context);
    final deleteAnswerFutures = answers.map(
      (final answer) => answer.deleteWithRelatives(
        context: context,
      ),
    );
    await Future.wait(deleteAnswerFutures);
    folder?.removeProject(this);
    await delete();
  }

  Future<void> removeAnswer({
    required final IdeaProjectAnswer answer,
    required final BuildContext context,
  }) async =>
      answer.deleteWithRelatives(context: context);
}

/// A mock for [IdeaProject].
/// To create use `final mockIdeaProject = MockIdeaProject();`
// ignore: avoid_implementing_value_types
// class MockIdeaProject extends Mock implements IdeaProject {}

// ignore: camel_case_extensions
extension IdeaProjectMigration_v4 on IdeaProject {
  // ignore: non_constant_identifier_names
  Future<void> migrate_v4() async {
    await Future.wait(
      (answers ?? <IdeaProjectAnswer>[]).map((final answer) {
        answer.projectId = answer.id;

        return answer.save();
      }),
    );
  }
}

// ignore: non_constant_identifier_names
Future<void> migrateIdeas_v4(final Box<IdeaProject> ideas) async {
  for (final idea in ideas.values) {
    await idea.migrate_v4();
  }
}
