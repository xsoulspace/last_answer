import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 0 gate (docs/design/shell-redesign-rail-views-tabs-2026-11-05.md):
/// the shipped themes ARE the DESIGN.md token table — not stock Material.
/// If a token drifts back to a framework default, this test fails.
void main() {
  group('la theme tokens', () {
    testWidgets('dark theme ships the documented dark palette', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: darkThemeData, home: const _Probe()),
      );
      final theme = Theme.of(tester.element(find.byType(_Probe)));
      expect(theme.scaffoldBackgroundColor, LaTokens.darkCanvas);
      expect(theme.colorScheme.primary, LaTokens.darkAccent);
      expect(theme.colorScheme.surface, LaTokens.darkSurface);
      expect(theme.colorScheme.error, LaTokens.darkDanger);
      expect(theme.dividerColor, LaTokens.darkRule);
      final la = theme.extension<LaThemeExtension>()!.palette;
      expect(la.surfaceRaised, LaTokens.darkSurfaceRaised);
      expect(la.surfaceOverlay, LaTokens.darkSurfaceOverlay);
      expect(la.inkMuted, LaTokens.darkInkMuted);
      expect(la.onAccent, LaTokens.darkOnAccent);
      expect(la.success, la.accent);
    });

    testWidgets('light theme ships the documented light palette', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: lightThemeData, home: const _Probe()),
      );
      final theme = Theme.of(tester.element(find.byType(_Probe)));
      expect(theme.scaffoldBackgroundColor, LaTokens.lightCanvas);
      expect(theme.colorScheme.primary, LaTokens.lightAccent);
      expect(theme.colorScheme.surface, LaTokens.lightSurface);
      expect(theme.dividerColor, LaTokens.lightRule);
      final la = theme.extension<LaThemeExtension>()!.palette;
      expect(la.ink, LaTokens.lightInk);
      expect(la.onAccent, LaTokens.lightOnAccent);
      expect(la.caution, LaTokens.lightCaution);
    });

    testWidgets('the type scale is the documented one', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: darkThemeData, home: const _Probe()),
      );
      final text = Theme.of(tester.element(find.byType(_Probe))).textTheme;
      expect(text.labelSmall?.fontSize, 11); // Micro
      expect(text.labelMedium?.fontSize, 12); // Compact
      expect(text.bodyMedium?.fontSize, 14); // Body
      expect(text.titleMedium?.fontSize, 15); // Emphasis
      expect(text.titleLarge?.fontSize, 18); // Section
      expect(text.headlineSmall?.fontSize, 24); // Display
      expect(text.titleMedium?.fontWeight, FontWeight.w600);
    });

    testWidgets('ink effects are off by law (de-Material)', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: darkThemeData, home: const _Probe()),
      );
      final theme = Theme.of(tester.element(find.byType(_Probe)));
      expect(theme.splashFactory, NoSplash.splashFactory);
      expect(theme.highlightColor, const Color(0x00000000));
    });

    testWidgets('the interface sans is the bundled Inter (v2)', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: darkThemeData, home: const _Probe()),
      );
      final theme = Theme.of(tester.element(find.byType(_Probe)));
      // DESIGN.md v2: Inter, bundled in packages/core/google_fonts —
      // if this pin drifts, the shipped look is no longer the mockup's.
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
      expect(theme.textTheme.titleMedium?.fontFamily, 'Inter');
    });
  });
}

class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(final BuildContext context) => const SizedBox.shrink();
}
