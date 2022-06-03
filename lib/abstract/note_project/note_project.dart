// ignore_for_file: overridden_fields

part of abstract;

@HiveType(typeId: HiveBoxesIds.noteProject)
class NoteProject extends BasicProject<NoteProjectModel> {
  NoteProject({
    required final super.id,
    required final super.createdAt,
    this.note = '',
    this.isToDelete = defaultProjectIsDeleted,
    this.folder,
    this.charactersLimit,
    final super.isCompleted = defaultProjectIsCompleted,
    final DateTime? updatedAt,
  }) : super(
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
    final int? charactersLimit,
    final String? id,
    final DateTime? updatedAt,
    final DateTime? createdAt,
    final String note = '',
    final bool isCompleted = defaultProjectIsCompleted,
  }) async {
    final created = DateTime.now();

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
  String toShareString() => note;

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
      userId: user.id,
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
