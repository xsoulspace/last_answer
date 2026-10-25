/// The view seam of the embedded browser window.
///
/// The window chrome (address entry, progress, title, errors) is product code
/// and lives in `workspace_browser.dart`. The page itself is rendered by a
/// view that the window does not know about: the default one is the native
/// `flutter_inappwebview` view, and tests inject a fake.
library;

import 'package:flutter/widgets.dart';

import 'package:lastanswer/browser/browser_bridge.dart';

/// Builds the widget that renders the page.
///
/// The builder receives the [BrowserBridge]: the view attaches its engine to
/// it and reports progress, title, address and errors through it. A builder
/// that never attaches an engine yields a window that shows chrome only.
typedef BrowserViewBuilder =
    Widget Function(BuildContext context, BrowserBridge bridge);
