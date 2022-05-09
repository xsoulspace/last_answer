// ignore_for_file: overridden_fields

part of abstract;

typedef IdeaProjectId = String;

@HiveType(typeId: HiveBoxesIds.ideaProject)
class IdeaProject extends BasicProject with EquatableMixin {
  IdeaProject({
    required final String id,
    required final String title,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final this.folder,
    final bool isCompleted = defaultProjectIsCompleted,
    final this.newAnswerText = '',
    final this.newQuestion,
    final this.answers,
  }) : super(
          createdAt: createdAt,
          id: id,
          title: title,
          isCompleted: isCompleted,
          updatedAt: updatedAt,
          folder: folder,
          type: ProjectTypes.idea,
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
class MockIdeaProject extends Mock implements IdeaProject {}
