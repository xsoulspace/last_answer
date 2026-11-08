// ADR 0024 — the shell registry's inspector surface: the REAL pane, not
// a placeholder. The tab lands on the pane's collapsed attention rule
// (ONE status line, product DESIGN §10); expanding fills the bounded
// tab. The pane here runs over the shared session registry
// (`HarnessSessionRegistry.instance` — empty in the test binding), the
// same default the tab uses in production.
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/surfaces.dart';

/// Builds the registry's inspector spec inside a Material + l10n tree
/// (the shell's own shape: titles resolve against `context.l10n` at
/// registry-build time) and hosts the spec's builder in a bounded box —
/// the center tab's shape.
Widget _pumpInspectorTab() => MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: Scaffold(
    body: Center(
      child: SizedBox(
        key: const Key('inspector.tab.box'),
        width: 800,
        height: 500,
        child: Builder(
          builder: (final context) {
            final spec =
                buildShellSurfaces(context)[kInspectorSurfaceId]!;
            return Builder(builder: spec.builder);
          },
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('the registry inspector spec mounts the real pane: the '
      'collapsed status rule is the landing state, no exception', (
    final tester,
  ) async {
    WorldInspectorPane.lastProjection = null;
    await tester.pumpWidget(_pumpInspectorTab());
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    // The REAL pane: the status rule and its toggle, collapsed (no
    // canvas leaf yet) — the honest attention-dial landing state.
    expect(find.byKey(const Key('world_inspector.rule')), findsOneWidget);
    expect(find.byKey(const Key('world_inspector.toggle')), findsOneWidget);
    expect(find.byKey(const Key('world_inspector.pane')), findsNothing);
    // The headless projection proves a pane mounted (a placeholder
    // writes no projection) and reads the shared registry — empty in
    // the test binding, so the rule instructs instead of blanking.
    final projection = WorldInspectorPane.lastProjection;
    expect(projection, isNotNull);
    expect(projection!.sessions, isEmpty);
    expect(find.textContaining('no live actor work'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('expanding the tab inspector fills the bounded tab', (
    final tester,
  ) async {
    await tester.pumpWidget(_pumpInspectorTab());
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const Key('world_inspector.toggle')));
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    final box = tester.getRect(find.byKey(const Key('inspector.tab.box')));
    final rule = tester.getRect(find.byKey(const Key('world_inspector.rule')));
    final pane = tester.getRect(find.byKey(const Key('world_inspector.pane')));
    // Production defaults: the 3D scene band is ON (ONE version law) and
    // the infinite expandedHeight became an Expanded that fills the tab
    // below the status rule, to the tab's edges.
    expect(pane.height, greaterThan(0));
    expect(pane.height.isFinite, isTrue);
    expect(pane.top, greaterThanOrEqualTo(rule.bottom - 0.5));
    expect(pane.bottom, closeTo(box.bottom, 0.5));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
