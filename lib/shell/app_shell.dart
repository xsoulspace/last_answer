/// ADR 0024 — the app shell. DESIGN.md v2 (owner law 2026-11-08, the
/// approved mockup's anatomy; cut to the bone 2026-11-10): the shell is
/// an ACTION BAR + PANE GROUPS, and it carries TWO projections of the
/// ONE layout document — never two shells:
///
/// - CHAT-FIRST (the first-entry projection, grok/Discord lens): the
///   three-button rail [search, actors, gear], the docked ROOMS COLUMN
///   (navigation chrome like VSCode's sidebar — never a tab, never a
///   surface), conversations in group 0 and view tabs splitting right.
/// - WORKSPACE: the rail undocked (`rail.actors` toggles + persists)
///   and the free pane groups, byte-identical to the legacy behavior.
///
/// - The rail is cut to the bone: `rail.search` (palette), `rail.actors`
///   (the rooms-column dock toggle, wearing the total-unread badge) and
///   `rail.settings`. The kind buttons retired — opening lives in the
///   strip's `+` picker, the ⌘K palette and the rooms column.
/// - Tabs are the universal content surface, owned by PANE GROUPS
///   ([ShellLayout] v4, persisted as `shell.views.v4`, migrated in one
///   pass from `shell.views.v3` / `shell.views.v2` / `shell.tabs.v1` /
///   `shell.paneTree.v1`). Each group renders its own [PaneStrip]; the
///   split control moves the active tab into a new group, the fold
///   control merges it back.
/// - Tabs are INSTANCES: content ids (`dm:`, `channel:`, `doc:`),
///   registry faces, and instance ids (`browser:2`) — one strip grammar.
/// - First-run stays a BOOT state, never a tab; the status edge spans
///   the window once; "keep an eye on this" is still the miniwindow
///   (ADR 0027), reached from a tab's context menu.
///
/// The shell owns the layout as state, installs the agent-doc mesh seams
/// that used to live on the dissolved HomeScreen, and provides the shared
/// [RealmChatService] to everything below it (bar, strips, pane bodies).
///
/// Route shape: the shell wraps the router's nested navigator; the
/// navigator rides the ACTIVE group's pane slot (GlobalKey reparenting
/// keeps pushed routes alive across group switches). The `/home` route
/// body is [CenterTabsArea] — the active group's active tab host.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:headless_core/headless_core.dart' as hc;

import 'package:lastanswer/_library/widgets/widgets.dart';

import 'package:lastanswer/coding_agent/acp_bridge/acp_bridge_registry.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/agent_doc_surface.dart';

import 'package:lastanswer/coding_agent/meaning_experiment_entry.dart';

import 'package:lastanswer/coding_agent/permission_doc_router.dart';

import 'package:lastanswer/coding_agent/provider_configuration.dart';

import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/la_world/la_world.dart';

import 'package:lastanswer/la_world/la_world_feed.dart';

import 'package:lastanswer/settings/settings.dart';

import 'package:lastanswer/shell/action_bar.dart';

import 'package:lastanswer/shell/center_tabs.dart';

import 'package:lastanswer/shell/command_palette.dart';

import 'package:lastanswer/shell/create_flows.dart';

import 'package:lastanswer/shell/miniwindows/mini_window.dart';

import 'package:lastanswer/shell/miniwindows/mini_window_persistence.dart';

import 'package:lastanswer/shell/new_tab_menu.dart';

import 'package:lastanswer/shell/pane_strip.dart';

import 'package:lastanswer/shell/pinned_conversation_peek.dart';

import 'package:lastanswer/shell/rooms_column.dart';

import 'package:lastanswer/shell/shell_layout.dart';

import 'package:lastanswer/shell/shell_scope.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/status_edge.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_documents.dart';

import 'package:lastanswer/shell/view_people.dart';

import 'package:lastanswer/workspaces/workspace_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// The SharedPreferences key holding the pane-group layout JSON v4
/// (`groups` + the active group index).
const String kViewLayoutPrefsKey = 'shell.views.v4';

/// The RETIRED per-view key (v3). Read once for the one-time migration
/// into v4; never written again.
const String kViewLayoutV3PrefsKey = 'shell.views.v3';

/// The RETIRED unified-views key (one global bar + pins). Read once for
/// the one-time migration; never written again.
const String kViewLayoutV2PrefsKey = 'shell.views.v2';

/// The RETIRED center-strip key, read only when v2 is absent.
const String kCenterTabsPrefsKey = 'shell.tabs.v1';

/// The RETIRED pane-tree key, read only when v2 and v1 are absent.
const String kLegacyPaneTreePrefsKey = 'shell.paneTree.v1';

/// The SharedPreferences key holding the rooms-column dock state (the
/// chat-first projection's bool). DEFAULT TRUE: a first entry lands in
/// the chat-first projection — rail + rooms column + conversation.
const String kRoomsDockedPrefsKey = 'shell.rooms.docked';

/// The shell chrome: the action bar, the pane groups (each with its own
/// strip), the picker overlay, the status edge. Inject [service] in
/// tests; production resolves it internally.
final class AppShell extends StatefulWidget {
  const AppShell({
    required this.child,
    this.service,
    this.worldState,
    super.key,
  });

  /// The router body below the shell (the nested navigator).
  final Widget child;

  /// Test seam; production creates and owns one.
  final RealmChatService? service;

  /// Test seam for the world's read model (phase 1d); production
  /// creates and owns one, polling the doctor/journal/registry truth.
  final WorldStateService? worldState;

  @override
  State<AppShell> createState() => _AppShellState();

  /// Debug-only root for the in-app semantics/element dump tool
  /// (`debug_semantics_labels`, registered in debug/profile builds).
  static BuildContext? debugRootContext;
}

class _AppShellState extends State<AppShell> {
  /// The chat service: injected (tests, a future root DI) or OWNED by
  /// the shell. An owned service is disposed WITH the shell — its
  /// journal watch's debounce timer must not outlive the widget tree
  /// (the teardown invariant), and the world it opened closes with it.
  late final RealmChatService _service;
  late final bool _ownsService;

  /// The world's read model behind the status edge, the landing inbox
  /// and the Models surface (phase 1d). Injected in tests (or resolved
  /// from DI); production creates and owns one (and its poll timer).
  late final WorldStateService? _injectedWorldState =
      widget.worldState ?? context.read<WorldStateService?>();
  late final WorldStateService _worldState =
      _injectedWorldState ?? WorldStateService();
  late final bool _ownsWorldState = _injectedWorldState == null;

  ShellLayout _layout = ShellLayout.defaultLayout();
  final PeopleFocus _peopleFocus = PeopleFocus();
  var _seamsInstalled = false;

  /// The rooms-column dock (the projection switch): true = chat-first
  /// (rail + rooms column + conversations in group 0), false = the
  /// workspace projection (free pane groups). Persisted as
  /// [kRoomsDockedPrefsKey]; the default is the first-entry projection.
  var _roomsDocked = true;

  /// 1a — LaWorld: the reactive ecsly projection over the realm
  /// journal (cursor-fed, never polling). Null until the chat service
  /// resolves the world and the human identity; the action bar's
  /// unread badge rides it first, surfaces migrate one by one. The
  /// feed's watch subscription is cancelled in dispose (the
  /// pending-timer law the WorldStateService poll follows).
  LaWorld? _laWorld;
  LaWorldFeed? _laWorldFeed;

  /// The conversation id the boot restore already handled (once per id,
  /// never retried — see [_restorePersistedConversationTab]).
  String? _bootRestoredId;

  /// The registry's loaded page, captured per build for `doc:<id>` tab
  /// titles (phase 3a).
  ProjectsNotifier? _projects;

  /// Phase 2 — the ⌘K command palette overlay's open state.
  bool _paletteOpen = false;

  /// The new-tab picker overlay (v4: a menu anchored to a strip's `+`,
  /// never a tab): which group's `+` owns it, and the anchor link.
  bool _pickerOpen = false;
  int _pickerGroup = 0;
  final LayerLink _pickerLink = LayerLink();

  /// Phase 2 — the shell's focus anchor: shell-level shortcuts answer
  /// even after clicks on non-focusable chrome (the `⌘T handled:false`
  /// class) because the anchor reclaims primary focus whenever focus
  /// falls to nothing.
  final FocusNode _shellFocus = FocusNode(debugLabel: 'shell.anchor');

  /// The navigator's reparenting key: the router's nested navigator
  /// rides the ACTIVE group's pane slot, and a group switch moves the
  /// element (with its pushed-route stack) instead of remounting it.
  final GlobalKey _navigatorKey = GlobalKey(debugLabel: 'shell.navigator');

  /// ADR 0027 — the miniwindow layer's state: floating windows (the
  /// window presentation of a surface), fed by a tab's context menu
  /// and persisted beside the layout.
  final MiniWindowController _miniWindows = MiniWindowController();
  final MiniWindowPersistence _miniWindowPersistence = MiniWindowPersistence();

  @override
  void initState() {
    super.initState();
    // The root DI owns the app-run singleton (one bot host per world);
    // the shell constructs its own only when no DI ancestor and no
    // injected service exist (hermetic tests) — and then owns its
    // disposal too.
    final injected = widget.service ?? context.read<RealmChatService?>();
    if (injected != null) {
      _service = injected;
      _ownsService = false;
    } else {
      _service = RealmChatService(
        providerConfiguration: context.read<ProviderConfigurationStore?>(),
      );
      _ownsService = true;
    }
    // G6 — the world's discovered palette becomes the chat bots' brain
    // source, and the daemon's liveness becomes the defer law's input.
    _service.resolveCastRung = _worldState.castDeclFor;
    _service.daemonLiveGetter = () => _worldState.daemonLive;
    unawaited(_service.ensureReady());
    // First entry (the chat-first projection): the shell asks the
    // service to seed the world's first channel ONCE at boot — a fresh
    // world then lands in the seeded #general through the existing
    // boot-restore/sync laws, never in a blank void. Fire-and-forget:
    // the chrome never waits on seeding.
    unawaited(
      _service.ensureReady().then((final _) {
        if (mounted) return _service.ensureSeededChannel();
      }),
    );
    // 2e — the ACP agent detection runs ONCE per app run on desktop (the
    // picker's bridge row renders the availability FACT; discovery never
    // executes an agent, and the flow re-checks before it binds).
    if (PlatformInfo.isNativeDesktop) {
      unawaited(AcpBridgeRegistry.detectAgents());
    }
    _service.addListener(_onServiceChanged);
    unawaited(_startLaWorld());
    // Phase 1d: the world's ambient poll (the doctor/journal/registry
    // pass behind the status edge). The shell polls only the service it
    // OWNS — an injected one (tests, a future root DI) manages its own
    // cadence, so a test binding never leaves a pending timer.
    if (_ownsWorldState) _worldState.startPolling();
    unawaited(_restoreLayout());
    unawaited(
      _miniWindowPersistence.restoreInto(_miniWindows, _miniWindowSpec),
    );
    _miniWindowPersistence.bind(_miniWindows);
    FocusManager.instance.addListener(_onPrimaryFocusChanged);
  }

  /// Focus fell to nothing (a click on non-focusable chrome): the
  /// shell's anchor takes it back so ⌘T/⌘W/K keep answering. A text
  /// field holding focus is never stolen (primaryFocus is non-null).
  void _onPrimaryFocusChanged() {
    if (!mounted) return;
    if (FocusManager.instance.primaryFocus == null) {
      _shellFocus.requestFocus();
    }
  }

  /// A pointer came up somewhere that is not a text field: the shell's
  /// anchor reclaims primary focus so the strip keyboard keeps
  /// answering (the `⌘T handled:false` class — focus stranded on a
  /// popped route's node or on chrome that never took it). Editable
  /// descendants keep their focus: typing is never stolen.
  void _reclaimFocusUnlessEditing() {
    if (!mounted) return;
    final current = FocusManager.instance.primaryFocus;
    if (current == _shellFocus) return;
    final context0 = current?.context;
    if (context0 != null &&
        (context0.widget is EditableText ||
            context0.findAncestorWidgetOfExactType<EditableText>() != null)) {
      return;
    }
    _shellFocus.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _installAgentDocSeams();
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onPrimaryFocusChanged);
    _shellFocus.dispose();
    _service.removeListener(_onServiceChanged);
    _laWorldFeed?.stop();
    _laWorld?.dispose();
    if (_ownsWorldState) _worldState.dispose();
    // The owned service LAST: the LaWorld fold rides its world, and its
    // journal-watch debounce timer dies with it (teardown invariant).
    if (_ownsService) _service.dispose();
    _peopleFocus.dispose();
    _miniWindowPersistence.dispose();
    _miniWindows.dispose();
    super.dispose();
  }

  /// 1a — starts the LaWorld fold once the chat service has resolved
  /// the world and the human identity (the receipts fold needs the
  /// stable human id). The store rides the SERVICE's world — never
  /// `RealmWorld.open()` — so hermetic overrides flow and the real
  /// realm singleton is untouched by tests.
  Future<void> _startLaWorld() async {
    await _service.ensureReady();
    if (!mounted) return;
    final world = _service.world;
    if (world == null) return;
    String humanId() => _service.humanActorId ?? '';
    final laWorld = LaWorld(humanActorId: humanId);
    final feed = LaWorldFeed(
      store: world.store,
      laWorld: laWorld,
      humanActorId: humanId,
    );
    _laWorld = laWorld;
    _laWorldFeed = feed;
    await feed.start();
    if (mounted) setState(() {});
  }

  // ---- the dissolved home face's seams (load-bearing; tests pump them) --

  /// Task H — the multiplayer wiring over the LIVE mesh replica
  /// (attached in `StorageBackendsNotifier.ensureMeshService`): the
  /// app-level [DocReplicaStore] + [ActorRoster] seams, exposed to the
  /// agent-doc surface as one typed contract. Moved here verbatim from
  /// the dissolved HomeScreen (ADR 0024 §4).
  AgentDocMeshWiring _agentDocMeshWiring() {
    final notifier = StorageBackendsNotifier.instance;
    return AgentDocMeshWiring(
      routerFor: (final docId) {
        final service = notifier.meshService;
        final store = notifier.docReplicaStore;
        if (service == null || store == null) {
          throw StateError('mesh replica is not live on this device');
        }
        return PermissionDocRouter(
          store: store,
          docId: docId,
          selfId: service.selfId,
        );
      },
      // Presence follows doc sessions (ADR 0031 §1). Mesh setup is never
      // started as a side effect of opening a doc: only a LIVE replica is
      // joined.
      joinDoc: (final docId) async {
        final service = notifier.meshService;
        if (service == null) return;
        await service.joinDoc(docId);
      },
      leaveDoc: (final docId) async {
        await notifier.meshService?.leaveDoc(docId);
      },
      statusFor: (final docId) {
        final service = notifier.meshService;
        return AgentDocMeshStatus(
          hosting: service?.isHosting ?? false,
          connected: service?.isConnected ?? false,
          peerCount: service?.peers.length ?? 0,
          presenceCount: service?.presence(docId).length ?? 0,
        );
      },
      // PLAN 6.C — the mesh task console seams: the shared board mounted
      // with the live replica (null until mesh is set up), and THIS
      // device's peer id — the identity that keeps a device from
      // auto-running its own dispatches.
      taskBoard: () => notifier.taskBoard,
      selfPeerId: () => notifier.meshService?.selfId,
    );
  }

  /// The agent-doc + mesh seams the home screen used to install on every
  /// build; installed once per shell now. The meaning-experiment hook
  /// runs in every build mode; the agent-driven seams stay under the
  /// debug/profile guard that registers the MCP entries (same as before).
  void _installAgentDocSeams() {
    if (_seamsInstalled) return;
    _seamsInstalled = true;
    // The FILESYSTEM view reads the workspace registry's folders (ADR
    // 0026) through the provider tree; the notifier is the DI one
    // (nullable read: hermetic test shells without DI keep the view's
    // honest empty state).
    final workspaces = context.read<WorkspaceNotifier?>();
    if (workspaces != null) {
      unawaited(workspaces.ensureLoaded());
    }
    AgentDocSurface.createMeaningExperimentHook = () =>
        openMeaningExperiment(context);
    assert(() {
      // R9.a — the `agent_doc_create` intent routes create+open through
      // the app's own path (OpenedProjectNotifier.createAgentProject,
      // including the route push).
      AgentDocSurface.createAgentProjectHook = () {
        final opened = context.read<OpenedProjectNotifier>()
          ..createAgentProject(context);
        return opened.value.value as ProjectModelDoc;
      };
      // Task H — the multiplayer seams become live: the doc surface reads
      // the mesh status, joins/leaves presence per doc session, and (when
      // the user enables routing in PROFILE) reaches the mesh-attached
      // doc replica store. After every sync cycle the open surface
      // re-reads the fold (a peer's routed permission answer arrives with
      // the sync).
      AgentDocSurface.meshWiring = _agentDocMeshWiring();
      // Multiplayer chat: chat docs route to the SAME mesh-attached
      // replica store (convergence over the LAN mesh), and the open chat
      // surface re-reads the fold after every cycle.
      hc.MeshAwareDocumentRepository.replicaStoreGetter = () =>
          StorageBackendsNotifier.instance.docReplicaStore;
      StorageBackendsNotifier.onSyncCycle = () {
        AgentDocSurface.debugSurface?.refreshAfterMeshSync();
      };
      return true;
    }(), 'agent-doc mesh seams installed under the debug guard');
  }

  // ---- layout persistence -------------------------------------------------

  /// Restores the persisted layout; a corrupt blob keeps the default
  /// (the model decodes tolerantly, so does the shell). The migration
  /// chain runs once, newest key first: v4 reads as-is; a v3 per-view
  /// blob flattens into ONE group (v3 had no splits); a v2/v1 blob (one
  /// global bar + pins) flattens likewise; else the retired pane-tree
  /// blob's leaves flatten in document order. The v4 key is written;
  /// legacy keys stay on disk but are never read again.
  Future<void> _restoreLayout() async {
    final prefs = await SharedPreferences.getInstance();
    // The projection switch restores beside the layout: an explicit
    // undock survives the restart; absence keeps the chat-first default.
    final docked = prefs.getBool(kRoomsDockedPrefsKey);
    if (docked != null && docked != _roomsDocked && mounted) {
      setState(() => _roomsDocked = docked);
    }
    final raw = prefs.getString(kViewLayoutPrefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (mounted) {
          setState(() => _layout = ShellLayout.fromJson(decoded));
        }
      } on Object {
        // Unreadable persisted state never takes the shell down.
      }
      _restorePersistedConversationTab();
      return;
    }
    for (final legacyKey in [
      kViewLayoutV3PrefsKey,
      kViewLayoutV2PrefsKey,
      kCenterTabsPrefsKey,
    ]) {
      final legacy = prefs.getString(legacyKey);
      if (legacy == null || legacy.isEmpty) continue;
      try {
        final migrated = ShellLayout.fromJson(jsonDecode(legacy));
        if (mounted) setState(() => _layout = migrated);
        await prefs.setString(
          kViewLayoutPrefsKey,
          jsonEncode(migrated.toJson()),
        );
      } on Object {
        // An unreadable legacy blob keeps the default layout.
      }
      _restorePersistedConversationTab();
      return;
    }
    final legacyTree = prefs.getString(kLegacyPaneTreePrefsKey);
    if (legacyTree == null || legacyTree.isEmpty) return;
    try {
      final ids = legacyPaneTreeSurfaceIds(jsonDecode(legacyTree));
      if (ids.isEmpty || !mounted) return;
      final migrated = ShellLayout.fromJson(<String, Object?>{'tabs': ids});
      setState(() => _layout = migrated);
      await prefs.setString(kViewLayoutPrefsKey, jsonEncode(migrated.toJson()));
    } on Object {
      // An unreadable legacy tree keeps the default layout.
    }
    _restorePersistedConversationTab();
  }

  void _onLayoutChanged(final ShellLayout layout) {
    if (layout == _layout) return;
    setState(() => _layout = layout);
    _persistLayout(layout);
  }

  void _persistLayout(final ShellLayout layout) {
    unawaited(
      SharedPreferences.getInstance().then(
        (final prefs) =>
            prefs.setString(kViewLayoutPrefsKey, jsonEncode(layout.toJson())),
      ),
    );
  }

  /// The service's sync law (v4): the room the human is IN always has a
  /// tab — but the user's focus is the user's. A thread selection the
  /// layout already shows changes nothing (v3 re-slotted and could
  /// steal focus on any notify); only a room WITHOUT a tab opens one.
  void _onServiceChanged() {
    if (!mounted) return;
    final surfaceId = conversationSurfaceId(
      activeThreadId: _service.activeThreadId,
      channels: _service.channels,
      actors: _service.roster?.all ?? const <ActorProfile>[],
      dmThreadOf: _service.dmThreadOf,
    );
    if (surfaceId == null) {
      _restorePersistedConversationTab();
      return;
    }
    if (_layout.groupOf(surfaceId) < 0) {
      _onLayoutChanged(_routeOpen(_layout, surfaceId));
    }
  }

  /// Boot restore: the layout persists its active conversation tab, but
  /// the service boots with NO selected thread — the tab would sit on
  /// the calm empty note until the first click. Once, when the rail
  /// object behind the active id is known and the service is ready,
  /// re-select it. Unknown objects never retry (and never CREATE a
  /// thread for them — openDm would).
  void _restorePersistedConversationTab() {
    if (_service.activeThreadId != null || !_service.isReady) return;
    final id = _layout.activeSurfaceId;
    if (!id.startsWith('dm:') &&
        !id.startsWith('channel:') &&
        !id.startsWith('room:')) {
      return;
    }
    if (_bootRestoredId == id) return;
    final dmActor = id.startsWith('dm:') ? id.substring('dm:'.length) : null;
    final channelId = id.startsWith('channel:')
        ? id.substring('channel:'.length)
        : null;
    final roomThread = id.startsWith('room:')
        ? id.substring('room:'.length)
        : null;
    final known =
        (dmActor != null && _service.roster?.get(dmActor) != null) ||
        (channelId != null &&
            _service.channels.any(
              (final channel) => channel.channelId == channelId,
            )) ||
        (roomThread != null && _service.knowsThread(roomThread));
    _bootRestoredId = id;
    if (!known) return;
    activateConversationSurface(_service, id);
  }

  // ---- actions -------------------------------------------------------------

  /// The conversation header's intent: show me this actor. The dock
  /// retired, so the people view appears as its own tab.
  void _onFocusActorIntent(final String actorId) {
    _peopleFocus.focus(actorId);
    _onLayoutChanged(_routeOpen(_layout, kPeopleSurfaceId));
  }

  /// ADR 0027 — a tab's context-menu affordance: a conversation in its
  /// own floating window. v1 content is the read-only peek (who is in
  /// it, the last word — [PinnedConversationPeek]); a DM without a
  /// thread yet is opened first (idempotent), a conversation that maps
  /// to no thread stays unopened. Replying stays in the main surface.
  void _openMiniWindow(final String surfaceId) {
    unawaited(() async {
      if (surfaceId.startsWith('dm:')) {
        await _service.openDm(surfaceId.substring('dm:'.length));
      }
      final spec = _miniWindowSpec(surfaceId);
      if (spec != null) _miniWindows.open(spec);
    }());
  }

  /// A tab's right-click (or long-press): the window presentation for
  /// conversation tabs — the miniwindow (ADR 0027). Other kinds have no
  /// context actions yet (honest absence: no menu).
  void _onTabContext(final String surfaceId, final Offset globalPosition) {
    if (_miniWindowSpec(surfaceId) == null &&
        !surfaceId.startsWith('dm:') &&
        !surfaceId.startsWith('channel:') &&
        !surfaceId.startsWith('room:')) {
      return;
    }
    unawaited(() async {
      final overlay =
          Overlay.of(context).context.findRenderObject()! as RenderBox;
      final choice = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          globalPosition.dx,
          globalPosition.dy,
          overlay.size.width - globalPosition.dx,
          overlay.size.height - globalPosition.dy,
        ),
        items: [
          PopupMenuItem<String>(
            value: 'miniwindow',
            child: Text(context.l10n.railRowMiniwindow),
          ),
        ],
      );
      if (choice == 'miniwindow') _openMiniWindow(surfaceId);
    }());
  }

  /// The miniwindow behind a conversation surface id, null when the id
  /// maps to no live thread (the same vocabulary as the strips).
  /// The persistence lane re-resolves persisted ids through this on
  /// boot — a ghost id restores as nothing.
  MiniWindowSpec? _miniWindowSpec(final String surfaceId) {
    final dmActor = surfaceId.startsWith('dm:')
        ? surfaceId.substring('dm:'.length)
        : null;
    final channelId = surfaceId.startsWith('channel:')
        ? surfaceId.substring('channel:'.length)
        : null;
    final roomThread = surfaceId.startsWith('room:')
        ? surfaceId.substring('room:'.length)
        : null;
    final threadId =
        roomThread ??
        (dmActor != null
            ? _service.dmThreadOf(dmActor)
            : _service.channels
                  .where((final channel) => channel.channelId == channelId)
                  .map((final channel) => channel.threadId)
                  .firstOrNull);
    if (threadId == null) return null;
    final title =
        conversationSurfaceTitle(
          surfaceId,
          channels: _service.channels,
          actors: _service.roster?.all ?? const <ActorProfile>[],
          topicOf: _service.topicOf,
        ) ??
        surfaceId;
    return MiniWindowSpec(
      id: surfaceId,
      title: title,
      builder: (final context) =>
          PinnedConversationPeek(service: _service, threadId: threadId),
    );
  }

  /// Phase 1e — settings-as-view: the gear opens the settings surface
  /// as a TAB of the active group (the embedded seam closes through
  /// the view scope). The shell grammar keeps zero exceptions: no
  /// route push, no `Navigator.pop` from inside a view.
  void _openSettings() =>
      _onLayoutChanged(_routeOpen(_layout, kSettingsSurfaceId));

  /// The status edge's backend click (phase 1d): the Models surface
  /// opens as a tab of the ACTIVE group (any pane may host any surface).
  void _openModelsTab() =>
      _onLayoutChanged(_routeOpen(_layout, kModelsSurfaceId));

  /// The status edge's attention click: the conversations world face,
  /// whose landing state is the inbox (open permissions reject-first,
  /// running tasks, last verdicts).
  void _openInbox() {
    _service.clearActiveThread();
    _onLayoutChanged(_routeOpen(_layout, kConversationsSurfaceId));
  }

  /// The action bar's actors button: toggles the rooms-column dock and
  /// persists the projection choice (chat-first is the first-entry
  /// default). The layout document is untouched — the column is chrome,
  /// never a tab.
  void _toggleRoomsDock() {
    setState(() => _roomsDocked = !_roomsDocked);
    unawaited(
      SharedPreferences.getInstance().then(
        (final prefs) => prefs.setBool(kRoomsDockedPrefsKey, _roomsDocked),
      ),
    );
  }

  /// The ONE tab router (the chat-first projection law): every open
  /// path rides it, so the two projections can never drift apart.
  /// UNDOCKED: byte-identical to the legacy `openTab` — the active
  /// group hosts, an open id focuses where it lives. DOCKED:
  /// conversation-family ids (`dm:`, `channel:`, `room:`, the world
  /// face) belong to group 0; any other id is a VIEW tab — with one
  /// group, the pure v4 ops compose (`openTab` then `split`) into a new
  /// right-hand group; with several, the active view group hosts it
  /// (never group 0 — the conversation group stays the conversation's).
  ShellLayout _routeOpen(final ShellLayout layout, final String surfaceId) {
    if (!_roomsDocked) return layout.openTab(surfaceId);
    if (isConversationSurfaceId(surfaceId)) {
      return layout.openTab(surfaceId, group: 0);
    }
    // An open id never duplicates — it focuses where it lives.
    if (layout.groupOf(surfaceId) >= 0) return layout.openTab(surfaceId);
    if (layout.groups.length == 1) {
      return layout.openTab(surfaceId).split();
    }
    return layout.openTab(
      surfaceId,
      group: layout.active > 0 ? layout.active : 1,
    );
  }

  /// The docked close law: group 0 is the front door — closing its LAST
  /// tab never removes the group, it lands on the conversations world
  /// face. View groups fold/remove exactly as the pure v4 op does, and
  /// undocked [ShellLayout.closeTab] runs unchanged (the sole-group
  /// front-door floor already lives in the model).
  ShellLayout _routeClose(final ShellLayout layout, final String surfaceId) {
    if (!_roomsDocked ||
        layout.groups.length < 2 ||
        layout.groupOf(surfaceId) != 0 ||
        layout.groups[0].tabs.length != 1) {
      return layout.closeTab(surfaceId);
    }
    final groups = List<ViewState>.of(layout.groups)
      ..[0] = ViewState(tabs: const <String>[kConversationsSurfaceId]);
    return ShellLayout(groups: groups, active: layout.active);
  }

  // ---- the strips' keyboard (the browser map) -----------------------------

  /// The strip keyboard map: ⌘T opens the picker on the ACTIVE group;
  /// ⌘W closes its focused tab; ⌘\ splits (the VS Code muscle memory);
  /// ⌘K is the command palette. The modifier is chosen per platform —
  /// meta on macOS, ctrl elsewhere — so the map never shadows a text
  /// field's editing bindings. Escape closes the picker while it is
  /// open (and only then — the map is rebuilt per state).
  Map<ShortcutActivator, Intent> _viewTabShortcuts() {
    final useMeta = defaultTargetPlatform == TargetPlatform.macOS;
    return <ShortcutActivator, Intent>{
      if (useMeta)
        const SingleActivator(LogicalKeyboardKey.keyT, meta: true):
            const _NewTabIntent(),
      if (useMeta)
        const SingleActivator(LogicalKeyboardKey.keyW, meta: true):
            const _CloseActiveTabIntent(),
      if (useMeta)
        const SingleActivator(LogicalKeyboardKey.backslash, meta: true):
            const _SplitIntent(),
      if (!useMeta)
        const SingleActivator(LogicalKeyboardKey.keyT, control: true):
            const _NewTabIntent(),
      if (!useMeta)
        const SingleActivator(LogicalKeyboardKey.keyW, control: true):
            const _CloseActiveTabIntent(),
      if (!useMeta)
        const SingleActivator(LogicalKeyboardKey.backslash, control: true):
            const _SplitIntent(),
      // Phase 2 — the ⌘K command palette over the unified search.
      if (useMeta)
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            const _PaletteIntent(),
      if (!useMeta)
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            const _PaletteIntent(),
      if (_pickerOpen)
        const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
    };
  }

  void _openPalette() {
    if (_paletteOpen) return;
    setState(() => _paletteOpen = true);
  }

  void _closePalette() {
    if (!_paletteOpen) return;
    setState(() => _paletteOpen = false);
    _shellFocus.requestFocus();
  }

  /// The `+`/⌘T flow: the picker menu toggles on the given group's `+`
  /// (ONE picker — a second `+` re-anchors it, the mockup's bindPlus
  /// law).
  void _togglePicker(final int group) {
    setState(() {
      if (_pickerOpen && _pickerGroup == group) {
        _pickerOpen = false;
      } else {
        _pickerOpen = true;
        _pickerGroup = group;
      }
    });
  }

  void _closePicker() {
    if (!_pickerOpen) return;
    setState(() => _pickerOpen = false);
  }

  /// The palette's unified search: views (action bar + fact surfaces),
  /// people, channels and shell actions — one list, keyboard-first.
  List<CommandEntry> _paletteEntries(final SurfaceRegistry surfaces) {
    final l10n = context.l10n;
    return <CommandEntry>[
      for (final spec in _viewSpecs(surfaces))
        CommandEntry(
          id: 'view.${spec.id}',
          label: spec.title,
          group: 'views',
          icon: spec.icon,
          // The palette is DETERMINISTIC: picking a view opens (or
          // focuses) the view's OWN face tab — through the ONE router.
          run: () => _onLayoutChanged(_routeOpen(_layout, spec.id)),
        ),
      CommandEntry(
        id: 'view.$kModelsSurfaceId',
        label: surfaces[kModelsSurfaceId]?.title ?? l10n.viewModelsTitle,
        group: 'views',
        icon: Icons.tune,
        run: _openModelsTab,
      ),
      CommandEntry(
        id: 'view.$kSettingsSurfaceId',
        label: surfaces[kSettingsSurfaceId]?.title ?? l10n.settings,
        group: 'views',
        icon: Icons.settings_outlined,
        run: _openSettings,
      ),
      for (final actor in _service.roster?.all ?? const <ActorProfile>[])
        CommandEntry(
          id: 'dm.${actor.actorId}',
          label: actor.displayName,
          group: 'people',
          run: () => _onSelectTab('dm:${actor.actorId}'),
        ),
      for (final channel in _service.channels)
        CommandEntry(
          id: 'channel.${channel.channelId}',
          label: '#${channel.name}',
          group: 'channels',
          run: () => _onSelectTab('channel:${channel.channelId}'),
        ),
      for (final thread in _service.roomThreads)
        CommandEntry(
          id: 'room.${thread['threadId']}',
          label: '${thread['topic'] ?? thread['threadId']}',
          group: 'rooms',
          icon: Icons.forum_outlined,
          run: () => _onSelectTab('room:${thread['threadId']}'),
        ),
      CommandEntry(
        id: 'action.newTab',
        label: l10n.newTabPageTitle,
        group: 'actions',
        icon: Icons.add,
        run: _openNewTab,
      ),
      CommandEntry(
        id: 'action.models',
        label: l10n.viewModelsTitle,
        group: 'actions',
        icon: Icons.tune,
        run: _openModelsTab,
      ),
      CommandEntry(
        id: 'action.inbox',
        label: l10n.actionLandingInbox,
        group: 'actions',
        icon: Icons.inbox_outlined,
        run: _openInbox,
      ),
      CommandEntry(
        id: 'action.armWorld',
        label: l10n.edgeArmWorld,
        group: 'actions',
        icon: Icons.power_settings_new,
        run: () => unawaited(_worldState.armWorld()),
      ),
    ];
  }

  /// The ⌘T flow: the picker on the ACTIVE group's `+`.
  void _openNewTab() => _togglePicker(_layout.active);

  /// The ⌘W flow: the active group's focused tab closes (the close law
  /// applies — the last tab of a group removes it, the sole group lands
  /// on the world face).
  void _closeActiveTab() => _onCloseTab(_layout.activeSurfaceId);

  /// A tab's ✕ (or ⌘W): closing a ROOM's tab also leaves the room —
  /// otherwise the service's active thread would re-open the tab on the
  /// next notify (the ensure-exists law must never resurrect what the
  /// human closed).
  void _onCloseTab(final String surfaceId) {
    if (surfaceId.startsWith('dm:') ||
        surfaceId.startsWith('channel:') ||
        surfaceId.startsWith('room:')) {
      final mapped = conversationSurfaceId(
        activeThreadId: _service.activeThreadId,
        channels: _service.channels,
        actors: _service.roster?.all ?? const <ActorProfile>[],
        dmThreadOf: _service.dmThreadOf,
      );
      if (mapped == surfaceId) _service.clearActiveThread();
    }
    _onLayoutChanged(_routeClose(_layout, surfaceId));
  }

  /// A strip tab tap (and the rooms column's row tap — one path):
  /// conversation tabs re-select their thread (the service is the
  /// source of truth for WHAT the room shows; openDm/selectChannel are
  /// idempotent — the reverse mapping in [_onServiceChanged] then
  /// re-enters as a no-op); every tab focuses where it lives through
  /// the ONE router.
  void _onSelectTab(final String surfaceId) {
    activateConversationSurface(_service, surfaceId);
    _onLayoutChanged(_routeOpen(_layout, surfaceId));
  }

  /// The strip's split control (group 0): the active tab moves into a
  /// new pane to the right (the mockup law).
  void _onSplit() => _onLayoutChanged(_layout.split());

  /// A native drag landed on a strip: the tab reorders inside its group
  /// or moves into another one ([ShellLayout.moveTabTo] decides — the
  /// shell only commits). [at] null = append to the strip's end.
  void _onMoveTab(final String tabId, final int group, final int? at) =>
      _onLayoutChanged(
        _layout.moveTabTo(tabId: tabId, group: group, at: at),
      );

  /// A native drag landed on a pane's dashed edge: the tab splits into
  /// a NEW group at that position ([ShellLayout.splitTabAt] decides —
  /// refusals are no-ops the commit swallows).
  void _onSplitTab(final String tabId, final int index, final bool after) =>
      _onLayoutChanged(
        _layout.splitTabAt(tabId: tabId, index: index, after: after),
      );

  /// A trailing pane's fold control: its tabs merge back left.
  void _onFold(final int group) => _onLayoutChanged(_layout.fold(group: group));

  void _onBack(final int group) => _onLayoutChanged(_layout.back(group: group));

  void _onForward(final int group) =>
      _onLayoutChanged(_layout.forward(group: group));

  /// Identity marks for conversation tabs (the strip's pills): the
  /// actor's avatar for `dm:`, the channel's `#` disc for `channel:`;
  /// static views carry their registry icon.
  Widget? _leadingFor(final String surfaceId) {
    if (surfaceId.startsWith('dm:')) {
      final actorId = surfaceId.substring('dm:'.length);
      final profile = _service.roster?.get(actorId);
      if (profile == null) return null;
      return ActorAvatar(profile: profile, size: _kIdentityMarkSize);
    }
    if (surfaceId.startsWith('channel:')) {
      return SizedBox(
        width: _kIdentityMarkSize,
        height: _kIdentityMarkSize,
        child: Center(
          child: Text(
            '#',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.shellMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    if (surfaceId.startsWith('room:')) {
      // A watchable room (1d): the forum mark — a room that is nobody's
      // DM and no registered channel still deserves an identity.
      return SizedBox(
        width: _kIdentityMarkSize,
        height: _kIdentityMarkSize,
        child: Icon(
          Icons.forum_outlined,
          size: _kIdentityMarkSize,
          color: context.shellMuted,
        ),
      );
    }
    return null;
  }

  static const double _kIdentityMarkSize = 14;

  /// 2a — the picker's code-file creation flow: persist through the
  /// registry's own update lane, then open the doc's tab (the same
  /// composition the documents view's button rides).
  Future<void> _createCodeFile() async {
    final projects = _projects;
    if (projects == null) return;
    final doc = ProjectModel.emptyCode();
    await projects.updateProject(doc);
    projects.onReset();
    if (!mounted) return;
    _onLayoutChanged(_routeOpen(_layout, 'doc:${doc.id}'));
  }

  /// The `doc:<id>` tab's title: the registry's loaded projection of the
  /// document (phase 3a); an unloaded id keeps its honest raw id.
  String? _documentTitle(final String id) {
    final projects = _projects;
    if (!isDocumentSurfaceId(id)) return null;
    final docId = id.substring('doc:'.length);
    final item = projects?.projectsPagedController.items.firstWhereOrNull(
      (final project) => '${project.id}' == docId,
    );
    if (item == null) return null;
    final title = projectTitleOf(item);
    return title.isEmpty ? null : title;
  }

  /// The kind list's ordered registry slice (the action bar's grammar):
  /// every static surface the bar fronts.
  List<SurfaceSpec> _viewSpecs(final SurfaceRegistry surfaces) => const [
    kConversationsSurfaceId,
    kDocumentsSurfaceId,
    kBoardsSurfaceId,
    kFilesystemSurfaceId,
    kBrowserSurfaceId,
    kInspectorSurfaceId,
    kThreadsSurfaceId,
    kTerminalSurfaceId,
    kPeopleSurfaceId,
  ].map((final id) => surfaces[id]).whereType<SurfaceSpec>().toList();

  /// The picker's sections (the format registry enumerated): faces
  /// openable today, the rooms, the instance row, the creation flows,
  /// and the named runway rows as honest absences.
  List<NewTabSection> _pickerSections(final SurfaceRegistry surfaces) {
    final l10n = context.l10n;
    // Every row tap closes the picker first — a pick is a commitment.
    void tap(final VoidCallback open) {
      _closePicker();
      open();
    }

    return <NewTabSection>[
      NewTabSection(
        label: l10n.newTabSectionRooms,
        rows: <NewTabRow>[
          for (final actor in _service.roster?.all ?? const <ActorProfile>[])
            if (actor.kind != ActorKind.human)
              NewTabRow(
                key: 'newtab.entry.dm:${actor.actorId}',
                label: actor.displayName,
                leading: ActorAvatar(profile: actor, size: 16),
                onTap: () => tap(() => _onSelectTab('dm:${actor.actorId}')),
              ),
          for (final channel in _service.channels)
            NewTabRow(
              key: 'newtab.entry.channel:${channel.channelId}',
              label: '#${channel.name}',
              icon: Icons.tag,
              onTap: () =>
                  tap(() => _onSelectTab('channel:${channel.channelId}')),
            ),
          // 1d — the WATCHABLE ROOMS: actor↔actor threads and group
          // threads are rooms like any other; the human watches and
          // joins by addressing.
          for (final thread in _service.roomThreads)
            NewTabRow(
              key: 'newtab.entry.room:${thread['threadId']}',
              label: '${thread['topic'] ?? thread['threadId']}',
              icon: Icons.forum_outlined,
              onTap: () =>
                  tap(() => _onSelectTab('room:${thread['threadId']}')),
            ),
        ],
      ),
      NewTabSection(
        label: l10n.newTabSectionOpen,
        rows: <NewTabRow>[
          for (final spec in _viewSpecs(surfaces))
            NewTabRow(
              key: 'newtab.entry.${spec.id}',
              label: spec.title,
              icon: spec.icon,
              onTap: () =>
                  tap(() => _onLayoutChanged(_routeOpen(_layout, spec.id))),
            ),
          NewTabRow(
            key: 'newtab.entry.$kModelsSurfaceId',
            label: surfaces[kModelsSurfaceId]?.title ?? l10n.viewModelsTitle,
            icon: Icons.tune,
            onTap: () => tap(_openModelsTab),
          ),
          NewTabRow(
            key: 'newtab.entry.$kSettingsSurfaceId',
            label: surfaces[kSettingsSurfaceId]?.title ?? l10n.settings,
            icon: Icons.settings_outlined,
            onTap: () => tap(_openSettings),
          ),
        ],
      ),
      NewTabSection(
        label: l10n.newTabSectionInstances,
        rows: <NewTabRow>[
          NewTabRow(
            key: 'newtab.instance.$kBrowserSurfaceId',
            label: l10n.newTabBrowserInstance,
            icon: Icons.web,
            onTap: () => tap(() {
              final id = _layout.nextInstanceId(kBrowserSurfaceId);
              _onLayoutChanged(_routeOpen(_layout, id));
            }),
          ),
        ],
      ),
      NewTabSection(
        label: l10n.newTabSectionCreate,
        rows: <NewTabRow>[
          NewTabRow(
            key: 'newtab.create.actor',
            label: l10n.worldChatMenuMessageActor,
            icon: Icons.person_search_outlined,
            onTap: () => tap(
              () => unawaited(
                openMessageActorFlow(
                  context,
                  service: _service,
                  onOpenSettings: _openSettings,
                ),
              ),
            ),
          ),
          NewTabRow(
            key: 'newtab.create.channel',
            label: l10n.worldChatMenuNewChannel,
            icon: Icons.tag,
            onTap: () => tap(
              () => unawaited(openNewChannelFlow(context, service: _service)),
            ),
          ),
          NewTabRow(
            key: 'newtab.create.workspace',
            label: l10n.worldChatMenuNewWorkspace,
            icon: Icons.create_new_folder_outlined,
            onTap: () => tap(() => unawaited(openNewWorkspaceFlow(context))),
          ),
          // 2e — the ACP external-actor bridge (desktop only). The row
          // NAMES its own absence when unavailable (never a crash,
          // never a faked agent); a still-undetected desktop keeps the
          // row open and the flow re-checks detection honestly.
          () {
            final detected = AcpBridgeRegistry.detectedAgents.value;
            final availability =
                detected == null && PlatformInfo.isNativeDesktop
                ? AcpBridgeAvailability.available
                : acpBridgeAvailability(
                    AcpBridgeRegistry.detectedAgentIds(),
                    Platform.operatingSystem,
                  );
            return NewTabRow(
              key: 'newtab.create.acp',
              label: switch (availability) {
                AcpBridgeAvailability.available => 'acp · bridge an agent',
                AcpBridgeAvailability.noAgentsDetected =>
                  'acp · bridge — no agent detected',
                AcpBridgeAvailability.unsupportedPlatform =>
                  'acp · bridge — desktop only',
              },
              icon: Icons.hub_outlined,
              enabled: availability == AcpBridgeAvailability.available,
              onTap: availability == AcpBridgeAvailability.available
                  ? () => tap(
                      () => unawaited(
                        openAcpBridgeFlow(context, service: _service),
                      ),
                    )
                  : null,
            );
          }(),
          // 2a — the code format's creation flow: the registry's own
          // update lane, then the doc's tab (the documents view's twin).
          NewTabRow(
            key: 'newtab.create.code',
            label: l10n.documentsNewCodeFile,
            icon: Icons.code,
            onTap: () => tap(() => unawaited(_createCodeFile())),
          ),
          NewTabRow(
            key: 'newtab.create.actor-new',
            label: l10n.actorsCreateActor,
            icon: Icons.person_add_alt,
            onTap: () => tap(_openSettings),
          ),
        ],
      ),
      NewTabSection(
        label: l10n.newTabSectionRunway,
        rows: <NewTabRow>[
          NewTabRow(
            key: 'newtab.runway.image',
            label: l10n.newTabRunwayImage,
            enabled: false,
          ),
          NewTabRow(
            key: 'newtab.runway.video',
            label: l10n.newTabRunwayVideo,
            enabled: false,
          ),
          NewTabRow(
            key: 'newtab.runway.audio',
            label: l10n.newTabRunwayAudio,
            enabled: false,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(final BuildContext context) {
    AppShell.debugRootContext = context;
    final surfaces = buildShellSurfaces(context, service: _service);
    _projects = context.read<ProjectsNotifier?>();
    final screenLayout = ScreenLayout.of(context);
    // The small-screen branch keeps today's anatomy EXACTLY: neither
    // the bar nor the column renders — the projection switch is chrome
    // the small screen never had.
    final roomsDocked = _roomsDocked && !screenLayout.small;
    return ChangeNotifierProvider<RealmChatService>.value(
      value: _service,
      child: ChangeNotifierProvider<WorldStateService>.value(
        value: _worldState,
        // 1a — LaWorld: the reactive journal projection (null until
        // the fold starts; consumers render honest absence until then).
        child: Provider<LaWorld?>.value(
          value: _laWorld,
          child: ChangeNotifierProvider<PeopleFocus>.value(
            value: _peopleFocus,
            child: ViewScope(
              layout: _layout,
              surfaces: surfaces,
              onChanged: _onLayoutChanged,
              onFocusActor: _onFocusActorIntent,
              titleFor: (final id) =>
                  conversationSurfaceTitle(
                    id,
                    channels: _service.channels,
                    actors: _service.roster?.all ?? const <ActorProfile>[],
                    topicOf: _service.topicOf,
                  ) ??
                  _documentTitle(id),
              leadingFor: _leadingFor,
              child: Shortcuts(
                shortcuts: _viewTabShortcuts(),
                child: Actions(
                  actions: <Type, Action<Intent>>{
                    _NewTabIntent: CallbackAction<_NewTabIntent>(
                      onInvoke: (final _) {
                        _openNewTab();
                        return null;
                      },
                    ),
                    _CloseActiveTabIntent:
                        CallbackAction<_CloseActiveTabIntent>(
                          onInvoke: (final _) {
                            _closeActiveTab();
                            return null;
                          },
                        ),
                    _SplitIntent: CallbackAction<_SplitIntent>(
                      onInvoke: (final _) {
                        _onSplit();
                        return null;
                      },
                    ),
                    _PaletteIntent: CallbackAction<_PaletteIntent>(
                      onInvoke: (final _) {
                        _openPalette();
                        return null;
                      },
                    ),
                    DismissIntent: CallbackAction<DismissIntent>(
                      onInvoke: (final _) {
                        _closePicker();
                        return null;
                      },
                    ),
                  },
                  // The focus anchor: shell-level shortcuts answer even
                  // when no text field holds focus — the anchor takes it
                  // once at mount (an autofocus request loses to any
                  // already-focused descendant) and key events then
                  // bubble up through the map.
                  child: Focus(
                    autofocus: true,
                    focusNode: _shellFocus,
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerUp: (final _) => _reclaimFocusUnlessEditing(),
                      child: MiniWindowLayer(
                        controller: _miniWindows,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // DESIGN.md v2 — the title bar is gone:
                                // on macOS the window's LEFTMOST chrome
                                // is its top row — the docked rooms
                                // column's head when the chat-first
                                // projection is on, else the first
                                // group's strip (the traffic lights ride
                                // there), so no gutter is reserved here;
                                // other platforms keep their system
                                // inset.
                                SizedBox(
                                  height: MediaQuery.of(
                                    context,
                                  ).viewPadding.top,
                                ),
                                Expanded(
                                  child: screenLayout.small
                                      ? _paneColumn(_layout.active, surfaces)
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ActionBar(
                                              layout: _layout,
                                              actorsDocked: roomsDocked,
                                              onToggleActors: _toggleRoomsDock,
                                              onOpenSettings: _openSettings,
                                              onOpenPalette: _openPalette,
                                            ),
                                            // The chat-first projection:
                                            // the docked rooms column
                                            // (navigation chrome, never
                                            // a tab).
                                            if (roomsDocked) _roomsColumn(),
                                            Expanded(
                                              child: _panesRow(surfaces),
                                            ),
                                          ],
                                        ),
                                ),
                                // Phase 1d — the status edge: ONE
                                // honest line (mesh · backend · daemon ·
                                // attention) at the window bottom,
                                // spanning every layout branch; its
                                // clicks route into the surfaces that
                                // own the facts (Models tab, landing
                                // inbox, arm).
                                StatusEdge(
                                  world: _worldState,
                                  onOpenModels: _openModelsTab,
                                  onOpenInbox: _openInbox,
                                ),
                                SizedBox(
                                  height: MediaQuery.of(
                                    context,
                                  ).viewPadding.bottom,
                                ),
                              ],
                            ),
                            if (_paletteOpen)
                              CommandPalette(
                                entries: _paletteEntries(surfaces),
                                onClose: _closePalette,
                              ),
                            if (_pickerOpen)
                              ListenableBuilder(
                                // Rooms arrive async (the roster and the
                                // channel registry load after boot): the
                                // open picker re-renders with them.
                                listenable: _service,
                                builder: (final context, final _) => NewTabMenu(
                                  link: _pickerLink,
                                  sections: _pickerSections(surfaces),
                                  onClose: _closePicker,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The docked rooms column (chat-first projection): navigation
  /// chrome, never a tab. It rebuilds on every service notify — rooms
  /// arrive async and the column is never cached (the title-stuck bug
  /// law).
  Widget _roomsColumn() => ListenableBuilder(
    listenable: _service,
    builder: (final context, final _) => RoomsColumn(
      service: _service,
      onSelect: _onSelectTab,
      onCreateChannel: () => unawaited(
        openNewChannelFlow(context, service: _service),
      ),
      onMessageActor: () => unawaited(
        openMessageActorFlow(
          context,
          service: _service,
          onOpenSettings: _openSettings,
        ),
      ),
      onMiniWindow: _openMiniWindow,
      lightsGutter: defaultTargetPlatform == TargetPlatform.macOS,
    ),
  );

  /// The pane groups, left → right (the split anatomy: N groups = N
  /// strips, each owning its tabs). The plain divider is retired: every
  /// group column now carries its own 6px edge drop zones INSIDE its
  /// left/right sides (the mockup's dashed edges), so a boundary is the
  /// two adjacent zones' 12px seam — its hairline rides the right
  /// zone's outer edge. A tab dropped on an edge splits into a NEW
  /// group at that position; the outer window edges (left of group 0,
  /// right of the last group) split before the first / after the last.
  Widget _panesRow(final SurfaceRegistry surfaces) {
    final groups = _layout.groups;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var g = 0; g < groups.length; g++)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _paneEdge(g, after: false),
                Expanded(child: _paneColumn(g, surfaces)),
                _paneEdge(g, after: true, rule: g < groups.length - 1),
              ],
            ),
          ),
      ],
    );
  }

  /// ONE pane edge's split drop zone (keys `pane.drop.<group>.left` /
  /// `pane.drop.<group>.right`): accepts an open tab, splits it into a
  /// new group beside this one, and shows the dashed accent line while
  /// a drag hovers (shape + accent, never color alone). [rule] paints
  /// the resting hairline seam between two groups (the right zone owns
  /// it; outer window edges stay clean).
  Widget _paneEdge(
    final int group, {
    required final bool after,
    final bool rule = false,
  }) => DragTarget<String>(
    key: ValueKey('pane.drop.$group.${after ? 'right' : 'left'}'),
    onWillAcceptWithDetails: (final details) =>
        _layout.groupOf(details.data) >= 0,
    onAcceptWithDetails: (final details) =>
        _onSplitTab(details.data, group, after),
    builder: (final context, final hovering, final rejected) => CustomPaint(
      painter: _PaneEdgePainter(
        accent: hovering.isEmpty ? null : context.la.accent,
        rule: rule ? context.shellHairline : null,
      ),
      child: const SizedBox(width: 6),
    ),
  );

  /// ONE pane column (the chrome budget: one strip row, then content):
  /// the group's strip above its focused surface. The ACTIVE group's
  /// slot hosts the router navigator (GlobalKey-reparented, so pushed
  /// routes survive a group switch); the others render their surface
  /// directly.
  Widget _paneColumn(final int group, final SurfaceRegistry surfaces) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ListenableBuilder(
        // Rebuilt per service notify so title facts (roster, channels)
        // land without a layout change — never a cached widget instance
        // (the title-stuck bug law).
        listenable: _service,
        builder: (final context, final _) => PaneStrip(
          group: group,
          layout: _layout,
          surfaces: surfaces,
          onSelect: _onSelectTab,
          onClose: _onCloseTab,
          onNewTab: () => _togglePicker(group),
          onSplit: _onSplit,
          onFold: () => _onFold(group),
          onBack: () => _onBack(group),
          onForward: () => _onForward(group),
          onMoveTab: _onMoveTab,
          onTabContext: _onTabContext,
          titleFor: (final id) =>
              conversationSurfaceTitle(
                id,
                channels: _service.channels,
                actors: _service.roster?.all ?? const <ActorProfile>[],
                topicOf: _service.topicOf,
              ) ??
              _documentTitle(id),
          leadingFor: _leadingFor,
          pickerLink: _pickerLink,
          pickerOwner: _pickerOpen && _pickerGroup == group,
          // The title-bar-is-gone law (macOS): the window's leftmost
          // chrome carries the traffic lights — the docked rooms
          // column's head when the chat-first projection is on, else
          // group 0's strip (today's anatomy, unchanged).
          lightsGutter:
              group == 0 &&
              defaultTargetPlatform == TargetPlatform.macOS &&
              !(_roomsDocked && !ScreenLayout.of(context).small),
        ),
      ),
      Expanded(
        child: group == _layout.active
            ? KeyedSubtree(key: _navigatorKey, child: widget.child)
            : buildSurfaceFor(
                context,
                _layout.groups[group].activeId,
                surfaces,
              ),
      ),
    ],
  );
}

/// The strip's keyboard intents (the browser map, see
/// [_AppShellState._viewTabShortcuts]).
class _NewTabIntent extends Intent {
  const _NewTabIntent();
}

class _CloseActiveTabIntent extends Intent {
  const _CloseActiveTabIntent();
}

/// The split shortcut (⌘\ — the VS Code muscle memory).
class _SplitIntent extends Intent {
  const _SplitIntent();
}

/// Phase 2 — the ⌘K command palette intent.
class _PaletteIntent extends Intent {
  const _PaletteIntent();
}

/// The pane edge zone's paint: the resting hairline seam between two
/// groups, and the DASHED accent line while a tab drag hovers (the
/// mockup's split edge — dashes carry the meaning by shape, never by
/// color alone).
final class _PaneEdgePainter extends CustomPainter {
  const _PaneEdgePainter({this.accent, this.rule});

  /// Non-null while a drag hovers: the zone's dashed accent line.
  final Color? accent;

  /// Non-null on a group boundary: the 1px resting seam (the retired
  /// divider's honest remains, centered in the 12px seam).
  final Color? rule;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (rule != null) {
      canvas.drawLine(
        Offset(size.width, 0),
        Offset(size.width, size.height),
        Paint()
          ..color = rule!
          ..strokeWidth = 1,
      );
    }
    if (accent != null) {
      final paint = Paint()
        ..color = accent!
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final x = size.width / 2;
      var y = 6.0;
      while (y + 8 <= size.height - 6) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 8), paint);
        y += 14;
      }
    }
  }

  @override
  bool shouldRepaint(final _PaneEdgePainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.rule != rule;
}

/// Re-selects the thread behind a conversation surface id through the
/// service (the source of truth for the room's content). Fire-and-
/// forget: selection is idempotent, and the service's notification
/// re-enters `_onServiceChanged` as a no-op for an open tab.
void activateConversationSurface(
  final RealmChatService? service,
  final String surfaceId,
) {
  if (service == null) return;
  if (surfaceId.startsWith('dm:')) {
    unawaited(service.openDm(surfaceId.substring('dm:'.length)));
  } else if (surfaceId.startsWith('channel:')) {
    service.selectChannel(surfaceId.substring('channel:'.length));
  } else if (surfaceId.startsWith('room:')) {
    // A watchable room (1d): selection is the join — the human watches
    // from the same surface and speaks by addressing.
    service.selectThread(surfaceId.substring('room:'.length));
  }
}

/// The `/home` route body: the ACTIVE group's ACTIVE tab host. The
/// strip lives above it in the shell; the body only mounts the focused
/// surface. Pushed project routes render as full pages of the navigator
/// above it; the bar and the strips (and their state) survive the
/// round-trip.
final class CenterTabsArea extends StatelessWidget {
  const CenterTabsArea({super.key});

  @override
  Widget build(final BuildContext context) {
    final scope = ViewScope.of(context);
    if (scope == null) {
      // Honest absence: the area only makes sense inside the shell.
      return const Center(child: Text('center tabs require the app shell'));
    }
    return buildSurfaceFor(
      context,
      scope.layout.activeSurfaceId,
      scope.surfaces,
    );
  }
}
