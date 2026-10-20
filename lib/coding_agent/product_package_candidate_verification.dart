import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:lastanswer/coding_agent/product_dart_runtime.dart';
import 'package:xsoulspace_agentic_host/conventional_change.dart';
import 'package:xsoulspace_tooling_runtime/xsoulspace_tooling_runtime.dart';

/// Compiler-only checks in the existing private candidate and native no-fork
/// verifier. Discovery supplies no verification; only the snapshot pass does.
final class ProductPackageCandidateVerifier {
  ProductPackageCandidateVerifier({
    required this.workspace,
    required this.runtime,
    required this.verifier,
  });

  final Directory workspace;
  final Future<ProductDartRuntime> Function() runtime;
  final MacOsCandidateVerifier verifier;
  static const _maxCapturedBytes = 128 * 1024 * 1024;
  static const _maxCapturedFiles = 12000;

  Future<ConventionalCheck> verifyCandidate(Directory candidate) async {
    var settled = true;
    final checks = <Map<String, Object?>>[];
    try {
      final root = workspace.resolveSymbolicLinksSync();
      final toolchain = await runtime();
      final identity = await toolchain.inspectCompiler();
      final bundle = toolchain.bundleRoot.resolveSymbolicLinksSync();
      final configFile = File('$root/.dart_tool/package_config.json');
      final configBytes = configFile.readAsBytesSync();
      final config = jsonDecode(utf8.decode(configBytes));
      if (config is! Map ||
          config['configVersion'] != 2 ||
          config['packages'] is! List) {
        throw const FormatException('coding_package_config_invalid');
      }
      final scratch = Directory(
        '${candidate.path}/.dart_tool/coding_verification',
      )..createSync(recursive: true);
      final inputs = <String, _Input>{};
      var capturedBytes = 0;
      final staged = <String, File>{};
      for (final file in candidate.listSync(
        recursive: true,
        followLinks: false,
      )) {
        if (file is! File || file.path.startsWith('${scratch.parent.path}/')) {
          continue;
        }
        final relative = file.path.substring(candidate.path.length + 1);
        staged['$root/$relative'] = file;
      }
      final manifest = jsonDecode(
        File(
          '${candidate.path}/.dart_tool/native_candidate_inputs.json',
        ).readAsStringSync(),
      );
      if (manifest is! Map ||
          manifest['format'] != 1 ||
          manifest['paths'] is! Map) {
        throw const FormatException('coding_candidate_input_manifest_invalid');
      }
      final declared = <String, bool>{};
      for (final entry in (manifest['paths'] as Map).entries) {
        final path = entry.key;
        if (path is! String ||
            entry.value is! bool ||
            path.startsWith('/') ||
            path
                .split('/')
                .any(
                  (part) =>
                      part.isEmpty ||
                      part == '.' ||
                      part == '..' ||
                      part.startsWith('.'),
                ) ||
            path.contains(r'\')) {
          throw const FormatException(
            'coding_candidate_input_manifest_invalid',
          );
        }
        final original = '$root/$path';
        declared[original] = entry.value as bool;
        if (staged.containsKey(original) != entry.value) {
          throw const FormatException(
            'coding_candidate_input_presence_mismatch',
          );
        }
      }
      if (declared.isEmpty ||
          staged.keys.any((path) => declared[path] != true)) {
        throw const FormatException('coding_candidate_input_manifest_scope');
      }
      final rawChanges = manifest['changedPaths'];
      if (rawChanges is! List ||
          rawChanges.isEmpty ||
          rawChanges.any(
            (path) => path is! String || !declared.containsKey('$root/$path'),
          ) ||
          rawChanges.toSet().length != rawChanges.length) {
        throw const FormatException('coding_candidate_input_changes_invalid');
      }
      final changed = {for (final path in rawChanges) '$root/$path'};
      void witness(String path, List<int> bytes) {
        if (inputs.containsKey(path)) return;
        capturedBytes += bytes.length;
        if (capturedBytes > _maxCapturedBytes ||
            inputs.length >= _maxCapturedFiles) {
          throw const FormatException('coding_verification_closure_limit');
        }
        final file = File(path);
        if (FileSystemEntity.isLinkSync(path)) {
          throw const FormatException('coding_verification_input_link');
        }
        inputs[path] = _Input(file.resolveSymbolicLinksSync(), _digest(bytes));
      }

      witness(configFile.path, configBytes);
      for (final path in <String>{
        '$root/pubspec.yaml',
        '$root/pubspec.lock',
        ...declared.keys.where(
          (path) =>
              path.endsWith('/pubspec.yaml') || path.endsWith('/pubspec.lock'),
        ),
      }) {
        final file = File(path);
        final present = file.existsSync();
        if (declared.containsKey(path) && declared[path] != present) {
          throw const FormatException(
            'coding_package_metadata_change_requires_resolution',
          );
        }
        if (!present) {
          inputs[path] = _Input(path, null);
          continue;
        }
        final bytes = file.readAsBytesSync();
        if (staged[path] case final proposed?) {
          if (_digest(proposed.readAsBytesSync()) != _digest(bytes)) {
            throw const FormatException(
              'coding_package_metadata_change_requires_resolution',
            );
          }
        }
        witness(path, bytes);
      }
      final packages = <_Package>[];
      final names = <String>{};
      for (final raw in config['packages'] as List) {
        if (raw is! Map ||
            raw['name'] is! String ||
            raw['rootUri'] is! String) {
          throw const FormatException('coding_package_config_invalid');
        }
        final name = raw['name'] as String;
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name) || !names.add(name)) {
          throw const FormatException('coding_package_config_invalid');
        }
        final rootUri = configFile.parent.uri.resolve(raw['rootUri'] as String);
        if (rootUri.scheme != 'file') {
          throw const FormatException('coding_package_root_unsupported');
        }
        final packageRoot = Directory.fromUri(
          rootUri,
        ).resolveSymbolicLinksSync();
        final packageUri = raw['packageUri'] as String? ?? 'lib/';
        final uri = Uri.parse(packageUri);
        if (uri.hasScheme ||
            uri.path.startsWith('/') ||
            uri.pathSegments.contains('..')) {
          throw const FormatException('coding_package_uri_unsupported');
        }
        final libraryDirectory = Directory('$packageRoot/$packageUri');
        final library = libraryDirectory.existsSync()
            ? libraryDirectory.resolveSymbolicLinksSync()
            : Directory(packageRoot).uri
                  .resolve(packageUri)
                  .toFilePath()
                  .replaceFirst(RegExp(r'/$'), '');
        if (!_under(library, packageRoot)) {
          throw const FormatException('coding_package_library_escapes_root');
        }
        final declaredLibrary = Directory(
          packageRoot,
        ).uri.resolve(packageUri).toFilePath();
        final normalizedLibrary = declaredLibrary.endsWith('/')
            ? declaredLibrary.substring(0, declaredLibrary.length - 1)
            : declaredLibrary;
        if (library != normalizedLibrary) {
          throw const FormatException(
            'coding_package_library_alias_unsupported',
          );
        }
        final own = _under(packageRoot, root);
        final snapshot = '${scratch.path}/packages/${packages.length}/';
        final package = _Package(
          raw: Map<String, Object?>.from(raw),
          root: packageRoot,
          identityPath: Directory.fromUri(rootUri).path,
          library: library,
          snapshot: snapshot,
          own: own,
        );
        packages.add(package);
        if (own) {
          for (final metadata in ['pubspec.yaml', 'pubspec.lock']) {
            final path = '$packageRoot/$metadata';
            final file = File(path);
            if (file.existsSync()) {
              witness(path, file.readAsBytesSync());
            } else {
              inputs[path] = _Input(path, null);
            }
          }
        }
        if (own && Directory(library).existsSync()) {
          for (final entity in Directory(
            library,
          ).listSync(recursive: true, followLinks: false)) {
            if (entity is Link) {
              throw const FormatException('coding_verification_input_link');
            }
            if (entity is! File || !entity.path.endsWith('.dart')) continue;
            final bytes = entity.readAsBytesSync();
            witness(entity.path, bytes);
            if (declared[entity.path] == false) continue;
            final proposed = staged[entity.path];
            _copy(
              '$snapshot${entity.path.substring(packageRoot.length + 1)}',
              proposed?.readAsBytesSync() ?? bytes,
            );
          }
        }
      }
      if (packages.length > 1024 || !packages.any((p) => p.root == root)) {
        throw const FormatException('coding_package_root_not_admitted');
      }
      final ownPackage = packages.firstWhere((p) => p.root == root);
      // New files and deletions are exact candidate effects. The host owns
      // their preimages; this verifier does not derive write authority.
      for (final entry in staged.entries) {
        if (!entry.key.endsWith('.dart')) continue;
        final package =
            packages.where((p) => p.own && _under(entry.key, p.root)).toList()
              ..sort((a, b) => b.root.length.compareTo(a.root.length));
        if (package.isEmpty) {
          throw const FormatException('coding_candidate_package_scope');
        }
        final owner = package.first;
        _copy(
          '${owner.snapshot}${entry.key.substring(owner.root.length + 1)}',
          entry.value.readAsBytesSync(),
        );
      }
      final entrypoint = '${ownPackage.snapshot}lib/main.dart';
      if (!File(entrypoint).existsSync()) {
        throw const FormatException('coding_flutter_entrypoint_required');
      }
      final compileTargets = <String>{};
      for (final path in staged.keys.where(
        (path) => changed.contains(path) && path.endsWith('.dart'),
      )) {
        final owner =
            packages.where((p) => p.own && _under(path, p.root)).toList()
              ..sort((a, b) => b.root.length.compareTo(a.root.length));
        if (owner.isEmpty) {
          throw const FormatException('coding_candidate_package_scope');
        }
        compileTargets.add(
          '${owner.first.snapshot}'
          '${path.substring(owner.first.root.length + 1)}',
        );
      }
      File writeConfig({required bool snapshotOnly}) {
        final result =
            File(
              '${scratch.path}/packages_${snapshotOnly ? 'snapshot' : 'discovery'}.json',
            )..writeAsStringSync(
              jsonEncode({
                'configVersion': 2,
                'packages': [
                  for (final p in packages)
                    {
                      ...p.raw,
                      'rootUri': Directory(
                        snapshotOnly || p.own ? p.snapshot : p.root,
                      ).uri.toString(),
                    },
                ],
              }),
            );
        return result;
      }

      Future<CandidateVerificationResult> compile({
        required bool snapshotOnly,
      }) async {
        final phase = snapshotOnly ? 'snapshot' : 'discovery';
        final result = await verifier.verifyCandidate(
          executable: '$bundle/dart-sdk/bin/dartaotruntime',
          arguments: [
            '$bundle/dart-sdk/bin/snapshots/frontend_server_aot.dart.snapshot',
            '--target=flutter',
            '--sdk-root=$bundle/flutter_patched_sdk/',
            '--platform=$bundle/flutter_patched_sdk/platform_strong.dill',
            '--packages=${writeConfig(snapshotOnly: snapshotOnly).path}',
            '--output-dill=${scratch.path}/$phase.dill',
            '--depfile=${scratch.path}/$phase.d',
            '--no-incremental',
            '--no-link-platform',
            for (final target in compileTargets) '--source=$target',
            entrypoint,
          ],
          candidateRoot: candidate.path,
          readOnlyRoots: [
            '$bundle/dart-sdk',
            '$bundle/flutter_patched_sdk',
            if (!snapshotOnly)
              ...packages
                  .where((p) => !p.own && Directory(p.library).existsSync())
                  .map((p) => p.library),
          ],
          deadline: const Duration(seconds: 90),
        );
        settled = result.physicallySettled;
        Map<String, Object?> outputState(String suffix) {
          final file = File('${scratch.path}/$phase.$suffix');
          try {
            final exists = file.existsSync();
            return {
              'exists': exists,
              'bytes': exists ? file.lengthSync() : null,
            };
          } on FileSystemException {
            // Diagnostic observation cannot replace the checker outcome.
            return {'exists': null, 'bytes': null, 'statUnavailable': true};
          }
        }

        checks.add({
          'phase': phase,
          'resultOk': result.ok,
          'processOk': result.process?.ok,
          'processCause': result.process?.cause.name,
          'inputProblem': result.process?.inputProblem,
          'transportProblem': result.process?.transportProblem,
          'settlementProblem': result.process?.settlementProblem,
          'spawnError': result.process?.spawnError,
          'survivors': result.process?.survivors,
          'expectedDill': outputState('dill'),
          'expectedDepfile': outputState('d'),
          'exitCode': result.process?.exitCode,
          'stdout': result.process?.stdout,
          'stderr': result.process?.stderr,
          'refusal': result.refusal,
          'physicallySettled': result.physicallySettled,
          'retainedScratchRoot': result.retainedScratchRoot,
          'acceptanceEvidence': snapshotOnly,
        });
        return result;
      }

      final discovery = await compile(snapshotOnly: false);
      if (!discovery.ok || !File('${scratch.path}/discovery.d').existsSync()) {
        return _failure(
          discovery.refusal ?? 'coding_dependency_discovery_failed',
          settled,
          checks,
        );
      }
      for (final path in _depfile(
        File('${scratch.path}/discovery.d').readAsStringSync(),
      )) {
        final canonical = File(path).resolveSymbolicLinksSync();
        if (_under(canonical, candidate.resolveSymbolicLinksSync()) ||
            _under(canonical, bundle)) {
          continue;
        }
        final owners =
            packages
                .where((p) => !p.own && _under(canonical, p.library))
                .toList()
              ..sort((a, b) => b.library.length.compareTo(a.library.length));
        if (owners.isEmpty) {
          throw const FormatException('coding_compiler_input_outside_grants');
        }
        final package = owners.first;
        final bytes = File(canonical).readAsBytesSync();
        witness(canonical, bytes);
        _copy(
          '${package.snapshot}${canonical.substring(package.root.length + 1)}',
          bytes,
        );
      }
      final authoritative = await compile(snapshotOnly: true);
      if (!authoritative.ok ||
          !File('${scratch.path}/snapshot.dill').existsSync() ||
          !File('${scratch.path}/snapshot.d').existsSync()) {
        return _failure(
          authoritative.refusal ?? 'coding_candidate_compile_failed',
          settled,
          checks,
        );
      }
      // Parse and fence the authoritative depfile as well: its compiler has no
      // live dependency grants, so every source must be in private custody.
      for (final path in _depfile(
        File('${scratch.path}/snapshot.d').readAsStringSync(),
      )) {
        final canonical = File(path).resolveSymbolicLinksSync();
        if (!_under(canonical, candidate.resolveSymbolicLinksSync()) &&
            !_under(canonical, bundle)) {
          throw const FormatException('coding_snapshot_input_outside_custody');
        }
      }
      final covered = _depfile(
        File('${scratch.path}/snapshot.d').readAsStringSync(),
      ).map((path) => File(path).resolveSymbolicLinksSync()).toSet();
      if (compileTargets.any(
        (path) => !covered.contains(File(path).resolveSymbolicLinksSync()),
      )) {
        throw const FormatException('coding_changed_source_not_compiled');
      }
      final originRoots = {for (final p in packages) p.identityPath: p.root};
      // Exact staged paths are already guarded by the native source witness
      // before each write. Exclude them so a valid first write does not make
      // the same proposal's second write appear stale.
      final dependencies = Map<String, _Input>.from(inputs)
        ..removeWhere((path, _) => declared.containsKey(path));
      bool revalidate() {
        try {
          if (workspace.resolveSymbolicLinksSync() != root) return false;
          for (final entry in originRoots.entries) {
            if (Directory(entry.key).resolveSymbolicLinksSync() !=
                entry.value) {
              return false;
            }
          }
          for (final entry in dependencies.entries) {
            final file = File(entry.key);
            if (entry.value.hash == null) {
              if (FileSystemEntity.typeSync(file.path, followLinks: false) !=
                  FileSystemEntityType.notFound) {
                return false;
              }
              continue;
            }
            if (FileSystemEntity.isLinkSync(file.path) ||
                file.resolveSymbolicLinksSync() != entry.value.canonical ||
                _digest(file.readAsBytesSync()) != entry.value.hash) {
              return false;
            }
          }
          return true;
        } on Object {
          return false;
        }
      }

      if (!revalidate()) {
        throw const FormatException('coding_verification_inputs_changed');
      }
      return ConventionalCheck(
        ok: true,
        physicallySettled: settled,
        revalidateInputs: revalidate,
        evidence: {
          'grade': 'compiler_only',
          'runtime': identity,
          'checks': checks,
          'compiledTargets': compileTargets.length,
          'capturedFiles': inputs.length,
          'capturedBytes': capturedBytes,
          'inputHashes': {
            for (final entry in dependencies.entries)
              entry.key: entry.value.hash,
          },
          'candidateExecuted': false,
          'functionalBehaviorVerified': false,
          'taskAcceptance': false,
          'dependencyDiscoveryIsVerification': false,
        },
      );
    } on Object catch (error) {
      return _failure(
        error is FormatException
            ? error.message
            : 'coding_package_compiler_unavailable',
        settled,
        checks,
      );
    }
  }

  static ConventionalCheck _failure(
    String error,
    bool settled,
    List<Map<String, Object?>> checks,
  ) => ConventionalCheck(
    ok: false,
    physicallySettled: settled,
    evidence: {
      'error': error,
      'grade': 'compiler_only',
      'checks': checks,
      'candidateExecuted': false,
      'taskAcceptance': false,
    },
  );
  static bool _under(String path, String root) =>
      path == root || path.startsWith('$root/');
  static String _digest(List<int> bytes) => sha256.convert(bytes).toString();
  static void _copy(String path, List<int> bytes) {
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(bytes, flush: true);
  }

  static List<String> _depfile(String text) {
    final colon = text.indexOf(': ');
    if (colon < 0) {
      throw const FormatException('coding_compiler_depfile_invalid');
    }
    final result = <String>[];
    final token = StringBuffer();
    var escaped = false;
    for (final rune in text.substring(colon + 2).runes) {
      final char = String.fromCharCode(rune);
      if (escaped) {
        if (char != '\n') token.write(char);
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char.trim().isEmpty) {
        if (token.isNotEmpty) {
          result.add(token.toString());
          token.clear();
        }
      } else {
        token.write(char);
      }
    }
    if (escaped) throw const FormatException('coding_compiler_depfile_invalid');
    if (token.isNotEmpty) result.add(token.toString());
    if (result.isEmpty) {
      throw const FormatException('coding_compiler_depfile_empty');
    }
    return result;
  }
}

final class _Input {
  const _Input(this.canonical, this.hash);
  final String canonical;
  final String? hash;
}

final class _Package {
  const _Package({
    required this.raw,
    required this.root,
    required this.library,
    required this.identityPath,
    required this.snapshot,
    required this.own,
  });
  final Map<String, Object?> raw;
  final String root;
  final String identityPath;
  final String library;
  final String snapshot;
  final bool own;
}
