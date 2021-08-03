part of abstract;

@HiveType(typeId: HiveBoxesIds.ideaProject)
class IdeaProject extends BasicProject {
  IdeaProject({
    required final String id,
    required final String title,
    required final DateTime created,
    required final this.answers,
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          title: title,
          isCompleted: isCompleted,
        );

  @HiveField(projectLatestFieldHiveId + 1)
  HiveList<IdeaProjectAnswer>? answers;
}

/// A mock for [IdeaProject].
/// To create use `final mockIdeaProject = MockIdeaProject();`
// ignore: avoid_implementing_value_types
class MockIdeaProject extends Mock implements IdeaProject {}
