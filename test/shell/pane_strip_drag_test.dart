// The NATIVE TAB DRAG (the owner's workspace-projection law, VSCode
// muscle memory, the approved mockup): dragging a tab inside its strip
// reorders it (insert BEFORE the hovered pill), dragging it onto
// another strip's trailing zone moves it to that group, and dropping it
// on a pane's dashed edge (`pane.drop.<g>.<side>`) splits it into a NEW
// group at that position. The oracle is the persisted v4 blob (the
// layout's durable truth) plus the rendered strip keys; an in-flight
// drag shows the ghost chip and the hovered target's affordance, and a
// drag released outside any target changes NOTHING — byte-identical.
// The pump is hermetic (the repo's lane): a real service over
// RealmWorld.open(rootOverride:), the mock prefs undock the rooms
// column so the workspace projection is under test.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/settings.dart';
import 'package:lastanswer/shell/app_shell.dart';
import 'package:lastanswer/shell/pane_strip.dart';
import 'package:lastanswer/shell/surfaces.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hermetic_world_state.dart';

/// Builds a ready hermetic service over a fresh temp world (the
/// rooms-column fixture's twin): two actors, a DM, a watchable room and
/// one registered channel — the channel keeps the shell's boot seed a
/// no-op, `clearActiveThread` keeps the sync law from re-opening tabs.
Future<RealmChatService> _hermeticService(final WidgetTester tester) async {
  late RealmChatService service;
  await tester.runAsync(() async {
    final temp = await Directory.systemTemp.createTemp('la_drag_');
    addTearDown(() => temp.delete(recursive: true));
    final world = (await RealmWorld.open(rootOverride: temp.path))!;
    service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    addTearDown(service.dispose);
    await service.ensureReady();
    final scout = (await service.createActor(
      displayName: 'Scout',
      kind: ActorKind.model,
      brainRef: '',
    ))!;
    final ember = (await service.createActor(
      displayName: 'Ember',
      kind: ActorKind.model,
      brainRef: '',
    ))!;
    await service.openDm(scout.actorId);
    await service.startThread(topic: 'Room One', participants: <String>[
      scout.actorId,
      ember.actorId,
    ]);
    await service.createChannel('guild');
    service.clearActiveThread();
  });
  return service;
}

/// The workspace projection on a seeded v4 layout: the rooms column
/// undocked (the projection under test) and the groups persisted.
void _seedWorkspace(final List<List<String>> groups) {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'shell.rooms.docked': false,
    'shell.views.v4': jsonEncode(<String, Object?>{
      'v': 4,
      'groups': <Object?>[
        for (final tabs in groups)
          <String, Object?>{'tabs': tabs, 'active': 0},
      ],
      'active': 0,
    }),
  });
}

Future<void> _pumpShell(
  final WidgetTester tester, {
  required RealmChatService service,
}) async {
  final worldState = hermeticWorldState();
  await worldState.refresh();
  await tester.pumpWidget(
    GlobalStatesProvider(
      builder: (final _) => MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkspaceNotifier>.value(
            value: WorkspaceNotifier(storeLoader: () async => null),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
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
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  addTearDown(worldState.dispose);
}

/// The persisted v4 layout, decoded (the drag law's oracle — the
/// rooms-column helper's twin).
Future<Map<String, Object?>> _persistedV4() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString('shell.views.v4')!)
      as Map<String, Object?>;
}

List<String> _groupTabs(final Map<String, Object?> decoded, final int group) =>
    (((decoded['groups']! as List)[group]! as Map)['tabs'] as List)
        .cast<String>();

void main() {
  late Directory devicePin;
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    devicePin = Directory.systemTemp.createTempSync('la_drag_home_');
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

  group('the native tab drag (the workspace projection)', () {
    testWidgets('dragging a tab onto another tab in its strip inserts it '
        'BEFORE the target (the persisted v4 reorders)', (
      final tester,
    ) async {
      _seedWorkspace(<List<String>>[
        <String>[kBoardsSurfaceId, kPeopleSurfaceId, kConversationsSurfaceId],
      ]);
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);

      final from = tester.getCenter(
        find.byKey(const ValueKey('view.tab.$kPeopleSurfaceId')),
      );
      final to = tester.getCenter(
        find.byKey(const ValueKey('view.tab.$kBoardsSurfaceId')),
      );
      await tester.dragFrom(from, to - from);
      await tester.pump();

      final decoded = await _persistedV4();
      expect(_groupTabs(decoded, 0), <String>[
        kPeopleSurfaceId,
        kBoardsSurfaceId,
        kConversationsSurfaceId,
      ]);
    });

    testWidgets('dragging a tab onto another strip’s trailing zone moves '
        'it to that group (append)', (final tester) async {
      _seedWorkspace(<List<String>>[
        <String>[kBoardsSurfaceId, kPeopleSurfaceId],
        <String>[kConversationsSurfaceId],
      ]);
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);
      expect(find.byType(PaneStrip), findsNWidgets(2));

      final from = tester.getCenter(
        find.byKey(const ValueKey('view.tab.$kPeopleSurfaceId')),
      );
      // The trailing free space of group 1's tab area: right of its one
      // pill (a pill never exceeds 176px), left of its fold control.
      final to =
          tester.getTopRight(
            find.byKey(const ValueKey('strip.drop.1')),
          ) +
          const Offset(-16, 17);
      await tester.dragFrom(from, to - from);
      await tester.pump();

      final decoded = await _persistedV4();
      expect(decoded['groups']! as List, hasLength(2));
      expect(_groupTabs(decoded, 0), <String>[kBoardsSurfaceId]);
      expect(_groupTabs(decoded, 1), <String>[
        kConversationsSurfaceId,
        kPeopleSurfaceId,
      ]);
      expect(decoded['active'], 1, reason: 'the target group takes focus');
    });

    testWidgets('dropping a tab on a pane’s right edge splits it into a '
        'NEW group at that position (two groups become three)', (
      final tester,
    ) async {
      _seedWorkspace(<List<String>>[
        <String>[kBoardsSurfaceId, kPeopleSurfaceId],
        <String>[kConversationsSurfaceId],
      ]);
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);

      final from = tester.getCenter(
        find.byKey(const ValueKey('view.tab.$kPeopleSurfaceId')),
      );
      final to = tester.getCenter(
        find.byKey(const ValueKey('pane.drop.0.right')),
      );
      await tester.dragFrom(from, to - from);
      await tester.pump();

      expect(find.byType(PaneStrip), findsNWidgets(3));
      final decoded = await _persistedV4();
      expect(decoded['groups']! as List, hasLength(3));
      expect(_groupTabs(decoded, 0), <String>[kBoardsSurfaceId]);
      expect(_groupTabs(decoded, 1), <String>[kPeopleSurfaceId]);
      expect(_groupTabs(decoded, 2), <String>[kConversationsSurfaceId]);
      expect(decoded['active'], 1, reason: 'the new pane takes focus');
    });

    testWidgets('an in-flight drag renders the ghost chip and the hovered '
        'target’s affordance; cancelling changes nothing', (
      final tester,
    ) async {
      _seedWorkspace(<List<String>>[
        <String>[kBoardsSurfaceId, kPeopleSurfaceId, kConversationsSurfaceId],
      ]);
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);
      final before = (await SharedPreferences.getInstance()).getString(
        'shell.views.v4',
      );

      final from = tester.getCenter(
        find.byKey(const ValueKey('view.tab.$kPeopleSurfaceId')),
      );
      final over = tester.getCenter(
        find.byKey(const ValueKey('view.tab.$kBoardsSurfaceId')),
      );
      final gesture = await tester.startGesture(from);
      await gesture.moveBy(over - from);
      await tester.pump();

      // The mockup's ghost tab rides the overlay; the hovered pill shows
      // its accent leading edge (the affordance's testable state).
      expect(
        find.byKey(const ValueKey('drag.ghost.$kPeopleSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('drop.hover.$kBoardsSurfaceId')),
        findsOneWidget,
      );

      await gesture.cancel();
      await tester.pump();
      expect(
        find.byKey(const ValueKey('drag.ghost.$kPeopleSurfaceId')),
        findsNothing,
      );
      final after = (await SharedPreferences.getInstance()).getString(
        'shell.views.v4',
      );
      expect(after, before);
    });

    testWidgets('a drag released outside any target leaves the layout '
        'byte-identical', (final tester) async {
      _seedWorkspace(<List<String>>[
        <String>[kBoardsSurfaceId, kPeopleSurfaceId, kConversationsSurfaceId],
      ]);
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);
      final before = (await SharedPreferences.getInstance()).getString(
        'shell.views.v4',
      );

      final from = tester.getCenter(
        find.byKey(const ValueKey('view.tab.$kPeopleSurfaceId')),
      );
      // The pane body below the strip: no drop target lives there.
      final outside =
          tester.getCenter(find.byKey(const ValueKey('view.strip.0'))) +
          const Offset(0, 200);
      await tester.dragFrom(from, outside - from);
      await tester.pump();

      final after = (await SharedPreferences.getInstance()).getString(
        'shell.views.v4',
      );
      expect(after, before);
      expect(_groupTabs(await _persistedV4(), 0), <String>[
        kBoardsSurfaceId,
        kPeopleSurfaceId,
        kConversationsSurfaceId,
      ]);
    });
  });
}
