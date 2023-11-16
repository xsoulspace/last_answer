part of pack_idea;

class IdeaAnswerScreen extends HookWidget {
  const IdeaAnswerScreen({
    required this.ideaId,
    required this.answerId,
    required this.onBack,
    required this.onUnknown,
    super.key,
  });
  final String ideaId;
  final String answerId;
  final ValueChanged<IdeaProject> onBack;

  /// callback to redirect if answerId is not found
  final TwoValuesChanged<IdeaProjectAnswerId, IdeaProject> onUnknown;

  IdeaProjectAnswer? getInitialAnswer({
    required final IdeaProject idea,
  }) {
    final answer =
        idea.answers?.firstWhereOrNull((final a) => a.id == answerId);
    if (answer != null) return answer;
    onUnknown(answerId, idea);

    return null;
  }

  @override
  Widget build(final BuildContext context) {
    final ideasProvider = context.read<IdeaProjectsState>();
    final maybeIdea = ideasProvider.state.value[ideaId]!;
    final maybeAnswer = getInitialAnswer(idea: maybeIdea);
    if (maybeAnswer == null) return Container();
    final answer = useState<IdeaProjectAnswer>(maybeAnswer);
    final textController = useTextEditingController(text: answer.value.text);
    // ignore: close_sinks
    final updatesStream = useStreamController<bool>();

    final state = useIdeaAnswerScreenState(
      answer: answer,
      context: context,
      idea: maybeIdea,
      onScreenBack: onBack,
      textController: textController,
      updatesStream: updatesStream,
    );

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
        onBack: state.onBack,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      onSubmit: state.onBack,
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
