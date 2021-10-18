part of idea_project;

class _AnswerField extends StatefulHookWidget {
  const _AnswerField({
    required final this.controller,
    required final this.onSubmit,
    final this.filled = true,
    final this.maxLines = 7,
    final this.endlessLines = false,
    final this.focusOnOpen = true,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final int maxLines;

  /// if [endlessLines] == [true] then maxLines will be ignored
  final bool endlessLines;
  final bool? focusOnOpen;
  final bool filled;

  @override
  State<_AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<_AnswerField> {
  final _keyboardFocusNode = FocusNode();
  final _textFieldFocusNode = FocusNode();
  @override
  void initState() {
    if (widget.focusOnOpen != false) {
      WidgetsBinding.instance?.addPostFrameCallback((final _) {
        FocusScope.of(context).requestFocus(_textFieldFocusNode);
      });
    }
    super.initState();
  }

  static final _border = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: defaultBorderRadius,
  );

  @override
  Widget build(final BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      onKey: (final event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
            (event.isShiftPressed || event.isControlPressed)) {
          widget.onSubmit();
        }
      },
      child: TextFormField(
        focusNode: _textFieldFocusNode,
        onFieldSubmitted: (final _) => widget.onSubmit(),
        controller: widget.controller,
        keyboardAppearance: Theme.of(context).brightness,
        minLines: widget.endlessLines ? null : 1,
        expands: widget.endlessLines,
        maxLines: widget.endlessLines ? null : widget.maxLines,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.bottom,
        onChanged: (final text) async {},
        style: Theme.of(context).textTheme.headline4,
        decoration: const InputDecoration()
            .applyDefaults(Theme.of(context).inputDecorationTheme)
            .copyWith(contentPadding: EdgeInsets.all(6),
              filled: widget.filled,
              // labelStyle: TextStyle(color: Colors.white),
              // fillColor: ThemeColors.lightAccent,
              focusedBorder: _border,
              border: _border,
              hintText: S.current.answer,
            ),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
