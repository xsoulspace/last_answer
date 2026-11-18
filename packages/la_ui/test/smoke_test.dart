import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_ui/la_ui.dart';

/// Kit smoke tests: the primitives build, activate and honor the token law
/// without any Material ancestor (the component-carrier law's floor).
void main() {
  Widget host(final Widget child) => LaUiThemeProvider(
    theme: LaUiTheme.dark(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        // A real Navigator: dialogs/sheets push routes, toasts find the
        // root overlay — same contract the app provides.
        child: Navigator(
          onGenerateRoute: (_) =>
              PageRouteBuilder<void>(pageBuilder: (_, _, _) => child),
        ),
      ),
    ),
  );

  testWidgets('LaButton activates and renders its label', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: LaButton(
            label: 'Send',
            variant: LaButtonVariant.primary,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    expect(find.text('Send'), findsOneWidget);
    await tester.tap(find.text('Send'));
    expect(taps, 1);
  });

  testWidgets('disabled LaButton refuses activation', (tester) async {
    const taps = 0;
    await tester.pumpWidget(host(const Center(child: LaButton(label: 'Nope'))));
    await tester.tap(find.text('Nope'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('LaField types, shows placeholder and reports changes', (
    tester,
  ) async {
    final controller = TextEditingController();
    var changes = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: SizedBox(
            width: 300,
            child: LaField(
              controller: controller,
              placeholder: 'Write a beat…',
              onChanged: (_) => changes++,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Write a beat…'), findsOneWidget);
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'hello');
    // The controller notification lands during enterText; the rebuild that
    // hides the placeholder is the NEXT frame.
    await tester.pump();
    expect(controller.text, 'hello');
    expect(changes, greaterThan(0));
    // The placeholder hides once text lands.
    expect(find.text('Write a beat…'), findsNothing);
  });

  testWidgets('LaRow selects and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: LaRow(
            titleText: '#general',
            selected: true,
            onTap: () => taps++,
          ),
        ),
      ),
    );
    expect(find.text('#general'), findsOneWidget);
    await tester.tap(find.text('#general'));
    expect(taps, 1);
  });

  testWidgets('showLaConfirm confirms', (tester) async {
    late Future<bool> result;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Center(
            child: LaButton(
              label: 'Delete',
              onPressed: () {
                result = showLaConfirm(
                  context,
                  title: 'Delete channel?',
                  message: 'The journal keeps every beat.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete channel?'), findsOneWidget);
    // Confirm is the second 'Delete' (action row).
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('LaToast shows on the root overlay', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Center(
            child: LaButton(
              label: 'Ping',
              onPressed: () => LaToast.show(
                context,
                message: 'Saved',
                variant: LaToastVariant.success,
                duration: const Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ping'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Saved'), findsOneWidget);
    // Drain the auto-dismiss timers so teardown sees no pending work.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('squircle path closes and spans the rect', (tester) async {
    final path = squirclePath(
      const Rect.fromLTWH(0, 0, 100, 40),
      borderRadius: BorderRadius.circular(8),
    );
    final bounds = path.getBounds();
    expect(bounds.width, closeTo(100, 0.001));
    expect(bounds.height, closeTo(40, 0.001));
  });

  // The spinner's motion decision must never do an inherited lookup during
  // initState (the framework assert caught by lane A); both paths mount.
  testWidgets('LaSpinner mounts normal and under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(host(const Center(child: LaSpinner())));
    await tester.pump();
    expect(find.byType(LaSpinner), findsOneWidget);
    await tester.pumpWidget(
      LaUiThemeProvider(
        theme: LaUiTheme.dark(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (_, _, _) => const Center(child: LaSpinner()),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(LaSpinner), findsOneWidget);
  });

  testWidgets('LaSwitch toggles', (tester) async {
    var value = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: LaSwitch(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(LaSwitch));
    await tester.pump();
    expect(value, isTrue);
  });

  // ----------------------------------------------------------------
  // LaSelect / LaMenuAnchor — the dropdown guards (zero-row menus used
  // to open as an 8 px chrome sliver; empty selects now go dormant).
  // ----------------------------------------------------------------

  /// Host with the portal theater mounted above the Navigator — what the
  /// app provides, and what LaMenuAnchor needs to actually open.
  Widget portalHost(final Widget child) => LaUiThemeProvider(
    theme: LaUiTheme.dark(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Portal(
          child: Navigator(
            onGenerateRoute: (_) =>
                PageRouteBuilder<void>(pageBuilder: (_, _, _) => child),
          ),
        ),
      ),
    ),
  );

  testWidgets('LaSelect with no items goes dormant and names the gap', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: SizedBox(
            width: 300,
            child: LaSelect<String>(
              placeholder: 'default provider',
              emptyHint: 'No providers configured',
              items: [],
            ),
          ),
        ),
      ),
    );
    // No anchor wired at all: tapping can never open a menu.
    expect(find.byType(LaMenuAnchor), findsNothing);
    expect(find.byType(LaTooltip), findsOneWidget);
    await tester.tap(find.text('default provider'), warnIfMissed: false);
    await tester.pump();
    expect(find.byType(LaMenu), findsNothing);
  });

  testWidgets('LaSelect opens, lists entries and reports selection', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      portalHost(
        Center(
          child: SizedBox(
            width: 300,
            child: LaSelect<String>(
              placeholder: 'pick',
              items: const [
                LaSelectItem(value: 'a', label: 'Alpha'),
                LaSelectItem(value: 'b', label: 'Beta'),
              ],
              onChanged: (value) => picked = value,
            ),
          ),
        ),
      ),
    );
    // The 22rem height cap rides through to the popover (long model lists
    // scroll instead of growing past the window).
    final anchor = tester.widget<LaMenuAnchor>(find.byType(LaMenuAnchor));
    expect(anchor.maxHeight, 352);
    await tester.tap(find.text('pick'));
    await tester.pump();
    expect(find.byType(LaMenu), findsOneWidget);
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(picked, 'b');
    expect(find.byType(LaMenu), findsNothing);
  });

  testWidgets('LaMenuAnchor refuses to open with no entries', (tester) async {
    await tester.pumpWidget(
      portalHost(
        const Center(
          child: LaMenuAnchor(
            entries: [],
            child: SizedBox(width: 40, height: 28),
          ),
        ),
      ),
    );
    final state = tester.state<LaMenuAnchorState>(find.byType(LaMenuAnchor))
      ..open();
    await tester.pump();
    expect(state.isOpen, isFalse);
    expect(find.byType(LaMenu), findsNothing);
  });

  testWidgets('LaMenuAnchor closes when its entries empty while open', (
    tester,
  ) async {
    // Mutate INSIDE the route: Navigator caches its route pages, so a
    // second pumpWidget with a fresh Navigator never revisits the anchor.
    var entries = <LaMenuEntry>[const LaMenuItem(label: 'One')];
    void Function(void Function())? rebuild;
    await tester.pumpWidget(
      portalHost(
        StatefulBuilder(
          builder: (context, setBuilderState) {
            rebuild = setBuilderState;
            return Center(
              child: LaMenuAnchor(
                entries: entries,
                child: const SizedBox(width: 40, height: 28),
              ),
            );
          },
        ),
      ),
    );
    final state = tester.state<LaMenuAnchorState>(find.byType(LaMenuAnchor))
      ..open();
    await tester.pump();
    expect(state.isOpen, isTrue);
    rebuild!.call(() => entries = const []);
    await tester.pump();
    expect(state.isOpen, isFalse);
    expect(find.byType(LaMenu), findsNothing);
  });

  testWidgets('LaMenu arrow keys survive a zero-item entry list', (
    tester,
  ) async {
    await tester.pumpWidget(
      portalHost(
        Center(
          child: LaMenu(entries: const [], onEscape: () {}),
        ),
      ),
    );
    await tester.pump();
    // Focus(autofocus) holds the key events; with no rows this used to
    // throw IntegerDivisionByZeroException on the modulo.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
  });

  // ── The fallback-style gate ────────────────────────────────────────
  // The app's real host is MaterialApp, whose root DefaultTextStyle is
  // the framework error style (`decoration: underline` + yellow + double,
  // debugLabel 'fallback style; consider putting your text in a
  // Material'). Floating surfaces ride the root navigator's overlay,
  // ABOVE the chrome body's kit base type — each must install its own
  // DefaultTextStyle (LaDialog.build law) or every inheriting Text
  // visibly picks up the yellow double underline. These tests host the
  // kit under a REAL MaterialApp and assert the nearest DefaultTextStyle
  // of plain Texts is never the fallback.

  /// A host like the app's: MaterialApp under the theme provider.
  Widget materialHost(final Widget child) => LaUiThemeProvider(
    theme: LaUiTheme.dark(),
    child: MaterialApp(home: child),
  );

  /// The nearest DefaultTextStyle above [text] must not be the framework
  /// fallback (kit base type or an explicit style — never the error one).
  void expectKitBaseType(final WidgetTester tester, final String text) {
    final inherited = DefaultTextStyle.of(
      tester.element(find.text(text)),
    ).style;
    expect(
      inherited.debugLabel ?? '',
      isNot(contains('fallback style; consider putting your text in')),
      reason: "Text '$text' inherits MaterialApp's fallback style",
    );
    expect(
      inherited.decoration,
      isNot(TextDecoration.underline),
      reason: "Text '$text' inherits the yellow double underline",
    );
  }

  testWidgets('LaDialog blocks the MaterialApp fallback style', (tester) async {
    await tester.pumpWidget(
      materialHost(
        Builder(
          builder: (context) => Center(
            child: LaButton(
              label: 'Open',
              onPressed: () => showLaDialog<void>(
                context: context,
                builder: (_) =>
                    const LaDialog(titleText: 'Avatar', content: Text('Body')),
              ),
            ),
          ),
        ),
      ),
    );
    // Sanity: the host root really carries the error style — the
    // condition the surfaces must block.
    final rootStyle = DefaultTextStyle.of(
      tester.element(find.byType(Navigator)),
    ).style;
    expect(rootStyle.debugLabel, contains('fallback style'));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Body'), findsOneWidget);
    expectKitBaseType(tester, 'Body');
    expectKitBaseType(tester, 'Avatar');
  });

  testWidgets('LaSheet blocks the MaterialApp fallback style', (tester) async {
    await tester.pumpWidget(
      materialHost(
        Builder(
          builder: (context) => Center(
            child: LaButton(
              label: 'Open',
              onPressed: () => showLaSheet<void>(
                context: context,
                builder: (_) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Sheet body'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet body'), findsOneWidget);
    expectKitBaseType(tester, 'Sheet body');
  });

  testWidgets('LaMenu blocks the MaterialApp fallback style', (tester) async {
    await tester.pumpWidget(
      materialHost(
        Builder(
          builder: (context) => Center(
            child: LaButton(
              label: 'Menu',
              onPressed: () => showLaMenuAt(
                context,
                globalPosition: tester.getCenter(find.text('Menu')),
                entries: [
                  const LaMenuHeader('Edit'),
                  LaMenuItem(label: 'Cut', onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Menu'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Cut'), findsOneWidget);
    expectKitBaseType(tester, 'Cut');
    // The header carries an explicit style and still inherits the
    // surface's base type beneath it.
    expectKitBaseType(tester, 'Edit');
  });

  testWidgets('LaToast blocks the MaterialApp fallback style', (tester) async {
    await tester.pumpWidget(
      materialHost(
        Builder(
          builder: (context) => Center(
            child: LaButton(
              label: 'Ping',
              onPressed: () => LaToast.show(
                context,
                message: 'Saved',
                duration: const Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ping'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Saved'), findsOneWidget);
    expectKitBaseType(tester, 'Saved');
    // Drain the auto-dismiss timers so teardown sees no pending work.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Saved'), findsNothing);
  });
}
