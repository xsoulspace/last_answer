part of idea_project;

class _QuestionsChips extends StatelessWidget {
  const _QuestionsChips({
    required final this.value,
    required final this.onChange,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectQuestion? value;
  final ValueChanged<IdeaProjectQuestion> onChange;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final questions = ideaProjectQuestionsProvider.state.values;
    return Wrap(
      spacing: 1,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: questions
          .map(
            (final question) => SizedBox(
              height: 38,
              child: ChoiceChip(
                label: Text(
                  question.title.getByLanguage(Intl.getCurrentLocale()),
                ),
                labelStyle: theme.textTheme.bodyText2,
                shape:
                    RoundedRectangleBorder(borderRadius: defaultBorderRadius),
                backgroundColor: _AnswerCreator.getBackgroundByTheme(theme),
                selectedColor: AppColors.primary2.withOpacity(
                  brightness == Brightness.light ? 0.2 : 0.2,
                ),
                selected: value == question,
                onSelected: (final _) => onChange(question),
                key: ValueKey(question.id),
              ),
            ),
          )
          .toList(),
    );
  }
}
