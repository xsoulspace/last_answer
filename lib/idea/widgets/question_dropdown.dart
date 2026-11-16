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

    return LaSelect<IdeaProjectQuestionModel>(
      value: answer.question,
      items: questions
          .map(
            (final question) => LaSelectItem<IdeaProjectQuestionModel>(
              value: question,
              label: question.title.localize(context),
              icon: Icon(
                Icons.circle,
                color: context.laUi.accent.withValues(alpha: 0.4),
                size: 6,
              ),
            ),
          )
          .toList(),
      onChanged: (final question) {
        if (question == null) return;
        onChanged(answer.copyWith(question: question));
      },
    );
  }
}
