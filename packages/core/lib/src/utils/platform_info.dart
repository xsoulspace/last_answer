import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class PlatformInfo {
  PlatformInfo._();
  static const _desktopPlatforms = [
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ];
  static const _mobilePlatforms = [TargetPlatform.android, TargetPlatform.iOS];
  static bool get isNativeDesktop => isNativeWebDesktop && isNative;
  static bool get isNativeWebDesktop =>
      _desktopPlatforms.contains(defaultTargetPlatform);
  static bool get isNativeMobile => isNativeWebMobile && isNative;
  static bool get isNativeWebMobile =>
      _mobilePlatforms.contains(defaultTargetPlatform);

  static double get pixelRatio =>
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;
  static bool get isWeb => kIsWeb;
  static bool get isNative => !isWeb;
  static bool get isTransparentBackgroundSupported => isMacOS;
  static bool get isCupertino => isIOS || isMacOS;
  static Future<bool> get isConnected async =>
      InternetConnectionChecker.createInstance().hasConnection;
  static Future<bool> get isDisconnected async => (await isConnected) == false;
}
