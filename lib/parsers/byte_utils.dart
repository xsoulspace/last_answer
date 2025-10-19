import 'dart:typed_data';
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

List<String> extractAsciiStrings(final Uint8List b, {final int minLen = 4, final int maxCount = 100}) {
  final results = <String>[];
  final buffer = <int>[];
  for (var i = 0; i < b.length; i++) {
    final v = b[i];
    if (v >= 32 && v <= 126) {
      buffer.add(v);
    } else {
      if (buffer.length >= minLen) {
        results.add(String.fromCharCodes(buffer));
        if (results.length >= maxCount) return results;
      }
      buffer.clear();
    }
  }
  if (buffer.length >= minLen && results.length < maxCount) results.add(String.fromCharCodes(buffer));
  return results;
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
