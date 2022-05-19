part of pack_note;

class NoteProjectScreen extends HookWidget {
  const NoteProjectScreen({
    required final this.noteId,
    required final this.onBack,
    required this.onGoHome,
    required this.checkIsProjectActive,
    final Key? key,
  }) : super(key: key);
  final String noteId;
  final ValueChanged<NoteProject> onBack;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onGoHome;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final screenLayout = ScreenLayout.of(context);

    final noteFocusNode = useFocusNode();

    final noteProvider = context.read<NoteProjectsNotifier>();
    final maybeNote = noteProvider.state[noteId];
    if (maybeNote == null) return const SizedBox();

    final note = useState<NoteProject>(maybeNote);
    final noteController = useTextEditingController(text: maybeNote.note);

    // ignore: close_sinks
    final updatesStream = useStreamController<NoteProjectNotifier>();

    final state = useNoteProjectScreenState(
      context: context,
      note: note.value,
      onScreenBack: onBack,
      noteController: noteController,
      updatesStream: updatesStream,
      onGoHome: onGoHome,
      checkIsProjectActive: checkIsProjectActive,
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
            controller: noteController,
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
                            controller: noteController,
                          ),
                        ),
                        NoteProjectSideActionBar(
                          closeEmojiKeyboard: closeEmojiKeyboard,
                          isEmojiKeyboardOpen: isEmojiKeyboardOpen,
                          note: note,
                          noteController: noteController,
                          noteFocusNode: noteFocusNode,
                          onRemove: state.onRemove,
                          showEmojiKeyboard: showEmojiKeyboard,
                          updatesStream: updatesStream,
                        ),
                      ],
                    ),
                  ),
                  if ((isNativeDesktop || kIsWeb) && !isEmojiKeyboardOpen.value)
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
