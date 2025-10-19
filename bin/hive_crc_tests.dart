import 'dart:io';
import 'dart:typed_data';

import 'package:lastanswer/parsers/byte_utils.dart';

int adler32(final Uint8List data) {
  const modAdler = 65521;
  var a = 1;
  var b = 0;
  for (var i = 0; i < data.length; i++) {
    a = (a + data[i]) % modAdler;
    b = (b + a) % modAdler;
  }
  return (b << 16) | a;
}

void main() {
  final f = File('archive/ideaproject.hive');
  if (!f.existsSync()) {
    print('file not found');
    return;
  }
  final bytes = f.readAsBytesSync();
  const offset = 0;
  if (offset + 8 > bytes.length) {
    print('file too small');
    return;
  }
  final frameLen = readUint32LE(bytes, offset);
  const payloadStart = offset + 4;
  final payloadEnd = offset + frameLen - 4;
  final payload = bytes.sublist(payloadStart, payloadEnd);
  final storedCrc = readUint32LE(bytes, payloadEnd);

  print('frameLen: $frameLen');
  print('storedCrc: 0x\$${storedCrc.toRadixString(16)}');

  final c1 = crc32(payload);
  final c1comp = c1 ^ 0xFFFFFFFF;
  final c2 = crc32(
    Uint8List.fromList(bytes.sublist(offset, payloadEnd)),
  ); // include len
  final c3 = adler32(payload);

  print('crc32(payload): 0x\$${c1.toRadixString(16)}');
  print('crc32(payload) ^ 0xFFFFFFFF: 0x\$${c1comp.toRadixString(16)}');
  print('crc32(len+payload): 0x\$${c2.toRadixString(16)}');
  print('adler32(payload): 0x\$${c3.toRadixString(16)}');

  // Try a few common variations
  print('first payload bytes (hex):');
  print(
    payload
        .sublist(0, payload.length < 64 ? payload.length : 64)
        .map((final b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' '),
  );
}
