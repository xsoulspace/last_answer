part of pack_note;

NoteProjectScreenState useNoteProjectScreenState({
  required final TextEditingController noteController,
  required final ValueNotifier<NoteProject> note,
  required final StreamController<bool> updatesStream,
  required final BuildContext context,
  required final ValueChanged<NoteProject> onScreenBack,
}) =>
    use(
      LifeHook(
        debugLabel: 'useNoteProjectScreenState',
        state: NoteProjectScreenState(
          note: note,
          noteController: noteController,
          updatesStream: updatesStream,
          context: context,
          onScreenBack: onScreenBack,
        ),
      ),
    );

class NoteProjectScreenState implements LifeState {
  NoteProjectScreenState({
    required this.noteController,
    required this.note,
    required this.updatesStream,
    required this.context,
    required this.onScreenBack,
  });

  @override
  late ValueChanged<VoidCallback> setState;
  final BuildContext context;
  final TextEditingController noteController;
  final ValueNotifier<NoteProject> note;
  final StreamController<bool> updatesStream;
  final ValueChanged<NoteProject> onScreenBack;
  late NoteProjectsProvider notesProvider;
  late FolderStateProvider folderProvider;
  @override
  void initState() {
    noteController.addListener(onNoteChange);
    notesProvider = context.read<NoteProjectsProvider>();
    folderProvider = context.read<FolderStateProvider>();

    updatesStream.stream
        .sampleTime(
          const Duration(milliseconds: 700),
        )
        .forEach(onUpdateFolder);
  }

  void onSettings() {}

  // ignore: avoid_positional_boolean_parameters
  Future<void> onUpdateFolder(final bool updateFolder) async {
    notesProvider.put(key: note.value.id, value: note.value);

    if (updateFolder) {
      note.value.folder?.sortProjectsByDate(project: note.value);
      folderProvider.notify();
    }

    return note.value.save();
  }

  void onNoteChange() {
    if (note.value.note == noteController.text) return;
    bool updateFolder = false;
    if (note.value.title != NoteProject.getTitle(noteController.text)) {
      updateFolder = true;
    } else {
      updateFolder = note.value.folder?.projectsList.first != note.value;
    }
    note.value
      ..note = noteController.text
      ..updated = DateTime.now();
    updatesStream.add(updateFolder);
  }

  void onBack() {
    closeKeyboard(context: context);
    onScreenBack(note.value);
  }

  @override
  void dispose() {
    noteController.removeListener(onNoteChange);
  }
}
