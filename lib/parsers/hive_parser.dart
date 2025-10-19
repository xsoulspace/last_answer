import 'dart:convert';
import 'dart:typed_data';

import 'package:lastanswer/parsers/byte_utils.dart';

Map<String, dynamic> _tryDeserializeHiveObject(final Uint8List bytes) {
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
            out['field_$fieldIdx'] = jsonDecode(sval);
            continue;
          } catch (_) {}
        }
        out['field_$fieldIdx'] = sval;
      } catch (_) {
        out['field_$fieldIdx'] = vbytes
            .map((final b) => b.toRadixString(16).padLeft(2, '0'))
            .join(' ');
      }
    } catch (_) {
      break;
    }
  }
  return out;
}

/// Parse a `.hive` file from raw bytes produced by tests or read from disk.
/// Returns a map of key -> value (strings for this minimal implementation).
Map<String, dynamic> parseHiveFromBytes(
  final Uint8List bytes, {
  final Uint8List? encryptionKey,
}) {
  final data = <String, dynamic>{};
  int offset = 0;
  while (offset + 8 <= bytes.length) {
    final frameLen = readUint32LE(bytes, offset);
    if (frameLen == 0) break;
    if (offset + frameLen > bytes.length) break; // truncated
    final payloadStart = offset + 4;
    final payloadEnd = offset + frameLen - 4;
    final payload = bytes.sublist(payloadStart, payloadEnd);
    final crc = readUint32LE(bytes, payloadEnd);
    // Accept CRC computed over payload alone (test fixtures) or over the
    // frame (len + payload) as observed in production Hive files.
    final crcPayload = crc32(payload);
    final crcFrame = crc32(bytes.sublist(offset, payloadEnd));
    if (crcPayload != crc && crcFrame != crc) {
      throw Exception('CRC mismatch in frame at $offset');
    }

    // parse payload: keyType(1), keyLen(4), keyBytes, [valueType(1), valueLen(4), valueBytes]
    try {
      int p = 0;
      if (p >= payload.length) throw Exception('empty payload');
      final keyType = payload[p++];
      if (keyType != 1) throw Exception('Unsupported key type in test parser');

      // Read key length as varint (supports small single-byte and multi-byte)
      final keyLenInfo = readVarUint(payload, p);
      final keyLen = keyLenInfo['value']!;
      p = keyLenInfo['newOffset']!;
      if (keyLen < 0 || p + keyLen > payload.length)
        throw Exception('invalid key length');
      final key = String.fromCharCodes(payload.sublist(p, p + keyLen));
      p += keyLen;

      if (p >= payload.length) {
        data.remove(key);
      } else {
        if (p >= payload.length) throw Exception('missing value type');
        final valueType = payload[p++];
        // length may be varint encoded
        int valueLen;
        try {
          final info = readVarUint(payload, p);
          valueLen = info['value']!;
          p = info['newOffset']!;
        } catch (_) {
          // fallback: take remaining bytes
          valueLen = payload.length - p;
        }
        if (valueLen < 0 || p + valueLen > payload.length)
          throw Exception('invalid value length');
        var valueBytes = payload.sublist(p, p + valueLen);
        if (encryptionKey != null) {
          try {
            valueBytes = decryptAes256Cbc(
              valueBytes,
              encryptionKey,
              Uint8List(16),
            );
          } catch (_) {
            // leave raw if decryption fails
          }
        }
        dynamic value;
        if (valueType == 1) {
          value = String.fromCharCodes(valueBytes);
          final s = value.toString().trimLeft();
          if (s.startsWith('{') || s.startsWith('[')) {
            try {
              value = jsonDecode(s);
            } catch (_) {
              // try heuristic deserialization for Hive objects
              final obj = _tryDeserializeHiveObject(valueBytes);
              if (obj.isNotEmpty) value = obj;
            }
          }
        } else {
          final ascii = extractAsciiStrings(valueBytes, minLen: 6, maxCount: 3);
          if (ascii.isNotEmpty) {
            value = {'type': valueType, 'ascii_preview': ascii};
          } else {
            final obj = _tryDeserializeHiveObject(valueBytes);
            if (obj.isNotEmpty) {
              value = {'type': valueType, 'object': obj};
            } else {
              value = {
                'type': valueType,
                'hex': valueBytes
                    .map((final b) => b.toRadixString(16).padLeft(2, '0'))
                    .join(' '),
              };
            }
          }
        }
        data[key] = value;
      }
    } catch (e) {
      // For robustness when parsing production files, record the frame error and
      // skip this frame rather than failing the entire parse run.
      data['__frame_error_at_$offset'] = e.toString();
    }

    offset += frameLen;
  }
  return data;
}
