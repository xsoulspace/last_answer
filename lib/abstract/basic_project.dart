part of abstract;

/// Use this for constructor default value in other projects
const defaultProjectIsCompleted = false;

/// Use this field to count fields in other projects like
/// `@HiveField(projectLatestFieldHiveId+1)`
const projectLatestFieldHiveId = 3;

/// This type purpose is to support all project types
/// such as [NoteProject], [StoryProject], [IdeaProject]
class BasicProject extends HiveObject with EquatableMixin {
  BasicProject({
    required final this.id,
    required final this.title,
    required final this.created,
    final this.isCompleted = defaultProjectIsCompleted,
  });
  @HiveField(0)
  final String id;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  String title;

  @HiveField(projectLatestFieldHiveId)
  final DateTime created;

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;
}
