import 'package:lastanswer/common_imports.dart';

class QuestionsChips extends StatelessWidget {
  const QuestionsChips({
    required this.value,
    required this.onChange,
    super.key,
  });
  final IdeaProjectQuestionModel? value;
  final ValueChanged<IdeaProjectQuestionModel> onChange;
  @override
  Widget build(final BuildContext context) {
    final questions = context.read<ProjectsNotifier>().ideaQuestions;

    return Wrap(
      spacing: 3,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: questions
          .map(
            (final question) => QuestionChip(
              key: ValueKey(question.id),
              text: question.title.localize(context),
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
  static final shape = RoundedRectangleBorder(
    borderRadius: defaultBorderRadius,
  );

  final String text;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return ChoiceChip.elevated(
      label: Text(text),
      labelStyle: theme.textTheme.bodyMedium,
      shape: shape,
      pressElevation: 2,
      showCheckmark: false,
      elevation: 0,
      selected: selected,
      onSelected: onSelected,
    );
  }
}
