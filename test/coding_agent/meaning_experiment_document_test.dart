import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';
import 'package:lastanswer/coding_agent/meaning_greeting_binding.dart';

import 'meaning_native_test_composition.dart';

import 'pump_until.dart';

void main() {
  testWidgets(
    'document keys, exact consent and intent projection share native state',
    (tester) async {
      final root = await tester.runAsync(
        () => Directory.systemTemp.createTemp('la_meaning_doc_'),
      );
      final workspace = Directory('${root!.path}/fixture')..createSync();
      addTearDown(() => root.delete(recursive: true));
      final fixture = Directory(
        '../../ecsai_harness/pkgs/xsoulspace_agentic_experiments/test/fixtures/meaning_greeting',
      );
      await tester.runAsync(() async {
        final manifest =
            jsonDecode(File('${fixture.path}/manifest.json').readAsStringSync())
                as Map;
        for (final raw in manifest['assets'] as List) {
          final asset = raw as Map;
          final copied = File('${workspace.path}/${asset['workspace_path']}');
          copied.parent.createSync(recursive: true);
          copied.writeAsBytesSync(
            File('${fixture.path}/${asset['fixture_path']}').readAsBytesSync(),
          );
        }
        final pub = await runMeaningComponentDart('dart', [
          'pub',
          'get',
          '--offline',
        ], workspace.path);
        expect(pub.exitCode, 0, reason: '${pub.stderr}');
      });
      final source = File('${workspace.path}/lib/greeting.dart');
      final before = source.readAsBytesSync();
      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          meaningProfile: true,
          checkCommand: const ['dart', 'test'],
          extraToolsWithContext: meaningGreetingTools(
            workspace.path,
            nativeComposition: meaningNativeTestComposition,
          ),
        ),
      );
      addTearDown(controller.dispose);
      await tester.runAsync(() => controller.createSession(workspace.path));
      expect(controller.error, isNull);
      final doc = (ProjectModel.emptyAgent() as ProjectModelDoc).copyWith(
        agent: AgentDocModel(
          workspaces: [workspace.path],
          checkCommand: const ['dart', 'test'],
        ),
      );
      Widget surface() => MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(doc: doc, controller: controller),
        ),
      );
      await tester.pumpWidget(surface());
      await tester.tap(find.byKey(const Key('coding_agent.meaning.preview')));
      await pumpUntil(
        tester,
        () =>
            controller.meaning.preview != null ||
            controller.meaning.refusal != null,
        maxCycles: 6000,
      );
      await tester.pump();
      expect(controller.meaning.refusal, isNull);
      expect(find.byKey(const Key('coding_agent.meaning.diff')), findsNothing);
      await tester.tap(find.byKey(const Key('coding_agent.meaning.details')));
      await tester.pump();
      expect(
        find.byKey(const Key('coding_agent.meaning.diff')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('coding_agent.meaning.details')));
      await tester.pump();
      expect(find.textContaining('Hello, Ada! — updated'), findsWidgets);
      expect(source.readAsBytesSync(), before);
      final stateEntry = agentMcpEntries().singleWhere(
        (entry) => entry.name == 'agent_doc_state',
      );
      final projected = await stateEntry.invokeDirect({'docId': doc.id.value});
      expect(projected.data['meaning'], AgentDocSurface.debugState!.meaning);
      await tester.tap(find.byKey(const Key('coding_agent.meaning.apply')));
      await pumpUntil(
        tester,
        () => controller.pendingPermission != null,
        maxCycles: 6000,
      );
      await tester.pump();
      expect(
        find.byKey(const Key('coding_agent.permission.reject')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('coding_agent.permission.allow')),
        findsOneWidget,
      );
      final exact =
          jsonDecode(controller.pendingPermission!.request.details!) as Map;
      expect(exact['proposalId'], controller.meaning.proposalId);
      expect(
        controller.meaningReviewProposal?['payload'],
        containsPair('proposalId', controller.meaning.proposalId),
      );
      await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
      await pumpUntil(tester, () => !controller.meaning.busy, maxCycles: 6000);
      await tester.pump();
      expect(
        controller.meaning.rollbackAvailable,
        true,
        reason: '${controller.meaning.toJson()}',
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(surface());
      expect(
        find.byKey(const Key('coding_agent.meaning.current_observation')),
        findsOneWidget,
      );
      final rollbackEntry = agentMcpEntries().singleWhere(
        (entry) => entry.name == 'agent_meaning_change',
      );
      Map<String, Object?>? rollback;
      unawaited(
        rollbackEntry
            .invokeDirect({'docId': doc.id.value, 'action': 'rollback'})
            .then(
              (result) => rollback = Map<String, Object?>.from(result.data),
            ),
      );
      await pumpUntil(tester, () => rollback != null, maxCycles: 6000);
      expect(rollback!['ok'], true, reason: '$rollback');
      await tester.pump();
      expect(source.readAsBytesSync(), before);
      expect(AgentDocSurface.debugState!.meaning!['rollbackAvailable'], false);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
