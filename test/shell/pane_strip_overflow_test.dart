// Wave I — the tab-strip OVERFLOW LAW (owner fix list 2026-11-10, the
// ~30-tab restore): compression-to-icon alone made the strip an
// unreadable icon row and squeezed unread badges into vertical glyph
// stacks. The law under test:
//   1. the CAP — at most floor((usable - overflowSlot) / compactWidth)
//      pills render, where usable = stripWidth - controlsWidth(132),
//      overflowSlot = 40 and compactWidth = 34; the tail hides
//      rightmost-first and the ACTIVE tab is never hidden (it swaps
//      into the last visible slot, the displaced tab hides in order);
//   2. the overflow control (`view.strip.overflow.<group>`) names the
//      exact hidden count and its menu lists EVERY hidden tab in
//      original tab order — a row tap opens that tab through onSelect;
//   3. the BADGE law — full pills keep the numeric badge (>= 14px,
//      one line, never stacked), compressed pills ride the fixed 6px
//      corner dot, and a 320px squeeze never paints badge text
//      vertically;
//   4. the wave-C drag law survives the cap: a visible tab still
//      reorders through onMoveTab at ORIGINAL layout indices.
// The pump is direct (PaneStrip alone over a bare MaterialApp): the
// cap is a width law, so the width is the fixture; the unread fact
// rides the injected `unreadFor` lane (hermetic — no world needed).
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/pane_strip.dart';
import 'package:lastanswer/shell/shell_layout.dart';
import 'package:lastanswer/shell/surfaces.dart';

/// 30 distinct tab ids (`tab.0` … `tab.29`).
List<String> _tabs(final int count) => <String>[
  for (var i = 0; i < count; i++) 'tab.$i',
];

/// A registry that gives every fixture tab a kind glyph + short title
/// (the compressed pill's 31px shape: 18 padding + 13 icon).
SurfaceRegistry _registry(final List<String> tabs) => <String, SurfaceSpec>{
  for (final id in tabs)
    id: SurfaceSpec(
      id: id,
      title: 'Tab ${id.split('.').last}',
      icon: Icons.description_outlined,
      builder: (final _) => const SizedBox.shrink(),
    ),
};

Future<void> _pumpStrip(
  final WidgetTester tester, {
  required final List<String> tabs,
  final int active = 0,
  final double width = 900,
  final int? Function(String surfaceId)? unreadFor,
  final List<String>? selected,
  final List<(String, int, int?)>? moves,
}) async {
  final layout = ShellLayout(
    groups: <ViewState>[ViewState(tabs: tabs, active: active)],
  );
  await tester.binding.setSurfaceSize(Size(width + 200, 600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      // The kit overlay host (same shape as last_answer_app.dart):
      // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
      builder: (final context, final child) =>
          Portal(child: child ?? const SizedBox.shrink()),locale: const Locale('en'),
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: PaneStrip(
              group: 0,
              layout: layout,
              surfaces: _registry(tabs),
              onSelect: (final id) => selected?.add(id),
              onClose: (final _) {},
              onNewTab: () {},
              onSplit: () {},
              onFold: () {},
              onBack: () {},
              onForward: () {},
              onMoveTab: (final id, final g, final at) =>
                  moves?.add((id, g, at)),
              onTabContext: (final _, final _) {},
              unreadFor: unreadFor,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// The menu's row values in tree order (the hidden tabs' order law).
/// The kit menu rows carry the frozen `view.strip.overflow.item.<id>`
/// keys (LaMenuItem.key → the rendered LaMenuRow), so the order reads
/// off the keys — the PopupMenuItem `value` lane retired with the
/// Material menu.
List<String> _menuValues(final WidgetTester tester) =>
    find
        .byWidgetPredicate(
          (final widget) =>
              widget.key is ValueKey<String> &&
              (widget.key! as ValueKey<String>)
                  .value
                  .startsWith('view.strip.overflow.item.'),
        )
        .evaluate()
        .map(
          (final element) =>
              (element.widget.key! as ValueKey<String>).value.substring(
                'view.strip.overflow.item.'.length,
              ),
        )
        .toList();

void main() {
  group('the Wave I overflow cap', () {
    testWidgets('30 tabs at 900px: at most the cap renders (21 pills), '
        'the tail hides, and the overflow button names the exact '
        'hidden count (+9)', (final tester) async {
      final tabs = _tabs(30);
      await _pumpStrip(tester, tabs: tabs);

      // The cap: floor((900 - 132 - 40) / 34) = floor(21.4) = 21.
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Draggable<String>),
        ),
        findsNWidgets(21),
      );
      for (var i = 0; i <= 20; i++) {
        expect(
          find.byKey(ValueKey('view.tab.tab.$i')),
          findsOneWidget,
          reason: 'slot $i stays visible',
        );
      }
      for (var i = 21; i < 30; i++) {
        expect(
          find.byKey(ValueKey('view.tab.tab.$i')),
          findsNothing,
          reason: 'tab $i hides behind the overflow control',
        );
      }
      expect(
        find.byKey(const ValueKey('view.strip.overflow.0')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('view.strip.overflow.0')),
          matching: find.text('+9'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the overflow menu lists EXACTLY the hidden ids in '
        'original tab order, and a row tap opens that tab through '
        'onSelect', (final tester) async {
      final tabs = _tabs(30);
      final selected = <String>[];
      await _pumpStrip(tester, tabs: tabs, selected: selected);

      await tester.tap(
        find.byKey(const ValueKey('view.strip.overflow.0')),
      );
      // The popup menu animates in — settle before reading it (the
      // shell test lane's showMenu law).
      await tester.pumpAndSettle();

      expect(_menuValues(tester), <String>[
        for (var i = 21; i < 30; i++) 'tab.$i',
      ]);
      // Every row carries its title and kind glyph.
      expect(find.text('Tab 25'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(
            const ValueKey('view.strip.overflow.item.tab.25'),
          ),
          matching: find.byIcon(Icons.description_outlined),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('view.strip.overflow.item.tab.25')),
      );
      await tester.pumpAndSettle();
      expect(selected, <String>['tab.25']);
    });

    testWidgets('the active-beyond-cap swap law: the active tab takes '
        'the last visible slot and the displaced tab hides IN ORDER', (
      final tester,
    ) async {
      final tabs = _tabs(30);
      await _pumpStrip(tester, tabs: tabs, active: 25);

      // Slots 0..19 keep the head; slot 20 carries the active tab.25.
      expect(find.byKey(const ValueKey('view.tab.tab.25')), findsOneWidget);
      expect(find.byKey(const ValueKey('view.tab.tab.19')), findsOneWidget);
      expect(find.byKey(const ValueKey('view.tab.tab.20')), findsNothing);
      expect(find.byKey(const ValueKey('view.tab.tab.26')), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('view.strip.overflow.0')),
      );
      await tester.pumpAndSettle();
      // The hidden list stays in ORIGINAL tab order: the displaced
      // tab.20 rides at its own index, tab.25 is absent.
      expect(_menuValues(tester), <String>[
        'tab.20',
        'tab.21',
        'tab.22',
        'tab.23',
        'tab.24',
        'tab.26',
        'tab.27',
        'tab.28',
        'tab.29',
      ]);
    });

    testWidgets('a hidden tab is not in the tree — the menu row OPENS '
        'it; it never drags (the wave-C law belongs to visible pills)', (
      final tester,
    ) async {
      final tabs = _tabs(30);
      await _pumpStrip(tester, tabs: tabs);
      expect(find.byKey(const ValueKey('view.tab.tab.29')), findsNothing);
      expect(
        find.byKey(const ValueKey('drag.ghost.tab.29')),
        findsNothing,
      );
    });
  });

  group('the Wave I badge law', () {
    testWidgets('full pills keep the NUMERIC badge (>= 14px wide, '
        'one line); a read tab renders nothing', (final tester) async {
      final tabs = _tabs(3);
      await _pumpStrip(
        tester,
        tabs: tabs,
        unreadFor: (final id) => switch (id) {
          'tab.0' => 12,
          'tab.1' => 3,
          _ => 0,
        },
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      final badge = tester.getSize(
        find.byKey(const ValueKey('view.tab.unread.tab.0')),
      );
      expect(badge.width, greaterThanOrEqualTo(14));
      // The fixed 14px height is the single-line proof: stacked glyphs
      // would double it.
      expect(badge.height, lessThanOrEqualTo(14));
      expect(
        find.byKey(const ValueKey('view.tab.unread.tab.2')),
        findsNothing,
        reason: 'a read tab badges honest-absent, never zero',
      );
    });

    testWidgets('COMPRESSED pills ride the fixed 6px corner dot — the '
        'number never paints inside the pill (the menu carries it)', (
      final tester,
    ) async {
      final tabs = _tabs(30);
      await _pumpStrip(
        tester,
        tabs: tabs,
        unreadFor: (final id) => id == 'tab.5' ? 7 : 0,
      );

      // tab.5 is compressed (the cap's tail side): the dot, not '7'.
      final dot = tester.getSize(
        find.byKey(const ValueKey('view.tab.unread.tab.5')),
      );
      expect(dot.width, 6);
      expect(dot.height, 6);
      expect(find.text('7'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('view.tab.unread.tab.5')),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      // The hidden tabs' counts ride the menu rows instead.
      await tester.tap(
        find.byKey(const ValueKey('view.strip.overflow.0')),
      );
      await tester.pumpAndSettle();
      expect(_menuValues(tester).first, 'tab.21');
    });

    testWidgets('the 320px squeeze: the badge never stacks — dot 6px, '
        'numeric single-line within 14px height, no vertical glyphs', (
      final tester,
    ) async {
      final tabs = _tabs(30);
      await _pumpStrip(
        tester,
        tabs: tabs,
        width: 320,
        unreadFor: (final id) => switch (id) {
          'tab.0' => 150,
          'tab.1' => 7,
          _ => 0,
        },
      );

      // Cap at 320px: floor((320 - 132 - 40) / 34) = 4 visible, +26.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('view.strip.overflow.0')),
          matching: find.text('+26'),
        ),
        findsOneWidget,
      );
      // The active pill keeps the numeric badge: '99+' on ONE line —
      // height pinned at 14, width never below 14.
      final numeric = tester.getSize(
        find.byKey(const ValueKey('view.tab.unread.tab.0')),
      );
      expect(find.text('99+'), findsOneWidget);
      expect(numeric.width, greaterThanOrEqualTo(14));
      expect(numeric.height, lessThanOrEqualTo(14));
      // The compressed neighbour rides the 6px dot: >= 6, <= 14.
      final dot = tester.getSize(
        find.byKey(const ValueKey('view.tab.unread.tab.1')),
      );
      expect(dot.width, greaterThanOrEqualTo(6));
      expect(dot.width, lessThanOrEqualTo(14));
      expect(dot.height, greaterThanOrEqualTo(6));
      expect(dot.height, lessThanOrEqualTo(14));
      // No stacked glyph run anywhere in the strip: every badge Text
      // stays a single line (its height fits the 14px badge).
      for (final id in <String>['tab.0', 'tab.1']) {
        final texts = tester.widgetList<Text>(
          find.descendant(
            of: find.byKey(ValueKey('view.tab.unread.$id')),
            matching: find.byType(Text),
          ),
        );
        for (final text in texts) {
          expect(text.maxLines, 1);
          expect(text.softWrap, isFalse);
        }
      }
    });
  });

  group('the wave-C drag law under the cap', () {
    testWidgets('a visible tab still reorders through onMoveTab at the '
        'ORIGINAL layout index (one reorder with the cap active)', (
      final tester,
    ) async {
      final tabs = _tabs(30);
      final moves = <(String, int, int?)>[];
      await _pumpStrip(tester, tabs: tabs, moves: moves);

      final from = tester.getCenter(
        find.byKey(const ValueKey('view.tab.tab.2')),
      );
      final to = tester.getCenter(
        find.byKey(const ValueKey('view.tab.tab.0')),
      );
      await tester.dragFrom(from, to - from);
      await tester.pump();

      // Insert BEFORE the hovered tab, counted on the FULL layout list
      // (index 0) — never on the visible slot order.
      expect(moves, <(String, int, int?)>[('tab.2', 0, 0)]);
    });
  });
}
