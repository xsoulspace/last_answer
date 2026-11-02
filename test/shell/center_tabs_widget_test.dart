// The top bar's widget law (WAVE 5): one bar renders one key per tab
// (`pane.tab.<id>`), each ✕ carries `pane.tab.close.<id>`, every
// STATIC view's tab carries `pane.tab.pin.<id>` (filled pin when
// pinned, outline when not; tap toggles), the active surface hosts
// under `pane.leaf.<id>`, taps report through the scope, the trailing
// `+` opens/focuses the picker, tabs close on middle-click, drag to
// reorder — the browser close law: closing the last REAL tab swaps the
// picker in, so only the lone PICKER keeps no ✕ — and SAFARI
// COMPRESSION: a narrow bar collapses non-active tabs to icon-only
// identity pills; the active tab never loses its title.
import 'package:core/core.dart';

import 'package:flutter/gestures.dart' show kMiddleMouseButton;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/shell/app_shell.dart';

import 'package:lastanswer/shell/center_tabs.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_layout.dart';

class _StubBody extends StatelessWidget {
  const _StubBody(this.label);

  final String label;

  @override
  Widget build(final BuildContext context) => Center(
    child: Text(label),
  );
}

SurfaceRegistry _stubSurfaces() => {
  kConversationsSurfaceId: SurfaceSpec(
    id: kConversationsSurfaceId,
    title: 'Conversations',
    builder: (final _) => const _StubBody('Conversations'),
  ),
  'stub:a': SurfaceSpec(
    id: 'stub:a',
    title: 'Surface A',
    builder: (final _) => const _StubBody('Surface A'),
    icon: Icons.web,
  ),
  'stub:b': SurfaceSpec(
    id: 'stub:b',
    title: 'Surface B',
    builder: (final _) => const _StubBody('Surface B'),
    icon: Icons.terminal,
  ),
  kNewTabSurfaceId: SurfaceSpec(
    id: kNewTabSurfaceId,
    title: 'New tab',
    builder: (final _) => const NewTabSurface(),
  ),
};

/// A minimal shell stand-in: owns the layout state exactly like
/// [_AppShellState] and reports every change.
class _Harness extends StatefulWidget {
  const _Harness({required this.initial, this.onChanged});

  final ViewLayout initial;
  final ValueChanged<ViewLayout>? onChanged;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late ViewLayout _layout;

  @override
  void initState() {
    super.initState();
    _layout = widget.initial;
  }

  void _update(final ViewLayout layout) {
    setState(() => _layout = layout);
    widget.onChanged?.call(layout);
  }

  @override
  Widget build(final BuildContext context) => ViewScope(
    layout: _layout,
    surfaces: _stubSurfaces(),
    onChanged: _update,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ViewTabBar(
          layout: _layout,
          surfaces: _stubSurfaces(),
          onSelect: (final id) => _update(_layout.open(id)),
          onClose: (final id) => _update(_layout.close(id)),
          onNewTab: () => _update(_layout.openNewTab()),
          onReorder: (final from, final to) =>
              _update(_layout.move(from, to)),
          onTogglePin: (final id) => _update(
            _layout.isPinned(id) ? _layout.unpin(id) : _layout.pin(id),
          ),
        ),
        const Expanded(child: CenterTabsArea()),
      ],
    ),
  );
}

Future<void> _pump(
  final WidgetTester tester,
  final ViewLayout initial, {
  final ValueChanged<ViewLayout>? onChanged,
  final Size? windowSize,
}) async {
  if (windowSize != null) {
    tester.view
      ..physicalSize = windowSize
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    MaterialApp(
      // The picker page reads l10n (page title + hints); the real
      // delegates keep the surface honest in the stub harness too.
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: Scaffold(
        body: _Harness(initial: initial, onChanged: onChanged),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('the bar renders one key per tab and hosts the active '
      'surface', (final tester) async {
    await _pump(tester, ViewLayout(tabs: const ['stub:a', 'stub:b']));

    expect(find.byKey(const ValueKey('center.tabs')), findsOneWidget);
    expect(find.byKey(const ValueKey('pane.tab.stub:a')), findsOneWidget);
    expect(find.byKey(const ValueKey('pane.tab.stub:b')), findsOneWidget);
    // Only the ACTIVE surface mounts.
    expect(find.byKey(const ValueKey('pane.leaf.stub:a')), findsOneWidget);
    expect(find.byKey(const ValueKey('pane.leaf.stub:b')), findsNothing);
    // The title renders twice: tab label + stub body.
    expect(find.text('Surface A'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a tab activates its surface', (final tester) async {
    ViewLayout? reported;
    await _pump(
      tester,
      ViewLayout(tabs: const ['stub:a', 'stub:b']),
      onChanged: (final layout) => reported = layout,
    );

    await tester.tap(find.byKey(const ValueKey('pane.tab.stub:b')));
    await tester.pump();

    expect(find.byKey(const ValueKey('pane.leaf.stub:b')), findsOneWidget);
    expect(find.byKey(const ValueKey('pane.leaf.stub:a')), findsNothing);
    expect(reported?.activeId, 'stub:b');
    expect(tester.takeException(), isNull);
  });

  testWidgets('an unknown surface id renders the named empty state', (
    final tester,
  ) async {
    await _pump(tester, ViewLayout(tabs: const ['mystery:x']));
    expect(
      find.byKey(const ValueKey('pane.leaf.mystery:x')),
      findsOneWidget,
    );
    expect(find.text('UNKNOWN SURFACE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("a tab's ✕ removes it; the survivor stays mounted", (
    final tester,
  ) async {
    ViewLayout? reported;
    await _pump(
      tester,
      ViewLayout(tabs: const ['stub:a', 'stub:b']),
      onChanged: (final layout) => reported = layout,
    );

    expect(
      find.byKey(const ValueKey('pane.tab.close.stub:b')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('pane.tab.close.stub:b')));
    await tester.pump();

    expect(find.byKey(const ValueKey('pane.tab.stub:b')), findsNothing);
    expect(find.byKey(const ValueKey('pane.leaf.stub:a')), findsOneWidget);
    expect(reported?.tabs, ['stub:a']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing the ACTIVE tab focuses the neighbor', (
    final tester,
  ) async {
    ViewLayout? reported;
    await _pump(
      tester,
      ViewLayout(tabs: const ['stub:a', 'stub:b'], active: 1),
      onChanged: (final layout) => reported = layout,
    );

    await tester.tap(find.byKey(const ValueKey('pane.tab.close.stub:b')));
    await tester.pump();

    // The neighbor (stub:a) becomes the active host.
    expect(find.byKey(const ValueKey('pane.leaf.stub:a')), findsOneWidget);
    expect(reported?.activeId, 'stub:a');
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing the LAST real tab swaps the picker in — the bar '
      'never goes empty; the lone PICKER keeps no ✕', (
    final tester,
  ) async {
    ViewLayout? reported;
    await _pump(tester, ViewLayout(), onChanged: (final l) => reported = l);

    // The lone REAL tab keeps its ✕ (the picker swaps in on close).
    expect(
      find.byKey(
        const ValueKey('pane.tab.close.$kConversationsSurfaceId'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(
        const ValueKey('pane.tab.close.$kConversationsSurfaceId'),
      ),
    );
    await tester.pump();

    expect(reported?.tabs, [kNewTabSurfaceId]);
    expect(
      find.byKey(const ValueKey('pane.tab.$kNewTabSurfaceId')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('pane.leaf.$kNewTabSurfaceId')),
      findsOneWidget,
    );
    // The lone picker keeps no close affordance — nothing to swap in.
    expect(
      find.byKey(const ValueKey('pane.tab.close.$kNewTabSurfaceId')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('middle-click closes the tab (browser convention)', (
    final tester,
  ) async {
    ViewLayout? reported;
    await _pump(
      tester,
      ViewLayout(tabs: const ['stub:a', 'stub:b']),
      onChanged: (final layout) => reported = layout,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('pane.tab.stub:b'))),
      buttons: kMiddleMouseButton,
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(reported?.tabs, ['stub:a']);
    expect(find.byKey(const ValueKey('pane.tab.stub:b')), findsNothing);
    // A middle-click is not a selection: the active tab stays.
    expect(reported?.active, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dragging a tab reorders it; the dragged id stays focused', (
    final tester,
  ) async {
    ViewLayout? reported;
    await _pump(
      tester,
      ViewLayout(tabs: const ['stub:a', 'stub:b']),
      onChanged: (final layout) => reported = layout,
    );

    final tab = find.byKey(const ValueKey('pane.tab.stub:a'));
    final width = tester.getSize(tab).width;
    final gesture = await tester.startGesture(tester.getCenter(tab));
    // Two moves: the first crosses the drag slop (start), the second
    // delivers the update past one tab-width (one swap). Real pointers
    // stream many moves; a synthetic single jump would be consumed by
    // the start.
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump();
    await gesture.moveBy(Offset(width, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(reported?.tabs, ['stub:b', 'stub:a']);
    expect(reported?.activeId, 'stub:a');
    expect(tester.takeException(), isNull);
  });

  testWidgets("the bar's + opens/focuses the picker — at most ONE "
      'newtab tab exists', (final tester) async {
    ViewLayout? reported;
    await _pump(
      tester,
      ViewLayout(tabs: const ['stub:a']),
      onChanged: (final layout) => reported = layout,
    );

    await tester.tap(find.byKey(const ValueKey('center.tabs.add')));
    await tester.pump();

    expect(reported?.tabs, ['stub:a', kNewTabSurfaceId]);
    expect(reported?.activeId, kNewTabSurfaceId);
    expect(
      find.byKey(const ValueKey('pane.leaf.$kNewTabSurfaceId')),
      findsOneWidget,
    );

    // The picker is already open and focused: + does not duplicate it.
    await tester.tap(find.byKey(const ValueKey('center.tabs.add')));
    await tester.pump();
    expect(reported?.tabs, ['stub:a', kNewTabSurfaceId]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the picker page lists the registry destinations and picking '
      'one replaces the picker tab in place', (final tester) async {
    ViewLayout? reported;
    await _pump(
      tester,
      ViewLayout(tabs: const ['stub:a', kNewTabSurfaceId], active: 1),
      onChanged: (final layout) => reported = layout,
    );

    expect(find.byKey(const ValueKey('newtab.page')), findsOneWidget);
    expect(find.byKey(const ValueKey('newtab.entry.stub:a')), findsOneWidget);
    expect(find.byKey(const ValueKey('newtab.entry.stub:b')), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('newtab.entry.$kConversationsSurfaceId'),
      ),
      findsOneWidget,
    );
    // The picker never lists itself.
    expect(
      find.byKey(const ValueKey('newtab.entry.$kNewTabSurfaceId')),
      findsNothing,
    );
    // Unknown destinations render name-only; known ones carry hints.
    // 'Surface A' shows twice (tab label + entry name), 'New tab' too
    // (tab label + the page's section label).
    expect(find.text('Surface A'), findsNWidgets(2));
    expect(find.text('New tab'), findsNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('newtab.entry.stub:b')));
    await tester.pump();

    // Replaced in place: same position, neighbors untouched.
    expect(reported?.tabs, ['stub:a', 'stub:b']);
    expect(reported?.active, 1);
    expect(find.byKey(const ValueKey('pane.leaf.stub:b')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking an already-open destination focuses it and closes '
      'the picker (stations stay unique)', (final tester) async {
    ViewLayout? reported;
    await _pump(
      tester,
      ViewLayout(tabs: const ['stub:a', kNewTabSurfaceId], active: 1),
      onChanged: (final layout) => reported = layout,
    );

    await tester.tap(find.byKey(const ValueKey('newtab.entry.stub:a')));
    await tester.pump();

    expect(reported?.tabs, ['stub:a']);
    expect(reported?.active, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a titleFor-less conversation tab labels with the raw id '
      'and hosts the ONE conversation slot', (final tester) async {
    // `dm:`/`channel:` ids are not in the static registry: they resolve
    // onto the conversations spec (the label stays the raw id when no
    // service titles it).
    await _pump(tester, ViewLayout(tabs: const ['dm:x']));
    expect(find.byKey(const ValueKey('pane.leaf.dm:x')), findsOneWidget);
    expect(find.text('dm:x'), findsOneWidget);
    expect(find.text('Conversations'), findsOneWidget);
    expect(find.text('UNKNOWN SURFACE'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('the pin affordance (WAVE 5)', () {
    testWidgets('static tabs carry the pin glyph; the picker does not', (
      final tester,
    ) async {
      await _pump(
        tester,
        ViewLayout(tabs: const ['stub:a', kNewTabSurfaceId]),
      );

      expect(
        find.byKey(const ValueKey('pane.tab.pin.stub:a')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.tab.pin.$kNewTabSurfaceId')),
        findsNothing,
      );
    });

    testWidgets('the glyph reads the pin state: outline unpinned, filled '
        'pinned (WAVE 5)', (final tester) async {
      await _pump(tester, ViewLayout(tabs: const ['stub:a']));

      Icon glyphOf() => tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const ValueKey('pane.tab.pin.stub:a')),
          matching: find.byType(Icon),
        ),
      );
      expect(glyphOf().icon, Icons.push_pin_outlined);

      // Tap toggles: pin.
      await tester.tap(find.byKey(const ValueKey('pane.tab.pin.stub:a')));
      await tester.pump();
      expect(glyphOf().icon, Icons.push_pin);

      // Tap toggles again: unpin.
      await tester.tap(find.byKey(const ValueKey('pane.tab.pin.stub:a')));
      await tester.pump();
      expect(glyphOf().icon, Icons.push_pin_outlined);
      expect(tester.takeException(), isNull);
    });

    testWidgets('conversation tabs carry no pin glyph (static views '
        'only)', (final tester) async {
      await _pump(tester, ViewLayout(tabs: const ['stub:a', 'dm:x']));
      expect(
        find.byKey(const ValueKey('pane.tab.pin.stub:a')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('pane.tab.pin.dm:x')), findsNothing);
    });
  });

  group('Safari compression (WAVE 5)', () {
    testWidgets('a wide bar keeps every tab title', (final tester) async {
      await _pump(
        tester,
        ViewLayout(tabs: const ['stub:a', 'stub:b']),
        windowSize: const Size(1600, 900),
      );
      expect(find.text('Surface A'), findsWidgets);
      expect(find.text('Surface B'), findsWidgets);
    });

    testWidgets('a narrow bar collapses non-active tabs to icon-only '
        'identity pills; the active tab never loses its title', (
      final tester,
    ) async {
      await _pump(
        tester,
        ViewLayout(tabs: const ['stub:a', 'stub:b']),
        windowSize: const Size(300, 600),
      );
      // The ACTIVE tab keeps its title (tab label + stub body = 2).
      expect(find.text('Surface A'), findsNWidgets(2));
      // The non-active tab degraded to its identity pill: no title text
      // anywhere (the stub body only mounts for the active surface).
      expect(find.text('Surface B'), findsNothing);
      // The pill still selects on tap (the identity is the tab).
      await tester.tap(find.byKey(const ValueKey('pane.tab.stub:b')));
      await tester.pump();
      expect(find.byKey(const ValueKey('pane.leaf.stub:b')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
