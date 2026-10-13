import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:lastanswer/coding_agent/runtime_sha256.dart';
import 'package:path_provider/path_provider.dart';
// Reuse the native owner's bounded process and settlement lane.
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness/src/lifecycle/bounded_process.dart';
import 'package:xsoulspace_agentic_host/meaning_span_preview.dart';

/// Product-owned native toolchain. No PATH or user SDK/cache discovery.
/// Explicit constructor paths support independent tests.
final class ProductDartRuntime {
  ProductDartRuntime({
    required this.bundleRoot,
    required this.supportDirectory,
  });

  final Directory bundleRoot;
  final Directory supportDirectory;
  static final _applications = <String, ProductDartRuntime>{};
  static final _inspections = <String, Future<Map<String, Object?>>>{};

  static Future<ProductDartRuntime> forApplication([Directory? support]) async {
    if (!Platform.isMacOS) {
      throw const MeaningPreviewRefusal('meaning_runtime_platform_unsupported');
    }
    final executable = File(Platform.resolvedExecutable);
    final supportDirectory = support ?? await getApplicationSupportDirectory();
    final bundle = Directory(
      '${executable.parent.parent.path}/Resources/meaning_runtime',
    );
    final key = '${bundle.path}\u0000${supportDirectory.path}';
    return _applications.putIfAbsent(
      key,
      () => ProductDartRuntime(
        bundleRoot: bundle,
        supportDirectory: supportDirectory,
      ),
    );
  }

  static Future<Map<String, Object?>> prepareWorkspace(
    Directory root,
    Directory appSupport,
  ) async {
    final runtime = await forApplication(appSupport);
    final receipt = await runtime.inspect();
    final lock = File('${root.path}/pubspec.lock');
    if (!lock.existsSync() ||
        await _digest(lock) != receipt['fixtureLockSha256']) {
      throw const MeaningPreviewRefusal(
        'meaning_runtime_fixture_lock_mismatch',
      );
    }
    final result = await runtime.execute('dart', ['pub', 'get'], root.path);
    if (result.exitCode != 0) {
      throw MeaningPreviewRefusal(
        'meaning_runtime_dependency_preparation_failed',
        '${result.stdout}${result.stderr}',
      );
    }
    if (await _digest(lock) != receipt['fixtureLockSha256']) {
      throw const MeaningPreviewRefusal('meaning_runtime_fixture_lock_changed');
    }
    return {...receipt, 'offlineDependenciesPrepared': true};
  }

  static Future<ProcessResult> run(
    String executable,
    List<String> arguments,
    String workingDirectory,
  ) async =>
      (await forApplication()).execute(executable, arguments, workingDirectory);

  Future<Map<String, Object?>> inspect() async {
    final totalWatch = Stopwatch()..start();
    final manifestFile = File('${bundleRoot.path}/manifest.json');
    if (!manifestFile.existsSync()) {
      throw const MeaningPreviewRefusal('meaning_runtime_bundle_missing');
    }
    final Object? manifest;
    try {
      manifest = jsonDecode(await manifestFile.readAsString());
    } on FormatException {
      throw const MeaningPreviewRefusal('meaning_runtime_manifest_invalid');
    }
    if (manifest is! Map ||
        manifest['format'] != 1 ||
        manifest['platform'] != Platform.operatingSystem ||
        manifest['seedFiles'] is! Map) {
      throw const MeaningPreviewRefusal('meaning_runtime_manifest_invalid');
    }
    final sdk = Directory('${bundleRoot.path}/dart-sdk');
    final executable = File('${sdk.path}/bin/dart');
    if (!File('${sdk.path}/version').existsSync() ||
        !executable.existsSync() ||
        (await File('${sdk.path}/version').readAsString()).trim() !=
            manifest['sdkVersion']) {
      throw const MeaningPreviewRefusal('meaning_runtime_sdk_mismatch');
    }
    final sdkWatch = Stopwatch()..start();
    final sdkPath = executable.path;
    final sdkDigest = await Isolate.run(() => _digestMeasured(sdkPath));
    if (sdkDigest['digest'] != manifest['executableSha256']) {
      throw const MeaningPreviewRefusal('meaning_runtime_sdk_mismatch');
    }
    final sdkElapsed = sdkWatch.elapsedMicroseconds;
    final seed = Directory('${bundleRoot.path}/pub-cache-seed');
    final hashes = Map<String, Object?>.from(manifest['seedFiles'] as Map);
    final manifestHash = await _digest(manifestFile);
    final cache = Directory(
      '${supportDirectory.path}/meaning_runtime/$manifestHash/pub-cache',
    );
    // Concurrent callers share one inspection/preparation. All SHA checks and
    // synchronous filesystem work run off the Flutter UI isolate; warm calls
    // still validate actual bytes, never merely a remembered metadata fence.
    final seedPath = seed.path;
    final cachePath = cache.path;
    // Equal manifests may come from different bundle roots. A caller must not
    // borrow another bundle's seed verification merely because the cache is
    // content-addressed to the same manifest.
    final inspectionKey = '$seedPath\u0000$cachePath';
    final inspection = _inspections.putIfAbsent(
      inspectionKey,
      () => Isolate.run(() => _prepareAndVerify(seedPath, cachePath, hashes)),
    );
    final workerWatch = Stopwatch()..start();
    late Map<String, Object?> workerTiming;
    try {
      workerTiming = await inspection;
    } finally {
      if (identical(_inspections[inspectionKey], inspection)) {
        await _inspections.remove(inspectionKey);
      }
    }
    return {
      'source': 'app_bundle',
      'executable': executable.path,
      'executableSha256': manifest['executableSha256'],
      'sdkVersion': manifest['sdkVersion'],
      'bundleManifestSha256': manifestHash,
      'fixtureLockSha256': manifest['fixtureLockSha256'],
      'pubCache': cache.path,
      'platform': manifest['platform'],
      'architecture': manifest['architecture'],
      'inspectionTiming': {
        'total_us': totalWatch.elapsedMicroseconds,
        'sdk_worker_wait_us': sdkElapsed,
        'sdk': sdkDigest,
        'seed_cache_worker_wait_us': workerWatch.elapsedMicroseconds,
        'seed_cache': workerTiming,
      },
    };
  }

  Future<ProcessResult> execute(
    String executable,
    List<String> arguments,
    String workingDirectory,
  ) async {
    if (executable != 'dart') {
      throw MeaningPreviewRefusal(
        'meaning_runtime_command_unsupported',
        executable,
      );
    }
    final inspectWatch = Stopwatch()..start();
    final receipt = await inspect();
    final inspectElapsed = inspectWatch.elapsedMicroseconds;
    final args = List<String>.of(arguments);
    if (args.length >= 2 && args[0] == 'pub' && args[1] == 'get') {
      if (!args.contains('--offline')) args.add('--offline');
      if (!args.contains('--enforce-lockfile')) args.add('--enforce-lockfile');
    }
    final processWatch = Stopwatch()..start();
    final result = await runBounded(
      '/usr/bin/env',
      [
        '-i',
        'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
        'HOME=${supportDirectory.path}',
        'TMPDIR=${Directory.systemTemp.path}',
        'PUB_CACHE=${receipt['pubCache']}',
        'DART_SUPPRESS_ANALYTICS=true',
        receipt['executable']! as String,
        ...args,
      ],
      workingDirectory: workingDirectory,
      deadline: const Duration(seconds: 90),
    );
    final runElapsed = processWatch.elapsedMicroseconds;
    await awaitProcessSettlement(result.survivors);
    // Bounded diagnostic receipt without stdout payload or authority.
    // ignore: avoid_print
    print(
      jsonEncode({
        'event': 'meaning_runtime_process_phase',
        'command': args.take(2).toList(),
        'inspection_us': inspectElapsed,
        'inspection': receipt['inspectionTiming'],
        'process_us': runElapsed,
        'settlement_us': processWatch.elapsedMicroseconds - runElapsed,
        'cause': result.cause.name,
        'exit_code': result.exitCode,
      }),
    );
    if (result.cause != BoundedProcessCause.exited ||
        result.survivors.isNotEmpty) {
      throw MeaningPreviewRefusal(
        'meaning_runtime_process_failed',
        '${result.cause}',
      );
    }
    return ProcessResult(
      result.pid ?? -1,
      result.exitCode,
      result.stdout,
      result.stderr,
    );
  }

  static Future<Map<String, Object?>> _prepareAndVerify(
    String seedPath,
    String cachePath,
    Map<String, Object?> hashes,
  ) async {
    final seed = Directory(seedPath);
    final cache = Directory(cachePath);
    final watch = Stopwatch()..start();
    if (cache.existsSync()) {
      // Each independent tree still reads, hashes and resolves every declared
      // file. Both workers settle before returning or throwing; seed failures
      // retain their original precedence over cache failures.
      final verified = await Future.wait([
        Isolate.run(() => _verifyFilesSettled(seedPath, hashes)),
        Isolate.run(() => _verifyFilesSettled(cachePath, hashes)),
      ]);
      for (final result in verified) {
        final error = result.$2;
        if (error != null) Error.throwWithStackTrace(error, result.$3!);
      }
      return {
        'total_us': watch.elapsedMicroseconds,
        'seed': verified[0].$1,
        'cache': verified[1].$1,
        'cache_copy_us': 0,
        'cache_copied': false,
        'verification_mode': 'parallel_existing_cache',
      };
    }
    // A new cache must be copied only after the source seed verifies, and the
    // resulting cache must verify before it can be used. Keep this cold path
    // ordered, including the staging directory's unconditional cleanup.
    final seedTiming = _verifyFilesSync(seed, hashes);
    final copyWatch = Stopwatch()..start();
    var copied = false;
    if (!cache.existsSync()) {
      copied = true;
      cache.parent.createSync(recursive: true);
      final staging = cache.parent.createTempSync('seed-');
      try {
        for (final relative in hashes.keys) {
          final destination = File('${staging.path}/$relative');
          destination.parent.createSync(recursive: true);
          File('${seed.path}/$relative').copySync(destination.path);
        }
        try {
          staging.renameSync(cache.path);
        } on FileSystemException {
          if (!cache.existsSync()) rethrow;
        }
      } finally {
        if (staging.existsSync()) staging.deleteSync(recursive: true);
      }
    }
    final copyElapsed = copyWatch.elapsedMicroseconds;
    final cacheTiming = _verifyFilesSync(cache, hashes);
    return {
      'total_us': watch.elapsedMicroseconds,
      'seed': seedTiming,
      'cache': cacheTiming,
      'cache_copy_us': copied ? copyElapsed : 0,
      'cache_copied': copied,
      'verification_mode': 'ordered_cache_preparation',
    };
  }

  static (Map<String, Object?>?, Object?, StackTrace?) _verifyFilesSettled(
    String rootPath,
    Map<String, Object?> hashes,
  ) {
    try {
      return (_verifyFilesSync(Directory(rootPath), hashes), null, null);
    } on Object catch (error, stack) {
      return (null, error, stack);
    }
  }

  static Map<String, Object?> _verifyFilesSync(
    Directory root,
    Map<String, Object?> hashes,
  ) {
    if (!root.existsSync()) {
      throw const MeaningPreviewRefusal('meaning_runtime_cache_mismatch');
    }
    final watch = Stopwatch()..start();
    var bytes = 0;
    var readUs = 0;
    var hashUs = 0;
    var pathCheckUs = 0;
    final canonical = root.resolveSymbolicLinksSync();
    for (final entry in hashes.entries) {
      final pathWatch = Stopwatch()..start();
      if (entry.value is! String ||
          entry.key.startsWith('/') ||
          entry.key.split('/').any((p) => p == '..' || p == '.' || p.isEmpty)) {
        throw const MeaningPreviewRefusal('meaning_runtime_manifest_invalid');
      }
      final file = File('${root.path}/${entry.key}');
      if (!file.existsSync() ||
          FileSystemEntity.isLinkSync(file.path) ||
          file.resolveSymbolicLinksSync() != '$canonical/${entry.key}') {
        throw MeaningPreviewRefusal(
          'meaning_runtime_cache_mismatch',
          entry.key,
        );
      }
      pathCheckUs += pathWatch.elapsedMicroseconds;
      final measured = _digestMeasured(file.path);
      bytes += measured['bytes']! as int;
      readUs += measured['read_us']! as int;
      hashUs += measured['hash_us']! as int;
      if (measured['digest'] != entry.value) {
        throw MeaningPreviewRefusal(
          'meaning_runtime_cache_mismatch',
          entry.key,
        );
      }
    }
    return {
      'elapsed_us': watch.elapsedMicroseconds,
      'files': hashes.length,
      'bytes': bytes,
      'read_us': readUs,
      'hash_us': hashUs,
      'path_and_link_check_us': pathCheckUs,
    };
  }

  static Map<String, Object?> _digestMeasured(String path) {
    final readWatch = Stopwatch()..start();
    final bytes = File(path).readAsBytesSync();
    final readUs = readWatch.elapsedMicroseconds;
    final hashWatch = Stopwatch()..start();
    final String digest;
    try {
      digest = runtimeSha256(bytes);
    } on Object catch (error) {
      throw MeaningPreviewRefusal(
        'meaning_runtime_digest_unavailable',
        '$error',
      );
    }
    return {
      'digest': digest,
      'bytes': bytes.length,
      'read_us': readUs,
      'hash_us': hashWatch.elapsedMicroseconds,
    };
  }

  static Future<String> _digest(File file) async {
    final path = file.path;
    final measured = await Isolate.run(() => _digestMeasured(path));
    return measured['digest']! as String;
  }
}
