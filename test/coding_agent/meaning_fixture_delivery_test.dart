import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('product bundles exact frozen fixture and locked dependencies', (
    tester,
  ) async {
    const prefix = 'assets/meaning_greeting';
    Future<List<int>> asset(String name) async {
      final data = await rootBundle.load('$prefix/$name');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }

    final manifest = await asset('manifest.json');
    final original = File(
      '../../ecsai_harness/pkgs/xsoulspace_agentic_experiments/'
      'test/fixtures/meaning_greeting/manifest.json',
    ).readAsBytesSync();
    expect(manifest, original);
    final frozen = jsonDecode(utf8.decode(manifest)) as Map;
    for (final raw in frozen['assets'] as List) {
      final entry = raw as Map;
      expect(
        sha256.convert(await asset(entry['fixture_path'] as String)).toString(),
        entry['sha256'],
        reason: '${entry['fixture_path']}',
      );
    }
    final delivery =
        jsonDecode(utf8.decode(await asset('delivery.json'))) as Map;
    expect(sha256.convert(manifest).toString(), delivery['manifest_sha256']);
    expect(
      sha256.convert(await asset('pubspec.lock')).toString(),
      delivery['lock_sha256'],
    );
  });
}
