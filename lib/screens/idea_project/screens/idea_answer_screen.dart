part of idea_project;

class IdeaAnswerScreen extends HookConsumerWidget {
  const IdeaAnswerScreen({
    required final this.ideaId,
    required final this.answerId,
    required final this.onBack,
    required final this.onUnknown,
    final Key? key,
  }) : super(key: key);
  final String ideaId;
  final String answerId;
  final ValueChanged<IdeaProject> onBack;

  /// callback to redirect if answerId is not found
  final TwoValuesChanged<IdeaProjectAnswerId, IdeaProject> onUnknown;

  IdeaProjectAnswer? getInitialAnswer({
    required final WidgetRef ref,
    required final IdeaProject idea,
  }) {
    final answer =
        idea.answers?.firstWhereOrNull((final a) => a.id == answerId);
    if (answer != null) return answer;
    onUnknown(answerId, idea);
    return null;
  }

  void back({
    required final BuildContext context,
    required final IdeaProject idea,
  }) {
    closeKeyboard(context: context);
    onBack(idea);
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final maybeIdea = ref.read(ideaProjectsProvider)[ideaId]!;
    final maybeAnswer = getInitialAnswer(ref: ref, idea: maybeIdea);
    if (maybeAnswer == null) return Container();
    final answer = useState<IdeaProjectAnswer>(maybeAnswer);
    final textController = useTextEditingController(text: answer.value.text);
    textController.addListener(() {
      if (answer.value.text == textController.text) return;
      answer.value.text = textController.text;
      answer.value.save();
    });
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      restorationId: 'ideas/$ideaId/$answerId',
      appBar: BackTextUniversalAppBar(
        useBackButton: true,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 252),
          child: HeroId(
            id: '$answerId-question${maybeAnswer.question.id}',
            type: HeroIdTypes.projectIdeaQuestionTitle,
            child: _QuestionDropdown(
              answer: answer.value,
              alignment: Alignment.center,
            ),
          ),
        ),
        onBack: () => back(idea: maybeIdea, context: context),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ScreenLayout.minFullscreenPageWidth,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: HeroId(
                    id: answerId,
                    type: HeroIdTypes.projectIdeaAnswerText,
                    child: ProjectTextField(
                      hintText: S.current.answer,
                      fillColor: Colors.transparent,
                      filled: false,
                      endlessLines: true,
                      focusOnInit: textController.text.isEmpty,
                      onSubmit: () => back(idea: maybeIdea, context: context),
                      controller: textController,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const BottomSafeArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
