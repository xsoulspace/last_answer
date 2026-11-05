part of 'theme.dart';

/// The DESIGN.md type scale as a [TextTheme]. The six documented roles map
/// onto the Material slots widgets already read, so legacy surfaces inherit
/// the scale for free:
///
/// | role     | slot          | size/height | weight |
/// |----------|---------------|-------------|--------|
/// | Micro    | labelSmall    | 11/16       | 500    |
/// | Compact  | labelMedium   | 12/17       | 450    |
/// | Body     | bodyMedium    | 14/20       | 400    |
/// | Emphasis | titleMedium   | 15/21       | 600    |
/// | Section  | titleLarge    | 18/24       | 600    |
/// | Display  | headlineSmall | 24/30       | 600    |
TextTheme _laTextTheme(final LaPalette p) {
  TextStyle tint(final TextStyle style, [final Color? color]) =>
      style.copyWith(color: color ?? p.ink);
  return TextTheme(
    labelSmall: tint(LaTokens.micro, p.inkQuiet),
    labelMedium: tint(LaTokens.compact, p.inkMuted),
    labelLarge: tint(LaTokens.body.copyWith(fontWeight: FontWeight.w500)),
    bodySmall: tint(LaTokens.compact, p.inkMuted),
    bodyMedium: tint(LaTokens.body),
    bodyLarge: tint(LaTokens.emphasis.copyWith(fontWeight: FontWeight.w400)),
    titleSmall: tint(LaTokens.body.copyWith(fontWeight: FontWeight.w600)),
    titleMedium: tint(LaTokens.emphasis),
    titleLarge: tint(LaTokens.section),
    headlineSmall: tint(LaTokens.display),
    headlineMedium: tint(LaTokens.section.copyWith(fontSize: 20)),
    headlineLarge: tint(LaTokens.display.copyWith(fontSize: 28)),
    displaySmall: tint(LaTokens.display),
  );
}
