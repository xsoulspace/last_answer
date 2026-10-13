import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/coding_agent/product_candidate_verification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_storage_live_apply/universal_storage_live_apply.dart';
import 'package:xsoulspace_agentic_harness/workspace_api.dart'
    show FsToolsRoot, listDirTool;
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/conventional_change.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// Product preparation installs proposals into the existing meaning tool pump.
/// It never enables raw filesystem tools or runs candidate code in the app.
final class ProductWorkspaceTooling {
  ProductWorkspaceTooling({
    this.verifyCandidate,
    this.verificationDescription = 'Contained candidate verification',
    this.supportDirectory = getApplicationSupportDirectory,
    List<String> verificationScratchPaths = const [],
  }) : verificationScratchPaths = List.unmodifiable(verificationScratchPaths);

  static final instance = ProductWorkspaceTooling(
    verifyCandidate: ProductDartCandidateVerifier.instance.verifyCandidate,
    verificationDescription:
        'Contained dependency-free Dart compiler check; '
        'functional and task acceptance remain separate',
    verificationScratchPaths: const ['.dart_tool'],
  );
  final Future<ConventionalCheck> Function(Directory candidate)?
  verifyCandidate;
  final String verificationDescription;
  final Future<Directory> Function() supportDirectory;
  final List<String> verificationScratchPaths;
  final _prepared = <String, Map<Object?, ProductWorkspaceToolBinding>>{};

  /// Drop this UI owner's cache references; issued effects and journals remain
  /// with the native host. Existing live bindings are not mutated or replayed.
  void forgetOwner(Object ownerKey) {
    for (final owners in _prepared.values) {
      owners.remove(ownerKey);
    }
    _prepared.removeWhere((_, owners) => owners.isEmpty);
  }

  Future<ProductWorkspaceToolBinding> prepare(
    String workspace, {
    Object? ownerKey,
    bool Function(HostToolExtensionContext context)? canReviewSaved,
  }) async {
    final directory = Directory(workspace);
    if (!directory.isAbsolute) {
      throw const FormatException('coding_absolute_workspace_required');
    }
    final canonical = await directory.resolveSymbolicLinks();
    final existing = _prepared[canonical]?[ownerKey];
    if (existing != null) return existing;
    final root = FsToolsRoot(
      canonical,
      pathAllowed: (absolute) {
        final prefix = '$canonical/';
        if (absolute == canonical) return true;
        if (!absolute.startsWith(prefix)) return false;
        final relative = absolute.substring(prefix.length);
        return _discoverable(
          relative,
          FileSystemEntity.typeSync(absolute, followLinks: false) ==
              FileSystemEntityType.directory,
        );
      },
    );
    final listing = listDirTool(root);
    final pending = <String>[''];
    final paths = <String>[];
    var directories = 0;
    // Metadata only. The native read/readFile action captures bytes, validates
    // text and enforces its own source budget when a dependency is requested.
    while (pending.isNotEmpty && paths.isEmpty) {
      final parent = pending.removeAt(0);
      if (++directories > 128 || parent.split('/').length > 32) {
        throw const FormatException('coding_seed_discovery_limit');
      }
      final raw = await listing.execute({'path': parent});
      if (raw == null) {
        throw const FormatException('coding_seed_directory_unavailable');
      }
      final entries = (jsonDecode(raw) as List).cast<String>();
      if (entries.length > 65536) {
        throw const FormatException('coding_directory_membership_limit');
      }
      final files = <String>[];
      for (final name in entries) {
        final directory = name.endsWith('/');
        final relative = directory ? name.substring(0, name.length - 1) : name;
        if (!_discoverable(relative, directory) ||
            FileSystemEntity.typeSync(
                  '$canonical/$relative',
                  followLinks: false,
                ) ==
                FileSystemEntityType.link) {
          continue;
        }
        if (directory) {
          pending.add(relative);
        } else {
          files.add(relative);
        }
      }
      const preferred = [
        'main.dart',
        'pubspec.yaml',
        'Cargo.toml',
        'package.json',
      ];
      for (final name in preferred) {
        final relative = parent.isEmpty ? name : '$parent/$name';
        if (files.contains(relative)) paths.add(relative);
      }
      if (paths.isEmpty && files.isNotEmpty) paths.add(files.first);
    }
    if (paths.isEmpty) {
      throw const FormatException('coding_supported_source_required');
    }
    final support = await supportDirectory();
    final key = sha256.convert(utf8.encode(canonical)).toString();
    final binding = ProductWorkspaceToolBinding._(
      canonical,
      List.unmodifiable(paths),
      LiveApplyJournalStore(storePath: '${support.path}/coding_recovery/$key'),
      verifyCandidate ??
          (_) async => const ConventionalCheck(
            ok: false,
            evidence: {
              'error': 'coding_contained_verifier_unavailable',
              'candidateExecuted': false,
              'liveSourceMutated': false,
            },
          ),
      verificationDescription,
      verificationScratchPaths,
      canReviewSaved,
    );
    (_prepared[canonical] ??= {})[ownerKey] = binding;
    return binding;
  }

  static bool _discoverable(String path, bool directory) {
    if (path.isEmpty || path.contains(r'\')) return false;
    if (path
        .split('/')
        .any(
          (p) =>
              p.isEmpty ||
              p.startsWith('.') ||
              p == 'build' ||
              p == 'node_modules',
        )) {
      return false;
    }
    return directory || _supported(path);
  }

  static bool _supported(String path) {
    final segments = path.split('/');
    if (segments.any((p) => p.isEmpty || p.startsWith('.')) ||
        path.contains(r'\')) {
      return false;
    }
    return const [
      '.dart',
      '.md',
      '.txt',
      '.json',
      '.yaml',
      '.yml',
      '.lock',
      '.toml',
      '.rs',
      '.py',
      '.ts',
      '.tsx',
      '.js',
      '.jsx',
      '.cs',
      '.swift',
      '.kt',
      '.java',
      '.c',
      '.h',
      '.cpp',
      '.html',
      '.css',
    ].any(path.endsWith);
  }
}

final class ProductWorkspaceToolBinding {
  ProductWorkspaceToolBinding._(
    this.workspace,
    this.dependencyPaths,
    this.store,
    this.verifyCandidate,
    this.verificationDescription,
    this.verificationScratchPaths,
    this.canReviewSaved,
  );

  final String workspace;
  final List<String> dependencyPaths;
  final LiveApplyJournalStore store;
  final Future<ConventionalCheck> Function(Directory) verifyCandidate;
  final String verificationDescription;
  final List<String> verificationScratchPaths;
  final bool Function(HostToolExtensionContext)? canReviewSaved;
  final _instances = <World, Map<String, ConventionalChangeToolExtension>>{};
  final observation = ValueNotifier<Map<String, Object?>?>(null);
  Map<String, Object?>? _previewObservation;
  final _reviews = <String, Map<String, Object?>>{};
  List<Map<String, Object?>> _savedCandidates = const [];
  List<Map<String, Object?>> get savedCandidates => _savedCandidates;
  String? _undoRunId;
  String? get undoRunId => _undoRunId;

  /// Retains the native review projection while its subsequent Apply awaits
  /// consent. This is display state, not a saved candidate or action grant.
  Map<String, Object?>? get previewObservation => _previewObservation;

  Map<String, Object?> toJson() => {
    'workspace': workspace,
    'preview': previewObservation,
    'lastOutcome': observation.value,
    'authority': 'native_owner_only',
  };

  Map<String, Object?>? reviewFor(Map exact) {
    final key =
        '${exact['taskId']}:${exact['proposalId']}:${exact['effectDigest']}';
    return _reviews[key];
  }

  void _observe(Map<String, Object?> outcome) {
    final result = outcome['result'] as Map?;
    if (result?['ok'] == true &&
        !const {
          'preview',
          'adoptCandidate',
          'apply',
          'rollback',
          'recoverRollback',
          'status',
          'finalize',
        }.contains(outcome['action'])) {
      return;
    }
    if (const {'preview', 'adoptCandidate'}.contains(outcome['action']) &&
        result?['ok'] == true) {
      _previewObservation = Map.unmodifiable(outcome);
      final proposal = result!['proposal'] as Map;
      final key =
          '${proposal['taskId']}:${proposal['proposalId']}:'
          '${proposal['effectDigest']}';
      _reviews[key] = _previewObservation!;
      if (_reviews.length > 128) _reviews.remove(_reviews.keys.first);
    }
    if (result?['ok'] == true && outcome['action'] == 'status') {
      _savedCandidates = [
        for (final row in (result?['saved_candidates'] as List? ?? const []))
          if (row is Map) Map<String, Object?>.unmodifiable(row),
      ];
      _undoRunId = null;
      final runs = result?['native_runs'] as List? ?? const [];
      for (final row in runs.whereType<Map>()) {
        if (row['status'] == 'applied') _undoRunId = row['runId'] as String?;
      }
    }
    if (result?['ok'] == true &&
        outcome['action'] == 'apply' &&
        result?['rollback_available'] == true) {
      _undoRunId = result?['runId'] as String?;
    }
    if (result?['ok'] == true &&
        const {
          'rollback',
          'recoverRollback',
          'finalize',
        }.contains(outcome['action']) &&
        result?['runId'] == _undoRunId) {
      _undoRunId = null;
    }
    // A display observation is never used to authorize another operation.
    observation.value = Map.unmodifiable(outcome);
  }

  final _compositions =
      <
        List<ToolDef> Function(HostToolExtensionContext),
        List<ToolDef> Function(HostToolExtensionContext)
      >{};

  /// Existing semantic actions and conventional candidates share the same
  /// install callback and native owner. Neither route replaces the other.
  List<ToolDef> Function(HostToolExtensionContext) compose(
    List<ToolDef> Function(HostToolExtensionContext)? semanticTools,
  ) {
    if (semanticTools == null) return tools;
    return _compositions.putIfAbsent(
      semanticTools,
      () =>
          (context) => [...semanticTools(context), ...tools(context)],
    );
  }

  // Stable callback identity prevents restarting the owner on every turn.
  // ignore: prefer_function_declarations_over_variables
  late final List<ToolDef> Function(HostToolExtensionContext) tools =
      (context) {
        if (context.workspace.resolveSymbolicLinksSync() != workspace) {
          return const [];
        }
        final tasks = _instances[context.world] ??= {};
        var extension = tasks[context.taskId];
        if (extension == null || !extension.context.isCurrent) {
          extension = tasks[context.taskId] = ConventionalChangeToolExtension(
            context: context,
            store: store,
            dependencyPaths: dependencyPaths,
            allowWrite: (path) =>
                ProductWorkspaceTooling._discoverable(path, false),
            allowDiscover: ProductWorkspaceTooling._discoverable,
            verifyCandidate: verifyCandidate,
            verificationDescription: verificationDescription,
            verificationScratchPaths: verificationScratchPaths,
            onOutcome: _observe,
            canAdoptCandidate: (_) async =>
                canReviewSaved?.call(context) ?? false,
            canRecoverRun: (_) async => canReviewSaved?.call(context) ?? false,
          );
        }
        return extension.tools;
      };
}
