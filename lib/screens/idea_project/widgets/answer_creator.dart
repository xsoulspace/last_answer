part of idea_project;

class _AnswerCreator extends HookWidget {
  const _AnswerCreator({
    required final this.onCreated,
    required final this.defaultQuestion,
    required final this.idea,
    required final this.onShareTap,
    required final this.onFocus,
    required final this.questionsOpened,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectQuestion defaultQuestion;
  final IdeaProject idea;
  final ValueChanged<IdeaProjectAnswer> onCreated;
  final VoidCallback onShareTap;
  final VoidCallback onFocus;
  final ValueNotifier<bool> questionsOpened;
  static Color getBackground(final BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? AppColors.grey4.withOpacity(0.15)
          : AppColors.grey1.withOpacity(0.15);
  @override
  Widget build(final BuildContext context) {
    final selectedQuestion =
        useState<IdeaProjectQuestion?>(idea.newQuestion ?? defaultQuestion);
    selectedQuestion.addListener(() async {
      idea.newQuestion = selectedQuestion.value;
      unawaited(idea.save());
    });

    final answerController = useTextEditingController(text: idea.newAnswerText);
    final answer = useState(answerController.text);
    answerController.addListener(() {
      idea.newAnswerText = answerController.text;
      answer.value = answerController.text;
      unawaited(idea.save());
    });

    Future<void> onCreate() async {
      final text = answerController.text;
      answerController.clear();
      final question = selectedQuestion.value;
      if (question == null || text.isEmpty) return;
      final answer =
          await IdeaProjectAnswer.create(text: text, question: question);
      final box = await Hive.openBox<IdeaProjectAnswer>(
        HiveBoxesIds.ideaProjectAnswerKey,
      );
      await box.put(answer.id, answer);
      onCreated(answer);
    }

    final sendButton = RotatedBox(
      quarterTurns: 3,
      child: IconButton(
        onPressed: answer.value.isNotEmpty ? onCreate : null,
        color: AppColors.primary2,
        icon: const Icon(Icons.send),
      ),
    );
    final shareButton = Hero(
      tag: const Key('shareButton'),
      child: IconShareButton(
        onTap: onShareTap,
      ),
    );
    return Material(
      color: questionsOpened.value
          ? getBackground(context)
          : Theme.of(context).canvasColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: questionsOpened.value,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 14,
                bottom: 2,
                right: 10,
                left: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _QuestionsChips(
                      onChange: (final question) =>
                          selectedQuestion.value = question,
                      value: selectedQuestion.value,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: shareButton,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: ProjectTextField(
                    hintText: S.current.answer,
                    focusOnInit: idea.answers?.isEmpty == true,
                    controller: answerController,
                    onSubmit: onCreate,
                    onFocus: onFocus,
                  ),
                ),
                if (questionsOpened.value) sendButton else shareButton
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
