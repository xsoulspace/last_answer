part of abstract;

/// Use this for constructor default value in other projects
const defaultProjectIsCompleted = false;

/// Use this field to count fields in other projects like
/// `@HiveField(projectLatestFieldHiveId+1)`
const projectLatestFieldHiveId = 4;

typedef ProjectId = String;

/// This type purpose is to support all project types
/// such as [NoteProject], [StoryProject], [IdeaProject]
class BasicProject extends HiveObject
    with EquatableMixin
    implements Sharable, BasicProjectFields {
  BasicProject({
    required final this.id,
    required final this.title,
    required final this.created,
    required final this.updated,
    required final this.folder,
    required final this.type,
    final this.isCompleted = defaultProjectIsCompleted,
  });
  @HiveField(0)
  final ProjectId id;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  String title;

  @HiveField(3)
  DateTime created;

  @HiveField(projectLatestFieldHiveId)
  DateTime updated;

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

  /// Always override it in extended projects
  /// to assign correct [HiveField] id
  @override
  ProjectFolder folder;

  @override
  final ProjectTypes type;
}
