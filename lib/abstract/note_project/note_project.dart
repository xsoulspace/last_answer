import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/basic_project.dart';
import 'package:lastanswer/abstract/hive_boxes_ids.dart';
import 'package:lastanswer/abstract/project_folder.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';

part 'note_project.g.dart';

@HiveType(typeId: HiveBoxesIds.noteProject)
class NoteProject extends BasicProject<NoteProjectModel> {
  NoteProject({
    required super.id,
    required super.createdAt,
    this.note = '',
    this.folder,
    this.charactersLimit,
    super.isCompleted = defaultProjectIsCompleted,
    final bool? isToDelete,
    final DateTime? updatedAt,
  })  : isToDelete = isToDelete ?? defaultProjectIsDeleted,
        super(
          updatedAt: updatedAt ?? createdAt,
          title: '',
          folder: folder,
          type: ProjectType.note,
        );

  static Future<NoteProject> fromModel({
    required final NoteProjectModel model,
    required final BuildContext context,
  }) async {
    final foldersNotifier = context.read<ProjectFoldersNotifier>();
    final folder = foldersNotifier.state[model.folderId]!;

    return create(
      context: context,
      note: model.note,
      folder: folder,
      charactersLimit: model.charactersLimit,
      createdAt: model.createdAt,
      id: model.id,
      isCompleted: model.isCompleted,
      updatedAt: model.updatedAt,
    );
  }

  // ignore: long-parameter-list
  static Future<NoteProject> create({
    required final ProjectFolder folder,
    required final BuildContext context,
    final int? charactersLimit,
    final String? id,
    final DateTime? updatedAt,
    final DateTime? createdAt,
    final String note = '',
    final bool isCompleted = defaultProjectIsCompleted,
  }) async {
    final created = dateTimeNowUtc();

    final noteProject = NoteProject(
      updatedAt: updatedAt ?? created,
      createdAt: createdAt ?? created,
      folder: folder,
      id: id ?? createId(),
      isCompleted: isCompleted,
      note: note,
      charactersLimit: charactersLimit,
    );

    final box = await Hive.openBox<NoteProject>(HiveBoxesIds.noteProjectKey);
    await box.put(noteProject.id, noteProject);
    context
        .read<NoteProjectsNotifier>()
        .put(key: noteProject.id, value: noteProject);
    folder.addProject(noteProject);

    return noteProject;
  }

  @HiveField(projectLatestFieldHiveId + 1)
  String note;

  @override
  @HiveField(projectLatestFieldHiveId + 2)
  ProjectFolder? folder;

  /// can be set via [CharactersLimitSetting]
  @HiveField(projectLatestFieldHiveId + 3)
  int? charactersLimit;

  @override
  @HiveField(projectLatestFieldHiveId + 4)
  bool isToDelete;

  static const titleLimit = 90;
  @override
  @JsonKey(ignore: true)
  String get title => getTitle(note);

  static String getTitle(final String text) {
    if (text.length <= titleLimit) return text;

    return text.substring(0, titleLimit);
  }

  /// title setter not needed to be implemented.
  @override
  set title(final String _) => throw UnimplementedError();

  @override
  String toShareString(final BuildContext context) => note;

  @override
  NoteProjectModel toModel({required final UserModel user}) {
    return NoteProjectModel(
      charactersLimit: charactersLimit,
      createdAt: createdAt,
      folderId: folder!.id,
      id: id,
      isCompleted: isCompleted,
      note: note,
      projectType: type,
      updatedAt: updatedAt,
      ownerId: user.id,
    );
  }

  @override
  Future<void> deleteWithRelatives({
    required final BuildContext context,
  }) async {
    context.read<NoteProjectsNotifier>().remove(key: key);
    folder?.removeProject(this);
    await delete();
  }
}

/// A mock for [NoteProject].
/// To create use `final mockNoteProject = MockNoteProject();`
// ignore: avoid_implementing_value_types
// class MockNoteProject extends Mock implements NoteProject {}
