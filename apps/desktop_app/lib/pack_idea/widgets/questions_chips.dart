import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/pack_idea/widgets/answer_creator.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

class QuestionsChips extends StatelessWidget {
  const QuestionsChips({
    required final this.value,
    required final this.onChange,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectQuestion? value;
  final ValueChanged<IdeaProjectQuestion> onChange;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final ideaQuestionsProvider = context.watch<IdeaProjectQuestionsNotifier>();

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
    final Key? key,
  }) : super(key: key);
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
        labelStyle: theme.textTheme.bodyText2,
        shape: shape,
        backgroundColor: AnswerCreator.getBackgroundByTheme(theme),
        selectedColor: AppColors.primary2.withOpacity(0.2),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}
