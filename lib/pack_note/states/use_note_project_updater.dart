part of pack_note;

@immutable
class NoteProjectNotifier {
  const NoteProjectNotifier({
    this.charactersLimitChanged = false,
    this.positionChanged = false,
  });
  final bool positionChanged;
  final bool charactersLimitChanged;
}

NoteProjectUpdaterState useNoteProjectUpdaterState({
  required final NoteProject note,
  required final StreamController<NoteProjectNotifier> updatesStream,
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
  final StreamController<NoteProjectNotifier> updatesStream;
  late NoteProjectsProvider notesProvider;
  late CurrentFolderNotifier folderProvider;

  @override
  @mustCallSuper
  void initState() {
    notesProvider = context.read<NoteProjectsProvider>();
    folderProvider = context.read<CurrentFolderNotifier>();

    updatesStream.stream
        .sampleTime(
          const Duration(milliseconds: 700),
        )
        .forEach(onUpdateFolder);
    super.initState();
  }

  @mustCallSuper
  // ignore: avoid_positional_boolean_parameters
  Future<void> onUpdateFolder(final NoteProjectNotifier notifier) async {
    notesProvider.put(key: note.id, value: note);

    if (notifier.positionChanged) {
      note.folder?.sortProjectsByDate(project: note);
      folderProvider.notify();
    }

    await note.save();
    if (notifier.charactersLimitChanged) setState();
  }
}
