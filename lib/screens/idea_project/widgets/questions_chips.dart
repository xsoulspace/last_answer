part of idea_project;

class _QuestionsChips extends ConsumerWidget {
  const _QuestionsChips({
    required final this.value,
    required final this.onChange,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectQuestion? value;
  final ValueChanged<IdeaProjectQuestion> onChange;
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final questions = ref.watch(ideaProjectQuestionsProvider).values;
    return Wrap(
      spacing: 5,
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
                labelStyle: Theme.of(context).textTheme.bodyText2,
                shape:
                    RoundedRectangleBorder(borderRadius: defaultBorderRadius),
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(.03),
                selectedColor: AppColors.primary2.withOpacity(
                  brightness == Brightness.light ? 0.05 : 0.2,
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
