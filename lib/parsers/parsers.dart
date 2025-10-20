import 'dart:convert';

import 'package:core/src/state_di/path_utils.dart' as path_utils;
import 'package:flutter/foundation.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/parsers/byte_utils.dart' as byte_utils;
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

  List<Map<String, dynamic>> extractJsonMapsFromString(final String s) {
    final out = <Map<String, dynamic>>[];
    final startIdx = s.indexOf(RegExp(r'[\{\[]'));
    if (startIdx < 0) return out;
    final limit = (startIdx + 20000).clamp(0, s.length);
    for (var end = startIdx + 1; end <= limit; end++) {
      try {
        final sub = s.substring(startIdx, end);
        final decoded = jsonDecode(sub);
        if (decoded is Map) {
          out.add(Map<String, dynamic>.from(decoded));
          return out;
        } else if (decoded is List) {
          for (final e in decoded) {
            if (e is Map) out.add(Map<String, dynamic>.from(e));
          }
          if (out.isNotEmpty) return out;
        }
      } catch (_) {
        // ignore and continue
      }
    }
    return out;
  }

  // Determine candidate directories using shared logic so tests and runtime
  // behave the same. Also include the repository-local `archive/` folder used
  // for production copies (useful when running locally or in CI).
  final candidateDirs = await path_utils.determineDbPaths();
  // Include local `archive/` directory only for non-release runs so tests
  // and local verification can use copied production files without
  // affecting release builds.
  if (!kReleaseMode) {
    final repoArchive = Directory('${Directory.current.path}/archive');
    if (repoArchive.existsSync()) candidateDirs.add(repoArchive.path);
  }

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
          // Prefer explicit JSON object previews but also try entries map
          // or ascii previews if available. Be tolerant - don't crash on
          // unexpected shapes from production files.
          final preview = meta['jsonObjectsPreview'];
          if (preview is List) {
            for (final obj in preview) {
              if (obj is Map) {
                projects.add(Map<String, dynamic>.from(obj));
              } else if (obj is String) {
                // try to extract JSON object(s) from longer strings
                try {
                  final decoded = jsonDecode(obj);
                  if (decoded is Map) {
                    projects.add(Map<String, dynamic>.from(decoded));
                    continue;
                  }
                } catch (_) {}

                final extracted = extractJsonMapsFromString(obj);
                for (final m in extracted) projects.add(m);
              }
            }
          }
          // If full entries were extracted by the Isar parser, try to
          // interpret them as JSON-like values too.
          final entries = meta['entries'];
          if (entries is Map) {
            for (final v in entries.values) {
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
          }
          print('Parsed isar $path: metaKeys=${meta.keys.toList()}');
        }
        if (path.endsWith('.hive')) {
          final bytes = await entity.readAsBytes();
          final data = hive_parser.parseHiveFromBytes(bytes);
          // Try to recover JSON objects from both parsed values and raw
          // ascii sequences present in the file bytes.
          for (final v in data.values) {
            // common shapes produced by the minimal hive parser include:
            // - Map (decoded object)
            // - String (utf8 decoded JSON)
            // - Map with ascii_preview / object / hex metadata
            if (v is Map) {
              // If parser produced an embedded object, prefer it.
              if (v.containsKey('object') && v['object'] is Map) {
                projects.add(Map<String, dynamic>.from(v['object'] as Map));
                continue;
              }
              // Try ascii previews if present to recover JSON fragments.
              if (v.containsKey('ascii_preview') &&
                  v['ascii_preview'] is List) {
                for (final s in v['ascii_preview'] as List) {
                  if (s is String) {
                    try {
                      final decoded = jsonDecode(s);
                      if (decoded is Map) {
                        projects.add(Map<String, dynamic>.from(decoded));
                        break;
                      }
                    } catch (_) {}
                  }
                }
              }
              // If the map itself looks like a JSON-like map, accept it.
              if (v.values.any(
                (final e) => e is String || e is num || e is Map,
              )) {
                try {
                  projects.add(Map<String, dynamic>.from(v));
                } catch (_) {}
              }
            } else if (v is String) {
              try {
                final decoded = jsonDecode(v);
                if (decoded is Map) {
                  projects.add(Map<String, dynamic>.from(decoded));
                  continue;
                }
              } catch (_) {}

              // Attempt to extract embedded JSON fragments from long strings
              final extracted = extractJsonMapsFromString(v);
              for (final m in extracted) projects.add(m);
            }
          }
          // Also scan raw bytes for ASCII JSON fragments that the frame
          // parser may have missed (useful for production Hive files).
          try {
            final ascii = byte_utils.extractAsciiStrings(
              Uint8List.fromList(bytes),
              minLen: 20,
              maxCount: 200,
            );
            for (final s in ascii) {
              final extracted = extractJsonMapsFromString(s);
              for (final m in extracted) projects.add(m);
            }
          } catch (_) {}
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
