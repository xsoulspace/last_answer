part of pack_note;

// ignore: long-parameter-list
NoteProjectScreenState useNoteProjectScreenState({
  required final NoteProjectsNotifier notesNotifier,
  required final CurrentFolderNotifier folderNotifier,
  required final ValueNotifier<NoteProject> noteNotifier,
  required final StreamController<NoteProjectUpdateDto> updatesStream,
  required final ValueChanged<NoteProject> onScreenBack,
  required final BoolValueChanged<BasicProject> checkIsProjectActive,
  required final VoidCallback onGoHome,
  required final ServerProjectsSyncService projectsSyncService,
}) =>
    use(
      LifeHook(
        debugLabel: 'useNoteProjectScreenState',
        state: NoteProjectScreenState(
          checkIsProjectActive: checkIsProjectActive,
          onGoHome: onGoHome,
          noteNotifier: noteNotifier,
          updatesStream: updatesStream,
          onScreenBack: onScreenBack,
          folderNotifier: folderNotifier,
          notesNotifier: notesNotifier,
          projectsSyncService: projectsSyncService,
        ),
      ),
    );

class NoteProjectScreenState extends NoteProjectUpdaterState {
  NoteProjectScreenState({
    required this.onScreenBack,
    required final this.checkIsProjectActive,
    required final this.onGoHome,
    required final super.folderNotifier,
    required final super.notesNotifier,
    required final super.noteNotifier,
    required final super.updatesStream,
    required final super.projectsSyncService,
  }) : noteController = TextEditingController(text: noteNotifier.value.note);

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
    updatesStream.add(NoteProjectUpdateDto(positionChanged: positionChanged));
  }

  void onBack() {
    closeKeyboard(context: context);
    onScreenBack(note);
  }

  @override
  void dispose() {
    noteController
      ..removeListener(onNoteChange)
      ..dispose();
    super.dispose();
  }
}
