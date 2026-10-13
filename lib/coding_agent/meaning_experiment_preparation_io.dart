import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/coding_agent/product_dart_runtime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xsoulspace_agentic_host/meaning_span_preview.dart';

const _assets = 'assets/meaning_greeting';
Future<void> _registryQueue = Future.value();

Future<List<int>> _asset(String name) async {
  final data = await rootBundle.load('$_assets/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<Map<String, Object?>> prepareMeaningExperiment() async {
  Directory? workspace;
  try {
    if (!(Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      return {'ok': false, 'error': 'meaning_experiment_platform_unavailable'};
    }
    final support = await getApplicationSupportDirectory();
    final parent = await Directory(
      '${support.path}/meaning_experiments',
    ).create(recursive: true);
    final manifestBytes = await _asset('manifest.json');
    final delivery =
        jsonDecode(utf8.decode(await _asset('delivery.json'))) as Map;
    if (sha256.convert(manifestBytes).toString() !=
        delivery['manifest_sha256']) {
      throw const FormatException('meaning_fixture_manifest_mismatch');
    }
    final manifest = jsonDecode(utf8.decode(manifestBytes)) as Map;
    final files = <String, List<int>>{};
    for (final raw in manifest['assets'] as List) {
      final asset = raw as Map;
      final bytes = await _asset(asset['fixture_path'] as String);
      if (sha256.convert(bytes).toString() != asset['sha256']) {
        throw const FormatException('meaning_fixture_asset_mismatch');
      }
      final relative = asset['workspace_path'] as String;
      if (relative.startsWith('/') || relative.split('/').contains('..')) {
        throw const FormatException('meaning_fixture_path_invalid');
      }
      files[relative] = bytes;
    }
    final lock = await _asset('pubspec.lock');
    if (sha256.convert(lock).toString() != delivery['lock_sha256']) {
      throw const FormatException('meaning_fixture_lock_mismatch');
    }
    files['pubspec.lock'] = lock;
    workspace = await parent.createTemp('experiment-');
    for (final entry in files.entries) {
      final file = File('${workspace.path}/${entry.key}');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(entry.value, flush: true);
    }
    await File(
      '${workspace.path}/.meaning-fixture-manifest.json',
    ).writeAsBytes(manifestBytes, flush: true);
    final runtime = await ProductDartRuntime.prepareWorkspace(
      workspace,
      support,
    );
    final receipt = <String, Object?>{
      'ok': true,
      'schema': 'lastanswer.meaning_experiment.v1',
      'workspace': await workspace.resolveSymbolicLinks(),
      'fixtureManifestSha256': delivery['manifest_sha256'],
      'runtime': runtime,
    };
    final prior = _registryQueue;
    _registryQueue = () async {
      await prior;
      final file = File('${parent.path}/registry.json');
      final registered = file.existsSync()
          ? Map<String, Object?>.from(
              jsonDecode(await file.readAsString()) as Map,
            )
          : <String, Object?>{};
      registered[receipt['workspace']! as String] = receipt;
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsString(jsonEncode(registered), flush: true);
      await temporary.rename(file.path);
    }();
    await _registryQueue;
    return receipt;
  } on Object catch (error) {
    return {
      'ok': false,
      'error': error is MeaningPreviewRefusal
          ? error.code
          : 'meaning_experiment_preparation_failed',
      'detail': '$error',
      if (workspace != null) 'workspace': workspace.path,
    };
  }
}

Future<Map<String, Object?>?> restoreMeaningExperiment(String workspace) async {
  try {
    if (!workspace.startsWith('/')) return null;
    final support = await getApplicationSupportDirectory();
    final parent = Directory('${support.path}/meaning_experiments');
    final registry = File('${parent.path}/registry.json');
    if (!registry.existsSync()) return null;
    final canonical = await Directory(workspace).resolveSymbolicLinks();
    if (Directory(canonical).parent.path !=
        await parent.resolveSymbolicLinks()) {
      return null;
    }
    final registered = jsonDecode(await registry.readAsString()) as Map;
    final raw = registered[canonical];
    if (raw is! Map || raw['schema'] != 'lastanswer.meaning_experiment.v1') {
      return null;
    }
    final marker = File('$canonical/.meaning-fixture-manifest.json');
    final delivery =
        jsonDecode(utf8.decode(await _asset('delivery.json'))) as Map;
    if (sha256.convert(await marker.readAsBytes()).toString() !=
        delivery['manifest_sha256']) {
      return null;
    }
    if (raw['fixtureManifestSha256'] != delivery['manifest_sha256']) {
      return null;
    }
    return Map<String, Object?>.from(raw);
  } on Object {
    return null;
  }
}
