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
    return FocusBubbleContainer(
      onUnfocus: _updateAnswer,
      child: TextField(
        onChanged: (final _) => _updateAnswer(),
        controller: controller,
        maxLines: null,
        keyboardAppearance: Theme.of(context).brightness,
        textAlignVertical: TextAlignVertical.bottom,
        keyboardType: TextInputType.multiline,
        onEditingComplete: _updateAnswer,
        style: Theme.of(context).textTheme.bodyText2,
        decoration: const InputDecoration()
            .applyDefaults(Theme.of(context).inputDecorationTheme)
            .copyWith(
              focusedBorder: OutlineInputBorder(
                borderRadius: defaultBorderRadius,
                borderSide: const BorderSide(width: 0.1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: defaultBorderRadius,
                borderSide: const BorderSide(width: 0.05),
              ),
              // focusedBorder: InputBorder.none,
              // enabledBorder: InputBorder.none,
              // errorBorder: InputBorder.none,
              // disabledBorder: InputBorder.none,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                  .copyWith(top: 4),
              // focusColor: Colors.transparent,
            ),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
