part of abstract;

/// TODO: implement StoryProject
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
        );
}
