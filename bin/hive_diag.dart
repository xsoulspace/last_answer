import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:lastanswer/parsers/byte_utils.dart';

void main() {
  final f = File('archive/ideaproject.hive');
  if (!f.existsSync()) {
    print(jsonEncode({'error': 'file not found'}));
    return;
  }
  final bytes = f.readAsBytesSync();
  final out = <String, dynamic>{};
  out['fileSize'] = bytes.length;
  out['firstBytes'] = bytes.sublist(0, bytes.length < 64 ? bytes.length : 64)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join(' ');

  // Try to parse first few frames
  var offset = 0;
  final frames = <dynamic>[];
  for (var i = 0; i < 5 && offset + 8 <= bytes.length; i++) {
    final frameLen = readUint32LE(bytes, offset);
    if (frameLen <= 8 || offset + frameLen > bytes.length) {
      frames.add({'offset': offset, 'error': 'invalid frameLen $frameLen'});
      break;
    }
    final payloadStart = offset + 4;
    final payloadEnd = offset + frameLen - 4;
    final payload = bytes.sublist(payloadStart, payloadEnd);
    final crcStored = readUint32LE(bytes, payloadEnd);
    final crcCalc = crc32(payload);
    frames.add({
      'offset': offset,
      'frameLen': frameLen,
      'payloadLen': payload.length,
      'crcStored': crcStored,
      'crcCalc': crcCalc,
      'crcMatch': crcStored == crcCalc,
      'payloadHexStart': payload.sublist(0, payload.length < 16 ? payload.length : 16)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' '),
    });
    offset += frameLen;
  }
  out['frames'] = frames;
  final encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(out));
}


