part of idea_project;

class _QuestionBubble extends StatelessWidget {
  const _QuestionBubble({
    required final this.answer,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  @override
  Widget build(final BuildContext context) {
    return _QuestionBubbleBox(
      child: _QuestionDropdown(answer: answer),
    );
  }
}

class _QuestionBubbleBox extends StatelessWidget {
  const _QuestionBubbleBox({
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(.03),
        borderRadius: defaultBorderRadius,
      ),
      child: child,
    );
  }
}
