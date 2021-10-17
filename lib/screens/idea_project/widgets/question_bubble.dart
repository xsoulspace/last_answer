part of idea_project;

class _QuestionBubble extends StatelessWidget {
  const _QuestionBubble({
    required final this.answer,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  @override
  Widget build(final BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: defaultBorderRadius,
      ),
      child: _QuestionDropdown(answer: answer),
    );
  }
}
