import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

Future<void> main(List<String> args) async {
  if (args.length != 3 || !Platform.isMacOS) {
    throw ArgumentError(
      'usage: bundle_meaning_runtime.dart sdk destination fixture-lock',
    );
  }
  final sdk = Directory(args[0]);
  final destination = Directory(args[1]);
  final lock = File(args[2]);
  if (!File('${sdk.path}/bin/dart').existsSync() || !lock.existsSync()) {
    throw StateError('meaning runtime SDK or frozen lock is missing');
  }
  final lockText = await lock.readAsString();
  final packages = <({String name, String version, String hash})>[];
  final blocks = RegExp(
    r'^  ([a-zA-Z0-9_]+):\n(.*?)(?=^  [a-zA-Z0-9_]+:|^sdks:)',
    multiLine: true,
    dotAll: true,
  );
  for (final block in blocks.allMatches(lockText)) {
    final body = block[2]!;
    if (!body.contains('source: hosted') || !body.contains('https://pub.dev')) {
      throw StateError('unsupported dependency in frozen lock: ${block[1]}');
    }
    final version = RegExp(
      '^    version: "([^"]+)"',
      multiLine: true,
    ).firstMatch(body)?[1];
    final hash = RegExp(
      '^      sha256: "?([a-f0-9]{64})"?',
      multiLine: true,
    ).firstMatch(body)?[1];
    if (version == null || hash == null) {
      throw StateError('incomplete frozen lock: ${block[1]}');
    }
    packages.add((name: block[1]!, version: version, hash: hash));
  }
  if (packages.isEmpty) throw StateError('empty frozen dependency lock');
  if (destination.existsSync()) await destination.delete(recursive: true);
  await destination.create(recursive: true);
  final copy = await Process.run('/usr/bin/ditto', [
    sdk.path,
    '${destination.path}/dart-sdk',
  ]);
  if (copy.exitCode != 0) {
    throw StateError('SDK bundle copy failed: ${copy.stderr}');
  }
  final donor =
      Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';
  final seed = Directory('${destination.path}/pub-cache-seed');
  for (final package in packages) {
    final relative = 'hosted/pub.dev/${package.name}-${package.version}';
    final source = Directory('$donor/$relative');
    final hashRelative =
        'hosted-hashes/pub.dev/${package.name}-${package.version}.sha256';
    final sourceHash = File('$donor/$hashRelative');
    if (!source.existsSync() ||
        !sourceHash.existsSync() ||
        (await sourceHash.readAsString()).trim() != package.hash) {
      throw StateError(
        'missing or mismatched offline dependency '
        '${package.name}-${package.version}',
      );
    }
    for (final entity in source.listSync(recursive: true, followLinks: false)) {
      if (entity is Link) {
        throw StateError('symlink in frozen package: ${entity.path}');
      }
      if (entity is! File) continue;
      final path = entity.path.substring(source.path.length + 1);
      final file = File('${seed.path}/$relative/$path');
      await file.parent.create(recursive: true);
      await entity.copy(file.path);
    }
    final hashFile = File('${seed.path}/$hashRelative');
    await hashFile.parent.create(recursive: true);
    await sourceHash.copy(hashFile.path);
  }
  // Sign copied nested executables before recording their exact hashes. Keep
  // each SDK executable's existing JIT entitlements; never enlarge app grants.
  final identity = Platform.environment['EXPANDED_CODE_SIGN_IDENTITY'];
  if (identity != null && identity.isNotEmpty && identity != '-') {
    for (final entity in Directory(
      '${destination.path}/dart-sdk/bin',
    ).listSync(recursive: true)) {
      if (entity is! File) continue;
      final kind = await Process.run('/usr/bin/file', ['-b', entity.path]);
      if (!(kind.stdout as String).contains('Mach-O')) continue;
      final existing = await Process.run('/usr/bin/codesign', [
        '-d',
        '--entitlements',
        ':-',
        entity.path,
      ]);
      final entitlement = File('${destination.path}/.sdk-entitlements.plist');
      final text = existing.stdout as String;
      if (text.contains('<plist')) await entitlement.writeAsString(text);
      final signed = await Process.run('/usr/bin/codesign', [
        '--force',
        '--sign',
        identity,
        '--options',
        'runtime',
        if (entitlement.existsSync()) ...['--entitlements', entitlement.path],
        entity.path,
      ]);
      if (entitlement.existsSync()) await entitlement.delete();
      if (signed.exitCode != 0) {
        throw StateError('SDK signing failed: ${signed.stderr}');
      }
    }
  }
  final seedFiles = <String, String>{};
  final files = seed.listSync(recursive: true).whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    seedFiles[file.path.substring(seed.path.length + 1)] = await digest(file);
  }
  // Package compilation uses matching Flutter platform artifacts independently
  // of the legacy experiment's dependency seed or lock.
  final platform = Directory(
    '${sdk.parent.path}/artifacts/engine/common/flutter_patched_sdk',
  );
  if (!File('${platform.path}/platform_strong.dill').existsSync()) {
    throw StateError('matching Flutter compiler platform is missing');
  }
  final platformCopy = await Process.run('/usr/bin/ditto', [
    platform.path,
    '${destination.path}/flutter_patched_sdk',
  ]);
  if (platformCopy.exitCode != 0) {
    throw StateError('Flutter compiler platform copy failed');
  }
  final compilerFiles = <String, String>{};
  for (final directory in [
    Directory('${destination.path}/dart-sdk/lib'),
    Directory('${destination.path}/flutter_patched_sdk'),
  ]) {
    for (final file in directory.listSync(recursive: true).whereType<File>()) {
      compilerFiles[file.path.substring(destination.path.length + 1)] =
          await digest(file);
    }
  }
  for (final relative in [
    'dart-sdk/bin/dartaotruntime',
    'dart-sdk/bin/snapshots/frontend_server_aot.dart.snapshot',
    'dart-sdk/bin/snapshots/dart2js_aot.dart.snapshot',
    'dart-sdk/version',
  ]) {
    compilerFiles[relative] = await digest(
      File('${destination.path}/$relative'),
    );
  }
  await File('${destination.path}/compiler_manifest.json').writeAsString(
    jsonEncode({
      'format': 1,
      'platform': 'macos',
      'sdkVersion': (await File('${sdk.path}/version').readAsString()).trim(),
      'files': compilerFiles,
    }),
  );
  final arch = await Process.run('/usr/bin/uname', ['-m']);
  await File('${destination.path}/manifest.json').writeAsString(
    jsonEncode({
      'format': 1,
      'platform': 'macos',
      'architecture': (arch.stdout as String).trim(),
      'sdkVersion': (await File('${sdk.path}/version').readAsString()).trim(),
      'executableSha256': await digest(
        File('${destination.path}/dart-sdk/bin/dart'),
      ),
      'fixtureLockSha256': await digest(lock),
      'packages': [
        for (final p in packages)
          {'name': p.name, 'version': p.version, 'sha256': p.hash},
      ],
      'seedFiles': seedFiles,
    }),
  );
  stdout.writeln(
    'Bundled native meaning SDK and ${packages.length} '
    'exact offline dependencies.',
  );
}

Future<String> digest(File file) async =>
    sha256.convert(await file.readAsBytes()).toString();
