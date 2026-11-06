/// ADR 0024 — the app shell. PHASE 1 — the shell redesign (docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md): the ORIGINAL idea,
/// restored — a left rail of VIEWS plus the roster, and EVERY view owns a
/// Safari-like tab strip above its content ([ShellLayout], persisted as
/// `shell.views.v3`, migrated in one pass from `shell.views.v2` /
/// `shell.tabs.v1` / `shell.paneTree.v1`). The WAVE 5 global top bar and
/// the dock of pins are retired: pins became tabs of their view, and
/// "keep an eye on this" is the miniwindow's job (ADR 0027).
///
/// The shell owns the layout as state, installs the agent-doc mesh seams
/// that used to live on the dissolved HomeScreen, and provides the shared
/// [RealmChatService] to everything below it (rail, strips, view bodies).
///
/// Route shape: the shell wraps the router's nested navigator, so project
/// docs/ideas/notes still push as full pages over the center while the
/// rail and the active view's strip stay. The `/home` route body is
/// [CenterTabsArea] — the active view's active tab host.
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

import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/settings/settings.dart';

import 'package:lastanswer/shell/actor_rail.dart';

import 'package:lastanswer/shell/center_tabs.dart';

import 'package:lastanswer/shell/command_palette.dart';

import 'package:lastanswer/shell/miniwindows/mini_window.dart';

import 'package:lastanswer/shell/miniwindows/mini_window_persistence.dart';

import 'package:lastanswer/shell/pinned_conversation_peek.dart';

import 'package:lastanswer/shell/shell_layout.dart';

import 'package:lastanswer/shell/shell_scope.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/status_edge.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_tab_strip.dart';

import 'package:lastanswer/shell/view_documents.dart';

import 'package:lastanswer/shell/view_people.dart';

import 'package:lastanswer/workspaces/workspace_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// The SharedPreferences key holding the per-view layout JSON
/// (`activeView` + each view's strip).
const String kViewLayoutPrefsKey = 'shell.views.v3';

/// The RETIRED unified-views key (one global bar + pins). Read once for
/// the one-time migration into v3; never written again.
const String kViewLayoutV2PrefsKey = 'shell.views.v2';

/// The RETIRED center-strip key, read only when v2 is absent.
const String kCenterTabsPrefsKey = 'shell.tabs.v1';

/// The RETIRED pane-tree key, read only when v2 and v1 are absent.
const String kLegacyPaneTreePrefsKey = 'shell.paneTree.v1';

/// The shell chrome: the rail of views + roster, the active view's tab
/// strip, the center host. Inject [service] in tests; production resolves
/// it internally.
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

  /// The conversation id the boot restore already handled (once per id,
  /// never retried — see [_restorePersistedConversationTab]).
  String? _bootRestoredId;

  /// The registry's loaded page, captured per build for `doc:<id>` tab
  /// titles (phase 3a).
  ProjectsNotifier? _projects;

  /// Whether the window currently clears the rail's expanded-width gate
  /// (captured by the build's LayoutBuilder); below it the rail collapses
  /// to its icon column (the owner's half-screen desktop case).
  bool _railExpanded = true;

  /// Phase 2 — the ⌘K command palette overlay's open state.
  bool _paletteOpen = false;

  /// Phase 2 — the shell's focus anchor: shell-level shortcuts answer
  /// even after clicks on non-focusable chrome (the `⌘T handled:false`
  /// class) because the anchor reclaims primary focus whenever focus
  /// falls to nothing.
  final FocusNode _shellFocus = FocusNode(debugLabel: 'shell.anchor');

  /// ADR 0027 — the miniwindow layer's state: floating windows (the
  /// window presentation of a surface), fed by the rail's "open in
  /// miniwindow" affordance and persisted beside the layout.
  final MiniWindowController _miniWindows = MiniWindowController();
  final MiniWindowPersistence _miniWindowPersistence = MiniWindowPersistence();

  @override
  void initState() {
    super.initState();
    unawaited(_service.ensureReady());
    _service.addListener(_onServiceChanged);
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
    if (_ownsWorldState) _worldState.dispose();
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
  /// (the model decodes tolerantly, so does the shell). The migration
  /// chain runs once, newest key first: v3 reads as-is; a v2/v1 blob
  /// (one global bar + pins) migrates through [ShellLayout.fromJson]
  /// (each tab to its own view's strip, pins become tabs); else the
  /// retired pane-tree blob's leaves flatten in document order. The v3
  /// key is written; legacy keys stay on disk but are never read again.
  Future<void> _restoreLayout() async {
    final prefs = await SharedPreferences.getInstance();
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
    for (final legacyKey in [kViewLayoutV2PrefsKey, kCenterTabsPrefsKey]) {
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
    if (_layout.activeView != kConversationsSurfaceId) return;
    final id = _layout.activeSurfaceId;
    if (id == null || _bootRestoredId == id) return;
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

  /// The conversation header's intent: show me this actor. The dock
  /// retired, so the people view appears as its own hosted tab.
  void _onFocusActorIntent(final String actorId) {
    _peopleFocus.focus(actorId);
    _onLayoutChanged(_layout.openTab(kPeopleSurfaceId, kPeopleSurfaceId));
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

  /// Phase 1e — settings-as-view: the gear opens the settings surface
  /// as a TAB of the active view (the embedded seam closes through the
  /// view scope). The shell grammar keeps zero exceptions: no route
  /// push, no `Navigator.pop` from inside a view.
  void _openSettings() =>
      _onLayoutChanged(_layout.openTab(_layout.activeView, kSettingsSurfaceId));

  /// The status edge's backend click (phase 1d): the Models surface
  /// opens as a tab of the ACTIVE view (any view may host any surface —
  /// the Safari law).
  void _openModelsTab() =>
      _onLayoutChanged(_layout.openTab(_layout.activeView, kModelsSurfaceId));

  /// The status edge's attention click: the Conversations view, whose
  /// landing state is the inbox (open permissions reject-first, running
  /// tasks, last verdicts).
  void _openInbox() {
    _service.clearActiveThread();
    _onLayoutChanged(_layout.showView(kConversationsSurfaceId));
  }

  // ---- the strips' keyboard (the browser map) -----------------------------

  /// The strip keyboard map: the picker shortcut (⌘T / ctrl+T) opens the
  /// picker in the ACTIVE view's strip; ⌘W / ctrl+W closes its focused
  /// tab. The modifier is chosen per platform — meta on macOS, ctrl
  /// elsewhere — so the map never shadows a text field's editing
  /// bindings.
  Map<ShortcutActivator, Intent> _viewTabShortcuts() {
    final useMeta = defaultTargetPlatform == TargetPlatform.macOS;
    return <ShortcutActivator, Intent>{
      if (useMeta)
        const SingleActivator(LogicalKeyboardKey.keyT, meta: true):
            const _NewTabIntent(),
      if (useMeta)
        const SingleActivator(LogicalKeyboardKey.keyW, meta: true):
            const _CloseActiveTabIntent(),
      if (!useMeta)
        const SingleActivator(LogicalKeyboardKey.keyT, control: true):
            const _NewTabIntent(),
      if (!useMeta)
        const SingleActivator(LogicalKeyboardKey.keyW, control: true):
            const _CloseActiveTabIntent(),
      // Phase 2 — the ⌘K command palette over the unified search.
      if (useMeta)
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            const _PaletteIntent(),
      if (!useMeta)
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            const _PaletteIntent(),
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

  /// The palette's unified search: views (rail + fact surfaces),
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
          // The palette is DETERMINISTIC where the rail is not: picking
          // a view hosts the view's OWN face tab (a strip left on the
          // picker would otherwise host the picker), while the rail's
          // showView keeps the Safari picker law.
          run: () => _onLayoutChanged(_layout.openTab(spec.id, spec.id)),
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
          run: () =>
              activateConversationSurface(_service, 'dm:${actor.actorId}'),
        ),
      for (final channel in _service.channels)
        CommandEntry(
          id: 'channel.${channel.channelId}',
          label: '#${channel.name}',
          group: 'channels',
          run: () => _service.selectChannel(channel.channelId),
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

  /// The `+`/⌘T flow: the picker opens/focuses as a new active tab of
  /// the hosted view.
  void _openNewTab() => _onLayoutChanged(_layout.openNewTab());

  /// The ⌘W flow: the hosted view's focused tab closes (the close law
  /// applies — a strip's lone real tab swaps the picker in).
  void _closeActiveTab() {
    final id = _layout.activeSurfaceId;
    if (id == null) return;
    _onLayoutChanged(_layout.closeTab(_layout.activeView, id));
  }

  /// A strip tab tap: conversation tabs re-select their thread (the
  /// service is the source of truth for WHAT is on the slot —
  /// openDm/selectChannel are idempotent; the reverse mapping in
  /// [_onServiceChanged] then re-enters as a no-op); every tab focuses
  /// in its own view's strip and hosts that view.
  void _onSelectTab(final String viewId, final String surfaceId) {
    activateConversationSurface(_service, surfaceId);
    _onLayoutChanged(_layout.openTab(viewId, surfaceId));
  }

  /// Identity marks for conversation tabs (the strip's compressed pills):
  /// the actor's avatar for `dm:`, the channel's `#` disc for `channel:`;
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
    return null;
  }

  static const double _kIdentityMarkSize = 16;

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

  /// The VIEWS section's ordered registry slice (the rail's activity
  /// bar): every static surface except the session picker.
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

  @override
  Widget build(final BuildContext context) {
    final surfaces = buildShellSurfaces(context, service: _service)
      ..[kNewTabSurfaceId] = SurfaceSpec(
        id: kNewTabSurfaceId,
        title: context.l10n.newTabPageTitle,
        builder: (final tabContext) => const NewTabSurface(),
        icon: Icons.crop_square,
      );
    _projects = context.read<ProjectsNotifier?>();
    final screenLayout = ScreenLayout.of(context);
    return ChangeNotifierProvider<RealmChatService>.value(
      value: _service,
      child: ChangeNotifierProvider<WorldStateService>.value(
        value: _worldState,
        child: ChangeNotifierProvider<PeopleFocus>.value(
          value: _peopleFocus,
          child: ViewScope(
            layout: _layout,
            surfaces: surfaces,
            onChanged: _onLayoutChanged,
            onFocusActor: _onFocusActorIntent,
            titleFor: (final id) => conversationSurfaceTitle(
              id,
              channels: _service.channels,
              actors: _service.roster?.all ?? const <ActorProfile>[],
            ),
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
                  _CloseActiveTabIntent: CallbackAction<_CloseActiveTabIntent>(
                    onInvoke: (final _) {
                      _closeActiveTab();
                      return null;
                    },
                  ),
                  _PaletteIntent: CallbackAction<_PaletteIntent>(
                    onInvoke: (final _) {
                      _openPalette();
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
                  focusNode: _shellFocus,
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerUp: (final _) => _reclaimFocusUnlessEditing(),
                    child: LayoutBuilder(
                      builder: (final context, final constraints) {
                        _railExpanded =
                            constraints.maxWidth >=
                            ShellTokens.railExpandedMinWindow;
                        return MiniWindowLayer(
                          controller: _miniWindows,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Phase 0 unified titlebar (macOS): the window
                                  // draws under the traffic lights, so the shell
                                  // reserves the system gutter above its chrome.
                                  // macOS reports no viewPadding for the titlebar,
                                  // hence the platform constant; zero elsewhere.
                                  SizedBox(
                                    height:
                                        defaultTargetPlatform ==
                                            TargetPlatform.macOS
                                        ? ShellTokens.titlebarGutter
                                        : MediaQuery.of(
                                            context,
                                          ).viewPadding.top,
                                  ),
                                  Expanded(
                                    child: screenLayout.small
                                        ? _centerColumn(surfaces)
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              SizedBox(
                                                width: _railExpanded
                                                    ? ShellTokens.railWidth
                                                    : ShellTokens
                                                          .railCompactWidth,
                                                child: ActorRail(
                                                  service: _service,
                                                  expanded: _railExpanded,
                                                  activeView:
                                                      _layout.activeView,
                                                  views: _viewSpecs(surfaces),
                                                  onOpenView: (final viewId) =>
                                                      _onLayoutChanged(
                                                        _layout.showView(
                                                          viewId,
                                                        ),
                                                      ),
                                                  onOpenSettings: _openSettings,
                                                  onOpenCommandPalette:
                                                      _openPalette,
                                                  onConversationNewTab:
                                                      (
                                                        final surfaceId,
                                                      ) => _onLayoutChanged(
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
                                                color: Theme.of(
                                                  context,
                                                ).dividerColor,
                                              ),
                                              Expanded(
                                                child: _centerColumn(surfaces),
                                              ),
                                            ],
                                          ),
                                  ),
                                  // Phase 1d — the status edge: ONE honest line
                                  // (mesh · backend · daemon · attention) at the
                                  // window bottom, spanning both layout branches;
                                  // its clicks route into the surfaces that own
                                  // the facts (Models tab, landing inbox, arm).
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
      ),
    );
  }

  /// The center: the hosted view's own tab strip above the router body
  /// (the `/home` route renders the strip's focused surface).
  Widget _centerColumn(final SurfaceRegistry surfaces) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ListenableBuilder(
        // Rebuilt per service notify so rail-driven title facts (roster,
        // channels) land without a layout change — never a cached widget
        // instance (the title-stuck bug law).
        listenable: _service,
        builder: (final context, final _) => ViewTabStrip(
          viewId: _layout.activeView,
          layout: _layout,
          surfaces: surfaces,
          onSelect: (final id) => _onSelectTab(_layout.activeView, id),
          onClose: (final id) =>
              _onLayoutChanged(_layout.closeTab(_layout.activeView, id)),
          onNewTab: _openNewTab,
          titleFor: (final id) =>
              conversationSurfaceTitle(
                id,
                channels: _service.channels,
                actors: _service.roster?.all ?? const <ActorProfile>[],
              ) ??
              _documentTitle(id),
          leadingFor: _leadingFor,
        ),
      ),
      Expanded(child: widget.child),
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

/// Phase 2 — the ⌘K command palette intent.
class _PaletteIntent extends Intent {
  const _PaletteIntent();
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

/// The `/home` route body: the ACTIVE view's ACTIVE tab host. The strip
/// lives above it in the shell; the body only mounts the focused surface.
/// Pushed project routes render as full pages of the navigator above it;
/// the rail and the strips (and their state) survive the round-trip.
final class CenterTabsArea extends StatelessWidget {
  const CenterTabsArea({super.key});

  @override
  Widget build(final BuildContext context) {
    final scope = ViewScope.of(context);
    if (scope == null) {
      // Honest absence: the area only makes sense inside the shell.
      return const Center(child: Text('center tabs require the app shell'));
    }
    final activeId = scope.layout.activeSurfaceId;
    if (activeId == null) {
      return const SizedBox.shrink();
    }
    // Conversation surface ids (`dm:`/`channel:`) are not in the static
    // registry — they share the ONE conversation slot, so they resolve
    // onto its [WorldChatSurface] spec.
    final spec =
        scope.surfaces[activeId] ??
        conversationSurfaceSpec(activeId, scope.surfaces) ??
        documentSurfaceSpec(activeId);
    return KeyedSubtree(
      key: ValueKey('pane.leaf.$activeId'),
      child: spec == null
          ? UnknownSurface(surfaceId: activeId)
          : Builder(builder: spec.builder),
    );
  }
}
