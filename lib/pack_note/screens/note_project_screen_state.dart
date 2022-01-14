part of pack_note;

NoteProjectScreenState useNoteProjectScreenState({
  required final TextEditingController noteController,
  required final NoteProject note,
  required final StreamController<NoteProjectNotifier> updatesStream,
  required final BuildContext context,
  required final ValueChanged<NoteProject> onScreenBack,
  required final BoolValueChanged<BasicProject> checkIsProjectActive,
  required final VoidCallback onGoHome,
}) =>
    use(
      LifeHook(
        debugLabel: 'useNoteProjectScreenState',
        state: NoteProjectScreenState(
          checkIsProjectActive: checkIsProjectActive,
          onGoHome: onGoHome,
          note: note,
          noteController: noteController,
          updatesStream: updatesStream,
          context: context,
          onScreenBack: onScreenBack,
        ),
      ),
    );

class NoteProjectScreenState extends NoteProjectUpdaterState {
  NoteProjectScreenState({
    required this.noteController,
    required this.onScreenBack,
    required final this.checkIsProjectActive,
    required final this.onGoHome,
    required final NoteProject note,
    required final StreamController<NoteProjectNotifier> updatesStream,
    required final BuildContext context,
  }) : super(context: context, note: note, updatesStream: updatesStream);

  final TextEditingController noteController;
  final ValueChanged<NoteProject> onScreenBack;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onGoHome;

  @override
  void initState() {
    noteController.addListener(onNoteChange);
    notesProvider = context.read<NoteProjectsProvider>();
    folderProvider = context.read<FolderStateProvider>();
    super.initState();
  }

  Future<void> onRemove() async {
    final remove = await showRemoveTitleDialog(
      title: note.title,
      context: context,
    );
    if (remove) {
      await removeProject(
        context: context,
        project: note,
        folderProvider: folderProvider,
        checkIsProjectActive: checkIsProjectActive,
        onGoHome: onGoHome,
      );
    }
  }

  void onNoteChange() {
    if (note.note == noteController.text) return;
    bool positionChanged = false;
    if (note.title != NoteProject.getTitle(noteController.text)) {
      positionChanged = true;
    } else {
      positionChanged = note.folder?.projectsList.first != note;
    }
    note
      ..note = noteController.text
      ..updated = DateTime.now();
    updatesStream.add(NoteProjectNotifier(positionChanged: positionChanged));
  }

  void onBack() {
    closeKeyboard(context: context);
    onScreenBack(note);
  }

  @override
  void dispose() {
    noteController.removeListener(onNoteChange);
    super.dispose();
  }
}
