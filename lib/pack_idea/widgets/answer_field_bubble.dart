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
        child: TextFormField(
          onChanged: updateAnswer,
          maxLines: null,
          initialValue: answer.text,
          textAlignVertical: TextAlignVertical.bottom,
          keyboardType: TextInputType.multiline,
          onEditingComplete: () {},
          style: context.textTheme.bodyMedium,
          cursorColor: context.colorScheme.secondary,
        ),
      ),
    );
  }
}
