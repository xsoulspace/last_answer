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
    final maybeNote = noteProvider.state[noteId]!;

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

    return Scaffold(
      backgroundColor: theme.canvasColor,
      restorationId: 'notes/$noteId',
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        height: screenLayout.small ? null : 30,
        screenLayout: screenLayout,
        titleStr: '',
        // actions: [
        //   if (!isDesktop)
        //     CupertinoIconButton(
        //       onPressed: state.onSettings,
        //       icon: Icons.more_vert_rounded,
        //     ),
        //   const SizedBox(width: 20),
        // ],
        onBack: state.onBack,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ScreenLayout.maxFullscreenPageWidth + 180,
          ),
          child: Column(
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
              const SizedBox(height: 14),
              const BottomSafeArea(),
            ],
          ),
        ),
      ),
    );
  }
}
