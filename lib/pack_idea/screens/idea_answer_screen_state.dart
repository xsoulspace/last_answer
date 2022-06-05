part of pack_idea;

// ignore: long-parameter-list
IdeaAnswerScreenState useIdeaAnswerScreenState({
  required final TextEditingController textController,
  required final StreamController<bool> updatesStream,
  required final ValueNotifier<IdeaProjectAnswer> answer,
  required final IdeaProject idea,
  required final ValueChanged<IdeaProject> onScreenBack,
  required final IdeaProjectsNotifier ideasNotifier,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useIdeaAnswerScreenState',
        state: IdeaAnswerScreenState(
          ideasNotifier: ideasNotifier,
          textController: textController,
          updatesStream: updatesStream,
          answer: answer,
          idea: idea,
          onScreenBack: onScreenBack,
        ),
      ),
    );

class IdeaAnswerScreenState extends ContextfulLifeState {
  IdeaAnswerScreenState({
    required this.textController,
    required this.ideasNotifier,
    required this.updatesStream,
    required this.answer,
    required this.idea,
    required this.onScreenBack,
  });
  final TextEditingController textController;
  final StreamController<bool> updatesStream;
  final ValueNotifier<IdeaProjectAnswer> answer;
  final IdeaProject idea;
  final ValueChanged<IdeaProject> onScreenBack;

  final IdeaProjectsNotifier ideasNotifier;
  @override
  void initState() {
    textController.addListener(onTextChanged);

    updatesStream.stream
        .sampleTime(
          const Duration(milliseconds: 700),
        )
        .forEach(onAnswerUpdate);
    super.initState();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> onAnswerUpdate(final bool update) async {
    idea.folder?.sortProjectsByDate(project: idea);
    await answer.value.save();
    ideasNotifier.notify();
    await idea.save();
  }

  @override
  void dispose() {
    super.dispose();
    textController.removeListener(onTextChanged);
  }

  void onTextChanged() {
    if (answer.value.text == textController.text) return;
    answer.value.text = textController.text;
    idea.updatedAt = dateTimeNowUtc();
    updatesStream.add(true);
  }

  void onBack() {
    closeKeyboard(context: context);
    onScreenBack(idea);
  }
}
