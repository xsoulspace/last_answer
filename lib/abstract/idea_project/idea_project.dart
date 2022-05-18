// ignore_for_file: overridden_fields

part of abstract;

@HiveType(typeId: HiveBoxesIds.ideaProject)
class IdeaProject extends BasicProject
    with EquatableMixin
    implements Deletable {
  IdeaProject({
    required final super.id,
    required final super.title,
    required final super.createdAt,
    this.isToDelete = false,
    this.newAnswerText = '',
    this.folder,
    this.newQuestion,
    this.answers,
    final DateTime? updatedAt,
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          isCompleted: isCompleted,
          updatedAt: updatedAt ?? createdAt,
          folder: folder,
          type: ProjectType.idea,
        );
  static Future<IdeaProject> create({
    required final String title,
    required final ProjectFolder folder,
  }) async {
    final created = DateTime.now();
    final idea = IdeaProject(
      updatedAt: created,
      createdAt: created,
      folder: folder,
      id: createId(),
      title: title,
    );
    final ideaBox =
        await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);
    final ideaAnswersBox = await Hive.openBox<IdeaProjectAnswer>(
      HiveBoxesIds.ideaProjectAnswerKey,
    );
    await ideaBox.put(idea.id, idea);
    idea.answers = HiveList<IdeaProjectAnswer>(ideaAnswersBox);

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
}

/// A mock for [IdeaProject].
/// To create use `final mockIdeaProject = MockIdeaProject();`
// ignore: avoid_implementing_value_types
// class MockIdeaProject extends Mock implements IdeaProject {}
