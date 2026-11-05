/// Phase 1 — the shell redesign's layout document (docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md §2.1): the ORIGINAL idea,
/// restored — a left rail of VIEWS (Zed/VSCode anatomy) where EACH view owns
/// a Safari-like tab strip. Replaces the WAVE 5 model (one global bar + a
/// dock of pins) with per-view tab state:
///
/// ```
/// ShellLayout {
///   activeView: viewId            // the view the center hosts
///   perView: {viewId: ViewState}  // each view's own strip
///   ViewState { tabs: [surfaceId], active: int }
/// }
/// ```
///
/// Tab ids are surface ids with prefix-generic parameters: static registry
/// ids (`boards`), conversation ids (`dm:<actor>`, `channel:<id>`), and the
/// kinds phase 3 adds (`doc:<docId>`, `board:<boardId>`,
/// `browser:<windowId>`). The registry resolves a prefix to a [SurfaceSpec];
/// the layout model never learns a kind.
///
/// Laws carried from the browser model (WAVE 4T) and kept per view:
/// `+`/⌘T opens the ONE newtab tab in the ACTIVE view's strip; picking a
/// destination replaces it in place; closing a view's LAST tab swaps the
/// picker in (a strip never goes empty); the picker is session chrome (a
/// lone newtab never survives a restore). Conversation ids reuse the ONE
/// conversation slot of the conversations view unless `forceNew`.
///
/// Persisted as `shell.views.v3`; [ShellLayout.fromJson] migrates the v2/v1
/// blob (`{"tabs": […], "active": n, "pinned": […]}`) in one pass: each tab
/// lands in its own view's strip (order kept), pins become tabs of their
/// view (nothing is lost when the dock retires), and the active id chooses
/// the active view.
library;

import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:lastanswer/shell/surfaces.dart';

/// One view's tab strip: ordered unique surface ids + the focused one.
@immutable
final class ViewState {
  factory ViewState({
    final List<String> tabs = const <String>[],
    final int active = 0,
  }) {
    final deduped = <String>[];
    for (final id in tabs) {
      if (!deduped.contains(id)) deduped.add(id);
    }
    if (deduped.isEmpty) deduped.add(kNewTabSurfaceId);
    return ViewState._(
      List.unmodifiable(deduped),
      active.clamp(0, deduped.length - 1),
    );
  }

  const ViewState._(this.tabs, this.active);

  /// Ordered, unique tab ids; never empty.
  final List<String> tabs;

  /// The focused tab index, always in range.
  final int active;

  String get activeId => tabs[active];

  Map<String, Object?> toJson() => <String, Object?>{
    'tabs': List<String>.of(tabs),
    'active': active,
  };

  @override
  bool operator ==(final Object other) =>
      other is ViewState &&
      other.active == active &&
      listEquals(other.tabs, tabs);

  @override
  int get hashCode => Object.hash(active, Object.hashAll(tabs));

  @override
  String toString() => 'ViewState(tabs: $tabs, active: $active)';
}

/// The shell's one layout document: which view is hosted, and every view's
/// own tab strip. Pure value semantics — every operation returns a new
/// [ShellLayout].
@immutable
final class ShellLayout {
  factory ShellLayout({
    final String activeView = kConversationsSurfaceId,
    final Map<String, ViewState> perView = const <String, ViewState>{},
  }) {
    final views = <String, ViewState>{...perView};
    views.putIfAbsent(
      activeView,
      () => ViewState(tabs: _defaultTabsOf(activeView)),
    );
    return ShellLayout._(activeView, Map.unmodifiable(views));
  }

  const ShellLayout._(this.activeView, this.perView);

  /// The default layout: the conversations view hosted with its world face,
  /// and the people view holding its own strip (the dock's old default pin,
  /// now a view like any other).
  factory ShellLayout.defaultLayout() => ShellLayout(
    perView: const <String, ViewState>{
      kConversationsSurfaceId: ViewState._(
        <String>[kConversationsSurfaceId],
        0,
      ),
      kPeopleSurfaceId: ViewState._(<String>[kPeopleSurfaceId], 0),
    },
  );

  /// Decodes the persisted shape, migrating v2/v1 blobs in the same pass.
  /// Tolerant: anything unusable decodes to [ShellLayout.defaultLayout].
  factory ShellLayout.fromJson(final Object? json) {
    if (json is! Map) return ShellLayout.defaultLayout();
    final version = json['v'];
    if (version == 3) return _fromV3(json);
    return _fromV2(json);
  }

  static ShellLayout _fromV3(final Map json) {
    final rawViews = json['views'];
    final views = <String, ViewState>{};
    if (rawViews is Map) {
      rawViews.forEach((final key, final value) {
        if (key is! String || value is! Map) return;
        final rawTabs = value['tabs'];
        final tabs = <String>[
          if (rawTabs is List)
            for (final id in rawTabs)
              if (id is String && id.isNotEmpty) id,
        ];
        if (tabs.isEmpty) return;
        final active = value['active'];
        views[key] = ViewState(tabs: tabs, active: active is int ? active : 0);
      });
    }
    final activeView = json['activeView'];
    final view = activeView is String && views.containsKey(activeView)
        ? activeView
        : (views.containsKey(kConversationsSurfaceId)
              ? kConversationsSurfaceId
              : views.keys.first);
    // A lone picker tab never survives a restore (session chrome).
    final restored = ShellLayout(activeView: view, perView: views);
    if (restored.tabsOf(view).every((final id) => id == kNewTabSurfaceId)) {
      return ShellLayout.defaultLayout();
    }
    return restored;
  }

  /// The v2/v1 migration: one global bar becomes per-view strips. Each tab
  /// lands in its own view (conversation ids share the conversations view,
  /// order kept); pins become tabs of their view so the dock's retirement
  /// loses nothing; the active id chooses the active view and its tab.
  static ShellLayout _fromV2(final Map json) {
    final rawTabs = json['tabs'];
    final tabs = <String>[
      if (rawTabs is List)
        for (final id in rawTabs)
          if (id is String && id.isNotEmpty) id,
    ];
    final rawPins = json['pinned'];
    if (rawPins is List) {
      for (final id in rawPins) {
        if (id is String && id.isNotEmpty) tabs.add(id);
      }
    }
    if (tabs.isEmpty || tabs.every((final id) => id == kNewTabSurfaceId)) {
      return ShellLayout.defaultLayout();
    }
    final views = <String, List<String>>{};
    for (final id in tabs) {
      if (id == kNewTabSurfaceId) continue; // session chrome, not restored
      views.putIfAbsent(viewOfSurface(id), () => <String>[]).add(id);
    }
    final active = json['active'];
    final activeId = active is int && active >= 0 && active < tabs.length
        ? tabs[active]
        : tabs.first;
    final activeView = viewOfSurface(activeId);
    return ShellLayout(
      activeView: views.containsKey(activeView)
          ? activeView
          : views.keys.first,
      perView: <String, ViewState>{
        for (final entry in views.entries)
          entry.key: ViewState(
            tabs: entry.value,
            active: entry.key == activeView
                ? entry.value.indexOf(activeId).clamp(0, entry.value.length - 1)
                : 0,
          ),
      },
    );
  }

  /// The view a surface id belongs to: conversation ids share the
  /// conversations view; everything else is its own view (phase 3 kinds
  /// extend this switch with their prefixes).
  static String viewOfSurface(final String surfaceId) =>
      isConversationSurfaceId(surfaceId)
      ? kConversationsSurfaceId
      : surfaceId == kNewTabSurfaceId
      ? kNewTabSurfaceId
      : surfaceId;

  /// The default strip of a view opened with no history: static views host
  /// their own id; the conversations view hosts the world face.
  static List<String> _defaultTabsOf(final String viewId) =>
      viewId == kConversationsSurfaceId
      ? const <String>[kConversationsSurfaceId]
      : <String>[viewId];

  /// The hosted view's id.
  final String activeView;

  /// Every view's strip; a view with no entry has no open tabs.
  final Map<String, ViewState> perView;

  /// [viewId]'s tab ids (empty when the view holds no strip).
  List<String> tabsOf(final String viewId) =>
      perView[viewId]?.tabs ?? const <String>[];

  /// [viewId]'s focused tab id (null when the view holds no strip).
  String? activeTabOf(final String viewId) => perView[viewId]?.activeId;

  /// The hosted view's focused tab id — what the center renders.
  String? get activeSurfaceId => activeTabOf(activeView);

  Map<String, Object?> toJson() => <String, Object?>{
    'v': 3,
    'activeView': activeView,
    'views': <String, Object?>{
      for (final entry in perView.entries) entry.key: entry.value.toJson(),
    },
  };

  // ---- view switching ----

  /// Hosts [viewId], opening its default strip when it has none.
  ShellLayout showView(final String viewId) {
    if (viewId == activeView && perView.containsKey(viewId)) return this;
    final views = Map<String, ViewState>.of(perView);
    views.putIfAbsent(viewId, () => ViewState(tabs: _defaultTabsOf(viewId)));
    return ShellLayout._(viewId, Map.unmodifiable(views));
  }

  // ---- per-view tab operations ----

  /// Focuses [surfaceId] in [viewId]'s strip, opening it right of the
  /// focused tab when new, and hosts the view.
  ShellLayout openTab(final String viewId, final String surfaceId) {
    final state = perView[viewId] ?? ViewState(tabs: _defaultTabsOf(viewId));
    final existing = state.tabs.indexOf(surfaceId);
    final ViewState next;
    if (existing >= 0) {
      next = ViewState(tabs: state.tabs, active: existing);
    } else {
      final at = (state.active + 1).clamp(0, state.tabs.length);
      next = ViewState(tabs: <String>[...state.tabs]..insert(at, surfaceId), active: at);
    }
    return _withView(viewId, next, host: true);
  }

  /// The `+`/⌘T flow: the picker as a tab of the ACTIVE view's strip.
  /// At most ONE newtab tab per strip.
  ShellLayout openNewTab() => openTab(activeView, kNewTabSurfaceId);

  /// The picker's flow in the ACTIVE view: choosing a destination replaces
  /// the picker tab IN PLACE; a destination that already holds a tab in
  /// that strip focuses it and the picker closes instead.
  ShellLayout pick(final String surfaceId) {
    if (surfaceId == kNewTabSurfaceId) return this;
    final viewId = activeView;
    final state = perView[viewId];
    if (state == null) return openTab(viewId, surfaceId);
    final pickerIndex = state.tabs.indexOf(kNewTabSurfaceId);
    if (pickerIndex < 0) return openTab(viewId, surfaceId);
    final existing = state.tabs.indexOf(surfaceId);
    if (existing >= 0) {
      final ids = List<String>.of(state.tabs)..removeAt(pickerIndex);
      final target = pickerIndex < existing ? existing - 1 : existing;
      return _withView(viewId, ViewState(tabs: ids, active: target), host: true);
    }
    final ids = List<String>.of(state.tabs);
    ids[pickerIndex] = surfaceId;
    return _withView(viewId, ViewState(tabs: ids, active: pickerIndex), host: true);
  }

  /// The rail's conversation flow: ids reuse the ONE conversation slot of
  /// the conversations view (slot id replaced in place, zero tab
  /// accumulation); `forceNew` (⌘-click intent) gives the id its own tab
  /// next to the slot. Hosts the conversations view.
  ShellLayout openConversation(
    final String surfaceId, {
    final bool forceNew = false,
  }) {
    const viewId = kConversationsSurfaceId;
    final state =
        perView[viewId] ??
        const ViewState._(<String>[kConversationsSurfaceId], 0);
    final slot = _conversationSlotOf(state);
    if (slot == null) {
      return _withView(
        viewId,
        ViewState(tabs: <String>[...state.tabs, surfaceId], active: state.tabs.length),
        host: true,
      );
    }
    if (!forceNew) {
      if (state.activeId == surfaceId) return showView(viewId);
      final kept = <String>[
        for (var i = 0; i < state.tabs.length; i++)
          if (i == slot) surfaceId else if (state.tabs[i] != surfaceId) state.tabs[i],
      ];
      return _withView(viewId, ViewState(tabs: kept, active: slot), host: true);
    }
    final existing = state.tabs.indexOf(surfaceId);
    if (existing >= 0) {
      return _withView(viewId, ViewState(tabs: state.tabs, active: existing), host: true);
    }
    final ids = List<String>.of(state.tabs)..insert(slot + 1, surfaceId);
    return _withView(viewId, ViewState(tabs: ids, active: slot + 1), host: true);
  }

  /// Focuses an already-open tab (a strip tap).
  ShellLayout focusTab(final String viewId, final String surfaceId) {
    final state = perView[viewId];
    if (state == null) return this;
    final index = state.tabs.indexOf(surfaceId);
    if (index < 0) return this;
    return _withView(viewId, ViewState(tabs: state.tabs, active: index), host: true);
  }

  /// Closes [surfaceId] from [viewId]'s strip (✕, middle-click, ⌘W). A
  /// strip never goes empty: closing the LAST tab swaps the picker in.
  /// The lone picker itself is refused. Closing the focused tab focuses
  /// the neighbor that takes its place, else the previous one.
  ShellLayout closeTab(final String viewId, final String surfaceId) {
    final state = perView[viewId];
    if (state == null) return this;
    final index = state.tabs.indexOf(surfaceId);
    if (index < 0) return this;
    if (state.tabs.length == 1) {
      if (surfaceId == kNewTabSurfaceId) return this;
      return _withView(viewId, const ViewState._(<String>[kNewTabSurfaceId], 0));
    }
    final ids = List<String>.of(state.tabs)..removeAt(index);
    var nextActive = state.active;
    if (index < state.active) {
      nextActive = state.active - 1;
    } else if (index == state.active) {
      nextActive = index.clamp(0, ids.length - 1);
    }
    return _withView(viewId, ViewState(tabs: ids, active: nextActive));
  }

  /// Moves the tab at [from] to [to] inside [viewId]'s strip; the focused
  /// id stays focused.
  ShellLayout moveTab(final String viewId, final int from, final int to) {
    final state = perView[viewId];
    if (state == null || from < 0 || from >= state.tabs.length) return this;
    final focused = state.activeId;
    final ids = List<String>.of(state.tabs);
    final id = ids.removeAt(from);
    ids.insert(to.clamp(0, ids.length), id);
    return _withView(viewId, ViewState(tabs: ids, active: ids.indexOf(focused)));
  }

  // ---- internals ----

  static int? _conversationSlotOf(final ViewState state) {
    for (var i = 0; i < state.tabs.length; i++) {
      if (isConversationSurfaceId(state.tabs[i])) return i;
    }
    return null;
  }

  ShellLayout _withView(
    final String viewId,
    final ViewState state, {
    final bool host = false,
  }) {
    final views = Map<String, ViewState>.of(perView)..[viewId] = state;
    return ShellLayout._(host ? viewId : activeView, Map.unmodifiable(views));
  }

  @override
  bool operator ==(final Object other) =>
      other is ShellLayout &&
      other.activeView == activeView &&
      other.perView.length == perView.length &&
      other.perView.entries.every(
        (final entry) => perView[entry.key] == entry.value,
      );

  @override
  int get hashCode => Object.hash(
    activeView,
    Object.hashAllUnordered(
      perView.entries.map((final entry) => Object.hash(entry.key, entry.value)),
    ),
  );

  @override
  String toString() =>
      'ShellLayout(activeView: $activeView, perView: $perView)';
}
