part of '../pack_note.dart';

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
    required this.checkIsProjectActive,
    required this.onGoHome,
    required super.note,
    required super.updatesStream,
    required super.context,
  });

  final TextEditingController noteController;
  final ValueChanged<NoteProject> onScreenBack;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onGoHome;

  @override
  void initState() {
    noteController.addListener(onNoteChange);
    notesProvider = context.read<NoteProjectsState>();
    folderProvider = context.read<FolderStateProvider>();
    super.initState();
  }

  Future<void> onRemove(final BuildContext context) async {
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
