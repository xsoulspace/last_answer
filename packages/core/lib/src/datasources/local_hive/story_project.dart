// ignore_for_file: overridden_fields
part of 'hive_models.dart';

typedef StoryProjectId = String;

@Deprecated('')
// TODO(arenukvern): implement StoryProject
@HiveType(typeId: HiveBoxesIds.storyProject)
class StoryProject extends BasicProject {
  @Deprecated('')
  StoryProject({
    required super.id,
    required super.title,
    required super.created,
    required this.folder,
    super.isCompleted,
  }) : super(
          updated: created,
          folder: folder,
          type: ProjectTypes.story,
        );

  @override
  @HiveField(projectLatestFieldHiveId + 1)
  ProjectFolder? folder;
}

/// A mock for [StoryProject].
/// To create use `final mockNoteProject = MockStoryProject();`
// ignore: avoid_implementing_value_types
class MockStoryProject extends Mock implements StoryProject {}
