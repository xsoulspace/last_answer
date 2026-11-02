/// WAVE 5 — unified views: the ONE layout document (docs/design/
/// unified-views.md). The old split — a center strip (`shell.tabs.v1`)
/// plus a context panel with its private tab taxonomy — collapses into
/// a single [ViewLayout]: a view is a view; where it lives is a
/// presentation, not a taxonomy.
///
/// Shape (persisted as `shell.views.v2`, ONE-TIME migrated from
/// `shell.tabs.v1` + the panel's people default):
///
/// ```
/// ViewLayout {
///   tabs: [viewId]        // the top bar, in order (newtab included)
///   active: int           // the focused center view
///   pinned: [viewId]      // the dock, in order — a view may be BOTH
///                         // pinned and open as a tab (Notion: a page
///                         // in peek AND in a tab)
///   dockFocus: viewId?    // the focused pin; null/stale = first pin
/// }
/// ```
///
/// Laws carried over from the center strip (WAVE 4T, the browser
/// model): the `+` opens/focuses the ONE newtab tab ([openNewTab]);
/// picking a destination replaces it in place ([pick]); closing the
/// LAST tab swaps the picker in ([close]); the picker is session
/// chrome — a LONE newtab tab never survives a restart
/// ([ViewLayout.fromJson]); the conversation slot reuses one tab in
/// place ([openConversation], the Discord flow).
///
/// Dock laws (new): [pin] appends the id to `pinned` and focuses the
/// dock on it; [unpin] removes the pin only (an open tab stays open);
/// [focusDock] moves the dock's focus. Pure value semantics — every
/// operation returns a new [ViewLayout].
library;

import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:lastanswer/shell/surfaces.dart';

/// The shell's layout: the top bar's tabs + the dock's pins, one
/// document.
@immutable
final class ViewLayout {
  /// Normalizing constructor: duplicate ids keep their first occurrence
  /// (tabs and pins separately), an empty tab strip falls back to the
  /// world conversations surface, [active] clamps into range, and
  /// [dockFocus] is kept only when it names a pin (else the dock's
  /// focus is the first pin — see [focusedDockId]). The default pin is
  /// People; a null [dockFocus] means "the first pin".
  factory ViewLayout({
    final List<String> tabs = const <String>[kConversationsSurfaceId],
    final int active = 0,
    final List<String> pinned = const <String>[kPeopleSurfaceId],
    final String? dockFocus,
  }) {
    final dedupedTabs = <String>[];
    for (final id in tabs) {
      if (!dedupedTabs.contains(id)) dedupedTabs.add(id);
    }
    if (dedupedTabs.isEmpty) dedupedTabs.add(kConversationsSurfaceId);
    final dedupedPins = <String>[];
    for (final id in pinned) {
      if (!dedupedPins.contains(id)) dedupedPins.add(id);
    }
    return ViewLayout._(
      List.unmodifiable(dedupedTabs),
      active.clamp(0, dedupedTabs.length - 1),
      List.unmodifiable(dedupedPins),
      dockFocus,
    );
  }

  /// The backing constructor; the factory normalizes first.
  const ViewLayout._(this.tabs, this.active, this.pinned, this.dockFocus);

  /// Decodes the persisted shape. Tolerant: anything unusable decodes
  /// to the default layout. The ONE-TIME migration rides the same
  /// decoder — a `shell.tabs.v1` blob (`{"tabs": […], "active": n}`)
  /// reads as a v2 layout with the default pin (People), which IS the
  /// migration's meaning. A LONE newtab tab never survives a restart —
  /// the picker is session chrome, so the restore lands on the default
  /// face.
  factory ViewLayout.fromJson(final Object? json) {
    if (json is! Map) return ViewLayout();
    final rawTabs = json['tabs'];
    final tabs = <String>[
      if (rawTabs is List)
        for (final id in rawTabs)
          if (id is String && id.isNotEmpty) id,
    ];
    // The factory dedupes below; judge lone-ness on the deduped list,
    // so a corrupt `['newtab', 'newtab']` remaps too.
    if (tabs.isNotEmpty && tabs.every((final id) => id == kNewTabSurfaceId)) {
      return ViewLayout();
    }
    final active = json['active'];
    final rawPins = json['pinned'];
    final rawFocus = json['dockFocus'];
    return ViewLayout(
      tabs: tabs,
      active: active is int ? active : 0,
      pinned: rawPins is List
          ? <String>[for (final id in rawPins) if (id is String) id]
          : const <String>[kPeopleSurfaceId],
      dockFocus: rawFocus is String ? rawFocus : kPeopleSurfaceId,
    );
  }

  /// Ordered, unique tab ids (the top bar); never empty.
  final List<String> tabs;

  /// The focused tab index, always in range.
  final int active;

  /// Ordered, unique pinned ids (the dock). May be empty — the dock
  /// shows what is pinned; nothing pinned, no dock. A view may be
  /// pinned AND open as a tab.
  final List<String> pinned;

  /// The dock focus INTENT (a pin id, possibly stale — normalization
  /// happens in [focusedDockId]).
  final String? dockFocus;

  /// The focused tab id.
  String get activeId => tabs[active];

  /// Whether [viewId] is pinned (it may simultaneously be a tab).
  bool isPinned(final String viewId) => pinned.contains(viewId);

  /// The dock's effective focus: the intent when it still names a pin,
  /// else the first pin, else null (no pins, no dock).
  String? get focusedDockId => pinned.isEmpty
      ? null
      : pinned.contains(dockFocus)
      ? dockFocus
      : pinned.first;

  Map<String, Object?> toJson() => <String, Object?>{
    'tabs': List<String>.of(tabs),
    'active': active,
    'pinned': List<String>.of(pinned),
    'dockFocus': focusedDockId,
  };

  // ---- the top bar (tab semantics carried from the center strip) ----

  /// Focuses [surfaceId], opening it right of the active tab when new.
  /// Stations open their own tab; conversation ids go through
  /// [openConversation] — use this for direct bar taps.
  ViewLayout open(final String surfaceId) {
    final existing = tabs.indexOf(surfaceId);
    if (existing >= 0) return _focus(existing);
    return _insertAndFocus(surfaceId);
  }

  /// The bar's `+` flow: opens the picker as a new active tab, right
  /// of the active tab. At most ONE newtab tab exists.
  ViewLayout openNewTab() => open(kNewTabSurfaceId);

  /// The picker's flow: choosing a destination replaces the newtab tab
  /// IN PLACE (a bookmark click on a browser's new-tab page navigates
  /// THAT tab — position and neighbors unchanged). A destination that
  /// already holds its own tab focuses it and the picker closes
  /// instead: stations stay unique in the bar. Without a picker tab
  /// this degrades to [open]; picking the picker itself changes
  /// nothing.
  ViewLayout pick(final String surfaceId) {
    if (surfaceId == kNewTabSurfaceId) return this;
    final pickerIndex = tabs.indexOf(kNewTabSurfaceId);
    if (pickerIndex < 0) return open(surfaceId);
    final existing = tabs.indexOf(surfaceId);
    if (existing >= 0) {
      final ids = List<String>.of(tabs)..removeAt(pickerIndex);
      final target = pickerIndex < existing ? existing - 1 : existing;
      return ViewLayout(
        tabs: ids,
        active: target,
        pinned: pinned,
        dockFocus: focusedDockId,
      );
    }
    final ids = List<String>.of(tabs);
    ids[pickerIndex] = surfaceId;
    return ViewLayout(
      tabs: ids,
      active: pickerIndex,
      pinned: pinned,
      dockFocus: focusedDockId,
    );
  }

  /// The rail's conversation flow: `dm:`/`channel:` ids reuse the ONE
  /// conversation slot — the slot's id is replaced in place, position
  /// and the tab count unchanged (zero tab accumulation). With
  /// `forceNew` (the rail's ⌘-click intent) the id gets its own tab
  /// instead, inserted next to the slot. When the bar hosts no
  /// conversation slot the id revives one.
  ViewLayout openConversation(
    final String surfaceId, {
    final bool forceNew = false,
  }) {
    final slot = _conversationSlot;
    if (slot == null) return _insertAndFocus(surfaceId);
    if (!forceNew) {
      // Already the slot's face: nothing changes.
      if (tabs[active] == surfaceId) return this;
      final kept = <String>[
        for (var i = 0; i < tabs.length; i++)
          if (i == slot) surfaceId else if (tabs[i] != surfaceId) tabs[i],
      ];
      return ViewLayout(
        tabs: kept,
        active: slot,
        pinned: pinned,
        dockFocus: focusedDockId,
      );
    }
    final existing = tabs.indexOf(surfaceId);
    if (existing >= 0) return _focus(existing);
    final ids = List<String>.of(tabs)..insert(slot + 1, surfaceId);
    return ViewLayout(
      tabs: ids,
      active: slot + 1,
      pinned: pinned,
      dockFocus: focusedDockId,
    );
  }

  /// Closes [surfaceId]'s tab (the ✕, middle-click, or ⌘W). A browser
  /// never shows zero tabs: closing the LAST tab swaps the newtab
  /// surface in — the window keeps a page. The lone PICKER itself is
  /// refused (there is nothing to swap into it; it stays — honest).
  /// Closing the active tab focuses its neighbor (the tab that takes
  /// its place, else the previous one). A PIN survives a tab close:
  /// closing removes the tab only ([unpin] removes the pin only).
  ViewLayout close(final String surfaceId) {
    final index = tabs.indexOf(surfaceId);
    if (index < 0) return this;
    if (tabs.length == 1) {
      if (surfaceId == kNewTabSurfaceId) return this;
      return ViewLayout(
        tabs: const <String>[kNewTabSurfaceId],
        pinned: pinned,
        dockFocus: focusedDockId,
      );
    }
    final ids = List<String>.of(tabs)..removeAt(index);
    var nextActive = active;
    if (index < active) {
      nextActive = active - 1;
    } else if (index == active) {
      nextActive = index.clamp(0, ids.length - 1);
    }
    return ViewLayout(
      tabs: ids,
      active: nextActive,
      pinned: pinned,
      dockFocus: focusedDockId,
    );
  }

  /// Moves the tab at [from] to [to]; the focused id stays focused.
  ViewLayout move(final int from, final int to) {
    if (from < 0 || from >= tabs.length) return this;
    final focused = activeId;
    final ids = List<String>.of(tabs);
    final id = ids.removeAt(from);
    ids.insert(to.clamp(0, ids.length), id);
    return ViewLayout(
      tabs: ids,
      active: ids.indexOf(focused),
      pinned: pinned,
      dockFocus: focusedDockId,
    );
  }

  // ---- the dock (pin semantics — WAVE 5) ----

  /// Pins [viewId]: appended to the dock and focused there. Pinning a
  /// view that is open as a tab does NOT close the tab (a view may be
  /// tab AND pin). Already-pinned ids just focus the dock.
  ViewLayout pin(final String viewId) {
    if (pinned.contains(viewId)) return focusDock(viewId);
    return ViewLayout(
      tabs: tabs,
      active: active,
      pinned: <String>[...pinned, viewId],
      dockFocus: viewId,
    );
  }

  /// Unpins [viewId]: removes the pin only — an open tab stays open,
  /// and the dock's focus falls to the first surviving pin (the
  /// normalization in [focusedDockId]). An id that is not pinned
  /// changes nothing.
  ViewLayout unpin(final String viewId) {
    if (!pinned.contains(viewId)) return this;
    return ViewLayout(
      tabs: tabs,
      active: active,
      pinned: <String>[
        for (final id in pinned)
          if (id != viewId) id,
      ],
      dockFocus: focusedDockId,
    );
  }

  /// Focuses [viewId]'s pin in the dock. An unpinned id changes
  /// nothing (focus follows pins, never creates them).
  ViewLayout focusDock(final String viewId) {
    if (!pinned.contains(viewId) || viewId == focusedDockId) return this;
    return ViewLayout(
      tabs: tabs,
      active: active,
      pinned: pinned,
      dockFocus: viewId,
    );
  }

  // ---- internals ----

  /// The conversation slot's index (the first conversation-surface
  /// tab), or null when the bar hosts no conversation.
  int? get _conversationSlot {
    for (var i = 0; i < tabs.length; i++) {
      if (isConversationSurfaceId(tabs[i])) return i;
    }
    return null;
  }

  ViewLayout _focus(final int index) => ViewLayout(
    tabs: tabs,
    active: index,
    pinned: pinned,
    dockFocus: focusedDockId,
  );

  ViewLayout _insertAndFocus(final String surfaceId) {
    final at = (active + 1).clamp(0, tabs.length);
    final ids = List<String>.of(tabs)..insert(at, surfaceId);
    return ViewLayout(
      tabs: ids,
      active: at,
      pinned: pinned,
      dockFocus: focusedDockId,
    );
  }

  @override
  bool operator ==(final Object other) =>
      other is ViewLayout &&
      other.active == active &&
      listEquals(other.tabs, tabs) &&
      listEquals(other.pinned, pinned) &&
      other.focusedDockId == focusedDockId;

  @override
  int get hashCode => Object.hash(
    active,
    Object.hashAll(tabs),
    Object.hashAll(pinned),
    focusedDockId,
  );

  @override
  String toString() =>
      'ViewLayout(tabs: $tabs, active: $active, pinned: $pinned, '
      'dockFocus: $focusedDockId)';
}

/// Flattens a LEGACY `shell.paneTree.v1` tree (`leaf`/`stack`/`split`
/// nodes) into its surface ids in document order — the one-time layout
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
  // Conversations is the bar's resident: bring it to the front, and
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
