/// The native embedded browser view (flutter_inappwebview 6.1.5).
///
/// This is the only file that knows about the plugin. The window chrome
/// above it never imports the plugin, so the chrome is testable without a
/// platform view and the plugin surface stays auditable in one place.
///
/// What this view deliberately does NOT do:
/// * it registers no JavaScript bridge (no app capability is exposed to the
///   page, and the page cannot call back into the app);
/// * it does not override TLS trust decisions (no `onReceivedServerTrustAuth
///   Request` handler) — the platform default applies;
/// * it does not auto-grant camera/microphone/geolocation permissions (no
///   `onPermissionRequest` handler) — the platform default applies;
/// * it does not open files, run project code, or start any server. Server
///   lifecycle belongs to whoever owns the server (Oka), not to a browser
///   window.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:lastanswer/browser/browser_bridge.dart';
import 'package:lastanswer/browser/browser_engine.dart';

/// Builds the native embedded view for the window.
Widget buildNativeBrowserView(BuildContext context, BrowserBridge bridge) =>
    NativeBrowserView(bridge: bridge);

/// The native view: an inline platform web view plus the engine handle the
/// window drives.
class NativeBrowserView extends StatefulWidget {
  const NativeBrowserView({required this.bridge, super.key});

  final BrowserBridge bridge;

  @override
  State<NativeBrowserView> createState() => _NativeBrowserViewState();
}

class _NativeBrowserViewState extends State<NativeBrowserView> {
  late final Uri _initialUrl =
      widget.bridge.takePendingUrl() ?? Uri.parse('about:blank');

  @override
  void dispose() {
    // The controller arrives asynchronously; the bridge holds the pending
    // address until then, so an initial URL is not lost.
    widget.bridge.detachEngine();
    super.dispose();
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    widget.bridge.attachEngine(_InAppBrowserEngine(controller, widget.bridge));
  }

  void _onTitleChanged(InAppWebViewController controller, String? title) {
    widget.bridge.reportTitle(title);
  }

  void _onProgressChanged(InAppWebViewController controller, int progress) {
    widget.bridge.reportProgress(progress / 100);
  }

  void _onLoadStart(InAppWebViewController controller, WebUri? url) {
    widget.bridge.reportLoadStarted();
    if (url != null) widget.bridge.reportUrl(url.uriValue);
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? url) {
    widget.bridge.reportLoadFinished();
    if (url != null) widget.bridge.reportUrl(url.uriValue);
  }

  void _onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    if (request.isForMainFrame ?? true) {
      widget.bridge.reportError(error.description);
    }
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url;
    if (url == null) return NavigationActionPolicy.ALLOW;
    final raw = url.rawValue.toLowerCase();
    final scheme = url.uriValue.scheme.toLowerCase();
    if (!navigationAction.isForMainFrame) return NavigationActionPolicy.ALLOW;
    // The blank bootstrap page is not navigation.
    if (scheme == 'about' && raw.startsWith('about:blank')) {
      return NavigationActionPolicy.ALLOW;
    }
    // Only web addresses navigate. `javascript:`, `data:` and `file:` links
    // inside a page are not address navigation and are refused.
    if (scheme == 'http' || scheme == 'https') {
      return NavigationActionPolicy.ALLOW;
    }
    return NavigationActionPolicy.CANCEL;
  }

  @override
  Widget build(BuildContext context) => InAppWebView(
    key: const Key('browser.native.view'),
    initialUrlRequest: URLRequest(url: WebUri(_initialUrl.toString())),
    onWebViewCreated: _onWebViewCreated,
    onTitleChanged: _onTitleChanged,
    onProgressChanged: _onProgressChanged,
    onLoadStart: _onLoadStart,
    onLoadStop: _onLoadStop,
    onReceivedError: _onReceivedError,
    shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
  );
}

/// The engine handle over an [InAppWebViewController].
class _InAppBrowserEngine implements BrowserEngine {
  _InAppBrowserEngine(this._controller, this._bridge);

  final InAppWebViewController _controller;
  final BrowserBridge _bridge;

  /// Runs a platform call, turning an unsupported operation into a reported
  /// error rather than an unhandled exception. The web implementation of the
  /// plugin supports a subset of the native calls.
  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } on Object catch (error) {
      _bridge.reportError('$error');
    }
  }

  @override
  Future<void> load(Uri url) => _guard(
    () => _controller.loadUrl(
      urlRequest: URLRequest(url: WebUri(url.toString())),
    ),
  );

  @override
  Future<void> goBack() => _guard(_controller.goBack);

  @override
  Future<void> goForward() => _guard(_controller.goForward);

  @override
  Future<void> reload() => _guard(_controller.reload);

  @override
  Future<bool> canGoBack() async {
    try {
      return await _controller.canGoBack();
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> canGoForward() async {
    try {
      return await _controller.canGoForward();
    } on Object {
      return false;
    }
  }
}
