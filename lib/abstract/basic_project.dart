part of abstract;

/// Use this for constructor default value in other projects
const defaultProjectIsCompleted = false;
const defaultProjectIsDeleted = false;

/// Use this field to count fields in other projects like
/// `@HiveField(projectLatestFieldHiveId+1)`
const projectLatestFieldHiveId = 4;

class BasicProjectIndexes {
  BasicProjectIndexes._();
  static const created = 3;
  static const id = 0;
  static const isCompleted = 1;
  static const title = 2;
}

/// This type purpose is to support all project types
/// such as [NoteProject], [StoryProject], [IdeaProject]
abstract class BasicProject extends HiveObjectWithId
    with EquatableMixin
    implements Sharable, BasicProjectFields {
  BasicProject({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.folder,
    required this.type,
    this.isToDelete = defaultProjectIsDeleted,
    this.isCompleted = defaultProjectIsCompleted,
  });
  @HiveField(BasicProjectIndexes.created)
  DateTime createdAt;

  /// Always override it in extended projects
  /// to assign correct [HiveField] id
  @override
  ProjectFolder? folder;

  @override
  @HiveField(BasicProjectIndexes.id)
  final ProjectId id;

  @HiveField(BasicProjectIndexes.isCompleted)
  bool isCompleted;

  @HiveField(BasicProjectIndexes.title)
  String title;

  @override
  final ProjectType type;

  @HiveField(projectLatestFieldHiveId)
  DateTime updatedAt;

  @override
  bool isToDelete;

  /// Always override it in extended projects
  @override
  String toShareString() => '';

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;

  SerializableProjectId get serializableId => SerializableProjectId(
        id: id,
        type: type,
      );
}
