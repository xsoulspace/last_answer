// TASK B / ADR 0003 Phase 1 — widget gate: the AGENT DOC surface drives the
// embedded harness end to end (LLM-free, scripted mover):
//
// task input (sentence + workspace) → delegate → the write-gate permission
// prompt surfaces → the user answers ALLOW → the verdict surfaces in the
// UI — and the doc payload persists the workspace binding (syncable doc
// data). Everything through the REAL surface widgets — no protocol bypass.
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

ProjectModelDoc _agentDoc() =>
    ProjectModel.emptyAgent() as ProjectModelDoc;

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('lastanswer_widget');
    File('${workspace.path}/main.dart').writeAsStringSync(
      "void main() { throw StateError('not implemented'); }\n",
    );
  });

  tearDown(() {
    try {
      workspace.deleteSync(recursive: true);
    } on Object {
      // best effort
    }
  });

  testWidgets(
    'delegate → permission prompt → allow → verdict surfaces; the doc '
    'payload pins the workspace',
    (final tester) async {
      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          handlerFactory: (_) =>
              ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
        ),
      );
      addTearDown(controller.dispose);

      final docUpdates = <ProjectModelDoc>[];
      final doc = _agentDoc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(
              doc: doc,
              controller: controller,
              onDocChanged: docUpdates.add,
            ),
          ),
        ),
      );

      // The user types the workspace and the task sentence, then delegates.
      await tester.enterText(
        find.byKey(const Key('coding_agent.workspace')),
        workspace.path,
      );
      await tester.enterText(
        find.byKey(const Key('coding_agent.task')),
        'Fix main.dart so `dart run main.dart` exits 0.',
      );
      await tester.tap(find.byKey(const Key('coding_agent.delegate')));
      await tester.pump();

      // The write-gate round-trip crosses the fake/real zone boundary —
      // alternate pump and runAsync until the prompt surfaces.
      await pumpUntil(tester, () => controller.pendingPermission != null);
      await tester.pump();

      expect(
        find.byKey(const Key('coding_agent.permission')),
        findsOneWidget,
        reason: 'the permission prompt must surface per write',
      );

      // The user-actor approves the write.
      await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
      await tester.pump();

      // The turn runs the workspace oracle (dart run main.dart) for real.
      await pumpUntil(tester, () => !controller.isRunning);
      await tester.pump();

      expect(
        find.textContaining('verdict: PASS'),
        findsWidgets,
        reason: 'the verdict must surface (banner + transcript)',
      );
      expect(
        find.byKey(const Key('coding_agent.verdict.card')),
        findsOneWidget,
        reason: 'the verdict banner must surface',
      );
      expect(
        File('${workspace.path}/main.dart').readAsStringSync(),
        contains("print('ok')"),
        reason: 'the allowed write must land in the workspace',
      );

      // ADR 0003: the workspace binding is DOC DATA — persisted via
      // onDocChanged into the syncable payload.
      expect(docUpdates, isNotEmpty, reason: 'the doc payload must update');
      final persisted = docUpdates.last;
      expect(persisted.agent, isNotNull);
      expect(persisted.agent!.workspaces, contains(workspace.path));
      expect(persisted.formatId, DocFormatIds.agent);

      // The agent/intent projection is live (MCP reads the same state).
      expect(AgentDocSurface.debugState, isNotNull);
      expect(AgentDocSurface.debugState!.workspaces, contains(workspace.path));
      expect(AgentDocSurface.debugState!.verdict, contains('PASS'));
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
