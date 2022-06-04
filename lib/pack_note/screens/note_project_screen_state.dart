part of pack_note;

// ignore: long-parameter-list
NoteProjectScreenState useNoteProjectScreenState({
  required final TextEditingController noteController,
  required final NoteProjectsNotifier notesNotifier,
  required final CurrentFolderNotifier folderNotifier,
  required final NoteProject note,
  required final StreamController<NoteProjectUpdate> updatesStream,
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
          onScreenBack: onScreenBack,
          folderNotifier: folderNotifier,
          notesNotifier: notesNotifier,
        ),
      ),
    );

class NoteProjectScreenState extends NoteProjectUpdaterState {
  NoteProjectScreenState({
    required this.noteController,
    required this.onScreenBack,
    required final this.checkIsProjectActive,
    required final this.onGoHome,
    required final super.folderNotifier,
    required final super.notesNotifier,
    required final super.note,
    required final super.updatesStream,
  });

  final TextEditingController noteController;
  final ValueChanged<NoteProject> onScreenBack;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onGoHome;

  @override
  void initState() {
    noteController.addListener(onNoteChange);
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
      ..updatedAt = DateTime.now();
    updatesStream.add(NoteProjectUpdate(positionChanged: positionChanged));
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
