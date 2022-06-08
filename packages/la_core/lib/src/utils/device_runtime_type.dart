import 'package:flutter/foundation.dart';

class DeviceRuntimeType {
  DeviceRuntimeType._();
  static final _instance = DeviceRuntimeType._();

  /// ********************************************
  /// *      Desktop
  /// ********************************************

  /// May return true for both native desktop and web browsers on the desktop
  static bool get isDesktop => _instance._isDesktop;
  bool? _isDesktopCache;
  bool get _isDesktop =>
      _isDesktopCache ??= defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows;

  static bool get isNativeDesktop => _instance._isNativeDesktop;
  bool? _isNativeDesktopCache;
  bool get _isNativeDesktop => _isNativeDesktopCache ??= _isDesktop && !kIsWeb;

  /// ********************************************
  /// *      Mobile
  /// ********************************************

  /// May return true for both native mobile and web browsers on the phone
  static bool get isMobile => _instance._isMobile;
  bool? _isMobileCache;
  bool get _isMobile => _isMobileCache ??= !isDesktop;

  /// ********************************************
  /// *      Other
  /// ********************************************

  /// May return true for both native mobile and web browsers on the phone
  static bool get isApple => _instance._isApple;
  bool? _isAppleCache;
  bool get _isApple =>
      _isAppleCache ??= defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.iOS;
}
