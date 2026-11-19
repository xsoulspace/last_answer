/// DESIGN.md v2 — the group-scoped tab strip (VS Code/Zed anatomy, the
/// owner's split-redesign law): tab ownership is scoped to PANE GROUPS,
/// never the window. Each pane column renders its OWN strip with its
/// per-group controls at the head — back/forward (the group's focus
/// MRU), the split control (group 0 — moves the active tab into a new
/// pane to the right), the fold control (groups after the first —
/// merges back), and the group's own `+` (the new-tab picker anchor).
/// Chrome budget per pane: ONE strip row + at most one toolbar row
/// inside the view; view-internal headers are content, not chrome.
///
/// Zero Material ink (hover + gesture + hairline, the de-Material law),
/// rounded compact tabs (27px, radius 8 — the only chrome up top),
/// Safari compression on overflow, middle-click close, right-click for
/// the window presentation (miniwindow), and the §2.3 contract: every
/// control's Semantics name is its widget key.
///
/// Native drag (the workspace projection law, VSCode muscle memory):
/// every tab is a `Draggable<String>` (its id) AND a `DragTarget<String>`
/// — a drop on a tab inserts BEFORE it, a drop on the strip's trailing
/// free space (`strip.drop.<group>`) appends, and a drop on the dragged
/// tab itself is inert. Hover affordance is shape + accent (a 2px
/// leading edge on the hovered tab, a dashed outline on the trailing
/// zone), never color alone; the ghost chip (`drag.ghost.<id>`) is a
/// floating layer — ONE soft shadow (DESIGN §3). The strip stays
/// callback-driven: every drop leaves through [PaneStrip.onMoveTab].
///
/// Wave I — the overflow law (owner fix list 2026-11-10, the ~30-tab
/// restore): compression alone made the strip an unreadable icon row,
/// so the strip now CAPS its visible pills — at most as many as fit at
/// COMPRESSED width with ONE slot reserved for the overflow control
/// (`view.strip.overflow.<group>`). Tabs beyond the cap hide
/// rightmost-first (the compression order); the ACTIVE tab is never
/// hidden — when it lands beyond the cap it swaps into the last
/// visible slot and the displaced tab hides in its place. The overflow
/// control shows the hidden count ("+N") and opens a menu listing
/// EVERY hidden tab (title + kind glyph + unread count); a menu row
/// OPENS that tab through [PaneStrip.onSelect]. Menu rows never drag —
/// hidden tabs are simply not in the tree, so the wave-C drag law
/// applies to the visible pills only, and a drop on a visible pill
/// still inserts at that tab's ORIGINAL layout index (the layout
/// document stays the authority; the strip never reorders it).
///
/// The unread badge law (Wave I): a badge NEVER renders below 14px —
/// full pills keep the numeric badge (fixed 14px height, one line,
/// never wrapped or stacked); COMPRESSED pills ride a fixed 6px dot on
/// the glyph's corner (shape beside the glyph, never color alone; the
/// overflow menu's row carries the count). A read room renders no
/// badge — honest absence, never a zero pill.
library;

import 'package:ecsly_flutter/ecsly_flutter.dart';
import 'package:flutter/gestures.dart' show kMiddleMouseButton;

import 'package:lastanswer/coding_agent/realm_chat/conversation_spaces.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/world/ecs/la_world.dart';
import 'package:lastanswer/ui_shell/shell_layout.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:lastanswer/ui_shell/surfaces.dart';
import 'package:lastanswer/ui_shell/window_drag.dart';

/// One pane group's strip: its tabs and the per-group controls.
final class PaneStrip extends StatelessWidget {
  const PaneStrip({
    required this.group,
    required this.layout,
    required this.surfaces,
    required this.onSelect,
    required this.onClose,
    required this.onNewTab,
    required this.onSplit,
    required this.onFold,
    required this.onBack,
    required this.onForward,
    required this.onMoveTab,
    required this.onTabContext,
    this.titleFor,
    this.leadingFor,
    this.unreadFor,
    this.pickerLink,
    this.pickerOwner = false,
    super.key,
  });

  /// The pane group's index (strips are keyed `view.strip.<group>`).
  final int group;
  final ShellLayout layout;
  final SurfaceRegistry surfaces;

  /// A tab tap.
  final ValueChanged<String> onSelect;

  /// A tab's ✕ (or middle-click).
  final ValueChanged<String> onClose;

  /// The group's `+` (and ⌘T on the active group): the picker menu.
  final VoidCallback onNewTab;

  /// The split control (group 0): the active tab moves into a new pane.
  final VoidCallback onSplit;

  /// The fold control (groups after the first): merge back left.
  final VoidCallback onFold;

  final VoidCallback onBack;
  final VoidCallback onForward;

  /// A native drag landed: move [tabId] into [group] at [at] (null =
  /// append to the strip's end). The shell translates it into
  /// [ShellLayout.moveTabTo] — the strip never touches layout state.
  final void Function(String tabId, int group, int? at) onMoveTab;

  /// Right-click (or long-press) on a tab: the shell's context menu.
  final void Function(String surfaceId, Offset globalPosition) onTabContext;

  final String? Function(String surfaceId)? titleFor;
  final Widget? Function(String surfaceId)? leadingFor;

  /// An injected unread fact (hermetic tests): the badge count for one
  /// tab. Null (the shell) rides the live LaWorld path — an
  /// [EcsWorldSelector] over the cursor fold keyed by the tab's thread
  /// (the rooms-column badge's twin), never a poll.
  final int? Function(String surfaceId)? unreadFor;

  /// The picker overlay's anchor link; [pickerOwner] marks the strip
  /// whose `+` currently carries the target (ONE picker, re-anchored).
  final LayerLink? pickerLink;
  final bool pickerOwner;

  String _titleOf(final String surfaceId) =>
      titleFor?.call(surfaceId) ?? surfaces[surfaceId]?.title ?? surfaceId;

  /// The tab's identity mark: the shell's injected leading (avatar,
  /// channel mark) first, then the registry's kind icon.
  Widget? _leadingOf(final String surfaceId, final BuildContext context) =>
      leadingFor?.call(surfaceId) ??
      (surfaces[surfaceId]?.icon != null
          ? Icon(
              surfaces[surfaceId]!.icon,
              size: 13,
              color: context.shellMuted,
            )
          : null);

  /// The live LaWorld (honest absence when the host provides none).
  static LaWorld? _laWorldOf(final BuildContext context) {
    try {
      return context.read<LaWorld?>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// The live chat service (the `dm:`/`channel:` → thread lane); null
  /// outside the shell keeps `room:` tabs badging and the rest honest-
  /// absent.
  static RealmChatService? _serviceOf(final BuildContext context) {
    try {
      return context.read<RealmChatService>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// The thread behind a conversation tab id (the badge is a thread's
  /// fact, never an invention): `room:<threadId>` directly, `dm:` and
  /// `channel:` through the service's live lanes.
  static String? _threadIdOf(
    final String surfaceId,
    final RealmChatService? service,
  ) {
    if (surfaceId.startsWith('room:')) {
      return surfaceId.substring('room:'.length);
    }
    if (surfaceId.startsWith('dm:')) {
      return service?.dmThreadOf(surfaceId.substring('dm:'.length));
    }
    if (surfaceId.startsWith('channel:')) {
      final channelId = surfaceId.substring('channel:'.length);
      for (final channel in service?.channels ?? const <ChannelInfo>[]) {
        if (channel.channelId == channelId) return channel.threadId;
      }
    }
    return null;
  }

  /// The unread count NOW (the overflow menu's transient row fact):
  /// the injected lane first, else the live projection's synchronous
  /// read. No world, no thread, a read room: 0 — honest absence.
  int _unreadNow(
    final String surfaceId,
    final LaWorld? laWorld,
    final RealmChatService? service,
  ) {
    final injected = unreadFor;
    if (injected != null) return injected(surfaceId) ?? 0;
    if (laWorld == null) return 0;
    final threadId = _threadIdOf(surfaceId, service);
    if (threadId == null) return 0;
    return laWorld.unreadByThread()[threadId] ?? 0;
  }

  @override
  Widget build(final BuildContext context) {
    final state = layout.groups[group];
    final tabs = state.tabs;
    final activeId = state.activeId;
    final l10n = context.l10n;
    final laWorld = _laWorldOf(context);
    final service = _serviceOf(context);
    final add = _AddTabButton(
      key: ValueKey('view.strip.add.$group'),
      label: 'view.strip.add.$group',
      onTap: onNewTab,
    );
    return WindowDragRegion(
      // The strip's empty chrome is the window's drag region (the
      // title bar is gone); child controls keep their taps — a tap
      // never becomes a pan.
      child: Container(
        key: ValueKey('view.strip.$group'),
        height: ShellTokens.stripHeight,
        decoration: BoxDecoration(
          color: context.la.surface,
          border: Border(
            bottom: BorderSide(
              color: context.shellHairline,
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            // Safari compression + the Wave I cap: the strip's usable
            // width minus the controls; the cap is how many pills fit
            // at COMPRESSED width with ONE slot reserved for the
            // overflow control. Beyond the cap the tail hides (the
            // compression order) behind the overflow menu; the ACTIVE
            // tab is never hidden — it swaps into the last visible
            // slot and the displaced tab hides in its place. Inside
            // the cap the old law stands: full pills first, then
            // compress rightmost-first until they fit; the focused tab
            // keeps its title longest.
            const controlsWidth = 132.0;
            const compactWidth = 34.0;
            const overflowSlot = _kOverflowSlot;
            final usable = constraints.maxWidth - controlsWidth;
            final cap = ((usable - overflowSlot) / compactWidth).floor();
            final overflowing = tabs.length > cap;
            final visibleCount = overflowing
                ? (cap < 1 ? 1 : cap)
                : tabs.length;
            // The visible SLOTS (original tab indices, left → right):
            // the head of the list, with the last slot carrying the
            // active tab when the cap would have hidden it.
            final slots = <int>[
              for (var i = 0; i < visibleCount; i++) i,
            ];
            final activeIndex = tabs.indexOf(activeId);
            if (overflowing && activeIndex >= visibleCount) {
              slots[visibleCount - 1] = activeIndex;
            }
            final slotSet = slots.toSet();
            final visibleIds = <String>[for (final i in slots) tabs[i]];
            // The hidden tabs in ORIGINAL tab order (the menu's row
            // order): everything the cap cut, the displaced slot's tab
            // included at its own index.
            final hiddenIds = <String>[
              for (var i = 0; i < tabs.length; i++)
                if (!slotSet.contains(i)) tabs[i],
            ];
            final tabsWidth = usable - (overflowing ? overflowSlot : 0.0);
            final fullCount = _fullCount(visibleCount, tabsWidth);
            final compressed = <String>{
              for (var s = visibleIds.length - 1; s >= fullCount; s--)
                visibleIds[s],
            }..remove(activeId);
            return Row(
              children: [
                const SizedBox(width: 4),
                _StripControl(
                  key: ValueKey('view.group.back.$group'),
                  label: 'view.group.back.$group',
                  tooltip: l10n.stripBack,
                  icon: Icons.arrow_back_outlined,
                  enabled: state.canBack,
                  onTap: onBack,
                ),
                _StripControl(
                  key: ValueKey('view.group.forward.$group'),
                  label: 'view.group.forward.$group',
                  tooltip: l10n.stripForward,
                  icon: Icons.arrow_forward_outlined,
                  enabled: state.canForward,
                  onTap: onForward,
                ),
                const SizedBox(width: 2),
                Expanded(
                  // The strip's trailing free space is the APPEND drop
                  // zone (`strip.drop.<group>`): the tabs ride their own
                  // inner targets, and a tab dropped on ITSELF stays
                  // inert (the tab's target swallows that drop, so a
                  // grab in place never throws the tab to the end). A
                  // hovered zone shows the dashed outline — shape +
                  // accent, never color alone (the mockup law).
                  child: DragTarget<String>(
                    key: ValueKey('strip.drop.$group'),
                    onWillAcceptWithDetails: (final details) =>
                        layout.groupOf(details.data) >= 0,
                    onAcceptWithDetails: (final details) =>
                        onMoveTab(details.data, group, null),
                    builder: (
                      final context,
                      final hovering,
                      final rejected,
                    ) =>
                        CustomPaint(
                          foregroundPainter: hovering.isEmpty
                              ? null
                              : _DashedOutline(context.la.accent),
                          // A ListView, not a SingleChildScrollView:
                          // the SCV's semantics subtree never assembles
                          // in a live desktop app (measured: elements
                          // mounted, render objects attached,
                          // `debugSemantics` null, full re-assembly
                          // forced — still absent; ListView-backed lists
                          // keep their nodes). Screen readers and agents
                          // need the strip's tabs, so the strip rides the
                          // primitive whose semantics provenly works.
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              // The Wave I cap: only the visible slots
                              // are in the tree — hidden tabs render
                              // through the overflow menu, never here.
                              for (var s = 0; s < slots.length; s++)
                                _dragTab(
                                  context,
                                  tabs,
                                  visibleIds[s],
                                  slots[s],
                                  activeId,
                                  compressed,
                                  laWorld,
                                  service,
                                ),
                            ],
                          ),
                        ),
                  ),
                ),
                if (overflowing)
                  _OverflowControl(
                    key: ValueKey('view.strip.overflow.$group'),
                    label: 'view.strip.overflow.$group',
                    count: hiddenIds.length,
                    tooltip: l10n.stripOverflowHint,
                    hidden: hiddenIds,
                    titleOf: _titleOf,
                    leadingOf: (final id) => _leadingOf(id, context),
                    unreadOf: (final id) => _unreadNow(id, laWorld, service),
                    onOpen: onSelect,
                  ),
                if (group == 0)
                  _StripControl(
                    key: ValueKey('view.group.split.$group'),
                    label: 'view.group.split.$group',
                    tooltip: l10n.stripSplit,
                    icon: Icons.vertical_split_outlined,
                    enabled: true,
                    onTap: onSplit,
                  )
                else
                  _StripControl(
                    key: ValueKey('view.group.fold.$group'),
                    label: 'view.group.fold.$group',
                    tooltip: l10n.stripFold,
                    icon: Icons.close_fullscreen_outlined,
                    enabled: true,
                    onTap: onFold,
                  ),
                if (pickerOwner && pickerLink != null)
                  CompositedTransformTarget(link: pickerLink!, child: add)
                else
                  add,
                const SizedBox(width: 6),
              ],
            );
          },
        ),
      ),
    );
  }

  /// How many tabs keep their title at [usable] width when the rest
  /// compress (the focused tab is never counted as compressible).
  int _fullCount(final int tabCount, final double usable) {
    const fullWidth = 150.0;
    const compactWidth = 34.0;
    for (var full = tabCount; full >= 0; full--) {
      final width = full * fullWidth + (tabCount - full) * compactWidth;
      if (width <= usable) return full;
    }
    return 0;
  }

  /// ONE draggable tab (the native-drag law): the pill is the drag
  /// source (its id) AND the insert-BEFORE drop target. The TARGET
  /// rides OUTSIDE the draggable so it stays mounted mid-drag (the
  /// draggable swaps its child for the dimmed pill): a drop back on the
  /// tab's own slot is then swallowed inert, never falling through to
  /// the strip's append zone. Will-accept is "an open tab, never a
  /// ghost id"; the hover affordance is the 2px accent leading edge
  /// (`drop.hover.<id>` is its testable state). The ghost chip rides
  /// the overlay. [originalIndex] is the tab's slot in the FULL layout
  /// list (the Wave I cap hides the tail, so the visible position and
  /// the layout position diverge) — a drop inserts at the layout index,
  /// never at the visual one.
  Widget _dragTab(
    final BuildContext context,
    final List<String> tabs,
    final String id,
    final int originalIndex,
    final String activeId,
    final Set<String> compressed,
    final LaWorld? laWorld,
    final RealmChatService? service,
  ) {
    Widget pill() => _StripTab(
      surfaceId: id,
      title: _titleOf(id),
      leading: _leadingOf(id, context),
      focused: id == activeId,
      compact: compressed.contains(id),
      onTap: () => onSelect(id),
      onClose: () => onClose(id),
      onContext: onTabContext,
      unreadFor: unreadFor,
      laWorld: laWorld,
      threadId: _threadIdOf(id, service),
    );
    final leading = _leadingOf(id, context);
    return DragTarget<String>(
      onWillAcceptWithDetails: (final details) =>
          layout.groupOf(details.data) >= 0,
      onAcceptWithDetails: (final details) {
        // The tab's own slot is inert: a grab released in place changes
        // nothing (and must never throw the tab to the strip's end).
        if (details.data == id) return;
        onMoveTab(
          details.data,
          group,
          _insertAt(tabs, details.data, originalIndex),
        );
      },
      builder: (final context, final hovering, final rejected) => Stack(
        children: [
          Draggable<String>(
            key: ValueKey('view.tab.$id'),
            data: id,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: _TabGhost(
              key: ValueKey('drag.ghost.$id'),
              title: _titleOf(id),
              leading: leading,
            ),
            childWhenDragging: Opacity(opacity: 0.35, child: pill()),
            child: pill(),
          ),
          if (hovering.isNotEmpty && hovering.first != id)
            Positioned(
              left: 0,
              top: 5,
              bottom: 5,
              child: Container(
                key: ValueKey('drop.hover.$id'),
                width: 2,
                decoration: BoxDecoration(
                  color: context.la.accent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The index a drop BEFORE `tabs[hovered]` inserts at: a same-strip
  /// drag counts the strip AFTER the dragged tab left its old slot, so
  /// a drag from the left shifts the target down by one. A tab from
  /// another group is not in [tabs] — the hovered index stands.
  int _insertAt(
    final List<String> tabs,
    final String dragged,
    final int hovered,
  ) {
    final from = tabs.indexOf(dragged);
    return from >= 0 && from < hovered ? hovered - 1 : hovered;
  }
}

/// The overflow control's reserved slot (px, the Wave I cap formula):
/// ONE compressed-width slot at the strip's tail. The pill inside is
/// constrained to fit it (max 36 + 2×2 margin).
const double _kOverflowSlot = 40;

/// The strip's overflow control (the Wave I law): a trailing pill
/// naming the hidden count ("+N") whose tap opens the hidden tabs'
/// menu — every hidden tab with its title, kind glyph and unread
/// count. A row OPENS its tab through [onOpen] (the strip's ordinary
/// select path); rows never drag — hidden tabs are simply not in the
/// tree, so the wave-C drag law belongs to the visible pills alone.
/// The menu is the rooms-column context menu's twin (`showLaMenuAt`, the
/// §2.3 Semantics-name-is-key contract on the control).
final class _OverflowControl extends StatefulWidget {
  const _OverflowControl({
    required this.label,
    required this.count,
    required this.tooltip,
    required this.hidden,
    required this.titleOf,
    required this.leadingOf,
    required this.unreadOf,
    required this.onOpen,
    super.key,
  });

  /// The Semantics name (the widget key — the §2.3 contract).
  final String label;
  final int count;
  final String tooltip;
  final List<String> hidden;
  final String Function(String surfaceId) titleOf;
  final Widget? Function(String surfaceId) leadingOf;
  final int Function(String surfaceId) unreadOf;
  final ValueChanged<String> onOpen;

  @override
  State<_OverflowControl> createState() => _OverflowControlState();
}

final class _OverflowControlState extends State<_OverflowControl> {
  // NOTE (test-pass sweep 2026-11-16): the first conversion used
  // imperative showLaMenuAt, whose edge-flip estimates width from
  // `minWidth` — wide row children (title + glyph + count) then painted
  // past the window's right edge and the menu was untappable. The
  // trigger sits at the strip's right tail, so the kit grammar for it
  // is the declarative LaMenuAnchor with `alignRight` (the menu's right
  // edge pins to the trigger's right edge and opens leftward). The
  // frozen `view.strip.overflow.item.<id>` keys, the open-on-choice
  // close and the hidden-list facts are unchanged.
  List<LaMenuEntry> get _entries => [
    for (final id in widget.hidden)
      LaMenuItem(
        key: ValueKey('view.strip.overflow.item.$id'),
        child: _menuRow(id),
        onPressed: () => widget.onOpen(id),
      ),
  ];

  /// ONE menu row: the kind glyph, the title (ellipsized), and the
  /// unread count — the numeric badge the compressed pill gave up
  /// (the dot is never color-alone: the count lives here).
  Widget _menuRow(final String id) {
    final unread = widget.unreadOf(id);
    final glyph =
        widget.leadingOf(id) ??
        Icon(Icons.tab_outlined, size: 14, color: context.shellMuted);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 16, height: 16, child: glyph),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(
            widget.titleOf(id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: context.laUi.compact.copyWith(color: context.laUi.ink),
          ),
        ),
        if (unread > 0) ...[
          const SizedBox(width: 8),
          Semantics(
            key: ValueKey('view.strip.overflow.unread.$id'),
            label: 'view.strip.overflow.unread.$id',
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
                maxHeight: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.la.accent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: context.laUi.micro.copyWith(
                  color: context.laUi.onAccent,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    hint: widget.tooltip,
    child: LaTooltip(
      message: widget.tooltip,
      // The anchor owns the menu; the pill stays the trigger.
      child: LaMenuAnchor.builder(
        entries: _entries,
        alignRight: true,
        // The shadcn dropdown height law: the list scrolls past ~10
        // rows instead of painting an unbounded column (the ~30-tab
        // restore's +26 rendered a screen-tall menu).
        maxHeight: 320,
        childBuilder: (final context, final anchor) => LaPressable(
          onTap: anchor.toggle,
          radius: BorderRadius.circular(ShellTokens.tabRadius),
          margin: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 2),
          // The outer Semantics carries the §2.3 contract — frozen.
          semanticsButton: false,
          child: Container(
            height: ShellTokens.tabHeight,
            constraints: const BoxConstraints(minWidth: 34, maxWidth: 36),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            child: Text(
              '+${widget.count}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: context.laUi.micro.copyWith(
                fontWeight: FontWeight.w600,
                color: context.shellMuted,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The drag's ghost chip (the mockup's ghost tab): the tab's identity
/// mark + title, styled like the strip's pills but elevated — a
/// floating layer, so ONE soft shadow (DESIGN §3), never an elevation
/// ladder.
final class _TabGhost extends StatelessWidget {
  const _TabGhost({required this.title, this.leading, super.key});

  final String title;
  final Widget? leading;

  @override
  Widget build(final BuildContext context) => Container(
    height: ShellTokens.tabHeight,
    constraints: const BoxConstraints(maxWidth: 176),
    padding: const EdgeInsets.symmetric(horizontal: 9),
    decoration: BoxDecoration(
      color: context.laUi.surfaceRaised,
      borderRadius: BorderRadius.circular(ShellTokens.tabRadius),
      boxShadow: shellFloatingShadow(context),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 6)],
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.laUi.compact.copyWith(
              color: context.laUi.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

/// The trailing drop zone's hover affordance (the mockup's dashed
/// edge): a dashed rounded outline in the accent — dashes carry the
/// meaning by SHAPE, never by color alone.
final class _DashedOutline extends CustomPainter {
  const _DashedOutline(this.color);

  final Color color;

  @override
  void paint(final Canvas canvas, final Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(2, 4, size.width - 2, size.height - 4),
          const Radius.circular(ShellTokens.tabRadius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(final _DashedOutline oldDelegate) =>
      oldDelegate.color != color;
}

/// One tab pill (v2 law: 27px, radius 8, raised-pill active): identity
/// mark + title (+ ✕ on hover/focus). Semantics: a named button — the
/// agent/screen-reader contract; middle-click closes; right-click asks
/// the shell for the context menu. The Wave I badge law rides the
/// pill: full pills keep the numeric badge, compressed pills ride the
/// 6px corner dot — a badge never renders below 14px of text width,
/// never wraps, never stacks.
final class _StripTab extends StatefulWidget {
  const _StripTab({
    required this.surfaceId,
    required this.title,
    required this.focused,
    required this.compact,
    required this.onTap,
    required this.onClose,
    required this.onContext,
    this.leading,
    this.unreadFor,
    this.laWorld,
    this.threadId,
  });

  final String surfaceId;
  final String title;
  final bool focused;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final void Function(String surfaceId, Offset globalPosition) onContext;
  final Widget? leading;

  /// The injected unread lane (hermetic tests); null rides the live
  /// [laWorld] + [threadId] selector.
  final int? Function(String surfaceId)? unreadFor;
  final LaWorld? laWorld;
  final String? threadId;

  @override
  State<_StripTab> createState() => _StripTabState();
}

final class _StripTabState extends State<_StripTab> {
  /// The badge SHAPE (the Wave I law): compressed → the fixed 6px dot
  /// (never text, so it can never stack); full → the numeric badge on
  /// fixed 14px height, one line, minWidth 14 — the squeeze that
  /// painted vertical glyphs is structurally impossible.
  Widget _badgeShape(final BuildContext context, final int unread) {
    final badgeKey = 'view.tab.unread.${widget.surfaceId}';
    if (widget.compact) {
      return Semantics(
        key: ValueKey(badgeKey),
        label: badgeKey,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: context.la.accent,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Semantics(
      key: ValueKey(badgeKey),
      label: badgeKey,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 14,
          minHeight: 14,
          maxHeight: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.la.accent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          unread > 99 ? '99+' : '$unread',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          style: context.laUi.micro.copyWith(
            color: context.laUi.onAccent,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  /// The badge slot: the injected fact (tests) or the live reactive
  /// selector over the cursor fold (the rooms-column badge's twin —
  /// no LaWorld, no thread or a read room renders nothing: honest
  /// absence, never a zero pill).
  Widget? _badgeSlot(final BuildContext context) {
    final injected = widget.unreadFor;
    if (injected != null) {
      final count = injected(widget.surfaceId) ?? 0;
      return count > 0 ? _badgeShape(context, count) : null;
    }
    final laWorld = widget.laWorld;
    final threadId = widget.threadId;
    if (laWorld == null || threadId == null) return null;
    return EcsWorldSelector<int>(
      world: laWorld.world,
      controller: laWorld.controller,
      select: (final world) => laWorld.unreadByThread()[threadId] ?? 0,
      builder: (final context, final unread) => unread > 0
          ? _badgeShape(context, unread)
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final badge = _badgeSlot(context);
    // The compressed pill's glyph carries the dot on its corner (a
    // zero-extra-width Stack, so the 34px budget stands); a glyph-less
    // compressed pill rides the dot inline.
    Widget? glyph = widget.leading;
    if (widget.compact && badge != null && glyph != null) {
      glyph = Stack(
        clipBehavior: Clip.none,
        children: [
          glyph,
          Positioned(right: -2, top: -2, child: badge),
        ],
      );
    }
    return Semantics(
      button: true,
      selected: widget.focused,
      // The agent contract: the Semantics name IS the widget key; the
      // human title rides the hint.
      label: 'view.tab.${widget.surfaceId}',
      hint: 'tab ${widget.title}',
      child: Listener(
        // Middle-click closes (the browser law), without disturbing
        // the primary tap path.
        onPointerDown: (final event) {
          if (event.buttons == kMiddleMouseButton) widget.onClose();
        },
        // The context-menu gestures ride OUTSIDE the pressable: they
        // need the event's globalPosition, which LaPressable's
        // position-less callbacks do not carry (kit gap). The
        // pressable's own detector never registers these, so the
        // arena has exactly one claimant each.
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onSecondaryTapUp: (final details) =>
              widget.onContext(widget.surfaceId, details.globalPosition),
          onLongPressStart: (final details) =>
              widget.onContext(widget.surfaceId, details.globalPosition),
          child: LaPressable.builder(
            onTap: widget.onTap,
            selected: widget.focused,
            // The focused pill states itself through the RAISED fill
            // (Wave K one-shadow law), not the ink-alpha selected wash.
            selectedFill: context.laUi.surfaceRaised,
            radius: BorderRadius.circular(ShellTokens.tabRadius),
            margin: const EdgeInsets.symmetric(vertical: 3.5),
            // The outer Semantics carries the §2.3 contract — frozen.
            semanticsButton: false,
            childBuilder: (final context, final state) {
              final closeVisible = widget.focused || state.hovered;
              return Container(
                height: ShellTokens.tabHeight,
                constraints: BoxConstraints(
                  maxWidth: widget.compact ? 42 : 176,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.compact) ...[
                      if (glyph != null)
                        glyph
                      else ?badge,
                    ] else ...[
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.laUi.compact.copyWith(
                            color: widget.focused
                                ? context.laUi.ink
                                : context.shellMuted,
                            fontWeight: widget.focused
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 5),
                        badge,
                      ],
                    ],
                    if (closeVisible) ...[
                      const SizedBox(width: 5),
                      GestureDetector(
                        key: ValueKey('view.tab.close.${widget.surfaceId}'),
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onClose,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(
                            Icons.close_outlined,
                            size: 12,
                            color: context.shellMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A strip control: the per-group chrome buttons (back/forward, split,
/// fold) — 24px quiet glyphs, the §2.3 Semantics-name-is-key contract.
/// The hover fill rides the kit's ONE state layer ([LaPressable], v6).
final class _StripControl extends StatelessWidget {
  const _StripControl({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    label: label,
    hint: tooltip,
    child: LaTooltip(
      message: tooltip,
      child: LaPressable(
        onTap: enabled ? onTap : null,
        enabled: enabled,
        radius: BorderRadius.circular(7),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        scaleOnPress: false,
        // The outer Semantics carries the §2.3 contract — frozen.
        semanticsButton: false,
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(
            icon,
            size: 14,
            color: enabled
                ? context.shellMuted
                : context.laUi.inkQuiet.withValues(alpha: 0.4),
          ),
        ),
      ),
    ),
  );
}

/// The strip's `+`: opens the picker menu anchored to THIS group.
final class _AddTabButton extends StatelessWidget {
  const _AddTabButton({required this.onTap, required this.label, super.key});

  final VoidCallback onTap;

  /// The Semantics name (the widget key — the §2.3 contract).
  final String label;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: label,
    hint: context.l10n.newTabPageTitle,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 26,
          height: ShellTokens.tabHeight + 4,
          child: Icon(
            Icons.add_outlined,
            size: 16,
            color: context.shellMuted,
          ),
        ),
      ),
    ),
  );
}
