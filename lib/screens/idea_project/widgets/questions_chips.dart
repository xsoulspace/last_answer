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
    final questions = ref.watch(ideaProjectQuestionsProvider).state;
    return Wrap(
      spacing: 5,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: questions
          .map(
            (final question) => ChoiceChip(
              label: Text(
                question.title.getByLanguage(Intl.getCurrentLocale()),
              ),
              selected: value == question,
              onSelected: (final _) => onChange(question),
              key: ValueKey(question.id),
            ),
          )
          .toList(),
    );
  }
}
