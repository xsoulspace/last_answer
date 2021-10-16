part of abstract;

@HiveType(typeId: HiveBoxesIds.ideaProject)
class IdeaProject extends BasicProject with EquatableMixin {
  IdeaProject({
    required final String id,
    required final String title,
    required final DateTime created,
    required final DateTime updated,
    final this.answers,
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          title: title,
          isCompleted: isCompleted,
          updated: updated,
        );
  static Future<IdeaProject> create({
    required final String title,
  }) async {
    final created = DateTime.now();
    final idea = IdeaProject(
      updated: created,
      created: created,
      id: createId(),
      title: title,
    );
    final ideaBox = Hive.box<IdeaProject>(HiveBoxesIds.ideaProjectKey);
    final ideaAnswersBox =
        Hive.box<IdeaProjectAnswer>(HiveBoxesIds.ideaProjectAnswerKey);
    await ideaBox.put(idea.id, idea);
    idea.answers = HiveList(ideaAnswersBox);
    return idea;
  }

  @HiveField(projectLatestFieldHiveId + 1)
  HiveList<IdeaProjectAnswer>? answers;

  @override
  List get props => [id];

  @override
  bool? get stringify => true;
}

/// A mock for [IdeaProject].
/// To create use `final mockIdeaProject = MockIdeaProject();`
// ignore: avoid_implementing_value_types
class MockIdeaProject extends Mock implements IdeaProject {}
