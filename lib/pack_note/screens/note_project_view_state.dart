part of 'note_project_view.dart';

class NoteProjectViewStateDto {
  NoteProjectViewStateDto({
    required final BuildContext context,
  })  : noteProjectsProvider = context.read(),
        folderStateProvider = context.read();
  final NoteProjectsState noteProjectsProvider;
  final FolderStateProvider folderStateProvider;
}

class NoteProjectViewState with ChangeNotifier implements Loadable {
  NoteProjectViewState({
    required this.delegate,
    required this.dto,
  }) {
    noteController.addListener(_onNoteChange);
  }
  final NoteProjectViewStateDto dto;
  final NoteProjectViewDelegate delegate;
  final noteController = TextEditingController();
  final undoController = UndoHistoryController();
  LoadableContainer<ProjectModelNote> noteContainer =
      LoadableContainer<ProjectModelNote>(
    value: ProjectModel.emptyNote,
  );
  ProjectModelNote get _note {
    assert(noteContainer.isLoaded, 'should be loaded at this moment');
    return noteContainer.value;
  }

  final focusNode = FocusNode();

  @override
  Future<void> onLoad() async {
    final maybeNote = dto.noteProjectsProvider.state[delegate.noteId];
    if (maybeNote == null) {
      /// create note
    } else {
      noteContainer = LoadableContainer.loaded(maybeNote.toModel());
      notifyListeners();
    }
  }

  Future<void> onRemove(final BuildContext context) async {
    final remove = await showRemoveTitleDialog(
      title: _note.title,
      context: context,
    );
    if (remove) {
      await removeProject(
        context: context,
        project: note,
        folderProvider: dto.folderStateProvider,
        checkIsProjectActive: delegate.checkIsProjectActive,
        onGoHome: delegate.onGoHome,
      );
    }
  }

  void _onNoteChange() {
    if (_note.note == noteController.text) return;
    bool positionChanged = false;
    if (_note.title != NoteProject.getTitle(noteController.text)) {
      positionChanged = true;
    } else {
      positionChanged = note.folder?.projectsList.first != note;
    }
    final note = _note.copyWith(
      note: noteController.text,
      updatedAt: DateTime.now(),
    );

    updatesStream.add(NoteProjectNotifier(positionChanged: positionChanged));
  }

  void onBack() {
    unawaited(SoftKeyboard.close());
    delegate.onBack();
  }

  @override
  void dispose() {
    focusNode.dispose();
    noteController
      ..removeListener(_onNoteChange)
      ..dispose();
    undoController.dispose();
    super.dispose();
  }
}
