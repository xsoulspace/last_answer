part of 'utils.dart';

/// Returns what version of layout needs to use
/// TODO(arenukvern): fix case when web running on touch device
final isDesktop =
    kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
