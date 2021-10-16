part of idea_project;

class _AnswerCreator extends HookWidget {
  const _AnswerCreator({
    required final this.onCreated,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<IdeaProjectAnswer> onCreated;
  @override
  Widget build(final BuildContext context) {
    final selectedQuestion = useState<IdeaProjectQuestion?>(null);
    final answerController = useTextEditingController();
    Future<void> onCreate() async {
      final text = answerController.text;
      final question = selectedQuestion.value;
      if (question == null || text.isEmpty) return;
      final answer =
          await IdeaProjectAnswer.create(text: text, question: question);
      answerController.clear();
      onCreated(answer);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _QuestionsChips(
                onChange: (final question) => selectedQuestion.value = question,
                value: selectedQuestion.value,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: IconShareButton(),
            ),
          ],
        ),
        Row(
          children: [
            _AnswerField(
              controller: answerController,
              onCreate: onCreate,
            ),
            IconButton(
              onPressed: onCreate,
              icon: const Icon(Icons.publish),
            ),
          ],
        )
      ],
    );
  }
}

class _AnswerField extends StatefulHookWidget {
  const _AnswerField({
    required final this.controller,
    required final this.onCreate,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final VoidCallback onCreate;
  @override
  State<_AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<_AnswerField> {
  final focusNode = FocusNode();
  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (final event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
            !event.isShiftPressed) {
          widget.onCreate();
        }
      },
      child: TextFormField(
        onFieldSubmitted: (final _) => widget.onCreate(),
        controller: widget.controller,
        minLines: 1,
        maxLines: 7,
        keyboardType: TextInputType.multiline,
        onChanged: (final text) async {},
        decoration: InputDecoration(
          // labelStyle: TextStyle(color: Colors.white),
          // fillColor: ThemeColors.lightAccent,
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: ThemeColors.lightAccent ?? Colors.white,
          //   ),
          // ),
          // border: OutlineInputBorder(
          //     borderSide: BorderSide(
          //         color: ThemeColors.lightAccent ?? Colors.white)),
          labelText: S.current.answer,
        ),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
