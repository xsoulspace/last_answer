// ADR 0007 — widget gate: the PROFILE pane's ACTORS section on the grid.
//
// Everything through the REAL widget keys (DESIGN §8 — the keys ARE the
// agent's UI contract): add/remove actors in flow, the §7 empty state
// that instructs and vanishes on action, session rows listing their
// actors through the roster, and the agent projection (debugState)
// reading the same roster.

import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

ProjectModelDoc _agentDoc() => ProjectModel.emptyAgent() as ProjectModelDoc;

/// A taller logical surface: the PROFILE pane is one scrollable grid, and
/// every ACTORS row under test must be on it at once (the pane builds
/// lazily — off-viewport rows are not mounted, so taps and finds would
/// silently miss them).
Future<void> _pumpSurface(
  final WidgetTester tester,
  final HarnessSessionController controller,
) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AgentDocSurface(doc: _agentDoc(), controller: controller),
      ),
    ),
  );
  await tester.pump();
}

/// Taps on the pane's grid after scrolling the row into view.
Future<void> _tapOnGrid(
  final WidgetTester tester,
  final Finder finder,
) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('lastanswer_actors');
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

  testWidgets('ACTORS: the empty state instructs quietly and vanishes on '
      'action (§7); add/remove run in flow on the grid', (final tester) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) =>
            ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
      ),
    );
    addTearDown(controller.dispose);
    await _pumpSurface(tester, controller);

    // Open PROFILE — the one simple place (§4).
    await tester.tap(find.byKey(const Key('coding_agent.profile.toggle')));
    await tester.pump();

    // Empty state instructs: numbered, quiet, on the grid.
    expect(find.text('no actors yet. two steps:'), findsOneWidget);
    expect(find.textContaining('1. add an actor'), findsOneWidget);
    expect(find.textContaining('2. actors recur'), findsOneWidget);

    // Action opens the in-flow form — the instruction vanishes (§7).
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.add')),
    );
    expect(find.text('no actors yet. two steps:'), findsNothing);

    // A model+role actor, filled on the grid.
    await tester.enterText(
      find.byKey(const Key('coding_agent.actors.name')),
      'afm coder',
    );
    await tester.enterText(
      find.byKey(const Key('coding_agent.actors.brain')),
      'afm-3',
    );
    await tester.enterText(
      find.byKey(const Key('coding_agent.actors.role')),
      'coder',
    );
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.confirm')),
    );

    // The entry is a small multiple: gutter-vocabulary name + kind ·
    // brain · role. No cards, no chips.
    expect(find.byKey(const Key('coding_agent.actors.afm-coder')),
        findsOneWidget);
    expect(find.text('AFM-CODER'), findsOneWidget);
    expect(find.text('model · afm-3 · coder'), findsOneWidget);
    expect(find.byKey(const Key('coding_agent.actors.afm-coder.remove')),
        findsOneWidget);
    expect(controller.roster.contains('afm-coder'), isTrue);

    // A second actor — a human, switched in flow via the kind toggles.
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.add')),
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('coding_agent.actors.name')),
      'anton',
    );
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.kind.human')),
    );
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.confirm')),
    );
    expect(find.text('ANTON'), findsOneWidget);
    expect(find.text('human'), findsOneWidget);

    // An empty name commits nothing — validation in the action path.
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.add')),
    );
    await tester.pump();
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.confirm')),
    );
    expect(controller.roster.length, 2);
    expect(find.byKey(const Key('coding_agent.actors.confirm')),
        findsOneWidget, reason: 'the form stays open for the correction');
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.cancel')),
    );

    // Remove in flow — one tap, entry gone, roster empty.
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.afm-coder.remove')),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('coding_agent.actors.afm-coder')),
      findsNothing,
    );
    expect(controller.roster.contains('afm-coder'), isFalse);
    await _tapOnGrid(
      tester,
      find.byKey(const Key('coding_agent.actors.anton.remove')),
    );
    await tester.pump();
    expect(controller.roster.isEmpty, isTrue);
    expect(find.text('no actors yet. two steps:'), findsOneWidget,
        reason: 'the empty state returns when the roster empties');
  });

  testWidgets('session rows list their actors (ADR 0006 Actors[] → '
      'roster-backed) and the agent projection reads the same roster',
      (final tester) async {
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) =>
            ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
      ),
    );
    addTearDown(controller.dispose);
    await _pumpSurface(tester, controller);

    // A roster actor + a session projection on the registry.
    controller.roster.upsert(
      const ActorProfile(
        actorId: 'afm-coder',
        displayName: 'afm coder',
        brainRef: 'afm-3',
        role: 'coder',
      ),
    );
    unawaited(controller.createSession(workspace.path));
    await pumpUntil(tester, () => controller.sessions.isNotEmpty);
    await tester.pump();

    final session = controller.sessions.first;
    controller.attachActor(session, 'afm-coder');
    await tester.pump();

    // Open PROFILE — the workspace-grouped grid is otherwise untouched.
    await tester.tap(find.byKey(const Key('coding_agent.profile.toggle')));
    await tester.pump();

    final actorsLine = find.byKey(
      Key('coding_agent.session.${session.viewId}.actors'),
    );
    expect(actorsLine, findsOneWidget);
    final line = tester.widget<Padding>(actorsLine).child! as Text;
    expect(line.data, contains('AFM-CODER'),
        reason: 'the gutter-vocabulary name renders on the session row');

    // One state, many projections (§5): the agent reads the same roster
    // and registry the pane renders.
    expect(AgentDocSurface.debugState, isNotNull);
    expect(
      AgentDocSurface.debugState!.actors.map((final a) => a.actorId),
      contains('afm-coder'),
    );
    expect(
      AgentDocSurface.debugState!.sessionActors['${session.viewId}'],
      ['afm-coder'],
    );
    final actorsJson = AgentDocSurface.debugState!.toJson()['actors'];
    expect(actorsJson, isA<List<Object?>>());
    expect((actorsJson! as List<Object?>).single,
        containsPair('actorId', 'afm-coder'));
  });
}
