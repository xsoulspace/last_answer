// Wave F — the `actor:<id>` info-surface lane, pumped hermetically
// through the REAL shell (the repo's lane: a final-class service is
// never faked). The laws under test:
// - the people view's row tap rides the shell's onFocus wiring into an
//   `actor:<id>` tab (owner law: info in a split, never a face swap);
// - the surface renders the profile facts, the EXISTING editor and the
//   grants section (named absence in a hermetic world);
// - an edit persists through the EXISTING `service.updateActor` verb
//   (the roster get reflects it);
// - a channel-membership row routes back into the shell's
//   conversation grammar (`channel:<id>` in group 0, docked).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/journal/actor_roster.dart';
import 'package:lastanswer/ui_documents/agent_doc_surface.dart';
import 'package:lastanswer/chat/actor_profile_editor.dart';
import 'package:lastanswer/journal/realm_chat_service.dart';
import 'package:lastanswer/journal/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_settings/ui_settings.dart';
import 'package:lastanswer/ui_shell/app_shell.dart';
import 'package:lastanswer/ui_shell/surfaces.dart';
import 'package:lastanswer/ui_workspaces/workspace_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hermetic_world_state.dart';

/// A ready hermetic service: one actor (Toby, rostered with role and
/// persona) and one registered channel listing him — the channel keeps
/// the shell's boot seed a no-op AND gives the people view a
/// conversation whose member rows render.
Future<RealmChatService> _hermeticService(final WidgetTester tester) async {
  late RealmChatService service;
  await tester.runAsync(() async {
    final temp = await Directory.systemTemp.createTemp('la_actor_info_');
    addTearDown(() => temp.delete(recursive: true));
    final world = (await RealmWorld.open(rootOverride: temp.path))!;
    service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    addTearDown(service.dispose);
    await service.ensureReady();
    final toby = (await service.createActor(
      displayName: 'Toby Researcher',
      kind: ActorKind.model,
      brainRef: '',
      role: 'researcher',
      systemPrompt: 'You are Toby, a careful researcher.',
    ))!;
    await service.createChannel(
      'guild',
      memberIds: <String>[toby.actorId],
    );
  });
  return service;
}

Future<void> _pumpShell(
  final WidgetTester tester, {
  required RealmChatService service,
}) async {
  final worldState = hermeticWorldState();
  await worldState.refresh();
  // Split panes need width headroom (the info surface is designed for
  // the 240px column, but three chrome regions share the window here).
  await tester.binding.setSurfaceSize(const Size(1440, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    GlobalStatesProvider(
      builder: (final _) => MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkspaceNotifier>.value(
            value: WorkspaceNotifier(storeLoader: () async => null),
          ),
        ],
        child: MaterialApp(
          // The kit overlay host (same shape as last_answer_app.dart):
          // LaTooltip/LaMenuAnchor/LaSelect below need a Portal ancestor.
          builder: (final context, final child) =>
              Portal(child: child ?? const SizedBox.shrink()),locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: AppShell(
              service: service,
              worldState: worldState,
              child: const CenterTabsArea(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  // flutter_animate's mounted-then-disposed timer law: tick the fake
  // clock once after the mount frame, then settle the boot animations.
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  addTearDown(worldState.dispose);
}

/// Opens the people tab through the strip's `+` picker (the lazy-list
/// scroll materializes rows past the fold).
Future<void> _openPeopleTab(final WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  final target = find.byKey(const ValueKey('newtab.entry.people'));
  final panel = find.byKey(const ValueKey('newtab.page'));
  for (var i = 0; i < 15 && target.evaluate().isEmpty; i++) {
    await tester.drag(panel, const Offset(0, -140), warnIfMissed: false);
    await tester.pump();
  }
  await tester.pump();
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

/// Drains the real IO the grants section / conversation selects start
/// (the settle-then-runAsync law: no live ticker is inside).
Future<void> _drain(final WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump();
}

void main() {
  late Directory devicePin;
  setUp(() {
    // The chat-first projection is the default (docked, no pref).
    SharedPreferences.setMockInitialValues({});
    devicePin = Directory.systemTemp.createTempSync('la_actor_home_');
    RealmWorld.debugDeviceHome = devicePin.path;
  });

  tearDown(() {
    // The shell installs the home face's seams on mount; release them.
    AgentDocSurface.createMeaningExperimentHook = null;
    AgentDocSurface.createAgentProjectHook = null;
    AgentDocSurface.meshWiring = null;
    StorageBackendsNotifier.onSyncCycle = null;
    RealmWorld.debugDeviceHome = null;
    devicePin.deleteSync(recursive: true);
  });

  testWidgets('a people row tap opens the actor:<id> info tab in a '
      'split: facts, editor and grants render', (final tester) async {
    final service = await _hermeticService(tester);
    final actorId = service
        .roster!
        .all
        .firstWhere((final actor) => actor.kind != ActorKind.human)
        .actorId;
    await _pumpShell(tester, service: service);
    await _openPeopleTab(tester);

    // The people view lists the channel's members; the row tap rides
    // the shell's onFocus wiring into the actor's OWN info tab.
    final row = find.byKey(ValueKey('shell.context.person.$actorId'));
    expect(row, findsOneWidget);
    await tester.tap(row);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final surfaceId = actorSurfaceId(actorId);
    expect(find.byKey(ValueKey('view.tab.$surfaceId')), findsOneWidget);
    expect(find.byKey(ValueKey('pane.leaf.$surfaceId')), findsOneWidget);
    expect(find.byKey(const ValueKey('actor.info')), findsOneWidget);

    // The read-only facts block: journal field names, verbatim values.
    expect(find.byKey(const ValueKey('actor.info.facts')), findsOneWidget);
    expect(
      tester.widget<Text>(
        find.byKey(const ValueKey('actor.info.fact.kind')),
      ).data,
      'model',
    );
    expect(
      tester.widget<Text>(
        find.byKey(const ValueKey('actor.info.fact.actorId')),
      ).data,
      actorId,
    );

    // The EXISTING editor renders seeded with the live profile.
    final nameField = find.byKey(const ValueKey(actorEditorNameKey));
    expect(nameField, findsOneWidget);
    expect(
      tester.widget<LaField>(nameField).controller?.text,
      'Toby Researcher',
    );
    expect(
      find.byKey(const ValueKey(actorEditorPersonaKey)),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('actor.info.save')), findsOneWidget);

    // The channel membership computed from service.channels.
    final channelId = service.channels.first.channelId;
    expect(
      find.byKey(ValueKey('actor.info.channel.$channelId')),
      findsOneWidget,
    );

    // The grants section renders the hermetic world's named absence
    // (or rows, once a grant exists) — after its real-IO reload drains.
    expect(
      find.byKey(const ValueKey('shell.people.access')),
      findsOneWidget,
    );
    await _drain(tester);
    final settled =
        find
            .byKey(const ValueKey('shell.people.access.empty'))
            .evaluate()
            .isNotEmpty ||
        find
            .byKey(const ValueKey('shell.people.access.message'))
            .evaluate()
            .isNotEmpty ||
        find
            .byWidgetPredicate(
              (final widget) =>
                  widget.key is ValueKey &&
                  (widget.key! as ValueKey).value
                      .toString()
                      .startsWith('shell.people.access.grant.'),
            )
            .evaluate()
            .isNotEmpty;
    expect(settled, isTrue);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pumpAndSettle();
  });

  testWidgets('an edit persists through updateActor and a membership '
      'row routes to its channel tab', (final tester) async {
    final service = await _hermeticService(tester);
    final actorId = service
        .roster!
        .all
        .firstWhere((final actor) => actor.kind != ActorKind.human)
        .actorId;
    await _pumpShell(tester, service: service);
    // The people row tap rides the shell's registry routing into the
    // actor's info tab (the ONE router places it in the view group).
    await _openPeopleTab(tester);
    await tester.tap(find.byKey(ValueKey('shell.context.person.$actorId')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Edit the name; Save rides the EXISTING service verb.
    await tester.enterText(
      find.byKey(const ValueKey(actorEditorNameKey)),
      'Toby Renamed',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('actor.info.save')));
    await tester.pump();
    // updateActor writes the durable world record — real IO, drained
    // inside the test (an unresolved store future poisons the next).
    await _drain(tester);
    expect(
      service.roster!.get(actorId)!.displayName,
      'Toby Renamed',
    );
    // The tab title is a live projection (never cached): the renamed
    // actor retitles its open tab.
    expect(find.text('Toby Renamed'), findsWidgets);

    // The membership row routes into the conversation grammar: the
    // channel opens in GROUP 0 (docked law — conversations own it).
    final channelId = service.channels.first.channelId;
    await tester.tap(find.byKey(ValueKey('actor.info.channel.$channelId')));
    await tester.pump();
    await _drain(tester);
    expect(
      find.byKey(ValueKey('view.tab.channel:$channelId')),
      findsOneWidget,
    );
    expect(service.activeThreadId, isNotNull);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pumpAndSettle();
  });

  testWidgets('a RETIRED card names the retirement and REVIVES through '
      'the verb (retired visibility, 2026-11-18)', (final tester) async {
    late RealmChatService service;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_actor_ret_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      // The retired durable row seeds BEFORE ensureReady: named by the
      // boot scan, never re-adopted (ADR 0120).
      await world.store.transact(
        (tx) => tx.put('realm_actors', 'toby-researcher', <String, Object?>{
          'actorId': 'toby-researcher',
          'kind': 'realm_actor',
          'displayName': 'Toby Researcher',
          'brainRef': 'local:qwen',
          'retiredAt': '2026-11-04T18:16:08.327830Z',
          'retireReason': 'hygiene-sweep',
        }),
      );
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      // A channel keeps the boot seed a no-op.
      await service.createChannel('guild');
      service.clearActiveThread();
    });
    await _pumpShell(tester, service: service);

    // The Retired section of the people view is the only door to a
    // retired actor: its tap opens the actor:<id> info tab.
    await _openPeopleTab(tester);
    await tester.tap(
      find.byKey(const ValueKey('shell.people.retired.toby-researcher')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byKey(const ValueKey('view.tab.actor:toby-researcher')),
      findsOneWidget,
    );

    // The card NAMES the retirement verbatim and offers the Revive
    // verb; verbs that would lie (message, remove, the editor) stay
    // hidden.
    expect(find.byKey(const ValueKey('actor.info.retired')), findsOneWidget);
    expect(find.byKey(const ValueKey('actor.info.revive')), findsOneWidget);
    expect(find.byKey(const ValueKey('actor.info.remove')), findsNothing);
    expect(find.byKey(const ValueKey('actor.info.save')), findsNothing);

    // The revival: the marks come off, the identity re-adopts, and the
    // SAME surface re-renders live — the editor and the actor-equality
    // verbs return.
    await tester.tap(find.byKey(const ValueKey('actor.info.revive')));
    await tester.pump();
    // reviveActor writes the durable world record — real IO, drained
    // (the updateActor test's law).
    await _drain(tester);
    expect(service.roster!.get('toby-researcher'), isNotNull);
    expect(service.retiredInfo('toby-researcher'), isNull);
    expect(
      find.byKey(const ValueKey('actor.info.retired')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('actor.info.save')), findsOneWidget);
    expect(find.byKey(const ValueKey('actor.info.remove')), findsOneWidget);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pumpAndSettle();
  });
}
