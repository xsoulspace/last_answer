part of abstract;

typedef NoteProjectId = String;

@HiveType(typeId: HiveBoxesIds.noteProject)
class NoteProject extends BasicProject {
  NoteProject({
    required final String id,
    required final String title,
    required final DateTime created,
    required final DateTime updated,
    final this.note = '',
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          title: title,
          isCompleted: isCompleted,
          updated: updated,
        );
  static Future<NoteProject> create({
    required final String title,
  }) async {
    final created = DateTime.now();
    final note = NoteProject(
      updated: created,
      created: created,
      id: createId(),
      title: title,
    );
    await Hive.box<NoteProject>(HiveBoxesIds.noteProjectKey).put(note.id, note);
    return note;
  }

  @HiveField(projectLatestFieldHiveId + 1)
  String note;
}

/// A mock for [NoteProject].
/// To create use `final mockNoteProject = MockNoteProject();`
// ignore: avoid_implementing_value_types
class MockNoteProject extends Mock implements NoteProject {}
