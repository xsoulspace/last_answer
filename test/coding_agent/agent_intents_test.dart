// R9.a — widget gate for the missing verbs: `agent_doc_create`,
// `agent_doc_bind`, `agent_task_guide`. Every entry is driven through its
// REAL intent entry (mcp_toolkit AgentCallEntry.invokeDirect) against the
// REAL surface — the scripted seam (LLM-free mover) keeps it deterministic.
//
// The binding is NEVER a form fill: the Phase-1.5 run measured that
// semantic text injection does not fire controller listeners, so
// `agent_doc_bind` writes the doc payload directly (ADR 0003 doc data).
// The guidance is a host-injected decision recorded as FIRST-CLASS grid
// state (GUIDE row + composer pre-fill), never a transcript-only line.
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

import 'pump_until.dart';

AgentCallEntry _entry(final String name) =>
    agentMcpEntries().firstWhere((final e) => e.name == name);

// The legacy mcpToolkitTool bridge wraps every MCPCallResult as
// AgentResult.success — the REAL ok flag is carried in data (the message
// carries the human-readable truth either way).
bool okOf(final AgentResult result) => result.data['ok'] == true;

ProjectModelDoc _agentDoc() => ProjectModel.emptyAgent() as ProjectModelDoc;

/// A mover for the FAIL → guide → PASS shape: it makes NO moves for the
/// first task (the workspace oracle FAILs honestly — main.dart still
/// throws) and writes the fix exactly ONCE when the prompt is the guided
/// continuation (`agent_task_guide` delegates "continue with guidance: …").
/// The harness calls [generate] MULTIPLE times per turn (one agency round
/// per tool call), so moves are keyed by PROMPT semantics, never by call
/// count — and a write fires once, then the mover goes quiet.
final class GuidedFixMover implements GenerationHandler {
  GuidedFixMover(this.path, this.content);

  final String path;
  final String content;
  bool _wrote = false;

  @override
  Future<ActorGenerateResponse> generate(
    final World world,
    final ActorGenerateRequest request,
  ) async {
    final guided = request.prompt.contains('continue with guidance');
    final calls = guided && !_wrote
        ? [ToolCall(name: const ToolName('write'), arguments: {
            'path': path,
            'content': content,
          })]
        : const <ToolCall>[];
    if (calls.isNotEmpty) _wrote = true;
    final text = calls.isEmpty ? 'no moves this round' : 'writing';
    final response = ActorGenerateResponse(
      actorEntity: request.actorEntity,
      structuredOutput: {'text': text},
      rawOutput: text,
      toolCalls: calls,
      taskId: request.taskId,
    );
    world.events.writer<ActorGenerateResponse>().send(response);
    return response;
  }
}

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('lastanswer_r9a');
    // The honest oracle: throws until the agent writes the fix.
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

  group('agent_doc_create', () {
    test(
      'returns the docId of the created + opened doc (app hook path)',
      () async {
        var hookCalls = 0;
        AgentDocSurface.createAgentProjectHook = () {
          hookCalls++;
          return ProjectModel.emptyAgent() as ProjectModelDoc;
        };
        addTearDown(() => AgentDocSurface.createAgentProjectHook = null);

        final result = await _entry('agent_doc_create').invokeDirect(const {});
        expect(okOf(result), isTrue, reason: result.message);
        final docId = result.data['docId'] as String?;
        expect(docId, isNotNull);
        expect(docId!.isNotEmpty, isTrue);
        expect(hookCalls, 1, reason: 'create + open is ONE verb');

        // A second create mints a NEW docId (each call is a new doc).
        final second = await _entry('agent_doc_create').invokeDirect(const {});
        expect(okOf(second), isTrue);
        expect(second.data['docId'], isNot(docId));
      },
    );

    test('refuses honestly when the app hook is not installed', () async {
      AgentDocSurface.createAgentProjectHook = null;
      final result = await _entry('agent_doc_create')
          .invokeDirect(const {});
      expect(okOf(result), isFalse);
      expect(result.message, contains('not wired'));
    });
  });

  testWidgets(
    'agent_doc_bind: binds workspace + check override DIRECTLY onto the '
    'doc payload (never a form fill) and refreshes the daemon config',
    (final tester) async {
      // ONE mover instance: the harness invokes handlerFactory PER TURN,
      // so per-turn state (the single scripted write) must live on a
      // shared object, not on a fresh mover.
      final mover = GuidedFixMover(
        'main.dart',
        "void main() { print('ok'); }\n",
      );
      final controller = HarnessSessionController(
        config: HarnessHostConfig(handlerFactory: (_) => mover),
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
      expect(
        docUpdates,
        isEmpty,
        reason: 'an unbound doc persists nothing until the bind intent runs',
      );

      final result = await _entry('agent_doc_bind')
          .invokeDirect({
            'workspace': workspace.path,
            'check': 'dart run main.dart',
          });
      expect(okOf(result), isTrue, reason: result.message);
      await tester.pump();

      // The binding is DOC DATA (syncable payload), persisted via
      // onDocChanged — not a field fill.
      expect(docUpdates, isNotEmpty);
      final persisted = docUpdates.last.agent!;
      expect(persisted.workspaces, contains(workspace.path));
      expect(persisted.checkCommand, [
        'dart',
        'run',
        'main.dart',
      ], reason: 'the override persists as literal argv (no shell)');

      // The human UI reflects the same typed state: the empty-state guide
      // closes and the agent projection carries the workspace.
      expect(
        find.byKey(const Key('coding_agent.empty_state')),
        findsNothing,
        reason: 'a bound workspace closes the honest guide',
      );
      expect(AgentDocSurface.debugState!.workspaces, contains(workspace.path));

      // The check override reaches the DAEMON config before the next turn
      // (the Phase-1.5 gap: field fills never did).
      await pumpUntil(
        tester,
        () => controller.config.checkCommand?.join(' ') ==
              'dart run main.dart',
      );

      // Absolute paths only — a relative path is refused honestly.
      final bad = await _entry('agent_doc_bind')
          .invokeDirect({'workspace': 'relative/path'});
      expect(okOf(bad), isFalse);
      expect(bad.message, contains('absolute'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'agent_task_guide: FAIL turn → guidance as first-class grid state → '
    'continuation turn PASSes (monotonic: one guidance per turn)',
    (final tester) async {
      // ONE mover instance: the harness invokes handlerFactory PER TURN,
      // so per-turn state (the single scripted write) must live on a
      // shared object, not on a fresh mover.
      final mover = GuidedFixMover(
        'main.dart',
        "void main() { print('ok'); }\n",
      );
      final controller = HarnessSessionController(
        config: HarnessHostConfig(handlerFactory: (_) => mover),
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

      // Bind via the intent (R9.a — no form fills anywhere in this gate).
      final bind = await _entry('agent_doc_bind')
          .invokeDirect({'workspace': workspace.path});
      expect(okOf(bind), isTrue, reason: bind.message);

      // Turn 1 through the REAL composer keys.
      await tester.enterText(
        find.byKey(const Key('coding_agent.task')),
        'Fix main.dart so `dart run main.dart` exits 0.',
      );
      await tester.tap(find.byKey(const Key('coding_agent.delegate')));
      // Wait for the turn to START (createSession completes slightly after
      // the tap) and only then for it to END — `!isRunning` is trivially
      // true while no session exists yet.
      await pumpUntil(tester, () => controller.isRunning);
      await pumpUntil(tester, () => !controller.isRunning);
      await tester.pump();

      expect(
        controller.current?.verdictPassed,
        isFalse,
        reason: 'turn 1 made no moves — the oracle must FAIL honestly',
      );

      // Guidance through the intent: host-injected, first-class state.
      final guide = await _entry('agent_task_guide')
          .invokeDirect({
            'guidance': 'the file throws in main — replace the throw with a '
                'print and nothing else.',
          });
      expect(okOf(guide), isTrue, reason: guide.message);

      // The continuation turn is delegated immediately; its write asks.
      await pumpUntil(tester, () => controller.pendingPermission != null);
      await tester.pump();
      await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
      await pumpUntil(tester, () => !controller.isRunning);
      await tester.pump();

      // The verdict lands on the grid; the guidance is FIRST-CLASS state
      // on the turn it responds to (GUIDE row under the FAIL turn), never
      // a bare transcript line.
      expect(
        controller.current?.verdictPassed,
        isTrue,
        reason:
            'the guided continuation must PASS '
            '(transcript: ${controller.current?.transcript})',
      );
      final failedTurn = controller.current!.turns[0];
      expect(
        failedTurn.guidance,
        contains('print'),
        reason: 'the guidance must be recorded on the turn it responds to',
      );
      expect(controller.current!.turns[1].taskSentence, startsWith('continue'),
        reason: 'the continuation sentence is the composer pre-fill',
      );
      expect(
        find.byKey(const Key('coding_agent.guidance')),
        findsOneWidget,
        reason: 'the guidance renders as a GUIDE grid row',
      );
      expect(
        AgentDocSurface.debugState!.lastGuidance,
        isNotNull,
        reason: 'the agent projection carries the guidance too',
      );
      expect(
        File('${workspace.path}/main.dart').readAsStringSync(),
        contains("print('ok')"),
        reason: 'the allowed continuation write lands in the workspace',
      );

      // Monotonic: the guard is PER TURN. A new guide after the guided
      // continuation ended is a legitimate NEW escalation (allowed); while
      // that turn runs, guiding again is refused.
      final again = await _entry('agent_task_guide')
          .invokeDirect({'guidance': 'escalate again'});
      expect(okOf(again), isTrue, reason: again.message);
      await pumpUntil(tester, () => controller.isRunning);
      final midContinuation = await _entry('agent_task_guide')
          .invokeDirect({'guidance': 'not while running'});
      expect(okOf(midContinuation), isFalse);
      expect(midContinuation.message, contains('running'));
      await pumpUntil(tester, () => !controller.isRunning);
      await tester.pump();
      expect(
        controller.current!.turns.last.hasVerdict,
        isTrue,
        reason: 'the second escalation completes with a mechanical verdict',
      );
      expect(
        controller.current!.turns.last.permissions,
        isEmpty,
        reason: 'the workspace is already fixed — no write, no gate',
      );
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  testWidgets(
    'agent_task_guide refuses honestly with no session, mid-turn, and '
    'before the last turn ends',
    (final tester) async {
      // ONE mover instance: the harness invokes handlerFactory PER TURN,
      // so per-turn state (the single scripted write) must live on a
      // shared object, not on a fresh mover.
      final mover = GuidedFixMover(
        'main.dart',
        "void main() { print('ok'); }\n",
      );
      final controller = HarnessSessionController(
        config: HarnessHostConfig(handlerFactory: (_) => mover),
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

      final noSession = await _entry('agent_task_guide')
          .invokeDirect({'guidance': 'anything'});
      expect(okOf(noSession), isFalse);
      expect(noSession.message, contains('no session'));

      await _entry('agent_doc_bind')
          .invokeDirect({'workspace': workspace.path});
      await tester.enterText(
        find.byKey(const Key('coding_agent.task')),
        'Fix main.dart so `dart run main.dart` exits 0.',
      );
      await tester.tap(find.byKey(const Key('coding_agent.delegate')));
      await pumpUntil(tester, () => controller.isRunning);

      final midTurn = await _entry('agent_task_guide')
          .invokeDirect({'guidance': 'anything'});
      expect(okOf(midTurn), isFalse);
      expect(midTurn.message, contains('running'));

      await pumpUntil(tester, () => !controller.isRunning);
      await tester.pump();
      expect(controller.current?.verdictPassed, isFalse);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
