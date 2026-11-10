// Wave F — the `shell_*` debug-bridge lane: a mounted AppShell assigns
// the ONE ShellDebugBridge instance (kDebugMode-guarded) and nulls it
// on dispose, and the bridge verbs drive the REAL layout document
// through the shell's own paths: toggleDock flips the persisted dock
// pref and the column's presence, openTab(split:) grows pane groups,
// selectRoom activates the conversation by its rooms-column row key,
// closeTab shrinks the strip, splitActive moves the focused tab right.
// The injected service is REAL over a hermetic world (the repo's lane).
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/mcp/shell_mcp_tools.dart';
import 'package:lastanswer/settings/settings.dart';
import 'package:lastanswer/shell/app_shell.dart';
import 'package:lastanswer/shell/surfaces.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hermetic_world_state.dart';

/// A ready hermetic service: one actor and one registered channel (its
/// non-empty registry keeps the shell's boot seed a no-op); no thread
/// is left selected, so the shell lands on the world face.
Future<RealmChatService> _hermeticService(final WidgetTester tester) async {
  late RealmChatService service;
  await tester.runAsync(() async {
    final temp = await Directory.systemTemp.createTemp('la_shell_tools_');
    addTearDown(() => temp.delete(recursive: true));
    final world = (await RealmWorld.open(rootOverride: temp.path))!;
    service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    addTearDown(service.dispose);
    service.firstRunSeedEnabled = false;
    await service.ensureReady();
    await service.createActor(
      displayName: 'Scout',
      kind: ActorKind.model,
      brainRef: '',
    );
    await service.createChannel('guild');
    service.clearActiveThread();
  });
  return service;
}

Future<void> _pumpShell(
  final WidgetTester tester, {
  required RealmChatService service,
}) async {
  final worldState = hermeticWorldState();
  await worldState.refresh();
  // Split panes need width headroom (the split verbs grow the row to
  // three groups by the end of the lane).
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
  // flutter_animate's mounted-then-disposed timer law: tick the fake
  // clock once after the mount frame, then settle the boot animations.
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  addTearDown(worldState.dispose);
}

/// Drains the real IO a conversation select starts (the
/// settle-then-runAsync law: no live ticker is inside the window).
Future<void> _drain(final WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump();
}

int _groupCount(final ShellDebugBridge bridge) =>
    (bridge.state()['groups']! as List).length;

void main() {
  late Directory devicePin;
  setUp(() {
    // The chat-first projection is the default (docked, no pref).
    SharedPreferences.setMockInitialValues({});
    devicePin = Directory.systemTemp.createTempSync('la_tools_home_');
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

  testWidgets('the family registers its six entries', (final tester) async {
    expect(shellMcpEntries(), hasLength(6));
  });

  testWidgets('a mounted shell assigns the bridge; its verbs drive the '
      'layout document; dispose releases it', (final tester) async {
    // No shell mounted: no bridge — the tools' honest-refusal floor.
    expect(ShellDebugBridge.instance, isNull);

    final service = await _hermeticService(tester);
    await _pumpShell(tester, service: service);
    final bridge = ShellDebugBridge.instance;
    expect(bridge, isNotNull);
    addTearDown(() => ShellDebugBridge.instance = null);

    // shell_state: the docked default, ONE group, the world face.
    final state = bridge!.state();
    expect(state['docked'], isTrue);
    expect(state['activeTab'], kConversationsSurfaceId);
    expect(_groupCount(bridge), 1);
    expect(bridge.docked(), isTrue);

    // shell_toggle_dock: flips the pref AND the column's presence.
    await bridge.toggleDock();
    await tester.pump();
    expect(bridge.docked(), isFalse);
    expect(
      find.byKey(const ValueKey('shell.roomsColumn')),
      findsNothing,
    );
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('shell.rooms.docked'), isFalse);
    await bridge.toggleDock();
    await tester.pump();
    expect(bridge.docked(), isTrue);
    expect(
      find.byKey(const ValueKey('shell.roomsColumn')),
      findsOneWidget,
    );
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('shell.rooms.docked'), isTrue);

    // shell_open_tab with split: the pure v4 composition grows groups.
    expect(await bridge.openTab('people', split: true), isTrue);
    await tester.pump();
    expect(_groupCount(bridge), 2);
    expect(bridge.state()['activeTab'], kPeopleSurfaceId);
    expect(find.byKey(const ValueKey('view.tab.people')), findsOneWidget);

    // An `actor:<id>` id routes like a VIEW id (information, never a
    // conversation): the docked active view group hosts it.
    final actorId = service
        .roster!
        .all
        .firstWhere((final actor) => actor.kind != ActorKind.human)
        .actorId;
    final actorSurface = actorSurfaceId(actorId);
    expect(await bridge.openTab(actorSurface), isTrue);
    await tester.pump();
    expect(
      find.byKey(ValueKey('view.tab.$actorSurface')),
      findsOneWidget,
    );
    expect(bridge.state()['activeTab'], actorSurface);
    // The info surface's grants reload is real IO — drain it.
    await _drain(tester);

    // shell_select_room: the row key activates the conversation tab
    // (group 0 — the docked law); unknown shapes refuse honestly.
    final channelId = service.channels.first.channelId;
    expect(bridge.selectRoom('rooms.row.channel.$channelId'), isTrue);
    await tester.pump();
    await _drain(tester);
    expect(bridge.state()['activeTab'], 'channel:$channelId');
    expect(bridge.selectRoom('rooms.cta.dm'), isFalse);
    expect(bridge.selectRoom('nonsense'), isFalse);

    // shell_close_tab: shrinks the strip; unknown ids refuse.
    expect(bridge.closeTab('people'), isTrue);
    await tester.pump();
    expect(find.byKey(const ValueKey('view.tab.people')), findsNothing);
    expect(bridge.closeTab('definitely-not-open'), isFalse);

    // shell_split_active: the focused tab moves into a new right pane.
    final before = _groupCount(bridge);
    bridge.splitActive();
    await tester.pump();
    expect(_groupCount(bridge), before + 1);
    expect(bridge.state()['activeTab'], 'channel:$channelId');

    // A focused composer holds a scheduler performance mode: unfocus
    // before the teardown swap (the shell test-lane law).
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    // The bridge dies WITH the tree — never a stale static seam.
    await tester.pumpWidget(const SizedBox());
    expect(ShellDebugBridge.instance, isNull);
  });
}
