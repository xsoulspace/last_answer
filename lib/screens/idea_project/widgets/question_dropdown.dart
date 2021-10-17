part of idea_project;

class _QuestionDropdown extends HookConsumerWidget {
  const _QuestionDropdown({
    required final this.answer,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final chosenQuestion = useState(answer.question);
    final questions = ref.watch(ideaProjectQuestionsProvider).values;
    final questionsItems = questions.map(
      (final question) => DropdownMenuItem<IdeaProjectQuestion>(
        value: question,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            question.title.getByLanguage(Intl.getCurrentLocale()),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ),
    );
    return DropdownButtonHideUnderline(
      child: DropdownButton<IdeaProjectQuestion>(
        isExpanded: true,
        itemHeight: null,
        borderRadius: defaultBorderRadius,
        value: chosenQuestion.value,
        items: questionsItems.toList(),
        onChanged: (final question) async {
          if (question == null) return;
          chosenQuestion.value = question;
          answer.question = question;
          await answer.save();
        },
      ),
    );
  }
}
