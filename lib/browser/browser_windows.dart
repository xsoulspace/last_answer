import 'package:lastanswer/browser/browser_address.dart';
import 'package:lastanswer/browser/browser_bridge.dart';

/// Mounted browser windows, addressed independently of widget positions.
/// Navigation never executes project commands or acquires server ownership.
final class BrowserWindows {
  BrowserWindows._();

  static int _nextId = 0;
  static final String _session = DateTime.now().microsecondsSinceEpoch
      .toRadixString(36);
  static final Map<String, BrowserBridge> _windows = {};

  static String register(BrowserBridge bridge) {
    final id = 'browser-$_session-${++_nextId}';
    _windows[id] = bridge;
    return id;
  }

  static void unregister(String id) => _windows.remove(id);

  static List<Map<String, Object?>> get states => [
    for (final entry in _windows.entries)
      {
        'windowId': entry.key,
        'url': entry.value.url?.toString(),
        'title': entry.value.title,
        'loading': entry.value.isLoading,
        'progress': entry.value.progress,
        'error': entry.value.error,
        'attached': entry.value.isAttached,
      },
  ];

  static Future<Map<String, Object?>> act({
    required String action,
    String? windowId,
    String? address,
  }) async {
    if (action == 'list') return {'ok': true, 'windows': states};
    final id = windowId ?? (_windows.length == 1 ? _windows.keys.single : null);
    final bridge = _windows[id];
    if (bridge == null) {
      return {
        'ok': false,
        'error': _windows.isEmpty
            ? 'browser_not_open'
            : windowId == null
            ? 'browser_window_ambiguous'
            : 'browser_window_unknown',
        'windows': states,
      };
    }
    if (!bridge.isAttached) {
      return {'ok': false, 'error': 'browser_not_ready', 'windowId': id};
    }
    switch (action) {
      case 'navigate':
        final parsed = parseBrowserAddress(address ?? '');
        if (!parsed.isAccepted) {
          return {'ok': false, 'error': 'browser_address_refused'};
        }
        bridge.load(parsed.url!);
      case 'back':
        await bridge.goBack();
      case 'forward':
        await bridge.goForward();
      case 'reload':
        await bridge.reload();
      default:
        return {'ok': false, 'error': 'browser_action_unknown'};
    }
    // A dispatched navigation is not a successful page load. Read the
    // eventual title/loading/error state or inspect the actual page.
    return {'ok': true, 'dispatched': true, 'windowId': id, 'windows': states};
  }
}
