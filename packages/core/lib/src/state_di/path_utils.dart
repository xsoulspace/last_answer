import 'package:flutter/foundation.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:path_provider/path_provider.dart';

/// Determine candidate directories where DB files might live on this platform.
/// Mirrors the logic previously present in `migrator.dart` so both the app
/// runtime migrator and offline tooling can reuse the same resolution.
Future<List<String>> determineDbPaths() async {
  final paths = <String>[];
  if (kIsWeb) {
    paths.add('/assets/${Envs.isarDbName}');
    return paths;
  }

  try {
    if (Platform.isIOS) {
      paths.add((await getLibraryDirectory()).path);
    } else {
      paths.add((await getApplicationDocumentsDirectory()).path);
    }
  } catch (_) {
    // fallback to current working directory if platform APIs fail
    paths.add(Directory.current.path);
  }

  return paths;
}
