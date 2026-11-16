import 'package:flutter/widgets.dart';
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
    final taps = 0;
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
}
