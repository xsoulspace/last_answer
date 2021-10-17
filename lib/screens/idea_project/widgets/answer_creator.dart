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
      final box = await Hive.openBox<IdeaProjectAnswer>(
          HiveBoxesIds.ideaProjectAnswerKey,);
      await box.put(answer.id, answer);
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
              padding: EdgeInsets.only(left: 14),
              child: IconShareButton(),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _AnswerField(
                controller: answerController,
                onCreate: onCreate,
              ),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: IconButton(
                onPressed: onCreate,
                icon: const Icon(
                  Icons.send,
                  color: AppColors.primary2,
                ),
              ),
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
  final _keyboardFocusNode = FocusNode();
  final _textFieldFocusNode = FocusNode();
  @override
  void initState() {
    _textFieldFocusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      onKey: (final event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
            (event.isShiftPressed || event.isControlPressed)) {
          widget.onCreate();
        }
      },
      child: TextFormField(
        focusNode: _textFieldFocusNode,
        onFieldSubmitted: (final _) => widget.onCreate(),
        controller: widget.controller,
        minLines: 1,
        maxLines: 7,
        keyboardType: TextInputType.multiline,
        onChanged: (final text) async {},
        style: Theme.of(context).textTheme.headline3,
        decoration: const InputDecoration()
            .applyDefaults(Theme.of(context).inputDecorationTheme)
            .copyWith(
              // labelStyle: TextStyle(color: Colors.white),
              // fillColor: ThemeColors.lightAccent,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.primary2,
                ),
              ),
              labelText: S.current.answer,
            ),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
