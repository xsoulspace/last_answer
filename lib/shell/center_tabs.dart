/// ADR 0024 — the center's flat tab strip: the pane tree retired.
///
/// The shell's center pane is one ordered strip of surfaces; the tree's
/// splits/stacks/tree-editing are gone. Two surface vocabularies share
/// the strip:
///
/// - **Station surfaces** (`browser`, `inspector`, …): one tab each;
///   opening an already-open station focuses it.
/// - **The conversation slot**: every conversation surface id —
///   `dm:<actorId>`, `channel:<channelId>`, and the plain world face
///   `conversations` — maps to THE SAME slot. The actor rail does not
///   know about tabs; it selects through the service
///   ([RealmChatService.openDm] / [RealmChatService.selectChannel]),
///   and the shell translates the service's `activeThreadId` back to a
///   `dm:`/`channel:` surface id ([conversationSurfaceId]) and REPLACES
///   the slot's id in place (Discord flow — rail clicks accumulate zero
///   tabs). An explicit new-tab intent (a ⌘-click on a rail row) opens a
///   second conversation tab instead ([CenterTabs.openConversation]
///   with `forceNew`).
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `center.tabs` (the strip), `center.tabs.add` (the trailing `+`),
/// `pane.tab.<surfaceId>` (select), `pane.tab.close.<surfaceId>`
/// (close), `pane.leaf.<surfaceId>` (the active content host),
/// `newtab.page` (the picker page) and `newtab.entry.<surfaceId>`
/// (its destinations).
///
/// The browser-model laws (WAVE 4T):
/// - the `+` opens/focuses the ONE newtab tab ([CenterTabs.openNewTab]);
/// - picking a destination replaces the newtab tab in place
///   ([CenterTabs.pick]);
/// - closing the LAST tab swaps the newtab surface in — the window
///   keeps a page ([CenterTabs.close]);
/// - the picker is session chrome: a lone newtab tab never survives a
///   restart ([CenterTabs.fromJson]).
library;

import 'package:flutter/foundation.dart' show listEquals;

import 'package:flutter/gestures.dart' show kMiddleMouseButton;

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/surfaces.dart';

/// Whether [surfaceId] stands for a conversation — the world face or a
/// rail-selected `dm:`/`channel:` — and therefore shares the ONE
/// conversation slot in the strip.
bool isConversationSurfaceId(final String surfaceId) =>
    surfaceId == kConversationsSurfaceId ||
    surfaceId.startsWith('dm:') ||
    surfaceId.startsWith('channel:');

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
/// unknown (the strip falls back to the raw id — honest, never blank).
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

/// The center's tab strip state: an ordered list of unique surface ids
/// plus the active index (kept clamped by every operation). Pure value
/// semantics — every operation returns a new [CenterTabs].
@immutable
final class CenterTabs {
  /// Normalizing constructor: duplicate ids keep their first occurrence,
  /// an empty strip falls back to the world conversations surface, and
  /// [active] is clamped into range.
  factory CenterTabs({
    final List<String> surfaceIds = const <String>[kConversationsSurfaceId],
    final int active = 0,
  }) {
    final deduped = <String>[];
    for (final id in surfaceIds) {
      if (!deduped.contains(id)) deduped.add(id);
    }
    if (deduped.isEmpty) deduped.add(kConversationsSurfaceId);
    return CenterTabs._(
      List.unmodifiable(deduped),
      active.clamp(0, deduped.length - 1),
    );
  }

  /// The backing constructor; the factory normalizes first.
  CenterTabs._(final List<String> ids, this.active)
    : surfaceIds = List.unmodifiable(ids);

  /// Decodes the persisted shape `{"tabs": [...], "active": n}`.
  /// Tolerant: anything unusable decodes to the default strip. A LONE
  /// newtab tab does not survive a restart — the picker is session
  /// chrome, so the restore lands on the default conversations face.
  factory CenterTabs.fromJson(final Object? json) {
    if (json is! Map) return CenterTabs();
    final rawTabs = json['tabs'];
    final tabs = <String>[
      if (rawTabs is List)
        for (final id in rawTabs)
          if (id is String && id.isNotEmpty) id,
    ];
    // The factory dedupes below; judge lone-ness on the deduped list,
    // so a corrupt `['newtab', 'newtab']` remaps too.
    if (tabs.isNotEmpty && tabs.every((final id) => id == kNewTabSurfaceId)) {
      return CenterTabs();
    }
    final active = json['active'];
    return CenterTabs(
      surfaceIds: tabs,
      active: active is int ? active : 0,
    );
  }

  /// Ordered, unique surface ids; never empty.
  final List<String> surfaceIds;

  /// The focused index, always in range.
  final int active;

  /// The focused surface id.
  String get activeId => surfaceIds[active];

  /// The conversation slot's index (the first conversation-surface tab),
  /// or null when the strip hosts no conversation.
  int? get _conversationSlot {
    for (var i = 0; i < surfaceIds.length; i++) {
      if (isConversationSurfaceId(surfaceIds[i])) return i;
    }
    return null;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'tabs': List<String>.of(surfaceIds),
    'active': active,
  };

  /// Focuses [surfaceId], opening it right of the active tab when new.
  /// Stations open their own tab; conversation ids go through
  /// [openConversation] — use this for direct strip taps.
  CenterTabs open(final String surfaceId) {
    final existing = surfaceIds.indexOf(surfaceId);
    if (existing >= 0) return _focus(existing);
    return _insertAndFocus(surfaceId);
  }

  /// The strip's `+` flow: opens the picker as a new active tab, right
  /// of the active tab. At most ONE newtab tab exists — an already-open
  /// picker just focuses (this stays true because every id is unique in
  /// the strip and only [openNewTab]/[pick] write the picker's id).
  CenterTabs openNewTab() => open(kNewTabSurfaceId);

  /// The picker's flow: choosing a destination replaces the newtab tab
  /// IN PLACE (a bookmark click on a browser's new-tab page navigates
  /// THAT tab — position and neighbors unchanged). A destination that
  /// already holds its own tab focuses it and the picker closes
  /// instead: stations stay unique in the strip. Without a picker tab
  /// this degrades to [open]; picking the picker itself changes nothing.
  CenterTabs pick(final String surfaceId) {
    if (surfaceId == kNewTabSurfaceId) return this;
    final pickerIndex = surfaceIds.indexOf(kNewTabSurfaceId);
    if (pickerIndex < 0) return open(surfaceId);
    final existing = surfaceIds.indexOf(surfaceId);
    if (existing >= 0) {
      final ids = List<String>.of(surfaceIds)..removeAt(pickerIndex);
      final target = pickerIndex < existing ? existing - 1 : existing;
      return CenterTabs(surfaceIds: ids, active: target);
    }
    final ids = List<String>.of(surfaceIds);
    ids[pickerIndex] = surfaceId;
    return CenterTabs(surfaceIds: ids, active: pickerIndex);
  }

  /// The rail's conversation flow: `dm:`/`channel:` ids reuse the ONE
  /// conversation slot — the slot's id is replaced in place, position
  /// and the tab count unchanged (zero tab accumulation). With
  /// `forceNew` (the rail's ⌘-click intent) the id gets its own tab
  /// instead, inserted next to the slot. When the strip hosts no
  /// conversation slot the id revives one.
  CenterTabs openConversation(
    final String surfaceId, {
    final bool forceNew = false,
  }) {
    final slot = _conversationSlot;
    if (slot == null) return _insertAndFocus(surfaceId);
    if (!forceNew) {
      // Already the slot's face: nothing changes.
      if (surfaceIds[active] == surfaceId) return this;
      final kept = <String>[
        for (var i = 0; i < surfaceIds.length; i++)
          if (i == slot)
            surfaceId
          else if (surfaceIds[i] != surfaceId)
            surfaceIds[i],
      ];
      return CenterTabs(surfaceIds: kept, active: slot);
    }
    final existing = surfaceIds.indexOf(surfaceId);
    if (existing >= 0) return _focus(existing);
    final ids = List<String>.of(surfaceIds)..insert(slot + 1, surfaceId);
    return CenterTabs(surfaceIds: ids, active: slot + 1);
  }

  /// Closes [surfaceId]'s tab (the ✕, middle-click, or ⌘W). A browser
  /// never shows zero tabs: closing the LAST tab swaps the newtab
  /// surface in — the window keeps a page. The lone PICKER itself is
  /// refused (there is nothing to swap into it; it stays — honest).
  /// Closing the active tab focuses its neighbor (the tab that takes
  /// its place, else the previous one).
  CenterTabs close(final String surfaceId) {
    final index = surfaceIds.indexOf(surfaceId);
    if (index < 0) return this;
    if (surfaceIds.length == 1) {
      if (surfaceId == kNewTabSurfaceId) return this;
      return CenterTabs(surfaceIds: const <String>[kNewTabSurfaceId]);
    }
    final ids = List<String>.of(surfaceIds)..removeAt(index);
    var nextActive = active;
    if (index < active) {
      nextActive = active - 1;
    } else if (index == active) {
      nextActive = index.clamp(0, ids.length - 1);
    }
    return CenterTabs(surfaceIds: ids, active: nextActive);
  }

  /// Moves the tab at [from] to [to]; the focused id stays focused.
  CenterTabs move(final int from, final int to) {
    if (from < 0 || from >= surfaceIds.length) return this;
    final focused = activeId;
    final ids = List<String>.of(surfaceIds);
    final id = ids.removeAt(from);
    ids.insert(to.clamp(0, ids.length), id);
    return CenterTabs(surfaceIds: ids, active: ids.indexOf(focused));
  }

  CenterTabs _focus(final int index) =>
      CenterTabs(surfaceIds: surfaceIds, active: index);

  CenterTabs _insertAndFocus(final String surfaceId) {
    final at = (active + 1).clamp(0, surfaceIds.length);
    final ids = List<String>.of(surfaceIds)..insert(at, surfaceId);
    return CenterTabs(surfaceIds: ids, active: at);
  }

  @override
  bool operator ==(final Object other) =>
      other is CenterTabs &&
      other.active == active &&
      listEquals(other.surfaceIds, surfaceIds);

  @override
  int get hashCode => Object.hash(active, Object.hashAll(surfaceIds));

  @override
  String toString() => 'CenterTabs($surfaceIds, active: $active)';
}

/// Flattens a LEGACY `shell.paneTree.v1` tree (`leaf`/`stack`/`split`
/// nodes) into its surface ids in document order — the one-time tab
/// migration reads this instead of keeping the deleted pane-tree model
/// alive. Unreadable nodes are skipped; the caller decides on an empty
/// result.
List<String> legacyPaneTreeSurfaceIds(final Object? json) {
  final ids = <String>[];
  void visit(final Object? node) {
    if (node is! Map) return;
    final surfaceId = node['surfaceId'];
    if (surfaceId is String && surfaceId.isNotEmpty) {
      ids.add(surfaceId);
      return;
    }
    final children = node['children'];
    if (children is List) {
      children.forEach(visit);
    }
  }

  visit(json);
  // Conversations is the strip's resident: bring it to the front, and
  // keep one tab per surface id (first occurrence wins).
  final ordered = <String>[];
  void keep(final String id) {
    if (!ordered.contains(id)) ordered.add(id);
  }

  if (ids.contains(kConversationsSurfaceId)) {
    keep(kConversationsSurfaceId);
  }
  ids.forEach(keep);
  return ordered;
}

/// The Codex-quiet tab strip: text tabs on one hairline — the active
/// tab reads through stronger ink plus a hairline underline, every tab
/// carries a ✕ (browser law: closing the last real tab swaps the
/// picker in, so only a lone PICKER tab keeps no ✕), the trailing `+`
/// opens the picker, tabs close on middle-click and drag to reorder.
/// Zero Material chrome: GestureDetector and hover only, no elevation,
/// no ripple. Overflow scrolls horizontally (Codex-like).
final class CenterTabsStrip extends StatelessWidget {
  const CenterTabsStrip({
    required this.tabs,
    required this.surfaces,
    this.onSelect,
    this.onClose,
    this.onNewTab,
    this.onReorder,
    this.titleFor,
    super.key,
  });

  /// The strip's state (ids + active index).
  final CenterTabs tabs;

  /// The surface registry (titles, icons, identity widgets).
  final SurfaceRegistry surfaces;

  /// Focuses a tab.
  final ValueChanged<String>? onSelect;

  /// Closes a tab; invoked from tabs whose close keeps a valid strip
  /// (✕, middle-click — the same availability law drives both).
  final ValueChanged<String>? onClose;

  /// Opens/focuses the new-tab picker (the strip's trailing `+`).
  final VoidCallback? onNewTab;

  /// Repositions a tab (drag reorder), as [CenterTabs.move] arguments.
  final void Function(int from, int to)? onReorder;

  /// Human title for ids the registry does not know (conversation
  /// surface ids); null falls back to the registry title, then the id.
  final String? Function(String surfaceId)? titleFor;

  /// A tab's ✕/middle-click is offered whenever closing it keeps the
  /// browser law intact: any tab while others exist, and the lone last
  /// REAL tab too (the picker swaps in). Only the lone PICKER keeps no
  /// close affordance — nothing exists to swap into it.
  bool _canClose(final int index) =>
      tabs.surfaceIds.length > 1 ||
      tabs.surfaceIds[index] != kNewTabSurfaceId;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return KeyedSubtree(
      key: const ValueKey('center.tabs'),
      child: Container(
        height: ShellTokens.tabHeight,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.shellHairline),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < tabs.surfaceIds.length; i++)
                _CenterTab(
                  key: ValueKey('pane.tab.${tabs.surfaceIds[i]}'),
                  surfaceId: tabs.surfaceIds[i],
                  index: i,
                  tabCount: tabs.surfaceIds.length,
                  title: _titleOf(tabs.surfaceIds[i]),
                  icon: surfaces[tabs.surfaceIds[i]]?.icon,
                  leading: surfaces[tabs.surfaceIds[i]]?.leading,
                  active: i == tabs.active,
                  style: theme.textTheme.labelMedium,
                  onTap: () => onSelect?.call(tabs.surfaceIds[i]),
                  onClose: _canClose(i)
                      ? () => onClose?.call(tabs.surfaceIds[i])
                      : null,
                  onReorder: onReorder,
                ),
              if (onNewTab != null) _NewTabButton(onTap: onNewTab!),
            ],
          ),
        ),
      ),
    );
  }

  String _titleOf(final String surfaceId) =>
      titleFor?.call(surfaceId) ??
      surfaces[surfaceId]?.title ??
      surfaceId;
}

/// The strip's trailing `+`: opens/focuses the new-tab picker. Quiet
/// ink, generous tap target, hover emphasis — the same chrome law as
/// the tabs themselves.
final class _NewTabButton extends StatefulWidget {
  const _NewTabButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_NewTabButton> createState() => _NewTabButtonState();
}

final class _NewTabButtonState extends State<_NewTabButton> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        key: const ValueKey('center.tabs.add'),
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          height: ShellTokens.tabHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.add,
              size: 15,
              color: _hovering
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.78)
                  : context.shellMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// One tab: quiet ink, hover emphasis, the active hairline underline,
/// a ✕ while its close keeps a valid strip, middle-click to close, and
/// horizontal drag to reposition (the simplest honest reorder: one
/// swap per dragged-tab-width of travel — the tap and the ✕ stay
/// tappable because taps resolve before the drag slop).
final class _CenterTab extends StatefulWidget {
  const _CenterTab({
    required this.surfaceId,
    required this.index,
    required this.tabCount,
    required this.title,
    required this.active,
    required this.style,
    required this.onTap,
    this.onClose,
    this.onReorder,
    this.icon,
    this.leading,
    super.key,
  });

  final String surfaceId;
  final String title;

  /// This tab's position in the strip (the drag's `from`).
  final int index;

  /// The strip's size (the drag's clamp).
  final int tabCount;
  final bool active;
  final TextStyle? style;
  final VoidCallback onTap;

  /// Closes the tab; null when no close affordance is offered (the
  /// lone picker tab).
  final VoidCallback? onClose;

  /// Repositions this tab, as [CenterTabs.move] arguments; null
  /// disables drag reorder.
  final void Function(int from, int to)? onReorder;
  final IconData? icon;
  final Widget? leading;

  @override
  State<_CenterTab> createState() => _CenterTabState();
}

final class _CenterTabState extends State<_CenterTab> {
  var _hovering = false;

  /// Horizontal travel since the last reorder (reset on each swap, so
  /// one tab-width of drag equals one position).
  double? _dragDx;

  void _onDragStart(final DragStartDetails details) {
    _dragDx = 0;
  }

  void _onDragUpdate(final DragUpdateDetails details) {
    final onReorder = widget.onReorder;
    if (onReorder == null) return;
    final width = context.size?.width ?? 0;
    if (width <= 0) return;
    _dragDx = (_dragDx ?? 0) + details.delta.dx;
    if (_dragDx!.abs() < width) return;
    final step = _dragDx!.isNegative ? -1 : 1;
    final target = (widget.index + step).clamp(0, widget.tabCount - 1);
    _dragDx = 0;
    if (target == widget.index) return;
    onReorder(widget.index, target);
  }

  void _onDragEnd(final DragEndDetails details) {
    _dragDx = null;
  }

  void _onDragCancel() {
    _dragDx = null;
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final emphasized = widget.active || _hovering;
    final color = widget.active
        ? theme.colorScheme.onSurface
        : _hovering
        ? theme.colorScheme.onSurface.withValues(alpha: 0.78)
        : context.shellMuted;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Listener(
        onPointerDown: (final event) {
          // Browser convention — middle-click closes. The button bits
          // live on DOWN (the same reason the rail row's gesture does).
          if (event.buttons == kMiddleMouseButton) widget.onClose?.call();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onHorizontalDragStart: widget.onReorder == null
              ? null
              : _onDragStart,
          onHorizontalDragUpdate: widget.onReorder == null
              ? null
              : _onDragUpdate,
          onHorizontalDragEnd: widget.onReorder == null
              ? null
              : _onDragEnd,
          onHorizontalDragCancel: widget.onReorder == null
              ? null
              : _onDragCancel,
          child: Container(
            height: ShellTokens.tabHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            // The active tab's ONE marker (DESIGN §3): the theme accent
            // as a 2px underline, plus the shared selected tint. Hover
            // reads quieter than active, never louder.
            decoration: BoxDecoration(
              color: widget.active ? context.shellSelected : null,
              border: widget.active
                  ? Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 6),
                ],
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 14, color: color),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.title,
                  style: (widget.style ?? const TextStyle()).copyWith(
                    color: color,
                    fontWeight: widget.active
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    key: ValueKey('pane.tab.close.${widget.surfaceId}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onClose,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        Icons.close,
                        size: 13,
                        color: emphasized
                            ? context.shellMuted
                            : context.shellMuted.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The shell's center-tabs scope: the strip state, the surface registry
/// and the change callback, inherited by the `/home` route body (and by
/// the new-tab picker, which navigates through it).
class CenterTabsScope extends InheritedWidget {
  const CenterTabsScope({
    required this.tabs,
    required this.surfaces,
    required this.onChanged,
    required super.child,
    super.key,
  });

  final CenterTabs tabs;
  final SurfaceRegistry surfaces;
  final ValueChanged<CenterTabs> onChanged;

  static CenterTabsScope? of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CenterTabsScope>();

  @override
  bool updateShouldNotify(final CenterTabsScope oldWidget) =>
      oldWidget.tabs != tabs || !identical(oldWidget.surfaces, surfaces);
}

/// WAVE 4T — the new-tab picker (Zed's New Tab, the browser model): a
/// quiet menu of destinations, not decorative cards. Each entry carries
/// a small icon tile, the surface's name and a one-line hint; tapping
/// one replaces THIS tab in place ([CenterTabs.pick]). Structure law:
/// generous tap targets on a hairline grid, no shadows, no elevation —
/// this is navigation, a separate design pass refines visuals later.
final class NewTabSurface extends StatelessWidget {
  const NewTabSurface({super.key});

  /// The one hint line per destination; unknown ids render name-only.
  static String? _hintFor(final BuildContext context, final String id) {
    final l10n = context.l10n;
    return switch (id) {
      kConversationsSurfaceId => l10n.newTabHintConversations,
      kBrowserSurfaceId => l10n.newTabHintBrowser,
      kInspectorSurfaceId => l10n.newTabHintInspector,
      _ => null,
    };
  }

  @override
  Widget build(final BuildContext context) {
    final scope = CenterTabsScope.of(context);
    if (scope == null) {
      // Honest absence: the picker only makes sense inside the shell.
      return const Center(child: Text('new tab requires the app shell'));
    }
    final destinations = <SurfaceSpec>[
      for (final entry in scope.surfaces.entries)
        if (entry.key != kNewTabSurfaceId) entry.value,
    ];
    return KeyedSubtree(
      key: const ValueKey('newtab.page'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                scope.surfaces[kNewTabSurfaceId]?.title ??
                    context.l10n.newTabPageTitle,
                style: shellSectionLabel(context),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 4.6,
                children: [
                  for (final spec in destinations)
                    _NewTabEntry(
                      key: ValueKey('newtab.entry.${spec.id}'),
                      spec: spec,
                      hint: _hintFor(context, spec.id),
                      onOpen: () =>
                          scope.onChanged(scope.tabs.pick(spec.id)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One picker destination: icon tile, name, one-line hint — a menu row
/// on the hairline grid, hover emphasis only.
final class _NewTabEntry extends StatefulWidget {
  const _NewTabEntry({
    required this.spec,
    required this.hint,
    required this.onOpen,
    super.key,
  });

  final SurfaceSpec spec;

  /// The one-line hint; null renders the name alone.
  final String? hint;
  final VoidCallback onOpen;

  @override
  State<_NewTabEntry> createState() => _NewTabEntryState();
}

final class _NewTabEntryState extends State<_NewTabEntry> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _hovering
        ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
        : context.shellHairline;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onOpen,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: context.shellHairline),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  widget.spec.icon ?? Icons.crop_square,
                  size: 15,
                  color: context.shellMuted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.spec.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.hint != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        widget.hint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.shellMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Named empty-state for a surface id the registry does not know.
final class UnknownSurface extends StatelessWidget {
  const UnknownSurface({required this.surfaceId, super.key});

  final String surfaceId;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'UNKNOWN SURFACE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(surfaceId, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
