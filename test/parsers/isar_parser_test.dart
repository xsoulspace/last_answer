import 'dart:io';

import 'package:core/src/state_di/parsers/isar_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isar parser reads meta from archive/isar_3.isar', () {
    final f = File('archive/isar_3.isar');
    if (!f.existsSync()) {
      // Skip if archive not present in this environment
      return;
    }
    final bytes = f.readAsBytesSync();
    final parsed = parseIsarFromBytes(bytes);
    expect(parsed, containsPair('pageSize', 4096));
    expect(parsed['activeTx'], anyOf(['page0', 'page1']));
    expect(parsed, contains('magic'));
  });
}
