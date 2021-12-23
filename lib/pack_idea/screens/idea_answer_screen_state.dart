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

class IdeaAnswerScreenState implements LifeState {
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
  @override
  late ValueChanged<VoidCallback> setState;

  @override
  void initState() {
    textController.addListener(onTextChanged);

    updatesStream.stream
        .sampleTime(
      const Duration(milliseconds: 700),
    )
        .forEach(
      (final _) async {
        idea.folder?.sortProjectsByDate(project: idea);
        // ideaProjectsProvider.notify();
        await answer.value.save();
        await idea.save();
      },
    );
  }

  @override
  void dispose() {
    textController.removeListener(onTextChanged);
  }

  void onTextChanged() {
    if (answer.value.text == textController.text) return;
    answer.value.text = textController.text;
    idea.updated = DateTime.now();
    updatesStream.add(true);
  }

  void onBack() {
    closeKeyboard(context: context);
    onScreenBack(idea);
  }
}
