part of idea_project;

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required final this.answer,
    required final this.confirmDelete,
    required final this.onReadyToDelete,
    required final this.deleteIconVisible,
    required final this.onExpand,
    required final this.onFocus,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  final BoolCallback confirmDelete;
  final VoidCallback onReadyToDelete;
  final bool deleteIconVisible;
  final ValueChanged<IdeaProjectAnswer> onExpand;
  final VoidCallback onFocus;
  @override
  Widget build(final BuildContext context) {
    return DismissibleTile(
      dismissibleKey: Key(answer.id),
      confirmDismiss: (final direction) async {
        if (direction != DismissDirection.startToEnd) return false;
        return confirmDelete();
      },
      onDismissed: (final direction) async {
        if (direction != DismissDirection.startToEnd) return;
        onReadyToDelete();
      },
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: 150,
              child: HeroId(
                flightShuttleBuilder: (
                  final _,
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
                  child: IconButton(
                    onPressed: () {
                      final confirmed = confirmDelete();
                      if (confirmed) onReadyToDelete();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
                IconButton(
                  onPressed: () => onExpand(answer),
                  icon: const Icon(Icons.expand),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 44.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 30),
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
