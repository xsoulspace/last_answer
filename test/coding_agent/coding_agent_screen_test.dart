// TASK B / ADR 0003 Phase 1 — widget gate: the AGENT DOC surface drives the
// embedded harness end to end (LLM-free, scripted mover):
//
// task input (sentence + workspace) → delegate → the write-gate permission
// prompt surfaces → the user answers ALLOW → the verdict surfaces in the
// UI — and the doc payload persists the workspace binding (syncable doc
// data). Everything through the REAL surface widgets — no protocol bypass.
import 'dart:io';

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:core/core.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

ProjectModelDoc _agentDoc() => ProjectModel.emptyAgent() as ProjectModelDoc;

/// Fake directory picker (no real NSOpenPanel inside a widget test).
final class _FakeFileSelectorPlatform extends FileSelectorPlatform {
  _FakeFileSelectorPlatform(this.path);

  final String? path;

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async => path;
}

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

  testWidgets(
    'empty state: an agent doc with no workspace instructs the human',
    (final tester) async {
      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          handlerFactory: (_) =>
              ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(
              key: const ValueKey('unbound'),
              doc: _agentDoc(),
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('coding_agent.empty_state')),
        findsOneWidget,
        reason: 'a doc with no workspace must show the honest guide',
      );
      expect(find.textContaining('Bind a workspace'), findsWidgets);
      expect(
        find.textContaining('asks you first'),
        findsOneWidget,
        reason: 'the guide must say that writes ask permission',
      );
      expect(
        find.textContaining('verdict'),
        findsWidgets,
        reason: 'the guide must say where the verdict lands',
      );

      // A doc WITH a bound workspace shows no guide (the binding is the
      // gate, not the text field's content).
      final bound = _agentDoc().copyWith(
        agent: const AgentDocModel().copyWith(workspaces: ['/tmp/whatever']),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(
              key: const ValueKey('bound'),
              doc: bound,
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('coding_agent.empty_state')),
        findsNothing,
        reason: 'a bound workspace closes the guide (the binding gates it)',
      );
    },
  );

  testWidgets(
    'workspace picker: choosing a directory fills the field (text field '
    'stays for power users); nothing persists until delegate',
    (final tester) async {
      FileSelectorPlatform.instance = _FakeFileSelectorPlatform(
        '/tmp/picked-workspace',
      );

      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          handlerFactory: (_) =>
              ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
        ),
      );
      addTearDown(controller.dispose);

      final docUpdates = <ProjectModelDoc>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(
              doc: _agentDoc(),
              controller: controller,
              onDocChanged: docUpdates.add,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('coding_agent.workspace.pick')));
      await tester.pump();

      expect(
        tester
            .widget<TextField>(find.byKey(const Key('coding_agent.workspace')))
            .controller!
            .text,
        '/tmp/picked-workspace',
        reason: 'the picked directory must land in the same field',
      );
      expect(
        docUpdates,
        isEmpty,
        reason: 'persistence stays as today: pinned on delegate',
      );

      // A cancelled dialog (null path) leaves the field untouched.
      FileSelectorPlatform.instance = _FakeFileSelectorPlatform(null);
      await tester.tap(find.byKey(const Key('coding_agent.workspace.pick')));
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('coding_agent.workspace')))
            .controller!
            .text,
        '/tmp/picked-workspace',
      );
    },
  );

  testWidgets('check override: typing a check command persists it into the doc '
      'payload (the human can target the oracle at the task)', (
    final tester,
  ) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) =>
            ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
      ),
    );
    addTearDown(controller.dispose);

    final docUpdates = <ProjectModelDoc>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(
            doc: _agentDoc(),
            controller: controller,
            onDocChanged: docUpdates.add,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('coding_agent.check')),
      'dart run tool/agent_fixture/main.dart',
    );
    await tester.pump();

    final persisted = docUpdates.last.agent!;
    expect(persisted.checkCommand, [
      'dart',
      'run',
      'tool/agent_fixture/main.dart',
    ], reason: 'the override persists as literal argv (no shell), ADR 0003');

    // Clearing the field returns to the workspace convention (D8).
    await tester.enterText(find.byKey(const Key('coding_agent.check')), '');
    await tester.pump();
    expect(docUpdates.last.agent!.checkCommand, isEmpty);
  });

  testWidgets(
    'OpenRouter without a key: honest pre-session config error surfaces '
    '(never a mid-turn crash)',
    (final tester) async {
      if (Platform.environment['OPENROUTER_API_KEY'] case final key?
          when key.isNotEmpty) {
        // ignore: avoid_print
        print(
          'OPENROUTER_KEY_TEST_SKIPPED: OPENROUTER_API_KEY is set in the '
          'environment, so the missing-key error cannot be exercised',
        );
        return;
      }
      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          handlerFactory: (_) =>
              ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(doc: _agentDoc(), controller: controller),
          ),
        ),
      );
      await tester.pump();

      // Switch the backend to OpenRouter through the REAL setup toggle
      // (labeled as the backup runtime — AFM is the real-work default).
      await tester.tap(find.textContaining('OpenRouter'));
      await tester.pump();
      await pumpUntil(tester, () => controller.config.backend == 'open_router');

      await tester.enterText(
        find.byKey(const Key('coding_agent.workspace')),
        workspace.path,
      );
      await tester.enterText(
        find.byKey(const Key('coding_agent.task')),
        'Fix main.dart so `dart run main.dart` exits 0.',
      );
      await tester.tap(find.byKey(const Key('coding_agent.delegate')));
      await pumpUntil(tester, () => controller.error != null);
      await tester.pump();

      expect(
        find.byKey(const Key('coding_agent.error')),
        findsOneWidget,
        reason: 'the missing-key config error must surface in the UI',
      );
      expect(
        find.textContaining('API key'),
        findsWidgets,
        reason: 'the error must tell the human what to do (enter a key)',
      );
      expect(
        controller.current,
        isNull,
        reason: 'no session may be created without a resolvable key',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets('the working surface is a conversation: PROFILE pane exposes the '
      'honest context load (turns, spend, permissions)', (final tester) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) =>
            ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(doc: _agentDoc(), controller: controller),
        ),
      ),
    );
    await tester.pump();

    // Profile hidden by default; toggled on from the status rule.
    expect(find.byKey(const Key('coding_agent.profile')), findsNothing);
    await tester.tap(find.byKey(const Key('coding_agent.profile.toggle')));
    await tester.pump();
    expect(find.byKey(const Key('coding_agent.profile')), findsOneWidget);
    expect(
      find.textContaining('turns 0'),
      findsOneWidget,
      reason: 'the profile must state the context load concisely',
    );
    expect(find.textContaining('PERMISSIONS'), findsOneWidget);

    // Delegate one turn; the profile then shows the spend from the
    // verdict line (the honest tokens source).
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
    await pumpUntil(tester, () => controller.pendingPermission != null);
    await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
    await pumpUntil(tester, () => !controller.isRunning);
    await tester.pump();

    expect(
      find.textContaining('turns 1'),
      findsOneWidget,
      reason: 'the profile must show the completed turn count',
    );
    expect(
      find.textContaining('#1 PASS'),
      findsOneWidget,
      reason: 'the small-multiple row must carry verdict + spend',
    );
    expect(
      find.textContaining('write main.dart'),
      findsWidgets,
      reason: 'the permission log must show the round-trip as data',
    );
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('enter delegates from the composer (messenger pattern)', (
    final tester,
  ) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) =>
            ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(doc: _agentDoc(), controller: controller),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('coding_agent.workspace')),
      workspace.path,
    );
    await tester.enterText(
      find.byKey(const Key('coding_agent.task')),
      'Fix main.dart so `dart run main.dart` exits 0.',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await pumpUntil(tester, () => controller.pendingPermission != null);
    expect(
      find.byKey(const Key('coding_agent.permission')),
      findsOneWidget,
      reason: 'enter in the composer must delegate the sentence',
    );
    // Finish the turn (allow → verdict) so no timer is left pending.
    await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
    await pumpUntil(tester, () => !controller.isRunning);
    await tester.pump();
    expect(
      find.textContaining('verdict: PASS'),
      findsWidgets,
      reason: 'the full ⏎ loop must land the verdict on the grid',
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}
