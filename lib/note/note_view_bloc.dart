import 'package:lastanswer/_library/hooks/hooks.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/settings.dart';

class NoteViewBlocDto {
  NoteViewBlocDto({
    required this.initialNote,
    required this.tickerProvider,
    required this.context,
  }) : openedProjectNotifier = context.read();
  final ProjectModelNote initialNote;
  final TickerProvider tickerProvider;
  final BuildContext context;
  final OpenedProjectNotifier openedProjectNotifier;
}

class NoteViewBloc extends ValueNotifier<ProjectModelNote> {
  NoteViewBloc({required this.dto}) : super(dto.initialNote);
  late final keyboardVisibilityController = KeyboardController()
    ..addListener(_onKeyboardVisibilityChanged);
  final NoteViewBlocDto dto;
  late final noteController = TextEditingController(text: dto.initialNote.note)
    ..addListener(_onChanged);
  final undoController = UndoHistoryController();
  late final characterLimitController = CharactersLimitController.fromNote(
    dto: CharactersLimitControllerDto(context: dto.context),
    noteCharactersLimit: dto.initialNote.charactersLimit,
  )..addListener(_onChanged);
  final focusNode = FocusNode();
  ProjectModelNote get note => value;
  late final specialEmojiController = SpecialEmojiController(
    focusNode: focusNode,
    textController: noteController,
    tickerProvider: dto.tickerProvider,
  )..addListener(notifyListeners);
  void _onKeyboardVisibilityChanged() {
    final isKeyboardVisible = keyboardVisibilityController.value;
    if (!isKeyboardVisible) return;
    if (specialEmojiController.value.isKeyboardOpen ||
        specialEmojiController.value.isKeyboardOpening) {
      unawaited(specialEmojiController.closeEmojiKeyboard());
    }
  }

  void _onChanged() {
    final updatedNote = value.copyWith(
      note: noteController.text,
      charactersLimit: int.tryParse(characterLimitController.value) ?? 0,
    );
    setValue(updatedNote);
    dto.openedProjectNotifier.updateProject(updatedNote);
  }

  Future<void> onRemove(final BuildContext context) async {
    final remove = await showRemoveTitleDialog(
      title: note.title,
      context: context,
    );
    if (!remove) return;
    dto.openedProjectNotifier.deleteProject();
  }

  Future<void> onSwitchKeyboard() async {
    final isKeyboardVisible = keyboardVisibilityController.value;
    void switchKeyboard({
      final bool forceToOpen = false,
    }) {
      if (isKeyboardVisible) {
        unawaited(SoftKeyboard.close());
      } else {
        if (focusNode.hasFocus || forceToOpen) {
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

  void onSubmit() {
    unawaited(SoftKeyboard.close());
  }

  @override
  void dispose() {
    keyboardVisibilityController
      ..removeListener(_onKeyboardVisibilityChanged)
      ..dispose();
    noteController
      ..removeListener(_onChanged)
      ..dispose();
    characterLimitController
      ..removeListener(_onChanged)
      ..dispose();
    specialEmojiController
      ..removeListener(notifyListeners)
      ..dispose();
    focusNode.dispose();
    undoController.dispose();
    super.dispose();
  }
}
