part of 'theme.dart';

/// DESIGN.md §Visual system AS CODE — the single source of truth for the
/// Last Answer palette, geometry and type scale. Every widget color in the
/// app derives from these tokens through [LaThemeExtension]; nothing invents
/// a hex value beside this file (phase 4 sweeps the legacy leaks).
///
/// v2 (2026-11-08, owner-approved mockup gate): the zinc-family neutral
/// palette — the shadcn discipline, warmless grays that make content the
/// only color — with the glade green accent kept as the one signature hue.
/// Dark is the inspector-friendly reference; light is first-class with
/// equal hierarchy.
abstract final class LaTokens {
  LaTokens._();

  // ── dark reference (DESIGN.md v2 palette table) ──────────────────
  static const Color darkCanvas = Color(0xFF09090B);
  static const Color darkSurface = Color(0xFF18181B);
  static const Color darkSurfaceRaised = Color(0xFF27272A);
  static const Color darkSurfaceOverlay = Color(0xFF323236);
  static const Color darkInk = Color(0xFFF4F4F5);
  static const Color darkInkMuted = Color(0xFFA1A1AA);
  static const Color darkInkQuiet = Color(0xFF71717A);
  static const Color darkRule = Color(0xFF27272A);
  static const Color darkAccent = Color(0xFF8DDCC2);
  static const Color darkOnAccent = Color(0xFF0B1F18);
  static const Color darkDanger = Color(0xFFF87171);
  static const Color darkCaution = Color(0xFFFBBF24);

  // ── light reference (DESIGN.md v2 palette table) ─────────────────
  static const Color lightCanvas = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFF4F4F5);
  static const Color lightSurfaceOverlay = Color(0xFFE9E9EC);
  static const Color lightInk = Color(0xFF18181B);
  static const Color lightInkMuted = Color(0xFF52525B);
  static const Color lightInkQuiet = Color(0xFF71717A);
  static const Color lightRule = Color(0xFFE4E4E7);
  static const Color lightAccent = Color(0xFF176D58);
  static const Color lightOnAccent = Color(0xFFFFFFFF);
  static const Color lightDanger = Color(0xFFDC2626);
  static const Color lightCaution = Color(0xFFB45309);

  // ── geometry (DESIGN.md §Spacing and geometry) ────────────────────
  /// Base spacing unit; common steps 4, 8, 12, 16, 24, 32.
  static const double unit = 4;

  /// Fills: search field, selected rows, composer.
  static const double radius = 8;

  /// Floating windows and anchored menus.
  static const double radiusFloating = 11;

  /// Region separators: one-pixel hairline, between meaningful regions only.
  static const double hairline = 1;

  /// Navigator rows.
  static const double rowHeight = 34;

  /// Touch platforms' minimum interactive target.
  static const double touchTarget = 44;

  // ── type scale (DESIGN.md §Typography) ────────────────────────────
  /// Timestamps, quiet state labels.
  static const TextStyle micro = TextStyle(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
  );

  /// Navigator metadata, controls.
  static const TextStyle compact = TextStyle(
    fontSize: 12,
    height: 17 / 12,
    fontWeight: FontWeight.w400,
  );

  /// Conversation and document text.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  /// Pane title, selected actor.
  static const TextStyle emphasis = TextStyle(
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w600,
  );

  /// Surface heading.
  static const TextStyle section = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  /// Empty-state or settings title only.
  static const TextStyle display = TextStyle(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
  );

  /// The one restrained monospace: code, paths, measured values.
  static const String monoFamily = 'Menlo';

  /// A mono style for data rows (spend, timings, commands).
  static TextStyle mono(final double size, final Color color) => TextStyle(
    fontFamily: monoFamily,
    fontSize: size,
    height: (size * 1.45) / size,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// One brightness' resolved palette.
final class LaPalette {
  const LaPalette({
    required this.brightness,
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
    required this.caution,
  });

  factory LaPalette.of(final Brightness brightness) =>
      brightness == Brightness.dark
      ? const LaPalette(
          brightness: Brightness.dark,
          canvas: LaTokens.darkCanvas,
          surface: LaTokens.darkSurface,
          surfaceRaised: LaTokens.darkSurfaceRaised,
          surfaceOverlay: LaTokens.darkSurfaceOverlay,
          ink: LaTokens.darkInk,
          inkMuted: LaTokens.darkInkMuted,
          inkQuiet: LaTokens.darkInkQuiet,
          rule: LaTokens.darkRule,
          accent: LaTokens.darkAccent,
          onAccent: LaTokens.darkOnAccent,
          danger: LaTokens.darkDanger,
          caution: LaTokens.darkCaution,
        )
      : const LaPalette(
          brightness: Brightness.light,
          canvas: LaTokens.lightCanvas,
          surface: LaTokens.lightSurface,
          surfaceRaised: LaTokens.lightSurfaceRaised,
          surfaceOverlay: LaTokens.lightSurfaceOverlay,
          ink: LaTokens.lightInk,
          inkMuted: LaTokens.lightInkMuted,
          inkQuiet: LaTokens.lightInkQuiet,
          rule: LaTokens.lightRule,
          accent: LaTokens.lightAccent,
          onAccent: LaTokens.lightOnAccent,
          danger: LaTokens.lightDanger,
          caution: LaTokens.lightCaution,
        );

  final Brightness brightness;
  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceOverlay;
  final Color ink;
  final Color inkMuted;
  final Color inkQuiet;
  final Color rule;
  final Color accent;

  /// Text/icons ON the accent (the send button, an unread badge): the
  /// v2 token — a near-black glade in dark, white in light.
  final Color onAccent;
  final Color danger;
  final Color caution;

  /// Success shares the accent by law (DESIGN.md palette table).
  Color get success => accent;

  bool get isDark => brightness == Brightness.dark;
}

/// The token carrier inside [ThemeData]: widgets read
/// `Theme.of(context).extension<LaThemeExtension>()!` (or the [LaThemeOf]
/// shortcut) instead of inventing colors.
final class LaThemeExtension extends ThemeExtension<LaThemeExtension> {
  const LaThemeExtension(this.palette);

  factory LaThemeExtension.of(final Brightness brightness) =>
      LaThemeExtension(LaPalette.of(brightness));

  final LaPalette palette;

  @override
  ThemeExtension<LaThemeExtension> copyWith() => this;

  @override
  ThemeExtension<LaThemeExtension> lerp(
    final ThemeExtension<LaThemeExtension>? other,
    final double t,
  ) =>
      t < 0.5 ? this : (other ?? this);
}

/// The one shortcut for token reads: `context.la.ink`, `context.la.canvas`.
/// Falls back to the brightness palette when a bare MaterialApp (tests,
/// embedded hosts) carries no extension — tokens never crash a surface.
extension LaThemeOf on BuildContext {
  LaPalette get la =>
      Theme.of(this).extension<LaThemeExtension>()?.palette ??
      LaPalette.of(Theme.of(this).brightness);
}
