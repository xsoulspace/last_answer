/// Shell design tokens (ADR 0024 chrome) — the design law (docs/DESIGN.md
/// §2–3) at Linear/Notion vocabulary: layered quiet surfaces, low-alpha
/// hairlines between regions only, a real type scale, one accent, quick
/// quiet motion. All colors derive from the app theme — this file invents
/// no palette, it only fixes the shell's constants.
library;


import 'package:lastanswer/common_imports.dart';

abstract final class ShellTokens {
  /// The action bar's width (px) — the Discord-law rail: rounded-square
  /// kind icons, unread pips, active pip; the persistent room list is
  /// retired (opening lives in the + picker and the palette).
  static const double actionBarWidth = 56;

  /// One action-bar kind button (mockup: 40px rounded square).
  static const double actionButtonSize = 40;

  /// The kind button's corner radii: resting → hover/active (the
  /// Discord squircle settle, 120ms).
  static const double actionButtonRadius = 14;
  static const double actionButtonRadiusActive = 12;

  /// Context column width (px) — a general narrow-column constant
  /// (tests and side panes); the retired WAVE 5 dock left it behind.
  static const double contextColumnWidth = 240;

  /// The tab strip's row height (px) — ONE chrome row per pane group
  /// (DESIGN.md v2 chrome budget).
  static const double stripHeight = 34;

  /// The tab pill's height (px) — rounded compact tabs (v2 law: 27px,
  /// radius 8, the only chrome up top).
  static const double tabHeight = 27;

  /// The tab pill's corner radius (v2 law).
  static const double tabRadius = 8;

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
/// second palette beside the app's design system. Phase 0: the hairline and
/// muted roles read the real tokens ([LaThemeExtension]); the hover/selected
/// fills stay alpha steps of ink over whatever surface they sit on.
extension ShellColors on BuildContext {
  Color get shellHover => la.ink.withValues(alpha: 0.05);

  Color get shellSelected => la.ink.withValues(alpha: 0.09);

  Color get shellHairline => la.rule;

  Color get shellMuted => la.inkMuted;

  Color get shellField => la.ink.withValues(alpha: 0.04);

  /// A raised surface one step of ink above the base (DESIGN §3 layered
  /// surfaces) — cards-on-canvas stay quiet without a border.
  Color get shellRaised => la.surfaceRaised;
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
    color: context.la.ink.withValues(alpha: 0.14),
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
    this.padding = ShellTokens.rowPadding,
    super.key,
  });

  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double height;

  /// Horizontal inset inside the row's fill; the compact rail tightens
  /// it so identity marks fit the icon column (phase 1b).
  final EdgeInsetsGeometry padding;

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
          padding: widget.padding,
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
