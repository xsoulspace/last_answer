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
  required final BuildContext context,
}) =>
    use(
      LifeHook(
        debugLabel: 'useNoteProjectUpdaterState',
        state: NoteProjectUpdaterState(
          note: note,
          updatesStream: updatesStream,
          context: context,
        ),
      ),
    );

class NoteProjectUpdaterState extends LifeState {
  NoteProjectUpdaterState({
    required this.note,
    required this.updatesStream,
    required this.context,
  });

  final BuildContext context;
  final NoteProject note;
  final StreamController<NoteProjectUpdate> updatesStream;
  late NoteProjectsNotifier notesProvider;
  late CurrentFolderNotifier folderProvider;

  @override
  @mustCallSuper
  void initState() {
    notesProvider = context.watch<NoteProjectsNotifier>();
    folderProvider = context.watch<CurrentFolderNotifier>();

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
    notesProvider.put(key: note.id, value: note);

    if (notifier.positionChanged) {
      note.folder?.sortProjectsByDate(project: note);
      folderProvider.notify();
    }

    await note.save();
    if (notifier.charactersLimitChanged) setState();
  }
}
