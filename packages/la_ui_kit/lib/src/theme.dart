import 'package:flutter/widgets.dart';

/// L0 tokens — DESIGN.md §Visual system as kit constants. The app registers
/// ONE [LaUiTheme] via [LaUiThemeProvider] (fed by the zinc `LaPalette`);
/// kit widgets read it through [LaUiTheme.of]. The dark/light factories
/// carry the DESIGN.md v2 reference values so the kit also works standalone
/// (tests, previews).
///
/// The kit invents no second palette and no second hover system: every state
/// fill derives from [hoverAlpha] / [pressedAlpha] / [selectedAlpha] over the
/// ambient surface or the component's own foreground ([stateOverlayBase]).
@immutable
class LaUiTheme {
  /// Builds a theme from explicit tokens; non-color knobs default to the
  /// DESIGN.md constants. The app uses this to feed the existing palette.
  const LaUiTheme({
    required this.isDark,
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceOverlay,
    required this.ink,
    required this.inkMuted,
    required this.inkQuiet,
    required this.rule,
    required this.accent,
    required this.onAccent,
    required this.danger,
    required this.onDanger,
    required this.caution,
    required this.success,
    this.fontFamily = 'Inter',
    this.monoFontFamily = 'monospace',
    this.hoverAlpha = 0.05,
    this.pressedAlpha = 0.09,
    this.selectedAlpha = 0.09,
    this.fieldAlpha = 0.04,
    this.radiusControl = 8,
    this.radiusSmall = 6,
    this.radiusFloating = 11,
    this.squircleExponent = 4,
    this.ringWidth = 2,
    this.ringOffset = 2,
    this.motionFast = const Duration(milliseconds: 120),
    this.motionSettle = const Duration(milliseconds: 150),
    this.motionOverlay = const Duration(milliseconds: 140),
    this.motionCurve = Curves.easeOutCubic,
    this.scrim = const Color(0x99000000),
  });

  /// DESIGN.md v2 dark reference (zinc + glade accent).
  factory LaUiTheme.dark() => const LaUiTheme(
    isDark: true,
    canvas: Color(0xFF09090B),
    surface: Color(0xFF18181B),
    surfaceRaised: Color(0xFF27272A),
    surfaceOverlay: Color(0xFF323236),
    ink: Color(0xFFF4F4F5),
    inkMuted: Color(0xFFA1A1AA),
    inkQuiet: Color(0xFF71717A),
    rule: Color(0xFF27272A),
    accent: Color(0xFF8DDCC2),
    onAccent: Color(0xFF0B1F18),
    danger: Color(0xFFF87171),
    onDanger: Color(0xFF2A0E0E),
    caution: Color(0xFFFBBF24),
    success: Color(0xFF8DDCC2),
  );

  /// DESIGN.md v2 light reference — first-class, equal hierarchy.
  factory LaUiTheme.light() => const LaUiTheme(
    isDark: false,
    canvas: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF4F4F5),
    surfaceOverlay: Color(0xFFE9E9EC),
    ink: Color(0xFF18181B),
    inkMuted: Color(0xFF52525B),
    inkQuiet: Color(0xFF71717A),
    rule: Color(0xFFE4E4E7),
    accent: Color(0xFF176D58),
    onAccent: Color(0xFFFFFFFF),
    danger: Color(0xFFDC2626),
    onDanger: Color(0xFFFFFFFF),
    caution: Color(0xFFB45309),
    success: Color(0xFF176D58),
    fieldAlpha: 0.03,
  );

  /// Dark is the reference theme (DESIGN.md v2).
  final bool isDark;

  // ── palette (DESIGN.md v2 token table) ───────────────────────────
  /// App and canvas background.
  final Color canvas;

  /// Pane and navigator surfaces.
  final Color surface;

  /// Selected rows and quiet raised regions.
  final Color surfaceRaised;

  /// Menus, popovers, floating windows.
  final Color surfaceOverlay;

  /// Primary text and icons.
  final Color ink;

  /// Secondary labels and descriptions.
  final Color inkMuted;

  /// Timestamps and tertiary metadata.
  final Color inkQuiet;

  /// Region boundaries and separators (the hairline).
  final Color rule;

  /// The glade — focus, active marker, primary action.
  final Color accent;

  /// Ink that reads on [accent].
  final Color onAccent;

  /// Destructive or failed state.
  final Color danger;

  /// Ink that reads on [danger] in both themes.
  final Color onDanger;

  /// Pending or attention-needed state.
  final Color caution;

  /// Confirmed success.
  final Color success;

  /// Dialog/toast barrier.
  final Color scrim;

  // ── state layers (ONE hover system) ──────────────────────────────
  /// Hover fill: ink (or the component's foreground) at this alpha.
  final double hoverAlpha;

  /// Pressed fill alpha (v6: paired with the 0.98 press settle).
  final double pressedAlpha;

  /// Selected-row fill alpha.
  final double selectedAlpha;

  /// The resting input fill (Linear's borderless-field law).
  final double fieldAlpha;

  // ── geometry (v6 squircle law) ───────────────────────────────────
  /// Controls, fields, rows.
  final double radiusControl;

  /// Small tokens (pills, checkboxes).
  final double radiusSmall;

  /// Floating windows, menus, dialogs.
  final double radiusFloating;

  /// Superellipse exponent (4 ≈ the Discord/iOS continuous corner).
  final double squircleExponent;

  /// Focus-ring stroke width (DESIGN.md v2 `ring`).
  final double ringWidth;

  /// Focus-ring offset from the control edge.
  final double ringOffset;

  // ── motion (v6: event-driven chrome motion) ──────────────────────
  /// Hover/press color settles.
  final Duration motionFast;

  /// Selection/thumb/panel settles.
  final Duration motionSettle;

  /// Overlay entry (dialog scale+fade, menu, toast slide).
  final Duration motionOverlay;

  /// The one chrome curve.
  final Curve motionCurve;

  // ── type (DESIGN.md §Typography, bundled Inter) ──────────────────
  /// The interface sans — bundled by the app (SIL OFL).
  final String fontFamily;

  /// Restrained monospace for code, paths and measured values.
  final String monoFontFamily;

  // The decoration belt: every kit style carries `decoration: none` so it
  // is self-contained — MaterialApp's root error style (the yellow double
  // underline, 'fallback style' debugLabel) can never bleed through a
  // merge, even where a float misses its DefaultTextStyle (the second
  // belt under the surface wraps; see LaDialog.build).
  //
  /// 11/16 w500 — timestamps, quiet state labels.
  TextStyle get micro => TextStyle(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: inkQuiet,
    decoration: TextDecoration.none,
  );

  /// 12/17 w400 — navigator metadata, controls.
  TextStyle get compact => TextStyle(
    fontSize: 12,
    height: 17 / 12,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: inkMuted,
    decoration: TextDecoration.none,
  );

  /// 14/20 w400 — conversation and document text.
  TextStyle get body => TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: ink,
    decoration: TextDecoration.none,
  );

  /// 15/21 w600 — pane title, selected actor.
  TextStyle get emphasis => TextStyle(
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: ink,
    decoration: TextDecoration.none,
  );

  /// 18/24 w600 — surface heading.
  TextStyle get section => TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: ink,
    decoration: TextDecoration.none,
  );

  /// 24/30 w600 — empty-state or settings title only.
  TextStyle get display => TextStyle(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: ink,
    decoration: TextDecoration.none,
  );

  /// Small button label (sm size, 28 px controls).
  TextStyle get buttonSm => TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    decoration: TextDecoration.none,
  );

  /// Default button label (md size, 34 px controls — the row grid).
  TextStyle get buttonMd => TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    decoration: TextDecoration.none,
  );

  /// Menu/dialog control label.
  TextStyle get control => TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: ink,
    decoration: TextDecoration.none,
  );

  /// Code, paths, measured values.
  TextStyle get mono => TextStyle(
    fontSize: 12,
    height: 17 / 12,
    fontFamily: monoFontFamily,
    color: inkMuted,
    decoration: TextDecoration.none,
  );

  // ── derived ──────────────────────────────────────────────────────
  /// The resting field fill (ink at [fieldAlpha]).
  Color get fieldFill => ink.withValues(alpha: fieldAlpha);

  /// A hover fill over any surface (the ONE hover system).
  Color hoverFill([Color? base]) => (base ?? ink).withValues(alpha: hoverAlpha);

  /// A pressed/selected fill over any surface.
  Color pressedFill([Color? base]) =>
      (base ?? ink).withValues(alpha: pressedAlpha);

  /// The selected-row fill.
  Color selectedFill([Color? base]) =>
      (base ?? ink).withValues(alpha: selectedAlpha);

  /// The ONE depth declaration for floating layers (DESIGN.md §Elevation):
  /// a soft offset shadow beside the hairline — never a halo, never a
  /// ladder.
  List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: ink.withValues(alpha: 0.14),
      offset: const Offset(0, 6),
      blurRadius: 20,
    ),
  ];

  /// The control corner radius as a [BorderRadius] (squircle-painted by the
  /// kit shapes, v6).
  BorderRadius get controlRadius => BorderRadius.circular(radiusControl);

  /// The small-token corner radius.
  BorderRadius get smallRadius => BorderRadius.circular(radiusSmall);

  /// The floating-layer corner radius.
  BorderRadius get floatingRadius => BorderRadius.circular(radiusFloating);

  /// Looks up the ambient theme; falls back to the platform-brightness
  /// reference so kit widgets also render standalone (tests, previews).
  static LaUiTheme of(final BuildContext context) {
    final provided = context
        .dependOnInheritedWidgetOfExactType<LaUiThemeProvider>()
        ?.theme;
    if (provided != null) {
      return provided;
    }
    final brightness =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.dark;
    return brightness == Brightness.light ? _lightFallback : _darkFallback;
  }

  static final LaUiTheme _darkFallback = LaUiTheme.dark();
  static final LaUiTheme _lightFallback = LaUiTheme.light();
}

/// Registers the app's [LaUiTheme] for the subtree — mounted ONCE above the
/// shell (the app feeds it from the existing zinc `LaPalette`).
class LaUiThemeProvider extends InheritedWidget {
  /// Wraps [child] with [theme].
  const LaUiThemeProvider({
    required this.theme,
    required super.child,
    super.key,
  });

  /// The tokens for the subtree.
  final LaUiTheme theme;

  @override
  bool updateShouldNotify(final LaUiThemeProvider oldWidget) =>
      !identical(oldWidget.theme, theme);
}

/// Sugar: `context.laUi` reads the ambient kit theme.
extension LaUiContext on BuildContext {
  /// The ambient [LaUiTheme].
  LaUiTheme get laUi => LaUiTheme.of(this);
}
