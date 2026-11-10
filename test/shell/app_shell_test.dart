// ADR 0024 — the app shell widget tests. DESIGN.md v2 anatomy (owner law
// 2026-11-08, cut to the bone 2026-11-10): the rail is the three-button
// action bar [search, actors, gear], tabs are owned by PANE GROUPS
// ([ShellLayout] v4, persisted as `shell.views.v4`; retired v3/v2/v1/
// pane-tree blobs migrate once), the picker is an anchored MENU (never a
// tab), and splits move the active tab into a second pane.
//
// This suite runs the WORKSPACE projection lane (`shell.rooms.docked`
// false — the legacy, byte-identical behavior); the chat-first
// projection (docked rooms column, group-0 routing, the close law) has
// its own suite in rooms_column_test.dart.
//
// The injected RealmChatService is a REAL service. Two lanes:
// - the default lane, whose world start fails honestly in the test
//   binding (path_provider has no plugin) — the shell renders its
//   not-ready states without touching any realm store;
// - a hermetic lane over `RealmWorld.open(rootOverride:)` for the
//   service-driven conversation flow (the picker/palette select through
//   the service; the shell translates that into room tabs).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/board_view.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/settings.dart';
import 'package:lastanswer/shell/app_shell.dart';
import 'package:lastanswer/shell/pane_strip.dart';
import 'package:lastanswer/shell/surfaces.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

import 'hermetic_world_state.dart';

/// A projects notifier fake whose real pager holds zero items — enough
/// for the document surfaces to render honestly empty.
class _IdleProjects extends ValueNotifier<ProjectsNotifierState>
    implements ProjectsNotifier {
  _IdleProjects() : super(const ProjectsNotifierState());

  @override
  final projectsPagedController = ProjectsPagedController(
    requestBuilder: _IdleRequests(),
  );

  @override
  Future<void> dispose() async => super.dispose();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IdleRequests extends ProjectsPagedDataRequestsBuilder {
  _IdleRequests()
    : super(
        onLoadData: (_) async => const PagingControllerPageModel(
          values: <ProjectModel>[],
          currentPage: 1,
          pagesCount: 1,
        ),
      );
}

Future<void> _pumpShell(
  final WidgetTester tester, {
  final RealmChatService? service,
  final WorldStateService? worldState,
}) async {
  final resolved = service ?? RealmChatService();
  // Phase 1d: the shell's world read model is hermetic in tests — the
  // injected service never polls (no pending timers) and probes nothing
  // real.
  final resolvedWorld = worldState ?? hermeticWorldState();
  // Let the service's world start fail for real — BEFORE any widget
  // pumps: path_provider has no plugin in the test binding, so
  // `ensureReady` lands in its named error state without a journal
  // write. The start must run inside runAsync while the service is not
  // yet attached to a tree: a start begun in initState lives in the
  // fake-async zone, and awaiting that same future from the real zone
  // never completes (it advances only on fake pumps). Started here it
  // is fully real-async, so the settled state is deterministic instead
  // of a guessed delay that a cold JIT can outrun. (An injected
  // hermetic service is already ready; the shell's own ensureReady is
  // an idempotent no-op.)
  if (service == null) {
    await tester.runAsync(resolved.ensureReady);
  }
  await tester.pumpWidget(
    // The production DI composition (lazy providers): phase 1e hosts
    // Settings inside a tab, so the harness needs the same graph
    // the app root builds — PrefsDb rides the mocked SharedPreferences.
    GlobalStatesProvider(
      builder: (final _) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ProjectsNotifier>.value(
            value: _IdleProjects(),
          ),
          // ADR 0026 — the workspace registry: the store-less notifier
          // renders the honest empty state (no store I/O).
          ChangeNotifierProvider<WorkspaceNotifier>.value(
            value: WorkspaceNotifier(storeLoader: () async => null),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          // Production wraps the shell in ScreenScaffold's Scaffold; mirror
          // that here so Material ancestors exist.
          home: Scaffold(
            body: AppShell(
              service: resolved,
              worldState: resolvedWorld,
              child: const CenterTabsArea(),
            ),
          ),
        ),
      ),
    ),
  );
  // Flush the initState `ensureReady` no-op (the already-settled start)
  // and let the not-ready progress indicator's animation timers fire.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Opens a picker entry on group 0's `+` (the kind buttons retired —
/// the picker and the palette are the view-opening paths now).
Future<void> _openViaPicker(
  final WidgetTester tester,
  final String entryKey, {
  final bool scroll = false,
}) async {
  await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
  await tester.pump();
  if (scroll) {
    final target = find.byKey(ValueKey(entryKey));
    final panel = find.byKey(const ValueKey('newtab.page'));
    for (var i = 0; i < 15 && target.evaluate().isEmpty; i++) {
      await tester.drag(panel, const Offset(0, -140), warnIfMissed: false);
      await tester.pump();
    }
    await tester.pump();
  }
  await tester.tap(find.byKey(ValueKey(entryKey)));
  await tester.pump();
}

void main() {
  late Directory devicePin;
  setUp(() {
    // The workspace-projection lane: undocked keeps every assertion
    // here on the legacy behavior (the docked projection is covered by
    // rooms_column_test.dart).
    SharedPreferences.setMockInitialValues({'shell.rooms.docked': false});
    // Pin the realm device root so the palette/health walk never reads
    // the real machine's ~/.xsoulspace.
    devicePin = Directory.systemTemp.createTempSync('la_shell_home_');
    RealmWorld.debugDeviceHome = devicePin.path;
  });

  tearDown(() {
    // The shell installs the home face's seams on mount; release them so
    // other suites start clean.
    AgentDocSurface.createMeaningExperimentHook = null;
    AgentDocSurface.createAgentProjectHook = null;
    AgentDocSurface.meshWiring = null;
    StorageBackendsNotifier.onSyncCycle = null;
    RealmWorld.debugDeviceHome = null;
    devicePin.deleteSync(recursive: true);
  });

  testWidgets('launching lands in the shell: the cut bar lists its THREE '
      'buttons and the one pane group hosts the world face with its strip', (
    final tester,
  ) async {
    await _pumpShell(tester);
    // The action bar (cut to the bone): search, the actors dock toggle,
    // the gear — and NO kind buttons (the vocabulary retired).
    expect(find.byKey(const ValueKey('rail.search')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.actors')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.settings')), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (final widget) =>
            widget.key is ValueKey &&
            (widget.key! as ValueKey).value.toString().startsWith('rail.view.'),
      ),
      findsNothing,
    );
    // This lane is undocked: the rooms column stays closed.
    expect(find.byKey(const ValueKey('shell.roomsColumn')), findsNothing);
    // ONE pane group, its strip, its world-face tab focused.
    expect(find.byType(PaneStrip), findsOneWidget);
    expect(find.byKey(const ValueKey('view.strip.0')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('view.tab.conversations')),
      findsOneWidget,
    );
    // The persistent roster column and the dock stay retired.
    expect(
      find.byWidgetPredicate(
        (final widget) =>
            widget.key is ValueKey &&
            (widget.key! as ValueKey).value.toString().startsWith(
              'rail.actor.',
            ),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('view.dock')), findsNothing);
  });

  testWidgets('the actors button docks and undocks the rooms column and '
      'persists the projection choice', (final tester) async {
    await _pumpShell(tester);
    expect(find.byKey(const ValueKey('shell.roomsColumn')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('rail.actors')));
    await tester.pump();
    expect(find.byKey(const ValueKey('shell.roomsColumn')), findsOneWidget);
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('shell.rooms.docked'), isTrue);
    await tester.tap(find.byKey(const ValueKey('rail.actors')));
    await tester.pump();
    expect(find.byKey(const ValueKey('shell.roomsColumn')), findsNothing);
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('shell.rooms.docked'), isFalse);
  });

  testWidgets('the picker opens a view as a TAB and persists v4', (
    final tester,
  ) async {
    await _pumpShell(tester);
    await _openViaPicker(tester, 'newtab.entry.boards');
    // The tab opens in the ONE group — beside the world face, not
    // replacing a hosted "view" (v4: groups own tabs).
    expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('view.tab.conversations')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('view.strip.0')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('shell.views.v4');
    expect(raw, isNotNull);
    final decoded = jsonDecode(raw!) as Map<String, Object?>;
    expect(decoded['v'], 4);
    final groups = decoded['groups']! as List<Object?>;
    expect(groups, hasLength(1));
    expect(
      (groups.first! as Map<String, Object?>)['tabs'],
      contains(kBoardsSurfaceId),
    );
  });

  /// The picker panel is a LAZY list (measured: `cacheExtent` does not
  /// extend the built window on this Flutter): rows past the fold exist
  /// only after scrolling — the same truth for users, agents and tests.
  Future<void> scrollPickerTo(
    final WidgetTester tester,
    final String key,
  ) async {
    final target = find.byKey(ValueKey(key));
    final panel = find.byKey(const ValueKey('newtab.page'));
    for (var i = 0; i < 15 && target.evaluate().isEmpty; i++) {
      await tester.drag(panel, const Offset(0, -140), warnIfMissed: false);
      await tester.pump();
    }
    await tester.pump();
  }

  testWidgets('the strip + opens the picker MENU and a pick opens the tab '
      'in place', (final tester) async {
    await _pumpShell(tester);
    await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
    await tester.pump();
    expect(find.byKey(const ValueKey('newtab.page')), findsOneWidget);
    // The picker enumerates the registry faces near the top, and one
    // pick opens the tab in place and closes the menu.
    expect(find.byKey(const ValueKey('newtab.entry.boards')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('newtab.entry.boards')));
    await tester.pump();
    expect(find.byKey(const ValueKey('newtab.page')), findsNothing);
    expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);

    // Reopened: the runway tail lives below the fold (honest absences
    // in the lazy list — scroll materializes them).
    await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
    await tester.pump();
    await scrollPickerTo(tester, 'newtab.runway.image');
    expect(find.byKey(const ValueKey('newtab.runway.image')), findsOneWidget);
  });

  testWidgets('the picker enumerates the instance row and the runway '
      '(the format registry, honest absences included)', (final tester) async {
    await _pumpShell(tester);
    await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
    await tester.pump();
    // The instance law's UI face: a "new instance" row (the browser is
    // the instanced kind today). The row is asserted, not tapped —
    // tapping mounts the real inappwebview platform surface, which is
    // the browser suite's job (workspace_browser_test injects a fake).
    // The scroll targets the LAST row (the lazy list builds everything
    // above it): the registry's honest tail is complete or absent.
    await scrollPickerTo(tester, 'newtab.runway.audio');
    expect(
      find.byKey(const ValueKey('newtab.instance.browser')),
      findsOneWidget,
    );
    // The creation flows live in the picker (the rail's + menu retired).
    expect(find.byKey(const ValueKey('newtab.create.channel')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('newtab.create.workspace')),
      findsOneWidget,
    );
    // Runway rows render dimmed and inert.
    expect(find.byKey(const ValueKey('newtab.runway.image')), findsOneWidget);
    expect(find.byKey(const ValueKey('newtab.runway.video')), findsOneWidget);
    expect(find.byKey(const ValueKey('newtab.runway.audio')), findsOneWidget);
  });

  testWidgets('strip tabs re-focus their rooms and the rooms survive '
      'navigation (hermetic world lane; the kind cycling retired with '
      'the kind buttons)', (final tester) async {
    late RealmChatService service;
    late ActorProfile first;
    late ActorProfile second;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_shell_cycle_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      first = (await service.createActor(
        displayName: 'Cycle One',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
      second = (await service.createActor(
        displayName: 'Cycle Two',
        kind: ActorKind.model,
        brainRef: '',
      ))!;
    });
    await _pumpShell(tester, service: service);

    // Open both rooms from the picker's rooms section (rooms lead the
    // picker — the door comes first; the lazy-list scroll helper keeps
    // the rows addressable however the roster grows).
    await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await scrollPickerTo(tester, 'newtab.entry.dm:${first.actorId}');
    await tester.tap(find.byKey(ValueKey('newtab.entry.dm:${first.actorId}')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await scrollPickerTo(tester, 'newtab.entry.dm:${second.actorId}');
    await tester.tap(find.byKey(ValueKey('newtab.entry.dm:${second.actorId}')));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(
      find.byKey(ValueKey('pane.leaf.dm:${second.actorId}')),
      findsOneWidget,
    );

    // The strip tabs are the navigation now: a tap focuses its room.
    await tester.tap(find.byKey(ValueKey('view.tab.dm:${first.actorId}')));
    await tester.pump();
    expect(
      find.byKey(ValueKey('pane.leaf.dm:${first.actorId}')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('view.tab.conversations')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('pane.leaf.conversations')),
      findsOneWidget,
    );

    // A view tab opens through the picker and focuses where it lives…
    await _openViaPicker(tester, 'newtab.entry.boards', scroll: true);
    expect(find.byKey(const ValueKey('pane.leaf.boards')), findsOneWidget);
    // …and the rooms survive the navigation (tabs are never destroyed).
    expect(
      find.byKey(ValueKey('view.tab.dm:${first.actorId}')),
      findsOneWidget,
    );

    // Drain the room taps' real IO (openDm) INSIDE the test: an
    // unresolved store future completing after teardown poisons the
    // NEXT test with its notifyListeners cascade.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
  });

  testWidgets('closing the focused tab lands the sole group on the world '
      'face (the front door — a strip never empties)', (final tester) async {
    await _pumpShell(tester);
    await _openViaPicker(tester, 'newtab.entry.boards');
    // The focused tab carries its close glyph.
    await tester.tap(find.byKey(const ValueKey('view.tab.close.boards')));
    await tester.pump();
    expect(find.byKey(const ValueKey('view.tab.boards')), findsNothing);
    expect(
      find.byKey(const ValueKey('view.tab.conversations')),
      findsOneWidget,
    );
  });

  testWidgets('split moves the active tab into a second pane; fold merges '
      'it back (VS Code anatomy)', (final tester) async {
    await _pumpShell(tester);
    await _openViaPicker(tester, 'newtab.entry.boards');
    await tester.tap(find.byKey(const ValueKey('view.group.split.0')));
    await tester.pump();
    // TWO strips now — each group owns its own (the group-scoped law).
    expect(find.byType(PaneStrip), findsNWidgets(2));
    expect(find.byKey(const ValueKey('view.strip.0')), findsOneWidget);
    expect(find.byKey(const ValueKey('view.strip.1')), findsOneWidget);
    // The moved tab lives in pane 2; pane 1 refilled with the world face.
    expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('view.tab.conversations')),
      findsOneWidget,
    );
    // The trailing pane folds back into ONE group.
    await tester.tap(find.byKey(const ValueKey('view.group.fold.1')));
    await tester.pump();
    expect(find.byType(PaneStrip), findsOneWidget);
    expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('view.tab.conversations')),
      findsOneWidget,
    );
  });

  testWidgets('a v3 per-view blob migrates once into ONE pane group', (
    final tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'shell.rooms.docked': false,
      'shell.views.v3': jsonEncode(<String, Object?>{
        'v': 3,
        'activeView': kBoardsSurfaceId,
        'views': <String, Object?>{
          kConversationsSurfaceId: <String, Object?>{
            'tabs': <String>[kConversationsSurfaceId, 'dm:scout'],
            'active': 0,
          },
          kBoardsSurfaceId: <String, Object?>{
            'tabs': <String>[kBoardsSurfaceId],
            'active': 0,
          },
        },
      }),
    });
    await _pumpShell(tester);
    // The active view's strip leads the flatten; both tabs survive.
    expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);
    expect(find.byKey(const ValueKey('view.strip.0')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final decoded =
        jsonDecode(prefs.getString('shell.views.v4')!) as Map<String, Object?>;
    expect(decoded['v'], 4);
    final groups = decoded['groups']! as List<Object?>;
    expect(groups, hasLength(1));
    final tabs = ((groups.first! as Map)['tabs'] as List).cast<String>();
    expect(tabs.first, kBoardsSurfaceId);
    expect(tabs, containsAll(<String>['dm:scout', kConversationsSurfaceId]));
  });

  testWidgets('a v2 blob migrates once into the one group', (
    final tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'shell.rooms.docked': false,
      'shell.views.v2': jsonEncode(<String, Object?>{
        'tabs': <String>[kConversationsSurfaceId, kBoardsSurfaceId],
        'active': 1,
        'pinned': <String>[kPeopleSurfaceId],
        'dockFocus': kPeopleSurfaceId,
      }),
    });
    await _pumpShell(tester);
    // The v2 active tab (boards) keeps focus; the pin became a tab.
    expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);
    expect(find.byKey(const ValueKey('view.tab.people')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final decoded =
        jsonDecode(prefs.getString('shell.views.v4')!) as Map<String, Object?>;
    expect(decoded['v'], 4);
    final groups = decoded['groups']! as List<Object?>;
    expect(groups, hasLength(1));
    expect((groups.first! as Map)['tabs'] as List, contains(kPeopleSurfaceId));
  });

  testWidgets('the service selecting a thread opens its ROOM tab beside the '
      'world face (hermetic world lane)', (final tester) async {
    late RealmWorld world;
    late RealmChatService service;
    late ActorProfile actor;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_shell_v4_');
      addTearDown(() => temp.delete(recursive: true));
      world = (await RealmWorld.open(rootOverride: temp.path))!;
      final roster = ActorRoster(replicaId: 'tester');
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      actor = (await service.createActor(
        displayName: 'Toby Researcher',
        kind: ActorKind.model,
        brainRef: '',
        role: 'researcher',
        systemPrompt: 'You are Toby, a careful researcher.',
      ))!;
    });
    await _pumpShell(tester, service: service);
    await tester.runAsync(() => service.openDm(actor.actorId));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // v4 law: rooms are ordinary tabs — the DM opens as its own tab and
    // the world face KEEPS its tab (v3 replaced it in the one slot).
    expect(
      find.byKey(ValueKey('view.tab.dm:${actor.actorId}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('view.tab.conversations')),
      findsOneWidget,
    );
  });

  group('phase 1d — the status edge + landing inbox + Models surface', () {
    testWidgets('the edge renders the honest world line and the ONE-click '
        'arm refuses by name when the artifact is absent', (
      final tester,
    ) async {
      final world = hermeticWorldState();
      await world.refresh();
      await _pumpShell(tester, worldState: world);

      expect(find.byKey(const ValueKey('shell.statusEdge')), findsOneWidget);
      expect(find.text('world down'), findsOneWidget);
      expect(find.byKey(const ValueKey('edge.arm')), findsOneWidget);
      // A down world still names its other segments honestly.
      expect(find.text('mesh off'), findsOneWidget);
      expect(find.text('attention: 0'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('edge.arm')));
      await tester.pump();
      expect(find.textContaining('arm failed'), findsOneWidget);
      expect(world.armError, 'daemon_artifact_absent');
      addTearDown(world.dispose);
    });

    testWidgets('the backend segment opens the Models surface as a tab of '
        'the active group', (final tester) async {
      final world = hermeticWorldState(daemonLive: true);
      await world.refresh();
      await _pumpShell(tester, worldState: world);

      expect(find.text('world live'), findsOneWidget);
      expect(find.text('no palette declared'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('edge.backend')));
      await tester.pump();
      expect(find.byKey(const ValueKey('view.tab.models')), findsOneWidget);
      expect(find.byKey(const ValueKey('shell.modelsView')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.palette.empty')),
        findsOneWidget,
      );
      addTearDown(world.dispose);
    });

    testWidgets('the attention segment re-focuses the conversations world '
        'face', (final tester) async {
      final world = hermeticWorldState(daemonLive: true);
      await world.refresh();
      await _pumpShell(tester, worldState: world);
      await _openViaPicker(tester, 'newtab.entry.boards');
      expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('edge.attention')));
      await tester.pump();
      // The world face tab is focused again — the boards TAB survives
      // (tabs are never destroyed by navigation).
      expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('view.tab.conversations')),
        findsOneWidget,
      );
      addTearDown(world.dispose);
    });

    testWidgets("the palette's Landing inbox action clears a focused "
        'thread back to the inbox (phase 3 verb)', (final tester) async {
      late RealmChatService service;
      late ActorProfile actor;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_inbox2_');
        addTearDown(() => temp.delete(recursive: true));
        final world = await RealmWorld.open(rootOverride: temp.path);
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        // These two tests assert the EMPTY-world face (the landing
        // inbox); the shell's first-run seed would land a fresh world
        // in #general instead — the policy input turns it off here.
        service.firstRunSeedEnabled = false;
        await service.ensureReady();
        actor = (await service.createActor(
          displayName: 'Inbox Checker',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
        await service.openDm(actor.actorId);
      });
      final worldState = hermeticWorldState(daemonLive: true);
      await worldState.refresh();
      await _pumpShell(tester, service: service, worldState: worldState);
      // A focused thread hosts the chat pane, not the inbox.
      expect(find.byKey(const ValueKey('shell.landingInbox')), findsNothing);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('palette.query')),
        'landing',
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const ValueKey('shell.landingInbox')), findsOneWidget);
      addTearDown(worldState.dispose);
    });

    testWidgets('the conversations void is the landing inbox (hermetic '
        'world lane)', (final tester) async {
      late RealmChatService service;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_inbox_');
        addTearDown(() => temp.delete(recursive: true));
        final world = await RealmWorld.open(rootOverride: temp.path);
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        // The void-face law under test: no seed, no thread, the inbox.
        service.firstRunSeedEnabled = false;
        await service.ensureReady();
      });
      final worldState = hermeticWorldState();
      await worldState.refresh();
      await _pumpShell(tester, service: service, worldState: worldState);

      // No thread open: the void became the inbox — and a down daemon
      // arms from there too (the first-session script's step 1).
      expect(find.byKey(const ValueKey('shell.landingInbox')), findsOneWidget);
      expect(find.byKey(const ValueKey('inbox.arm')), findsOneWidget);
      expect(find.byKey(const ValueKey('inbox.arm.button')), findsOneWidget);
      addTearDown(worldState.dispose);
    });
  });

  testWidgets('phase 1e — the gear opens settings as a tab and its close '
      'button closes the TAB, never the shell', (final tester) async {
    await _pumpShell(tester);
    await tester.tap(find.byKey(const ValueKey('rail.settings')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const ValueKey('view.tab.settings')), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);

    // The embedded seam: the close affordance goes through the view
    // scope (a route pop from inside a view would take the shell down).
    await tester.tap(find.byType(CupertinoCloseButton).first);
    await tester.pump();
    expect(find.byKey(const ValueKey('view.tab.settings')), findsNothing);
    expect(find.byType(SettingsScreen), findsNothing);
    // The shell is still standing: edge, strip and bar all present.
    expect(find.byKey(const ValueKey('shell.statusEdge')), findsOneWidget);
    expect(find.byKey(const ValueKey('view.strip.0')), findsOneWidget);
    expect(find.byKey(const ValueKey('shell.actionBar')), findsOneWidget);
  });

  group('phase 3 — threads, terminal arm, boards mesh settle', () {
    testWidgets('the terminal view keeps its honest note and arms the '
        'world from there (phase 3c)', (final tester) async {
      final world = hermeticWorldState();
      await world.refresh();
      await _pumpShell(tester, worldState: world);
      await _openViaPicker(tester, 'newtab.entry.terminal', scroll: true);
      expect(find.byKey(const ValueKey('terminal.arm')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('terminal.arm')));
      await tester.pump();
      expect(world.armError, 'daemon_artifact_absent');
      addTearDown(world.dispose);
    });

    testWidgets('the boards view hosts the planning board; the mesh settle '
        'section stays absent without a live replica (phase 3c)', (
      final tester,
    ) async {
      await _pumpShell(tester);
      await _openViaPicker(tester, 'newtab.entry.boards');
      expect(find.byType(BoardView), findsOneWidget);
      expect(find.byKey(const ValueKey('boards.meshTasks')), findsNothing);
    });

    testWidgets('the threads view lists the realm threads through the '
        'shell (phase 3b, hermetic world lane)', (final tester) async {
      late RealmChatService service;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_shell_thr_');
        addTearDown(() => temp.delete(recursive: true));
        final world = await RealmWorld.open(rootOverride: temp.path);
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        await service.startThread(topic: 'Shell threads lane');
      });
      await _pumpShell(tester, service: service);
      await _openViaPicker(tester, 'newtab.entry.threads', scroll: true);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Shell threads lane'), findsOneWidget);
    });
  });
}
