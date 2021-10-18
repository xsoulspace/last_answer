part of idea_project;

class AnswerFieldBubble extends HookWidget {
  const AnswerFieldBubble({
    required final this.answer,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;

  @override
  Widget build(final BuildContext context) {
    final controller = useTextEditingController(text: answer.text);
    void _updateAnswer() => answer
      ..text = controller.text
      ..save();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: defaultBorderRadius,
      ),
      child: Focus(
        onFocusChange: (final hasFocus) async {
          if (hasFocus) return;
          _updateAnswer();
        },
        child: TextField(
          onChanged: (final _) => _updateAnswer(),
          controller: controller,
          minLines: 1,
          maxLines: 7,
          keyboardAppearance: Theme.of(context).brightness,
          textAlignVertical: TextAlignVertical.bottom,
          keyboardType: TextInputType.multiline,
          onEditingComplete: _updateAnswer,
          style: Theme.of(context).textTheme.bodyText2,
          decoration: const InputDecoration()
              .applyDefaults(Theme.of(context).inputDecorationTheme)
              .copyWith(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                fillColor: Colors.transparent,
                focusColor: Colors.transparent,
              ),
          cursorColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
