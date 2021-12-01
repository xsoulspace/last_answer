part of pack_idea;

class _QuestionDropdown extends HookWidget {
  const _QuestionDropdown({
    required final this.answer,
    final this.alignment = Alignment.centerLeft,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  final Alignment alignment;
  @override
  Widget build(final BuildContext context) {
    final chosenQuestion = useState(answer.question);
    final questions = ideaProjectQuestionsProvider.state.values;
    final textStyle = Theme.of(context).textTheme.bodyText1!;
    final questionsItems = questions.map(
      (final question) => DropdownMenuItem<IdeaProjectQuestion>(
        value: question,
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            question.title.getByLanguage(Intl.getCurrentLocale()),
            style: textStyle.copyWith(
              color: textStyle.color!.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
    return DropdownButtonHideUnderline(
      child: DropdownButton<IdeaProjectQuestion>(
        isExpanded: true,
        itemHeight: null,
        icon: const SizedBox(),
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
