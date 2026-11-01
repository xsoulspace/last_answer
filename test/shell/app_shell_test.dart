// ADR 0024 — the app shell widget tests: the rail is the chrome, the
// center is a flat tab strip, and the strip survives a restart through
// its persisted JSON blob (the retired pane-tree blob migrates once).
//
// The injected RealmChatService is a REAL service. Two lanes:
// - the default lane, whose world start fails honestly in the test
//   binding (path_provider has no plugin) — the shell renders its
//   not-ready states without touching any realm store;
// - a hermetic lane over `RealmWorld.open(rootOverride:)` for the
//   rail-contract test (the rail selects through the service; the shell
//   translates that into the conversation slot).
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

import 'package:flutter/gestures.dart' show kSecondaryMouseButton;

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/agent_doc_surface.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/settings/features/storage_backends_state.dart';

import 'package:lastanswer/shell/app_shell.dart';

import 'package:lastanswer/shell/context_column.dart';

import 'package:lastanswer/shell/pinned_conversation_peek.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/workspaces/workspace_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

/// A projects notifier fake whose real pager holds zero items — enough
/// for the rail's PROJECTS section to render honestly empty.
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
}) async {
  final resolved = service ?? RealmChatService();
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectsNotifier>.value(value: _IdleProjects()),
        // ADR 0026 — the rail's WORKSPACES section: the store-less
        // notifier renders the honest empty state (no store I/O).
        ChangeNotifierProvider<WorkspaceNotifier>.value(
          value: WorkspaceNotifier(storeLoader: () async => null),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        // Production wraps the shell in ScreenScaffold's Scaffold; mirror
        // that here so Material ancestors exist.
        home: Scaffold(
          body: AppShell(service: resolved, child: const CenterTabsArea()),
        ),
      ),
    ),
  );
  // Flush the initState `ensureReady` no-op (the already-settled start)
  // and let the not-ready progress indicator's animation timers fire.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
  // Advance fake time so the not-ready progress indicator's animation
  // timers fire and complete before the invariant check.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    // The shell installs the home face's seams on mount; release them so
    // other suites start clean.
    AgentDocSurface.createMeaningExperimentHook = null;
    AgentDocSurface.createAgentProjectHook = null;
    AgentDocSurface.meshWiring = null;
    StorageBackendsNotifier.onSyncCycle = null;
  });

  testWidgets('launching lands in the shell: the rail is present and the '
      'conversations tab hosts the center (not-ready states are honest)', (
    final tester,
  ) async {
    await _pumpShell(tester);

    // The rail chrome exists…
    expect(find.byKey(const ValueKey('rail.search')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.add')), findsOneWidget);
    expect(find.byKey(const ValueKey('rail.settings')), findsOneWidget);
    // …and the center is the flat strip hosting the conversations
    // surface.
    expect(find.byKey(const ValueKey('center.tabs')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('pane.tab.$kConversationsSurfaceId')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('pane.leaf.$kConversationsSurfaceId')),
      findsOneWidget,
    );
    // No home face: no Workbench entry, no greeting.
    expect(find.byKey(const ValueKey('home-open-workbench')), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    // The dissolved home face's load-bearing seams are installed by the
    // shell itself (debug/profile guard, same as before the move).
    expect(AgentDocSurface.createMeaningExperimentHook, isNotNull);
    expect(AgentDocSurface.meshWiring, isNotNull);
    expect(StorageBackendsNotifier.onSyncCycle, isNotNull);
  });

  testWidgets(
    'the conversations surface is collapsed: no inner thread list, the '
    'rail is the one conversation list',
    (final tester) async {
      await _pumpShell(tester);

      // The surface's old inner list affordance is gone — the rail owns
      // it now. The collapsed surface mounts no list or composer in any
      // state; in this lane the injected world fails honestly, so the
      // center is the not-ready note (a live world renders the focused
      // conversation only — world_chat_surface.dart no longer contains
      // a thread pane).
      expect(find.byKey(const ValueKey('worldchat.new')), findsNothing);
      expect(find.byKey(const ValueKey('worldchat.composer')), findsNothing);
      expect(
        find.textContaining('The world chat failed to open'),
        findsOneWidget,
      );
      // The rail carries the conversation-list chrome (search + add).
      expect(find.byKey(const ValueKey('rail.search')), findsOneWidget);
      expect(find.byKey(const ValueKey('rail.add')), findsOneWidget);
    },
  );

  testWidgets(
    'context column: auto-hidden below the 980px minimum window width, '
    'present at and above it, hideable by the human',
    (final tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pumpShell(tester);

      // Default test surface (800px): below the gate — hidden.
      expect(
        find.byKey(const ValueKey('shell.contextColumn')),
        findsNothing,
      );

      // 1000px clears the 980px gate: the column joins the shell row,
      // quiet note while no conversation is open. (This pins the lowered
      // gate — the old 1200px gate kept the column hidden here.)
      tester.view
        ..physicalSize = const Size(1000, 900)
        ..devicePixelRatio = 1.0;
      await tester.pump();
      final column = find.byKey(const ValueKey('shell.contextColumn'));
      expect(column, findsOneWidget);
      expect(
        find.descendant(
          of: column,
          matching: find.text('Select a conversation from the rail.'),
        ),
        findsOneWidget,
      );

      // The human's toggle (the conversation header's panel-right
      // affordance drives the same controller) hides and restores it.
      final controller = tester.element(column).read<ContextColumnController>()
        ..setVisible(value: false);
      await tester.pump();
      expect(
        find.byKey(const ValueKey('shell.contextColumn')),
        findsNothing,
      );

      controller.setVisible(value: true);
      await tester.pump();
      expect(find.byKey(const ValueKey('shell.contextColumn')), findsOneWidget);
    },
  );

  testWidgets(
    'tabs persistence round-trip: a restored two-tab strip tab-switches '
    'and the choice survives a fresh shell',
    (final tester) async {
      // Seed: conversations + inspector, conversations active. (The
      // browser leaf needs the webview platform — not hermetic in the
      // test binding; the inspector leaf is the real pane over the
      // empty shared registry.)
      SharedPreferences.setMockInitialValues({
        kCenterTabsPrefsKey: jsonEncode({
          'tabs': [kConversationsSurfaceId, kInspectorSurfaceId],
          'active': 0,
        }),
      });

      await _pumpShell(tester);

      // The restored strip renders both tabs; the inactive leaf is not
      // built.
      expect(
        find.byKey(const ValueKey('pane.tab.$kConversationsSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.tab.$kInspectorSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.leaf.$kConversationsSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.leaf.$kInspectorSurfaceId')),
        findsNothing,
      );

      // Switch to the inspector tab: the shell persists the activation.
      await tester.tap(
        find.byKey(const ValueKey('pane.tab.$kInspectorSurfaceId')),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('pane.leaf.$kInspectorSurfaceId')),
        findsOneWidget,
      );
      final stored =
          jsonDecode(
                (await SharedPreferences.getInstance()).getString(
                  kCenterTabsPrefsKey,
                )!,
              )
              as Map;
      expect(stored['active'], 1);
      expect(stored['tabs'], [
        kConversationsSurfaceId,
        kInspectorSurfaceId,
      ]);

      // A fresh shell restores the strip as the human left it.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await _pumpShell(tester);
      expect(
        find.byKey(const ValueKey('pane.leaf.$kInspectorSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.leaf.$kConversationsSurfaceId')),
        findsNothing,
      );

      // The real inspector pane owns this leaf; its periodic poll must
      // not outlive the test (the pending-timer invariant). Dispose the
      // tree, as the pane's own tests do.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'a corrupt persisted strip keeps the default shell (never takes the '
    'app down)',
    (final tester) async {
      SharedPreferences.setMockInitialValues({
        kCenterTabsPrefsKey: '{not json',
      });
      await _pumpShell(tester);
      expect(
        find.byKey(const ValueKey('pane.leaf.$kConversationsSurfaceId')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'the retired pane-tree blob migrates once: leaves flatten into tabs '
    '(conversations first), the new key is written, the legacy key is '
    'never read again',
    (final tester) async {
      // Seed ONLY the legacy key: a two-leaf split with conversations
      // NOT first in the tree — the flatten must still lead the strip
      // with it.
      SharedPreferences.setMockInitialValues({
        kLegacyPaneTreePrefsKey: jsonEncode({
          't': 'split',
          'axis': 'horizontal',
          'ratio': 0.5,
          'children': [
            {
              't': 'leaf',
              'surfaceId': kInspectorSurfaceId,
              'params': <String, Object?>{},
            },
            {
              't': 'leaf',
              'surfaceId': kConversationsSurfaceId,
              'params': <String, Object?>{},
            },
          ],
        }),
      });

      await _pumpShell(tester);

      // The flattened strip: conversations first and active.
      expect(
        find.byKey(const ValueKey('pane.tab.$kConversationsSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.tab.$kInspectorSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.leaf.$kConversationsSurfaceId')),
        findsOneWidget,
      );

      // The migration wrote the new key; the legacy key is untouched.
      final prefs = await SharedPreferences.getInstance();
      final migrated =
          jsonDecode(prefs.getString(kCenterTabsPrefsKey)!) as Map;
      expect(migrated['tabs'], [
        kConversationsSurfaceId,
        kInspectorSurfaceId,
      ]);
      expect(migrated['active'], 0);
      expect(
        prefs.getString(kLegacyPaneTreePrefsKey),
        isNotNull,
      );

      // The old key is never read again: poisoning it changes nothing —
      // a fresh shell reads the new key.
      await prefs.setString(kLegacyPaneTreePrefsKey, '{garbage');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await _pumpShell(tester);
      expect(
        find.byKey(const ValueKey('pane.tab.$kInspectorSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.leaf.$kConversationsSurfaceId')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'the rail contract reuses the ONE conversation slot: openDm replaces '
    'the slot in place (Discord flow), selectChannel likewise — station '
    'tabs are untouched',
    (final tester) async {
      // Hermetic lane: a REAL service over a REAL world in a temp home,
      // with one actor and one open thread — the same shape the rail's
      // rows select through.
      late final RealmChatService service;
      late final ActorProfile toby;
      late final Directory temp;
      await tester.runAsync(() async {
        temp = await Directory.systemTemp.createTemp('la_center_tabs_');
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        final roster = ActorRoster(replicaId: 'tester');
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: roster,
          debugStartBotDispatcher: false,
        );
        await service.ensureReady();
        toby = (await service.createActor(
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
          role: 'researcher',
          systemPrompt: 'You are Toby, a careful researcher.',
        ))!;
        await service.startThread(
          topic: 'Toby Researcher',
          participants: <String>[toby.actorId],
        );
      });
      addTearDown(service.dispose);
      addTearDown(() => temp.delete(recursive: true));

      // Two tabs: conversations + inspector.
      SharedPreferences.setMockInitialValues({
        kCenterTabsPrefsKey: jsonEncode({
          'tabs': [kConversationsSurfaceId, kInspectorSurfaceId],
          'active': 0,
        }),
      });
      await _pumpShell(tester, service: service);

      // The rail's ACTORS row: openDm(actorId) — the shell translates
      // the service's focused thread into the conversation slot.
      await tester.runAsync(() => service.openDm(toby.actorId));
      await tester.pump();

      expect(
        find.byKey(ValueKey('pane.tab.dm:${toby.actorId}')),
        findsOneWidget,
      );
      // The slot was REPLACED in place — still exactly two tabs, the
      // inspector station untouched, the plain conversations face gone.
      expect(
        find.byKey(const ValueKey('pane.tab.$kConversationsSurfaceId')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('pane.tab.$kInspectorSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('pane.leaf.dm:${toby.actorId}')),
        findsOneWidget,
      );

      // The rail's CHANNELS row: create + selectChannel — the SAME slot
      // becomes the channel face, still in place.
      final channel = await tester.runAsync(
        () => service.createChannel('dev'),
      );
      await tester.pump();
      expect(channel, isNotNull);
      expect(
        find.byKey(ValueKey('pane.tab.channel:${channel!.channelId}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('pane.tab.dm:${toby.actorId}')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('pane.tab.$kInspectorSurfaceId')),
        findsOneWidget,
      );

      // The reused slot persisted as such.
      final stored =
          jsonDecode(
                (await SharedPreferences.getInstance()).getString(
                  kCenterTabsPrefsKey,
                )!,
              )
              as Map;
      expect(stored['tabs'], [
        'channel:${channel.channelId}',
        kInspectorSurfaceId,
      ]);
    },
  );

  testWidgets(
    'boot restore: a persisted conversation tab whose thread the '
    'service has not selected re-selects it once (no empty-note wait, '
    'no duplicate thread)',
    (final tester) async {
      // Hermetic lane, pre-ready service: exactly the injected-service
      // shape where no ready-notify ever reaches the shell — the
      // restore must fire from the tabs load itself.
      late final RealmChatService service;
      late final ActorProfile toby;
      late final Directory temp;
      await tester.runAsync(() async {
        temp = await Directory.systemTemp.createTemp('la_boot_restore_');
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        await service.ensureReady();
        toby = (await service.createActor(
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
          role: 'researcher',
        ))!;
      });
      addTearDown(service.dispose);
      addTearDown(() => temp.delete(recursive: true));

      // The strip persisted the DM tab from a previous run; the service
      // boots with NO selected thread.
      SharedPreferences.setMockInitialValues({
        kCenterTabsPrefsKey: jsonEncode({
          'tabs': ['dm:${toby.actorId}'],
          'active': 0,
        }),
      });
      await _pumpShell(tester, service: service);

      // The restore's openDm lives in the fake-async zone — real store
      // IO completes as pumps and runAsync take turns.
      await tester.runAsync(() async {
        for (var i = 0; i < 60 && service.activeThreadId == null; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }
      });
      expect(service.activeThreadId, isNotNull);
      expect(service.dmThreadOf(toby.actorId), isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the rail context menu floats a conversation into a miniwindow: '
    'the peek renders read-only above the shell',
    (final tester) async {
      late final RealmChatService service;
      late final ActorProfile toby;
      late final Directory temp;
      await tester.runAsync(() async {
        temp = await Directory.systemTemp.createTemp('la_miniwindow_');
        final world = (await RealmWorld.open(rootOverride: temp.path))!;
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: ActorRoster(replicaId: 'tester'),
          debugStartBotDispatcher: false,
        );
        await service.ensureReady();
        toby = (await service.createActor(
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
          role: 'researcher',
        ))!;
      });
      addTearDown(service.dispose);
      addTearDown(() => temp.delete(recursive: true));
      await _pumpShell(tester, service: service);
      final row = find.byKey(ValueKey('rail.actor.${toby.actorId}'));
      expect(row, findsOneWidget);

      // Right-click the row; the context menu offers the miniwindow.
      await tester.tap(row, buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open in miniwindow'));
      await tester.pumpAndSettle();

      // The window floats above the shell; the DM was opened for the
      // peek's thread id (real IO — pumps and runAsync take turns).
      final window = find.byKey(ValueKey('miniwindow.dm:${toby.actorId}'));
      await tester.runAsync(() async {
        for (var i = 0; i < 60 && !tester.any(window); i++) {
          await tester.pump(const Duration(milliseconds: 50));
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }
      });
      expect(window, findsOneWidget);
      expect(find.byType(PinnedConversationPeek), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ctrl+T opens/focuses the picker as a new active tab; ctrl+W closes '
    'the active tab (the browser keyboard map, ctrl lane)',
    (final tester) async {
      await _pumpShell(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(
        find.byKey(const ValueKey('pane.tab.$kNewTabSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.leaf.$kNewTabSurfaceId')),
        findsOneWidget,
      );
      // The picker page lists the real registry's destinations.
      expect(
        find.byKey(
          const ValueKey('newtab.entry.$kConversationsSurfaceId'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('newtab.entry.$kBrowserSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('newtab.entry.$kInspectorSurfaceId')),
        findsOneWidget,
      );

      // ctrl+W closes the ACTIVE tab (the picker) — nothing to swap in,
      // so the conversations face returns.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(
        find.byKey(const ValueKey('pane.tab.$kNewTabSurfaceId')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('pane.leaf.$kConversationsSurfaceId')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the macOS lane binds meta, not ctrl (⌘T picker, ⌘W close)',
    (final tester) async {
      // The foundation invariant check runs inside the test body's
      // lifetime (before addTearDown teardowns), so the override resets
      // in a finally — before the test ends.
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await _pumpShell(tester);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        expect(
          find.byKey(const ValueKey('pane.leaf.$kNewTabSurfaceId')),
          findsOneWidget,
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        expect(
          find.byKey(const ValueKey('pane.tab.$kNewTabSurfaceId')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'closing the last real tab leaves the picker; a restart lands on the '
    'conversations face (the picker is session chrome, never an empty '
    'persisted list)',
    (final tester) async {
      await _pumpShell(tester);

      // The default strip is the lone conversations face: its ✕ swaps
      // the picker in (the close law), and the real id persists.
      await tester.tap(
        find.byKey(
          const ValueKey('pane.tab.close.$kConversationsSurfaceId'),
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('pane.leaf.$kNewTabSurfaceId')),
        findsOneWidget,
      );
      final stored =
          jsonDecode(
                (await SharedPreferences.getInstance()).getString(
                  kCenterTabsPrefsKey,
                )!,
              )
              as Map;
      expect(stored['tabs'], [kNewTabSurfaceId]);

      // A fresh shell: the lone picker does not survive the restart —
      // the restore lands on the default conversations face.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await _pumpShell(tester);
      expect(
        find.byKey(const ValueKey('pane.leaf.$kConversationsSurfaceId')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('pane.tab.$kNewTabSurfaceId')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a title fact arriving WITHOUT a tab change relabels the '
      'strip (the strip rebuilds on service notifications)', (
    final tester,
  ) async {
    // Regression: the strip widget instance was built once OUTSIDE its
    // ListenableBuilder, so Flutter saw an identical child and never
    // rebuilt — a tab kept its raw-id label forever.
    late final RealmChatService service;
    late final Directory temp;
    await tester.runAsync(() async {
      temp = await Directory.systemTemp.createTemp('la_title_fact_');
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: ActorRoster(replicaId: 'tester'),
        debugStartBotDispatcher: false,
      );
      await service.ensureReady();
    });
    addTearDown(service.dispose);
    addTearDown(() => temp.delete(recursive: true));

    // The tab persists an id the roster cannot yet name — the honest
    // fallback labels it with the raw id.
    SharedPreferences.setMockInitialValues({
      kCenterTabsPrefsKey: jsonEncode({
        'tabs': ['dm:ghost'],
        'active': 0,
      }),
    });
    await _pumpShell(tester, service: service);
    expect(find.text('dm:ghost'), findsOneWidget);

    // The roster learns the id (a pure title fact — the TAB ITSELF
    // never changes, no open/close/focus fires): upsert into the SAME
    // roster override the service reads, then refresh (notify).
    await tester.runAsync(() async {
      service.roster?.upsert(
        const ActorProfile(actorId: 'ghost', displayName: 'Ghost Writer'),
      );
      await service.refreshThreads();
    });
    await tester.pump();

    expect(find.text('dm:ghost'), findsNothing);
    // The tab relabeled; the rail's row carries the same name.
    expect(find.text('Ghost Writer'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
