// ignore_for_file: overridden_fields

part of abstract;

// TODO(arenukvern): implement StoryProject
@HiveType(typeId: HiveBoxesIds.storyProject)
class StoryProject extends BasicProject {
  StoryProject({
    required final ProjectId id,
    required final String title,
    required final DateTime createdAt,
    required final this.folder,
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          createdAt: createdAt,
          id: id,
          title: title,
          isCompleted: isCompleted,
          updatedAt: createdAt,
          folder: folder,
          type: ProjectType.story,
        );

  @override
  @HiveField(projectLatestFieldHiveId + 1)
  ProjectFolder? folder;
}

/// A mock for [StoryProject].
/// To create use `final mockNoteProject = MockStoryProject();`
// ignore: avoid_implementing_value_types
// class MockStoryProject extends Mock implements StoryProject {}
