import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';

void main() {
  test(
    'ordinary preparation scopes source and refuses uncontained checks',
    () async {
      final root = await Directory.systemTemp.createTemp('product_scope_');
      addTearDown(() => root.delete(recursive: true));
      final workspace = await Directory('${root.path}/project').create();
      final support = await Directory('${root.path}/support').create();
      final lib = await Directory('${workspace.path}/lib').create();
      File('${lib.path}/digest.dart').writeAsStringSync('void main() {}\n');
      File('${workspace.path}/README.md').writeAsStringSync('Source');
      File('${workspace.path}/pubspec.yaml').writeAsStringSync('name: digest');
      File('${workspace.path}/.env').writeAsStringSync('private');
      File('${workspace.path}/logo.png').writeAsBytesSync([0, 255]);
      Directory('${workspace.path}/build').createSync();
      File(
        '${workspace.path}/build/output.dart',
      ).writeAsStringSync('generated');
      if (!Platform.isWindows) {
        Link(
          '${workspace.path}/linked.dart',
        ).createSync('${lib.path}/digest.dart');
      }
      final preparation = ProductWorkspaceTooling(
        supportDirectory: () async => support,
      );
      final binding = await preparation.prepare(workspace.path);
      expect(binding.dependencyPaths, ['pubspec.yaml']);
      expect(
        identical(binding, await preparation.prepare(workspace.path)),
        true,
      );
      expect(identical(binding.tools, binding.tools), true);
      final refused = await binding.verifyCandidate(workspace);
      expect(refused.ok, false);
      expect(
        refused.evidence['error'],
        'coding_contained_verifier_unavailable',
      );
      expect(refused.evidence['candidateExecuted'], false);
      expect(
        File('${lib.path}/digest.dart').readAsStringSync(),
        'void main() {}\n',
      );
    },
  );

  test(
    'large workspace prepares seeds, explicit dependency reads stay bounded',
    () async {
      final root = await Directory.systemTemp.createTemp('product_lazy_');
      addTearDown(() => root.delete(recursive: true));
      final workspace = await Directory('${root.path}/project').create();
      File('${workspace.path}/main.dart').writeAsStringSync('void main() {}\n');
      File(
        '${workspace.path}/huge.dart',
      ).writeAsBytesSync(List.filled(3 * 1024 * 1024, 65));
      File('${workspace.path}/invalid.dart').writeAsBytesSync([255]);
      final lib = await Directory('${workspace.path}/lib').create();
      for (var i = 0; i < 1200; i++) {
        File(
          '${lib.path}/source_$i.dart',
        ).writeAsStringSync('const value = 1;');
      }
      final preparation = ProductWorkspaceTooling(
        supportDirectory: () async => root,
      );
      final binding = await preparation.prepare(workspace.path);
      expect(binding.dependencyPaths, ['main.dart']);
      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          meaningProfile: true,
          extraToolsWithContext: binding.tools,
        ),
      );
      addTearDown(() async {
        await controller.host.stop();
        controller.dispose();
      });
      await controller.createSession(workspace.path);
      final session = controller.current!.id;
      final source = await controller.host.conventionalAction(
        session,
        'read',
        {},
      );
      expect(source['ok'], true, reason: '$source');
      final listing = await controller.host.conventionalAction(
        session,
        'listSources',
        {'sourceId': source['sourceId'], 'path': '', 'limit': 128},
      );
      expect(listing['ok'], true, reason: '$listing');
      expect(listing['sourceBytesCaptured'], false);
      expect((listing['entries']! as List).length, 4);
      final huge = await controller.host.conventionalAction(
        session,
        'readFile',
        {'sourceId': source['sourceId'], 'path': 'huge.dart'},
      );
      expect(huge['error'], 'coding_source_limit');
      final invalid = await controller.host.conventionalAction(
        session,
        'readFile',
        {'sourceId': source['sourceId'], 'path': 'invalid.dart'},
      );
      expect(invalid['error'], 'coding_source_encoding_unsupported');
      final page = await controller.host.conventionalAction(
        session,
        'listSources',
        {'sourceId': source['sourceId'], 'path': 'lib', 'limit': 128},
      );
      expect(page['hasMore'], true);
      expect((page['entries']! as List).length, 128);
      expect(binding.dependencyPaths, ['main.dart']);
    },
  );
}
