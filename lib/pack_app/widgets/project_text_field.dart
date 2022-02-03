part of pack_app;

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
    this.countCharacters = false,
    this.limit,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final int maxLines;
  final String hintText;
  final FocusNode? focusNode;
  final int? limit;
  final bool countCharacters;

  /// if [endlessLines] == [true] then maxLines will be ignored
  final bool endlessLines;
  final bool focusOnInit;
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
  int? _maxLength;
  void setMaxLength() {
    if (widget.limit == null || widget.limit == 0) {
      _maxLength = widget.countCharacters ? TextField.noMaxLength : null;
    } else {
      _maxLength = widget.limit;
    }
  }

  @override
  void initState() {
    setMaxLength();
    if (widget.focusOnInit) {
      WidgetsBinding.instance?.addPostFrameCallback((final _) {
        if (!mounted) return;
        if (_textFieldFocusNode.canRequestFocus) {
          FocusScope.of(context).requestFocus(_textFieldFocusNode);
        }
      });
    }

    _textFieldFocusNode = widget.focusNode ?? FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    if (widget.focusNode == null) _textFieldFocusNode.dispose();
    super.dispose();
  }

  static final _border = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: defaultBorderRadius,
  );

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final scrollController = useScrollController();

    useEffect(
      // ignore: unnecessary_lambdas
      () {
        setMaxLength();

        return null;
      },
      [widget.limit],
    );

    return RightScrollbar(
      controller: scrollController,
      child: FocusBubbleContainer(
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
            maxLength: _maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            maxLines: widget.endlessLines ? null : widget.maxLines,
            scrollController: scrollController,
            focusNode: _textFieldFocusNode,
            onFieldSubmitted: (final _) => widget.onSubmit(),
            controller: widget.controller,
            keyboardAppearance: theme.brightness,
            minLines: widget.endlessLines ? null : 1,
            expands: widget.endlessLines,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.bottom,
            style: theme.textTheme.bodyText2,
            decoration: const InputDecoration()
                .applyDefaults(theme.inputDecorationTheme)
                .copyWith(
                  contentPadding: isNativeDesktop
                      ? const EdgeInsets.all(6)
                      : const EdgeInsets.only(top: 6, bottom: 4),
                  filled: widget.filled,
                  // labelStyle: TextStyle(color: Colors.white),
                  // fillColor: ThemeColors.lightAccent,
                  focusedBorder: _border,
                  border: _border,
                  fillColor: Colors.transparent,
                  hintText: widget.hintText,
                ),
            cursorColor: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
