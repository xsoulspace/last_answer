import 'dart:typed_data';

import 'package:lastanswer/parsers/isar_parser.dart';
import 'package:test/test.dart';

void main() {
  test('isar parser placeholder throws', () {
    final bytes = Uint8List(4096);
    expect(() => parseIsarFromBytes(bytes), throwsA(isA<UnimplementedError>()));
  });
}
