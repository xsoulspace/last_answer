/// ADR 0024 — the shell's surface registry: what a view can host.
/// WAVE 5 — ONE registry for the unified views (docs/design/
/// unified-views.md): the same [SurfaceSpec] renders as a top-bar tab
/// (focused in the center) or as a docked pin (the dock). Presentations
/// multiply; the registry is one.
///
/// View ids:
/// - `conversations` — the world conversation surface over the durable
///   realm threads ([WorldChatSurface]).
/// - `browser` — the embedded workspace browser ([WorkspaceBrowser]).
/// - `inspector` — the real world inspector ([WorldInspectorPane]),
///   collapsed to its ONE status rule by default; expanding fills the
///   view (the pane is a pure embed — the fullscreen page's Scaffold
///   and close button are its own wrapper, not the pane's).
/// - `filesystem` — the FILESYSTEM view (RENAMED from the panel's
///   `docs`; it absorbs the old Files tab): the workspace folder tree
///   ([WorkspaceFilesTab] as-is).
/// - `people` — the actor-profile view ([PeopleView], promoted from
///   the context panel).
/// - `terminal`, `threads` — honest quiet states; the information
///   architecture exists before their content lands.
/// - `newtab` — the picker (session chrome, never persisted).
///
/// Conversation ids (`dm:<actorId>`, `channel:<channelId>`) are not in
/// the static registry — they share the ONE conversation slot and map
/// onto the same [WorldChatSurface] ([conversationSurfaceSpec] in
/// app_shell.dart).
///
/// `settings` is a surface like any other (phase 1e): [SettingsScreen]
/// grew the embedding seam (`onClose` + `embedded`), so the rail's gear
/// opens a TAB of the active view and the shell grammar keeps zero
/// exceptions.
library;

import 'package:lastanswer/browser/browser_strings.dart';
import 'package:lastanswer/browser/workspace_browser.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/board_view.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/settings.dart';
import 'package:lastanswer/shell/shell_scope.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/view_documents.dart';
import 'package:lastanswer/shell/view_models.dart';
import 'package:lastanswer/shell/view_people.dart';
import 'package:lastanswer/shell/view_threads.dart';
import 'package:lastanswer/workspaces/workspace_files_tab.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';

/// Declarative description of one surface kind that can live in a view
/// (top-bar tab or dock pin).
final class SurfaceSpec {
  const SurfaceSpec({
    required this.id,
    required this.title,
    required this.builder,
    this.icon,
    this.leading,
  });

  final String id;

  /// Human title shown in the tab bar and the dock pills.
  final String title;
  final IconData? icon;

  /// Builds the surface content.
  final WidgetBuilder builder;

  /// Small identity widget (e.g. an avatar) rendered before the title.
  final Widget? leading;
}

/// The shell's surface vocabulary, keyed by surface id.
typedef SurfaceRegistry = Map<String, SurfaceSpec>;

/// The id of the surface the default bar opens: the world conversation.
const String kConversationsSurfaceId = 'conversations';

/// The browser view's surface id.
const String kBrowserSurfaceId = 'browser';

/// The world inspector view's surface id.
const String kInspectorSurfaceId = 'inspector';

/// The FILESYSTEM view's surface id (the workspace folder tree; the
/// panel's `docs` view renamed and merged with the old Files tab).
const String kFilesystemSurfaceId = 'filesystem';

/// The people view's surface id (the default pin).
const String kPeopleSurfaceId = 'people';

/// The terminal view's surface id (an honest quiet state today).
const String kTerminalSurfaceId = 'terminal';

/// The threads view's surface id (an honest quiet state today).
const String kThreadsSurfaceId = 'threads';

/// The boards view's surface id — plans, decomposition and delegation
/// rows on the ecsly_boards substrate (the boards program, stage 4).
const String kBoardsSurfaceId = 'boards';

/// The Models surface's id (phase 1d): the dynamic palette read model —
/// rungs × health × ladder × telemetry, the daemon's arm controls and
/// the palette editor. Opened from the status edge or the picker; not a
/// rail view (it is a fact surface, not a workspace).
const String kModelsSurfaceId = 'models';

/// The Documents view's surface id (phase 3a): the human document
/// navigation — the registry's grid, opened documents as tabs of this
/// view (`doc:<id>`).
const String kDocumentsSurfaceId = 'documents';

/// The settings surface's id (phase 1e): settings-as-view — the shell
/// grammar has no exceptions, so the rail's gear opens a TAB of the
/// active view instead of pushing a route (the embedded seam closes
/// through the view, never through `Navigator.pop`).
const String kSettingsSurfaceId = 'settings';

/// The RETIRED picker-tab's surface id (WAVE 4T's browser model: the
/// `+` opened the picker AS A TAB). DESIGN.md v2 made the picker an
/// anchored MENU — this constant survives only as migration vocabulary:
/// legacy blobs may contain `newtab` tabs, and the layout's tolerant
/// decode drops them (session chrome never survives a restart).
const String kNewTabSurfaceId = 'newtab';

/// Whether [surfaceId] stands for a conversation — the world face, a
/// rail-selected `dm:`/`channel:`, or a watchable `room:<threadId>`
/// (1d: actor↔actor rooms and group threads are rooms like any other)
/// — and therefore shares the ONE conversation slot in the bar.
bool isConversationSurfaceId(final String surfaceId) =>
    surfaceId == kConversationsSurfaceId ||
    surfaceId.startsWith('dm:') ||
    surfaceId.startsWith('channel:') ||
    surfaceId.startsWith('room:');

/// The surface id standing for the service's focused thread. DM and
/// channel threads map to their rail-object slots; ANY OTHER thread
/// (an actor↔actor room, a group thread — the 1d watchable rooms)
/// maps to its own `room:<threadId>` slot, so the room the human is
/// IN always has a tab. Null only when nothing is selected.
String? conversationSurfaceId({
  required final String? activeThreadId,
  required final Iterable<ChannelInfo> channels,
  required final Iterable<ActorProfile> actors,
  required final String? Function(String actorId) dmThreadOf,
}) {
  if (activeThreadId == null) return null;
  for (final channel in channels) {
    if (channel.threadId == activeThreadId) {
      return 'channel:${channel.channelId}';
    }
  }
  for (final actor in actors) {
    if (dmThreadOf(actor.actorId) == activeThreadId) {
      return 'dm:${actor.actorId}';
    }
  }
  return 'room:$activeThreadId';
}

/// The human title of a conversation surface id (the tab label), null
/// when the registry's own title covers it or the rail object is
/// unknown (the bar falls back to the raw id — honest, never blank).
/// A `room:` tab titles from the thread's topic via [topicOf].
String? conversationSurfaceTitle(
  final String surfaceId, {
  required final Iterable<ChannelInfo> channels,
  required final Iterable<ActorProfile> actors,
  final String? Function(String threadId)? topicOf,
}) {
  if (surfaceId.startsWith('channel:')) {
    final channelId = surfaceId.substring('channel:'.length);
    for (final channel in channels) {
      if (channel.channelId == channelId) return '#${channel.name}';
    }
    return null;
  }
  if (surfaceId.startsWith('dm:')) {
    final actorId = surfaceId.substring('dm:'.length);
    for (final actor in actors) {
      if (actor.actorId == actorId) return actor.displayName;
    }
    return null;
  }
  if (surfaceId.startsWith('room:')) {
    return topicOf?.call(surfaceId.substring('room:'.length));
  }
  return null;
}

/// Whether [surfaceId] stands for an opened document tab (phase 3a).
bool isDocumentSurfaceId(final String surfaceId) =>
    surfaceId.startsWith('doc:');

/// Whether [surfaceId] stands for the browser surface or one of its
/// INSTANCES (the tab law: the same kind opens N times — `browser:2`).
bool isBrowserSurfaceId(final String surfaceId) =>
    surfaceId == kBrowserSurfaceId || surfaceId.startsWith('browser:');

/// The spec for a `browser:<n>` instance tab: the one browser surface,
/// per instance (each tab mounts its own [WorkspaceBrowser] state).
SurfaceSpec? browserSurfaceSpec(
  final String surfaceId,
  final SurfaceRegistry surfaces,
) {
  if (!surfaceId.startsWith('browser:')) return null;
  final base = surfaces[kBrowserSurfaceId];
  if (base == null) return null;
  final n = surfaceId.substring('browser:'.length);
  return SurfaceSpec(
    id: surfaceId,
    title: '${base.title} $n',
    builder: base.builder,
    icon: base.icon,
  );
}

/// The action-bar KIND of a tab id (DESIGN.md v2: the rail is a
/// Discord-style action bar of rounded-square kind icons; one click
/// opens the kind, further clicks cycle its open tabs). Conversation
/// ids fold into `conversations`, documents into `documents`, browser
/// instances into `browser`; static registry ids are their own kind.
String kindOfSurfaceId(final String surfaceId) {
  if (isConversationSurfaceId(surfaceId)) return kConversationsSurfaceId;
  if (isDocumentSurfaceId(surfaceId)) return kDocumentsSurfaceId;
  if (isBrowserSurfaceId(surfaceId)) return kBrowserSurfaceId;
  return surfaceId;
}

/// The spec for a `doc:<id>` tab: the registry's projection of the
/// document through the route page's own doc→surface map, embedded.
SurfaceSpec? documentSurfaceSpec(final String surfaceId) {
  if (!isDocumentSurfaceId(surfaceId)) return null;
  final docId = surfaceId.substring('doc:'.length);
  return SurfaceSpec(
    id: surfaceId,
    title: docId,
    builder: (final _) => DocumentsTabHost(docId: docId),
    icon: Icons.description_outlined,
  );
}

/// The spec for a conversation surface id (`dm:`/`channel:`/`room:`):
/// the ONE conversation slot's [WorldChatSurface]. Null for anything
/// that is neither a static surface nor a conversation slot id
/// (honest unknown).
SurfaceSpec? conversationSurfaceSpec(
  final String surfaceId,
  final SurfaceRegistry surfaces,
) {
  if (!surfaceId.startsWith('dm:') &&
      !surfaceId.startsWith('channel:') &&
      !surfaceId.startsWith('room:')) {
    return null;
  }
  return surfaces[kConversationsSurfaceId];
}

/// Builds the shell's surface registry against [context] (for l10n and
/// DI). Pass [service] to pin the conversation service (tests); when
/// null the registry resolves it through the provider tree.
SurfaceRegistry buildShellSurfaces(
  final BuildContext context, {
  final RealmChatService? service,
}) => {
  kConversationsSurfaceId: SurfaceSpec(
    id: kConversationsSurfaceId,
    title: context.l10n.worldChatConversations,
    builder: (final tabContext) => WorldChatSurface(
      service: service ?? tabContext.read<RealmChatService?>(),
    ),
    icon: Icons.forum_outlined,
  ),
  kBrowserSurfaceId: SurfaceSpec(
    id: kBrowserSurfaceId,
    title: BrowserStrings.of(context).windowTitle,
    builder: (final _) => const WorkspaceBrowser(),
    icon: Icons.web,
  ),
  kInspectorSurfaceId: SurfaceSpec(
    id: kInspectorSurfaceId,
    title: context.l10n.settingsWorldInspector,
    builder: (final tabContext) => const _InspectorTabEmbed(),
    icon: Icons.travel_explore,
  ),
  kFilesystemSurfaceId: SurfaceSpec(
    id: kFilesystemSurfaceId,
    title: context.l10n.viewFilesystemTitle,
    builder: (final tabContext) {
      // The workspace registry's folders (ADR 0026) — the same
      // [WorkspaceFilesTab] the panel's FILES tab mounted, now the
      // filesystem view's body. Nullable read: hermetic shells without
      // DI keep the view's honest empty note.
      final workspaces = tabContext.read<WorkspaceNotifier?>();
      if (workspaces == null) {
        return _QuietViewNote(text: context.l10n.workspacesFilesEmpty);
      }
      return WorkspaceFilesTab(notifier: workspaces);
    },
    icon: Icons.folder_outlined,
  ),
  kPeopleSurfaceId: SurfaceSpec(
    id: kPeopleSurfaceId,
    title: context.l10n.contextTabPeople,
    builder: (final tabContext) {
      final peopleService = service ?? tabContext.read<RealmChatService?>();
      if (peopleService == null) {
        return _QuietViewNote(text: tabContext.l10n.worldChatSelectFromRail);
      }
      return PeopleView(
        service: peopleService,
        focus: tabContext.read<PeopleFocus?>(),
      );
    },
    icon: Icons.people_outline,
  ),
  kTerminalSurfaceId: SurfaceSpec(
    id: kTerminalSurfaceId,
    title: context.l10n.contextTabTerminal,
    // Phase 3c — the honest note stays (no PTY yet), but the status
    // edge's arm instruction routes into a ONE-CLICK action here
    // (redesign §2.2.3).
    builder: (final tabContext) =>
        _TerminalViewEmbed(world: tabContext.read<WorldStateService?>()),
    icon: Icons.terminal,
  ),
  kThreadsSurfaceId: SurfaceSpec(
    id: kThreadsSurfaceId,
    title: context.l10n.contextTabThreads,
    // Phase 3b — the threads the rail cannot name: plain group threads
    // and the live session registry, read-only.
    builder: (final tabContext) {
      final scope = ViewScope.of(tabContext);
      return ThreadsView(
        service: service ?? tabContext.read<RealmChatService?>(),
        onOpenThread: (final threadId) {
          final chat = service ?? tabContext.read<RealmChatService?>();
          chat?.selectThread(threadId);
          if (scope == null) return;
          // 1d — the thread opens as ITS OWN room tab (dm:/channel:
          // when a rail object names it, room:<threadId> otherwise),
          // never as a face swap that leaves the tab bar lying.
          final surfaceId =
              conversationSurfaceId(
                activeThreadId: threadId,
                channels: chat?.channels ?? const <ChannelInfo>[],
                actors: chat?.roster?.all ?? const <ActorProfile>[],
                dmThreadOf: chat?.dmThreadOf ?? (_) => null,
              ) ??
              kConversationsSurfaceId;
          scope.onChanged(scope.layout.showView(surfaceId));
        },
      );
    },
    icon: Icons.account_tree_outlined,
  ),
  kBoardsSurfaceId: SurfaceSpec(
    id: kBoardsSurfaceId,
    // The boards program's product face (plans, decomposition,
    // delegation rows on one substrate); the view is key-contracted
    // (board.*).
    title: context.l10n.viewBoardsTitle,
    builder: (final tabContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BoardView(
            // The mesh-synced controller when the mesh seams are
            // attached; otherwise the view owns a session-local one.
            controller: tabContext
                .read<StorageBackendsNotifier?>()
                ?.planningController,
          ),
        ),
        // Phase 3c — the mesh task rows settle HERE, beside the cards
        // they belong to (redesign §2.2.4), not only in Settings.
        _MeshTasksSection(
          backends: tabContext.read<StorageBackendsNotifier?>(),
        ),
      ],
    ),
    icon: Icons.view_kanban_outlined,
  ),
  kModelsSurfaceId: SurfaceSpec(
    id: kModelsSurfaceId,
    title: context.l10n.viewModelsTitle,
    builder: (final tabContext) {
      // The world's read model (phase 1d); a hermetic shell without it
      // keeps the honest quiet note.
      final world = tabContext.read<WorldStateService?>();
      if (world == null) {
        return _QuietViewNote(text: tabContext.l10n.modelsNoPalette);
      }
      return ModelsView(world: world);
    },
    icon: Icons.tune,
  ),
  kDocumentsSurfaceId: SurfaceSpec(
    id: kDocumentsSurfaceId,
    title: context.l10n.viewDocumentsTitle,
    builder: (final tabContext) => const DocumentsView(),
    icon: Icons.description_outlined,
  ),
  kSettingsSurfaceId: SurfaceSpec(
    id: kSettingsSurfaceId,
    title: context.l10n.settings,
    builder: (final tabContext) => SettingsScreen(
      embedded: true,
      // The embedded seam: close means close THIS TAB through the view
      // scope — a Navigator.pop from inside a view would pop the shell.
      onClose: () {
        final scope = ViewScope.of(tabContext);
        if (scope == null) return;
        scope.onChanged(scope.layout.closeTab(kSettingsSurfaceId));
      },
    ),
    icon: Icons.settings_outlined,
  ),
  // The new-tab picker is an anchored MENU (new_tab_menu.dart), not a
  // surface: the registry has no `newtab` entry any more.
};

/// The terminal view's honest state: no PTY yet (the package decision
/// is separate), the quiet note plus — when the world is down — the
/// ONE-click arm the status edge's instruction routes to (phase 3c).
final class _TerminalViewEmbed extends StatelessWidget {
  const _TerminalViewEmbed({required this.world});

  final WorldStateService? world;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    final down = world != null && !world!.daemonLive;
    return ListenableBuilder(
      listenable: world ?? ValueNotifier(0),
      builder: (final context, final _) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _QuietViewNote(text: l10n.contextTerminalEmpty),
          if (down) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  world!.armState == WorldArmState.error
                      ? '${l10n.inboxWorldArmFailed}: ${world!.armError ?? ''}'
                      : l10n.inboxWorldDown,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: la.inkMuted),
                ),
                const SizedBox(width: 10),
                TextButton(
                  key: const ValueKey('terminal.arm'),
                  onPressed: world!.armState == WorldArmState.arming
                      ? null
                      : () => unawaited(world!.armWorld()),
                  child: Text(
                    world!.armState == WorldArmState.arming
                        ? l10n.edgeArming
                        : l10n.edgeArmWorld,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The mesh task board's rows as settle data beside the planning cards
/// (phase 3c): status, the sentence, the verdict word. Absent mesh =
/// absent section — the board only exists once a replica is live.
final class _MeshTasksSection extends StatelessWidget {
  const _MeshTasksSection({required this.backends});

  final StorageBackendsNotifier? backends;

  @override
  Widget build(final BuildContext context) {
    final records = backends?.taskBoard?.allRecords ?? const [];
    if (records.isEmpty) return const SizedBox.shrink();
    final la = context.la;
    return Container(
      key: const ValueKey('boards.meshTasks'),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: la.rule)),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 4),
            child: Text(
              context.l10n.boardsMeshTasks,
              style: shellSectionLabel(context),
            ),
          ),
          for (final record in records.take(8))
            Container(
              key: ValueKey('boards.mesh.${record.taskId}'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: Row(
                children: [
                  Text(
                    '[${record.status}]',
                    style: LaTokens.mono(10, la.inkQuiet),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.task,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  if (record.verdict case final verdict?)
                    Text(
                      '${verdict['status'] ?? ''}',
                      style: LaTokens.mono(10, la.inkMuted),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A view's quiet named empty state: honest absence, one line.
final class _QuietViewNote extends StatelessWidget {
  const _QuietViewNote({required this.text});

  final String text;

  @override
  Widget build(final BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        key: const ValueKey('view.empty'),
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: context.shellMuted),
      ),
    ),
  );
}

/// The inspector view's embedding seam. [WorldInspectorPane] is a pure
/// embed (no route, no scaffold, no MediaQuery sizing — the fullscreen
/// page's Scaffold and close button are its own wrapper, not the
/// pane's), and it polls the ONE session registry by default
/// ([HarnessSessionRegistry.instance], the same index the doc surfaces
/// register under) — so the view owes it only what the doc composition
/// owns elsewhere: a store for the picked world binding. The pane is
/// stateless about the binding (its caller persists it — under the doc,
/// into the doc payload); without a store the connect affordance would
/// silently drop the pick. View-local state keeps the affordance honest
/// for the view's lifetime. Named follow-up: persist the binding beyond
/// the leaf swap (workspace-level state) if the inspector view grows a
/// store of its own.
final class _InspectorTabEmbed extends StatefulWidget {
  const _InspectorTabEmbed();

  @override
  State<_InspectorTabEmbed> createState() => _InspectorTabEmbedState();
}

final class _InspectorTabEmbedState extends State<_InspectorTabEmbed> {
  WorldBindingModel? _binding;

  @override
  Widget build(final BuildContext context) => WorldInspectorPane(
    binding: _binding,
    // The view is a bounded surface: expanding fills the view, it does
    // not open a fixed-height strip. Collapsed stays ONE status rule —
    // the honest landing state (product DESIGN §10 attention dial).
    expandedHeight: double.infinity,
    onBindingChanged: (final binding) => setState(() => _binding = binding),
  );
}
