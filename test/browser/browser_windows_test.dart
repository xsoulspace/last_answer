import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/browser/browser_bridge.dart';
import 'package:lastanswer/browser/browser_engine.dart';
import 'package:lastanswer/browser/browser_windows.dart';

final class _Engine implements BrowserEngine {
  final loaded = <Uri>[];
  int reloads = 0;
  @override
  Future<void> load(Uri url) async => loaded.add(url);
  @override
  Future<void> reload() async => reloads++;
  @override
  Future<void> goBack() async {}
  @override
  Future<void> goForward() async {}
  @override
  Future<bool> canGoBack() async => false;
  @override
  Future<bool> canGoForward() async => false;
}

void main() {
  test(
    'navigation selects the mounted engine and reports dispatch only',
    () async {
      final bridge = BrowserBridge();
      final engine = _Engine();
      bridge.attachEngine(engine);
      final id = BrowserWindows.register(bridge);
      addTearDown(() => BrowserWindows.unregister(id));
      final result = await BrowserWindows.act(
        action: 'navigate',
        windowId: id,
        address: 'http://localhost:1234/page',
      );
      expect(result['dispatched'], true);
      expect(engine.loaded.single.path, '/page');
      expect(BrowserWindows.states.single['loading'], true);
      bridge.reportError('connection refused');
      expect(BrowserWindows.states.single['error'], 'connection refused');
    },
  );

  test(
    'multiple windows require selection and stale ids cannot retarget',
    () async {
      final first = _Engine();
      final second = _Engine();
      final a = BrowserWindows.register(BrowserBridge()..attachEngine(first));
      final b = BrowserWindows.register(BrowserBridge()..attachEngine(second));
      addTearDown(() {
        BrowserWindows.unregister(a);
        BrowserWindows.unregister(b);
      });
      expect(
        (await BrowserWindows.act(action: 'reload'))['error'],
        'browser_window_ambiguous',
      );
      await BrowserWindows.act(action: 'reload', windowId: b);
      expect(first.reloads, 0);
      expect(second.reloads, 1);
      BrowserWindows.unregister(b);
      expect(
        (await BrowserWindows.act(action: 'reload', windowId: b))['error'],
        'browser_window_unknown',
      );
      expect(first.reloads, 0);
    },
  );

  test(
    'navigation refuses executable addresses and unattached windows',
    () async {
      final bridge = BrowserBridge();
      final id = BrowserWindows.register(bridge);
      addTearDown(() => BrowserWindows.unregister(id));
      expect(
        (await BrowserWindows.act(action: 'reload', windowId: id))['error'],
        'browser_not_ready',
      );
      final engine = _Engine();
      bridge.attachEngine(engine);
      expect(
        (await BrowserWindows.act(
          action: 'navigate',
          windowId: id,
          address: 'javascript:alert(1)',
        ))['error'],
        'browser_address_refused',
      );
      expect(engine.loaded, isEmpty);
    },
  );
}
