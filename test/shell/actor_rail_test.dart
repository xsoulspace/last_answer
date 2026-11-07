// ADR 0024 — the actor rail tests: the rail is THE conversation list
// (Discord model). The selection rule (a row's fill follows the
// service's open thread) is a pure mapping, tested directly; the
// widget-level chrome is tested against a REAL service whose world
// start fails honestly in the test binding — same lane as
// app_shell_test.dart (no realm store journal writes). The WORKSPACES
// section (ADR 0026) rides a hermetic plain-directory store: seeded
// records, never the device's world.
import 'package:flutter/gestures.dart' show kMiddleMouseButton;

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/la_world/la_world_components.dart';
import 'package:lastanswer/shell/actor_rail.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';
import 'package:lastanswer/workspaces/workspace_registry.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// A workspace notifier wired to a hermetic plain-directory store —
/// the world store never opens in a widget test.
WorkspaceNotifier _hermeticWorkspaces(final Directory home) =>
    WorkspaceNotifier(
      storeLoader: () async => RealmControlStore(home),
    );

void main() {
  test(
    'rail selection rule: the fill follows activeThreadId, a row with '
    'no DM thread is never selected',
    () {
      expect(
        railRowIsSelected(rowThreadId: 't1', activeThreadId: 't1'),
        isTrue,
      );
      expect(
        railRowIsSelected(rowThreadId: 't1', activeThreadId: 't2'),
        isFalse,
      );
      expect(
        railRowIsSelected(rowThreadId: 't1', activeThreadId: null),
        isFalse,
      );
      // An actor whose DM does not exist yet has no thread to map.
      expect(
        railRowIsSelected(rowThreadId: null, activeThreadId: 't1'),
        isFalse,
      );
    },
  );

  Future<void> pumpRail(
    final WidgetTester tester, {
    required final RealmChatService service,
    required final WorkspaceNotifier workspaces,
    final ValueChanged<String>? onConversationNewTab,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkspaceNotifier>.value(value: workspaces),
        ],
        child: MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: ActorRail(
              service: service,
              onOpenSettings: () {},
              onOpenCommandPalette: () {},
              onConversationNewTab: onConversationNewTab,
            ),
          ),
        ),
      ),
    );
    // Let the service's world start fail for real (no plugin in the
    // test binding) and the workspace load finish on the real event
    // loop, then settle the not-ready animations.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.runAsync(workspaces.ensureLoaded);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
    'the rail renders identities-first chrome with an empty world: '
    'search, add, human identity, no conversation or workspace rows',
    (final tester) async {
      final service = RealmChatService();
      addTearDown(service.dispose);
      final workspaces = WorkspaceNotifier(
        storeLoader: () async => null,
      );
      addTearDown(workspaces.dispose);
      await pumpRail(tester, service: service, workspaces: workspaces);

      expect(find.byKey(const ValueKey('rail.search')), findsOneWidget);
      expect(find.byKey(const ValueKey('rail.add')), findsOneWidget);
      expect(find.byKey(const ValueKey('rail.settings')), findsOneWidget);
      // No world data: no ACTORS/CHANNELS/WORKSPACES rows exist.
      const rowPrefixes = <String>[
        'rail.actor.',
        'rail.channel.',
        'rail.workspace.',
      ];
      for (final prefix in rowPrefixes) {
        expect(
          find.byWidgetPredicate(
            (final widget) =>
                widget.key is ValueKey &&
                (widget.key! as ValueKey).value.toString().startsWith(
                  prefix,
                ),
          ),
          findsNothing,
          reason: 'no rows for $prefix in an empty world',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'selection mapping over the live service: selecting a thread never '
    'highlights a row that is not its thread',
    (final tester) async {
      final service = RealmChatService();
      addTearDown(service.dispose);
      final workspaces = WorkspaceNotifier(
        storeLoader: () async => null,
      );
      addTearDown(workspaces.dispose);
      await pumpRail(tester, service: service, workspaces: workspaces);

      // With no threads the service's dmThreadOf maps every actor row to
      // null: open-thread selection must light no row.
      service.selectThread('some-dm-thread');
      await tester.pump();
      expect(service.activeThreadId, 'some-dm-thread');
      expect(service.dmThreadOf('any-actor'), isNull);
      expect(
        railRowIsSelected(
          rowThreadId: service.dmThreadOf('any-actor'),
          activeThreadId: service.activeThreadId,
        ),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the WORKSPACES section (ADR 0026): roots render, children fold '
    'under their parent, a tap selects and shows the file-tree note',
    (final tester) async {
      final service = RealmChatService();
      addTearDown(service.dispose);
      final tempHome = await tester.runAsync(
        () => Directory.systemTemp.createTemp('la_rail_workspaces_test'),
      );
      if (tempHome == null) {
        fail('runAsync lost the temp directory');
      }
      addTearDown(() {
        if (tempHome.existsSync()) tempHome.deleteSync(recursive: true);
      });
      final registry = WorkspaceRegistry(store: RealmControlStore(tempHome));
      final root = await tester.runAsync(
        () => registry.create(
          name: 'Orbit',
          folderPaths: <String>['/tmp/orbit'],
        ),
      );
      if (root == null) fail('runAsync lost the root workspace');
      final child = await tester.runAsync(
        () => registry.create(
          name: 'Docs',
          parentIds: <String>{root.id},
        ),
      );
      if (child == null) fail('runAsync lost the child workspace');
      final workspaces = _hermeticWorkspaces(tempHome);
      addTearDown(workspaces.dispose);
      await pumpRail(tester, service: service, workspaces: workspaces);

      // The root renders; the child stays folded until expanded.
      expect(
        find.byKey(ValueKey('rail.workspace.${root.id}')),
        findsOneWidget,
      );
      expect(find.text('Orbit'), findsOneWidget);
      expect(
        find.byKey(ValueKey('rail.workspace.${child.id}')),
        findsNothing,
      );

      // Expanding the root reveals the nested child (one hop of the
      // overlap-capable graph).
      await tester.tap(
        find.byKey(ValueKey('rail.workspace.toggle.${root.id}')),
      );
      await tester.pump();
      expect(
        find.byKey(ValueKey('rail.workspace.${child.id}')),
        findsOneWidget,
      );
      expect(find.text('Docs'), findsOneWidget);

      // Selecting a row keeps the selection local and shows the quiet
      // empty-state note where the file tree will land.
      await tester.tap(find.byKey(ValueKey('rail.workspace.${root.id}')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('rail.workspace.empty-tree')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '⌘-click / middle-click on an actor row reports the dm surface id '
    'to the shell WITHOUT selecting it; a plain tap still selects',
    (final tester) async {
      // Hermetic world (the lane above): the gesture test needs a real
      // actor row, and no thread may be created behind the new-tab
      // gesture — only a hermetic store makes that observable.
      late final RealmChatService service;
      late final String actorId;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_rail_newtab_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        actorId = (await service.createActor(
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
          role: 'researcher',
        ))!
            .actorId;
      });
      final reported = <String>[];
      await pumpRail(
        tester,
        service: service,
        workspaces: WorkspaceNotifier(storeLoader: () async => null),
        onConversationNewTab: reported.add,
      );
      final row = find.byKey(ValueKey('rail.actor.$actorId'));
      expect(row, findsOneWidget);

      // ⌘+click: the row reports, nothing is selected or created.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.tap(row);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();
      expect(reported, <String>['dm:$actorId']);
      expect(service.activeThreadId, isNull);
      expect(service.dmThreadOf(actorId), isNull);

      // Middle-click: same report path, still no thread. startGesture
      // IS the down — it carries the button bits onPointerDown sees.
      final center = tester.getCenter(row);
      final gesture = await tester.startGesture(
        center,
        pointer: 7,
        buttons: kMiddleMouseButton,
      );
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(reported, <String>['dm:$actorId', 'dm:$actorId']);
      expect(service.activeThreadId, isNull);

      // The plain tap keeps its old meaning: open-or-create the DM.
      // The tap's openDm lives in the fake-async zone — real store IO
      // completes only when pumps (fake clocks) and runAsync (real
      // event loop) take turns.
      await tester.tap(row);
      await tester.pump();
      await tester.runAsync(() async {
        for (var i = 0; i < 60 && service.activeThreadId == null; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }
      });
      expect(service.activeThreadId, isNotNull);
      expect(service.dmThreadOf(actorId), isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the unread badge (1g): LaWorld feeds the rail row reactively — '
    'the receipt clears it, the selected row never badges',
    (final tester) async {
      late final RealmChatService service;
      late final LaWorld laWorld;
      late final String actorId;
      late final String threadId;
      late final Directory wsHome;
      await tester.runAsync(() async {
        wsHome = await Directory.systemTemp.createTemp('la_rail_badge_ws_');
        final temp = await Directory.systemTemp.createTemp('la_rail_badge_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        final actor = (await service.createActor(
          displayName: 'Badge Bot',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
        actorId = actor.actorId;
        await service.openDm(actorId);
        threadId = service.dmThreadOf(actorId)!;
        // Looking away: the badge law only shows on rows you are not in.
        service.clearActiveThread();
        laWorld = LaWorld(humanActorId: () => service.humanActorId!);
        addTearDown(laWorld.dispose);
        laWorld.putRoom(
          RoomRow(
            threadId: threadId,
            topic: 'Badge Bot',
            lastBeat: 3,
            participants: [service.humanActorId!, actorId],
          ),
        );
        laWorld.commitBatch();
      });

      final workspaces = _hermeticWorkspaces(wsHome);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WorkspaceNotifier>.value(
              value: workspaces,
            ),
            Provider<LaWorld?>.value(value: laWorld),
          ],
          child: MaterialApp(
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(
              body: ActorRail(
                service: service,
                onOpenSettings: () {},
                onOpenCommandPalette: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final badge = find.byKey(ValueKey('rail.unread.$threadId'));
      expect(badge, findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // The receipt clears it reactively (one batch, one rebuild).
      laWorld.putRoomReceipt(threadId, 3);
      laWorld.commitBatch();
      await tester.pump();
      expect(find.text('3'), findsNothing);

      // A new beat re-badges; SELECTING the room suppresses it (you
      // are looking at it — the receipt follows the open).
      laWorld.putRoom(
        RoomRow(
          threadId: threadId,
          topic: 'Badge Bot',
          lastBeat: 4,
          participants: [service.humanActorId!, actorId],
        ),
      );
      laWorld.commitBatch();
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      service.selectThread(threadId);
      await tester.pump();
      expect(
        badge,
        findsNothing,
        reason: 'the selected row never badges',
      );
    },
  );
}
