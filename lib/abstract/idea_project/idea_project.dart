// ignore_for_file: overridden_fields

part of abstract;

@HiveType(typeId: HiveBoxesIds.ideaProject)
class IdeaProject extends BasicProject<IdeaProjectModel> with EquatableMixin {
  IdeaProject({
    required final super.id,
    required final super.title,
    required final super.createdAt,
    this.isToDelete = defaultProjectIsDeleted,
    this.newAnswerText = '',
    this.folder,
    this.newQuestion,
    this.answers,
    final DateTime? updatedAt,
    final super.isCompleted = defaultProjectIsCompleted,
  }) : super(
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
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? id,
    final bool isCompleted = defaultProjectIsCompleted,
    final String newAnswerText = '',
    final IdeaProjectQuestion? newQuestion,
  }) async {
    final created = DateTime.now();
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
    final ideaAnswersBox = await Hive.openBox<IdeaProjectAnswer>(
      HiveBoxesIds.ideaProjectAnswerKey,
    );
    await ideaBox.put(idea.id, idea);
    idea.answers = HiveList<IdeaProjectAnswer>(ideaAnswersBox);
    folder.addProject(idea);

    return idea;
  }

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

  @override
  String toShareString() {
    final buffer = StringBuffer('$title \n');
    final List<IdeaProjectAnswer> resolvedAnswers = answers ?? [];
    for (final answer in resolvedAnswers) {
      buffer.writeln(answer.toShareString());
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
      newQuestionId: newQuestion!.id,
      title: title,
    );
  }

  @override
  Future<void> deleteWithRelatives({
    required final BuildContext context,
  }) async {
    context.read<IdeaProjectsNotifier>().remove(key: key);
    final deleteAnswerFutures = answers?.map(
      (final answer) => answer.deleteWithRelatives(
        context: context,
        idea: this,
      ),
    );
    if (deleteAnswerFutures != null) {
      await Future.wait(deleteAnswerFutures);
    }
    folder?.removeProject(this);
    await delete();
  }

  void addAnswer(final IdeaProjectAnswer answer) {
    answers?.add(answer);
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
