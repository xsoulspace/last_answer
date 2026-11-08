/// The shell's layout document, v4 — DESIGN.md v2 tab law (owner law
/// 2026-11-08, the approved mockup's anatomy): tabs are the universal
/// content surface, OWNED BY PANE GROUPS (VS Code/Zed), never by the
/// window and never by "views":
///
/// ```
/// ShellLayout {
///   groups: [ViewState]   // pane columns, left → right; normally ONE
///   active: int           // the group holding focus
///   ViewState { tabs: [tabId], active: int, hist/histAt (runtime MRU) }
/// }
/// ```
///
/// The laws this model carries:
/// - **Splits are pane groups.** [split] moves the active tab into a NEW
///   group to the right (the mockup law); the emptied source refills
///   with the conversations world face (the front door — a strip is
///   never empty and the picker is no longer a tab). [fold] merges a
///   group back into its left neighbour. A diff/side-by-side view is
///   ONE group showing two panes, never two groups.
/// - **Tabs are instances, not singletons.** A tab id is a surface id
///   (`boards`), a content id (`dm:<actor>`, `channel:<id>`,
///   `doc:<docId>`) or an INSTANCE id (`browser:2` — [nextInstanceId]
///   mints them; the registry resolves the prefix). Ids stay unique
///   across groups: opening an id that is open somewhere focuses it
///   where it lives.
/// - **Per-group history.** Each group keeps a runtime MRU of focus
///   (not persisted — history is a session fact, the tab set is the
///   durable one); [back]/[forward] walk it, skipping closed tabs.
/// - **Closing the last tab** of a group removes the group (when
///   another survives) or lands on the world face (the sole group —
///   conversation is the door).
///
/// Persisted as `shell.views.v4`; [ShellLayout.fromJson] migrates the
/// v3 per-view blob (the active view's strip first, then the rest in
/// order, one group — v3 had no splits), the v2/v1 global bar + pins,
/// and (through [legacyPaneTreeSurfaceIds]) the pane-tree fossil.
library;

import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:lastanswer/shell/surfaces.dart';

/// One pane group's tab strip: ordered unique tab ids, the focused one,
/// and the session's focus history (back/forward).
@immutable
final class ViewState {
  factory ViewState({
    final List<String> tabs = const <String>[],
    final int active = 0,
  }) {
    final deduped = <String>[];
    for (final id in tabs) {
      if (id.isNotEmpty && !deduped.contains(id)) deduped.add(id);
    }
    if (deduped.isEmpty) deduped.add(kConversationsSurfaceId);
    final at = active.clamp(0, deduped.length - 1);
    return ViewState._(deduped, at, <String>[deduped[at]], 0);
  }

  const ViewState._(this.tabs, this.active, this.hist, this.histAt);

  /// The history's cap — a session-long back stack, not an archive.
  static const int histCap = 24;

  /// Ordered, unique tab ids; never empty (the world face is the floor).
  final List<String> tabs;

  /// The focused tab index, always in range.
  final int active;

  /// Runtime MRU of focused ids, oldest → newest; [histAt] is the
  /// cursor. Session-scoped by law: never persisted, never in `==`
  /// (every history move also moves `active`, so rebuilds never lag).
  final List<String> hist;
  final int histAt;

  String get activeId => tabs[active];

  /// Focuses [index], pushing the MRU. Same index = no-op.
  ViewState focusedOn(final int index) {
    if (index < 0 || index >= tabs.length || index == active) return this;
    final trimmed = <String>[
      for (final id in hist.take(histAt + 1))
        if (id != tabs[index]) id,
    ]..add(tabs[index]);
    while (trimmed.length > histCap) {
      trimmed.removeAt(0);
    }
    return ViewState._(tabs, index, trimmed, trimmed.length - 1);
  }

  /// Inserts [id] at [at], focused, carrying the MRU forward (the
  /// factory constructor seeds a fresh history — this path must not:
  /// an open tab is a focus step, not a new session).
  ViewState inserted(final String id, final int at) {
    final ids = List<String>.of(tabs)..insert(at, id);
    final trimmed = <String>[
      for (final entry in hist.take(histAt + 1))
        if (entry != id) entry,
    ]..add(id);
    while (trimmed.length > histCap) {
      trimmed.removeAt(0);
    }
    return ViewState._(ids, at, trimmed, trimmed.length - 1);
  }

  bool get canBack {
    for (var i = 0; i < histAt; i++) {
      if (tabs.contains(hist[i])) return true;
    }
    return false;
  }

  bool get canForward {
    for (var i = histAt + 1; i < hist.length; i++) {
      if (tabs.contains(hist[i])) return true;
    }
    return false;
  }

  /// Steps the cursor to the nearest live older entry (closed tabs are
  /// skipped, never resurrected).
  ViewState back() {
    for (var i = histAt - 1; i >= 0; i--) {
      final idx = tabs.indexOf(hist[i]);
      if (idx >= 0) return ViewState._(tabs, idx, hist, i);
    }
    return this;
  }

  ViewState forward() {
    for (var i = histAt + 1; i < hist.length; i++) {
      final idx = tabs.indexOf(hist[i]);
      if (idx >= 0) return ViewState._(tabs, idx, hist, i);
    }
    return this;
  }

  /// The state after [id] left the strip: the neighbour takes focus
  /// (the one that slides into its place, else the previous), and the
  /// MRU forgets the closed tab.
  ViewState without(final int index) {
    final ids = List<String>.of(tabs)..removeAt(index);
    var nextActive = active;
    if (index < active) {
      nextActive = active - 1;
    } else if (index == active) {
      nextActive = index.clamp(0, ids.length - 1);
    }
    final closed = tabs[index];
    final newHist = <String>[
      for (final id in hist)
        if (id != closed) id,
    ];
    var newAt = histAt;
    for (var i = 0; i < histAt && i < hist.length; i++) {
      if (hist[i] == closed) newAt--;
    }
    if (newHist.isEmpty) {
      newHist.add(ids[nextActive]);
      newAt = 0;
    }
    return ViewState._(
      ids,
      nextActive,
      newHist,
      newAt.clamp(0, newHist.length - 1),
    );
  }

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

/// The shell's one layout document: the pane groups, left → right, and
/// which one holds focus. Pure value semantics — every operation
/// returns a new [ShellLayout].
@immutable
final class ShellLayout {
  factory ShellLayout({
    final List<ViewState> groups = const <ViewState>[],
    final int active = 0,
  }) {
    final list = groups.isEmpty ? <ViewState>[ViewState()] : List.of(groups);
    return ShellLayout._(list, active.clamp(0, list.length - 1));
  }

  const ShellLayout._(this.groups, this.active);

  /// The default layout: ONE pane group on the conversations world face
  /// (conversation is the primary interaction mode — the front door).
  factory ShellLayout.defaultLayout() => const ShellLayout._(<ViewState>[
    ViewState._(
      <String>[kConversationsSurfaceId],
      0,
      <String>[kConversationsSurfaceId],
      0,
    ),
  ], 0);

  /// Decodes the persisted shape, migrating v3/v2/v1 blobs in the same
  /// pass. Tolerant: anything unusable decodes to
  /// [ShellLayout.defaultLayout].
  factory ShellLayout.fromJson(final Object? json) {
    if (json is! Map) return ShellLayout.defaultLayout();
    final version = json['v'];
    if (version == 4) return _fromV4(json);
    if (version == 3) return _fromV3(json);
    return _fromV2(json);
  }

  static ShellLayout _fromV4(final Map json) {
    final rawGroups = json['groups'];
    final groups = <ViewState>[];
    if (rawGroups is List) {
      for (final raw in rawGroups) {
        if (raw is! Map) continue;
        final tabs = _stringList(raw['tabs']);
        if (tabs.isEmpty) continue;
        final active = raw['active'];
        groups.add(ViewState(tabs: tabs, active: active is int ? active : 0));
      }
    }
    if (groups.isEmpty) return ShellLayout.defaultLayout();
    final active = json['active'];
    return ShellLayout(groups: groups, active: active is int ? active : 0);
  }

  /// The v3 migration: per-view strips flatten into ONE group — the
  /// hosted view's strip first (its focused tab keeps focus), then the
  /// other views in order. v3 had no splits, so one group is faithful.
  static ShellLayout _fromV3(final Map json) {
    final rawViews = json['views'];
    if (rawViews is! Map) return ShellLayout.defaultLayout();
    final ordered = <String>[];
    void addAll(final Object? value) {
      if (value is! Map) return;
      for (final id in _stringList(value['tabs'])) {
        if (id != kNewTabSurfaceId && !ordered.contains(id)) ordered.add(id);
      }
    }

    final activeView = json['activeView'];
    if (activeView is String) addAll(rawViews[activeView]);
    rawViews.forEach((final key, final value) {
      if (key != activeView) addAll(value);
    });
    if (ordered.isEmpty) return ShellLayout.defaultLayout();
    String? activeId;
    final activeState = activeView is String && rawViews[activeView] is Map
        ? rawViews[activeView] as Map
        : null;
    final rawActive = activeState?['active'];
    final stateTabs = _stringList(activeState?['tabs']);
    if (rawActive is int && rawActive >= 0 && rawActive < stateTabs.length) {
      activeId = stateTabs[rawActive];
    }
    final at = activeId == null ? 0 : ordered.indexOf(activeId);
    return ShellLayout(
      groups: <ViewState>[ViewState(tabs: ordered, active: at < 0 ? 0 : at)],
    );
  }

  /// The v2/v1 migration: one global bar (+ pins) becomes the single
  /// group; the picker tab is session chrome and is not restored.
  static ShellLayout _fromV2(final Map json) {
    final tabs = <String>[
      ..._stringList(json['tabs']),
      ..._stringList(json['pinned']),
    ];
    final ordered = <String>[];
    for (final id in tabs) {
      if (id != kNewTabSurfaceId && !ordered.contains(id)) ordered.add(id);
    }
    if (ordered.isEmpty) return ShellLayout.defaultLayout();
    final active = json['active'];
    final rawTabs = _stringList(json['tabs']);
    var at = 0;
    if (active is int && active >= 0 && active < rawTabs.length) {
      final idx = ordered.indexOf(rawTabs[active]);
      if (idx >= 0) at = idx;
    }
    return ShellLayout(
      groups: <ViewState>[ViewState(tabs: ordered, active: at)],
    );
  }

  static List<String> _stringList(final Object? raw) => <String>[
    if (raw is List)
      for (final id in raw)
        if (id is String && id.isNotEmpty) id,
  ];

  /// The pane groups, left → right; never empty.
  final List<ViewState> groups;

  /// The focused group's index, always in range.
  final int active;

  ViewState get activeGroup => groups[active];

  /// The focused group's focused tab — what the center renders. Never
  /// null: a group always holds at least the world face.
  String get activeSurfaceId => activeGroup.activeId;

  /// The group holding [tabId], or -1 (ids are unique across groups).
  int groupOf(final String tabId) {
    for (var g = 0; g < groups.length; g++) {
      if (groups[g].tabs.contains(tabId)) return g;
    }
    return -1;
  }

  /// Every open tab id, group order then strip order.
  List<String> get allTabs => <String>[
    for (final group in groups) ...group.tabs,
  ];

  bool get isSplit => groups.length > 1;

  Map<String, Object?> toJson() => <String, Object?>{
    'v': 4,
    'groups': <Object?>[for (final group in groups) group.toJson()],
    'active': active,
  };

  // ---- tab operations ----

  /// Focuses [tabId] wherever it lives (an open id never duplicates);
  /// a new id opens right of the focused tab of [group] (default: the
  /// active group) and takes focus.
  ShellLayout openTab(final String tabId, {final int? group}) {
    final found = groupOf(tabId);
    if (found >= 0) {
      final state = groups[found];
      return _withGroup(
        found,
        state.focusedOn(state.tabs.indexOf(tabId)),
        activate: true,
      );
    }
    final g = (group ?? active).clamp(0, groups.length - 1);
    final state = groups[g];
    final at = state.active + 1;
    return _withGroup(g, state.inserted(tabId, at), activate: true);
  }

  /// Rooms are ordinary tabs now (the persistent room list retired —
  /// opening lives in the picker and the palette). The name survives
  /// for the first-run boot grammar.
  ShellLayout openConversation(final String surfaceId) => openTab(surfaceId);

  /// Registry faces open like any tab (kept for callers speaking the v3
  /// vocabulary: "host this view" = "focus its tab").
  ShellLayout showView(final String surfaceId) => openTab(surfaceId);

  /// The picker's flow: choosing a destination is opening its tab.
  ShellLayout pick(final String surfaceId) => openTab(surfaceId);

  /// Closes [tabId] (✕, middle-click, ⌘W). The last tab of a group
  /// removes the group when another survives; the sole group lands on
  /// the conversations world face (the front door — a strip is never
  /// empty).
  ShellLayout closeTab(final String tabId) {
    final g = groupOf(tabId);
    if (g < 0) return this;
    final state = groups[g];
    final index = state.tabs.indexOf(tabId);
    if (state.tabs.length == 1) {
      if (groups.length == 1) {
        if (tabId == kConversationsSurfaceId) return this;
        return ShellLayout._(<ViewState>[ViewState()], 0);
      }
      final next = List<ViewState>.of(groups)..removeAt(g);
      var nextActive = active;
      if (g < active) {
        nextActive = active - 1;
      } else if (g == active) {
        nextActive = (g - 1).clamp(0, next.length - 1);
      }
      return ShellLayout._(next, nextActive);
    }
    return _withGroup(g, state.without(index));
  }

  /// Moves a tab within its group's strip; the focused id stays
  /// focused.
  ShellLayout moveTab(final int group, final int from, final int to) {
    if (group < 0 || group >= groups.length) return this;
    final state = groups[group];
    if (from < 0 || from >= state.tabs.length) return this;
    final focused = state.activeId;
    final ids = List<String>.of(state.tabs);
    final id = ids.removeAt(from);
    ids.insert(to.clamp(0, ids.length), id);
    return _withGroup(
      group,
      ViewState(tabs: ids, active: ids.indexOf(focused)),
    );
  }

  // ---- splits: pane groups (VS Code anatomy) ----

  /// The strip's split control: the active tab MOVES into a new group
  /// to the right, which takes focus. An emptied source refills with
  /// the world face; splitting the lone world face is refused (there
  /// would be nothing honest to show beside itself).
  ShellLayout split({final int? group}) {
    final g = (group ?? active).clamp(0, groups.length - 1);
    final state = groups[g];
    final tabId = state.activeId;
    if (state.tabs.length == 1 && tabId == kConversationsSurfaceId) {
      return this;
    }
    final rest = <String>[
      for (final id in state.tabs)
        if (id != tabId) id,
    ];
    if (rest.isEmpty) rest.add(kConversationsSurfaceId);
    final sourceActive = state.active > state.tabs.indexOf(tabId)
        ? state.active - 1
        : state.active.clamp(0, rest.length - 1);
    final next = List<ViewState>.of(groups)
      ..[g] = ViewState(tabs: rest, active: sourceActive)
      ..insert(g + 1, ViewState(tabs: <String>[tabId]));
    return ShellLayout._(next, g + 1);
  }

  /// The second pane's fold control: the group merges into its left
  /// neighbour (group 0 folds right); its focused tab keeps focus.
  ShellLayout fold({final int? group}) {
    if (groups.length < 2) return this;
    final g = (group ?? active).clamp(0, groups.length - 1);
    final target = g > 0 ? g - 1 : 1;
    final moved = groups[g];
    final into = groups[target];
    final merged = <String>[...into.tabs];
    for (final id in moved.tabs) {
      if (!merged.contains(id)) merged.add(id);
    }
    final focusId = moved.activeId;
    final next = List<ViewState>.of(groups)..removeAt(g);
    final mergedAt = target > g ? target - 1 : target;
    next[mergedAt] = ViewState(
      tabs: merged,
      active: merged.indexOf(focusId).clamp(0, merged.length - 1),
    );
    var nextActive = active;
    if (g < active) nextActive = active - 1;
    if (nextActive >= next.length) nextActive = next.length - 1;
    if (g == active || target == active) nextActive = mergedAt;
    return ShellLayout._(next, nextActive.clamp(0, next.length - 1));
  }

  // ---- per-group history (the strip's ‹ ›) ----

  ShellLayout back({final int? group}) {
    final g = (group ?? active).clamp(0, groups.length - 1);
    final next = groups[g].back();
    if (next == groups[g]) return this;
    return _withGroup(g, next, activate: true);
  }

  ShellLayout forward({final int? group}) {
    final g = (group ?? active).clamp(0, groups.length - 1);
    final next = groups[g].forward();
    if (next == groups[g]) return this;
    return _withGroup(g, next, activate: true);
  }

  // ---- instances (the tab law: same kind, N times) ----

  /// The next free instance id for [kind] (`browser` → `browser:2`):
  /// the bare kind counts as instance 1, numeric suffixes scan upward.
  String nextInstanceId(final String kind) {
    var max = 1;
    for (final id in allTabs) {
      if (!id.startsWith('$kind:')) continue;
      final n = int.tryParse(id.substring(kind.length + 1));
      if (n != null && n > max) max = n;
    }
    return '$kind:${max + 1}';
  }

  // ---- internals ----

  ShellLayout _withGroup(
    final int index,
    final ViewState state, {
    final bool activate = false,
  }) {
    final next = List<ViewState>.of(groups)..[index] = state;
    return ShellLayout._(next, activate ? index : active);
  }

  @override
  bool operator ==(final Object other) =>
      other is ShellLayout &&
      other.active == active &&
      listEquals(other.groups, groups);

  @override
  int get hashCode => Object.hash(active, Object.hashAll(groups));

  @override
  String toString() => 'ShellLayout(groups: $groups, active: $active)';
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
  // Conversations is the door: bring it to the front, and keep one tab
  // per surface id (first occurrence wins).
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
