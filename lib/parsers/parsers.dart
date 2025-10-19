import 'dart:convert';

import 'package:core/src/state_di/path_utils.dart' as path_utils;
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/parsers/hive_parser.dart' as hive_parser;
import 'package:lastanswer/parsers/isar_parser.dart' as isar_parser;
// shared_preferences previously used for migration convenience; no longer used

/// Simple library facade for existing parsers. This package provides a
/// `parseAndPopulate` entry point used by `migrate()` to discover archive
/// files and parse them. For now this uses a conservative scanner of the
/// current working directory and common platform paths.
/// Parse known DB files and return a list of parsed project JSON-like maps.
///
/// This used to write results into `SharedPreferences`. For migration we now
/// return parsed project objects so callers (migrator) can persist them via
/// application data sources.
Future<List<Map<String, dynamic>>> parseAndPopulate() async {
  final List<Map<String, dynamic>> projects = [];

  // Determine candidate directories using shared logic so tests and runtime
  // behave the same.
  final candidateDirs = await path_utils.determineDbPaths();

  for (final dirPath in candidateDirs) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync().whereType<File>()) {
      final path = entity.path;
      try {
        if (path.endsWith('.isar')) {
          // For now read small files fully; future work: streaming parse.
          final bytes = await entity.readAsBytes();
          final meta = isar_parser.parseIsarFromBytes(bytes);
          final preview = meta['jsonObjectsPreview'];
          if (preview is List) {
            for (final obj in preview) {
              if (obj is Map) projects.add(Map<String, dynamic>.from(obj));
            }
          }
          print('Parsed isar $path: metaKeys=${meta.keys.toList()}');
        }
        if (path.endsWith('.hive')) {
          final bytes = await entity.readAsBytes();
          final data = hive_parser.parseHiveFromBytes(bytes);
          for (final v in data.values) {
            if (v is Map) {
              projects.add(Map<String, dynamic>.from(v));
            } else if (v is String) {
              try {
                final decoded = jsonDecode(v);
                if (decoded is Map)
                  projects.add(Map<String, dynamic>.from(decoded));
              } catch (_) {}
            }
          }
          print('Parsed hive $path: entries=${data.length}');
        }
      } catch (e, st) {
        // continue on parse error but keep a trace for debugging
        print('Parser error for $path: $e\n$st');
      }
    }
  }
  return projects;
}

/// Convenience: parse projects from provided paths (used in tests later).
Future<List<Map<String, dynamic>>> parseProjectsFromPaths(
  final List<String> paths,
) async {
  final out = <Map<String, dynamic>>[];
  for (final p in paths) {
    final f = File(p);
    if (!f.existsSync()) continue;
    if (p.endsWith('.isar')) {
      final meta = isar_parser.parseIsarFromBytes(f.readAsBytesSync());
      out.add({'path': p, 'meta': meta});
    } else if (p.endsWith('.hive')) {
      final data = hive_parser.parseHiveFromBytes(f.readAsBytesSync());
      out.add({'path': p, 'entriesCount': data.length});
    }
  }
  return out;
}
