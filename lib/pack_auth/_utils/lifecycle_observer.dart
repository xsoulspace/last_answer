import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleObserver({
    this.onScreenLocked,
    this.onScreenUnlocked,
  });
  final VoidCallback? onScreenLocked;
  final VoidCallback? onScreenUnlocked;

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onScreenUnlocked?.call();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      default:
        onScreenLocked?.call();
    }
  }
}
