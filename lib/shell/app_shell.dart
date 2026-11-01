/// ADR 0024 — the app shell: actor rail on the left, a flat tab strip in
/// the center, no home face. The shell owns the center's [CenterTabs]
/// as state (persisted as one SharedPreferences JSON blob — the same
/// store the storage backends use), installs the agent-doc mesh seams
/// that used to live on the dissolved HomeScreen, and provides the
/// shared [RealmChatService] to everything below it (rail, tab
/// surfaces).
///
/// The pane tree (splits/stacks/tree editing) retired in favor of the
/// flat strip; the old `shell.paneTree.v1` blob migrates one time
/// ([_restoreTabs]).
///
/// Route shape: the shell wraps the router's nested navigator, so
/// project docs/ideas/notes still push as full pages over the center
/// while the rail stays. The `/home` route body is [CenterTabsArea] —
/// the strip the shell owns.
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
import 'package:lastanswer/workspaces/workspace_files_tab.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// The SharedPreferences key holding the center tabs JSON.
const String kCenterTabsPrefsKey = 'shell.tabs.v1';

/// The RETIRED pane-tree key. Read once for the one-time migration;
/// never written, never re-read once the new key exists.
const String kLegacyPaneTreePrefsKey = 'shell.paneTree.v1';

/// The shell chrome: the rail, the center tab strip, and everything the
/// old home face installed. Inject [service] in tests; production
/// resolves it internally.
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
  CenterTabs _tabs = CenterTabs();
  final ContextColumnController _contextColumn = ContextColumnController();
  var _seamsInstalled = false;

  /// The conversation id the boot restore already handled (once per id,
  /// never retried — see [_restorePersistedConversationTab]).
  String? _bootRestoredId;

  /// ADR 0027 — the miniwindow layer's state: floating windows (the
  /// window presentation of a surface), fed by the rail's "open in
  /// miniwindow" affordance and persisted beside the tab strip.
  final MiniWindowController _miniWindows = MiniWindowController();
  final MiniWindowPersistence _miniWindowPersistence = MiniWindowPersistence();

  @override
  void initState() {
    super.initState();
    unawaited(_service.ensureReady());
    _service.addListener(_onServiceChanged);
    unawaited(_restoreTabs());
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
    // The context panel's FILES tab mounts the workspace registry's
    // folders (ADR 0026) — the panel file stays registry-agnostic via
    // this seam; the notifier is the DI one (nullable read: hermetic
    // test shells without DI keep the tab's honest empty state).
    final workspaces = context.read<WorkspaceNotifier?>();
    if (workspaces != null) {
      ShellContextColumn.filesTabContentBuilder = (final tabContext) =>
          WorkspaceFilesTab(notifier: workspaces);
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

  // ---- center-tabs persistence -------------------------------------------

  /// Restores the persisted tabs; a corrupt blob keeps the default strip
  /// (the model decodes tolerantly, so does the shell). When the new key
  /// does not exist yet, the RETIRED pane-tree blob migrates one time:
  /// its leaves flatten in document order (deduped, conversations
  /// first) into tabs, the new key is written, and the legacy key stays
  /// on disk but is never read again.
  Future<void> _restoreTabs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kCenterTabsPrefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (mounted) setState(() => _tabs = CenterTabs.fromJson(decoded));
      } on Object {
        // Unreadable persisted state never takes the shell down.
      }
      _restorePersistedConversationTab();
      return;
    }
    final legacy = prefs.getString(kLegacyPaneTreePrefsKey);
    if (legacy == null || legacy.isEmpty) return;
    try {
      final ids = legacyPaneTreeSurfaceIds(jsonDecode(legacy));
      if (ids.isEmpty || !mounted) return;
      final migrated = CenterTabs(surfaceIds: ids);
      setState(() => _tabs = migrated);
      await prefs.setString(kCenterTabsPrefsKey, jsonEncode(migrated.toJson()));
    } on Object {
      // An unreadable legacy tree keeps the default strip.
    }
    _restorePersistedConversationTab();
  }

  void _onTabsChanged(final CenterTabs tabs) {
    setState(() => _tabs = tabs);
    _persistTabs(tabs);
  }

  void _persistTabs(final CenterTabs tabs) {
    unawaited(
      SharedPreferences.getInstance().then(
        (final prefs) =>
            prefs.setString(kCenterTabsPrefsKey, jsonEncode(tabs.toJson())),
      ),
    );
  }

  /// The rail's selection flow. The rail never learns about tabs: its
  /// rows select through the service (`openDm`/`selectChannel`), and the
  /// shell translates the service's focused thread back to a
  /// `dm:`/`channel:` surface id — reusing the ONE conversation slot
  /// ([CenterTabs.openConversation], Discord flow, zero tab
  /// accumulation). A thread that maps to no rail object (nothing
  /// selected, an unregistered group) leaves the strip untouched.
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
    final next = _tabs.openConversation(surfaceId);
    if (next == _tabs) return;
    setState(() => _tabs = next);
    _persistTabs(next);
  }

  /// Boot restore: the strip persists its active conversation tab, but
  /// the service boots with NO selected thread — the tab would sit on
  /// the calm empty note until the first click. Once, when the rail
  /// object behind the active id is known and the service is ready,
  /// re-select it. Unknown objects never retry (and never CREATE a
  /// thread for them — openDm would).
  void _restorePersistedConversationTab() {
    if (_service.activeThreadId != null || !_service.isReady) return;
    final id = _tabs.activeId;
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
  /// maps to no live thread (the same vocabulary as the tab strip).
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
  /// pops the enclosing route, so a tab embedding would pop the whole
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

  // ---- center-tabs keyboard (the browser map) -----------------------------

  /// The strip's keyboard map: the picker shortcut (⌘T / ctrl+T) and the
  /// close-the-active-tab shortcut (⌘W / ctrl+W). The modifier is
  /// chosen per platform — meta on macOS, ctrl elsewhere — so the map
  /// never shadows a text field's editing bindings (no text-editing
  /// default uses meta+T/meta+W, and ctrl+T/ctrl+W are only bound here
  /// on the platforms where they are not text-editing bindings).
  Map<ShortcutActivator, Intent> _centerTabShortcuts() {
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
  void _openNewTab() => _onTabsChanged(_tabs.openNewTab());

  /// The ⌘W flow: the active tab closes (the close law applies — a lone
  /// real tab swaps the picker in).
  void _closeActiveTab() => _onTabsChanged(_tabs.close(_tabs.activeId));

  @override
  Widget build(final BuildContext context) {
    final surfaces =
        buildShellSurfaces(context, service: _service)
          ..[kNewTabSurfaceId] = SurfaceSpec(
            id: kNewTabSurfaceId,
            title: context.l10n.newTabPageTitle,
            builder: (final tabContext) => const NewTabSurface(),
            icon: Icons.crop_square,
          );
    final screenLayout = ScreenLayout.of(context);
    // v1 is desktop-first; small layouts fall back to the navigator body
    // alone (the old HomeScreen did the same with its rail). The context
    // column joins at the app's minimum window width and up — the header
    // toggle is the only hider (Discord keeps its member list on narrow
    // windows) — and only while the human has not hidden it.
    final body = screenLayout.small
        ? widget.child
        : LayoutBuilder(
            builder: (final context, final constraints) => ListenableBuilder(
              listenable: _contextColumn,
              builder: (final context, final _) {
                final showContext =
                    constraints.maxWidth >= kContextColumnMinWindowWidth &&
                    _contextColumn.visible;
                // ADR 0027 — the miniwindow layer floats above the whole
                // three-column body: windows may overlap every column,
                // and gestures outside them fall through untouched.
                return MiniWindowLayer(
                  controller: _miniWindows,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: kActorRailWidth,
                        child: ActorRail(
                          service: _service,
                          onOpenSettings: _openSettings,
                          onConversationNewTab: (final surfaceId) =>
                              _onTabsChanged(
                                _tabs.openConversation(
                                  surfaceId,
                                  forceNew: true,
                                ),
                              ),
                          onMiniWindow: _openMiniWindow,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      Expanded(child: widget.child),
                      if (showContext)
                        SizedBox(
                          width: ShellTokens.contextColumnWidth,
                          child: ShellContextColumn(service: _service),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
    return ChangeNotifierProvider<RealmChatService>.value(
      value: _service,
      child: ChangeNotifierProvider<ContextColumnController>.value(
        value: _contextColumn,
        child: CenterTabsScope(
          tabs: _tabs,
          surfaces: surfaces,
          onChanged: _onTabsChanged,
          child: Shortcuts(
            shortcuts: _centerTabShortcuts(),
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
              // The focus anchor: shell-level shortcuts answer even when
              // no text field holds focus — the anchor takes it once at
              // mount (an autofocus request loses to any already-focused
              // descendant, so the rail's search field is never stolen
              // from) and key events then bubble up through the map.
              child: Focus(
                autofocus: true,
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The center-tabs keyboard intents (the browser map, see
/// [_AppShellState._centerTabShortcuts]).
class _NewTabIntent extends Intent {
  const _NewTabIntent();
}

class _CloseActiveTabIntent extends Intent {
  const _CloseActiveTabIntent();
}

/// The `/home` route body: the center tab strip plus the active
/// surface. Pushed project routes render as full pages of the navigator
/// above it; the strip (and its state) survive the round-trip in the
/// shell.
/// The spec for a conversation surface id (`dm:`/`channel:`): the ONE
/// conversation slot's [WorldChatSurface]. Null for anything that is
/// neither a static surface nor a conversation slot id (honest unknown).
SurfaceSpec? conversationSurfaceSpec(
  final String surfaceId,
  final SurfaceRegistry surfaces,
) {
  if (!surfaceId.startsWith('dm:') && !surfaceId.startsWith('channel:')) {
    return null;
  }
  return surfaces[kConversationsSurfaceId];
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

final class CenterTabsArea extends StatelessWidget {
  const CenterTabsArea({super.key});

  @override
  Widget build(final BuildContext context) {
    final scope = CenterTabsScope.of(context);
    if (scope == null) {
      // Honest absence: the area only makes sense inside the shell.
      return const Center(child: Text('center tabs require the app shell'));
    }
    final tabs = scope.tabs;
    final activeId = tabs.activeId;
    // Conversation surface ids (`dm:`/`channel:`) are not in the static
    // registry — they share the ONE conversation slot, so they resolve
    // onto its [WorldChatSurface] spec.
    final spec =
        scope.surfaces[activeId] ??
        conversationSurfaceSpec(activeId, scope.surfaces);
    final service = context.read<RealmChatService?>();
    // Built per-call, never cached: a widget INSTANCE handed back from
    // a builder is treated as unchanged and its subtree never rebuilds
    // — pure title facts (channels/roster loading) would never land.
    CenterTabsStrip buildStrip() => CenterTabsStrip(
      tabs: tabs,
      surfaces: scope.surfaces,
      // Conversation surface ids are not in the static registry; their
      // titles come from the service's projections (channel name / actor
      // display name), falling back to the registry title, then the id.
      titleFor: service == null
          ? null
          : (final id) => conversationSurfaceTitle(
              id,
              channels: service.channels,
              actors: service.roster?.all ?? const <ActorProfile>[],
            ),
      onSelect: (final id) {
        // A conversation tab re-selects its thread: the service is the
        // source of truth for WHAT is on the slot, the strip only names
        // it (openDm/selectChannel are idempotent; the reverse mapping
        // in _onServiceChanged then re-enters as a no-op).
        activateConversationSurface(service, id);
        scope.onChanged(tabs.open(id));
      },
      onClose: (final id) => scope.onChanged(tabs.close(id)),
      onNewTab: () => scope.onChanged(tabs.openNewTab()),
      onReorder: (final from, final to) => scope.onChanged(tabs.move(from, to)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The strip follows the service's notifications so rail-driven
        // title facts (roster, channels) land without a tab change.
        if (service == null)
          buildStrip()
        else
          ListenableBuilder(
            listenable: service,
            builder: (final context, final _) => buildStrip(),
          ),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey('pane.leaf.$activeId'),
            child: spec == null
                ? UnknownSurface(surfaceId: activeId)
                : Builder(builder: spec.builder),
          ),
        ),
      ],
    );
  }
}
