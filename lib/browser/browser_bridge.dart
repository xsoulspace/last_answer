/// Pure state bridge between the workspace browser widget and the embedded
/// view.
///
/// No plugin imports, no platform imports: the bridge is plain Dart so it can
/// be exercised in a widget test with a fake view, and so its rules cannot
/// drift with the plugin's API.
library;

import 'dart:async';

import 'package:lastanswer/browser/browser_engine.dart';

/// What the view reports back to the browser chrome.
final class BrowserBridge {
  /// Creates an empty bridge; a view attaches its engine to it.
  BrowserBridge();

  BrowserEngine? _engine;
  Uri? _pendingUrl;
  final List<void Function()> _listeners = <void Function()>[];

  Uri? _url;
  String? _title;
  double _progress = 0;
  String? _error;
  bool _loading = false;

  /// The address currently shown, when the view reported one.
  Uri? get url => _url;

  /// The page title, when the view reported one.
  String? get title => _title;

  /// Load progress in the range 0..1.
  double get progress => _progress;

  /// The last error message, when the view reported one.
  String? get error => _error;

  /// Whether a load is in flight.
  bool get isLoading => _loading;

  /// Whether an engine is attached.
  bool get isAttached => _engine != null;

  /// Primes the address without notifying listeners.
  ///
  /// Used before the first frame: the native view reads it to open the
  /// address directly, so the page is not loaded twice.
  void primeUrl(Uri url) {
    _url = url;
    _pendingUrl = url;
  }

  /// Takes the pending address, if any, leaving the bridge without one.
  Uri? takePendingUrl() {
    final pending = _pendingUrl;
    _pendingUrl = null;
    return pending;
  }

  /// Registers a listener notified whenever the reported state changes.
  void addListener(void Function() listener) => _listeners.add(listener);

  /// Whether a pending address waits for an engine.
  bool get hasPendingUrl => _pendingUrl != null;

  /// Removes a listener registered with [addListener].
  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notify() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }

  /// Registers the engine. The initial address, if any, is loaded now.
  void attachEngine(BrowserEngine engine) {
    _engine = engine;
    final pending = _pendingUrl;
    _pendingUrl = null;
    if (pending != null) {
      unawaited(_load(engine, pending));
    }
  }

  /// Detaches the engine; further commands are ignored until re-attached.
  void detachEngine() {
    _engine = null;
  }

  /// Loads [url] in the view.
  void load(Uri url) {
    _url = url;
    _error = null;
    _loading = true;
    _progress = 0;
    _notify();
    final engine = _engine;
    if (engine == null) {
      _pendingUrl = url;
      return;
    }
    unawaited(_load(engine, url));
  }

  Future<void> _load(BrowserEngine engine, Uri url) async {
    try {
      await engine.load(url);
    } on Object catch (error) {
      reportError('$error');
    }
  }

  /// Goes back one entry.
  Future<void> goBack() async {
    final engine = _engine;
    if (engine == null) return;
    await engine.goBack();
  }

  /// Goes forward one entry.
  Future<void> goForward() async {
    final engine = _engine;
    if (engine == null) return;
    await engine.goForward();
  }

  /// Reloads the current page.
  Future<void> reload() async {
    final engine = _engine;
    if (engine == null) return;
    _loading = true;
    _progress = 0;
    _error = null;
    await engine.reload();
  }

  /// Whether the engine can go back.
  Future<bool> canGoBack() async => await _engine?.canGoBack() ?? false;

  /// Whether the engine can go forward.
  Future<bool> canGoForward() async => await _engine?.canGoForward() ?? false;

  /// Reports the page title from the view.
  void reportTitle(String? title) {
    _title = title;
    _notify();
  }

  /// Reports the current address from the view.
  void reportUrl(Uri? url) {
    if (url != null) _url = url;
    _notify();
  }

  /// Reports load progress from the view (0..1).
  void reportProgress(double progress) {
    _progress = progress < 0 ? 0 : (progress > 1 ? 1 : progress);
    _notify();
  }

  /// Reports a load error from the view, or clears it when [message] is null.
  void reportError(String? message) {
    _error = message;
    if (message != null) _loading = false;
    _notify();
  }

  /// Reports that loading finished.
  void reportLoadFinished() {
    _loading = false;
    _progress = 1;
    _notify();
  }

  /// Reports that a new load started.
  void reportLoadStarted() {
    _loading = true;
    _progress = 0;
    _notify();
  }
}
