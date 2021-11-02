part of 'utils.dart';

/// Returns what version of layout needs to use
final isDesktop = defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows;

final isNativeDesktop = Platform.isMacOS || Platform.isLinux;

final isAppleDevice = defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.iOS;
