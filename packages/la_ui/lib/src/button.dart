import 'package:flutter/widgets.dart';

import 'package:la_ui/src/pressable.dart';
import 'package:la_ui/src/theme.dart';
import 'package:la_ui/src/tooltip.dart';

/// The shadcn button grammar, on the 34 px row grid (sm = 28 px).
enum LaButtonVariant {
  /// Accent fill — the ONE primary action per surface.
  primary,

  /// Raised surface + hairline — the default secondary.
  secondary,

  /// Transparent, muted ink earning a hover tint — chrome icon affordances
  /// ("buttons stop being boxes", de-material plan §2).
  ghost,

  /// Transparent with a hairline — form neutrals.
  outline,

  /// Danger fill — destructive confirmation.
  destructive,

  /// Danger ink on transparent — destructive lists/rows.
  destructiveGhost,

  /// Accent ink, no fill — inline text actions.
  link,
}

/// Control heights: md = 34 (the row grid), sm = 28.
enum LaButtonSize { sm, md }

/// The kit button. Replaces TextButton/FilledButton/ElevatedButton/
/// OutlinedButton/IconButton with ONE component: compact metrics matched to
/// the 34 px row grid, squircle corners (v6), state-layer hover from
/// [LaPressable], the keyboard focus ring, and a 0.98 press settle (v6
/// event motion).
class LaButton extends StatelessWidget {
  /// A label and/or icon button.
  const LaButton({
    this.label,
    this.child,
    this.icon,
    this.trailing,
    this.onPressed,
    this.variant = LaButtonVariant.secondary,
    this.size = LaButtonSize.md,
    this.expand = false,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.dense = false,
    super.key,
  });

  /// An icon-only button (the IconButton replacement): square metrics.
  const LaButton.icon({
    required Widget this.icon,
    this.onPressed,
    this.variant = LaButtonVariant.ghost,
    this.size = LaButtonSize.md,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.dense = false,
    this.expand = false,
    super.key,
  }) : label = null,
       child = null,
       trailing = null;

  /// Text label (styled by the kit).
  final String? label;

  /// Custom content (takes precedence over [label]; keeps existing call
  /// sites mechanical — `child: Text(...)` still works).
  final Widget? child;

  /// Leading icon widget.
  final Widget? icon;

  /// Trailing widget (chevrons, counts).
  final Widget? trailing;

  /// Activation; null disables.
  final VoidCallback? onPressed;

  /// Visual grammar.
  final LaButtonVariant variant;

  /// Height/padding step.
  final LaButtonSize size;

  /// Fill the incoming width.
  final bool expand;

  /// Optional LaTooltip message.
  final String? tooltip;

  /// External focus node.
  final FocusNode? focusNode;

  /// Grab focus on mount.
  final bool autofocus;

  /// Tighter horizontal padding (dense toolbars).
  final bool dense;

  bool get _iconOnly =>
      icon != null && label == null && child == null && trailing == null;

  double get _height => switch (size) {
    LaButtonSize.sm => 28,
    LaButtonSize.md => 34,
  };

  EdgeInsets get _padding {
    if (_iconOnly) {
      return EdgeInsets.zero;
    }
    final h = switch ((size, dense)) {
      (LaButtonSize.sm, _) => 8.0,
      (LaButtonSize.md, true) => 8.0,
      (LaButtonSize.md, false) => 12.0,
    };
    return EdgeInsets.symmetric(horizontal: h);
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final enabled = onPressed != null;

    final (Color fg, Color? bg, BorderSide? border) = switch (variant) {
      LaButtonVariant.primary => (theme.onAccent, theme.accent, null),
      LaButtonVariant.secondary => (
        theme.ink,
        theme.surfaceRaised,
        BorderSide(color: theme.rule),
      ),
      LaButtonVariant.ghost => (theme.inkMuted, null, null),
      LaButtonVariant.outline => (
        theme.ink,
        null,
        BorderSide(color: theme.rule),
      ),
      LaButtonVariant.destructive => (theme.onDanger, theme.danger, null),
      LaButtonVariant.destructiveGhost => (theme.danger, null, null),
      LaButtonVariant.link => (theme.accent, null, null),
    };

    final labelStyle =
        (size == LaButtonSize.sm ? theme.buttonSm : theme.buttonMd).copyWith(
          color: enabled ? fg : theme.inkQuiet,
        );

    Widget content =
        child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: size == LaButtonSize.sm ? 14 : 16,
                  color: enabled ? fg : theme.inkQuiet,
                ),
                child: icon!,
              ),
              if (label != null || trailing != null) const SizedBox(width: 6),
            ],
            if (label != null)
              Text(
                label!,
                style: labelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ],
        );

    if (!enabled && variant != LaButtonVariant.ghost) {
      content = Opacity(opacity: 0.5, child: content);
    }

    Widget button = LaPressable.builder(
      onTap: onPressed,
      enabled: enabled,
      focusNode: focusNode,
      autofocus: autofocus,
      overlayBase: variant == LaButtonVariant.primary
          ? theme.onAccent
          : variant == LaButtonVariant.destructive
          ? theme.onDanger
          : theme.ink,
      fill: enabled ? bg : null,
      border: enabled
          ? border
          : border == null
          ? null
          : BorderSide(color: theme.rule),
      padding: _padding,
      childBuilder: (context, state) {
        // Ghost variants brighten their foreground on hover (the de-material
        // plan's "bare glyph earning a hover tint").
        Color effectiveFg = fg;
        if (enabled && state.hovered) {
          effectiveFg = switch (variant) {
            LaButtonVariant.ghost => theme.ink,
            LaButtonVariant.link => theme.accent,
            _ => fg,
          };
        }
        final style = labelStyle.copyWith(
          color: enabled ? effectiveFg : theme.inkQuiet,
        );

        return SizedBox(
          height: _height,
          width: _iconOnly ? _height : (expand ? double.infinity : null),
          child: Center(
            widthFactor: expand ? null : 1,
            child: DefaultTextStyle(
              style: style,
              child: IconTheme.merge(
                data: IconThemeData(
                  color: enabled ? effectiveFg : theme.inkQuiet,
                ),
                child: content,
              ),
            ),
          ),
        );
      },
    );

    if (expand && !_iconOnly) {
      button = SizedBox(width: double.infinity, child: button);
    }
    if (tooltip != null) {
      button = LaTooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
