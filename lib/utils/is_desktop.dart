part of 'utils.dart';

/// Returns what version of layout needs to use
final isDesktop =
    kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
