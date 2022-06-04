part of pack_idea;

// ignore: long-parameter-list
AnswerCreatorState useAnswerCreatorState({
  required final IdeaProject idea,
  required final IdeaProjectQuestion defaultQuestion,
  required final ValueChanged<IdeaProjectAnswer> onCreated,
  required final VoidCallback onShareTap,
  required final VoidCallback onFocus,
  required final ValueNotifier<bool> questionsOpened,
  required final VoidCallback onChanged,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useAnswerCreatorState',
        state: AnswerCreatorState(
          idea: idea,
          defaultQuestion: defaultQuestion,
          onChanged: onChanged,
          onCreated: onCreated,
          onFocus: onFocus,
          onShareTap: onShareTap,
          questionsOpened: questionsOpened,
        ),
      ),
    );

class AnswerCreatorState extends ContextfulLifeState {
  AnswerCreatorState({
    required this.defaultQuestion,
    required this.onCreated,
    required this.onShareTap,
    required this.onFocus,
    required this.questionsOpened,
    required this.onChanged,
    required this.idea,
  });

  final IdeaProject idea;
  final IdeaProjectQuestion defaultQuestion;
  final ValueChanged<IdeaProjectAnswer> onCreated;
  final VoidCallback onShareTap;
  final VoidCallback onFocus;
  final ValueNotifier<bool> questionsOpened;
  final VoidCallback onChanged;

  final answerFocusNode = FocusNode();
  late final selectedQuestion =
      ValueNotifier<IdeaProjectQuestion?>(idea.newQuestion ?? defaultQuestion);
  late final answerController = TextEditingController(text: idea.newAnswerText);
  late final answer = ValueNotifier<String>(answerController.text);

  @override
  void initState() {
    selectedQuestion.addListener(onSelectedQuestionChanged);
    answerController.addListener(onAnswerControllerChanged);
    super.initState();
  }

  @override
  void dispose() {
    answerFocusNode.dispose();
    answer.dispose();
    selectedQuestion
      ..removeListener(onSelectedQuestionChanged)
      ..dispose();
    answerController
      ..removeListener(onAnswerControllerChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> onAnswerControllerChanged() async {
    if (idea.newAnswerText == answerController.text) return;
    idea.newAnswerText = answerController.text;
    answer.value = answerController.text;
    onChanged();
    unawaited(idea.save());
  }

  Future<void> onSelectedQuestionChanged() async {
    if (selectedQuestion.value == idea.newQuestion) return;
    idea.newQuestion = selectedQuestion.value;
    unawaited(idea.save());
  }

  Future<void> onCreate() async {
    final text = answerController.text;
    answerController.clear();
    final question = selectedQuestion.value;
    if (question == null || text.isEmpty) return;
    final answer = await IdeaProjectAnswer.create(
      text: text,
      question: question,
      idea: idea,
      context: context,
    );

    onCreated(answer);
  }
}
