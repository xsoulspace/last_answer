import 'dart:typed_data';

import 'byte_utils.dart';

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
    // Lower minLen to 4 to catch shorter JSON fragments embedded in pages
    final ascii = extractAsciiStrings(bytes);
    final jsonObjects = <dynamic>[];
    for (final s in ascii) {
      // Use tolerant decoding in case ascii extraction picked up mixed bytes
      final t = s.trimLeft();
      if (t.isEmpty) continue;
      if (t.startsWith('{') || t.startsWith('[')) {
        try {
          extractJsonMaps(t).forEach(jsonObjects.add);
        } catch (e, st) {
          print('Error decoding JSON: $e\n$st');
          // ignore non-json sequences
        }
      }
    }
    if (jsonObjects.isNotEmpty) result['jsonObjectsPreview'] = jsonObjects;
  } catch (e, st) {
    print('Error extracting ASCII sequences: $e\n$st');
    // ignore errors during preview extraction
  }

  // If we successfully located a root page, attempt full B+ tree traversal
  // to extract key/value pairs. This is best-effort and errors are ignored
  // to avoid failing the migrator during app startup.
  if (rootPage != null) {
    try {
      final entries = traverseBTree(
        bytes,
        rootPage,
        pageSize: result['pageSize']! as int,
      );
      if (entries.isNotEmpty) result['entries'] = entries;
    } catch (_) {
      // ignore traversal errors
    }
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
  // Robust recursive B+ tree traversal for simple Isar/MDBX-like page layouts.
  // This implementation aims to be forgiving and extract key/value pairs from
  // leaf pages and to recurse branch pages to collect all leaf entries.

  final pageOffset = rootPage * pageSize;
  if (pageOffset + pageSize > bytes.length)
    throw Exception('root page out of range');
  final page = bytes.sublist(pageOffset, pageOffset + pageSize);
  final pageType = page[0];

  // Collect entries for leaf pages.
  if (pageType == 0x02) {
    // header: [pageType(1)][numEntries(2)][reserved(1)]
    final numEntries = page.length >= 3 ? (page[1] | (page[2] << 8)) : 0;
    var p = 4; // start after header (1 + 2 + 1)
    final out = <dynamic, dynamic>{};
    for (var i = 0; i < numEntries; i++) {
      if (p + 4 > page.length) break; // truncated
      final klen = readUint32LE(page, p);
      p += 4;
      if (klen < 0 || p + klen > page.length) break;
      final keyBytes = page.sublist(p, p + klen);
      p += klen;

      if (p + 4 > page.length) break;
      final vlen = readUint32LE(page, p);
      p += 4;
      if (vlen < 0 || p + vlen > page.length) break;
      final valBytes = page.sublist(p, p + vlen);
      p += vlen;

      // decode key and value with tolerant UTF-8; attempt JSON decode on value
      final key = decodeToStringOrHex(Uint8List.fromList(keyBytes));
      final value = decodeValue(Uint8List.fromList(valBytes));

      out[key] = value;
    }
    return out;
  }
  // Branch page: contains child page numbers and separator keys. Recurse all children.
  else if (pageType == 0x01) {
    final childCount = page.length >= 3 ? (page[1] | (page[2] << 8)) : 0;
    var p = 4;
    final children = <int>[];
    for (var i = 0; i < childCount; i++) {
      if (p + 4 > page.length) break;
      final child = readUint32LE(page, p);
      p += 4;
      // read optional key length and key bytes (some formats store separators)
      if (p + 4 > page.length) {
        children.add(child);
        continue;
      }
      final klen = readUint32LE(page, p);
      p += 4;
      if (klen < 0 || p + klen > page.length) {
        children.add(child);
        continue;
      }
      // skip separator key bytes
      p += klen;
      children.add(child);
    }

    final aggregated = <dynamic, dynamic>{};
    for (final c in children) {
      try {
        final sub = traverseBTree(bytes, c, pageSize: pageSize);
        aggregated.addAll(Map.from(sub));
      } catch (_) {
        // ignore traversal errors for specific children
      }
    }
    return aggregated;
  } else {
    throw Exception('unknown page type $pageType');
  }
}
