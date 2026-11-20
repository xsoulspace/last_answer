// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

/// Determine candidate directories where DB files might live on this platform.
/// Mirrors the logic previously present in `migrator.dart` so both the app
/// runtime migrator and offline tooling can reuse the same resolution.
Future<List<String>> determineDbPaths() async {
  final paths = <String>[];
  if (kIsWeb) {
    paths.add('/assets/isar_4');
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

/// Determine candidate directories where DB files might live on this platform.
/// Mirrors the logic previously present in `migrator.dart` so both the app
/// runtime migrator and offline tooling can reuse the same resolution.
Future<void> removeDbFiles() async {
  final paths = <String>[];
  if (kIsWeb) {
    paths.add('/assets/isar_4');
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

  for (final path in paths) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is File &&
          (entity.path.endsWith('.isar') || entity.path.endsWith('.hive'))) {
        try {
          entity.deleteSync();
        } catch (_) {
          // ignore errors deleting files
        }
      }
    }
  }
}
