import 'dart:typed_data';
import 'package:lastanswer/parsers/byte_utils.dart';

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
    if (crc32(payload) != crc)
      throw Exception('CRC mismatch in frame at $offset');

    // parse payload: keyType(1), keyLen(4), keyBytes, [valueType(1), valueLen(4), valueBytes]
    int p = 0;
    final keyType = payload[p++];
    if (keyType != 1) throw Exception('Unsupported key type in test parser');
    final keyLen = readUint32LE(payload, p);
    p += 4;
    final key = String.fromCharCodes(payload.sublist(p, p + keyLen));
    p += keyLen;

    if (p >= payload.length) {
      data.remove(key);
    } else {
      final valueType = payload[p++];
      if (valueType != 1)
        throw Exception('Unsupported value type in test parser');
      final valueLen = readUint32LE(payload, p);
      p += 4;
      var valueBytes = payload.sublist(p, p + valueLen);
      if (encryptionKey != null) {
        // Decrypt if requested (not implemented)
        valueBytes = decryptAes256Cbc(valueBytes, encryptionKey, Uint8List(16));
      }
      final value = String.fromCharCodes(valueBytes);
      data[key] = value;
    }

    offset += frameLen;
  }
  return data;
}
