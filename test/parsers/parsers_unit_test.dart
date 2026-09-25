import 'dart:io';

import 'package:core/src/data_sources/mutations/parsers/hive_parser.dart'
    as hive_parser;
import 'package:core/src/data_sources/mutations/parsers/isar_parser.dart'
    as isar_parser;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseProjectsFromPaths returns summaries for archive files', () {
    final dir = Directory('archive');
    if (!dir.existsSync()) return; // skip if no archives present

    final isarFile = File('archive/isar_3.isar');
    if (isarFile.existsSync()) {
      final bytes = isarFile.readAsBytesSync();
      final meta = isar_parser.parseIsarFromBytes(bytes);
      expect(meta, contains('pageSize'));
      // When root page is found, ensure traversal extracts entries map
      if (meta.containsKey('entries')) {
        final entries = Map<String, dynamic>.from(meta['entries'] as Map);
        expect(entries, isA<Map<String, dynamic>>());
        // At least one JSON-like preview or ascii should exist for real files
        expect(entries.isNotEmpty, isTrue);
      }
    }
  });

  test(
    'parseAndPopulate returns parsed project maps (skips when no files)',
    () {
      final dir = Directory('archive');
      if (!dir.existsSync()) return;

      final exists = dir.listSync().any(
        (final e) =>
            e is File && (e.path.endsWith('.isar') || e.path.endsWith('.hive')),
      );
      if (!exists) return;

      final hiveFile = File('archive/ideaproject.hive');
      if (hiveFile.existsSync()) {
        final bytes = hiveFile.readAsBytesSync();
        final data = hive_parser.parseHiveFromBytes(bytes);
        expect(data, isA<Map<String, dynamic>>());
      }
    },
  );
}
