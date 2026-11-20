import 'package:cupertino_ui/cupertino_ui.dart' show cupertinoTextSelectionControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:la_ui_kit/src/pressable.dart';
import 'package:la_ui_kit/src/scroll.dart';
import 'package:la_ui_kit/src/selectable.dart';
import 'package:la_ui_kit/src/theme.dart';

/// The kit text input: [EditableText] (the engine — IME, selection, a11y)
/// wrapped in the Linear field law from the de-material plan §2: borderless
/// at rest, earns the field fill on hover, fill + accent hairline on focus;
/// honest error line below; prefix/suffix slots. Replaces
/// TextField+InputDecoration everywhere.
class LaField extends StatefulWidget {
  /// A single-line (or [maxLines]-limited) text field.
  const LaField({
    this.controller,
    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTapOutside,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.textAlign = TextAlign.start,
    this.style,
    this.placeholderStyle,
    this.prefix,
    this.suffix,
    this.errorText,
    this.counterText,
    this.height = 34,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.radius,
    this.fill,
    this.showFocusHairline = true,
    this.maxLength,
    this.cursorColor,
    super.key,
  });

  /// Text controller (created internally when null).
  final TextEditingController? controller;

  /// External focus node.
  final FocusNode? focusNode;

  /// Hint text (quiet ink, never a floating label).
  final String? placeholder;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Submit callback (enter on single-line fields).
  final ValueChanged<String>? onSubmitted;

  /// Editing-complete hook.
  final VoidCallback? onEditingComplete;

  /// Tap-outside hook (wire to unfocus where needed).
  final void Function(PointerDownEvent)? onTapOutside;

  /// Grab focus on mount.
  final bool autofocus;

  /// False greys the field out.
  final bool enabled;

  /// Non-editable but selectable.
  final bool readOnly;

  /// Password mode.
  final bool obscureText;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// IME action.
  final TextInputAction? textInputAction;

  /// Capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Autocorrect flag.
  final bool autocorrect;

  /// Suggestion flag.
  final bool enableSuggestions;

  /// Input formatters (masking, length caps).
  final List<TextInputFormatter>? inputFormatters;

  /// Line cap (null with [expands] for composer-style growth).
  final int? maxLines;

  /// Line floor for multiline growth.
  final int? minLines;

  /// Fill the incoming height (needs maxLines null).
  final bool expands;

  /// Text alignment.
  final TextAlign textAlign;

  /// Text style override (defaults to the body token, 13.5 px).
  final TextStyle? style;

  /// Placeholder style override (defaults to body @ inkQuiet).
  final TextStyle? placeholderStyle;

  /// Leading slot (search glyph, attach button).
  final Widget? prefix;

  /// Trailing slot (send, clear, visibility toggle).
  final Widget? suffix;

  /// Honest error line (danger, below the field).
  final String? errorText;

  /// Counter/measure text (bottom-right, micro).
  final String? counterText;

  /// Resting height (ignored when multiline/expands).
  final double height;

  /// Inner inset.
  final EdgeInsetsGeometry padding;

  /// Corner radii override.
  final BorderRadius? radius;

  /// Resting fill override (null = transparent at rest, the field law).
  final Color? fill;

  /// Whether focus earns the accent hairline.
  final bool showFocusHairline;

  /// Optional hard length cap (drives the default counter when set).
  final int? maxLength;

  /// Cursor color override (defaults to accent).
  final Color? cursorColor;

  @override
  State<LaField> createState() => LaFieldState();
}

/// Public state so hosts can request focus/inspect the controller.
class LaFieldState extends State<LaField> {
  TextEditingController? _internalController;
  FocusNode? _internalNode;
  bool _hover = false;
  bool _focus = false;

  /// The active controller.
  TextEditingController get controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  /// The active focus node.
  FocusNode get focusNode =>
      widget.focusNode ?? (_internalNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocus);
    controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(final LaField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      _internalController?.dispose();
      _internalController = null;
      controller.addListener(_onTextChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocus);
      _internalNode?.dispose();
      _internalNode = null;
      focusNode.addListener(_onFocus);
      _focus = focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocus);
    controller.removeListener(_onTextChanged);
    _internalNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  void _onFocus() {
    final has = focusNode.hasFocus;
    if (has != _focus && mounted) {
      setState(() => _focus = has);
    }
  }

  void _onTextChanged() {
    // The placeholder visibility and the default counter read the live
    // text — rebuild on every edit.
    if (mounted) {
      setState(() {});
    }
  }

  bool get _multiline =>
      widget.expands || (widget.maxLines ?? 1) > 1 || widget.maxLines == null;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final radius = widget.radius ?? theme.controlRadius;
    final enabled = widget.enabled;

    final textStyle = (widget.style ?? theme.body.copyWith(fontSize: 13.5))
        .copyWith(color: enabled ? theme.ink : theme.inkQuiet);

    final Color? fill;
    if (!enabled) {
      fill = widget.fill;
    } else if (_focus) {
      fill = theme.fieldFill;
    } else if (_hover) {
      fill = theme.fieldFill;
    } else {
      fill = widget.fill;
    }
    final border = _focus && enabled && widget.showFocusHairline
        ? BorderSide(color: theme.accent)
        : null;

    final text = controller.text;
    final showPlaceholder = widget.placeholder != null && text.isEmpty;

    final counter =
        widget.counterText ??
        (widget.maxLength != null
            ? '${text.length}/${widget.maxLength}'
            : null);

    Widget field = LaPressable(
      // Pure paint + hover carrier: EditableText owns taps, focus and the
      // cursor, so the pressable never competes for gestures or traversal.
      ownFocus: false,
      enabled: enabled,
      showRing: false,
      scaleOnPress: false,
      hitTestBehavior: HitTestBehavior.translucent,
      radius: radius,
      fill: fill,
      border: border,
      onHoverChange: (v) {
        if (v != _hover) {
          setState(() => _hover = v);
        }
      },
      child: Padding(
        padding: widget.padding,
        child: Row(
          crossAxisAlignment: _multiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (widget.prefix != null) ...[
              widget.prefix!,
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (showPlaceholder)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: IgnorePointer(
                        child: Text(
                          widget.placeholder!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: widget.textAlign,
                          style:
                              widget.placeholderStyle ??
                              textStyle.copyWith(color: theme.inkQuiet),
                        ),
                      ),
                    ),
                  _EditableField(state: this, style: textStyle, theme: theme),
                ],
              ),
            ),
            if (widget.suffix != null) ...[
              const SizedBox(width: 6),
              widget.suffix!,
            ],
          ],
        ),
      ),
    );

    if (!_multiline) {
      field = ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.height),
        child: field,
      );
    }

    if (widget.errorText != null || counter != null) {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          field,
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: widget.errorText != null
                    ? Text(
                        widget.errorText!,
                        style: theme.compact.copyWith(color: theme.danger),
                      )
                    : const SizedBox.shrink(),
              ),
              if (counter != null) Text(counter, style: theme.micro),
            ],
          ),
        ],
      );
    }
    return field;
  }

  /// The custom selection toolbar (the kit's own — the adaptive Material one
  /// is banned by the component-carrier law): quiet floating row over the
  /// selection anchors, built from the engine's own button items.
  Widget buildContextMenu(final EditableTextState editableTextState) =>
      LaSelectionToolbar(
        items: editableTextState.contextMenuButtonItems,
        anchors: editableTextState.contextMenuAnchors,
        labelFor: LaSelectionLabels.labelFor,
      );
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.state,
    required this.style,
    required this.theme,
  });

  final LaFieldState state;
  final TextStyle style;
  final LaUiTheme theme;

  @override
  Widget build(final BuildContext context) {
    final widget = state.widget;
    return EditableText(
      controller: state.controller,
      focusNode: state.focusNode,
      style: style,
      cursorColor: widget.cursorColor ?? theme.accent,
      backgroundCursorColor: theme.inkQuiet,
      selectionColor: theme.accent.withValues(alpha: 0.28),
      cursorWidth: 1.5,
      cursorRadius: const Radius.circular(1),
      textAlign: widget.textAlign,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly || !widget.enabled,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      onTapOutside: widget.onTapOutside,
      keyboardAppearance: theme.isDark ? Brightness.dark : Brightness.light,
      selectionControls: switch (defaultTargetPlatform) {
        TargetPlatform.iOS ||
        TargetPlatform.android => cupertinoTextSelectionControls,
        _ => null,
      },
      contextMenuBuilder: (context, editableTextState) =>
          state.buildContextMenu(editableTextState),
      showCursor: widget.readOnly ? false : null,
      scrollBehavior: const LaScrollBehavior().copyWith(
        scrollbars: false,
        overscroll: false,
      ),
    );
  }
}

/// The multiline/composer variant: grows between [minLines] and [maxLines],
/// top-aligned placeholder. Same chrome law as [LaField].
class LaTextArea extends StatelessWidget {
  /// A growing multiline field.
  const LaTextArea({
    this.controller,
    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.minLines = 3,
    this.maxLines = 8,
    this.expands = false,
    this.style,
    this.prefix,
    this.suffix,
    this.errorText,
    this.counterText,
    this.maxLength,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.radius,
    this.fill,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    super.key,
  });

  /// Text controller.
  final TextEditingController? controller;

  /// Focus node.
  final FocusNode? focusNode;

  /// Hint text.
  final String? placeholder;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Submit callback.
  final ValueChanged<String>? onSubmitted;

  /// Grab focus on mount.
  final bool autofocus;

  /// Enabled flag.
  final bool enabled;

  /// Read-only flag.
  final bool readOnly;

  /// Line floor.
  final int? minLines;

  /// Line cap (null with [expands]).
  final int? maxLines;

  /// Fill the incoming height.
  final bool expands;

  /// Style override.
  final TextStyle? style;

  /// Leading slot.
  final Widget? prefix;

  /// Trailing slot.
  final Widget? suffix;

  /// Error line.
  final String? errorText;

  /// Counter text.
  final String? counterText;

  /// Hard length cap (drives the default counter).
  final int? maxLength;

  /// Inner inset.
  final EdgeInsetsGeometry padding;

  /// Corner radii.
  final BorderRadius? radius;

  /// Resting fill override.
  final Color? fill;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// IME action.
  final TextInputAction? textInputAction;

  /// Capitalization.
  final TextCapitalization textCapitalization;

  /// Formatters.
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(final BuildContext context) => LaField(
    controller: controller,
    focusNode: focusNode,
    placeholder: placeholder,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    autofocus: autofocus,
    enabled: enabled,
    readOnly: readOnly,
    minLines: minLines,
    maxLines: maxLines,
    expands: expands,
    style: style,
    prefix: prefix,
    suffix: suffix,
    errorText: errorText,
    counterText: counterText,
    maxLength: maxLength,
    padding: padding,
    radius: radius,
    fill: fill,
    keyboardType: keyboardType ?? TextInputType.multiline,
    textInputAction: textInputAction,
    textCapitalization: textCapitalization,
    inputFormatters: inputFormatters,
  );
}
