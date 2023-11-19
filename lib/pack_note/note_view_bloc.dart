part of 'note_view.dart';

class NoteProjectViewStateDto {
  NoteProjectViewStateDto({
    required this.context,
    required this.noteId,
    required this.tickerProvider,
  });
  final ProjectModelId noteId;
  final TickerProvider tickerProvider;
  final BuildContext context;
}

class NoteProjectViewBloc extends ValueNotifier<ProjectModelNote> {
  NoteProjectViewBloc({
    required this.delegate,
    required this.dto,
  }) : super(
          ProjectModelNote(
            id: ProjectModelId.empty,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
          // dto._getInitialNote()
          ,
        ) {
    specialEmojiController.addListener(notifyListeners);
  }

  final NoteProjectViewStateDto dto;
  final NoteProjectViewDelegate delegate;
  final noteController = TextEditingController();
  final undoController = UndoHistoryController();
  late final characterLimitController = CharactersLimitController.fromNote(
    dto: CharactersLimitControllerDto(context: dto.context),
    noteCharactersLimit: note.charactersLimit,
  );
  final focusNode = FocusNode();
  ProjectModelNote get note => value;
  late final specialEmojiController = SpecialEmojiController(
    focusNode: focusNode,
    textController: noteController,
    tickerProvider: dto.tickerProvider,
  );

  Future<void> onRemove(final BuildContext context) async {
    final remove = await showRemoveTitleDialog(
      title: note.title,
      context: context,
    );
    if (!remove) return;
    // await removeProject(
    //   context: context,
    //   project: note,
    //   folderProvider: dto.folderStateProvider,
    //   checkIsProjectActive: delegate.checkIsProjectActive,
    //   onGoHome: delegate.onGoHome,
    // );
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

  void onBack() {
    unawaited(SoftKeyboard.close());
    delegate.onBack(note);
  }

  @override
  void dispose() {
    noteController.dispose();
    specialEmojiController
      ..removeListener(notifyListeners)
      ..dispose();
    focusNode.dispose();
    undoController.dispose();
    super.dispose();
  }
}
