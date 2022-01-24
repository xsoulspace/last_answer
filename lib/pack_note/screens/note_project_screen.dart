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

    final noteProvider = context.read<NoteProjectsProvider>();
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
                          child: ProjectTextField(
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            NoteSettingsButton(
                              note: note.value,
                              onRemove: state.onRemove,
                              updatesStream: updatesStream,
                            ),
                            SpecialEmojiPopup(
                              controller: noteController,
                              focusNode: noteFocusNode,
                              onShowEmojiKeyboard: showEmojiKeyboard,
                            ),
                            SizedBox(
                              height: 34,
                              width: 48,
                              child: IconShareButton(
                                onTap: () {
                                  ProjectSharer.of(context)
                                      .share(project: note.value);
                                },
                              ),
                            ),
                            EmojiPopup(
                              controller: noteController,
                              focusNode: noteFocusNode,
                            ),
                            if (Platform.isAndroid || Platform.isIOS)
                              IconButton(
                                onPressed: () {
                                  closeKeyboard(context: context);
                                  closeEmojiKeyboard();
                                },
                                icon: const Icon(
                                  CupertinoIcons.keyboard_chevron_compact_down,
                                ),
                              ),
                          ]
                              .map(
                                (final e) => Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: e,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  if (isNativeDesktop) const SizedBox(height: 14),
                  const BottomSafeArea(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
