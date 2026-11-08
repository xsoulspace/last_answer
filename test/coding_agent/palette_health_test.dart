import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/realm_chat/palette_health.dart';

void main() {
  late Directory scratch;

  setUp(() {
    scratch = Directory.systemTemp.createTempSync('palette_health_');
    addTearDown(() => scratch.deleteSync(recursive: true));
  });

  PaletteHealthStore storeFor() =>
      PaletteHealthStore(resolveHome: () => scratch.path);

  test('reads the daemon status file and maps cast ids to verdicts', () {
    Directory('${scratch.path}/.xsoulspace').createSync(recursive: true);
    File('${scratch.path}/.xsoulspace/palette_health.json')
      .writeAsStringSync(
        jsonEncode({
          'schema': 1,
          'updatedAt': '2026-11-03T10:00:00.000Z',
          'entries': {
            'modelscope_qwen38max': {
              'status': 'ok',
              'at': '2026-11-03T10:00:00.000Z',
              'source': 'runtime',
            },
            'openrouter_deepseek': {
              'status': 'failed',
              'code': 'transport_http_404',
              'detail': 'rename the model id and restart',
              'at': '2026-11-03T10:01:00.000Z',
              'source': 'runtime',
            },
            'qwen': {
              'status': 'not_downloaded',
              'code': 'not_downloaded',
              'detail': 'cache the snapshot (the runtime never downloads)',
            },
          },
        }),
      );
    final store = storeFor();
    final ok = store.statusFor('modelscope_qwen38max');
    expect(ok, isNotNull);
    expect(ok!.status, 'ok');
    expect(ok.isHealthy, isTrue);
    // A brainRef carrying parameters still resolves its cast id.
    expect(store.statusFor('openrouter_deepseek?x=1')!.code,
        'transport_http_404');
    expect(store.statusFor('openrouter_deepseek?x=1')!.isHealthy, isFalse);
    final local = store.statusFor('qwen');
    expect(local!.status, 'not_downloaded');
    expect(local.detail, contains('never downloads'));
  });

  test('a missing or malformed file degrades to no verdict', () {
    expect(storeFor().statusFor('modelscope_qwen38max'), isNull);
    Directory('${scratch.path}/.xsoulspace').createSync(recursive: true);
    File('${scratch.path}/.xsoulspace/palette_health.json')
        .writeAsStringSync('not json');
    expect(storeFor().statusFor('openrouter_deepseek'), isNull);
  });

  test('an empty brainRef resolves nothing', () {
    expect(storeFor().statusFor(''), isNull);
  });
}
