// ADR 0009 — Gate 1, the two-surface gate (widget-driven on REAL keys,
// DESIGN §8): TWO agent docs open at once on scripted controllers
// (LLM-free), and every doc verb resolves its target through the session
// REGISTRY (D1/D2) — never a widget static:
//
// - explicit docId → THAT doc's state / delegation (the raw doc id and
//   the exact registry key agent-<docId> both resolve);
// - absent docId → the FOCUSED doc (device-local last interaction);
// - two live docs with NO focus → refused with an error that NAMES the
//   live sessions (never a silent wrong-target answer, DESIGN §6);
// - a STALE teardown (an old state's dispose after the slot was
//   re-registered) never clobbers the live handle — the identical guard;
// - the registry snapshot is HONEST (DESIGN §6): the host truth rides
//   the verb output without fabricating spend/context.
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

AgentCallEntry _entry(final String name) =>
    agentMcpEntries().firstWhere((final e) => e.name == name);

/// The legacy mcpToolkitTool bridge wraps every MCPCallResult as
/// AgentResult.success — the REAL ok flag is carried in data.
bool okOf(final AgentResult result) => result.data['ok'] == true;

ProjectModelDoc _agentDoc() => ProjectModel.emptyAgent() as ProjectModelDoc;

/// The two-surface gate fixture: two docs, two scripted controllers,
/// both surfaces PRESENT in the registry under their deterministic mesh
/// replica ids.
final class _Gate {
  _Gate(this.docA, this.docB, this.controllerA, this.controllerB);

  final ProjectModelDoc docA;
  final ProjectModelDoc docB;
  final HarnessSessionController controllerA;
  final HarnessSessionController controllerB;

  String get keyA => 'agent-${docA.id.value}';
  String get keyB => 'agent-${docB.id.value}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory workspaceA;
  late Directory workspaceB;
  const fixTask = 'Fix main.dart so `dart run main.dart` exits 0.';

  setUp(() async {
    workspaceA = await Directory.systemTemp.createTemp('lastanswer_gate_a');
    workspaceB = await Directory.systemTemp.createTemp('lastanswer_gate_b');
    for (final workspace in [workspaceA, workspaceB]) {
      File('${workspace.path}/main.dart').writeAsStringSync(
        "void main() { throw StateError('not implemented'); }\n",
      );
    }
    // The registry is a process-wide singleton: start every test clean
    // (the identical guard means a defensive sweep cannot clobber a live
    // widget — none exists between tests).
    final registry = HarnessSessionRegistry.instance;
    for (final entry in registry.sessions.entries.toList()) {
      registry.unregister(entry.key, entry.value);
    }
    AgentDocSurface.debugState = null;
    AgentDocSurface.debugSurface = null;
    AgentDocSurface.shadowDoc = null;
  });

  tearDown(() {
    for (final workspace in [workspaceA, workspaceB]) {
      try {
        workspace.deleteSync(recursive: true);
      } on Object {
        // best effort
      }
    }
  });

  /// Opens TWO agent-doc surfaces at once (the desktop split-view shape)
  /// and asserts both are PRESENT in the registry.
  Future<_Gate> pumpTwoSurfaces(final WidgetTester tester) async {
    HarnessSessionController controller(
          final Directory workspace,
        ) => HarnessSessionController(
          config: HarnessHostConfig(
            handlerFactory: (_) => ScriptedWriteMover(
              'main.dart',
              "void main() { print('ok'); }\n",
            ),
          ),
        );
    final controllerA = controller(workspaceA);
    final controllerB = controller(workspaceB);
    addTearDown(controllerA.dispose);
    addTearDown(controllerB.dispose);
    final docA = _agentDoc();
    final docB = _agentDoc();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: AgentDocSurface(
                  key: const ValueKey('surface-a'),
                  doc: docA,
                  controller: controllerA,
                ),
              ),
              Expanded(
                child: AgentDocSurface(
                  key: const ValueKey('surface-b'),
                  doc: docB,
                  controller: controllerB,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final registry = HarnessSessionRegistry.instance;
    final gate = _Gate(docA, docB, controllerA, controllerB);
    expect(
      registry.sessions.keys,
      containsAll([gate.keyA, gate.keyB]),
      reason: 'both surfaces register presence under their mesh replica '
          'ids (ADR 0009 D1)',
    );
    return gate;
  }

  testWidgets(
    "explicit docId returns THAT doc's state (the raw doc id and the "
    'exact registry key both resolve), and the registry truth rides the '
    'output honestly',
    (final tester) async {
      final gate = await pumpTwoSurfaces(tester);

      // The exact registry key resolves A.
      final stateA = await _entry(
        'agent_doc_state',
      ).invokeDirect({'docId': gate.keyA});
      expect(okOf(stateA), isTrue, reason: stateA.message);
      expect(stateA.data['docId'], gate.docA.id.value);
      expect(stateA.data['registryKey'], gate.keyA);
      // Today's JSON shape is kept (the queue rides along, ADR 0011).
      expect(stateA.data.keys, containsAll(['workspaces', 'backend', 'queue']));

      // The exact registry key resolves B — not A's projection.
      final stateB = await _entry(
        'agent_doc_state',
      ).invokeDirect({'docId': gate.keyB});
      expect(okOf(stateB), isTrue, reason: stateB.message);
      expect(stateB.data['docId'], gate.docB.id.value);
      expect(stateB.data['registryKey'], gate.keyB);

      // The raw doc id is the alias the other mesh verbs carry.
      final raw = await _entry(
        'agent_doc_state',
      ).invokeDirect({'docId': gate.docA.id.value});
      expect(okOf(raw), isTrue, reason: raw.message);
      expect(raw.data['registryKey'], gate.keyA);

      // The registry snapshot is HONEST (DESIGN §6): a surface with no
      // daemon session yet carries an empty session id, zero turns, and
      // NEVER a fabricated spend or context cut.
      final session = stateA.data['session']! as Map<Object?, Object?>;
      expect(session['kind'], 'surface');
      expect(session['running'], isFalse);
      expect(session['sessionId'], '');
      expect(session['turnCount'], 0);
      expect(session['spend'], isNull);
      expect(session['contextSummary'], '');
    },
  );

  testWidgets(
    'no docId resolves the FOCUSED doc (device-local last interaction); '
    'two live docs with no focus are refused with the live sessions '
    'named; the explicit selector still works under the same ambiguity',
    (final tester) async {
      final gate = await pumpTwoSurfaces(tester);
      final registry = HarnessSessionRegistry.instance;

      // An interaction with B pins the focus (the refusal is honest — B
      // binds no workspace yet — but the host-injected decision targeted
      // B, so the marker moved).
      final warmB = await _entry(
        'agent_task_delegate',
      ).invokeDirect({'docId': gate.keyB, 'task': fixTask});
      expect(okOf(warmB), isFalse, reason: warmB.message);
      expect(warmB.message, contains('no workspace bound'));
      expect(registry.focused, gate.keyB);

      final focusedState = await _entry(
        'agent_doc_state',
      ).invokeDirect(const {});
      expect(okOf(focusedState), isTrue, reason: focusedState.message);
      expect(focusedState.data['docId'], gate.docB.id.value);

      // An interaction with A moves the focus; the no-target verb
      // follows.
      final warmA = await _entry(
        'agent_task_delegate',
      ).invokeDirect({'docId': gate.keyA, 'task': fixTask});
      expect(okOf(warmA), isFalse, reason: warmA.message);
      expect(registry.focused, gate.keyA);
      final nowAState = await _entry(
        'agent_doc_state',
      ).invokeDirect(const {});
      expect(nowAState.data['docId'], gate.docA.id.value);

      // The undecided state — two live docs, no focus — is refused with
      // an error that NAMES the live sessions (never a silent
      // wrong-target answer). Re-registering a live id REPLACES the slot
      // without moving focus (presence, not authority — ADR 0007 §3), so
      // the replacement below clears the marker while both docs stay
      // live.
      final handleA = registry.sessions[gate.keyA]!;
      expect(registry.unregister(gate.keyA, handleA), same(handleA));
      registry.register(gate.keyA, handleA);
      expect(registry.focused, isNull);

      final ambiguous = await _entry(
        'agent_doc_state',
      ).invokeDirect(const {});
      expect(okOf(ambiguous), isFalse, reason: ambiguous.message);
      expect(ambiguous.message, contains(gate.keyA));
      expect(ambiguous.message, contains(gate.keyB));
      expect(
        (ambiguous.data['liveSessions']! as List).cast<Object?>(),
        containsAll([gate.keyA, gate.keyB]),
      );

      // The explicit selector still resolves under the same ambiguity.
      final explicit = await _entry(
        'agent_doc_state',
      ).invokeDirect({'docId': gate.keyB});
      expect(okOf(explicit), isTrue, reason: explicit.message);
      expect(explicit.data['docId'], gate.docB.id.value);
    },
  );

  testWidgets(
    'delegate with docId routes to the RIGHT surface; the no-docId '
    'delegate resolves the FOCUSED one; the registry snapshot names the '
    'live daemon session',
    (final tester) async {
      final gate = await pumpTwoSurfaces(tester);
      final registry = HarnessSessionRegistry.instance;

      // Delegates via the verb and waits for the turn's write gate to
      // surface (the scripted mover writes once per turn — every turn
      // asks).
      Future<void> delegateAndGate(
        final Map<String, String> parameters,
        final HarnessSessionController controller,
      ) async {
        final result = await _entry(
          'agent_task_delegate',
        ).invokeDirect(parameters);
        expect(okOf(result), isTrue, reason: result.message);
        await pumpUntil(tester, () => controller.isRunning);
        await pumpUntil(tester, () => controller.pendingPermission != null);
      }

      // Stops the running turn deny-first and drains the round-trip (the
      // request's 5-minute deadline timer must never outlive the test).
      Future<void> stopTurn(final HarnessSessionController controller) async {
        controller.cancelCurrent();
        await pumpUntil(tester, () => !controller.isRunning);
        await pumpUntil(tester, () => controller.pendingPermission == null);
      }

      // Bind both docs through the REAL setup keys (A renders first).
      await tester.enterText(
        find.byKey(const Key('coding_agent.workspace')).first,
        workspaceA.path,
      );
      await tester.enterText(
        find.byKey(const Key('coding_agent.workspace')).last,
        workspaceB.path,
      );
      await tester.pump();

      // Explicit docId → THAT surface's controller runs the turn; the
      // other doc stays untouched.
      await delegateAndGate(
        {'docId': gate.keyA, 'task': fixTask},
        gate.controllerA,
      );
      expect(
        gate.controllerB.isRunning,
        isFalse,
        reason: 'the explicit docId must not delegate the other doc',
      );
      expect(gate.controllerB.current, isNull);
      expect(gate.controllerA.current?.turns.last.taskSentence, fixTask);
      await stopTurn(gate.controllerA);

      // Pin the deterministic focus on B (an explicit interaction), then
      // the no-docId delegate resolves the FOCUSED doc — B, not A.
      await delegateAndGate(
        {'docId': gate.keyB, 'task': fixTask},
        gate.controllerB,
      );
      expect(
        registry.focused,
        gate.keyB,
        reason: 'the host-injected decision interacted with B — the '
            'device-local focus follows the last interaction',
      );
      await stopTurn(gate.controllerB);

      // The no-docId delegate resolves the FOCUSED doc — B (never a
      // silent wrong-target answer, DESIGN §6).
      await delegateAndGate({'task': fixTask}, gate.controllerB);
      expect(gate.controllerB.current?.turns.last.taskSentence, fixTask);
      expect(
        gate.controllerA.isRunning,
        isFalse,
        reason: 'the no-docId delegate resolved the focused doc, not the '
            'other one',
      );
      expect(
        gate.controllerA.current?.turns,
        hasLength(1),
        reason: 'A ran exactly the explicit-docId turn',
      );

      // The registry truth MID-TURN: the snapshot names B's LIVE daemon
      // session and the running flag — read through the REGISTRY, never
      // a static.
      final duringB = await _entry(
        'agent_doc_state',
      ).invokeDirect({'docId': gate.keyB});
      expect(okOf(duringB), isTrue, reason: duringB.message);
      final session = duringB.data['session']! as Map<Object?, Object?>;
      expect(session['running'], isTrue);
      expect(session['sessionId'], gate.controllerB.current?.id);
      await stopTurn(gate.controllerB);
    },
  );

  testWidgets(
    'agent_permission_answer with docId resolves THAT doc; an unknown '
    'docId is refused with the live sessions named',
    (final tester) async {
      final gate = await pumpTwoSurfaces(tester);

      // No pending round-trip on A — the refusal is honest AND the
      // interaction marks the doc focused (the verb contract is the same
      // intent seam as before).
      final answeredA = await _entry(
        'agent_permission_answer',
      ).invokeDirect({'docId': gate.keyA, 'allow': 'true'});
      expect(okOf(answeredA), isFalse, reason: answeredA.message);
      expect(answeredA.message, contains('no pending permission request.'));
      expect(
        HarnessSessionRegistry.instance.focused,
        gate.keyA,
        reason: 'the answered interaction marks the doc focused',
      );

      // An unknown docId never silently answers another doc: the error
      // names the live sessions.
      final unknown = await _entry(
        'agent_permission_answer',
      ).invokeDirect({'docId': 'agent-unknown-doc', 'allow': 'true'});
      expect(okOf(unknown), isFalse, reason: unknown.message);
      expect(unknown.message, contains('agent-unknown-doc'));
      expect(unknown.message, contains(gate.keyA));
      expect(unknown.message, contains(gate.keyB));
    },
  );

  testWidgets(
    'a STALE teardown never clobbers: re-opening the same doc replaces '
    "the slot and the old state's dispose is a no-op; disposing A after "
    'B is registered leaves B resolvable',
    (final tester) async {
      final gate = await pumpTwoSurfaces(tester);
      final registry = HarnessSessionRegistry.instance;
      final liveBefore = registry.sessions[gate.keyA];
      expect(liveBefore, isNotNull);

      // Re-open the SAME doc A as a NEW state: a fresh registration
      // REPLACES the slot (the same shape the widget statics had, now
      // keyed and guarded). The old state's dispose lands AFTER the new
      // registration (frame finalization) — the stale teardown the
      // identical guard must absorb.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: AgentDocSurface(
                    // A DIFFERENT key → a new State (initState registers
                    // the fresh handle).
                    key: const ValueKey('surface-a2'),
                    doc: gate.docA,
                    controller: gate.controllerA,
                  ),
                ),
                Expanded(
                  child: AgentDocSurface(
                    key: const ValueKey('surface-b'),
                    doc: gate.docB,
                    controller: gate.controllerB,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final liveAfter = registry.sessions[gate.keyA];
      expect(
        liveAfter,
        isNotNull,
        reason: 'the stale teardown must NOT clobber the live '
            'registration',
      );
      expect(
        liveAfter,
        isNot(same(liveBefore)),
        reason: 'the fresh registration replaced the slot',
      );

      // The resolved handle is the LIVE surface: the verb resolves and
      // projects A through the registry.
      final stateA = await _entry(
        'agent_doc_state',
      ).invokeDirect({'docId': gate.keyA});
      expect(okOf(stateA), isTrue, reason: stateA.message);
      expect(stateA.data['docId'], gate.docA.id.value);
      expect(stateA.data['registryKey'], gate.keyA);

      // Disposing A (the tree drops to B only) unregisters A; B —
      // registered long before A's dispose — still resolves.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentDocSurface(
              key: const ValueKey('surface-b'),
              doc: gate.docB,
              controller: gate.controllerB,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(registry.sessions.keys, isNot(contains(gate.keyA)));
      expect(registry.sessions.keys, contains(gate.keyB));
      final stateB = await _entry(
        'agent_doc_state',
      ).invokeDirect({'docId': gate.keyB});
      expect(okOf(stateB), isTrue, reason: stateB.message);
      expect(stateB.data['docId'], gate.docB.id.value);
    },
  );
}
