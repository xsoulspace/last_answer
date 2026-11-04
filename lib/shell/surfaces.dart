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
/// `settings` is deliberately absent: [SettingsScreen]'s close button
/// pops the enclosing route, so hosting it in a view would pop the
/// whole shell. The rail's gear pushes the settings route until
/// Settings grows an embedding seam (open-view callback instead of
/// `Navigator.pop`).
library;

import 'package:lastanswer/browser/browser_strings.dart';

import 'package:lastanswer/browser/workspace_browser.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/board_view.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';

import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';

import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/view_people.dart';

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

/// The new-tab picker's surface id (WAVE 4T — the browser model): the
/// bar's `+` opens it, picking a destination replaces it in place.
/// It is session chrome, not a persisted face — a LONE newtab tab does
/// not survive a restart (the layout's tolerant decode maps it back to
/// the default conversations face).
const String kNewTabSurfaceId = 'newtab';

/// Whether [surfaceId] stands for a conversation — the world face or a
/// rail-selected `dm:`/`channel:` — and therefore shares the ONE
/// conversation slot in the bar.
bool isConversationSurfaceId(final String surfaceId) =>
    surfaceId == kConversationsSurfaceId ||
    surfaceId.startsWith('dm:') ||
    surfaceId.startsWith('channel:');

/// Whether [surfaceId]'s tab carries the pin affordance: every STATIC
/// registry view is pin-able. Conversation slot ids (`dm:`/`channel:`)
/// and the picker are not (the picker is chrome; pinned conversations
/// arrive later — the model already holds them).
bool isPinnableSurfaceId(final String surfaceId) =>
    surfaceId != kNewTabSurfaceId &&
    !surfaceId.startsWith('dm:') &&
    !surfaceId.startsWith('channel:');

/// The surface id standing for the service's focused thread, or null
/// when the thread maps to no rail object (nothing selected, or an
/// unregistered group thread): the shell keeps the slot's current face
/// rather than guessing.
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
  return null;
}

/// The human title of a conversation surface id (the tab label), null
/// when the registry's own title covers it or the rail object is
/// unknown (the bar falls back to the raw id — honest, never blank).
String? conversationSurfaceTitle(
  final String surfaceId, {
  required final Iterable<ChannelInfo> channels,
  required final Iterable<ActorProfile> actors,
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
  return null;
}

/// The spec for a conversation surface id (`dm:`/`channel:`): the ONE
/// conversation slot's [WorldChatSurface]. Null for anything that is
/// neither a static surface nor a conversation slot id (honest
/// unknown).
SurfaceSpec? conversationSurfaceSpec(
  final String surfaceId,
  final SurfaceRegistry surfaces,
) {
  if (!surfaceId.startsWith('dm:') && !surfaceId.startsWith('channel:')) {
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
      service:
          service ?? tabContext.read<RealmChatService?>(),
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
    builder: (final tabContext) =>
        _QuietViewNote(text: tabContext.l10n.contextTerminalEmpty),
    icon: Icons.terminal,
  ),
  kThreadsSurfaceId: SurfaceSpec(
    id: kThreadsSurfaceId,
    title: context.l10n.contextTabThreads,
    builder: (final tabContext) =>
        _QuietViewNote(text: tabContext.l10n.contextThreadsEmpty),
    icon: Icons.account_tree_outlined,
  ),
  kBoardsSurfaceId: SurfaceSpec(
    id: kBoardsSurfaceId,
    // The boards program's product face (plans, decomposition,
    // delegation rows on one substrate); the view is key-contracted
    // (board.*).
    title: context.l10n.viewBoardsTitle,
    builder: (final tabContext) => BoardView(
      // The mesh-synced controller when the mesh seams are attached;
      // otherwise the view owns a session-local one.
      controller: tabContext
          .read<StorageBackendsNotifier?>()
          ?.planningController,
    ),
    icon: Icons.view_kanban_outlined,
  ),
  // The newtab picker's spec is composed by AppShell (center_tabs.dart
  // hosts the [NewTabSurface] and the scope it navigates through) —
  // this module stays a leaf and never imports the tabs feature.
};

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
