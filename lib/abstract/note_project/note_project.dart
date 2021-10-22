part of abstract;

typedef NoteProjectId = String;

@HiveType(typeId: HiveBoxesIds.noteProject)
class NoteProject extends BasicProject {
  NoteProject({
    required final String id,
    required final DateTime created,
    required final DateTime updated,
    final this.note = '',
    final bool isCompleted = defaultProjectIsCompleted,
  }) : super(
          created: created,
          id: id,
          isCompleted: isCompleted,
          updated: updated,
          title: '',
        );
  static Future<NoteProject> create({
    required final String title,
  }) async {
    final created = DateTime.now();
    final note = NoteProject(
      updated: created,
      created: created,
      id: createId(),
    );
    final box = await Hive.openBox<NoteProject>(HiveBoxesIds.noteProjectKey);
    await box.put(note.id, note);
    return note;
  }

  @override
  @JsonKey(ignore: true)
  String get title {
    if (note.length <= 90) return note;
    return note.substring(0, 90);
  }

  /// title setter not needed to be implemented.
  @override
  set title(final String _) => throw UnimplementedError();

  @override
  String toShareString() => note;

  @HiveField(projectLatestFieldHiveId + 1)
  String note;
}

/// A mock for [NoteProject].
/// To create use `final mockNoteProject = MockNoteProject();`
// ignore: avoid_implementing_value_types
class MockNoteProject extends Mock implements NoteProject {}
