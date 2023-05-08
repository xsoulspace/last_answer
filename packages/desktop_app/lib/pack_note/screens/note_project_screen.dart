import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_note/screens/note_project_screen_state.dart';
import 'package:lastanswer/pack_note/states/use_note_project_updater.dart';
import 'package:lastanswer/pack_note/widgets/note_project_side_actionbar.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

class NoteProjectScreen extends HookWidget {
  const NoteProjectScreen({
    required this.noteId,
    final Key? key,
  }) : super(key: key);
  final String noteId;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final screenLayout = ScreenLayout.of(context);

    final noteFocusNode = useFocusNode();

    final noteProvider = context.watch<NoteProjectsNotifier>();
    final maybeNote = noteProvider.state[noteId];

    /// This case may appear only when the note gets deleted
    if (maybeNote == null) return const SizedBox();

    final note = useState<NoteProject>(maybeNote);

    // ignore: close_sinks
    final updatesStream = useStreamController<NoteProjectUpdateDto>();

    final state = useNoteProjectScreenState(
      projectsSyncService: context.read(),
      noteNotifier: note,
      updatesStream: updatesStream,
      folderNotifier: context.watch(),
      notesNotifier: context.watch(),
    );

    double? appBarHeight;
    if (Platform.isMacOS) {
      appBarHeight = null;
    } else {
      appBarHeight = screenLayout.small ? 40 : 30;
    }

    return Scaffold(
      backgroundColor: theme.canvasColor,
      restorationId: 'notes/$noteId',
      resizeToAvoidBottomInset: false,
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        height: appBarHeight,
        screenLayout: screenLayout,
        titleStr: '',
        onBack: state.onBack,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ScreenLayout.maxFullscreenPageWidth + 180,
          ),
          child: SpecialEmojisKeyboardActions(
            focusNode: noteFocusNode,
            controller: state.noteController,
            builder: (
              final context,
              final showEmojiKeyboard,
              final closeEmojiKeyboard,
              final isEmojiKeyboardOpen,
            ) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: FlatTextField(
                            hintText: S.current.writeANote,
                            fillColor: Colors.transparent,
                            filled: false,
                            limit: note.value.charactersLimit,
                            focusNode: noteFocusNode,
                            endlessLines: true,
                            focusOnInit: note.value.note.isEmpty,
                            onSubmit: state.onBack,
                            controller: state.noteController,
                          ),
                        ),
                        NoteProjectSideActionBar(
                          closeEmojiKeyboard: closeEmojiKeyboard,
                          isEmojiKeyboardOpen: isEmojiKeyboardOpen,
                          noteNotifier: note,
                          noteController: state.noteController,
                          noteFocusNode: noteFocusNode,
                          onRemove: state.onRemove,
                          showEmojiKeyboard: showEmojiKeyboard,
                          updatesStream: updatesStream,
                        ),
                      ],
                    ),
                  ),
                  if ((DeviceRuntimeType.isNativeDesktop || kIsWeb) &&
                      !isEmojiKeyboardOpen.value)
                    const SizedBox(height: 16),
                  if (!isEmojiKeyboardOpen.value) const BottomSafeArea(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
