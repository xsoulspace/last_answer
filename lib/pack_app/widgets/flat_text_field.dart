import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';

class FlatTextField extends StatefulHookWidget {
  const FlatTextField({
    required final this.controller,
    required final this.onSubmit,
    required final this.hintText,
    this.onUnfocus,
    this.onFocus,
    this.filled = true,
    this.maxLines = 7,
    this.endlessLines = false,
    this.focusOnInit = true,
    this.fillColor,
    this.focusNode,
    this.countCharacters = false,
    this.limit,
    this.labelText,
    this.contentPadding,
    this.obscureText = false,
    this.validator,
    final Key? key,
  }) : super(key: key);
  final String? labelText;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final int maxLines;
  final String hintText;
  final FocusNode? focusNode;
  final int? limit;
  final bool countCharacters;
  final EdgeInsets? contentPadding;
  final FormFieldValidator<String>? validator;
  final bool obscureText;

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

class _ProjectTextFieldState extends State<FlatTextField> {
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
            validator: widget.validator,
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
            obscureText: widget.obscureText,
            decoration: const InputDecoration()
                .applyDefaults(theme.inputDecorationTheme)
                .copyWith(
                  contentPadding: widget.contentPadding ??
                      (DeviceRuntimeType.isNativeDesktop
                          ? const EdgeInsets.all(6)
                          : const EdgeInsets.only(top: 6, bottom: 4)),
                  filled: widget.filled,
                  labelText: widget.labelText,
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
