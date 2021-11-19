part of note_project;

class NoteProjectScreen extends HookConsumerWidget {
  const NoteProjectScreen({
    required final this.noteId,
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final String noteId;
  final ValueChanged<NoteProject> onBack;

  void back({
    required final BuildContext context,
    required final NoteProject note,
  }) {
    closeKeyboard(context: context);
    onBack(note);
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final noteFocusNode = useFocusNode();
    final maybeNote = ref.read(noteProjectsProvider)[noteId]!;
    final note = useState<NoteProject>(maybeNote);
    final noteController = useTextEditingController(text: maybeNote.note);

    // ignore: close_sinks
    final updatesStream = useStreamController<bool>();
    noteController.addListener(() {
      if (note.value.note == noteController.text) return;
      note.value.note = noteController.text;
      updatesStream.add(true);
    });
    updatesStream.stream
        .throttleTime(
      const Duration(milliseconds: 700),
      leading: true,
      trailing: true,
    )
        .forEach((final _) async {
      ref
          .read(noteProjectsProvider.notifier)
          .put(key: maybeNote.id, value: maybeNote);
      return note.value.save();
    });
    final screenLayout = ScreenLayout.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      restorationId: 'notes/$noteId',
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        height: screenLayout.small ? null : 30,
        screenLayout: screenLayout,
        titleStr: '',
        onBack: () => back(context: context, note: note.value),
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
                        focusNode: noteFocusNode,
                        endlessLines: true,
                        onSubmit: () =>
                            back(context: context, note: note.value),
                        controller: noteController,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
              const SafeAreaBottom(),
            ],
          ),
        ),
      ),
    );
  }
}
