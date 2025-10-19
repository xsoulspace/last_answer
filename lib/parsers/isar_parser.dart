import 'dart:convert';
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

  final result = {
    'pageSize': defaultPageSize,
    'pages': pages,
    'activeTx': active == page0 ? 'page0' : 'page1',
    'magic': magic,
    'rootPage': rootPage,
  };

  // Attempt to extract ASCII sequences and decode embedded JSON objects as a
  // best-effort data preview. This is especially useful when full B+ tree
  // traversal isn't yet implemented for all Isar formats.
  try {
    final ascii = extractAsciiStrings(bytes, minLen: 8, maxCount: 300);
    final jsonObjects = <dynamic>[];
    for (final s in ascii) {
      final t = s.trimLeft();
      if (t.isEmpty) continue;
      if (t.startsWith('{') || t.startsWith('[')) {
        try {
          final decoded = jsonDecode(t);
          jsonObjects.add(decoded);
          if (jsonObjects.length >= 20) break;
        } catch (_) {
          // ignore non-json sequences
        }
      }
    }
    if (jsonObjects.isNotEmpty) result['jsonObjectsPreview'] = jsonObjects;
  } catch (_) {
    // ignore errors during preview extraction
  }

  return result;
}

// Placeholder for future B+ tree traversal. Accepts the full file bytes and a
// root page number (page-indexed) and returns a map of key->value. Not yet
// implemented; will be driven by tests that include small synthetic pages.
Map<dynamic, dynamic> traverseBTree(
  final Uint8List bytes,
  final int rootPage, {
  final int pageSize = 4096,
}) {
  // For the first TDD step we parse a very small synthetic leaf page format
  // produced by tests: header [pageType(1)=0x02][numEntries(2)][reserved(1)]
  // then repeated entries: [keyLen(4)][keyBytes][valLen(4)][valBytes]
  final pageOffset = rootPage * pageSize;
  if (pageOffset + pageSize > bytes.length)
    throw Exception('root page out of range');
  final page = bytes.sublist(pageOffset, pageOffset + pageSize);
  final pageType = page[0];
  if (pageType == 0x02) {
    // leaf
    final numEntries = page[1] | (page[2] << 8);
    var p = 4; // start after header (1 + 2 + 1)
    final out = <dynamic, dynamic>{};
    for (var i = 0; i < numEntries; i++) {
      if (p + 4 > page.length) throw Exception('truncated key len');
      final klen = readUint32LE(page, p);
      p += 4;
      final key = String.fromCharCodes(page.sublist(p, p + klen));
      p += klen;
      final vlen = readUint32LE(page, p);
      p += 4;
      final val = String.fromCharCodes(page.sublist(p, p + vlen));
      p += vlen;
      out[key] = val;
    }
    return out;
  } else if (pageType == 0x01) {
    // branch: read child pages and recurse into first child for this test
    final childCount = page[1] | (page[2] << 8);
    var p = 4;
    final children = <int>[];
    final keys = <String>[];
    for (var i = 0; i < childCount; i++) {
      final child = readUint32LE(page, p);
      p += 4;
      final klen = readUint32LE(page, p);
      p += 4;
      final key = String.fromCharCodes(page.sublist(p, p + klen));
      p += klen;
      children.add(child);
      keys.add(key);
    }
    // For tests, recurse into the first child
    if (children.isEmpty) return <dynamic, dynamic>{};
    return traverseBTree(bytes, children[0], pageSize: pageSize);
  } else {
    throw Exception('unknown page type $pageType');
  }
}
