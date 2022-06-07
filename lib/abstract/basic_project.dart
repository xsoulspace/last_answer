import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/basic_project_fields.dart';
import 'package:lastanswer/abstract/project_folder.dart';
import 'package:lastanswer/abstract/serialazable_project_id.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/utils/utils.dart';

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
abstract class BasicProject<TModel extends BasicProjectModel>
    extends RemoteHiveObjectWithId<TModel>
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
  String toShareString(final BuildContext context) => '';

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;

  SerializableProjectId get serializableId => SerializableProjectId(
        id: id,
        type: type,
      );
}
