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
    final maybeNote = ref.read(noteProjectsProvider)[noteId];
    final originalTitle = useState(maybeNote?.title ?? '');
    final originalTitleManuallyChanged = useIsBool();
    if (maybeNote == null) {
      back(context);
      return Container();
    }
    final note = useState<NoteProject>(maybeNote);
    final titleController = useTextEditingController(text: maybeNote.title);
    final noteController = useTextEditingController(text: maybeNote.note);

    noteController.addListener(() {
      if (note.value.note == noteController.text) return;
      if (!originalTitleManuallyChanged.value &&
              originalTitle.value.isEmpty &&
              titleController.text.length < 20 ||
          noteController.text.length < 20) {
        titleController.text = noteController.text;
        note.value.title = noteController.text;
      }
      note.value.note = noteController.text;
      note.value.save();
    });

    return Scaffold(
      restorationId: 'notes/$noteId',
      appBar: AppBar(
        toolbarHeight: 80,
        leading: BackButton(
          onPressed: () => back(context),
        ),
        title: ProjectTitleField(
          controller: titleController,
          heroId: maybeNote.id,
          onChanged: (final text) {
            if (!originalTitleManuallyChanged.value) {
              originalTitleManuallyChanged.value = true;
            }
            maybeNote
              ..title = text
              ..save();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ProjectTextField(
                hintText: 'Write a note',
                fillColor: Colors.transparent,
                filled: false,
                endlessLines: true,
                focusOnInit: noteController.text.isEmpty,
                onSubmit: () => back(context),
                controller: noteController,
              ),
            ),
            const SafeAreaBottom(),
          ],
        ),
      ),
    );
  }
}
