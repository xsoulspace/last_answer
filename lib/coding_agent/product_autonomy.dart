import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/product_candidate_verification.dart';
import 'package:lastanswer/coding_agent/product_dart_runtime.dart';
import 'package:lastanswer/coding_agent/product_journey_seed.dart';
import 'package:lastanswer/coding_agent/product_local_pair.dart';
import 'package:lastanswer/coding_agent/product_web_preview.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';
import 'package:xsoulspace_agentic_host/conventional_change.dart';

/// Retained native resources, not another world or execution loop. A view may
/// leave and reattach to the same controller while its existing pump continues.
final class ProductAutonomy {
  ProductAutonomy._(this.authority, this.preview, this.tooling);
  final ConventionalChangeAuthority authority;
  final ProductWebPreview preview;
  final ProductWorkspaceTooling tooling;
  static final _projects = <String, ProductAutonomy>{};
  static final changes = ValueNotifier<int>(0);
  static final controllers = <String, HarnessSessionController>{};
  static final subscriptions = <String, ({String clientId, String model})>{};
  static final localPairs = <String, ProductLocalPair>{};

  static ProductAutonomy? forWorkspace(String path) {
    if (path.isEmpty || !Directory(path).existsSync()) return null;
    return _projects[Directory(path).resolveSymbolicLinksSync()];
  }

  static Future<ProductAutonomy> start(Directory workspace) async {
    workspace.createSync(recursive: true);
    final root = Directory(workspace.resolveSymbolicLinksSync());
    final existing = _projects[root.path];
    if (existing != null &&
        !existing.authority.revoked &&
        DateTime.now().isBefore(existing.authority.expiresAt)) {
      return existing;
    }
    // Starting a board never overwrites an existing source file.
    final main = File('${root.path}/main.dart');
    if (!main.existsSync()) {
      main.writeAsStringSync(productJourneySeed, flush: true);
    }
    final authority = ConventionalChangeAuthority(
      workspace: root,
      writablePaths: const ['main.dart'],
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
    );
    final compiler = ProductDartCandidateVerifier(web: true);
    final preview =
        existing?.preview ?? ProductWebPreview(root, compiler: compiler);
    final session = ProductAutonomy._(
      authority,
      preview,
      ProductWorkspaceTooling(
        standingAuthority: authority,
        verifyCandidate: compiler.verifyCandidate,
        verificationDescription:
            'Contained Dart web compiler; visible behavior checked separately',
        verificationScratchPaths: const ['.dart_tool'],
      ),
    );
    _projects[root.path] = session;
    changes.value++;
    await preview.start();
    return session;
  }

  void revoke() {
    authority.revoke();
    changes.value++;
  }

  /// Compiler-only final check supplied by product composition, not user PATH
  /// setup. Rendered behavior remains independently evaluated.
  Future<List<String>> goalCheckCommand() async {
    final runtime = await ProductDartRuntime.forApplication();
    await runtime.inspectCompiler();
    final sdk = '${runtime.bundleRoot.path}/dart-sdk';
    return [
      '$sdk/bin/dartaotruntime',
      '$sdk/bin/snapshots/dart2js_aot.dart.snapshot',
      '--invoker=dart_cli',
      '--libraries-spec=$sdk/lib/libraries.json',
      '--platform-binaries=$sdk/lib/_internal',
      '--no-source-maps',
      '--csp',
      'main.dart',
      '-o',
      '.dart_tool/task-board-check.js',
    ];
  }

  Map<String, Object?> toJson() => {
    'authority': authority.toSummary(),
    'product': preview.toJson(),
    'meaningMaterialization': 'paused_for_this_journey',
  };
}
