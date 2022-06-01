// ignore_for_file: overridden_fields

part of abstract;

// TODO(arenukvern): implement StoryProject
@HiveType(typeId: HiveBoxesIds.storyProject)
class StoryProject extends BasicProject {
  StoryProject({
    required final super.id,
    required final super.title,
    required final super.createdAt,
    required final this.folder,
    this.isToDelete = defaultProjectIsDeleted,
    final DateTime? updatedAt,
    final super.isCompleted = defaultProjectIsCompleted,
  }) : super(
          updatedAt: updatedAt ?? createdAt,
          folder: folder,
          type: ProjectType.story,
        );

  @override
  @HiveField(projectLatestFieldHiveId + 1)
  ProjectFolder? folder;

  @override
  @HiveField(projectLatestFieldHiveId + 2)
  bool isToDelete;

  @override
  HasId toModel({required final UserModel user}) {
    // TODO: implement toModel
    throw UnimplementedError();
  }
}

/// A mock for [StoryProject].
/// To create use `final mockNoteProject = MockStoryProject();`
// ignore: avoid_implementing_value_types
// class MockStoryProject extends Mock implements StoryProject {}
