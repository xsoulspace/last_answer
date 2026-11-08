/// The macOS window-drag seam (DESIGN.md v2 — the title bar is gone):
/// with the tab strip as the window's only top row, the native drag
/// region is the strip's empty chrome. Flutter content under the
/// transparent titlebar receives its own events, so the shell marks its
/// drag surfaces explicitly: a pan anywhere on a [WindowDragRegion]
/// asks the native side to `performDrag(with:)` (the AppKit-sanctioned
/// call — the same one window_manager ships). Double-tap zooms, the
/// macOS titlebar idiom.
///
/// Every other platform: a no-op wrapper (mobile windows do not drag).
library;

import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _kWindowChannel = MethodChannel('dev.lastanswer/window');

/// Asks the native window to start a drag from the current event.
/// Silently ignored off macOS and in tests (no plugin bound).
Future<void> startWindowDrag() async {
  if (defaultTargetPlatform != TargetPlatform.macOS) return;
  try {
    await _kWindowChannel.invokeMethod<void>('startDrag');
  } on PlatformException {
    // A window that cannot drag is honest absence, never a crash.
  } on MissingPluginException {
    // Test bindings and non-macOS hosts.
  }
}

/// Asks the native window to zoom (the double-click-a-titlebar idiom).
Future<void> zoomWindow() async {
  if (defaultTargetPlatform != TargetPlatform.macOS) return;
  try {
    await _kWindowChannel.invokeMethod<void>('zoom');
  } on PlatformException {
    // Honest absence.
  } on MissingPluginException {
    // Test bindings.
  }
}

/// A region of window chrome that drags the window: pan starts the
/// native drag, double-tap zooms. Child buttons keep their taps (a tap
/// never becomes a pan).
final class WindowDragRegion extends StatelessWidget {
  const WindowDragRegion({required this.child, super.key});

  final Widget child;

  @override
  Widget build(final BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) return child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (final _) => unawaited(startWindowDrag()),
      onDoubleTap: () => unawaited(zoomWindow()),
      child: child,
    );
  }
}
