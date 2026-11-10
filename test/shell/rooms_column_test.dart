// The docked ROOMS COLUMN (owner law 2026-11-10, the chat-first
// projection) and its shell laws: the column is navigation chrome —
// never a tab, never a surface. Rows ride the shell's ordinary
// tab-select path into GROUP 0 (the conversation group); view tabs
// split right; closing group 0's last tab lands on the world face and
// NEVER removes the group; the first entry seeds #general once and the
// composer takes the caret. The injected service is REAL over a
// hermetic world (the repo's lane — a final class is never faked).
import 'dart:convert';

import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/la_world/la_world_components.dart';
import 'package:lastanswer/settings/settings.dart';
import 'package:lastanswer/shell/app_shell.dart';
import 'package:lastanswer/shell/pane_strip.dart';
import 'package:lastanswer/shell/rooms_column.dart';
import 'package:lastanswer/shell/surfaces.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hermetic_world_state.dart';

/// Builds a ready hermetic service over a fresh temp world. The
/// fixture world carries: two actors (Scout, Ember), a DM with Scout,
/// one watchable room thread (both actors + the human) and one
/// registered channel (`guild`).
Future<RealmChatService> _hermeticService(final WidgetTester tester) async {
  late RealmChatService service;
  await tester.runAsync(() async {
    final temp = await Directory.systemTemp.createTemp('la_rooms_');
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
    // A watchable room: THREE members — neither a two-member DM slot
    // nor a channel.
    await service.startThread(topic: 'Room One', participants: <String>[
      scout.actorId,
      ember.actorId,
    ]);
    // A registered channel LAST: createChannel selects it, and its
    // non-empty registry keeps the shell's boot seed a no-op here.
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

/// The persisted v4 layout, decoded (the routing law's oracle).
Future<Map<String, Object?>> _persistedV4() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString('shell.views.v4')!) as Map<String, Object?>;
}

List<String> _groupTabs(final Map<String, Object?> decoded, final int group) =>
    (((decoded['groups']! as List)[group]! as Map)['tabs'] as List)
        .cast<String>();

/// The composer's focus fact (the first-entry law's oracle).
bool _composerFocused(final WidgetTester tester) {
  final editable = tester.widget<EditableText>(
    find.descendant(
      of: find.byKey(const ValueKey('worldchat.composer')),
      matching: find.byType(EditableText),
    ),
  );
  return editable.focusNode.hasFocus;
}

/// The picker panel is a LAZY list: rows past the fold exist only after
/// scrolling (the same truth for users, agents and tests).
Future<void> _scrollPickerTo(
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

void main() {
  late Directory devicePin;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    devicePin = Directory.systemTemp.createTempSync('la_rooms_home_');
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

  group('the column renders the service facts', () {
    testWidgets('sections and rows render from the fixture service', (
      final tester,
    ) async {
      final service = await _hermeticService(tester);
      final actorId = service.roster!.all
          .firstWhere((final actor) => actor.kind != ActorKind.human)
          .actorId;
      final channelId = service.channels.first.channelId;
      final roomThreadId = service.roomThreads.first['threadId']! as String;
      await _pumpShell(tester, service: service);

      // First entry is the chat-first projection: the column is docked
      // without a single pref written.
      expect(find.byKey(const ValueKey('shell.roomsColumn')), findsOneWidget);
      expect(find.byKey(const ValueKey('rooms.section.dms')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('rooms.section.channels')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('rooms.section.rooms')), findsOneWidget);
      expect(
        find.byKey(ValueKey('rooms.row.dm.$actorId')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('rooms.row.channel.$channelId')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('rooms.row.room.$roomThreadId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('rooms.create.channel')),
        findsOneWidget,
      );
      // The column is chrome, never a tab: no strip pill for it.
      expect(find.byKey(const ValueKey('view.tab.rooms')), findsNothing);
    });

    testWidgets('an empty DMs section renders the ONE CTA row', (
      final tester,
    ) async {
      late RealmChatService service;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_rooms_cta_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        // A channel keeps the boot seed a no-op; no actor → no DM rows.
        await service.createChannel('guild');
        service.clearActiveThread();
      });
      await _pumpShell(tester, service: service);
      expect(find.byKey(const ValueKey('rooms.cta.dm')), findsOneWidget);
      expect(find.byKey(const ValueKey('rooms.section.dms')), findsOneWidget);
    });

    testWidgets('no LaWorld = honest absence: no row badges render', (
      final tester,
    ) async {
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);
      expect(
        find.byWidgetPredicate(
          (final widget) =>
              widget.key is ValueKey &&
              (widget.key! as ValueKey).value
                  .toString()
                  .startsWith('rooms.unread.'),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a fed LaWorld badges the row reactively; the receipt '
        'clears it', (final tester) async {
      final service = await _hermeticService(tester);
      final actorId = service.roster!.all
          .firstWhere(
            (final actor) =>
                actor.kind != ActorKind.human &&
                service.dmThreadOf(actor.actorId) != null,
          )
          .actorId;
      final dmThread = service.dmThreadOf(actorId)!;
      late LaWorld laWorld;
      await tester.runAsync(() async {
        laWorld = LaWorld(humanActorId: () => service.humanActorId!);
        addTearDown(laWorld.dispose);
        laWorld
          ..putRoom(
            RoomRow(
              threadId: dmThread,
              topic: 'Scout',
              lastBeat: 2,
              participants: [service.humanActorId!, actorId],
            ),
          )
          ..commitBatch();
      });

      // The shell OWNS its LaWorld provider (null until the fold
      // starts), so the badge contract is asserted on the column
      // directly — the same lane the action bar's badge test rides.
      await tester.pumpWidget(
        Provider<LaWorld?>.value(
          value: laWorld,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(
              body: ListenableBuilder(
                listenable: service,
                builder: (final context, final _) => RoomsColumn(
                  service: service,
                  onSelect: (_) {},
                  onCreateChannel: () {},
                  onMessageActor: () {},
                  onMiniWindow: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final badge = find.byKey(ValueKey('rooms.unread.dm:$actorId'));
      expect(badge, findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // The receipt clears it reactively (one batch, one rebuild).
      laWorld
        ..putRoomReceipt(dmThread, 2)
        ..commitBatch();
      await tester.pump();
      expect(find.text('2'), findsNothing);
    });
  });

  group('the dock toggle', () {
    testWidgets('rail.actors undocks and re-docks the column and persists '
        'the projection choice', (final tester) async {
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);
      // The first entry is docked (the default, no pref on disk).
      expect(find.byKey(const ValueKey('shell.roomsColumn')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('rail.actors')));
      await tester.pump();
      expect(find.byKey(const ValueKey('shell.roomsColumn')), findsNothing);
      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kRoomsDockedPrefsKey), isFalse);

      await tester.tap(find.byKey(const ValueKey('rail.actors')));
      await tester.pump();
      expect(find.byKey(const ValueKey('shell.roomsColumn')), findsOneWidget);
      prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kRoomsDockedPrefsKey), isTrue);
    });

    testWidgets('a persisted undock restores the workspace projection', (
      final tester,
    ) async {
      SharedPreferences.setMockInitialValues({'shell.rooms.docked': false});
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);
      expect(find.byKey(const ValueKey('shell.roomsColumn')), findsNothing);
      expect(find.byKey(const ValueKey('rail.actors')), findsOneWidget);
    });
  });

  group('tab routing while docked (the chat-first projection)', () {
    testWidgets('a room row opens its conversation tab in GROUP 0', (
      final tester,
    ) async {
      final service = await _hermeticService(tester);
      final channelId = service.channels.first.channelId;
      await _pumpShell(tester, service: service);

      await tester.tap(find.byKey(ValueKey('rooms.row.channel.$channelId')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.byKey(ValueKey('view.tab.channel:$channelId')),
        findsOneWidget,
      );
      final decoded = await _persistedV4();
      expect(decoded['groups']! as List, hasLength(1));
      expect(_groupTabs(decoded, 0), contains('channel:$channelId'));
      // The row tap re-selected the thread through the service (the
      // source of truth), and the selected row mirrors it.
      expect(service.activeThreadId, service.channels.first.threadId);

      // Drain the selection's real IO (beat tail read) INSIDE the test.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    });

    testWidgets('the first view tab splits RIGHT (openTab+split compose); '
        'a second view joins the active view group', (final tester) async {
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);

      // Open a view through the picker: with ONE group the pure v4 ops
      // compose — the view tab ends up in a NEW right-hand group.
      await tester.tap(find.byKey(const ValueKey('view.strip.add.0')));
      await tester.pump();
      await _scrollPickerTo(tester, 'newtab.entry.boards');
      await tester.tap(find.byKey(const ValueKey('newtab.entry.boards')));
      await tester.pump();
      expect(find.byType(PaneStrip), findsNWidgets(2));
      var decoded = await _persistedV4();
      expect(_groupTabs(decoded, 0), <String>[kConversationsSurfaceId]);
      expect(_groupTabs(decoded, 1), contains(kBoardsSurfaceId));

      // A second view joins the ACTIVE view group (never group 0).
      await tester.tap(find.byKey(const ValueKey('view.strip.add.1')));
      await tester.pump();
      await _scrollPickerTo(tester, 'newtab.entry.people');
      await tester.tap(find.byKey(const ValueKey('newtab.entry.people')));
      await tester.pump();
      decoded = await _persistedV4();
      expect(decoded['groups']! as List, hasLength(2));
      expect(_groupTabs(decoded, 1), containsAll(<String>[
        kBoardsSurfaceId,
        kPeopleSurfaceId,
      ]));
      expect(_groupTabs(decoded, 0), <String>[kConversationsSurfaceId]);
    });

    testWidgets('closing group 0’s LAST tab lands on the world face and '
        'never removes group 0', (final tester) async {
      SharedPreferences.setMockInitialValues({
        'shell.views.v4': jsonEncode(<String, Object?>{
          'v': 4,
          'groups': <Object?>[
            <String, Object?>{'tabs': <String>['dm:ghost'], 'active': 0},
            <String, Object?>{'tabs': <String>[kBoardsSurfaceId], 'active': 0},
          ],
          'active': 0,
        }),
      });
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);
      expect(find.byType(PaneStrip), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey('view.tab.close.dm:ghost')));
      await tester.pump();
      // Group 0 survived — on the conversations world face (the front
      // door); the view group is untouched.
      expect(find.byType(PaneStrip), findsNWidgets(2));
      expect(
        find.byKey(const ValueKey('view.tab.conversations')),
        findsOneWidget,
      );
      final decoded = await _persistedV4();
      expect(_groupTabs(decoded, 0), <String>[kConversationsSurfaceId]);
      expect(_groupTabs(decoded, 1), <String>[kBoardsSurfaceId]);

      // Closing the world face itself (group 0's last tab) is a no-op
      // while docked: the front door never closes.
      await tester.tap(
        find.byKey(const ValueKey('view.tab.close.conversations')),
      );
      await tester.pump();
      expect(find.byType(PaneStrip), findsNWidgets(2));
      expect(
        find.byKey(const ValueKey('view.tab.conversations')),
        findsOneWidget,
      );
    });
  });

  group('undocked stays byte-identical to the legacy behavior', () {
    testWidgets('a view opens in the active group; closing a sole group’s '
        'last tab folds it away', (final tester) async {
      SharedPreferences.setMockInitialValues({
        'shell.rooms.docked': false,
        'shell.views.v4': jsonEncode(<String, Object?>{
          'v': 4,
          'groups': <Object?>[
            <String, Object?>{
              'tabs': <String>[kBoardsSurfaceId],
              'active': 0,
            },
            <String, Object?>{
              'tabs': <String>[kPeopleSurfaceId],
              'active': 0,
            },
          ],
          'active': 1,
        }),
      });
      final service = await _hermeticService(tester);
      await _pumpShell(tester, service: service);
      expect(find.byType(PaneStrip), findsNWidgets(2));

      // The legacy fold law: closing a group's last tab REMOVES it.
      await tester.tap(
        find.byKey(const ValueKey('view.tab.close.$kPeopleSurfaceId')),
      );
      await tester.pump();
      expect(find.byType(PaneStrip), findsOneWidget);
      final decoded = await _persistedV4();
      expect(decoded['groups']! as List, hasLength(1));
      expect(_groupTabs(decoded, 0), <String>[kBoardsSurfaceId]);
    });
  });

  group('the channel row’s context menu', () {
    testWidgets('rename calls the service verb and the row follows', (
      final tester,
    ) async {
      final service = await _hermeticService(tester);
      final channelId = service.channels.first.channelId;
      await _pumpShell(tester, service: service);

      await tester.tap(
        find.byKey(ValueKey('rooms.row.channel.$channelId')),
        buttons: kSecondaryMouseButton,
      );
      // The popup route animates in: settle before tapping its items
      // (a mid-animation menu absorbs the tap).
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('rooms.menu.rename.$channelId')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('rooms.rename.name')), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('rooms.rename.name')),
        'renamed-guild',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('rooms.rename.confirm')));
      // The dialog's exit animation must FINISH before the real-IO
      // window: a fake-clock ticker drained inside runAsync poisons the
      // next fake pump (negative elapsed).
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();

      expect(service.channels.single.name, 'renamed-guild');
      expect(find.text('#renamed-guild'), findsWidgets);
    });

    testWidgets('close archives the channel through the service verb', (
      final tester,
    ) async {
      final service = await _hermeticService(tester);
      final channelId = service.channels.first.channelId;
      await _pumpShell(tester, service: service);
      expect(
        find.byKey(ValueKey('rooms.row.channel.$channelId')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(ValueKey('rooms.row.channel.$channelId')),
        buttons: kSecondaryMouseButton,
      );
      // The popup route animates in: settle before tapping its items.
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('rooms.menu.close.$channelId')));
      // Settle the menu's exit animation before the real-IO window
      // (fake-clock tickers inside runAsync poison the next pump).
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();

      // LAW: closing archives — the channel leaves the projections, the
      // journal is never destroyed.
      expect(service.channels, isEmpty);
      expect(
        find.byKey(ValueKey('rooms.row.channel.$channelId')),
        findsNothing,
      );
    });

    testWidgets('a dm row offers the miniwindow only', (final tester) async {
      final service = await _hermeticService(tester);
      final actorId = service.roster!.all
          .firstWhere((final actor) => actor.kind != ActorKind.human)
          .actorId;
      await _pumpShell(tester, service: service);

      await tester.tap(
        find.byKey(ValueKey('rooms.row.dm.$actorId')),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(ValueKey('rooms.menu.miniwindow.dm:$actorId')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (final widget) =>
              widget.key is ValueKey &&
              (widget.key! as ValueKey).value
                  .toString()
                  .startsWith('rooms.menu.rename.'),
        ),
        findsNothing,
      );
      // Dismiss the menu and let its exit animation finish before the
      // teardown invariants run.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });
  });

  group('first entry (the seeded boot)', () {
    testWidgets('a fresh world seeds #general ONCE at boot and lands in it', (
      final tester,
    ) async {
      late RealmChatService service;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_rooms_seed_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
      });
      await _pumpShell(tester, service: service);
      // The seed's registry IO is real: drain it inside the test.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Seeded ONCE: exactly one channel, named general.
      expect(service.channels, hasLength(1));
      expect(service.channels.single.name, 'general');
      // …and the boot-restore/sync laws landed the shell IN it: the
      // channel's tab is open in group 0 and focused.
      final channelId = service.channels.single.channelId;
      expect(
        find.byKey(ValueKey('view.tab.channel:$channelId')),
        findsOneWidget,
      );
      final decoded = await _persistedV4();
      expect(_groupTabs(decoded, 0), contains('channel:$channelId'));
      expect(
        find.byKey(ValueKey('rooms.row.channel.$channelId')),
        findsOneWidget,
      );
      // A focused composer holds a scheduler performance mode; the
      // teardown invariant forbids leaving it pending.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    });

    testWidgets('booting into a room focuses the composer without a click', (
      final tester,
    ) async {
      late RealmChatService service;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_rooms_focus_');
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
          displayName: 'Scout',
          kind: ActorKind.model,
          brainRef: '',
        ))!;
        // The DM is the restored room; a registered channel keeps the
        // boot seed from re-selecting over it.
        await service.createChannel('guild');
        await service.openDm(actor.actorId);
      });
      await _pumpShell(tester, service: service);
      await tester.pump();

      // The caret is in the composer: the room-entry focus law, no
      // click, no key event.
      expect(_composerFocused(tester), isTrue);
      // Release the caret: its performance mode must not outlive the
      // test (teardown invariant).
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    });

    testWidgets('the seeded boot focuses the composer too', (
      final tester,
    ) async {
      late RealmChatService service;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_rooms_seedf_');
        addTearDown(() => temp.delete(recursive: true));
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
      });
      await _pumpShell(tester, service: service);
      // The seed lands asynchronously; once it selects #general the
      // pane rebuilds into the room and the composer takes the caret.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_composerFocused(tester), isTrue);
      // Release the caret: its performance mode must not outlive the
      // test (teardown invariant).
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    });
  });
}
