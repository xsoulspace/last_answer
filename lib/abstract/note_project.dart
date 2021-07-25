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
        );
  @HiveField(projectLatestFieldHiveId + 1)
  String note;
}
