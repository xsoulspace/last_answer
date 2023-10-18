part of 'utils.dart';

/// Returns what version of layout needs to use
/// May return true for both native and web
final isDesktop = defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows;

final isNativeDesktop =
    (Platform.isMacOS || Platform.isLinux || Platform.isWindows) && !kIsWeb;
final nativeTransparentBackgroundSupported = Platform.isMacOS;

final isAppleDevice = defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.iOS;
