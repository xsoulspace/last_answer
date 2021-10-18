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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: questionsOpened.value,
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
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: _AnswerField(
                focusOnInit: idea.answers?.isEmpty == true,
                controller: answerController,
                onSubmit: onCreate,
                onFocus: onFocus,
              ),
            ),
            if (questionsOpened.value) sendButton else shareButton,
          ],
        )
      ],
    );
  }
}
