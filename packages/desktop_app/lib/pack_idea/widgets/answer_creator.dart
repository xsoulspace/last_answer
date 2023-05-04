import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_idea/widgets/answer_creator_state.dart';
import 'package:lastanswer/pack_idea/widgets/questions_chips.dart';
import 'package:provider/provider.dart';

class AnswerCreator extends HookWidget {
  const AnswerCreator({
    required this.onCreated,
    required this.defaultQuestion,
    required this.idea,
    required this.onShareTap,
    required this.onFocus,
    required this.questionsOpened,
    required this.onChanged,
    required this.answersIsEmpty,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectQuestion defaultQuestion;
  final IdeaProject idea;
  final ValueChanged<IdeaProjectAnswer> onCreated;
  final VoidCallback onShareTap;
  final VoidCallback onFocus;
  final ValueNotifier<bool> questionsOpened;
  final VoidCallback onChanged;
  final bool answersIsEmpty;
  static Color getBackgroundByTheme(final ThemeData theme) =>
      theme.brightness == Brightness.light
          ? AppColors.grey4.withOpacity(0.15)
          : AppColors.grey1.withOpacity(0.15);
  @override
  Widget build(final BuildContext context) {
    final state = useAnswerCreatorState(
      ideaSyncService: context.watch(),
      defaultQuestion: defaultQuestion,
      idea: idea,
      onChanged: onChanged,
      onCreated: onCreated,
      onFocus: onFocus,
      onShareTap: onShareTap,
      questionsOpened: questionsOpened,
    );

    final theme = Theme.of(context);

    final sendButton = RotatedBox(
      quarterTurns: 3,
      child: IconButton(
        onPressed: state.answer.value.isNotEmpty ? state.onCreate : null,
        color: AppColors.primary2,
        icon: const Icon(Icons.send),
      ),
    );
    final shareButton = Hero(
      tag: const Key('shareButton'),
      child: IconShareButton(
        onTap: onShareTap,
      ),
    );

    return Material(
      color: questionsOpened.value
          ? getBackgroundByTheme(theme)
          : theme.canvasColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: questionsOpened.value,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 14,
                bottom: 2,
                right: 10,
                left: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<IdeaProjectQuestion?>(
                      valueListenable: state.selectedQuestion,
                      builder: (
                        final context,
                        final selectedQuestion,
                        final child,
                      ) {
                        return QuestionsChips(
                          onChange: (final question) =>
                              state.selectedQuestion.value = question,
                          value: selectedQuestion,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        shareButton,
                        EmojiPopup(
                          controller: state.answerController,
                          focusNode: state.answerFocusNode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: FlatTextField(
                    hintText: S.current.writeAnAnswer,
                    focusOnInit: answersIsEmpty,
                    controller: state.answerController,
                    onSubmit: state.onCreate,
                    focusNode: state.answerFocusNode,
                    onFocus: onFocus,
                  ),
                ),
                if (questionsOpened.value) sendButton else shareButton,
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
