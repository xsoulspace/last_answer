import 'package:lastanswer/common_imports.dart';
import 'package:flutter/widgets.dart';
import 'package:la_ui_kit/la_ui_kit.dart';

/// The ONE bridge between the app's zinc palette (`LaPalette`, DESIGN.md v2
/// tokens) and the kit's token carrier (`LaUiTheme`, packages/la_ui). The
/// kit never learns about core; the app feeds it. Registered once in
/// `last_answer_app.dart`'s MaterialApp builder.
LaUiTheme laUiThemeFromPalette(final LaPalette p) {
  final dark = p.brightness == Brightness.dark;
  return LaUiTheme(
    isDark: dark,
    canvas: p.canvas,
    surface: p.surface,
    surfaceRaised: p.surfaceRaised,
    surfaceOverlay: p.surfaceOverlay,
    ink: p.ink,
    inkMuted: p.inkMuted,
    inkQuiet: p.inkQuiet,
    rule: p.rule,
    accent: p.accent,
    onAccent: p.onAccent,
    danger: p.danger,
    onDanger: dark ? const Color(0xFF2A0E0E) : const Color(0xFFFFFFFF),
    caution: p.caution,
    success: p.accent,
    fieldAlpha: dark ? 0.04 : 0.03,
  );
}
