part of 'note_view.dart';

class NoteProjectViewStateDto {
  NoteProjectViewStateDto({
    required this.context,
    required this.noteId,
    required this.tickerProvider,
  })  : noteProjectsState = context.read(),
        folderStateProvider = context.read();
  final NoteProjectsState noteProjectsState;
  final FolderStateNotifier folderStateProvider;
  final ProjectModelId noteId;
  final TickerProvider tickerProvider;

  final BuildContext context;
  ProjectModelNote _getInitialNote() {
    final maybeNote = noteProjectsState.state.value[noteId.value];
    if (maybeNote == null) {
      return ProjectModel.emptyNote;
    } else {
      return maybeNote.toModel();
    }
  }
}

class NoteProjectViewBloc extends ValueNotifier<ProjectModelNote> {
  NoteProjectViewBloc({
    required this.delegate,
    required this.dto,
  }) : super(dto._getInitialNote()) {
    specialEmojiController.addListener(notifyListeners);
  }

  final NoteProjectViewStateDto dto;
  final NoteProjectViewDelegate delegate;
  final noteController = TextEditingController();
  final undoController = UndoHistoryController();
  late final characterLimitController = CharactersLimitController.fromNote(
    dto: CharactersLimitControllerDto(context: dto.context),
    note: note,
  );
  final focusNode = FocusNode();
  ProjectModelNote get note => value;
  late final specialEmojiController = SpecialEmojiController(
    focusNode: focusNode,
    textController: noteController,
    tickerProvider: dto.tickerProvider,
  );

  late final _updatesStreamController =
      StreamController<ProjectModelNote>.broadcast()
        ..stream
            .sampleTime(
              const Duration(milliseconds: 700),
            )
            .forEach(_onUpdateNote)
            .ignore();

  Future<void> onRemove(final BuildContext context) async {
    final remove = await showRemoveTitleDialog(
      title: note.title,
      context: context,
    );
    if (!remove) return;
    await removeProject(
      context: context,
      project: note,
      folderProvider: dto.folderStateProvider,
      checkIsProjectActive: delegate.checkIsProjectActive,
      onGoHome: delegate.onGoHome,
    );
  }

  Future<void> onSwitchKeyboard({
    required final bool isKeyboardVisible,
  }) async {
    void switchKeyboard({
      final bool forceToOpen = false,
    }) {
      if (isKeyboardVisible && !forceToOpen) {
        unawaited(SoftKeyboard.close());
      } else {
        if (focusNode.hasFocus) {
          unawaited(SoftKeyboard.open());
        } else {
          focusNode.requestFocus();
        }
      }
    }

    if (specialEmojiController.value.isKeyboardOpen) {
      await specialEmojiController.closeEmojiKeyboard();
      switchKeyboard(forceToOpen: true);
    } else {
      switchKeyboard();
    }
  }

  void _onNoteChange() {
    final oldNote = note;
    final fixedNewValue = noteController.text;
    if (oldNote.note == fixedNewValue) return;
    bool positionChanged = false;
    if (oldNote.title != NoteProject.getTitle(fixedNewValue)) {
      positionChanged = true;
    } else {
      positionChanged = oldNote.folder?.projectsList.first.id != note;
    }
    final updatedNote = oldNote.copyWith(
      note: fixedNewValue,
      updatedAt: DateTime.now(),
    );

    _updatesStreamController.add();
  }

  void onBack() {
    unawaited(SoftKeyboard.close());
    delegate.onBack(note);
  }

  Future<void> _onUpdateNote(final ProjectModelNote updatedNote) async {
    dto.notesState.put(key: note.id, value: note);

    if (notifier.positionChanged) {
      note.folder?.sortProjectsByDate(project: note);
      dto.folderBloc.notify();
    }

    await note.save();
    if (notifier.charactersLimitChanged) notifyListeners();
  }

  @override
  void dispose() {
    noteController
      ..removeListener(_onNoteChange)
      ..dispose();
    specialEmojiController
      ..removeListener(notifyListeners)
      ..dispose();
    unawaited(_updatesStreamController.close());
    focusNode.dispose();
    undoController.dispose();
    super.dispose();
  }
}
