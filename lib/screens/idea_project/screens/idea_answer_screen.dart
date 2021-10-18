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

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final idea = ref.read(ideaProjectsProvider)[ideaId]!;
    final maybeAnswer = getInitialAnswer(ref: ref, idea: idea);
    if (maybeAnswer == null) return Container();
    final answer = useState<IdeaProjectAnswer>(maybeAnswer);
    final textController = useTextEditingController(text: answer.value.text);
    textController.addListener(() {
      if (answer.value.text == textController.text) return;
      answer.value.text = textController.text;
      answer.value.save();
    });
    return Scaffold(
      restorationId: 'ideas/$ideaId/$answerId',
      appBar: AppBar(
        toolbarHeight: 80,
        leading: BackButton(
          onPressed: () => onBack(idea),
        ),
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 252),
          child: HeroId(
            id: '$answerId-question${maybeAnswer.question.id}',
            type: HeroIdTypes.projectIdeaQuestionTitle,
            child: _QuestionBubble(answer: answer.value),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: HeroId(
                id: answerId,
                type: HeroIdTypes.projectIdeaAnswerText,
                child: _AnswerField(
                  filled: false,
                  endlessLines: true,
                  onSubmit: () => onBack(idea),
                  controller: textController,
                ),
              ),
            ),
            const SafeAreaBottom(),
          ],
        ),
      ),
    );
  }
}
