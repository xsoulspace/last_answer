import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lastanswer/parsers/hive_parser.dart' as hive_parser;
import 'package:lastanswer/parsers/isar_parser.dart' as isar_parser;

/// Simple library facade for existing parsers. This package provides a
/// `parseAndPopulate` entry point used by `migrate()` to discover archive
/// files and parse them. For now this uses a conservative scanner of the
/// current working directory and common platform paths.
Future<void> parseAndPopulate() async {
  final List<File> candidates = [];
  // heuristics: current dir and common document paths
  candidates.addAll(Directory.current.listSync().whereType<File>());

  final List<String> projectsJson = [];

  for (final file in candidates) {
    final path = file.path;
    try {
      if (path.endsWith('.isar')) {
        final bytes = file.readAsBytesSync();
        final meta = isar_parser.parseIsarFromBytes(bytes);
        // Collect any JSON preview objects found by the parser
        final preview = meta['jsonObjectsPreview'];
        if (preview is List) {
          for (final obj in preview) {
            if (obj is Map) projectsJson.add(jsonEncode(obj));
          }
        }
        print('Parsed isar $path: metaKeys=${meta.keys.toList()}');
      }
      if (path.endsWith('.hive')) {
        final bytes = file.readAsBytesSync();
        final data = hive_parser.parseHiveFromBytes(bytes);
        for (final v in data.values) {
          if (v is Map) {
            projectsJson.add(jsonEncode(v));
          } else if (v is String) {
            try {
              final decoded = jsonDecode(v);
              if (decoded is Map) projectsJson.add(jsonEncode(decoded));
            } catch (_) {}
          }
        }
        print('Parsed hive $path: entries=${data.length}');
      }
    } catch (e) {
      print('Parser error for $path: $e');
    }
  }

  if (projectsJson.isNotEmpty) {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('webProjects', projectsJson);
      print('Wrote ${projectsJson.length} project(s) to SharedPreferences:webProjects');
    } catch (e) {
      print('Failed to write parsed projects to SharedPreferences: $e');
    }
  }
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
