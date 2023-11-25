import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class ProjectTextField extends StatefulHookWidget {
  const ProjectTextField({
    required this.onSubmit,
    required this.hintText,
    this.controller,
    this.onUnfocus,
    this.onFocus,
    this.filled = true,
    this.value,
    this.onChanged,
    this.maxLines = 7,
    this.endlessLines = false,
    this.focusOnInit = true,
    this.focusNode,
    this.countCharacters = false,
    this.undoController,
    this.limit,
    this.hasBorder = true,
    this.contentPadding,
    super.key,
  });
  final TextEditingController? controller;
  final VoidCallback onSubmit;
  final int maxLines;
  final String hintText;
  final FocusNode? focusNode;
  final int? limit;
  final EdgeInsets? contentPadding;
  final UndoHistoryController? undoController;
  final bool countCharacters;
  final String? value;
  final ValueChanged<String>? onChanged;

  /// if [endlessLines] == [true] then maxLines will be ignored
  final bool endlessLines;
  final bool focusOnInit;
  final bool filled;
  final VoidCallback? onUnfocus;
  final bool hasBorder;
  final VoidCallback? onFocus;

  @override
  _ProjectTextFieldState createState() => _ProjectTextFieldState();
}

class _ProjectTextFieldState extends State<ProjectTextField> {
  late final _isInnerControllerUsed = widget.controller == null;
  late final _controller =
      widget.controller ?? TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant final ProjectTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final v = widget.value;
    if (v == null) return;
    if (mounted) _controller.text = v;
  }

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
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        if (_textFieldFocusNode.canRequestFocus) {
          if (!mounted) return;
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
    if (_isInnerControllerUsed) _controller.dispose();
    super.dispose();
  }

  static final _border = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: defaultBorderRadius,
  );

  @override
  Widget build(final BuildContext context) {
    final focusedBorder = widget.hasBorder
        ? OutlineInputBorder(
            borderRadius: defaultBorderRadius,
            borderSide:
                BorderSide(color: context.colorScheme.primary.withOpacity(0.4)),
          )
        : _border;
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
        onUnfocus: widget.onUnfocus,
        child: RawKeyboardListener(
          focusNode: _keyboardFocusNode,
          onKey: (final event) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
                (event.isMetaPressed || event.isControlPressed)) {
              widget.onSubmit();
            }
          },
          child: TextFormField(
            onChanged: widget.onChanged,
            maxLength: _maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            maxLines: widget.endlessLines ? null : widget.maxLines,
            scrollController: scrollController,
            focusNode: _textFieldFocusNode,
            onFieldSubmitted: (final _) => widget.onSubmit(),
            controller: _controller,
            undoController: widget.undoController,
            keyboardAppearance: theme.brightness,
            minLines: widget.endlessLines ? null : 1,
            expands: widget.endlessLines,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.bottom,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              contentPadding: widget.contentPadding ??
                  (PlatformInfo.isNativeDesktop
                      ? const EdgeInsets.fromLTRB(12, 20, 0, 20)
                      : const EdgeInsets.only(bottom: 4)),
              filled: widget.filled,
              focusedBorder: focusedBorder,
              border: _border,
              hoverColor: context.colorScheme.secondary.withOpacity(0.01),
              focusColor: Colors.transparent,
              fillColor: Colors.transparent,
              hintText: widget.hintText,
            ),
          ),
        ),
      ),
    );
  }
}
