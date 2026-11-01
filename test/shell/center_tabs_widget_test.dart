// The center tab strip widget law: the strip renders one key per tab
// (`pane.tab.<id>`), each ✕ carries `pane.tab.close.<id>`, the active
// surface hosts under `pane.leaf.<id>`, taps report through the scope,
// the trailing `+` opens/focuses the picker, tabs close on
// middle-click, drag to reorder — and the browser close law: closing
// the last REAL tab swaps the picker in, so only the lone PICKER keeps
// no ✕.
import 'package:core/core.dart';

import 'package:flutter/gestures.dart' show kMiddleMouseButton;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/shell/app_shell.dart';

import 'package:lastanswer/shell/center_tabs.dart';

import 'package:lastanswer/shell/surfaces.dart';

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
  ),
  'stub:b': SurfaceSpec(
    id: 'stub:b',
    title: 'Surface B',
    builder: (final _) => const _StubBody('Surface B'),
  ),
  kNewTabSurfaceId: SurfaceSpec(
    id: kNewTabSurfaceId,
    title: 'New tab',
    builder: (final _) => const NewTabSurface(),
  ),
};

/// A minimal shell stand-in: owns the strip state exactly like
/// [_AppShellState] and reports every change.
class _Harness extends StatefulWidget {
  const _Harness({required this.initial, this.onChanged});

  final CenterTabs initial;
  final ValueChanged<CenterTabs>? onChanged;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late CenterTabs _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = widget.initial;
  }

  @override
  Widget build(final BuildContext context) => CenterTabsScope(
    tabs: _tabs,
    surfaces: _stubSurfaces(),
    onChanged: (final tabs) {
      setState(() => _tabs = tabs);
      widget.onChanged?.call(tabs);
    },
    child: const CenterTabsArea(),
  );
}

Future<void> _pump(
  final WidgetTester tester,
  final CenterTabs initial, {
  final ValueChanged<CenterTabs>? onChanged,
}) async {
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
  testWidgets('the strip renders one key per tab and hosts the active '
      'surface', (final tester) async {
    await _pump(tester, CenterTabs(surfaceIds: const ['stub:a', 'stub:b']));

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
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(surfaceIds: const ['stub:a', 'stub:b']),
      onChanged: (final tabs) => reported = tabs,
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
    await _pump(tester, CenterTabs(surfaceIds: const ['mystery:x']));
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
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(surfaceIds: const ['stub:a', 'stub:b']),
      onChanged: (final tabs) => reported = tabs,
    );

    expect(
      find.byKey(const ValueKey('pane.tab.close.stub:b')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('pane.tab.close.stub:b')));
    await tester.pump();

    expect(find.byKey(const ValueKey('pane.tab.stub:b')), findsNothing);
    expect(find.byKey(const ValueKey('pane.leaf.stub:a')), findsOneWidget);
    expect(reported?.surfaceIds, ['stub:a']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing the ACTIVE tab focuses the neighbor', (
    final tester,
  ) async {
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(surfaceIds: const ['stub:a', 'stub:b'], active: 1),
      onChanged: (final tabs) => reported = tabs,
    );

    await tester.tap(find.byKey(const ValueKey('pane.tab.close.stub:b')));
    await tester.pump();

    // The neighbor (stub:a) becomes the active host.
    expect(find.byKey(const ValueKey('pane.leaf.stub:a')), findsOneWidget);
    expect(reported?.activeId, 'stub:a');
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing the LAST real tab swaps the picker in — the strip '
      'never goes empty; the lone PICKER keeps no ✕', (
    final tester,
  ) async {
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(),
      onChanged: (final tabs) => reported = tabs,
    );

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

    expect(reported?.surfaceIds, [kNewTabSurfaceId]);
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
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(surfaceIds: const ['stub:a', 'stub:b']),
      onChanged: (final tabs) => reported = tabs,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('pane.tab.stub:b'))),
      buttons: kMiddleMouseButton,
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(reported?.surfaceIds, ['stub:a']);
    expect(find.byKey(const ValueKey('pane.tab.stub:b')), findsNothing);
    // A middle-click is not a selection: the active tab stays.
    expect(reported?.active, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dragging a tab reorders it; the dragged id stays focused', (
    final tester,
  ) async {
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(surfaceIds: const ['stub:a', 'stub:b']),
      onChanged: (final tabs) => reported = tabs,
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

    expect(reported?.surfaceIds, ['stub:b', 'stub:a']);
    expect(reported?.activeId, 'stub:a');
    expect(tester.takeException(), isNull);
  });

  testWidgets("the strip's + opens/focuses the picker — at most ONE "
      'newtab tab exists', (final tester) async {
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(surfaceIds: const ['stub:a']),
      onChanged: (final tabs) => reported = tabs,
    );

    await tester.tap(find.byKey(const ValueKey('center.tabs.add')));
    await tester.pump();

    expect(reported?.surfaceIds, ['stub:a', kNewTabSurfaceId]);
    expect(reported?.activeId, kNewTabSurfaceId);
    expect(
      find.byKey(const ValueKey('pane.leaf.$kNewTabSurfaceId')),
      findsOneWidget,
    );

    // The picker is already open and focused: + does not duplicate it.
    await tester.tap(find.byKey(const ValueKey('center.tabs.add')));
    await tester.pump();
    expect(reported?.surfaceIds, ['stub:a', kNewTabSurfaceId]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the picker page lists the registry destinations and picking '
      'one replaces the picker tab in place', (final tester) async {
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(
        surfaceIds: const ['stub:a', kNewTabSurfaceId],
        active: 1,
      ),
      onChanged: (final tabs) => reported = tabs,
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
    expect(reported?.surfaceIds, ['stub:a', 'stub:b']);
    expect(reported?.active, 1);
    expect(find.byKey(const ValueKey('pane.leaf.stub:b')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking an already-open destination focuses it and closes '
      'the picker (stations stay unique)', (final tester) async {
    CenterTabs? reported;
    await _pump(
      tester,
      CenterTabs(
        surfaceIds: const ['stub:a', kNewTabSurfaceId],
        active: 1,
      ),
      onChanged: (final tabs) => reported = tabs,
    );

    await tester.tap(find.byKey(const ValueKey('newtab.entry.stub:a')));
    await tester.pump();

    expect(reported?.surfaceIds, ['stub:a']);
    expect(reported?.active, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a titleFor override labels conversation tabs', (
    final tester,
  ) async {
    // The area wires titleFor to the service's projections; here the
    // fallback law is pinned: registry titles cover known ids, the raw
    // id labels unknown ones (the service is absent in this harness).
    await _pump(tester, CenterTabs(surfaceIds: const ['stub:a', 'dm:x']));
    expect(find.text('Surface A'), findsNWidgets(2));
    expect(find.text('dm:x'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a conversation tab hosts the ONE conversation slot, not '
      'the unknown state', (final tester) async {
    // `dm:`/`channel:` ids are not in the static registry: they resolve
    // onto the conversations spec (the strip label stays the raw id
    // when no service titles it).
    await _pump(tester, CenterTabs(surfaceIds: const ['dm:x']));
    expect(find.byKey(const ValueKey('pane.leaf.dm:x')), findsOneWidget);
    // The label falls back to the raw id (no service titles it here);
    // the HOSTED BODY is the conversation slot's.
    expect(find.text('dm:x'), findsOneWidget);
    expect(find.text('Conversations'), findsOneWidget);
    expect(find.text('UNKNOWN SURFACE'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a channel tab hosts the conversation slot too', (
    final tester,
  ) async {
    await _pump(tester, CenterTabs(surfaceIds: const ['channel:c1']));
    expect(find.byKey(const ValueKey('pane.leaf.channel:c1')), findsOneWidget);
    expect(find.text('channel:c1'), findsOneWidget);
    expect(find.text('Conversations'), findsOneWidget);
    expect(find.text('UNKNOWN SURFACE'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
