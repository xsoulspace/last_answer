/// ADR 0024 — the shell's surface registry: what a center tab can host.
///
/// Surface ids (v1):
/// - `conversations` — the world conversation surface over the durable
///   realm threads ([WorldChatSurface]).
/// - `browser` — the embedded workspace browser ([WorkspaceBrowser]).
/// - `inspector` — the real world inspector ([WorldInspectorPane]),
///   collapsed to its ONE status rule by default; expanding fills the
///   tab (the pane is a pure embed — the fullscreen page's Scaffold and
///   close button are its own wrapper, not the pane's).
///
/// Conversation ids (`dm:<actorId>`, `channel:<channelId>`) are not in
/// the static registry — they share the ONE conversation slot and map
/// onto the same [WorldChatSurface]; see center_tabs.dart for the
/// mapping.
///
/// `settings` is deliberately absent: [SettingsScreen]'s close button
/// pops the enclosing route, so hosting it in a tab would pop the whole
/// shell. The rail's gear pushes the settings route until Settings grows
/// an embedding seam (open tab callback instead of `Navigator.pop`).
library;

import 'package:lastanswer/browser/browser_strings.dart';

import 'package:lastanswer/browser/workspace_browser.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';

import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';

import 'package:lastanswer/common_imports.dart';

/// Declarative description of one surface kind that can live in a
/// center tab.
final class SurfaceSpec {
  const SurfaceSpec({
    required this.id,
    required this.title,
    required this.builder,
    this.icon,
    this.leading,
  });

  final String id;

  /// Human title shown in the tab strip.
  final String title;
  final IconData? icon;

  /// Builds the surface content.
  final WidgetBuilder builder;

  /// Small identity widget (e.g. an avatar) rendered before the title.
  final Widget? leading;
}

/// The shell's surface vocabulary, keyed by surface id.
typedef SurfaceRegistry = Map<String, SurfaceSpec>;

/// The id of the surface the default strip opens: the world conversation.
const String kConversationsSurfaceId = 'conversations';

/// The browser tab's surface id.
const String kBrowserSurfaceId = 'browser';

/// The world inspector tab's surface id.
const String kInspectorSurfaceId = 'inspector';

/// The new-tab picker's surface id (WAVE 4T — the browser model): the
/// strip's `+` opens it, picking a destination replaces it in place.
/// It is session chrome, not a persisted face — a LONE newtab tab does
/// not survive a restart ([CenterTabs.fromJson] maps it back to the
/// default conversations face).
const String kNewTabSurfaceId = 'newtab';

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
  // The newtab picker's spec is composed by AppShell (center_tabs.dart
  // hosts the [NewTabSurface] and the scope it navigates through) —
  // this module stays a leaf and never imports the tabs feature.
};

/// The inspector tab's embedding seam. [WorldInspectorPane] is a pure
/// embed (no route, no scaffold, no MediaQuery sizing — the fullscreen
/// page's Scaffold and close button are its own wrapper, not the
/// pane's), and it polls the ONE session registry by default
/// ([HarnessSessionRegistry.instance], the same index the doc surfaces
/// register under) — so the tab owes it only what the doc composition
/// owns elsewhere: a store for the picked world binding. The pane is
/// stateless about the binding (its caller persists it — under the doc,
/// into the doc payload); without a store the connect affordance would
/// silently drop the pick. Tab-local state keeps the affordance honest
/// for the tab's lifetime. Named follow-up: persist the binding beyond
/// the leaf swap (workspace-level state) if the inspector tab grows a
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
    // The tab is a bounded surface: expanding fills the tab, it does
    // not open a fixed-height strip. Collapsed stays ONE status rule —
    // the honest landing state (product DESIGN §10 attention dial).
    expandedHeight: double.infinity,
    onBindingChanged: (final binding) => setState(() => _binding = binding),
  );
}
