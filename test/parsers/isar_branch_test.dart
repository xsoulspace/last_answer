import 'dart:convert';
import 'dart:typed_data';

import 'package:core/src/data_sources/mutations/parsers/isar_parser.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _u32(final int v) => Uint8List.fromList([
  v & 0xFF,
  (v >> 8) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 24) & 0xFF,
]);

Uint8List buildBranchPage(
  final int pageSize,
  final List<int> childPages,
  final List<String> keys,
) {
  final b = BytesBuilder();
  // pageType = 0x01 (branch)
  b.add([0x01]);
  b.add([childPages.length & 0xFF, (childPages.length >> 8) & 0xFF]);
  b.add([0]);
  for (var i = 0; i < childPages.length; i++) {
    b.add(_u32(childPages[i]));
    final key = i < keys.length ? utf8.encode(keys[i]) : <int>[];
    b.add(_u32(key.length));
    b.add(key);
  }
  final content = b.toBytes();
  if (content.length > pageSize)
    throw Exception('page overflow in test builder');
  final page = Uint8List(pageSize);
  page.setAll(0, content);
  return page;
}

Uint8List buildLeafPage(final int pageSize, final Map<String, String> entries) {
  final b = BytesBuilder();
  b.add([0x02]);
  b.add([entries.length & 0xFF, (entries.length >> 8) & 0xFF]);
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
  test('traverseBTree traverses branch->leaf and returns entries', () {
    const pageSize = 4096;
    const branchPage = 1;
    const leafPage = 2;
    final leafEntries = {'k': 'v'};
    final leaf = buildLeafPage(pageSize, leafEntries);
    final branch = buildBranchPage(pageSize, [leafPage], []);

    const totalPages = leafPage + 1;
    final fileBytes = Uint8List(totalPages * pageSize);
    fileBytes.setAll(branchPage * pageSize, branch);
    fileBytes.setAll(leafPage * pageSize, leaf);

    final parsed = traverseBTree(fileBytes, branchPage);
    expect(parsed['k'], equals('v'));
  });
}
