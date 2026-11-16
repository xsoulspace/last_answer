import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/widgets/answer_field_bubble.dart';
import 'package:lastanswer/idea/widgets/question_dropdown.dart';
import 'package:lastanswer/widgets/legacy_kit/legacy_kit.dart';

class AnswerTile extends StatelessWidget {
  const AnswerTile({
    required this.answer,
    required this.confirmDelete,
    required this.onReadyToDelete,
    required this.deleteIconVisible,
    required this.onExpand,
    required this.onFocus,
    required this.onChanged,
    super.key,
  });
  const AnswerTile.deletable({
    required this.answer,
    required this.confirmDelete,
    required this.onReadyToDelete,
    required this.deleteIconVisible,
    required this.onExpand,
    required this.onFocus,
    required this.onChanged,
    super.key,
  });
  final IdeaProjectAnswerModel answer;
  final FutureBoolCallback confirmDelete;
  final ValueChanged<IdeaProjectAnswerModel> onReadyToDelete;
  final ValueChanged<IdeaProjectAnswerModel> onChanged;
  final ValueChanged<IdeaProjectAnswerModel> onExpand;
  final bool deleteIconVisible;
  final VoidCallback onFocus;
  @override
  Widget build(final BuildContext context) => DismissibleTile(
    dismissibleKey: Key(answer.id.value),
    // confirmDismiss: (final direction) async {
    //   if (direction != DismissDirection.startToEnd) return false;
    //   return confirmDelete();
    // },
    onDismissed: () => onReadyToDelete(answer),
    child: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: SizedBox(
            width: 150,
            child: HeroId(
              id: '${answer.id}-question',
              type: HeroIdTypes.projectIdeaQuestionTitle,
              child: QuestionDropdown(answer: answer, onChanged: onChanged),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Row(
            children: [
              Visibility(
                visible: deleteIconVisible,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: LaButton.icon(
                    onPressed: () async {
                      final confirmed = await confirmDelete();
                      if (confirmed) onReadyToDelete(answer);
                    },
                    icon: Icon(
                      Icons.close,
                      color: context.laUi.danger.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              LaButton.icon(
                onPressed: () => onExpand(answer),
                icon: Icon(
                  Icons.expand,
                  size: 18,
                  color: context.laUi.accent.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 54, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 24),
              Flexible(
                child: HeroId(
                  id: answer.id.value,
                  placeholderBuilder: (final _, final _, final child) =>
                      Opacity(opacity: 0.4, child: child),
                  type: HeroIdTypes.projectIdeaAnswerText,
                  child: AnswerFieldBubble(
                    onFocus: onFocus,
                    answer: answer,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
