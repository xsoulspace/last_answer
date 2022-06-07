import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

class QuestionDropdown extends HookWidget {
  const QuestionDropdown({
    required final this.answer,
    final this.onChange,
    final this.alignment = Alignment.centerLeft,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  final Alignment alignment;
  final VoidCallback? onChange;
  @override
  Widget build(final BuildContext context) {
    final chosenQuestion = useState(answer.question);

    useEffect(
      () {
        chosenQuestion.value = answer.question;

        return null;
      },
      [answer.question],
    );

    final ideaQuestionsProvider = context.watch<IdeaProjectQuestionsNotifier>();
    final questions = ideaQuestionsProvider.values;
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
          if (question == null || chosenQuestion.value == question) return;
          chosenQuestion.value = question;
          answer.question = question;
          onChange?.call();
          await answer.save();
        },
      ),
    );
  }
}
