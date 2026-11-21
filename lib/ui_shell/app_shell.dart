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

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, listEquals;
import 'package:headless_core/headless_core.dart' as hc;
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_agents/acp/acp_actor_bridge.dart';
import 'package:lastanswer/data_agents/acp/acp_bridge_registry.dart';
import 'package:lastanswer/data_agents/acp/acp_bridge_transport.dart';
import 'package:lastanswer/data_agents/acp/acp_provider.dart';
import 'package:lastanswer/data_agents/acp/acp_turn_worker.dart';
import 'package:lastanswer/data_agents/config/provider_configuration.dart';
import 'package:lastanswer/data_agents/config/subscription_provider.dart';
import 'package:lastanswer/data_agents/subscriptions/chatgpt_subscription_controller.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_subscription_controller.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/ecs_plugins/conversation/conversation_spaces.dart';
import 'package:lastanswer/ecs_world/world.dart';
import 'package:lastanswer/ecs_world/world_feed.dart';
import 'package:lastanswer/ui_automations/lens_surface.dart';
import 'package:lastanswer/ui_chat/actor_avatar.dart';
import 'package:lastanswer/ui_chat/actor_brain.dart';
import 'package:lastanswer/ui_chat/brain_provider_picker.dart';
import 'package:lastanswer/ui_chat/channel_members_ui.dart';
import 'package:lastanswer/ui_documents/agent_doc_surface.dart';
import 'package:lastanswer/ui_models/agent_config/agent_config_persistence.dart';
import 'package:lastanswer/ui_settings/ui_settings.dart';
import 'package:lastanswer/ui_shell/action_bar.dart';
import 'package:lastanswer/ui_shell/center_tabs.dart';
import 'package:lastanswer/ui_shell/command_palette.dart';
import 'package:lastanswer/ui_shell/create_flows.dart';
import 'package:lastanswer/ui_shell/miniwindows/mini_window.dart';
import 'package:lastanswer/ui_shell/miniwindows/mini_window_persistence.dart';
import 'package:lastanswer/ui_shell/new_tab_menu.dart';
import 'package:lastanswer/ui_shell/pane_strip.dart';
import 'package:lastanswer/ui_shell/pinned_conversation_peek.dart';
import 'package:lastanswer/ui_shell/rooms_column.dart';
import 'package:lastanswer/ui_shell/shell_layout.dart';
import 'package:lastanswer/ui_shell/shell_scope.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:lastanswer/ui_shell/status_edge.dart';
import 'package:lastanswer/ui_shell/surfaces.dart';
import 'package:lastanswer/ui_shell/view_documents.dart';
import 'package:lastanswer/ui_shell/view_people.dart';
import 'package:lastanswer/ui_workspaces/workspace_notifier.dart';
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

/// The SharedPreferences key holding the pane groups' width weights
/// (JSON list of relative flex weights, parallel to the layout's
/// `groups`; the drag-resize law). Beside the layout document — a drag
/// must never rewrite the tab layout per pointer move.
const String kPaneWeightsPrefsKey = 'shell.pane.weights.v1';

/// The SharedPreferences key holding the docked rooms column's dragged
/// width (px, double). Default: [ShellTokens.contextColumnWidth].
const String kRoomsColumnWidthPrefsKey = 'shell.rooms.width.v1';

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
  ChatGptSubscriptionController? _chatgptActors;
  GrokSubscriptionController? _grokActors;
  AgentConfigStore? _acpConfigStore;
  var _acpCatalogHooked = false;

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

  /// The pane groups' width weights (the drag-resize law): relative
  /// flex shares parallel to [_layout.groups] — 1.0 each by default
  /// (the equal-`Expanded` anatomy), dragged at the seams, persisted as
  /// [kPaneWeightsPrefsKey]. Presentation chrome BESIDE the layout
  /// document: a drag must never rewrite the tab layout doc per pointer
  /// move, and the weights never change which tabs live where.
  List<double> _paneWeights = const <double>[];

  /// The docked rooms column's width (px; the drag-resize law at its
  /// right edge), persisted as [kRoomsColumnWidthPrefsKey].
  double _roomsColumnWidth = ShellTokens.contextColumnWidth;

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
    // ACP model list: discovery never executes an agent. The host
    // embodies an `acp:` actor once a model is runnable.
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
    // Wave F — the shell's debug bridge (the `shell_*` fmtk lane): the
    // mounted shell assigns the ONE instance; kDebugMode-guarded so a
    // release tree carries nothing, and the tools refuse honestly
    // (`shell_bridge_absent`) while no shell is mounted.
    if (kDebugMode) {
      // Block bodies, NOT arrows: a multi-line arrow body swallows the
      // cascade sections that follow it into its own expression.
      ShellDebugBridge.instance = ShellDebugBridge()
        // ignore: prefer_expression_function_bodies
        ..docked = () {
          return _roomsDocked;
        }
        ..state = _debugShellState
        ..toggleDock = () async {
          _toggleRoomsDock();
        }
        ..openTab = _debugOpenTab
        ..closeTab = _debugCloseTab
        ..splitActive = _onSplit
        ..selectRoom = _debugSelectRoom;
    }
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
    _bindSubscriptionActors();
    _bindAcpActors();
  }

  /// Subscription plans are providers an actor can name (ADR 0031).
  /// The resolver reads the live controllers, and a later sign-in
  /// re-aligns the bot loops.
  void _bindSubscriptionActors() {
    final chatgpt = context.read<ChatGptSubscriptionController?>();
    final grok = context.read<GrokSubscriptionController?>();
    var changed = false;
    if (!identical(chatgpt, _chatgptActors)) {
      _chatgptActors?.removeListener(_onSubscriptionActors);
      _chatgptActors = chatgpt;
      chatgpt?.addListener(_onSubscriptionActors);
      changed = true;
    }
    if (!identical(grok, _grokActors)) {
      _grokActors?.removeListener(_onSubscriptionActors);
      _grokActors = grok;
      grok?.addListener(_onSubscriptionActors);
      changed = true;
    }
    _service.resolveSubscription = (final providerId, final model) =>
        subscriptionClientFor(
          providerId: providerId,
          model: model,
          chatgpt: _chatgptActors,
          grok: _grokActors,
        );
    if (changed) _service.syncBots();
  }

  void _onSubscriptionActors() {
    if (!mounted) return;
    _service.noteSubscriptionProvidersChanged();
  }

  /// Provider `acp` is an actor brain. The factory reads the live
  /// catalog (detected installs, then saved servers) at sync time.
  void _bindAcpActors() {
    _service.createAcpWorker = _acpWorkerFor;
    AgentConfigStore? store;
    try {
      store = context.read<AgentConfigStore>();
    } on Object {
      store = null;
    }
    if (!identical(store, _acpConfigStore)) {
      _acpConfigStore?.removeListener(_onAcpCatalogChanged);
      _acpConfigStore = store;
      store?.addListener(_onAcpCatalogChanged);
    }
    if (_acpCatalogHooked) return;
    _acpCatalogHooked = true;
    AcpBridgeRegistry.detectedAgents.addListener(_onAcpCatalogChanged);
    _service.syncBots();
  }

  void _onAcpCatalogChanged() {
    if (!mounted) return;
    _service.syncBots();
  }

  /// One ACP process for this actor, in a scratch directory. A missing
  /// model waits; the next catalog sync tries again. Never the device's
  /// first workspace folder.
  AcpTurnWorker? _acpWorkerFor(final ActorProfile actor) {
    if (!mounted) return null;
    final modelId = parseAcpBrainRef(actor.brainRef);
    if (modelId == null) return null;
    final world = _service.world;
    if (world == null) return null;
    AcpModelChoice? choice;
    for (final model in acpModelCatalog(
      detected: AcpBridgeRegistry.detectedAgents.value,
      servers: acpServersIn(context),
    )) {
      if (model.id == modelId) {
        choice = model;
        break;
      }
    }
    if (choice == null) return null;
    final store = _acpConfigStore;
    final environment = choice.environment.isEmpty
        ? null
        : <String, String>{
            for (final entry in choice.environment.entries)
              entry.key: store == null
                  ? entry.value
                  : store.expandEnv(entry.value).value,
          };
    final bridge = AcpActorBridge(
      actorId: actor.actorId,
      agentId: modelId,
      workingDirectory: acpActorWorkspace(actor.actorId),
      transport: AcpRuntimeBridgeTransport(
        config: AcpRuntimeConfig(
          command: choice.command,
          arguments: choice.arguments,
          environment: environment,
        ),
      ),
      world: world,
      hostDriven: true,
    );
    bridge.arm();
    return bridge;
  }

  @override
  void dispose() {
    // The bridge dies WITH the shell — never a stale static seam
    // pointing at a disposed state (Wave F).
    if (kDebugMode) ShellDebugBridge.instance = null;
    FocusManager.instance.removeListener(_onPrimaryFocusChanged);
    _shellFocus.dispose();
    _chatgptActors?.removeListener(_onSubscriptionActors);
    _grokActors?.removeListener(_onSubscriptionActors);
    _acpConfigStore?.removeListener(_onAcpCatalogChanged);
    if (_acpCatalogHooked) {
      AcpBridgeRegistry.detectedAgents.removeListener(_onAcpCatalogChanged);
    }
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
  /// build; installed once per shell now. The agent-driven seams stay
  /// under the debug/profile guard that registers the MCP entries (same
  /// as before).
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
      context.read<hc.DocReplicaStoreRef>().getter = () =>
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
    // The resize law's chrome restores beside the layout too: the pane
    // weights and the rooms column's width. An unusable blob keeps the
    // defaults (equal shares, the token width) — the same tolerant
    // decode the layout itself rides.
    final rawWeights = prefs.getString(kPaneWeightsPrefsKey);
    if (rawWeights != null && rawWeights.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawWeights);
        if (decoded is List) {
          final weights = <double>[
            for (final entry in decoded)
              if (entry is num) entry.toDouble(),
          ];
          if (weights.isNotEmpty && mounted) {
            setState(() => _paneWeights = weights);
          }
        }
      } on Object {
        // An unreadable blob keeps the equal shares.
      }
    }
    final rawWidth = prefs.getDouble(kRoomsColumnWidthPrefsKey);
    if (rawWidth != null && mounted) {
      setState(() {
        _roomsColumnWidth = rawWidth.clamp(
          ShellTokens.minRoomsColumnWidth,
          ShellTokens.maxRoomsColumnWidth,
        );
      });
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
    setState(() {
      _layout = layout;
      _paneWeights = _weightsAfter(layout);
    });
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

  // ---- drag resize (owner request 2026-11-18) -----------------------------
  //
  // The pane groups' seams and the docked rooms column's right edge are
  // drag handles. Pane widths are RELATIVE flex weights ([_paneWeights])
  // — 1.0 each by default, so the resting anatomy is the old equal
  // split. The weight laws ride the layout ops they accompany:
  // - a split (every path — the strip control, a dashed-edge tab drop,
  //   the router's first-view split) lands the NEW group at
  //   `next.active` and it takes HALF its left neighbour's weight (the
  //   new pane shares its source's width);
  // - a fold hands the folded group's weight to the merge target (the
  //   surviving pane keeps the combined width);
  // - a group close drops that group's weight (the remaining flexes
  //   re-share), and an emptied-source cross-group move moves the
  //   source's width WITH its lone tab;
  // - any other change length-normalizes (an unusable entry is 1.0).

  /// The weights for the layout [next]: growth (a split — the new
  /// group sits at `next.active`) half-splits the new group's left
  /// neighbour's weight; everything else length-normalizes.
  List<double> _weightsAfter(final ShellLayout next) {
    final w = List<double>.of(_paneWeights);
    if (next.groups.length > w.length) {
      final at = next.active;
      if (at >= 0 && at <= w.length) {
        final share = at > 0 ? w[at - 1] / 2 : 1.0;
        if (at > 0) w[at - 1] = share;
        w.insert(at, share);
      }
    }
    return _normalizedWeights(w, next.groups.length);
  }

  /// [weights] trimmed/padded to exactly [count] entries; unusable
  /// entries (non-finite, ≤ 0) fall back to the equal share 1.0.
  static List<double> _normalizedWeights(
    final List<double> weights,
    final int count,
  ) => <double>[
    for (var i = 0; i < count; i++)
      if (i < weights.length && weights[i].isFinite && weights[i] > 0)
        weights[i]
      else
        1.0,
  ];

  /// The weight for group [index] as the tree stands now (a missing or
  /// unusable entry is the equal share). Build-path safe.
  double _weightFor(final int index) {
    if (index >= 0 && index < _paneWeights.length) {
      final w = _paneWeights[index];
      if (w.isFinite && w > 0) return w;
    }
    return 1;
  }

  /// Commits [layout] together with explicit resize [weights] (null =
  /// the generic [_onLayoutChanged] law), persisting both documents.
  void _setLayoutWithWeights(
    final ShellLayout layout,
    final List<double>? weights,
  ) {
    if (weights == null) {
      _onLayoutChanged(layout);
      return;
    }
    final next = _normalizedWeights(weights, layout.groups.length);
    if (layout == _layout && listEquals(next, _paneWeights)) return;
    setState(() {
      _layout = layout;
      _paneWeights = next;
    });
    _persistLayout(layout);
    _persistPaneWeights();
  }

  /// ONE pane seam's drag: moves [dxPx] of real width from the group
  /// right of the seam into the group left of it ([left]; negative dx
  /// the other way). Both sides keep [ShellTokens.minPaneWidth] real
  /// pixels of CONTENT — plus each group's own two 6px edge zones —
  /// of [flexibleWidth], the panes row's full width (each group's
  /// Expanded share; at equal weights a dragged px moves the seam 1:1).
  /// Mid-drag this updates state only; the blob persists at drag end.
  void _onPaneResizeDrag(
    final int left,
    final double dxPx,
    final double flexibleWidth,
  ) {
    if (left < 0 || left + 1 >= _layout.groups.length) return;
    final current = _normalizedWeights(_paneWeights, _layout.groups.length);
    var sum = 0.0;
    for (final w in current) {
      sum += w;
    }
    if (sum <= 0 || flexibleWidth <= 0) return;
    final pxPerWeight = flexibleWidth / sum;
    final minWeight = (ShellTokens.minPaneWidth + 12.0) / pxPerWeight;
    // Manual clamp: in a window too small for two minimum panes the
    // bounds cross, and `num.clamp` refuses crossed bounds.
    final lo = minWeight - current[left];
    final hi = current[left + 1] - minWeight;
    var d = dxPx / pxPerWeight;
    if (d < lo) d = lo;
    if (d > hi) d = hi;
    final next = List<double>.of(current)
      ..[left] = current[left] + d
      ..[left + 1] = current[left + 1] - d;
    if (listEquals(next, current)) return;
    setState(() => _paneWeights = next);
  }

  void _persistPaneWeights() {
    unawaited(
      SharedPreferences.getInstance().then(
        (final prefs) =>
            prefs.setString(kPaneWeightsPrefsKey, jsonEncode(_paneWeights)),
      ),
    );
  }

  /// The rooms column's right-edge drag: real pixels, clamped to the
  /// token band; persisted at drag end like the pane weights.
  void _onRoomsResizeDrag(final double dxPx) {
    final next = (_roomsColumnWidth + dxPx).clamp(
      ShellTokens.minRoomsColumnWidth,
      ShellTokens.maxRoomsColumnWidth,
    );
    if (next == _roomsColumnWidth) return;
    setState(() => _roomsColumnWidth = next);
  }

  void _persistRoomsWidth() {
    unawaited(
      SharedPreferences.getInstance().then(
        (final prefs) =>
            prefs.setDouble(kRoomsColumnWidthPrefsKey, _roomsColumnWidth),
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
        (channelId != null && _service.channelByAnyId(channelId) != null) ||
        (roomThread != null && _service.knowsThread(roomThread));
    _bootRestoredId = id;
    if (!known) return;
    activateConversationSurface(_service, id);
  }

  // ---- actions -------------------------------------------------------------

  /// The conversation header's intent: show me this actor. Wave F
  /// owner law: the actor's INFO opens as its own `actor:<id>` tab
  /// through the ONE router (a split beside the conversation), never
  /// as an in-view face swap. [ViewScope.onFocusActor] stays the seam
  /// other callers ride.
  void _onFocusActorIntent(final String actorId) {
    _onLayoutChanged(_routeOpen(_layout, actorSurfaceId(actorId)));
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

  /// A tab's right-click (or long-press): the kit menu — the window
  /// presentation for conversation tabs (the miniwindow, ADR 0027) and,
  /// for EVERY tab kind, the close-all cleanup. Conversational-ness is
  /// the id-prefix fact (a `dm:` without a live thread still opens the
  /// window first — [_openMiniWindow] is idempotent).
  void _onTabContext(final String surfaceId, final Offset globalPosition) {
    final conversational =
        surfaceId.startsWith('dm:') ||
        surfaceId.startsWith('channel:') ||
        surfaceId.startsWith('room:');
    // The kit menu grammar (v6): the row carries its own activation and
    // the menu closes on choice.
    showLaMenuAt(
      context,
      globalPosition: globalPosition,
      entries: [
        if (conversational)
          LaMenuItem(
            label: context.l10n.railRowMiniwindow,
            onPressed: () => _openMiniWindow(surfaceId),
          ),
        if (conversational) const LaMenuSeparator(),
        LaMenuItem(
          key: const ValueKey('view.tab.ctx.closeAll'),
          label: context.l10n.stripCloseAllTabs,
          onPressed: _onCloseAllTabs,
        ),
      ],
    );
  }

  /// The miniwindow behind a conversation surface id, null when the id
  /// maps to no live thread (the same vocabulary as the strips).
  /// The persistence lane re-resolves persisted ids through this on
  /// boot — a ghost id restores as nothing.
  MiniWindowSpec? _miniWindowSpec(final String surfaceId) {
    // ADR 0010 phase 3: the lens rides the miniwindow layer too — the
    // ChatGPT-pattern floating pane over whatever the user is doing.
    if (surfaceId == kLensSurfaceId) {
      return MiniWindowSpec(
        id: kLensSurfaceId,
        title: 'Lens',
        builder: (final context) => const LensSurface(),
        initialSize: const Size(560, 420),
      );
    }
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
            : channelId == null
            ? null
            : _service.channelByAnyId(channelId)?.threadId);
    if (threadId == null) return null;
    final title =
        conversationSurfaceTitle(
          surfaceId,
          channels: _titleChannels,
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

  /// ADR 0032 — the automations surface opens as a tab of the active
  /// group, through the ONE router like every surface (no exceptions).
  void _openAutomations() =>
      _onLayoutChanged(_routeOpen(_layout, kAutomationsSurfaceId));

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

  /// The rooms column's "Change icon…" apply lane (Wave D): one service
  /// verb — the row write AND the registry mirror live in
  /// [RealmChatService.setChannelIcon] (the steward verb that collapsed
  /// this lane's original store-plus-rename workaround).
  Future<bool> _setChannelIcon(final String channelId, final String? icon) =>
      _service.setChannelIcon(channelId: channelId, icon: icon);

  /// ADR 0146 — the channel view the tab-title and miniwindow lookups
  /// resolve over: the row-built projection PLUS the registry's legacy
  /// rows (the W1 fallback). A persisted `channel:<registryId>` tab or
  /// miniwindow keeps resolving exactly as today — legacy tabs and
  /// references never die; the registry answer rides
  /// [RealmChatService.registryChannels] (empty after a W3 flip).
  Iterable<ChannelInfo> get _titleChannels => [
    ..._service.channels,
    ..._service.registryChannels,
  ];

  // ---- Wave F: the `shell_*` debug bridge's implementations -----------
  //
  // Thin verbs over the shell's OWN paths (the ONE router, the dock
  // law, the close law) — the bridge never grows a second layout
  // grammar. They exist so live fmtk iteration is deterministic (the
  // semantics walker's rail-drop is a known framework gap).

  /// The layout document's projection for `shell_state`: the dock bool,
  /// the pane groups with their tab ids, the active group and tab, and
  /// the resize law's chrome (the pane weights, the rooms width).
  Map<String, Object?> _debugShellState() => <String, Object?>{
    'docked': _roomsDocked,
    'activeGroup': _layout.active,
    'activeTab': _layout.activeSurfaceId,
    'paneWeights': List<double>.of(_paneWeights),
    'roomsColumnWidth': _roomsColumnWidth,
    'groups': <Object?>[
      for (final group in _layout.groups)
        <String, Object?>{
          'tabs': List<String>.of(group.tabs),
          'active': group.active,
          'activeTab': group.activeId,
        },
    ],
  };

  /// `shell_open_tab`: opens [id] through the shell's own routing (a
  /// conversation id re-selects its thread, exactly like a strip tap).
  /// [group] forces a pane group; [split] composes the pure v4 ops
  /// (openTab then split) so the tab lands in its own new right group.
  Future<bool> _debugOpenTab(
    final String id, {
    final int? group,
    final bool split = false,
  }) async {
    if (id.isEmpty) return false;
    activateConversationSurface(_service, id);
    final ShellLayout layout;
    if (group != null && group >= 0 && group < _layout.groups.length) {
      layout = _layout.openTab(id, group: group);
    } else if (split) {
      layout = _layout.openTab(id).split();
    } else {
      layout = _routeOpen(_layout, id);
    }
    _onLayoutChanged(layout);
    return true;
  }

  /// `shell_close_tab`: closes an open tab (the docked close law
  /// applies); false for an id that is not open — honest refusal.
  bool _debugCloseTab(final String id) {
    if (_layout.groupOf(id) < 0) return false;
    _onCloseTab(id);
    return true;
  }

  /// `shell_select_room`: a rooms-column row key
  /// (`rooms.row.{dm,channel}.<id>`) → its conversation surface id,
  /// selected through the shell's own row-tap path. False for any
  /// other key shape (the CTA rows are not rooms; the retired
  /// `rooms.row.room.` keys honestly refuse — rooms live in the
  /// channel view's threads browser now). ADR 0146: the key shape is
  /// frozen (keys are opaque ids) — the `<id>` tail may be either
  /// channel-id spelling (the row-built threadId or a legacy registry
  /// mint); the `channel:` surface id it maps to resolves through
  /// [RealmChatService.channelByAnyId], both spellings.
  bool _debugSelectRoom(final String rowKey) {
    const prefixes = <String, String>{
      'rooms.row.dm.': 'dm:',
      'rooms.row.channel.': 'channel:',
    };
    for (final entry in prefixes.entries) {
      if (!rowKey.startsWith(entry.key)) continue;
      final tail = rowKey.substring(entry.key.length);
      if (tail.isEmpty) return false;
      _onSelectTab('${entry.value}$tail');
      return true;
    }
    return false;
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
  /// `actor:<id>` info tabs (Wave F) ARE view ids: an actor's
  /// information is not a conversation, so it splits right exactly
  /// like `people` or `boards`.
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
      CommandEntry(
        id: 'view.$kAutomationsSurfaceId',
        label:
            surfaces[kAutomationsSurfaceId]?.title ??
            l10n.supervisorSectionTitle,
        group: 'views',
        icon: Icons.bolt_outlined,
        run: _openAutomations,
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
      // No `rooms` group (the projection law): rooms and sessions
      // surface in the panes' threads browser and via linkified
      // references, never as top-level commands.
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
    final old = _layout;
    final next = _routeClose(old, surfaceId);
    if (next.groups.length < old.groups.length) {
      // A group dissolves: its weight drops with it (the remaining
      // flexes re-share the space).
      final g = old.groupOf(surfaceId);
      final w = List<double>.of(_paneWeights);
      if (g >= 0 && g < w.length) w.removeAt(g);
      _setLayoutWithWeights(next, w);
      return;
    }
    _onLayoutChanged(next);
  }

  /// The tab context menu's "close all": every tab in every group. The
  /// service's active thread clears exactly like a single room-tab close
  /// (the ensure-exists law must never resurrect what the human closed;
  /// only the ACTIVE room auto-opens, so the others stay closed), then
  /// the layout law lands the world face — [ShellLayout.closeAllTabs].
  void _onCloseAllTabs() {
    final mapped = conversationSurfaceId(
      activeThreadId: _service.activeThreadId,
      channels: _service.channels,
      actors: _service.roster?.all ?? const <ActorProfile>[],
      dmThreadOf: _service.dmThreadOf,
    );
    if (mapped != null) _service.clearActiveThread();
    _onLayoutChanged(_layout.closeAllTabs());
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

  /// The rooms COLUMN's row tap (owner law 2026-11-18, every click): a
  /// DM row opens the conversation AND the actor's info tab — the info
  /// routes FIRST, the DM SECOND, and the last [ShellLayout.openTab]
  /// wins the focus, so the conversation is active and the info sits
  /// open beside it (re-clicks open nothing new — an open id never
  /// duplicates). Every other row (channels, retired → `actor:<id>`)
  /// rides the one tab-select path unchanged.
  void _onRoomsSelect(final String surfaceId) {
    if (!surfaceId.startsWith('dm:')) {
      _onSelectTab(surfaceId);
      return;
    }
    final actorId = surfaceId.substring('dm:'.length);
    activateConversationSurface(_service, surfaceId);
    _onLayoutChanged(_routeOpen(_layout, actorSurfaceId(actorId)));
    _onLayoutChanged(_routeOpen(_layout, surfaceId));
  }

  /// The strip's split control (group 0): the active tab moves into a
  /// new pane to the right (the mockup law).
  void _onSplit() => _onLayoutChanged(_layout.split());

  /// A native drag landed on a strip: the tab reorders inside its group
  /// or moves into another one ([ShellLayout.moveTabTo] decides — the
  /// shell only commits). [at] null = append to the strip's end. An
  /// emptied source group dissolves, and its weight drops with it (the
  /// remaining flexes re-share).
  void _onMoveTab(final String tabId, final int group, final int? at) {
    final old = _layout;
    final next = old.moveTabTo(tabId: tabId, group: group, at: at);
    if (next.groups.length < old.groups.length) {
      final s = old.groupOf(tabId);
      final w = List<double>.of(_paneWeights);
      if (s >= 0 && s < w.length) w.removeAt(s);
      _setLayoutWithWeights(next, w);
      return;
    }
    _onLayoutChanged(next);
  }

  /// A native drag landed on a pane's dashed edge: the tab splits into
  /// a NEW group at that position ([ShellLayout.splitTabAt] decides —
  /// refusals are no-ops the commit swallows). Weight laws: the generic
  /// split law (the new group half-shares its left neighbour) covers
  /// the growth paths; when the source's LONE tab moved out of a
  /// multi-group tree, the source dissolved and its width MOVES with
  /// the tab into the new group (the whole tab set moved, so the width
  /// must follow it).
  void _onSplitTab(final String tabId, final int index, final bool after) {
    final old = _layout;
    final next = old.splitTabAt(tabId: tabId, index: index, after: after);
    if (next == old) return;
    final s = old.groupOf(tabId);
    List<double>? weights;
    if (s >= 0 &&
        old.groups.length > 1 &&
        old.groups[s].tabs.length == 1 &&
        s < _paneWeights.length) {
      final at = after ? index + 1 : index;
      final w = List<double>.of(_paneWeights);
      final sourceWeight = w.removeAt(s);
      w.insert((at > s ? at - 1 : at).clamp(0, w.length), sourceWeight);
      weights = w;
    }
    _setLayoutWithWeights(next, weights);
  }

  /// A trailing pane's fold control: its tabs merge back left — and its
  /// width merges with them: the merge target absorbs the folded
  /// group's weight, so the surviving pane keeps the combined width.
  void _onFold(final int group) {
    final old = _layout;
    final next = old.fold(group: group);
    if (next == old) return;
    final g = group.clamp(0, old.groups.length - 1);
    final w = List<double>.of(_paneWeights);
    if (g < w.length) {
      final moved = w.removeAt(g);
      final target = g > 0 ? g - 1 : 1;
      final mergedAt = (target > g ? target - 1 : target).clamp(
        0,
        w.length - 1,
      );
      w[mergedAt] += moved;
    }
    _setLayoutWithWeights(next, w);
  }

  void _onBack(final int group) => _onLayoutChanged(_layout.back(group: group));

  void _onForward(final int group) =>
      _onLayoutChanged(_layout.forward(group: group));

  /// Identity marks for conversation tabs (the strip's pills): the
  /// actor's avatar for `dm:` AND `actor:` (Wave F — the info tab wears
  /// the same identity mark), the channel's user-settable icon mark
  /// (default '#') for `channel:`; static views carry their registry
  /// icon.
  Widget? _leadingFor(final String surfaceId) {
    if (surfaceId.startsWith('dm:') || isActorSurfaceId(surfaceId)) {
      final actorId = surfaceId.substring(surfaceId.indexOf(':') + 1);
      final profile = _service.roster?.get(actorId);
      if (profile == null) return null;
      return ActorAvatar(profile: profile, size: _kIdentityMarkSize);
    }
    if (surfaceId.startsWith('channel:')) {
      // The channel's user-settable icon (Wave D): the strip pill
      // renders through the SAME mark widget as the rooms column's
      // row — curated glyph, raw emoji, or the default '#' mark.
      // ADR 0146: BOTH id spellings resolve (channelByAnyId).
      final channel = _service.channelByAnyId(
        surfaceId.substring('channel:'.length),
      );
      return ChannelIconMark(icon: channel?.icon, size: _kIdentityMarkSize);
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

  /// The `actor:<id>` tab's title (Wave F): the roster's live
  /// displayName, falling back to [actorDisplayFallback] — recomputed
  /// per build inside the strip's ListenableBuilder, never cached (the
  /// title-stuck bug law: a renamed actor retitles its open tab).
  String? _actorTitle(final String id) {
    if (!isActorSurfaceId(id)) return null;
    final actorId = id.substring('actor:'.length);
    return _service.roster?.get(actorId)?.displayName ??
        actorDisplayFallback(actorId);
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
          // The watchable rooms have NO top-level row (the projection
          // law): they surface inside the conversation panes' threads
          // browser and through linkified references — opening one is
          // still `room:<threadId>` through the ONE router.
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
          NewTabRow(
            key: 'newtab.entry.$kAutomationsSurfaceId',
            label:
                surfaces[kAutomationsSurfaceId]?.title ??
                l10n.supervisorSectionTitle,
            icon: Icons.bolt_outlined,
            onTap: () => tap(_openAutomations),
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
    final surfaces = buildShellSurfaces(
      context,
      service: _service,
      // Wave F: "show me this actor" (beat names, the members popover,
      // the people rows) routes into the actor's `actor:<id>` info tab.
      onTapActor: _onFocusActorIntent,
      // Wave N: the people row's Message verb routes the DM tab.
      onOpenConversation: _onSelectTab,
    );
    // Wave F — `actor:<id>` specs are runtime facts: the shell projects
    // the OPEN actor tabs into the registry per build (exact-id keys,
    // resolved ahead of the prefix-generic kinds; never cached — the
    // title-stuck bug law).
    for (final id in _layout.allTabs) {
      if (!isActorSurfaceId(id)) continue;
      final spec = actorSurfaceSpec(
        id,
        service: _service,
        onOpenConversation: _onSelectTab,
      );
      if (spec != null) surfaces[id] = spec;
    }
    _projects = context.read<ProjectsNotifier?>();
    // The retired `ScreenLayout`'s small-screen law, inlined (the lane
    // must not import lib/_library): small = width < 450 (its
    // maxSmallWidth/minFullscreenPageWidth constant).
    final smallScreen = MediaQuery.sizeOf(context).width < 450;
    // The small-screen branch keeps today's anatomy EXACTLY: neither
    // the bar nor the column renders — the projection switch is chrome
    // the small screen never had.
    final roomsDocked = _roomsDocked && !smallScreen;
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
              onOpenThread: (final threadId) => _onSelectTab('room:$threadId'),
              // The channel view's threads browser and the beat text's
              // linkified references ride the SAME router at full
              // surface-id breadth (dm:/channel:/room: — the ONE
              // `_onSelectTab`; the registry and the actor-info surface
              // pin the same closure).
              onOpenConversation: _onSelectTab,
              titleFor: (final id) =>
                  conversationSurfaceTitle(
                    id,
                    channels: _titleChannels,
                    actors: _service.roster?.all ?? const <ActorProfile>[],
                    topicOf: _service.topicOf,
                  ) ??
                  _documentTitle(id) ??
                  _actorTitle(id),
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
                                // DESIGN.md v2 — the title bar is gone.
                                // Lights gutter law v2 (Wave D): on
                                // macOS the RAIL always owns the
                                // traffic-light gutter — the rail is
                                // always the window's leftmost chrome,
                                // docked or not — so no gutter is
                                // reserved here; other platforms keep
                                // their system inset.
                                SizedBox(
                                  height: MediaQuery.of(
                                    context,
                                  ).viewPadding.top,
                                ),
                                Expanded(
                                  child: smallScreen
                                      ? _paneColumn(_layout.active, surfaces)
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ActionBar(
                                              layout: _layout,
                                              actorsDocked: roomsDocked,
                                              onToggleActors: _toggleRoomsDock,
                                              onOpenAutomations:
                                                  _openAutomations,
                                              onOpenSettings: _openSettings,
                                              onOpenPalette: _openPalette,
                                            ),
                                            // The chat-first projection:
                                            // the docked rooms column
                                            // (navigation chrome, never
                                            // a tab) — its right edge
                                            // is the width drag handle
                                            // (the resize law).
                                            if (roomsDocked) ...[
                                              _roomsColumn(),
                                              _ResizeHandle(
                                                key: const ValueKey(
                                                  'shell.rooms.resize',
                                                ),
                                                label: 'shell.rooms.resize',
                                                hint: context
                                                    .l10n
                                                    .resizeRoomsHint,
                                                // The hover accent lands on
                                                // the handle's edge against
                                                // the column's own right
                                                // hairline — one boundary
                                                // line, brightened on hover.
                                                hoverLineLeft: 0,
                                                onDragUpdate:
                                                    _onRoomsResizeDrag,
                                                onDragEnd: _persistRoomsWidth,
                                                onIncrease: () =>
                                                    _onRoomsResizeDrag(24),
                                                onDecrease: () =>
                                                    _onRoomsResizeDrag(-24),
                                                child: const SizedBox(
                                                  width: ShellTokens
                                                      .resizeHandleWidth,
                                                ),
                                              ),
                                            ],
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
      width: _roomsColumnWidth,
      onSelect: _onRoomsSelect,
      onCreateChannel: () =>
          unawaited(openNewChannelFlow(context, service: _service)),
      onMessageActor: () => unawaited(
        openMessageActorFlow(
          context,
          service: _service,
          onOpenSettings: _openSettings,
        ),
      ),
      onMiniWindow: _openMiniWindow,
      onSetIcon: _setChannelIcon,
      onManageMembers: (final channel) => unawaited(
        openChannelMembersDialog(context, service: _service, channel: channel),
      ),
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
  ///
  /// The resize law (owner request 2026-11-18): each group is a flex
  /// child weighted by its persisted width weight ([_paneWeights]; 1.0
  /// each by default = the equal split), and every INNER seam is a drag
  /// handle — its two abutting zones both drag the same boundary, so
  /// the whole 12px seam resizes the pair of groups it separates.
  Widget _panesRow(final SurfaceRegistry surfaces) {
    final groups = _layout.groups;
    return LayoutBuilder(
      builder: (final context, final constraints) {
        // The drag math's px-per-weight basis: the row's FULL width —
        // exactly what the flex children (the group columns) share.
        final flexible = constraints.maxWidth;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var g = 0; g < groups.length; g++)
              Expanded(
                flex: (_weightFor(g) * 1000).round().clamp(1, 1 << 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _paneEdge(
                      g,
                      after: false,
                      resizable: g > 0,
                      flexibleWidth: flexible,
                    ),
                    Expanded(child: _paneColumn(g, surfaces)),
                    _paneEdge(
                      g,
                      after: true,
                      rule: g < groups.length - 1,
                      resizable: g < groups.length - 1,
                      flexibleWidth: flexible,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  /// ONE pane edge's split drop zone (keys `pane.drop.<group>.left` /
  /// `pane.drop.<group>.right`): accepts an open tab, splits it into a
  /// new group beside this one, and shows the dashed accent line while
  /// a drag hovers (shape + accent, never color alone). [rule] paints
  /// the resting hairline seam between two groups (the right zone owns
  /// it; outer window edges stay clean). [resizable] turns the zone
  /// into the resize handle of the seam it borders (`after` = the seam
  /// right of this group, else the seam left of it); the resize law
  /// drags group [group] against its neighbour, [flexibleWidth] is the
  /// panes row's full width (the px-per-weight basis).
  Widget _paneEdge(
    final int group, {
    required final bool after,
    final bool rule = false,
    final bool resizable = false,
    final double flexibleWidth = 0,
  }) {
    // The seam this zone drags: the left group of the pair it resizes
    // (-1 = the zone is split-only, an outer window edge).
    final seamLeft = !resizable
        ? -1
        : after
        ? group
        : group - 1;
    final l10n = context.l10n;
    return DragTarget<String>(
      key: ValueKey('pane.drop.$group.${after ? 'right' : 'left'}'),
      onWillAcceptWithDetails: (final details) =>
          _layout.groupOf(details.data) >= 0,
      onAcceptWithDetails: (final details) =>
          _onSplitTab(details.data, group, after),
      builder: (final context, final hovering, final rejected) => _ResizeHandle(
        key: ValueKey('pane.resize.$group.${after ? 'right' : 'left'}'),
        label: 'pane.resize.$group.${after ? 'right' : 'left'}',
        enabled: seamLeft >= 0,
        hint: l10n.resizePaneHint,
        // The hover accent lands ON the seam's resting hairline: the
        // right zone owns the rule at its outer (right) edge; the left
        // zone's seam-centre edge is its left. Either way hover
        // brightens ONE line — never a second line beside it.
        hoverLineLeft: after ? ShellTokens.resizeHandleWidth - 1 : 0,
        onDragUpdate: seamLeft >= 0
            ? (final dx) => _onPaneResizeDrag(seamLeft, dx, flexibleWidth)
            : null,
        onDragEnd: _persistPaneWeights,
        onIncrease: seamLeft >= 0
            ? () => _onPaneResizeDrag(seamLeft, 24, flexibleWidth)
            : null,
        onDecrease: seamLeft >= 0
            ? () => _onPaneResizeDrag(seamLeft, -24, flexibleWidth)
            : null,
        child: CustomPaint(
          painter: _PaneEdgePainter(
            accent: hovering.isEmpty ? null : context.la.accent,
            rule: rule ? context.shellHairline : null,
          ),
          child: const SizedBox(width: ShellTokens.resizeHandleWidth),
        ),
      ),
    );
  }

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
                channels: _titleChannels,
                actors: _service.roster?.all ?? const <ActorProfile>[],
                topicOf: _service.topicOf,
              ) ??
              _documentTitle(id) ??
              _actorTitle(id),
          leadingFor: _leadingFor,
          pickerLink: _pickerLink,
          pickerOwner: _pickerOpen && _pickerGroup == group,
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

/// The drag-width handle (the resize law, owner request 2026-11-18;
/// shared by the pane seams and the rooms column's right edge): an
/// invisible [ShellTokens.resizeHandleWidth] strip that owns the
/// horizontal drag and the resize cursor, and while hovered brightens
/// THE boundary's own hairline — [hoverLineLeft] places the 1px accent
/// line exactly on the resting rule's pixel (a seam zone's
/// seam-centre edge, or the rooms handle's edge against the column's
/// right border), so hover shows ONE line, never a second one beside
/// it. The resting affordance is the cursor alone (quiet chrome, the
/// de-Material law). The §2.3 contract holds here too: the Semantics
/// label IS the widget key, and increase/decrease actions resize for a
/// screen reader or keyboard-only user in 24px steps.
final class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({
    required this.label,
    required this.child,
    required this.hoverLineLeft,
    this.hint,
    this.enabled = true,
    this.onDragUpdate,
    this.onDragEnd,
    this.onIncrease,
    this.onDecrease,
    super.key,
  });

  /// The Semantics name (the widget key — the §2.3 contract).
  final String label;

  /// The localized drag hint (the Semantics hint).
  final String? hint;

  /// The hover accent line's x within the handle: the boundary's
  /// resting hairline position, so hover overlays that ONE line.
  final double hoverLineLeft;

  /// The handle's visual body (the zone's own paint).
  final Widget child;

  /// False leaves the strip inert (an outer window edge): no cursor,
  /// no hover line, no drag.
  final bool enabled;

  final ValueChanged<double>? onDragUpdate;
  final VoidCallback? onDragEnd;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

final class _ResizeHandleState extends State<_ResizeHandle> {
  var _hovered = false;

  @override
  Widget build(final BuildContext context) {
    final live = widget.enabled && widget.onDragUpdate != null;
    return Semantics(
      // The §2.3 name rides the handle's own key (the caller's); the
      // Semantics node carries the label/hint without a second key so
      // finders stay unambiguous.
      label: widget.label,
      hint: widget.hint,
      enabled: live,
      onIncrease: widget.onIncrease,
      onDecrease: widget.onDecrease,
      child: MouseRegion(
        cursor: live ? SystemMouseCursors.resizeLeftRight : MouseCursor.defer,
        onEnter: live ? (_) => setState(() => _hovered = true) : null,
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: live
              ? (final details) => widget.onDragUpdate!(details.delta.dx)
              : null,
          onHorizontalDragEnd: live ? (_) => widget.onDragEnd?.call() : null,
          onHorizontalDragCancel: live ? () => widget.onDragEnd?.call() : null,
          child: Stack(
            children: [
              widget.child,
              if (_hovered && live)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: widget.hoverLineLeft,
                  width: 1,
                  child: ColoredBox(
                    color: context.la.accent.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
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

/// Wave F — the shell's debug bridge: the ONE seam the `shell_*` fmtk
/// tools (`lib/mcp/shell_mcp_tools.dart`) ride. The mounted [AppShell]
/// assigns [instance] in `initState` under a kDebugMode guard and nulls
/// it in `dispose`, so a release tree carries nothing and the tools
/// refuse honestly (`shell_bridge_absent`) while no shell is mounted.
/// Static-by-contract — the same debug-seam shape as
/// `AgentDocSurface.debugSurface` and `RealmChatService.debugInstances`.
final class ShellDebugBridge {
  /// The live bridge; null when no app shell is mounted.
  static ShellDebugBridge? instance;

  /// The projection switch: true = chat-first (docked rooms column).
  late final bool Function() docked;

  /// The layout document's projection: docked bool, pane groups with
  /// their tab ids, the active group and tab.
  late final Map<String, Object?> Function() state;

  /// Flips + persists the rooms-column dock (the rail's actors button).
  late final Future<void> Function() toggleDock;

  /// Opens a tab id through the shell's ONE router; [group] forces a
  /// pane group, [split] lands the tab in its own new right group.
  late final Future<bool> Function(String id, {int? group, bool split}) openTab;

  /// Closes an open tab (the docked close law applies); false when the
  /// id is not open.
  late final bool Function(String id) closeTab;

  /// The strip's split control: the active tab moves into a new pane
  /// to the right.
  late final void Function() splitActive;

  /// Selects a rooms-column row by its contract key
  /// (`rooms.row.{dm,channel,room}.<id>`); false for unknown keys.
  late final bool Function(String rowKey) selectRoom;
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
