part of widgets;

class ProjectTextField extends StatefulHookWidget {
  const ProjectTextField({
    required final this.controller,
    required final this.onSubmit,
    required final this.hintText,
    final this.onUnfocus,
    final this.onFocus,
    final this.filled = true,
    final this.maxLines = 7,
    final this.endlessLines = false,
    final this.focusOnInit = true,
    final this.fillColor,
    final this.focusNode,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final int maxLines;
  final String hintText;
  final FocusNode? focusNode;

  /// if [endlessLines] == [true] then maxLines will be ignored
  final bool endlessLines;
  final bool? focusOnInit;
  final bool filled;
  final Color? fillColor;
  final VoidCallback? onUnfocus;
  final VoidCallback? onFocus;

  @override
  _ProjectTextFieldState createState() => _ProjectTextFieldState();
}

class _ProjectTextFieldState extends State<ProjectTextField> {
  final _keyboardFocusNode = FocusNode();
  late FocusNode _textFieldFocusNode;
  @override
  void initState() {
    if (widget.focusOnInit != false) {
      WidgetsBinding.instance?.addPostFrameCallback((final _) {
        FocusScope.of(context).requestFocus(_textFieldFocusNode);
      });
    }
    _textFieldFocusNode = widget.focusNode ?? FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  static final _border = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: defaultBorderRadius,
  );

  @override
  Widget build(final BuildContext context) {
    return FocusBubbleContainer(
      onFocus: widget.onFocus,
      fillColor: widget.fillColor,
      child: RawKeyboardListener(
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
          style: Theme.of(context).textTheme.bodyText2,
          decoration: const InputDecoration()
              .applyDefaults(Theme.of(context).inputDecorationTheme)
              .copyWith(
                contentPadding: const EdgeInsets.all(6),
                filled: widget.filled,
                // labelStyle: TextStyle(color: Colors.white),
                // fillColor: ThemeColors.lightAccent,
                focusedBorder: _border,
                border: _border,
                fillColor: Colors.transparent,
                hintText: widget.hintText,
              ),
          cursorColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
