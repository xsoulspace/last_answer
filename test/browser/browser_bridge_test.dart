import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/browser/browser_address.dart';
import 'package:lastanswer/browser/browser_bridge.dart';
import 'package:lastanswer/browser/browser_engine.dart';

/// A fake engine: it records what the window asked for and never touches a
/// platform view.
final class FakeEngine implements BrowserEngine {
  final List<Uri> loaded = <Uri>[];
  int backCalls = 0;
  int forwardCalls = 0;
  int reloadCalls = 0;
  bool backAvailable = false;
  bool forwardAvailable = false;

  @override
  Future<void> load(Uri url) {
    loaded.add(url);
    return Future<void>.value();
  }

  @override
  Future<void> goBack() {
    backCalls++;
    return Future<void>.value();
  }

  @override
  Future<void> goForward() {
    forwardCalls++;
    return Future<void>.value();
  }

  @override
  Future<void> reload() {
    reloadCalls++;
    return Future<void>.value();
  }

  @override
  Future<bool> canGoBack() async => backAvailable;

  @override
  Future<bool> canGoForward() async => forwardAvailable;
}

void main() {
  group('BrowserBridge', () {
    test('holds the pending address until an engine attaches', () async {
      final bridge = BrowserBridge();
      bridge.load(Uri.parse('https://example.com/a'));

      final engine = FakeEngine();
      bridge.attachEngine(engine);

      expect(engine.loaded, hasLength(1));
      expect(engine.loaded.single.host, 'example.com');
    });

    test('reports progress, title, address and errors', () {
      final bridge = BrowserBridge();
      bridge.reportTitle('Example');
      bridge.reportUrl(Uri.parse('https://example.com/'));
      bridge.reportProgress(0.5);
      bridge.reportError('boom');

      expect(bridge.title, 'Example');
      expect(bridge.url.toString(), 'https://example.com/');
      expect(bridge.progress, 0.5);
      expect(bridge.error, 'boom');
      expect(bridge.isLoading, isFalse);
    });

    test('notifies listeners on state change', () {
      final bridge = BrowserBridge();
      var notifications = 0;
      bridge.addListener(() => notifications++);
      bridge.reportTitle('x');
      bridge.reportProgress(0.2);
      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('navigates back, forward and reload through the engine', () async {
      final bridge = BrowserBridge();
      final engine = FakeEngine();
      bridge.attachEngine(engine);

      await bridge.goBack();
      await bridge.goForward();
      await bridge.reload();

      expect(engine.backCalls, 1);
      expect(engine.forwardCalls, 1);
      expect(engine.reloadCalls, 1);
    });
  });

  group('address rules', () {
    test('only http and https reach the engine', () {
      final address = parseBrowserAddress('javascript:alert(1)');
      expect(address.isAccepted, isFalse);
      expect(isNavigableAddress(address.url), isFalse);
    });
  });
}
