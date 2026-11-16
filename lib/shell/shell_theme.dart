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

/// Shell colors, derived from the ambient kit tokens (`context.laUi`,
/// DESIGN.md v6 component-carrier law) each build — no second palette
/// beside the app's design system, and no hand-rolled hover system: the
/// fills ARE the kit's one state-layer alphas. Names are frozen — call
/// sites across the shell depend on them.
extension ShellColors on BuildContext {
  Color get shellHover => laUi.hoverFill();

  Color get shellSelected => laUi.selectedFill();

  Color get shellHairline => laUi.rule;

  Color get shellMuted => laUi.inkMuted;

  Color get shellField => laUi.fieldFill;

  /// A raised surface one step of ink above the base (DESIGN §3 layered
  /// surfaces) — cards-on-canvas stay quiet without a border.
  Color get shellRaised => laUi.surfaceRaised;
}

/// The micro-label style (DESIGN §3): sentence case, muted, one step
/// down — hierarchy by tone and size, not by case tricks. The kit's
/// `micro` token IS this role (11/16 w500).
TextStyle shellSectionLabel(final BuildContext context) =>
    context.laUi.micro.copyWith(color: context.shellMuted);

/// The ONE depth declaration for floating layers (DESIGN §3):
/// miniwindows, menus, popovers — a soft offset shadow beside their
/// hairline, never a zero-offset halo, never an elevation ladder.
/// Owned by the kit (v6): `context.laUi.floatingShadow`.
List<BoxShadow> shellFloatingShadow(final BuildContext context) =>
    context.laUi.floatingShadow;

/// A compact hoverable/selectable row: the rail's one tile shape. A thin
/// facade over the kit's [LaPressable] (v6 component-carrier law) — the
/// hover/selected/press fills come from the kit's ONE state machine with
/// its 120 ms settle and squircle paint; this file no longer hand-rolls
/// MouseRegion+GestureDetector state. The public API is frozen: call
/// sites pass child/selected/onTap/onLongPress/height/padding.
class ShellRow extends StatelessWidget {
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
  Widget build(final BuildContext context) => Padding(
    // The row's quiet side margin (the fill never touches the column edge).
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: LaPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected,
      radius: BorderRadius.circular(ShellTokens.radius),
      child: SizedBox(
        height: height,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}
