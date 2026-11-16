import 'package:lastanswer/common_imports.dart';

class AnswerFieldBubble extends HookWidget {
  const AnswerFieldBubble({
    required this.answer,
    required this.onFocus,
    required this.onChanged,
    super.key,
  });
  final IdeaProjectAnswerModel answer;
  final ValueChanged<IdeaProjectAnswerModel> onChanged;
  final VoidCallback onFocus;
  @override
  Widget build(final BuildContext context) {
    void updateAnswer(final String text) {
      if (answer.text == text) return;
      onChanged(answer.copyWith(text: text));
    }

    // The legacy FocusBubbleContainer focus fill is now the kit field's own
    // hover/focus paint; the focus callback rides a listener on the node.
    final focusNode = useFocusNode();
    useEffect(
      () {
        void listener() {
          if (focusNode.hasFocus) onFocus();
        }

        focusNode.addListener(listener);
        return () => focusNode.removeListener(listener);
      },
      const [],
    );

    // The legacy UiTextField was value-driven; mirror the answer text into
    // a controller for the kit field.
    final controller = useTextEditingController(text: answer.text);
    useValueChanged<String, void>(answer.text, (final _, final _) {
      if (controller.text != answer.text) controller.text = answer.text;
    });

    return LaField(
      controller: controller,
      focusNode: focusNode,
      onChanged: updateAnswer,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: context.laUi.body,
    );
  }
}
