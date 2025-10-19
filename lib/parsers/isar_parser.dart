import 'dart:typed_data';

import 'package:lastanswer/parsers/byte_utils.dart';

/// Minimal Isar parser helpers for test-driven development.
/// This first pass extracts basic metadata: page size and a simple sanity check
/// from the meta pages (page 0 / page 1). Full B+ tree traversal follows tests.
Map<String, dynamic> parseIsarFromBytes(final Uint8List bytes) {
  const defaultPageSize = 4096;
  if (bytes.length < defaultPageSize * 2) {
    throw Exception('File too small to contain Isar meta pages');
  }
  final page0 = bytes.sublist(0, defaultPageSize);
  final page1 = bytes.sublist(defaultPageSize, defaultPageSize * 2);
  // crude tx id locations are at last 8 bytes; prefer the page with higher tx
  final tx0 = readUint64LE(page0, defaultPageSize - 8);
  final tx1 = readUint64LE(page1, defaultPageSize - 8);
  final active = tx0 >= tx1 ? page0 : page1;

  // read magic at offset 0 (libmdbx magic differs; use a heuristic)
  final magic = readUint32LE(active, 0);
  final pages = (bytes.length / defaultPageSize).floor();

  // Try to locate a plausible root page number in meta. Different MDBX
  // derivatives store DB root references at different offsets, try common
  // offsets and pick the first plausible page number.
  final candidateOffsets = [32, 40, 48, 64];
  int? rootPage;
  for (final off in candidateOffsets) {
    if (off + 4 <= active.length) {
      final v = readUint32LE(active, off);
      if (v > 0 && v < pages) {
        rootPage = v;
        break;
      }
    }
  }

  return {
    'pageSize': defaultPageSize,
    'pages': pages,
    'activeTx': active == page0 ? 'page0' : 'page1',
    'magic': magic,
    'rootPage': rootPage,
  };
}

// Placeholder for future B+ tree traversal. Accepts the full file bytes and a
// root page number (page-indexed) and returns a map of key->value. Not yet
// implemented; will be driven by tests that include small synthetic pages.
Map<dynamic, dynamic> traverseBTree(
  final Uint8List bytes,
  final int rootPage, {
  final int pageSize = 4096,
}) {
  throw UnimplementedError('B+ tree traversal not implemented');
}
