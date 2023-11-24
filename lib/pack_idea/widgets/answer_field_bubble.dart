import 'package:lastanswer/_library/widgets/widgets.dart';
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
    final consts = FocusBubbleContainerConsts.of(context);
    void updateAnswer(final String text) {
      if (answer.text == text) return;
      onChanged(answer.copyWith(text: text));
    }

    final theme = Theme.of(context);

    return FocusBubbleContainer(
      onUnfocus: () {},
      onFocus: onFocus,
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            focusedBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: defaultBorderRadius,
              borderSide: BorderSide(
                color: context.colorScheme.onPrimaryContainer.withOpacity(0.2),
              ),
            ),
          ),
        ),
        child: UiTextField(
          onChanged: updateAnswer,
          value: answer.text,
          maxLines: null,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.multiline,
          style: context.textTheme.bodyMedium,
          decoration: const InputDecoration(isDense: true),
        ),
      ),
    );
  }
}
