// ignore_for_file: overridden_fields

part of abstract;

typedef StoryProjectId = String;

// TODO(arenukvern): implement StoryProject
@HiveType(typeId: HiveBoxesIds.storyProject)
class StoryProject extends BasicProject {
  StoryProject({
    required final String id,
    required final String title,
    required final DateTime created,
    required final this.folder,
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          title: title,
          isCompleted: isCompleted,
          updated: created,
          folder: folder,
          type: ProjectTypes.story,
        );

  @override
  @HiveField(projectLatestFieldHiveId + 1)
  ProjectFolder folder;
}

/// A mock for [StoryProject].
/// To create use `final mockNoteProject = MockStoryProject();`
// ignore: avoid_implementing_value_types
class MockStoryProject extends Mock implements StoryProject {}
