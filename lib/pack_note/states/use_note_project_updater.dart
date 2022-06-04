part of pack_note;

@immutable
class NoteProjectUpdate {
  const NoteProjectUpdate({
    this.charactersLimitChanged = false,
    this.positionChanged = false,
  });
  final bool positionChanged;
  final bool charactersLimitChanged;
}

NoteProjectUpdaterState useNoteProjectUpdaterState({
  required final NoteProject note,
  required final StreamController<NoteProjectUpdate> updatesStream,
  required final NoteProjectsNotifier notesNotifier,
  required final CurrentFolderNotifier folderNotifier,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useNoteProjectUpdaterState',
        state: NoteProjectUpdaterState(
          note: note,
          updatesStream: updatesStream,
          folderNotifier: folderNotifier,
          notesNotifier: notesNotifier,
        ),
      ),
    );

class NoteProjectUpdaterState extends ContextfulLifeState {
  NoteProjectUpdaterState({
    required this.folderNotifier,
    required this.notesNotifier,
    required this.note,
    required this.updatesStream,
  });

  final NoteProject note;
  final StreamController<NoteProjectUpdate> updatesStream;
  final NoteProjectsNotifier notesNotifier;
  final CurrentFolderNotifier folderNotifier;

  @override
  @mustCallSuper
  void initState() {
    updatesStream.stream
        .sampleTime(
          const Duration(milliseconds: 700),
        )
        .forEach(onUpdateFolder);
    super.initState();
  }

  @mustCallSuper
  // ignore: avoid_positional_boolean_parameters
  Future<void> onUpdateFolder(final NoteProjectUpdate notifier) async {
    notesNotifier.put(key: note.id, value: note);

    if (notifier.positionChanged) {
      note.folder?.sortProjectsByDate(project: note);
      folderNotifier.notify();
    }

    await note.save();
    if (notifier.charactersLimitChanged) setState();
  }
}
