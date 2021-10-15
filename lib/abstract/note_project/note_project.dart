part of abstract;

@HiveType(typeId: HiveBoxesIds.noteProject)
class NoteProject extends BasicProject {
  NoteProject({
    required final String id,
    required final String title,
    required final DateTime created,
    final bool isCompleted = defaultProjectIsCompleted,
    final this.note = '',
  }) : super(
            created: created,
            id: id,
            title: title,
            isCompleted: isCompleted,
            updated: created);
  @HiveField(projectLatestFieldHiveId + 1)
  String note;
}

/// A mock for [NoteProject].
/// To create use `final mockNoteProject = MockNoteProject();`
// ignore: avoid_implementing_value_types
class MockNoteProject extends Mock implements NoteProject {}
