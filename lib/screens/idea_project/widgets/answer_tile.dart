part of idea_project;

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required final this.answer,
    required final this.confirmDelete,
    required final this.onReadyToDelete,
    required final this.deleteIconVisible,
    final Key? key,
  }) : super(key: key);
  final IdeaProjectAnswer answer;
  final BoolCallback confirmDelete;
  final VoidCallback onReadyToDelete;
  final bool deleteIconVisible;

  @override
  Widget build(final BuildContext context) {
    return DismissibleTile(
      dismissibleKey: Key(answer.id),
      confirmDismiss: (final direction) async {
        if (direction.index != 3) return false;
        return confirmDelete();
      },
      onDismissed: (final direction) async {
        onReadyToDelete();
      },
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Row(
              children: [
                _QuestionBubble(
                  answer: answer,
                ),
                const Spacer(),
                Visibility(
                  visible: deleteIconVisible,
                  child: IconButton(
                    onPressed: () {
                      final confirmed = confirmDelete();
                      if (confirmed) onReadyToDelete();
                    },
                    icon: const Icon(Icons.close),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 15,
            left: 17,
            child: AnswerFieldBubble(
              answer: answer,
            ),
          ),
        ],
      ),
    );
  }
}
