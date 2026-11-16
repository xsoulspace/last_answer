import 'package:flutter/cupertino.dart' show cupertinoTextSelectionControls;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/widgets/legacy_kit/legacy_kit.dart';

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
    this.textAlignVertical = TextAlignVertical.bottom,
    super.key,
  });

  /// NOTE(ui-kit sweep lane D): retained for call-site compatibility. The
  /// field now rides the widgets-layer [EditableText] (kit gap: [LaField]
  /// carries no [undoController]/[scrollController]), which top-aligns its
  /// content; vertical alignment inside an expanding field is not applied.
  final TextAlignVertical textAlignVertical;
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

  /// Mirrors `TextField.noMaxLength`: show the character counter without
  /// enforcing a limit (the original used `MaxLengthEnforcement.none`).
  static const int _noMaxLength = -1;

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
  bool _focused = false;

  void setMaxLength() {
    if (widget.limit == null || widget.limit == 0) {
      _maxLength = widget.countCharacters ? _noMaxLength : null;
    } else {
      _maxLength = widget.limit;
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    setMaxLength();
    _controller.addListener(_onTextChanged);
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
    _controller.removeListener(_onTextChanged);
    _keyboardFocusNode.dispose();
    if (widget.focusNode == null) _textFieldFocusNode.dispose();
    if (_isInnerControllerUsed) _controller.dispose();
    super.dispose();
  }

  String? _counterText() {
    final maxLength = _maxLength;
    if (maxLength == null) return null;
    final length = _controller.text.length;
    if (maxLength == _noMaxLength) return '$length';
    return '$length/$maxLength';
  }

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    final scrollController = useScrollController();

    useEffect(
      // ignore: unnecessary_lambdas
      () {
        setMaxLength();

        return null;
      },
      [widget.limit],
    );

    final showPlaceholder = _controller.text.isEmpty;
    final counter = _counterText();
    final textStyle = laUi.body;

    Widget field = LaPressable(
      // Pure paint + hover carrier: EditableText owns taps, focus and the
      // cursor (same composition as the kit's own LaField).
      ownFocus: false,
      showRing: false,
      scaleOnPress: false,
      hitTestBehavior: HitTestBehavior.translucent,
      radius: defaultBorderRadius,
      fill: _focused || widget.filled ? laUi.fieldFill : null,
      border: widget.hasBorder && _focused
          ? BorderSide(color: laUi.accent.withValues(alpha: 0.4))
          : null,
      child: Padding(
        padding:
            widget.contentPadding ??
            (PlatformInfo.isNativeDesktop
                ? const EdgeInsets.fromLTRB(12, 20, 0, 20)
                : const EdgeInsets.only(bottom: 4)),
        child: Stack(
          children: [
            if (showPlaceholder)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: Text(
                    widget.hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(color: laUi.inkQuiet),
                  ),
                ),
              ),
            KeyboardListener(
              focusNode: _keyboardFocusNode,
              onKeyEvent: (final event) {
                if ((HardwareKeyboard.instance.isMetaPressed ||
                        HardwareKeyboard.instance.isControlPressed) &&
                    HardwareKeyboard.instance.isLogicalKeyPressed(
                      LogicalKeyboardKey.enter,
                    )) {
                  widget.onSubmit();
                }
              },
              child: Focus(
                onFocusChange: (final hasFocus) {
                  if (hasFocus != _focused && mounted) {
                    setState(() => _focused = hasFocus);
                  }
                  if (hasFocus) {
                    widget.onFocus?.call();
                  } else {
                    widget.onUnfocus?.call();
                  }
                },
                child: EditableText(
                  controller: _controller,
                  focusNode: _textFieldFocusNode,
                  undoController: widget.undoController,
                  scrollController: scrollController,
                  style: textStyle,
                  cursorColor: laUi.accent,
                  backgroundCursorColor: laUi.inkQuiet,
                  selectionColor: laUi.accent.withValues(alpha: 0.28),
                  cursorWidth: 1.5,
                  cursorRadius: const Radius.circular(1),
                  maxLines: widget.endlessLines ? null : widget.maxLines,
                  minLines: widget.endlessLines ? null : 1,
                  expands: widget.endlessLines,
                  keyboardType: TextInputType.multiline,
                  keyboardAppearance: laUi.isDark
                      ? Brightness.dark
                      : Brightness.light,
                  onChanged: widget.onChanged,
                  onSubmitted: (final _) => widget.onSubmit(),
                  selectionControls: switch (defaultTargetPlatform) {
                    TargetPlatform.iOS || TargetPlatform.android =>
                      cupertinoTextSelectionControls,
                    _ => null,
                  },
                  contextMenuBuilder: (context, editableTextState) =>
                      LaSelectionToolbar(
                        items: editableTextState.contextMenuButtonItems,
                        anchors: editableTextState.contextMenuAnchors,
                        labelFor: LaSelectionLabels.labelFor,
                      ),
                  scrollBehavior: const LaScrollBehavior().copyWith(
                    scrollbars: false,
                    overscroll: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (counter != null) {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: field),
          const SizedBox(height: 2),
          Text(counter, style: laUi.micro),
        ],
      );
    }

    return RightScrollbar(controller: scrollController, child: field);
  }
}
