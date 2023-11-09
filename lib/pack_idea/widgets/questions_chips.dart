part of pack_idea;

class _QuestionsChips extends StatelessWidget {
  const _QuestionsChips({
    required this.value,
    required this.onChange,
  });
  final IdeaProjectQuestion? value;
  final ValueChanged<IdeaProjectQuestion> onChange;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final ideaQuestionsProvider = context.read<IdeaProjectQuestionsState>();

    final questions = ideaQuestionsProvider.values;

    return Wrap(
      spacing: 1,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: questions
          .map(
            (final question) => QuestionChip(
              key: ValueKey(question.id),
              text: question.title.getByLanguage(Intl.getCurrentLocale()),
              selected: value == question,
              onSelected: (final _) => onChange(question),
            ),
          )
          .toList(),
    );
  }
}

class QuestionChip extends StatelessWidget {
  const QuestionChip({
    required this.onSelected,
    required this.selected,
    required this.text,
    super.key,
  });
  static final shape =
      RoundedRectangleBorder(borderRadius: defaultBorderRadius);

  final String text;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 38,
      child: ChoiceChip(
        label: Text(text),
        labelStyle: theme.textTheme.bodyMedium,
        shape: shape,
        backgroundColor: _AnswerCreator.getBackgroundByTheme(theme),
        selectedColor: AppColors.primary2.withOpacity(0.2),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}
