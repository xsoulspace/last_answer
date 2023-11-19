import 'package:lastanswer/common_imports.dart';

class QuestionDropdown extends HookWidget {
  const QuestionDropdown({
    required this.answer,
    super.key,
    this.onChange,
    this.alignment = Alignment.centerLeft,
  });
  final IdeaProjectAnswer answer;
  final Alignment alignment;
  final VoidCallback? onChange;
  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.read<ProjectsNotifier>();
    final questions = projectsNotifier.ideaQuestions;
    final chosenQuestion = useState<IdeaProjectQuestionModel>(questions.first);

    // useEffect(
    //   () {
    //     chosenQuestion.value = answer.question;

    //     return null;
    //   },
    //   [answer.question],
    // );

    final textStyle = Theme.of(context).textTheme.bodyLarge!;

    final questionsItems = questions.map(
      (final question) => DropdownMenuItem<IdeaProjectQuestionModel>(
        value: question,
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            question.title.localize(context),
            style: textStyle.copyWith(
              color: textStyle.color!.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );

    return DropdownButtonHideUnderline(
      child: DropdownButton<IdeaProjectQuestionModel>(
        isExpanded: true,
        itemHeight: null,
        icon: const SizedBox(),
        borderRadius: defaultBorderRadius,
        value: chosenQuestion.value,
        items: questionsItems.toList(),
        onChanged: (final question) async {
          if (question == null || chosenQuestion.value == question) return;
          chosenQuestion.value = question;
          // answer.question = question;
          onChange?.call();
          await answer.save();
        },
      ),
    );
  }
}
