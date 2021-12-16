// ignore_for_file: overridden_fields

part of abstract;

typedef NoteProjectId = String;

@HiveType(typeId: HiveBoxesIds.noteProject)
class NoteProject extends BasicProject {
  NoteProject({
    required final String id,
    required final DateTime created,
    required final DateTime updated,
    final this.folder,
    final this.note = '',
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          isCompleted: isCompleted,
          updated: updated,
          title: '',
          folder: folder,
          type: ProjectTypes.note,
        );
  static Future<NoteProject> create({
    required final String title,
    required final ProjectFolder folder,
  }) async {
    final created = DateTime.now();

    final note = NoteProject(
      updated: created,
      created: created,
      folder: folder,
      id: createId(),
    );

    final box = await Hive.openBox<NoteProject>(HiveBoxesIds.noteProjectKey);
    await box.put(note.id, note);

    return note;
  }

  @HiveField(projectLatestFieldHiveId + 1)
  String note;

  @override
  @HiveField(projectLatestFieldHiveId + 2)
  ProjectFolder? folder;

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
}

/// A mock for [NoteProject].
/// To create use `final mockNoteProject = MockNoteProject();`
// ignore: avoid_implementing_value_types
class MockNoteProject extends Mock implements NoteProject {}
