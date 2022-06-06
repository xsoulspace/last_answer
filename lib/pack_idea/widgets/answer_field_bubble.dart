part of pack_idea;

class AnswerFieldBubble extends HookWidget {
  const AnswerFieldBubble({
    required final this.answer,
    required final this.onFocus,
    required final this.onChange,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  final VoidCallback onFocus;
  final VoidCallback onChange;
  @override
  Widget build(final BuildContext context) {
    final controller = useTextEditingController(
      text: answer.text,
    );
    final ideaAnswerSyncService = context.watch<ServerIdeaAnswerSyncService>();

    useEffect(
      () {
        controller.text = answer.text;

        return null;
      },
      [answer.text],
    );
    final consts = FocusBubbleContainerConsts.of(context);
    void _updateAnswer() {
      if (answer.text == controller.text) return;
      // TODO(arenukvern): refactor answers updates to single stream
      answer
        ..text = controller.text
        ..updatedAt = dateTimeNowUtc()
        ..save();
      ideaAnswerSyncService.upsert([answer]);
      onChange();
    }

    final theme = Theme.of(context);

    return FocusBubbleContainer(
      onUnfocus: _updateAnswer,
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
          onChanged: (final _) => _updateAnswer(),
          controller: controller,
          maxLines: null,
          keyboardAppearance: Theme.of(context).brightness,
          textAlignVertical: TextAlignVertical.bottom,
          keyboardType: TextInputType.multiline,
          onEditingComplete: _updateAnswer,
          style: Theme.of(context).textTheme.bodyText2,
          cursorColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
