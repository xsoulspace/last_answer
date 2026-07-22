import 'dart:typed_data';

import 'package:core/src/data_sources/mutations/parsers/byte_utils.dart';
import 'package:core/src/data_sources/mutations/parsers/hive_parser.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _buildHiveFrame({required final Uint8List payload}) {
  // Frame layout: [len(4 LE)] [payload...] [crc(4 LE)]
  final len = 4 + payload.length + 4; // include len field and crc
  final out = BytesBuilder()
    ..add(_u32(len))
    ..add(payload);
  final crc = crc32(payload);
  out.add(_u32(crc));
  return out.toBytes();
}

Uint8List _u32(final int v) => Uint8List.fromList([
  v & 0xFF,
  (v >> 8) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 24) & 0xFF,
]);

Uint8List _buildSimpleKeyValueFrame(final String key, final String value) {
  // ignore: lines_longer_than_80_chars
  // payload: [keyType(1)=1 string][keyLen(4)][keyBytes][valueType(1)=1 string][valueLen(4)][valueBytes]
  final kb = Uint8List.fromList(key.codeUnits);
  final vb = Uint8List.fromList(value.codeUnits);
  final payload = BytesBuilder()
    ..add([1])
    ..add(_u32(kb.length))
    ..add(kb)
    ..add([1])
    ..add(_u32(vb.length))
    ..add(vb);
  return _buildHiveFrame(payload: payload.toBytes());
}

void main() {
  test('byte_utils read/write u32 works', () {
    final b = Uint8List.fromList([0x78, 0x56, 0x34, 0x12]);
    expect(readUint32LE(b, 0), equals(0x12345678));
  });

  test('crc32 of simple payload', () {
    final p = Uint8List.fromList([1, 2, 3, 4, 5]);
    expect(crc32(p), isA<int>());
  });

  test('hive parser reads single key/value frame', () {
    final frame = _buildSimpleKeyValueFrame('name', 'alice');
    final parsed = parseHiveFromBytes(frame);
    expect(parsed['name'], equals('alice'));
  });

  test('hive parser handles delete frame (empty value)', () {
    // key with empty value -> delete
    final kb = Uint8List.fromList('age'.codeUnits);
    final payload = BytesBuilder()
      ..add([1])
      ..add(_u32(kb.length))
      ..add(kb);
    // no value bytes => delete
    final frame = _buildHiveFrame(payload: payload.toBytes());
    final start = BytesBuilder()
      ..add(_buildSimpleKeyValueFrame('name', 'bob'))
      ..add(frame);
    final parsed = parseHiveFromBytes(start.toBytes());
    expect(parsed.containsKey('name'), isFalse);
  });
}
