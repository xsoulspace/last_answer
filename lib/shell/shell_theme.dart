/// Shell design tokens (ADR 0024 chrome) — the design law (docs/DESIGN.md
/// §2–3) at Linear/Notion vocabulary: layered quiet surfaces, low-alpha
/// hairlines between regions only, a real type scale, one accent, quick
/// quiet motion. All colors derive from the app theme — this file invents
/// no palette, it only fixes the shell's constants.
library;

import 'package:flutter/material.dart';

abstract final class ShellTokens {
  /// Rail width (px) — the one fixed column of the shell.
  static const double railWidth = 272;

  /// Context column width (px) — the shell's right column
  /// (participants, topic, artifacts).
  static const double contextColumnWidth = 240;

  /// Tab strip height (px) — the pane stack's one quiet rule.
  static const double tabHeight = 36;

  /// Compact row height in lists (channel/DM tiles).
  static const double rowHeight = 34;

  /// Avatar diameter in list rows.
  static const double rowAvatar = 22;

  /// Avatar diameter beside messages.
  static const double messageAvatar = 30;

  /// Corner radius for fills (search field, selected rows, composer).
  static const double radius = 8;

  /// The role gutter for beats (DESIGN §3 reference: 52px).
  static const double messageGutter = 44;

  /// Hairline width (DESIGN §3).
  static const double hairline = 1;

  /// Micro-label (DESIGN §3, Linear vocabulary): sentence case, muted,
  /// one step down — no letterspaced small caps.
  static const double sectionLabelSize = 11;

  static const EdgeInsets sectionPadding = EdgeInsets.fromLTRB(14, 14, 14, 6);

  static const EdgeInsets rowPadding = EdgeInsets.symmetric(horizontal: 10);
}

/// Shell colors, derived from the ambient [ThemeData] each build — no
/// second palette beside the app's design system.
extension ShellColors on BuildContext {
  Color get shellHover =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.05);

  Color get shellSelected =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.09);

  Color get shellHairline => Theme.of(this).dividerColor;

  Color get shellMuted => Theme.of(this).colorScheme.onSurfaceVariant;

  Color get shellField =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.04);

  /// A raised surface one step of ink above the base (DESIGN §3 layered
  /// surfaces) — cards-on-canvas stay quiet without a border.
  Color get shellRaised =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.03);
}

/// The micro-label style (DESIGN §3): sentence case, muted, one step
/// down — hierarchy by tone and size, not by case tricks.
TextStyle shellSectionLabel(final BuildContext context) =>
    Theme.of(context).textTheme.labelMedium!.copyWith(
      fontSize: ShellTokens.sectionLabelSize,
      fontWeight: FontWeight.w500,
      color: context.shellMuted,
    );

/// The ONE depth declaration for floating layers (DESIGN §3):
/// miniwindows, menus, popovers — a soft offset shadow beside their
/// hairline, never a zero-offset halo, never an elevation ladder.
List<BoxShadow> shellFloatingShadow(final BuildContext context) => [
  BoxShadow(
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.14),
    offset: const Offset(0, 6),
    blurRadius: 20,
  ),
];

/// A compact hoverable/selectable row: the rail's one tile shape.
class ShellRow extends StatefulWidget {
  const ShellRow({
    required this.child,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.height = ShellTokens.rowHeight,
    super.key,
  });

  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double height;

  @override
  State<ShellRow> createState() => _ShellRowState();
}

class _ShellRowState extends State<ShellRow> {
  bool _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final fill = widget.selected
        ? context.shellSelected
        : _hovering
        ? context.shellHover
        : null;
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: ShellTokens.rowPadding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
