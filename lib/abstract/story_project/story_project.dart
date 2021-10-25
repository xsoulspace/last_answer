part of abstract;

/// TODO(arenukvern): implement StoryProject
@HiveType(typeId: HiveBoxesIds.storyProject)
class StoryProject extends BasicProject {
  StoryProject({
    required final String id,
    required final String title,
    required final DateTime created,
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          title: title,
          isCompleted: isCompleted,
          updated: created,
        );
}

/// A mock for [StoryProject].
/// To create use `final mockNoteProject = MockStoryProject();`
// ignore: avoid_implementing_value_types
class MockStoryProject extends Mock implements StoryProject {}
