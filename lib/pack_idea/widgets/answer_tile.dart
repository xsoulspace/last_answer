part of pack_idea;

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required final this.answer,
    required final this.confirmDelete,
    required final this.onReadyToDelete,
    required final this.deleteIconVisible,
    required final this.onExpand,
    required final this.onFocus,
    required final this.onChange,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  final FutureBoolCallback confirmDelete;
  final VoidCallback onReadyToDelete;
  final bool deleteIconVisible;
  final ValueChanged<IdeaProjectAnswer> onExpand;
  final VoidCallback onFocus;
  final VoidCallback onChange;
  @override
  Widget build(final BuildContext context) {
    return DismissibleTile(
      dismissibleKey: Key(answer.id),
      // confirmDismiss: (final direction) async {
      //   if (direction != DismissDirection.startToEnd) return false;
      //   return confirmDelete();
      // },
      onDismissed: onReadyToDelete,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: 150,
              child: HeroId(
                flightShuttleBuilder: (
                  final context,
                  final animation,
                  final direction,
                  final ____,
                  final _____,
                ) {
                  switch (direction) {
                    case HeroFlightDirection.pop:
                      return Material(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 11.5),
                          child: Text(
                            answer.question.title
                                .getByLanguage(Intl.getCurrentLocale()),
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      );
                    case HeroFlightDirection.push:
                      return Material(
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                answer.question.title
                                    .getByLanguage(Intl.getCurrentLocale()),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),

                              /// Size of icon for dropdown
                              const SizedBox(width: 24),
                            ],
                          ),
                        ),
                      );
                  }
                },
                id: '${answer.id}-question${answer.question.id}',
                type: HeroIdTypes.projectIdeaQuestionTitle,
                child: _QuestionDropdown(
                  answer: answer,
                  onChange: onChange,
                ),
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
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      onPressed: () async {
                        final confirmed = await confirmDelete();
                        if (confirmed) onReadyToDelete();
                      },
                      color: AppColors.accent2.withOpacity(0.6),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onExpand(answer),
                  iconSize: 18,
                  icon: const Icon(Icons.expand),
                  color: AppColors.primary2.withOpacity(0.6),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 54.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 24),
                Flexible(
                  child: HeroId(
                    id: answer.id,
                    placeholderBuilder: (final _, final __, final child) {
                      return Opacity(opacity: 0.4, child: child);
                    },
                    type: HeroIdTypes.projectIdeaAnswerText,
                    child: AnswerFieldBubble(
                      onFocus: onFocus,
                      answer: answer,
                      onChange: onChange,
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
}
