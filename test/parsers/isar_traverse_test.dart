import 'dart:convert';
import 'dart:typed_data';

import 'package:core/src/state_di/parsers/isar_parser.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _u16(final int v) => Uint8List.fromList([v & 0xFF, (v >> 8) & 0xFF]);
Uint8List _u32(final int v) => Uint8List.fromList([
  v & 0xFF,
  (v >> 8) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 24) & 0xFF,
]);

Uint8List buildLeafPage(final int pageSize, final Map<String, String> entries) {
  final b = BytesBuilder();
  // pageType = 0x02 (leaf)
  b.add([0x02]);
  b.add(_u16(entries.length));
  // reserved one byte to make header 3 bytes
  b.add([0]);
  entries.forEach((final k, final v) {
    final kb = utf8.encode(k);
    final vb = utf8.encode(v);
    b.add(_u32(kb.length));
    b.add(kb);
    b.add(_u32(vb.length));
    b.add(vb);
  });
  final content = b.toBytes();
  if (content.length > pageSize)
    throw Exception('page overflow in test builder');
  final page = Uint8List(pageSize);
  page.setAll(0, content);
  return page;
}

void main() {
  test('traverseBTree parses synthetic single leaf page', () {
    const pageSize = 4096;
    const rootPage = 2;
    final entries = {'name': 'alice', 'city': 'wonderland'};
    final page = buildLeafPage(pageSize, entries);

    // Build file bytes with rootPage at index 2
    const totalPages = rootPage + 1;
    final fileBytes = Uint8List(totalPages * pageSize);
    fileBytes.setAll(rootPage * pageSize, page);

    final parsed = traverseBTree(fileBytes, rootPage);
    expect(parsed.length, equals(entries.length));
    expect(parsed['name'], equals('alice'));
    expect(parsed['city'], equals('wonderland'));
  });
}
