/// The engine contract the workspace browser drives.
///
/// The contract is intentionally tiny and free of plugin types: the native
/// view (flutter_inappwebview) implements it, and widget tests implement it
/// with a fake. Nothing here can reach app capabilities, JavaScript bridges
/// or the file system — a browser window renders a page, it does not act on
/// behalf of the app.
library;

/// The navigation handle exposed by an embedded browser engine.
abstract interface class BrowserEngine {
  /// Loads [url] in the current view.
  Future<void> load(Uri url);

  /// Goes one entry back in the engine's own history.
  Future<void> goBack();

  /// Goes one entry forward in the engine's own history.
  Future<void> goForward();

  /// Reloads the current page.
  Future<void> reload();

  /// Whether the engine can go back.
  Future<bool> canGoBack();

  /// Whether the engine can go forward.
  Future<bool> canGoForward();
}
