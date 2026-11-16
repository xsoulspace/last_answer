import 'package:flutter/widgets.dart';

import 'package:la_ui/src/pressable.dart';
import 'package:la_ui/src/theme.dart';

/// The kit list row — ShellRow generalized to the full anatomy
/// (leading / title / meta / trailing), 34 px compact desktop metric, 44 px
/// touch metric. Replaces ListTile, HoverableListTile and hand-rolled rows.
class LaRow extends StatelessWidget {
  /// A hoverable/selectable list row.
  const LaRow({
    this.leading,
    this.title,
    this.titleText,
    this.meta,
    this.metaText,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.selected = false,
    this.enabled = true,
    this.height = 34,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.radius,
    this.margin = const EdgeInsets.symmetric(horizontal: 8),
    this.showRing = true,
    this.child,
    super.key,
  });

  /// Free-form row content (bypasses the leading/title/meta anatomy).
  const LaRow.custom({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.selected = false,
    this.enabled = true,
    this.height = 34,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.radius,
    this.margin = const EdgeInsets.symmetric(horizontal: 8),
    this.showRing = true,
    super.key,
  }) : leading = null,
       title = null,
       titleText = null,
       meta = null,
       metaText = null,
       trailing = null;

  /// Leading widget (avatar, creature, icon tile).
  final Widget? leading;

  /// Title widget.
  final Widget? title;

  /// Title as plain text (body style, ellipsized).
  final String? titleText;

  /// Secondary-line widget under the title (rows may grow for it).
  final Widget? meta;

  /// Secondary line as plain text (compact muted style).
  final String? metaText;

  /// Trailing widget (badge, chevron, hover cluster).
  final Widget? trailing;

  /// Activation.
  final VoidCallback? onTap;

  /// Long-press activation.
  final VoidCallback? onLongPress;

  /// Right-click activation (context menus).
  final VoidCallback? onSecondaryTap;

  /// Selected fill (the kit's selectedAlpha law).
  final bool selected;

  /// False greys the row out.
  final bool enabled;

  /// Row height; 34 compact, 44 touch (null = content-sized).
  final double? height;

  /// Inset inside the fill.
  final EdgeInsetsGeometry padding;

  /// Corner radius override.
  final BorderRadius? radius;

  /// Space outside the fill.
  final EdgeInsetsGeometry margin;

  /// Whether the keyboard focus ring may draw.
  final bool showRing;

  /// Free-form content for [LaRow.custom].
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final hasMeta = meta != null || metaText != null;

    Widget content;
    if (child != null) {
      content = child!;
    } else {
      final titleWidget =
          title ??
          (titleText != null
              ? Text(
                  titleText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.body.copyWith(
                    fontSize: 13,
                    color: enabled ? theme.ink : theme.inkQuiet,
                  ),
                )
              : null);
      final metaWidget =
          meta ??
          (metaText != null
              ? Text(
                  metaText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.compact.copyWith(
                    color: enabled ? theme.inkMuted : theme.inkQuiet,
                  ),
                )
              : null);
      content = Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: hasMeta && (titleWidget != null || metaWidget != null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [?titleWidget, ?metaWidget],
                  )
                : titleWidget ?? const SizedBox.shrink(),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      );
    }

    return LaPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      selected: selected,
      enabled: enabled,
      showRing: showRing,
      radius: radius ?? theme.controlRadius,
      margin: margin,
      scaleOnPress: false,
      padding: padding,
      child: SizedBox(
        height: hasMeta && height == 34 ? null : height,
        child: content,
      ),
    );
  }
}
