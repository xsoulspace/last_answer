import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/product_dart_runtime.dart';
import 'package:lastanswer/coding_agent/runtime_sha256.dart';
import 'package:xsoulspace_agentic_host/meaning_span_preview.dart';

void main() {
  test('runtime SHA preserves known vectors, blocks and arbitrary bytes', () {
    expect(
      runtimeSha256([]),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
    expect(
      runtimeSha256(utf8.encode('abc')),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
    for (final length in [1, 55, 56, 63, 64, 65, 127, 128, 129, 65536]) {
      final bytes = List.generate(length, (index) => (index * 73 + 19) & 255);
      expect(
        runtimeSha256(bytes),
        sha256.convert(bytes).toString(),
        reason: 'length $length',
      );
      final before = runtimeSha256(bytes);
      bytes[bytes.length ~/ 2] ^= 1;
      expect(runtimeSha256(bytes), isNot(before));
    }
  });

  test('every inspection checks actual SDK, seed and cache bytes', () async {
    final support = Directory.systemTemp.createTempSync('meaning-digest-unit-');
    addTearDown(() => support.deleteSync(recursive: true));
    final bundle = Directory('${support.path}/bundle')..createSync();
    final sdk = File('${bundle.path}/dart-sdk/bin/dart');
    sdk.parent.createSync(recursive: true);
    sdk.writeAsStringSync('synthetic component input; never executed');
    File('${bundle.path}/dart-sdk/version').writeAsStringSync('3.13.4');
    const relative = 'hosted/pub.dev/example-1.0.0/a.txt';
    final seed = File('${bundle.path}/pub-cache-seed/$relative');
    seed.parent.createSync(recursive: true);
    seed.writeAsStringSync('first');
    File('${bundle.path}/manifest.json').writeAsStringSync(
      jsonEncode({
        'format': 1,
        'platform': Platform.operatingSystem,
        'sdkVersion': '3.13.4',
        'executableSha256': sha256.convert(sdk.readAsBytesSync()).toString(),
        'fixtureLockSha256': 'unused',
        'seedFiles': {
          relative: sha256.convert(seed.readAsBytesSync()).toString(),
        },
      }),
    );
    final runtime = ProductDartRuntime(
      bundleRoot: bundle,
      supportDirectory: support,
    );
    final first = await runtime.inspect();
    final timing = first['inspectionTiming']! as Map;
    expect(((timing['seed_cache']! as Map)['seed']! as Map)['files'], 1);
    final cache = File('${first['pubCache']}/$relative');
    final originalModified = cache.lastModifiedSync();
    // Same size, restored mtime.
    cache
      ..writeAsStringSync('other')
      ..setLastModifiedSync(originalModified);
    await expectLater(
      runtime.inspect(),
      throwsA(
        isA<MeaningPreviewRefusal>().having(
          (error) => error.code,
          'code',
          'meaning_runtime_cache_mismatch',
        ),
      ),
    );
    cache.writeAsBytesSync(seed.readAsBytesSync());
    await runtime.inspect();
    seed.writeAsStringSync('other');
    await expectLater(
      runtime.inspect(),
      throwsA(
        isA<MeaningPreviewRefusal>().having(
          (error) => error.code,
          'code',
          'meaning_runtime_cache_mismatch',
        ),
      ),
    );
    seed.writeAsStringSync('first');
    sdk.writeAsStringSync('corrupted');
    await expectLater(
      runtime.inspect(),
      throwsA(
        isA<MeaningPreviewRefusal>().having(
          (error) => error.code,
          'code',
          'meaning_runtime_sdk_mismatch',
        ),
      ),
    );
  });

  test(
    'warm workers reject leaf and parent symlinks with matching bytes',
    () async {
      final fixture = _RuntimeFixture.create();
      addTearDown(() => fixture.support.deleteSync(recursive: true));
      final initial = await fixture.runtime.inspect();
      final cache = File('${initial['pubCache']}/${fixture.relative}');
      final seed = File(
        '${fixture.bundle.path}/pub-cache-seed/${fixture.relative}',
      );
      final original = seed.readAsBytesSync();
      final target = File('${fixture.support.path}/matching.txt')
        ..writeAsBytesSync(original);
      for (final file in [cache, seed]) {
        file.deleteSync();
        Link(file.path).createSync(target.path);
        await expectLater(
          fixture.runtime.inspect(),
          throwsA(
            isA<MeaningPreviewRefusal>().having(
              (error) => error.code,
              'code',
              'meaning_runtime_cache_mismatch',
            ),
          ),
        );
        Link(file.path).deleteSync();
        file.writeAsBytesSync(original);
        await fixture.runtime.inspect();
      }
      final parent = cache.parent;
      final moved = parent.renameSync('${fixture.support.path}/moved');
      Link(parent.path).createSync(moved.path);
      await expectLater(
        fixture.runtime.inspect(),
        throwsA(
          isA<MeaningPreviewRefusal>().having(
            (error) => error.code,
            'code',
            'meaning_runtime_cache_mismatch',
          ),
        ),
      );
      Link(parent.path).deleteSync();
      moved.renameSync(parent.path);
      final restored = await fixture.runtime.inspect();
      expect(
        ((restored['inspectionTiming']! as Map)['seed_cache']!
            as Map)['verification_mode'],
        'parallel_existing_cache',
      );
    },
  );

  test(
    'concurrent preparation shares checks and failed checks are retired',
    () async {
      final fixture = _RuntimeFixture.create(files: 512);
      addTearDown(() => fixture.support.deleteSync(recursive: true));
      final receipts = await Future.wait(
        List.generate(8, (_) => fixture.runtime.inspect()),
      );
      final workers = receipts.map(
        (receipt) => (receipt['inspectionTiming']! as Map)['seed_cache'],
      );
      expect(workers.toSet().length, lessThan(receipts.length));
      final cache = Directory(receipts.first['pubCache']! as String);
      expect(
        cache.parent.listSync().where(
          (entry) =>
              entry.path.split(Platform.pathSeparator).last.startsWith('seed-'),
        ),
        isEmpty,
      );
      final file = File('${cache.path}/${fixture.relative}');
      final original = file.readAsBytesSync();
      final modified = file.lastModifiedSync();
      final changed = List<int>.of(original)..[0] ^= 1;
      file
        ..writeAsBytesSync(changed)
        ..setLastModifiedSync(modified);
      await Future.wait(
        List.generate(8, (_) async {
          await expectLater(
            fixture.runtime.inspect(),
            throwsA(
              isA<MeaningPreviewRefusal>().having(
                (error) => error.code,
                'code',
                'meaning_runtime_cache_mismatch',
              ),
            ),
          );
        }),
      );
      file.writeAsBytesSync(original);
      await fixture.runtime.inspect();
    },
  );

  test('equal manifests cannot borrow a different bundle seed check', () async {
    final fixture = _RuntimeFixture.create(files: 512);
    addTearDown(() => fixture.support.deleteSync(recursive: true));
    await fixture.runtime.inspect();
    final otherBundle = Directory('${fixture.support.path}/other-bundle')
      ..createSync();
    for (final entry in fixture.bundle.listSync(recursive: true)) {
      if (entry is! File) continue;
      final relative = entry.path.substring(fixture.bundle.path.length + 1);
      final destination = File('${otherBundle.path}/$relative');
      destination.parent.createSync(recursive: true);
      entry.copySync(destination.path);
    }
    final other = ProductDartRuntime(
      bundleRoot: otherBundle,
      supportDirectory: fixture.support,
    );
    final seed = File('${otherBundle.path}/pub-cache-seed/${fixture.relative}');
    final original = seed.readAsBytesSync();
    seed.writeAsBytesSync(List<int>.of(original)..[0] ^= 1);
    await Future.wait(
      List.generate(4, (_) async {
        await Future.wait([
          fixture.runtime.inspect(),
          expectLater(
            other.inspect(),
            throwsA(
              isA<MeaningPreviewRefusal>().having(
                (error) => error.code,
                'code',
                'meaning_runtime_cache_mismatch',
              ),
            ),
          ),
        ]);
      }),
    );
    seed.writeAsBytesSync(original);
    await other.inspect();
  });

  test(
    'parallel failures retain seed-first refusal and settle before repair',
    () async {
      final fixture = _RuntimeFixture.create(files: 512);
      addTearDown(() => fixture.support.deleteSync(recursive: true));
      final receipt = await fixture.runtime.inspect();
      const lastRelative = 'hosted/pub.dev/example-1.0.0/file-511.txt';
      final seed = File('${fixture.bundle.path}/pub-cache-seed/$lastRelative');
      final cache = File('${receipt['pubCache']}/${fixture.relative}');
      final seedBytes = seed.readAsBytesSync();
      final cacheBytes = cache.readAsBytesSync();
      seed.writeAsBytesSync(List<int>.of(seedBytes)..[0] ^= 1);
      cache.writeAsBytesSync(List<int>.of(cacheBytes)..[0] ^= 1);
      await expectLater(
        fixture.runtime.inspect(),
        throwsA(
          isA<MeaningPreviewRefusal>()
              .having(
                (error) => error.code,
                'code',
                'meaning_runtime_cache_mismatch',
              )
              .having((error) => error.detail, 'detail', lastRelative),
        ),
      );
      seed.writeAsBytesSync(seedBytes);
      cache.writeAsBytesSync(cacheBytes);
      await fixture.runtime.inspect();
    },
  );

  test('invalid cold seed cannot publish a cache or leave staging', () async {
    final fixture = _RuntimeFixture.create();
    addTearDown(() => fixture.support.deleteSync(recursive: true));
    final seed = File(
      '${fixture.bundle.path}/pub-cache-seed/${fixture.relative}',
    );
    final bytes = seed.readAsBytesSync();
    seed.writeAsBytesSync(List<int>.of(bytes)..[0] ^= 1);
    await expectLater(
      fixture.runtime.inspect(),
      throwsA(
        isA<MeaningPreviewRefusal>().having(
          (error) => error.code,
          'code',
          'meaning_runtime_cache_mismatch',
        ),
      ),
    );
    expect(
      Directory('${fixture.support.path}/meaning_runtime').existsSync(),
      false,
    );
    seed.writeAsBytesSync(bytes);
    final recovered = await fixture.runtime.inspect();
    final timing =
        (recovered['inspectionTiming']! as Map)['seed_cache']! as Map;
    expect(timing['cache_copied'], true);
    expect(timing['verification_mode'], 'ordered_cache_preparation');
  });
}

final class _RuntimeFixture {
  _RuntimeFixture(this.support, this.bundle, this.runtime, this.relative);

  factory _RuntimeFixture.create({int files = 1}) {
    final support = Directory.systemTemp.createTempSync('runtime-integrity-');
    final bundle = Directory('${support.path}/bundle')..createSync();
    final sdk = File('${bundle.path}/dart-sdk/bin/dart');
    sdk.parent.createSync(recursive: true);
    sdk.writeAsStringSync('synthetic SDK; never executed');
    File('${bundle.path}/dart-sdk/version').writeAsStringSync('3.13.4');
    final hashes = <String, String>{};
    for (var index = 0; index < files; index++) {
      final relative = 'hosted/pub.dev/example-1.0.0/file-$index.txt';
      final file = File('${bundle.path}/pub-cache-seed/$relative');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('fixture bytes $index');
      hashes[relative] = sha256.convert(file.readAsBytesSync()).toString();
    }
    File('${bundle.path}/manifest.json').writeAsStringSync(
      jsonEncode({
        'format': 1,
        'platform': Platform.operatingSystem,
        'sdkVersion': '3.13.4',
        'executableSha256': sha256.convert(sdk.readAsBytesSync()).toString(),
        'fixtureLockSha256': 'unused',
        'seedFiles': hashes,
      }),
    );
    return _RuntimeFixture(
      support,
      bundle,
      ProductDartRuntime(bundleRoot: bundle, supportDirectory: support),
      hashes.keys.first,
    );
  }

  final Directory support;
  final Directory bundle;
  final ProductDartRuntime runtime;
  final String relative;
}
