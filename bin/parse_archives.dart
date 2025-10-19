import 'dart:convert';
import 'dart:io';

import 'package:lastanswer/parsers/__init.dart' as parsers;

Future<void> main() async {
  final dir = Directory('archive');
  if (!dir.existsSync()) {
    print(jsonEncode({'error': 'archive directory not found'}));
    return;
  }

  final results = <String, dynamic>{};
  for (final name in ['isar_3.isar', 'isar_4.isar', 'ideaproject.hive']) {
    final file = File('${dir.path}/$name');
    if (!file.existsSync()) continue;
    try {
      final bytes = await file.readAsBytes();
      dynamic parsed;
      if (name.endsWith('.isar')) {
        parsed = parsers.parseIsarFromBytes(bytes);
      } else if (name.endsWith('.hive')) {
        parsed = parsers.parseHiveFromBytes(bytes);
      } else {
        parsed = 'unsupported';
      }
      // add ascii extraction for manual inspection
      parsed = {
        'parsed': parsed,
        'ascii': parsers.extractAsciiStrings(bytes, minLen: 6).take(50).toList(),
      };
      results[name] = parsed;
    } catch (e, st) {
      results[name] = {
        'error': e.toString(),
        'stack': st.toString().split('\n').take(5).join('\n'),
      };
    }
  }

  // Pretty print JSON
  const encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(results));
}
