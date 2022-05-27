part of pack_idea;

IdeaAnswerScreenState useIdeaAnswerScreenState({
  required final BuildContext context,
  required final TextEditingController textController,
  required final StreamController<bool> updatesStream,
  required final ValueNotifier<IdeaProjectAnswer> answer,
  required final IdeaProject idea,
  required final ValueChanged<IdeaProject> onScreenBack,
}) =>
    use(
      LifeHook(
        debugLabel: 'useIdeaAnswerScreenState',
        state: IdeaAnswerScreenState(
          context: context,
          textController: textController,
          updatesStream: updatesStream,
          answer: answer,
          idea: idea,
          onScreenBack: onScreenBack,
        ),
      ),
    );

class IdeaAnswerScreenState extends LifeState {
  IdeaAnswerScreenState({
    required final this.context,
    required this.textController,
    required this.updatesStream,
    required this.answer,
    required this.idea,
    required this.onScreenBack,
  });
  final BuildContext context;
  final TextEditingController textController;
  final StreamController<bool> updatesStream;
  final ValueNotifier<IdeaProjectAnswer> answer;
  final IdeaProject idea;
  final ValueChanged<IdeaProject> onScreenBack;

  late IdeaProjectsNotifier ideasProvider;
  @override
  void initState() {
    textController.addListener(onTextChanged);
    ideasProvider = context.watch<IdeaProjectsNotifier>();

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
    ideasProvider.notify();
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
    idea.updatedAt = DateTime.now();
    updatesStream.add(true);
  }

  void onBack() {
    closeKeyboard(context: context);
    onScreenBack(idea);
  }
}
