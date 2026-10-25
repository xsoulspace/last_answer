import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/browser/browser_bridge.dart';
import 'package:lastanswer/browser/browser_engine.dart';
import 'package:lastanswer/browser/workspace_browser.dart';

final class _FakeEngine implements BrowserEngine {
  final List<Uri> loaded = <Uri>[];
  int backCalls = 0;
  int forwardCalls = 0;
  int reloadCalls = 0;
  bool backAvailable = true;
  bool forwardAvailable = true;

  @override
  Future<void> load(Uri url) async => loaded.add(url);

  @override
  Future<void> goBack() async => backCalls++;

  @override
  Future<void> goForward() async => forwardCalls++;

  @override
  Future<void> reload() async => reloadCalls++;

  @override
  Future<bool> canGoBack() async => backAvailable;

  @override
  Future<bool> canGoForward() async => forwardAvailable;
}

void main() {
  testWidgets('address entry opens a typed address in the view', (tester) async {
    final engine = _FakeEngine();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspaceBrowser(
            viewBuilder: (context, bridge) {
              bridge.attachEngine(engine);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('browser.address')), 'https://example.com/x');
    await tester.tap(find.byKey(const Key('browser.go')));
    await tester.pump();

    expect(engine.loaded, hasLength(1));
    expect(engine.loaded.single.toString(), 'https://example.com/x');
  });

  testWidgets('a refused address is reported and never loaded', (tester) async {
    final engine = _FakeEngine();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspaceBrowser(
            viewBuilder: (context, bridge) {
              bridge.attachEngine(engine);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('browser.address')),
      'javascript:alert(1)',
    );
    await tester.tap(find.byKey(const Key('browser.go')));
    await tester.pump();

    expect(engine.loaded, isEmpty);
    expect(find.byKey(const Key('browser.error')), findsOneWidget);
  });

  testWidgets('the initial address is loaded on open', (tester) async {
    final engine = _FakeEngine();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspaceBrowser(
            initialUrl: Uri.parse('http://localhost:8080/'),
            viewBuilder: (context, bridge) {
              bridge.attachEngine(engine);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(engine.loaded, hasLength(1));
    expect(engine.loaded.single.host, 'localhost');
  });

  testWidgets('back, forward and reload reach the engine', (tester) async {
    final engine = _FakeEngine();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspaceBrowser(
            viewBuilder: (context, bridge) {
              bridge.attachEngine(engine);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('browser.reload')));
    await tester.pump();
    expect(engine.reloadCalls, 1);

    // History flags are read from the engine after a navigation, so the
    // back/forward controls become available.
    await tester.enterText(
      find.byKey(const Key('browser.address')),
      'https://example.com/x',
    );
    await tester.tap(find.byKey(const Key('browser.go')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('browser.back')));
    await tester.pumpAndSettle();
    expect(engine.backCalls, 1);

    await tester.tap(find.byKey(const Key('browser.forward')));
    await tester.pumpAndSettle();
    expect(engine.forwardCalls, 1);
  });

  testWidgets('the view reports the page title', (tester) async {
    late BrowserBridge bridgeRef;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspaceBrowser(
            viewBuilder: (context, bridge) {
              bridgeRef = bridge;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    bridgeRef.reportTitle('Example Domain');
    await tester.pump();

    expect(find.text('Example Domain'), findsOneWidget);
  });
}
