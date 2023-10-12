part of pack_idea;

class AnswerFieldBubble extends HookWidget {
  const AnswerFieldBubble({
    required this.answer,
    required this.onFocus,
    required this.onChange,
    super.key,
  });
  final IdeaProjectAnswer answer;
  final VoidCallback onFocus;
  final VoidCallback onChange;
  @override
  Widget build(final BuildContext context) {
    final controller = useTextEditingController(
      text: answer.text,
    );

    useEffect(
      () {
        controller.text = answer.text;

        return null;
      },
      [answer.text],
    );
    final consts = FocusBubbleContainerConsts.of(context);
    void updateAnswer() {
      if (answer.text == controller.text) return;
      answer.text = controller.text;
      unawaited(answer.save());
      onChange();
    }

    final theme = Theme.of(context);

    return FocusBubbleContainer(
      onUnfocus: updateAnswer,
      onFocus: onFocus,
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            focusedBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(
                width: 0.1,
                color: consts.brightness == Brightness.light
                    ? AppColors.black
                    : AppColors.grey2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(
                width: 0.05,
                color: consts.brightness == Brightness.light
                    ? AppColors.black
                    : AppColors.grey4,
              ),
            ),
            focusColor: Colors.red,
            fillColor: Colors.green,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20)
                    .copyWith(top: 4),
          ),
        ),
        child: TextField(
          onChanged: (final _) => updateAnswer(),
          controller: controller,
          maxLines: null,
          keyboardAppearance: Theme.of(context).brightness,
          textAlignVertical: TextAlignVertical.bottom,
          keyboardType: TextInputType.multiline,
          onEditingComplete: updateAnswer,
          style: Theme.of(context).textTheme.bodyText2,
          cursorColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
