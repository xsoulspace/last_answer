part of note_project;

class NoteProjectScreen extends HookConsumerWidget {
  const NoteProjectScreen({
    required final this.noteId,
    required final this.onBack,
    final Key? key,
  }) : super(key: key);
  final String noteId;
  final VoidCallback onBack;

  void back(final BuildContext context) {
    closeKeyboard(context: context);
    onBack();
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
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

    return Scaffold(
      restorationId: 'notes/$noteId',
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        leading: BackButton(
          onPressed: () => back(context),
        ),
        actions: const [
          SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ScreenLayout.maxFullscreenPageWidth,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ProjectTextField(
                          hintText: 'Write a note',
                          fillColor: Colors.transparent,
                          filled: false,
                          endlessLines: true,
                          onSubmit: () => back(context),
                          controller: noteController,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                          const SizedBox(height: 20),
                          EmojiPopup(controller: noteController),
                        ],
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
      ),
    );
  }
}
