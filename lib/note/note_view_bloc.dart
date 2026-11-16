import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lastanswer/_library/hooks/hooks.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/note/note_asset_store.dart';
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
    if (value.note == noteController.text) return;
    final updatedNote = value.copyWith(
      note: noteController.text,
      charactersLimit: int.tryParse(characterLimitController.limit) ?? 0,
    );
    setValue(updatedNote);
    dto.openedProjectNotifier.updateProject(updatedNote);
  }

  /// Wave D1 — attachments ride the SAME funnel as text edits
  /// (copyWith → persist through the opened-project notifier), so
  /// selection and storage stay owned by one place. The FILES already
  /// live in the note's asset dir (the store imported them); these
  /// ops commit the metadata rows only.
  void addAssets(final List<NoteAssetModel> assets) {
    if (assets.isEmpty) return;
    _commitAssets([...value.assets, ...assets]);
  }

  /// The full-list commit (caption edits and removals pass the whole
  /// surviving list).
  void setAssets(final List<NoteAssetModel> assets) {
    _commitAssets(assets);
  }

  void _commitAssets(final List<NoteAssetModel> assets) {
    final updatedNote = value.copyWith(assets: assets);
    setValue(updatedNote);
    dto.openedProjectNotifier.updateProject(updatedNote);
  }

  Future<void> onRemove(final BuildContext context) async {
    final remove = await showRemoveTitleDialog(
      title: note.getTitle(context),
      context: context,
    );
    if (!remove) return;
    // Wave D1 — the note owns its attachments' lifecycle: the asset
    // files go with the note. The ROW deletion is the user's intent
    // and must not wait on the file plane (tests run without the
    // path-provider channel) — cleanup is best-effort after it.
    dto.openedProjectNotifier.deleteProject(project: note);
    if (!kIsWeb) {
      unawaited(
        NoteAssetStore.instance()
            .then(
              (final store) => store.deleteAssets(
                noteId: note.id,
                assets: note.assets,
              ),
            )
            .catchError((final Object _) {}),
      );
    }
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
