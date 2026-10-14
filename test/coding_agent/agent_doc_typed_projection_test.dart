import 'dart:io';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

class _ProseVerdict implements GenerationHandler {
  @override
  Future<ActorGenerateResponse> generate(
    World world,
    ActorGenerateRequest request,
  ) async => ActorGenerateResponse(
    actorEntity: request.actorEntity,
    taskId: request.taskId,
    structuredOutput: const {'text': 'verdict: PASS is ordinary prose'},
    rawOutput: 'verdict: PASS is ordinary prose',
  );
}

void main() {
  test('settlement replaces provisional discussion without duplication', () {
    final turn = HarnessTurn('Question', DateTime.utc(2026));
    CodingTextUpdate update(CodingTextPhase phase, String text, int sequence) =>
        CodingTextUpdate(
          eventId: 'decision:$sequence',
          requestId: 'decision',
          sequence: sequence,
          occurredAt: DateTime.utc(2026),
          context: const CodingEventContext(taskId: 'task'),
          phase: phase,
          text: text,
        );
    turn.observeText(update(CodingTextPhase.delta, 'Provisional ', 0));
    turn.observeText(update(CodingTextPhase.delta, 'answer', 1));
    expect(turn.displayedText, 'Provisional answer');
    expect(turn.text.toString(), isEmpty);
    turn.observeText(
      update(CodingTextPhase.settled, 'Corrected final answer', 2),
    );
    expect(turn.displayedText.trim(), 'Corrected final answer');
    expect(turn.text.toString().trim(), 'Corrected final answer');
    turn.observeText(
      update(CodingTextPhase.settled, 'Corrected final answer', 2),
    );
    expect(turn.displayedText.trim(), 'Corrected final answer');
  });

  test('model verdict prose cannot assert a host result', () async {
    final root = await Directory.systemTemp.createTemp('prose_verdict_');
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) => _ProseVerdict(),
        extraToolsWithContext: (_) => const [],
      ),
    );
    addTearDown(() async {
      await controller.host.stop();
      controller.dispose();
      await root.delete(recursive: true);
    });
    await controller.openNewSession(root.path);
    await controller.delegate('[read-only] State the quoted sentence.');
    final turn = controller.current!.turns.single;
    expect(turn.verdictLine, 'verdict: COMPLETE');
    expect(turn.verdictPassed, isFalse);
    expect(turn.completedUnverified, isTrue);
    expect(turn.text.toString().trim(), 'verdict: PASS is ordinary prose');
    expect(turn.spend, isNotNull);
  });

  testWidgets('bracket prose stays text and tool activity remains typed', (
    tester,
  ) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(extraToolsWithContext: (_) => const []),
    );
    addTearDown(controller.dispose);
    final view = HarnessSessionView(id: 'projection', cwd: '');
    final turn = HarnessTurn('Read this reference', DateTime.utc(2026));
    turn.text.write(
      '[reference](https://example.com)\n[1, 2, 3]\nverdict: PASS is prose\ndelegated: is prose',
    );
    turn.toolCalls.add(TurnToolCall('read source', DateTime.utc(2026)));
    view.turns.add(turn);
    controller.current = view;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(
            doc: ProjectModel.emptyAgent() as ProjectModelDoc,
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pump();
    controller.selectSession(view);
    await tester.pump();
    expect(
      find.text(
        '[reference](https://example.com)\n[1, 2, 3]\nverdict: PASS is prose\ndelegated: is prose',
      ),
      findsOneWidget,
    );
    expect(find.text('tool'), findsOneWidget);
    final state = AgentDocSurface.debugSurface!;
    expect(state.state.beats.map((beat) => beat.detail), ['read source']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('provisional rendering leaves document checkpoints untouched', (
    tester,
  ) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(extraToolsWithContext: (_) => const []),
    );
    addTearDown(controller.dispose);
    final view = HarnessSessionView(id: 'projection', cwd: '');
    final turn = HarnessTurn('A streamed result', DateTime.utc(2026));
    view.turns.add(turn);
    var writes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(
            doc: ProjectModel.emptyAgent() as ProjectModelDoc,
            controller: controller,
            onDocChanged: (_) => writes++,
          ),
        ),
      ),
    );
    await tester.pump();
    controller.selectSession(view);
    await tester.pump();
    final before = writes;
    for (var i = 0; i < 500; i++) {
      turn.text.write('.');
      controller.selectSession(view);
    }
    await tester.pump();
    expect(writes, before);
    expect(find.text('.' * 500), findsOneWidget);
    controller.enqueueSteer('Keep this pending decision');
    await tester.pump();
    expect(writes, before + 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long history constructs visible turns on demand', (
    tester,
  ) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(extraToolsWithContext: (_) => const []),
    );
    addTearDown(controller.dispose);
    final view = HarnessSessionView(id: 'projection', cwd: '');
    for (var i = 0; i < 500; i++) {
      view.turns.add(
        HarnessTurn('Turn $i', DateTime.utc(2026).add(Duration(seconds: i)))
          ..text.write('Result $i'),
      );
    }
    controller.current = view;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(
            doc: ProjectModel.emptyAgent() as ProjectModelDoc,
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pump();
    controller.selectSession(view);
    await tester.pump();
    expect(find.text('Turn 499'), findsOneWidget);
    expect(find.text('Turn 0'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
