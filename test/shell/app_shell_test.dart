// ADR 0024 — the app shell widget tests. PHASE 1: the rail of views +
// roster hosts the center; EVERY view owns its Safari-like strip
// ([ShellLayout], persisted as `shell.views.v3`; the retired v2/v1 and
// pane-tree blobs migrate once). The dock and the global bar are gone —
// these tests are the chrome's new contract.
//
// The injected RealmChatService is a REAL service. Two lanes:
// - the default lane, whose world start fails honestly in the test
//   binding (path_provider has no plugin) — the shell renders its
//   not-ready states without touching any realm store;
// - a hermetic lane over `RealmWorld.open(rootOverride:)` for the
//   service-driven conversation flow (the rail selects through the
//   service; the shell translates that into the conversations strip).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/agent_doc_surface.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/settings/features/storage_backends_state.dart';

import 'package:lastanswer/shell/app_shell.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_tab_strip.dart';

import 'package:lastanswer/workspaces/workspace_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

/// A projects notifier fake whose real pager holds zero items — enough
/// for the rail's legacy sections to render honestly empty.
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

  testWidgets(
    'launching lands in the shell: the rail lists the views and the '
    'conversations view hosts the center with its own strip',
    (final tester) async {
      await _pumpShell(tester);
      // The rail's VIEWS section (the activity bar).
      expect(find.byKey(const ValueKey('rail.view.conversations')), findsOneWidget);
      expect(find.byKey(const ValueKey('rail.view.boards')), findsOneWidget);
      expect(find.byKey(const ValueKey('rail.view.inspector')), findsOneWidget);
      // The hosted view's strip, with its world-face tab focused.
      expect(find.byType(ViewTabStrip), findsOneWidget);
      expect(find.byKey(const ValueKey('view.strip.conversations')), findsOneWidget);
      expect(find.byKey(const ValueKey('view.tab.conversations')), findsOneWidget);
      // No dock, no global bar: the retired chrome stays retired.
      expect(find.byKey(const ValueKey('view.dock')), findsNothing);
    },
  );

  testWidgets('a rail view row hosts that view and persists v3', (
    final tester,
  ) async {
    await _pumpShell(tester);
    await tester.tap(find.byKey(const ValueKey('rail.view.boards')));
    await tester.pump();
    expect(find.byKey(const ValueKey('view.strip.boards')), findsOneWidget);
    expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);
    // The conversations strip survives, unfocused.
    expect(find.byKey(const ValueKey('view.strip.conversations')), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('shell.views.v3');
    expect(raw, isNotNull);
    final decoded = jsonDecode(raw!) as Map<String, Object?>;
    expect(decoded['v'], 3);
    expect(decoded['activeView'], kBoardsSurfaceId);
  });

  testWidgets('the strip + opens the picker in the ACTIVE view and pick '
      'replaces it in place', (final tester) async {
    await _pumpShell(tester);
    await tester.tap(find.byKey(const ValueKey('view.strip.add.conversations')));
    await tester.pump();
    expect(find.byKey(const ValueKey('view.tab.newtab')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('newtab.entry.boards')));
    await tester.pump();
    // The picker tab became the boards tab IN PLACE (one strip, one tab
    // row: the conversations strip now hosts conversations+boards? no —
    // pick replaces within the ACTIVE view's strip: conversations view
    // strip gains boards as a tab id? boards is its OWN view...
    // The picker's pick() replaces the picker tab in the active strip;
    // hosting stays on the conversations view (pick does not re-host).
    expect(find.byKey(const ValueKey('view.tab.newtab')), findsNothing);
    expect(find.byKey(const ValueKey('view.tab.boards')), findsOneWidget);
  });

  testWidgets('closing a strip\'s focused tab swaps the picker in', (
    final tester,
  ) async {
    await _pumpShell(tester);
    await tester.tap(find.byKey(const ValueKey('rail.view.boards')));
    await tester.pump();
    // The focused tab carries its close glyph.
    await tester.tap(find.byKey(const ValueKey('view.tab.close.boards')));
    await tester.pump();
    expect(find.byKey(const ValueKey('view.tab.newtab')), findsOneWidget);
  });

  testWidgets('a v2 blob migrates once into per-view strips', (
    final tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'shell.views.v2': jsonEncode(<String, Object?>{
        'tabs': <String>[kConversationsSurfaceId, kBoardsSurfaceId],
        'active': 1,
        'pinned': <String>[kPeopleSurfaceId],
        'dockFocus': kPeopleSurfaceId,
      }),
    });
    await _pumpShell(tester);
    // The v2 active tab was boards: the boards view hosts, with its own
    // strip; the pin became a tab of the people view.
    expect(find.byKey(const ValueKey('view.strip.boards')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final decoded =
        jsonDecode(prefs.getString('shell.views.v3')!) as Map<String, Object?>;
    final views = decoded['views'] as Map<String, Object?>;
    expect(views.containsKey(kPeopleSurfaceId), isTrue);
    expect(views.containsKey(kConversationsSurfaceId), isTrue);
  });

  testWidgets('the service selecting a thread re-slots the conversations '
      'strip (hermetic world lane)', (final tester) async {
    late RealmWorld world;
    late RealmChatService service;
    late ActorProfile actor;
    await tester.runAsync(() async {
      final temp = await Directory.systemTemp.createTemp('la_shell_v3_');
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
    // The ONE conversation slot carries the dm id (zero accumulation).
    expect(find.byKey(ValueKey('view.tab.dm:${actor.actorId}')), findsOneWidget);
    expect(find.byKey(const ValueKey('view.tab.conversations')), findsNothing);
  });
}
