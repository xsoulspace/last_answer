// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:from_json_to_json/from_json_to_json.dart';
// AES package usage was considered (aes_crypt_null_safe). To avoid a hard
// dependency during initial TDD steps, the AES helper remains a stub.

int readUint32LE(final Uint8List b, final int off) =>
    b[off] | (b[off + 1] << 8) | (b[off + 2] << 16) | (b[off + 3] << 24);

int readUint32BE(final Uint8List b, final int off) =>
    (b[off] << 24) | (b[off + 1] << 16) | (b[off + 2] << 8) | b[off + 3];

int readUint64LE(final Uint8List b, final int off) {
  final low = readUint32LE(b, off);
  final high = readUint32LE(b, off + 4);
  return (high << 32) | (low & 0xFFFFFFFF);
}

double readFloat64LE(final Uint8List b, final int off) {
  final bd = b.buffer.asByteData();
  return bd.getFloat64(off, Endian.little);
}

/// Simple CRC32 implementation (polynomial 0xEDB88320)
int crc32(final Uint8List bytes) {
  var crc = 0xFFFFFFFF;
  for (var i = 0; i < bytes.length; i++) {
    final byte = bytes[i];
    crc ^= byte;
    for (var j = 0; j < 8; j++) {
      final mask = -(crc & 1);
      crc = (crc >> 1) ^ (0xEDB88320 & mask);
    }
  }
  return ~crc & 0xFFFFFFFF;
}

/// Read unsigned varint (7-bit groups, little-endian style).
/// Returns a map with 'value' and 'newOffset'.
Map<String, int> readVarUint(final Uint8List b, final int off) {
  var shift = 0;
  var value = 0;
  var pos = off;
  while (pos < b.length) {
    final byte = b[pos++];
    value |= (byte & 0x7F) << shift;
    if ((byte & 0x80) == 0) break;
    shift += 7;
    if (shift > 63) throw Exception('varint too large');
  }
  return {'value': value, 'newOffset': pos};
}

List<String> extractAsciiStrings(final Uint8List b, {final int minLen = 4}) {
  final results = <String>[];
  final buffer = <int>[];
  for (var i = 0; i < b.length; i++) {
    final v = b[i];
    if (v >= 32 && v <= 126) {
      buffer.add(v);
    } else {
      if (buffer.length >= minLen) {
        results.add(String.fromCharCodes(buffer));
      }
      buffer.clear();
    }
  }
  if (buffer.length >= minLen) {
    results.add(String.fromCharCodes(buffer));
  }
  // Join all ASCII strings into a large buffer for pattern scanning.
  final str = results.join(' ');

  // Pattern to match JSON objects {...} and arrays [...]
  final RegExp jsonPattern = RegExp(
    // Improved pattern for nested {}, [] with recursive matching in
    // Dart RegExp (no recursive group, so match non-greedy)
    r'(\{(?:[^{}]|\{[^{}]*\})*\}|\[(?:[^\[\]]|\[[^\[\]]*\])*\])',
    dotAll: true,
  );

  // Attempt extraction
  final jsonMatches = <String>[];
  for (final m in jsonPattern.allMatches(str)) {
    final fragment = m.group(0);
    if (fragment != null && fragment.length >= 2) {
      jsonMatches.add(fragment);
    }
  }

  return jsonMatches;
}

/// {@template decode_to_string_or_hex}
/// Tolerant UTF-8 decode with hex fallback for robust parsing of production files.
///
/// Attempts UTF-8 decoding with malformed sequence tolerance. If decoding fails,
/// returns a hex representation of the bytes for debugging purposes.
///
/// This is particularly useful when parsing database files that may contain
/// mixed encoding or corrupted data.
/// {@endtemplate}
String decodeToStringOrHex(final Uint8List bytes) {
  try {
    return utf8.decode(bytes, allowMalformed: true);
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    return bytes
        .map((final b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');
  }
}

/// Find the end position of valid JSON in a string that may have trailing garbage.
/// Returns the position after the last valid JSON character, or -1 if no valid JSON found.
int _findJsonEnd(final String s) {
  if (s.isEmpty) return -1;

  var depth = 0;
  var inString = false;
  var escaped = false;
  final isArray = s[0] == '[';
  final isObject = s[0] == '{';

  if (!isArray && !isObject) return -1;

  for (var i = 0; i < s.length; i++) {
    final ch = s[i];

    if (escaped) {
      escaped = false;
      continue;
    }

    if (inString) {
      if (ch == r'\') {
        escaped = true;
      } else if (ch == '"') {
        inString = false;
      }
      continue;
    }

    if (ch == '"') {
      inString = true;
      continue;
    }

    if (isArray && ch == '[') {
      depth++;
    } else if (isArray && ch == ']') {
      depth--;
      if (depth == 0) return i + 1;
    } else if (isObject && ch == '{') {
      depth++;
    } else if (isObject && ch == '}') {
      depth--;
      if (depth == 0) return i + 1;
    }
  }

  return -1;
}

/// {@template extract_json_maps}
/// Extracts complete JSON objects/arrays from a string that may contain garbage.
///
/// This function is designed to handle production database files where JSON data
/// may be embedded within other content or have trailing garbage. It attempts
/// to parse the string as JSON and extracts all Map objects found.
///
/// Returns an empty list if no valid JSON maps are found.
/// {@endtemplate}
List<Map<String, dynamic>> extractJsonMaps(
  final String s, {
  final Uint8List? bytes,
}) {
  List<Map<String, dynamic>> tryDecode() {
    try {
      final jsonEnd = _findJsonEnd(s);
      if (jsonEnd > 0) {
        final jsonPart = s.substring(0, jsonEnd);
        return extractJsonMaps(jsonPart, bytes: bytes);
      } else {
        throw Exception('Could not find valid JSON');
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      log('Error decoding JSON as list', error: e, stackTrace: st);
      // not valid JSON despite being textual; try Hive object heuristic
      final obj = tryDeserializeHiveObject(bytes!);
      if (obj.isNotEmpty) {
        return [obj];
      }
    }
    return [];
  }

  try {
    if (s.startsWith('[')) {
      // try to decode as list
      final decodedList = jsonDecodeList(s);
      if (decodedList.isNotEmpty) {
        return decodedList
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
    }
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    // Try to extract just the valid JSON portion by finding where it ends
    return tryDecode();
  }
  try {
    if (s.startsWith('{')) {
      final decodedMap = jsonDecodeMapAs<String, dynamic>(s);
      if (decodedMap.isNotEmpty) {
        return [decodedMap];
      }
    }
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    return tryDecode();
  }
  return [];
}

/// {@template try_deserialize_hive_object}
/// Attempts to deserialize Hive's custom object format from raw bytes.
///
/// Uses a heuristic approach to parse Hive's binary object format:
/// - First byte indicates number of fields
/// - Each field consists of: [fieldIndex(1)][valueLen(varint)][valueBytes]
///
/// This is a best-effort parser designed for migration scenarios where
/// exact Hive deserialization may not be available.
/// {@endtemplate}
Map<String, dynamic> tryDeserializeHiveObject(final Uint8List bytes) {
  // Heuristic: first byte = numFields (small), then sequence of
  // [fieldIndex(1)][valueLen(varint)][valueBytes]
  if (bytes.isEmpty) return {};
  final numFields = bytes[0];
  if (numFields == 0 || numFields > 200) return {};
  var p = 1;
  final out = <String, dynamic>{};
  for (var i = 0; i < numFields; i++) {
    if (p >= bytes.length) break;
    final fieldIdx = bytes[p++];
    if (p >= bytes.length) break;
    try {
      final info = readVarUint(bytes, p);
      final vlen = info['value']!;
      p = info['newOffset']!;
      if (vlen < 0 || p + vlen > bytes.length) break;
      final vbytes = bytes.sublist(p, p + vlen);
      p += vlen;
      // try to parse as utf8/json
      String sval;
      try {
        sval = utf8.decode(vbytes);
        final ts = sval.trimLeft();
        if (ts.startsWith('{') || ts.startsWith('[')) {
          try {
            out['field_$fieldIdx'] = extractJsonMaps(sval);
            continue;
            // ignore: avoid_catches_without_on_clauses
          } catch (_) {}
        }
        out['field_$fieldIdx'] = sval;
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        out['field_$fieldIdx'] = vbytes
            .map((final b) => b.toRadixString(16).padLeft(2, '0'))
            .join(' ');
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      break;
    }
  }
  return out;
}

/// {@template decode_value}
/// Attempts to decode bytes using multiple strategies in order:
/// 1. UTF-8 decode → JSON parse (if starts with { or [)
/// 2. UTF-8 decode → plain string
/// 3. ASCII extraction preview
/// 4. Hex representation
///
/// This is the unified value decoder used across all parsers to handle
/// the common pattern of attempting multiple decoding strategies for
/// robust parsing of production database files.
///
/// The [valueType] parameter is included in fallback representations
/// for debugging purposes.
/// {@endtemplate}
dynamic decodeValue(final Uint8List bytes, {final int? valueType}) {
  // Attempt tolerant UTF-8 decode first for both textual and non-textual
  // value types. Many production values embed JSON or UTF-8 text
  // but may contain occasional malformed sequences.
  try {
    final decoded = utf8.decode(bytes, allowMalformed: true);
    final s = decoded.trimLeft();
    if (s.startsWith('{') || s.startsWith('[')) {
      return extractJsonMaps(s);
    } else {
      // treat as plain string when decoding succeeds
      return s;
    }
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    // Non-decodable bytes; fall back to ascii extraction and heuristics
    final ascii = extractAsciiStrings(bytes);
    if (ascii.isNotEmpty) {
      return {'type': valueType, 'ascii_preview': ascii};
    } else {
      final obj = tryDeserializeHiveObject(bytes);
      if (obj.isNotEmpty) {
        return {'type': valueType, 'object': obj};
      } else {
        return {
          'type': valueType,
          'hex': bytes
              .map((final b) => b.toRadixString(16).padLeft(2, '0'))
              .join(' '),
        };
      }
    }
  }
}

// AES helpers: provide function signature for future: decryptAES256CBC
Uint8List decryptAes256Cbc(
  final Uint8List encrypted,
  final Uint8List key,
  final Uint8List iv,
) {
  // Not implemented here. When integrating, prefer `aes_crypt_null_safe`:
  // final crypt = AesCrypt('password');
  // crypt.aesSetKeys(key, iv);
  // crypt.aesSetMode(AesMode.cbc);
  // return crypt.aesDecrypt(encrypted);
  throw UnimplementedError(
    'AES decrypt helper not implemented; integrate aes_crypt_null_safe',
  );
}
