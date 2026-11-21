import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'motion.dart';
import 'squircle.dart';
import 'theme.dart';

/// The interactive state snapshot [LaPressable.childBuilder] receives — the
/// ONE place hover/focus/press/selected truth exists (the kit's answer to
/// "two hover systems").
@immutable
class LaPressState {
  /// Snapshot of the interaction state.
  const LaPressState({
    this.hovered = false,
    this.pressed = false,
    this.selected = false,
    this.focused = false,
    this.enabled = true,
  });

  /// Pointer is over the control.
  final bool hovered;

  /// Primary pointer is down inside the control.
  final bool pressed;

  /// The control is in its selected mode.
  final bool selected;

  /// The control holds focus.
  final bool focused;

  /// The control accepts interaction.
  final bool enabled;
}

/// The kit's keystone primitive: ONE hover/focus/press/disabled state
/// machine that paints the state layer (ink alpha over the ambient surface),
/// carries the keyboard-only focus ring (DESIGN.md v2 `ring` law — finally a
/// carrier), settles in 120 ms (v6 event motion) and scales to 0.98 on
/// press. Replaces InkWell, Material-wrapper hover hacks and every
/// hand-rolled MouseRegion+GestureDetector.
class LaPressable extends StatefulWidget {
  /// Wraps [child] with the full interaction state machine.
  const LaPressable({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.enabled = true,
    this.selected = false,
    this.radius,
    this.padding,
    this.margin,
    this.fill,
    this.border,
    this.hoverFill,
    this.pressedFill,
    this.selectedFill,
    this.overlayBase,
    this.showRing = true,
    this.focusNode,
    this.autofocus = false,
    this.scaleOnPress = true,
    this.cursor,
    this.onHoverChange,
    this.onFocusChange,
    this.semanticLabel,
    this.semanticsButton = true,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.childBuilder,
    this.shadows,
    this.ownFocus = true,
    super.key,
  });

  /// Builds from the live interaction state instead of a static [child] —
  /// how LaButton animates its foreground on hover.
  const LaPressable.builder({
    required this.childBuilder,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.enabled = true,
    this.selected = false,
    this.radius,
    this.padding,
    this.margin,
    this.fill,
    this.border,
    this.hoverFill,
    this.pressedFill,
    this.selectedFill,
    this.overlayBase,
    this.showRing = true,
    this.focusNode,
    this.autofocus = false,
    this.scaleOnPress = true,
    this.cursor,
    this.onHoverChange,
    this.onFocusChange,
    this.semanticLabel,
    this.semanticsButton = true,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.child,
    this.shadows,
    this.ownFocus = true,
    super.key,
  });

  /// The content.
  final Widget? child;

  /// State-driven content builder (takes precedence over [child]).
  final Widget Function(BuildContext context, LaPressState state)? childBuilder;

  /// Primary activation.
  final VoidCallback? onTap;

  /// Double-click activation.
  final VoidCallback? onDoubleTap;

  /// Long-press activation.
  final VoidCallback? onLongPress;

  /// Right-click / secondary activation (context menus).
  final VoidCallback? onSecondaryTap;

  /// False greys the control out and refuses gestures.
  final bool enabled;

  /// Selected mode (rows, toggled chips).
  final bool selected;

  /// Squircle corner radius; defaults to the theme control radius.
  final BorderRadius? radius;

  /// Inset inside the painted fill.
  final EdgeInsetsGeometry? padding;

  /// Space outside the painted fill.
  final EdgeInsetsGeometry? margin;

  /// Resting fill (null = transparent).
  final Color? fill;

  /// Resting hairline/stroke.
  final BorderSide? border;

  /// Explicit hover color (overrides the alpha law for this control).
  final Color? hoverFill;

  /// Explicit pressed color.
  final Color? pressedFill;

  /// Explicit selected color.
  final Color? selectedFill;

  /// The color the state-layer alphas derive from (defaults to theme ink;
  /// filled buttons pass their foreground so the overlay reads on the fill).
  final Color? overlayBase;

  /// Whether the keyboard focus ring may draw (v2 ring law).
  final bool showRing;

  /// External focus node (created internally when null).
  final FocusNode? focusNode;

  /// Grab focus on mount.
  final bool autofocus;

  /// v6 press settle: scale to 0.98 while pressed.
  final bool scaleOnPress;

  /// Pointer cursor override (defaults to click when interactive).
  final MouseCursor? cursor;

  /// Hover changes, for surfaces that reveal affordances on hover.
  final ValueChanged<bool>? onHoverChange;

  /// Focus changes.
  final ValueChanged<bool>? onFocusChange;

  /// Semantics label (falls through to the child's text when null).
  final String? semanticLabel;

  /// Announce as a button in semantics.
  final bool semanticsButton;

  /// Hit-test behavior for the gesture area.
  final HitTestBehavior hitTestBehavior;

  /// Shadows under the fill (floating chips).
  final List<BoxShadow>? shadows;

  /// False for hosts that manage their own focus node (text fields): skips
  /// the Focus/Shortcuts wrappers so the pressable is a pure paint + hover
  /// carrier and never competes for keyboard traversal.
  final bool ownFocus;

  @override
  State<LaPressable> createState() => _LaPressableState();
}

class _LaPressableState extends State<LaPressable> {
  bool _hover = false;
  bool _down = false;
  bool _focus = false;
  FocusNode? _internalNode;
  bool _keyboardMode = false;

  FocusNode get _node => widget.focusNode ?? (_internalNode ??= FocusNode());

  bool get _interactive =>
      widget.enabled &&
      (widget.onTap != null ||
          widget.onLongPress != null ||
          widget.onSecondaryTap != null ||
          widget.onDoubleTap != null);

  @override
  void initState() {
    super.initState();
    _keyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
    if (widget.ownFocus) {
      _node.addListener(_onFocus);
    }
  }

  @override
  void didUpdateWidget(final LaPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.ownFocus) {
        oldWidget.focusNode?.removeListener(_onFocus);
      }
      _internalNode?.dispose();
      _internalNode = null;
      if (widget.ownFocus) {
        _node.addListener(_onFocus);
        _focus = _node.hasFocus;
      }
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    if (widget.ownFocus) {
      _node.removeListener(_onFocus);
    }
    _internalNode?.dispose();
    super.dispose();
  }

  void _onHighlightMode(final FocusHighlightMode mode) {
    final keyboard = mode == FocusHighlightMode.traditional;
    if (keyboard != _keyboardMode) {
      setState(() => _keyboardMode = keyboard);
    }
  }

  void _onFocus() {
    final has = _node.hasFocus;
    if (has != _focus) {
      setState(() => _focus = has);
      widget.onFocusChange?.call(has);
    }
  }

  void _setHover(final bool value) {
    if (value == _hover) {
      return;
    }
    setState(() => _hover = value);
    widget.onHoverChange?.call(value);
  }

  void _setDown(final bool value) {
    if (value == _down) {
      return;
    }
    setState(() => _down = value);
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final radius = widget.radius ?? theme.controlRadius;
    final state = LaPressState(
      hovered: _hover && widget.enabled,
      pressed: _down && widget.enabled,
      selected: widget.selected,
      focused: _focus,
      enabled: widget.enabled,
    );
    final content =
        widget.childBuilder?.call(context, state) ??
        widget.child ??
        const SizedBox.shrink();

    // The ONE state-layer system: an animated ink-alpha overlay composited
    // over the resting fill, or an explicit state color when the host
    // overrides it. Animating the ALPHA (not a nullable Color) keeps the
    // implicit animation honest and the transitions consistent everywhere.
    final base = widget.overlayBase ?? theme.ink;
    Color? stateFill;
    var targetAlpha = 0.0;
    if (widget.enabled) {
      if (state.pressed) {
        stateFill = widget.pressedFill;
        targetAlpha = theme.pressedAlpha;
      } else if (widget.selected) {
        stateFill = widget.selectedFill;
        targetAlpha = theme.selectedAlpha;
      } else if (_hover) {
        stateFill = widget.hoverFill;
        targetAlpha = theme.hoverAlpha;
      }
    }
    if (stateFill != null) {
      targetAlpha = 0;
    }

    final ringVisible =
        widget.showRing && _focus && _keyboardMode && widget.enabled;

    final duration = laMotion(context, theme.motionFast);
    final reduced = laReducedMotion(context);
    final scale = !reduced && widget.scaleOnPress && state.pressed ? 0.98 : 1.0;

    Widget result = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetAlpha),
      duration: duration,
      curve: theme.motionCurve,
      builder: (context, alpha, child) => CustomPaint(
        painter: _PressablePainter(
          fill: stateFill ?? widget.fill,
          overlay: alpha > 0.001 ? base.withValues(alpha: alpha) : null,
          border: widget.border,
          radius: radius,
          exponent: theme.squircleExponent,
          shadows: widget.shadows,
          ringColor: ringVisible ? theme.accent : null,
          ringWidth: theme.ringWidth,
          ringOffset: theme.ringOffset,
        ),
        child: child,
      ),
      child: widget.padding == null
          ? content
          : Padding(padding: widget.padding!, child: content),
    );

    if (!reduced && widget.scaleOnPress) {
      result = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1, end: scale),
        duration: duration,
        curve: theme.motionCurve,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: result,
      );
    }

    result = MouseRegion(
      cursor: !widget.enabled
          ? MouseCursor.defer
          : widget.cursor ??
                (_interactive ? SystemMouseCursors.click : MouseCursor.defer),
      onEnter: (_) => _setHover(true),
      onExit: (_) {
        _setHover(false);
        _setDown(false);
      },
      child: GestureDetector(
        behavior: widget.hitTestBehavior,
        onTap: _interactive ? widget.onTap : null,
        onDoubleTap: widget.enabled ? widget.onDoubleTap : null,
        onLongPress: _interactive ? widget.onLongPress : null,
        onSecondaryTap: _interactive ? widget.onSecondaryTap : null,
        onTapDown: widget.enabled ? (_) => _setDown(true) : null,
        onTapUp: widget.enabled ? (_) => _setDown(false) : null,
        onTapCancel: widget.enabled ? () => _setDown(false) : null,
        child: result,
      ),
    );

    if (_interactive && widget.ownFocus) {
      result = Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: Actions(
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: result,
        ),
      );
    }

    if (widget.ownFocus) {
      result = Focus(
        focusNode: _node,
        autofocus: widget.autofocus,
        canRequestFocus: widget.enabled,
        child: result,
      );
    }

    result = Semantics(
      button: widget.semanticsButton && _interactive,
      enabled: widget.enabled ? null : false,
      selected: widget.selected ? true : null,
      label: widget.semanticLabel,
      child: result,
    );

    if (widget.margin != null) {
      result = Padding(padding: widget.margin!, child: result);
    }
    return result;
  }
}

class _PressablePainter extends CustomPainter {
  const _PressablePainter({
    required this.radius,
    required this.exponent,
    this.fill,
    this.overlay,
    this.border,
    this.shadows,
    this.ringColor,
    this.ringWidth = 2,
    this.ringOffset = 2,
  });

  final Color? fill;
  final Color? overlay;
  final BorderSide? border;
  final BorderRadius radius;
  final double exponent;
  final List<BoxShadow>? shadows;
  final Color? ringColor;
  final double ringWidth;
  final double ringOffset;

  @override
  void paint(final Canvas canvas, final Size size) {
    final rect = Offset.zero & size;
    final path = squirclePath(rect, borderRadius: radius, exponent: exponent);
    if (shadows != null) {
      for (final shadow in shadows!) {
        canvas.drawPath(path.shift(shadow.offset), shadow.toPaint());
      }
    }
    if (fill != null && fill!.a > 0) {
      canvas.drawPath(path, Paint()..color = fill!);
    }
    if (overlay != null) {
      canvas.drawPath(path, Paint()..color = overlay!);
    }
    if (border != null &&
        border!.style != BorderStyle.none &&
        border!.width > 0) {
      final half = border!.width / 2;
      canvas.drawPath(
        squirclePath(
          rect.deflate(half),
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(
              (radius.topLeft.x - half).clamp(0.0, double.infinity),
              (radius.topLeft.y - half).clamp(0.0, double.infinity),
            ),
            topRight: Radius.elliptical(
              (radius.topRight.x - half).clamp(0.0, double.infinity),
              (radius.topRight.y - half).clamp(0.0, double.infinity),
            ),
            bottomLeft: Radius.elliptical(
              (radius.bottomLeft.x - half).clamp(0.0, double.infinity),
              (radius.bottomLeft.y - half).clamp(0.0, double.infinity),
            ),
            bottomRight: Radius.elliptical(
              (radius.bottomRight.x - half).clamp(0.0, double.infinity),
              (radius.bottomRight.y - half).clamp(0.0, double.infinity),
            ),
          ),
          exponent: exponent,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = border!.width
          ..color = border!.color,
      );
    }
    if (ringColor != null) {
      final grow = ringOffset + ringWidth / 2;
      final growRadius = Radius.circular(grow);
      canvas.drawPath(
        squirclePath(
          rect.inflate(grow),
          borderRadius: BorderRadius.only(
            topLeft: radius.topLeft + growRadius,
            topRight: radius.topRight + growRadius,
            bottomLeft: radius.bottomLeft + growRadius,
            bottomRight: radius.bottomRight + growRadius,
          ),
          exponent: exponent,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth
          ..color = ringColor!,
      );
    }
  }

  @override
  bool shouldRepaint(final _PressablePainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.overlay != overlay ||
      oldDelegate.border != border ||
      oldDelegate.radius != radius ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.shadows != shadows;
}

/// Draws the keyboard focus ring (v2 `ring` law: 2 px offset accent outline,
/// keyboard travel only, never on hover) around ANY child — for surfaces that
/// manage their own [FocusNode] outside [LaPressable].
class LaFocusRing extends StatefulWidget {
  /// Rings [child] while [focusNode] holds keyboard focus.
  const LaFocusRing({
    required this.child,
    this.focusNode,
    this.radius,
    super.key,
  });

  /// The ringed content.
  final Widget child;

  /// The node whose focus drives the ring (required to observe).
  final FocusNode? focusNode;

  /// Corner radius; defaults to the theme control radius.
  final BorderRadius? radius;

  @override
  State<LaFocusRing> createState() => _LaFocusRingState();
}

class _LaFocusRingState extends State<LaFocusRing> {
  bool _keyboardMode = false;

  @override
  void initState() {
    super.initState();
    _keyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
    widget.focusNode?.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(final LaFocusRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocus);
      widget.focusNode?.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    widget.focusNode?.removeListener(_onFocus);
    super.dispose();
  }

  void _onHighlightMode(final FocusHighlightMode mode) {
    final keyboard = mode == FocusHighlightMode.traditional;
    if (keyboard != _keyboardMode) {
      setState(() => _keyboardMode = keyboard);
    }
  }

  void _onFocus() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final active = _keyboardMode && (widget.focusNode?.hasFocus ?? false);
    return CustomPaint(
      foregroundPainter: active
          ? _PressablePainter(
              radius: widget.radius ?? theme.controlRadius,
              exponent: theme.squircleExponent,
              ringColor: theme.accent,
              ringWidth: theme.ringWidth,
              ringOffset: theme.ringOffset,
            )
          : null,
      child: widget.child,
    );
  }
}
