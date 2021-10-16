part of idea_project;

class _QuestionBubble extends StatelessWidget {
  const _QuestionBubble({
    required final this.answer,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: _QuestionDropdown(answer: answer),
    );
  }
}
