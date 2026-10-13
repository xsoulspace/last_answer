import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/product_coding_change_view.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';
import 'package:xsoulspace_agentic_host/conventional_change.dart';

void main() {
  testWidgets('visual candidate answers its exact pending round-trip', (
    tester,
  ) async {
    final root = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('visual_code_'),
    ))!;
    final workspace = Directory('${root.path}/project')..createSync();
    Directory('${workspace.path}/lib').createSync();
    final original = File('${workspace.path}/lib/value.dart')
      ..writeAsStringSync('int answer() => 1;\n');
    File('${workspace.path}/obsolete.txt').writeAsStringSync('old');
    File('${workspace.path}/main.dart').writeAsStringSync(
      "import 'lib/value.dart';\nvoid main() => print(answer());\n",
    );
    final support = Directory('${root.path}/support')..createSync();
    // This trusted unit checker does not execute untrusted code; it grades UI
    // routing only, not provider capability or production containment.
    final preparation = ProductWorkspaceTooling(
      supportDirectory: () async => support,
      verifyCandidate: (_) async => const ConventionalCheck(
        ok: true,
        evidence: {'exitCode': 0, 'stdout': 'unit checker passed'},
      ),
    );
    late HarnessSessionController controller;
    final binding = (await tester.runAsync(
      () => preparation.prepare(
        workspace.path,
        canReviewSaved: (context) =>
            controller.host.admitsSavedCodeReview(context),
      ),
    ))!;
    controller = HarnessSessionController(
      config: HarnessHostConfig(
        meaningProfile: true,
        extraToolsWithContext: binding.tools,
      ),
    );
    addTearDown(() async {
      await tester.runAsync(controller.host.stop);
      controller.dispose();
      await tester.runAsync(() => root.delete(recursive: true));
    });
    await tester.runAsync(() => controller.createSession(workspace.path));
    expect(controller.error, null);
    final session = controller.current!.id;
    Future<Map<String, Object?>> action(
      String name, [
      Map<String, Object?> args = const {},
    ]) async => (await tester.runAsync(
      () => controller.host.conventionalAction(session, name, args),
    ))!;
    Future<Map<String, Object?>> freshPreview() async {
      final seed = await action('read');
      final value = await action('readFile', {
        'sourceId': seed['sourceId'],
        'path': 'lib/value.dart',
      });
      final read = await action('readFile', {
        'sourceId': value['sourceId'],
        'path': 'obsolete.txt',
      });
      final target = await action('declareTarget', {
        'sourceId': read['sourceId'],
        'path': 'lib/helper.dart',
      });
      return action('preview', {
        'sourceId': target['sourceId'],
        'changesJson': jsonEncode({
          'lib/value.dart': "import 'helper.dart';\nint answer() => value;\n",
          'lib/helper.dart': 'const value = 2;\n',
          'obsolete.txt': null,
        }),
      });
    }

    final preview = await freshPreview();
    expect(preview['ok'], true, reason: '$preview');
    final proposal = preview['proposal']! as Map;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductCodingChangeView(
              binding: binding,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final before = tester.widget<SelectableText>(
      find.byKey(
        const ValueKey('coding_agent.change.file.lib/value.dart.before'),
      ),
    );
    expect(before.data, 'int answer() => 1;\n');
    final after = tester.widget<SelectableText>(
      find.byKey(
        const ValueKey('coding_agent.change.file.lib/value.dart.after'),
      ),
    );
    expect(after.data, "import 'helper.dart';\nint answer() => value;\n");
    expect(find.text('create  lib/helper.dart'), findsOneWidget);
    expect(find.text('delete  obsolete.txt'), findsOneWidget);
    expect(find.textContaining('unit checker passed'), findsOneWidget);
    expect(find.byKey(const Key('coding_agent.change.apply')), findsNothing);
    expect(original.readAsStringSync(), 'int answer() => 1;\n');

    late Future<Map<String, Object?>> applying;
    await tester.runAsync(() async {
      final requested = controller.nextPermission(
        timeout: const Duration(seconds: 10),
      );
      applying = controller.host.conventionalAction(session, 'apply', {
        'proposalId': proposal['proposalId'],
      });
      await requested;
    });
    expect(controller.pendingPermission, isNotNull);
    await tester.pump();
    final rejectButton = find.byKey(const Key('coding_agent.change.reject'));
    expect(rejectButton, findsOneWidget);
    await tester.ensureVisible(rejectButton);
    await tester.tap(rejectButton);
    await tester.pumpAndSettle();
    final denied = (await tester.runAsync(() => applying))!;
    expect(denied['ok'], false);
    expect(controller.pendingPermission, null);
    expect(find.byKey(const Key('coding_agent.change.apply')), findsNothing);
    expect(original.readAsStringSync(), before.data);
    final nextPreview = await freshPreview();
    expect(nextPreview['ok'], true, reason: '$nextPreview');
    final nextProposal = nextPreview['proposal']! as Map;
    expect(nextProposal['proposalId'], isNot(proposal['proposalId']));
    await tester.runAsync(() async {
      final requested = controller.nextPermission(
        timeout: const Duration(seconds: 10),
      );
      applying = controller.host.conventionalAction(session, 'apply', {
        'proposalId': nextProposal['proposalId'],
      });
      await requested;
    });
    await tester.pump();
    final applyButton = find.byKey(const Key('coding_agent.change.apply'));
    expect(applyButton, findsOneWidget);
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();
    final applied = (await tester.runAsync(() => applying))!;
    expect(applied['ok'], true, reason: '$applied');
    expect(applied['proposalId'], nextProposal['proposalId']);
    expect(controller.pendingPermission, null);
    expect(find.byKey(const Key('coding_agent.change.apply')), findsNothing);
    expect(original.readAsStringSync(), after.data);
    expect(File('${workspace.path}/lib/helper.dart').existsSync(), true);
    expect(File('${workspace.path}/obsolete.txt').existsSync(), false);
    final undo = await action('rollback', {
      'proposalId': nextProposal['proposalId'],
      'runId': applied['runId'],
    });
    expect(undo['ok'], true, reason: '$undo');
    expect(original.readAsStringSync(), before.data);
    final adopted = await action('adoptCandidate', {
      'candidateId': preview['candidateId'],
    });
    expect(adopted['ok'], true, reason: '$adopted');
    expect(
      (adopted['proposal']! as Map)['proposalId'],
      isNot(proposal['proposalId']),
    );
    late Future<Map<String, Object?>> savedApplying;
    await tester.runAsync(() async {
      final requested = controller.nextPermission();
      savedApplying = controller.host.conventionalAction(session, 'apply', {
        'proposalId': (adopted['proposal']! as Map)['proposalId'],
      });
      await requested;
    });
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('coding_agent.change.apply')),
    );
    await tester.tap(find.byKey(const Key('coding_agent.change.apply')));
    await tester.pumpAndSettle();
    final savedApplied = (await tester.runAsync(() => savedApplying))!;
    expect(savedApplied['ok'], true, reason: '$savedApplied');
    final recovered = await action('recoverRollback', {
      'runId': savedApplied['runId'],
    });
    expect(recovered['ok'], true, reason: '$recovered');
    expect(original.readAsStringSync(), before.data);
    final status = await action('status');
    expect(status['saved_candidates'], isNotEmpty);
    expect(binding.savedCandidates, isNotEmpty);
  });
}
