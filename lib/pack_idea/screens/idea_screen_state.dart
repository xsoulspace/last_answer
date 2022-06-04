part of pack_idea;

IdeaScreenState useIdeaScreenState({
  required final VoidCallback onScreenBack,
  required final StreamController<bool> ideaUpdatesStream,
  required final IdeaProject idea,
  required final ValueNotifier<bool> questionsOpened,
  required final ValueNotifier<List<IdeaProjectAnswer>> answers,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useIdeaScreenState',
        state: IdeaScreenState(
          onScreenBack: onScreenBack,
          idea: idea,
          ideaUpdatesStream: ideaUpdatesStream,
          questionsOpened: questionsOpened,
          answers: answers,
        ),
      ),
    );

class IdeaScreenState extends ContextfulLifeState {
  IdeaScreenState({
    required this.onScreenBack,
    required this.ideaUpdatesStream,
    required this.idea,
    required this.questionsOpened,
    required this.answers,
  });
  final VoidCallback onScreenBack;
  final IdeaProject idea;
  final ValueNotifier<bool> questionsOpened;
  final ValueNotifier<List<IdeaProjectAnswer>> answers;

  final StreamController<bool> ideaUpdatesStream;

  late CurrentFolderNotifier folderProvider;
  late IdeaProjectsNotifier ideasProvider;
  @override
  void initState() {
    folderProvider = context.watch<CurrentFolderNotifier>();
    ideasProvider = context.watch<IdeaProjectsNotifier>();
    ideaUpdatesStream.stream
        .sampleTime(
          const Duration(milliseconds: 700),
        )
        .forEach(onIdeaUpdate);
    super.initState();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> onIdeaUpdate(final bool updateFolder) async {
    ideasProvider.put(
      key: idea.id,
      value: idea..updatedAt = DateTime.now(),
    );

    if (updateFolder) {
      idea.folder?.sortProjectsByDate(project: idea);
      folderProvider.notify();
    }
    await idea.save();
  }

  void closeQuestions() {
    if (questionsOpened.value) questionsOpened.value = false;
  }

  void openQuestions() {
    if (!questionsOpened.value) questionsOpened.value = true;
  }

  Future<void> onIdeaTitleChange(final String newText) async {
    if (newText == idea.title) return;
    idea.title = newText;
    // final updateFolder = checkToUpdateFolder(title: newText);
    ideaUpdatesStream.add(true);
  }

  bool checkToUpdateFolder({
    final String? title,
    final bool? answersUpdated,
  }) {
    final toPop = idea.folder?.projectsList.first != idea;
    if (title != null || answersUpdated == true) {
      if (toPop) return true;
    }

    return false;
  }

  Future<void> onReadyToDeleteAnswer(final IdeaProjectAnswer answer) async {
    await idea.removeAnswer(answer: answer, context: context);
    answers.value = [...answers.value]..remove(answer);
    final updateFolder = checkToUpdateFolder(answersUpdated: true);
    ideaUpdatesStream.add(updateFolder);
  }

  Future<void> onAnswersChange() async {
    final updateFolder = checkToUpdateFolder(answersUpdated: true);
    ideaUpdatesStream.add(updateFolder);
  }

  Future<void> onAnswerCreated(final IdeaProjectAnswer answer) async {
    answers.value = [...answers.value, answer];
    final updateFolder = checkToUpdateFolder(answersUpdated: true);
    ideaUpdatesStream.add(updateFolder);
  }
}
