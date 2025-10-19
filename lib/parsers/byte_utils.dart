import 'dart:typed_data';

int readUint32LE(final Uint8List b, final int off) =>
    b[off] | (b[off + 1] << 8) | (b[off + 2] << 16) | (b[off + 3] << 24);

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

// AES helpers: provide function signature for future: decryptAES256CBC
Uint8List decryptAes256Cbc(
  final Uint8List encrypted,
  final Uint8List key,
  final Uint8List iv,
) {
  throw UnimplementedError(
    'AES decrypt helper not implemented in this iteration',
  );
}
