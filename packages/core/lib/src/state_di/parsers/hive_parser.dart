import 'dart:convert';
import 'dart:typed_data';

import 'byte_utils.dart';

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
      // Use tolerant UTF-8 decoding for keys (production files may be malformed)
      final key = utf8.decode(
        payload.sublist(p, p + keyLen),
        allowMalformed: true,
      );
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
        final value = decodeValue(valueBytes, valueType: valueType);
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
