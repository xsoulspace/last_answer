import 'package:flutter/widgets.dart';

import 'squircle.dart';
import 'theme.dart';

/// The v2 pill-exception token as a first-class component: a compact status
/// token whose SHAPE conveys a real state (kind labels, counts, flags).
/// Not a general-purpose container.
class LaPill extends StatelessWidget {
  /// A quiet token pill.
  const LaPill({
    required this.label,
    this.icon,
    this.color,
    this.background,
    this.onTap,
    this.radius,
    super.key,
  });

  /// Token text (micro style).
  final String label;

  /// Optional leading glyph (12 px).
  final Widget? icon;

  /// Text/icon color override (defaults to muted ink).
  final Color? color;

  /// Fill override (defaults to surfaceRaised).
  final Color? background;

  /// Optional activation.
  final VoidCallback? onTap;

  /// Radius override (defaults to the small token radius).
  final BorderRadius? radius;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final fg = color ?? theme.inkMuted;
    Widget pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 7 : 5,
        vertical: 2,
      ),
      decoration: ShapeDecoration(
        color: background ?? theme.surfaceRaised,
        shape: SquircleShape(
          radius: radius ?? theme.smallRadius,
          exponent: theme.squircleExponent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme.merge(
              data: IconThemeData(size: 12, color: fg),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(label, style: theme.micro.copyWith(color: fg)),
        ],
      ),
    );
    if (onTap != null) {
      pill = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: pill,
      );
    }
    return pill;
  }
}

/// The unread/count badge — accent fill, tabular numerals, the rail's pill
/// (v2's sanctioned exception).
class LaBadge extends StatelessWidget {
  /// A count badge; renders nothing below 1.
  const LaBadge({
    required this.count,
    this.color,
    this.onColor,
    this.max = 99,
    super.key,
  });

  /// The count; 0 hides the badge.
  final int count;

  /// Fill override (defaults to accent).
  final Color? color;

  /// Ink on the fill (defaults to onAccent).
  final Color? onColor;

  /// Render ">max" beyond this.
  final int max;

  @override
  Widget build(final BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    final theme = context.laUi;
    final label = count > max ? '$max+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: ShapeDecoration(
        color: color ?? theme.accent,
        shape: const SquircleShape(),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          height: 14 / 10,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
          fontFamily: theme.fontFamily,
          color: onColor ?? theme.onAccent,
        ),
      ),
    );
  }
}
