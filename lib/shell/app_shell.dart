/// ADR 0024 — the app shell. WAVE 5 — unified views: ONE top bar of
/// view tabs spans ABOVE the whole row (rail | center | dock); every
/// center and right view opens as a tab; views PIN into the dock. The
/// shell owns the layout as state ([ViewLayout], persisted as one
/// SharedPreferences JSON blob — `shell.views.v2`, ONE-TIME migrated
/// from `shell.tabs.v1`, which itself migrated from the retired
/// `shell.paneTree.v1`), installs the agent-doc mesh seams that used
/// to live on the dissolved HomeScreen, and provides the shared
/// [RealmChatService] to everything below it (rail, view surfaces).
///
/// Route shape: the shell wraps the router's nested navigator, so
/// project docs/ideas/notes still push as full pages over the center
/// while the rail and the top bar stay. The `/home` route body is
/// [CenterTabsArea] — the active view's host (the bar lives above).
library;

import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:headless_core/headless_core.dart' as hc;

import 'package:lastanswer/_library/widgets/widgets.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/agent_doc_surface.dart';

import 'package:lastanswer/coding_agent/meaning_experiment_entry.dart';

import 'package:lastanswer/coding_agent/permission_doc_router.dart';

import 'package:lastanswer/coding_agent/provider_configuration.dart';

import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/settings/settings.dart';

import 'package:lastanswer/shell/actor_rail.dart';

import 'package:lastanswer/shell/center_tabs.dart';

import 'package:lastanswer/shell/context_column.dart';

import 'package:lastanswer/shell/miniwindows/mini_window.dart';

import 'package:lastanswer/shell/miniwindows/mini_window_persistence.dart';

import 'package:lastanswer/shell/pinned_conversation_peek.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_dock.dart';

import 'package:lastanswer/shell/view_layout.dart';

import 'package:lastanswer/shell/view_people.dart';

import 'package:lastanswer/workspaces/workspace_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// The SharedPreferences key holding the unified views layout JSON
/// (`tabs` + `active` + `pinned` + `dockFocus`).
const String kViewLayoutPrefsKey = 'shell.views.v2';

/// The RETIRED center-strip key. Read once for the one-time migration
/// (a v1 blob decodes as a v2 layout with the default pin); never
/// written, never re-read once the new key exists.
const String kCenterTabsPrefsKey = 'shell.tabs.v1';

/// The RETIRED pane-tree key. Read once for the one-time migration;
/// never written, never re-read once a newer key exists.
const String kLegacyPaneTreePrefsKey = 'shell.paneTree.v1';

/// The shell chrome: the rail, the top bar of view tabs, the center
/// and the dock. Inject [service] in tests; production resolves it
/// internally.
final class AppShell extends StatefulWidget {
  const AppShell({required this.child, this.service, super.key});

  /// The router body below the shell (the nested navigator).
  final Widget child;

  /// Test seam; production creates and owns one.
  final RealmChatService? service;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final RealmChatService _service =
      widget.service ??
      // The root DI owns the app-run singleton (one bot host per world);
      // construct only when no DI ancestor exists (hermetic tests). The
      // nullable read answers null when no provider is above the shell.
      context.read<RealmChatService?>() ??
      RealmChatService(
        providerConfiguration: context.read<ProviderConfigurationStore?>(),
      );
  ViewLayout _layout = ViewLayout();
  final PeopleFocus _peopleFocus = PeopleFocus();

  /// The dock's session intent + the conversation header's bridge.
  final ContextColumnController _contextColumn = ContextColumnController();
  var _seamsInstalled = false;

  /// The conversation id the boot restore already handled (once per id,
  /// never retried — see [_restorePersistedConversationTab]).
  String? _bootRestoredId;

  /// Whether the window currently clears the dock's width gate —
  /// captured by the build's LayoutBuilder; the actor-focus intent
  /// reads it to decide WHERE the people view appears (a focused pin
  /// in a hidden dock shows nothing, so narrow windows get the tab).
  bool _windowWide = true;

  /// ADR 0027 — the miniwindow layer's state: floating windows (the
  /// window presentation of a surface), fed by the rail's "open in
  /// miniwindow" affordance and persisted beside the layout.
  final MiniWindowController _miniWindows = MiniWindowController();
  final MiniWindowPersistence _miniWindowPersistence = MiniWindowPersistence();

  @override
  void initState() {
    super.initState();
    _contextColumn.onFocusActorIntent = _onFocusActorIntent;
    unawaited(_service.ensureReady());
    _service.addListener(_onServiceChanged);
    unawaited(_restoreLayout());
    unawaited(
      _miniWindowPersistence.restoreInto(_miniWindows, _miniWindowSpec),
    );
    _miniWindowPersistence.bind(_miniWindows);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _installAgentDocSeams();
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    _contextColumn.dispose();
    _peopleFocus.dispose();
    _miniWindowPersistence.dispose();
    _miniWindows.dispose();
    super.dispose();
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
  /// (the model decodes tolerantly, so does the shell). When the v2 key
  /// does not exist yet, the migration runs once: the RETIRED
  /// `shell.tabs.v1` blob reads as a v2 layout (tabs + active carried,
  /// People the default pin), else the RETIRED pane-tree blob's leaves
  /// flatten in document order (deduped, conversations first) — the
  /// v2 key is written and the legacy keys stay on disk but are never
  /// read again.
  Future<void> _restoreLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kViewLayoutPrefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (mounted) setState(() => _layout = ViewLayout.fromJson(decoded));
      } on Object {
        // Unreadable persisted state never takes the shell down.
      }
      _restorePersistedConversationTab();
      return;
    }
    final legacyTabs = prefs.getString(kCenterTabsPrefsKey);
    if (legacyTabs != null && legacyTabs.isNotEmpty) {
      try {
        final migrated = ViewLayout.fromJson(jsonDecode(legacyTabs));
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
      final migrated = ViewLayout(tabs: ids);
      setState(() => _layout = migrated);
      await prefs.setString(
        kViewLayoutPrefsKey,
        jsonEncode(migrated.toJson()),
      );
    } on Object {
      // An unreadable legacy tree keeps the default layout.
    }
    _restorePersistedConversationTab();
  }

  void _onLayoutChanged(final ViewLayout layout) {
    if (layout == _layout) return;
    setState(() => _layout = layout);
    _persistLayout(layout);
  }

  void _persistLayout(final ViewLayout layout) {
    unawaited(
      SharedPreferences.getInstance().then(
        (final prefs) =>
            prefs.setString(kViewLayoutPrefsKey, jsonEncode(layout.toJson())),
      ),
    );
  }

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
    _onLayoutChanged(_layout.openConversation(surfaceId));
  }

  /// Boot restore: the layout persists its active conversation tab, but
  /// the service boots with NO selected thread — the tab would sit on
  /// the calm empty note until the first click. Once, when the rail
  /// object behind the active id is known and the service is ready,
  /// re-select it. Unknown objects never retry (and never CREATE a
  /// thread for them — openDm would).
  void _restorePersistedConversationTab() {
    if (_service.activeThreadId != null || !_service.isReady) return;
    final id = _layout.activeId;
    if (_bootRestoredId == id) return;
    final dmActor = id.startsWith('dm:') ? id.substring('dm:'.length) : null;
    final channelId = id.startsWith('channel:')
        ? id.substring('channel:'.length)
        : null;
    final known =
        (dmActor != null && _service.roster?.get(dmActor) != null) ||
        (channelId != null &&
            _service.channels.any(
              (final channel) => channel.channelId == channelId,
            ));
    _bootRestoredId = id;
    if (!known) return;
    activateConversationSurface(_service, id);
  }

  // ---- actions -------------------------------------------------------------

  /// Pin intent from a tab's glyph: pinned views unpin (the tab stays),
  /// unpinned ones pin (the tab stays too — a view may be tab AND pin).
  void _togglePin(final String surfaceId) => _onLayoutChanged(
    _layout.isPinned(surfaceId)
        ? _layout.unpin(surfaceId)
        : _layout.pin(surfaceId),
  );

  /// A dock pill tap: focuses that pin.
  void _focusPin(final String surfaceId) =>
      _onLayoutChanged(_layout.focusDock(surfaceId));

  /// A dock pill's unpin glyph: removes the pin only (an open tab
  /// stays open).
  void _unpin(final String surfaceId) =>
      _onLayoutChanged(_layout.unpin(surfaceId));

  /// The conversation header's intent: show me this actor. The people
  /// view appears where the human can SEE it: a focused pin when the
  /// dock is actually visible (people pinned, window wide, dock not
  /// hidden), else an open tab in the center.
  void _onFocusActorIntent(final String actorId) {
    _peopleFocus.focus(actorId);
    final peoplePinned = _layout.isPinned(kPeopleSurfaceId);
    final dockShowsPeople =
        peoplePinned &&
        _windowWide &&
        _contextColumn.visible;
    final next = dockShowsPeople
        ? _layout.focusDock(kPeopleSurfaceId)
        : _layout.open(kPeopleSurfaceId);
    _onLayoutChanged(next);
  }

  /// ADR 0027 — the rail's right-click affordance: a conversation in
  /// its own floating window. v1 content is the read-only peek (who is
  /// in it, the last word — [PinnedConversationPeek]); a DM without a
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

  /// The miniwindow behind a conversation surface id, null when the id
  /// maps to no live thread (the same vocabulary as the tab bar).
  /// The persistence lane re-resolves persisted ids through this on
  /// boot — a ghost id restores as nothing.
  MiniWindowSpec? _miniWindowSpec(final String surfaceId) {
    final dmActor = surfaceId.startsWith('dm:')
        ? surfaceId.substring('dm:'.length)
        : null;
    final channelId = surfaceId.startsWith('channel:')
        ? surfaceId.substring('channel:'.length)
        : null;
    final threadId = dmActor != null
        ? _service.dmThreadOf(dmActor)
        : _service.channels
              .where((final channel) => channel.channelId == channelId)
              .map((final channel) => channel.threadId)
              .firstOrNull;
    if (threadId == null) return null;
    final title =
        conversationSurfaceTitle(
          surfaceId,
          channels: _service.channels,
          actors: _service.roster?.all ?? const <ActorProfile>[],
        ) ??
        surfaceId;
    return MiniWindowSpec(
      id: surfaceId,
      title: title,
      builder: (final context) =>
          PinnedConversationPeek(service: _service, threadId: threadId),
    );
  }

  /// Settings stays a route push in v1: SettingsScreen's close button
  /// pops the enclosing route, so a view embedding would pop the whole
  /// shell (named follow-up — see surfaces.dart).
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (final _) => const SettingsScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  // ---- the top bar's keyboard (the browser map) ---------------------------

  /// The bar's keyboard map: the picker shortcut (⌘T / ctrl+T) and the
  /// close-the-active-tab shortcut (⌘W / ctrl+W). The modifier is
  /// chosen per platform — meta on macOS, ctrl elsewhere — so the map
  /// never shadows a text field's editing bindings (no text-editing
  /// default uses meta+T/meta+W, and ctrl+T/ctrl+W are only bound here
  /// on the platforms where they are not text-editing bindings).
  Map<ShortcutActivator, Intent> _viewTabShortcuts() {
    final useMeta = defaultTargetPlatform == TargetPlatform.macOS;
    return <ShortcutActivator, Intent>{
      if (useMeta)
        const SingleActivator(
          LogicalKeyboardKey.keyT,
          meta: true,
        ): const _NewTabIntent(),
      if (useMeta)
        const SingleActivator(
          LogicalKeyboardKey.keyW,
          meta: true,
        ): const _CloseActiveTabIntent(),
      if (!useMeta)
        const SingleActivator(
          LogicalKeyboardKey.keyT,
          control: true,
        ): const _NewTabIntent(),
      if (!useMeta)
        const SingleActivator(
          LogicalKeyboardKey.keyW,
          control: true,
        ): const _CloseActiveTabIntent(),
    };
  }

  /// The `+`/⌘T flow: the picker opens/focuses as a new active tab.
  void _openNewTab() => _onLayoutChanged(_layout.openNewTab());

  /// The ⌘W flow: the active tab closes (the close law applies — a lone
  /// real tab swaps the picker in).
  void _closeActiveTab() => _onLayoutChanged(_layout.close(_layout.activeId));

  /// A bar tab tap: conversation tabs re-select their thread (the
  /// service is the source of truth for WHAT is on the slot —
  /// openDm/selectChannel are idempotent; the reverse mapping in
  /// [_onServiceChanged] then re-enters as a no-op), every tab focuses.
  void _onSelectTab(final String surfaceId) {
    activateConversationSurface(_service, surfaceId);
    _onLayoutChanged(_layout.open(surfaceId));
  }

  /// Identity marks for conversation tabs (the bar's compressed pills
  /// and the dock pills): the actor's avatar for `dm:`, the channel's
  /// `#` disc for `channel:`; static views carry their registry icon.
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
    return null;
  }

  static const double _kIdentityMarkSize = 16;

  @override
  Widget build(final BuildContext context) {
    final surfaces = buildShellSurfaces(context, service: _service)
      ..[kNewTabSurfaceId] = SurfaceSpec(
        id: kNewTabSurfaceId,
        title: context.l10n.newTabPageTitle,
        builder: (final tabContext) => const NewTabSurface(),
        icon: Icons.crop_square,
      );
    final screenLayout = ScreenLayout.of(context);
    // v1 is desktop-first; small layouts fall back to the navigator body
    // alone (the rail is a desktop luxury) — the top bar still maps the
    // session. The dock joins at the app's minimum window width and up —
    // the width gate and the human's toggle are the only hiders.
    return ChangeNotifierProvider<RealmChatService>.value(
      value: _service,
      child: ChangeNotifierProvider<PeopleFocus>.value(
        value: _peopleFocus,
        child: ChangeNotifierProvider<ContextColumnController>.value(
          value: _contextColumn,
          child: ViewScope(
            layout: _layout,
            surfaces: surfaces,
            onChanged: _onLayoutChanged,
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
                  _CloseActiveTabIntent: CallbackAction<_CloseActiveTabIntent>(
                    onInvoke: (final _) {
                      _closeActiveTab();
                      return null;
                    },
                  ),
                },
                // The focus anchor: shell-level shortcuts answer even
                // when no text field holds focus — the anchor takes it
                // once at mount (an autofocus request loses to any
                // already-focused descendant, so the rail's search field
                // is never stolen from) and key events then bubble up
                // through the map.
                child: Focus(
                  autofocus: true,
                  child: LayoutBuilder(
                    builder: (final context, final constraints) {
                      _windowWide =
                          constraints.maxWidth >=
                          kContextColumnMinWindowWidth;
                      final pins = _layout.pinned;
                      return MiniWindowLayer(
                        controller: _miniWindows,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Phase 0 unified titlebar (macOS): the window
                            // draws under the traffic lights, so the shell
                            // reserves the system gutter above its one bar.
                            // macOS reports no viewPadding for the titlebar,
                            // hence the platform constant; zero elsewhere.
                            SizedBox(
                              height: defaultTargetPlatform ==
                                      TargetPlatform.macOS
                                  ? 28
                                  : MediaQuery.of(context).viewPadding.top,
                            ),
                            _buildTopBar(surfaces, pins),
                            Expanded(
                              child: ListenableBuilder(
                                listenable: _contextColumn,
                                builder: (final context, final _) {
                                  // Recomputed per notify: the human's
                                  // visibility toggle is one of the three
                                  // conditions (width gate, visibility,
                                  // something pinned).
                                  final showDock =
                                      _windowWide &&
                                      _contextColumn.visible &&
                                      pins.isNotEmpty;
                                  return screenLayout.small
                                    ? widget.child
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(
                                            width: kActorRailWidth,
                                            child: ActorRail(
                                              service: _service,
                                              onOpenSettings: _openSettings,
                                              onConversationNewTab:
                                                  (final surfaceId) =>
                                                      _onLayoutChanged(
                                                        _layout
                                                            .openConversation(
                                                              surfaceId,
                                                              forceNew: true,
                                                            ),
                                                      ),
                                              onMiniWindow: _openMiniWindow,
                                            ),
                                          ),
                                          VerticalDivider(
                                            width: 1,
                                            color:
                                                Theme.of(context).dividerColor,
                                          ),
                                          Expanded(child: widget.child),
                                          if (showDock)
                                            SizedBox(
                                              width:
                                                  ShellTokens
                                                      .contextColumnWidth,
                                              child: ViewDock(
                                                layout: _layout,
                                                surfaces: surfaces,
                                                service: _service,
                                                onFocusPin: _focusPin,
                                                onUnpin: _unpin,
                                                titleFor: (final id) =>
                                                    conversationSurfaceTitle(
                                                      id,
                                                      channels:
                                                          _service.channels,
                                                      actors:
                                                          _service
                                                              .roster
                                                              ?.all ??
                                                          const <
                                                              ActorProfile>[],
                                                    ),
                                                leadingFor: _leadingFor,
                                              ),
                                            ),
                                        ],
                                      );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The ONE top bar: rebuilt per call inside the service's
  /// ListenableBuilder so rail-driven title facts (roster, channels)
  /// land without a layout change — never a cached widget instance
  /// (the title-stuck bug law).
  Widget _buildTopBar(
    final SurfaceRegistry surfaces,
    final List<String> pins,
  ) => ListenableBuilder(
    listenable: _service,
    builder: (final context, final _) => ViewTabBar(
      layout: _layout,
      surfaces: surfaces,
      onSelect: _onSelectTab,
      onClose: (final id) => _onLayoutChanged(_layout.close(id)),
      onNewTab: _openNewTab,
      onReorder: (final from, final to) =>
          _onLayoutChanged(_layout.move(from, to)),
      onTogglePin: _togglePin,
      titleFor: (final id) => conversationSurfaceTitle(
        id,
        channels: _service.channels,
        actors: _service.roster?.all ?? const <ActorProfile>[],
      ),
      leadingFor: _leadingFor,
      // Below the width gate the dock hides; the glyph focuses the
      // first pinned view full-width — the simplest honest restore.
      onDockRestore: !_windowWide && pins.isNotEmpty
          ? () => _onLayoutChanged(_layout.open(pins.first))
          : null,
    ),
  );
}


/// The top bar's keyboard intents (the browser map, see
/// [_AppShellState._viewTabShortcuts]).
class _NewTabIntent extends Intent {
  const _NewTabIntent();
}

class _CloseActiveTabIntent extends Intent {
  const _CloseActiveTabIntent();
}

/// Re-selects the thread behind a conversation surface id through the
/// service (the source of truth for the slot's content). Fire-and-
/// forget: selection is idempotent, and the service's notification
/// re-enters `_onServiceChanged` as a no-op for the same id.
void activateConversationSurface(
  final RealmChatService? service,
  final String surfaceId,
) {
  if (service == null) return;
  if (surfaceId.startsWith('dm:')) {
    unawaited(service.openDm(surfaceId.substring('dm:'.length)));
  } else if (surfaceId.startsWith('channel:')) {
    service.selectChannel(surfaceId.substring('channel:'.length));
  }
}

/// The `/home` route body: the ACTIVE view's host. The top bar lives
/// above the whole row in the shell; the body only mounts the focused
/// surface. Pushed project routes render as full pages of the navigator
/// above it; the bar (and its state) survive the round-trip in the
/// shell.
final class CenterTabsArea extends StatelessWidget {
  const CenterTabsArea({super.key});

  @override
  Widget build(final BuildContext context) {
    final scope = ViewScope.of(context);
    if (scope == null) {
      // Honest absence: the area only makes sense inside the shell.
      return const Center(child: Text('center tabs require the app shell'));
    }
    final layout = scope.layout;
    final activeId = layout.activeId;
    // Conversation surface ids (`dm:`/`channel:`) are not in the static
    // registry — they share the ONE conversation slot, so they resolve
    // onto its [WorldChatSurface] spec.
    final spec =
        scope.surfaces[activeId] ??
        conversationSurfaceSpec(activeId, scope.surfaces);
    return KeyedSubtree(
      key: ValueKey('pane.leaf.$activeId'),
      child: spec == null
          ? UnknownSurface(surfaceId: activeId)
          : Builder(builder: spec.builder),
    );
  }
}
