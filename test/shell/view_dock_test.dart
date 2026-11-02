// The dock's widget law (WAVE 5): the right column renders the PINNED
// views from the ONE layout — a vertical pill strip (`view.dock.pill.<id>`)
// above the focused pin's content (`view.dock.content.<id>`); a pill tap
// focuses that pin; the unpin glyph (`view.dock.unpin.<id>`) shows on
// the focused pill and on hover; the focused pill carries the shared
// selected tint. Rebuilt per call — no cached strip instances.
import 'package:core/core.dart';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_dock.dart';

import 'package:lastanswer/shell/view_layout.dart';

class _StubBody extends StatelessWidget {
  const _StubBody(this.label);

  final String label;

  @override
  Widget build(final BuildContext context) => Center(child: Text(label));
}

SurfaceRegistry _stubSurfaces() => {
  'stub:a': SurfaceSpec(
    id: 'stub:a',
    title: 'Surface A',
    builder: (final _) => const _StubBody('Body A'),
    icon: Icons.folder_outlined,
  ),
  'stub:b': SurfaceSpec(
    id: 'stub:b',
    title: 'Surface B',
    builder: (final _) => const _StubBody('Body B'),
    icon: Icons.terminal,
  ),
};

Future<void> _pump(
  final WidgetTester tester,
  final ViewLayout layout, {
  final ValueChanged<String>? onFocusPin,
  final ValueChanged<String>? onUnpin,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      // The pills' unpin tooltip reads l10n; the real delegates keep the
      // harness honest (the shell always provides them).
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: Scaffold(
        body: Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            SizedBox(
              width: ShellTokens.contextColumnWidth,
              child: ViewDock(
                layout: layout,
                surfaces: _stubSurfaces(),
                onFocusPin: onFocusPin,
                onUnpin: onUnpin,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets("the dock renders one pill per pin and the focused pin's "
      'content below', (final tester) async {
    await _pump(
      tester,
      ViewLayout(
        tabs: const ['stub:a'],
        pinned: const ['stub:a', 'stub:b'],
        dockFocus: 'stub:a',
      ),
    );

    expect(find.byKey(const ValueKey('view.dock')), findsOneWidget);
    expect(find.byKey(const ValueKey('view.dock.pill.stub:a')), findsOneWidget);
    expect(find.byKey(const ValueKey('view.dock.pill.stub:b')), findsOneWidget);
    // The focused pin's content hosts under its own key; the other
    // pin's body stays unmounted.
    expect(
      find.byKey(const ValueKey('view.dock.content.stub:a')),
      findsOneWidget,
    );
    expect(find.text('Body A'), findsOneWidget);
    expect(find.text('Body B'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a pill tap focuses that pin (its content swaps in)', (
    final tester,
  ) async {
    var focused = '';
    await _pump(
      tester,
      ViewLayout(
        tabs: const ['stub:a'],
        pinned: const ['stub:a', 'stub:b'],
        dockFocus: 'stub:a',
      ),
      onFocusPin: (final id) => focused = id,
    );

    await tester.tap(find.byKey(const ValueKey('view.dock.pill.stub:b')));
    expect(focused, 'stub:b');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the focused pill shows the unpin glyph; background pills '
      'wait for hover', (final tester) async {
    await _pump(
      tester,
      ViewLayout(
        tabs: const ['stub:a'],
        pinned: const ['stub:a', 'stub:b'],
        dockFocus: 'stub:a',
      ),
      onFocusPin: (_) {},
      onUnpin: (_) {},
    );

    expect(
      find.byKey(const ValueKey('view.dock.unpin.stub:a')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('view.dock.unpin.stub:b')),
      findsNothing,
    );
  });

  testWidgets('the focused pill carries the shared selected tint', (
    final tester,
  ) async {
    await _pump(
      tester,
      ViewLayout(
        tabs: const ['stub:a'],
        pinned: const ['stub:a', 'stub:b'],
        dockFocus: 'stub:a',
      ),
    );
    Color? fillOf(final String id) {
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(ValueKey('view.dock.pill.$id')),
          matching: find.byType(Container),
        ),
      );
      return container.decoration == null
          ? null
          : (container.decoration! as BoxDecoration).color;
    }

    // The same theme-derived token the pills read.
    final selected =
        tester.element(find.byKey(const ValueKey('view.dock'))).shellSelected;
    expect(fillOf('stub:a'), selected);
    expect(fillOf('stub:b'), isNull);
  });

  testWidgets('the unpin glyph reports the unpin intent', (final tester) async {
    var unpinned = '';
    await _pump(
      tester,
      ViewLayout(
        tabs: const ['stub:a'],
        pinned: const ['stub:a', 'stub:b'],
        dockFocus: 'stub:a',
      ),
      onUnpin: (final id) => unpinned = id,
    );

    await tester.tap(find.byKey(const ValueKey('view.dock.unpin.stub:a')));
    expect(unpinned, 'stub:a');
    expect(tester.takeException(), isNull);
  });
}
