part of 'hive_models.dart';

/// Use this for constructor default value in other projects
const defaultProjectIsCompleted = false;

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

typedef ProjectId = String;

@Deprecated('')

/// This type purpose is to support all project types
/// such as [NoteProject], [StoryProject], [IdeaProject]
class BasicProject extends HiveObject
    with EquatableMixin
    implements Sharable, BasicProjectFields, HasId {
  @Deprecated('')
  BasicProject({
    required this.id,
    required this.title,
    required this.created,
    required this.updated,
    required this.folder,
    required this.type,
    this.isCompleted = defaultProjectIsCompleted,
  });
  @HiveField(BasicProjectIndexes.created)
  DateTime created;

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
  final ProjectTypes type;

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
}
