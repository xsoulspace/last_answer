part of 'note_project_view.dart';

class NoteProjectViewStateDto {
  NoteProjectViewStateDto({
    required final BuildContext context,
  })  : noteProjectsProvider = context.read(),
        folderStateProvider = context.read();
  final NoteProjectsState noteProjectsProvider;
  final FolderStateNotifier folderStateProvider;
}

class NoteProjectViewBloc
    extends ValueNotifier<LoadableContainer<ProjectModelNote>>
    implements Loadable {
  NoteProjectViewBloc({
    required this.delegate,
    required this.dto,
  }) : super(LoadableContainer(value: ProjectModel.emptyNote)) {
    noteController.addListener(_onNoteChange);
  }
  final NoteProjectViewStateDto dto;
  final NoteProjectViewDelegate delegate;
  final noteController = TextEditingController();
  final undoController = UndoHistoryController();

  ProjectModelNote get _note {
    assert(value.isLoaded, 'should be loaded at this moment');
    return value.value;
  }

  final focusNode = FocusNode();

  @override
  Future<void> onLoad() async {
    final maybeNote = dto.noteProjectsProvider.state[delegate.noteId];
    if (maybeNote == null) {
      /// create note
    } else {
      setValue(LoadableContainer.loaded(maybeNote.toModel()));
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
    delegate.onBack(value.value);
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
