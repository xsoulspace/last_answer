import 'package:path_provider/path_provider.dart';

/// The project-scope base on IO platforms: the app-support directory,
/// next to the agent config document.
///
/// ADR 0107 — this is NOT a world home. It is Last Answer's project
/// scope inside the realm's one world (whose control store lives under
/// `~/.xsoulspace/worlds/<realm id>/coordination`); only the durable
/// threads are sealed to this scope.
Future<String> resolveProjectScopeBase() async {
  final support = await getApplicationSupportDirectory();
  return support.path;
}
