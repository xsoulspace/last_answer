import 'package:lastanswer/common_imports.dart';

class QuestionDropdown extends StatelessWidget {
  const QuestionDropdown({
    required this.answer,
    required this.onChanged,
    super.key,
    this.alignment = Alignment.centerLeft,
  });
  final IdeaProjectAnswerModel answer;
  final Alignment alignment;
  final ValueChanged<IdeaProjectAnswerModel> onChanged;
  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.watch<ProjectsNotifier>();
    final questions = projectsNotifier.ideaQuestions;
    final textStyle = context.textTheme.bodyLarge;

    final dropdownMenuEntries = questions
        .map(
          (final question) => DropdownMenuEntry<IdeaProjectQuestionModel>(
            value: question,
            labelWidget: Text(
              question.title.localize(context),
              style: textStyle?.copyWith(
                color: textStyle.color?.withOpacity(0.8),
              ),
            ),
            label: question.title.localize(context),
          ),
        )
        .toList();

    return DropdownMenu<IdeaProjectQuestionModel>(
      dropdownMenuEntries: dropdownMenuEntries,
      initialSelection: answer.question,
      menuStyle: MenuStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: defaultBorderRadius,
          ),
        ),
      ),
      leadingIcon: Icon(
        Icons.circle,
        color: context.colorScheme.tertiaryContainer.withOpacity(0.4),
        size: 6,
      ),
      selectedTrailingIcon: const SizedBox(),
      trailingIcon: const SizedBox(),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        isCollapsed: true,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5),
      ),
      onSelected: (final question) async {
        if (question == null) return;
        onChanged(answer.copyWith(question: question));
      },
    );
  }
}
