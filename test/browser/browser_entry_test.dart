import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/browser/browser_entry.dart';

void main() {
  testWidgets('the dialog entry opens the browser window', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openWorkspaceBrowser(
                context,
                // A fake view: the native view needs a platform channel.
                viewBuilder: (context, bridge) => const SizedBox.shrink(),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('browser.dialog')), findsOneWidget);
    expect(find.byKey(const Key('browser.address')), findsOneWidget);
    expect(find.byKey(const Key('browser.close')), findsOneWidget);
  });
}
