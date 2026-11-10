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
library;

import 'package:flutter/gestures.dart' show kMiddleMouseButton;

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_layout.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/surfaces.dart';
import 'package:lastanswer/shell/window_drag.dart';

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
    this.pickerLink,
    this.pickerOwner = false,
    this.lightsGutter = false,
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

  /// The picker overlay's anchor link; [pickerOwner] marks the strip
  /// whose `+` currently carries the target (ONE picker, re-anchored).
  final LayerLink? pickerLink;
  final bool pickerOwner;

  /// The title-bar-is-gone law (DESIGN.md v2): on macOS the FIRST
  /// group's strip is the window's top row — the traffic lights ride
  /// at its head, so it keeps an inert, draggable lights zone there.
  final bool lightsGutter;

  String _titleOf(final String surfaceId) =>
      titleFor?.call(surfaceId) ?? surfaces[surfaceId]?.title ?? surfaceId;

  @override
  Widget build(final BuildContext context) {
    final state = layout.groups[group];
    final tabs = state.tabs;
    final activeId = state.activeId;
    final l10n = context.l10n;
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
            // Safari compression: the strip's usable width minus the
            // controls; full pills first, then compress rightmost-first
            // until they fit; the focused tab keeps its title longest.
            const controlsWidth = 132.0;
            const fullWidth = 150.0;
            const compactWidth = 34.0;
            final usable =
                constraints.maxWidth - controlsWidth - (lightsGutter ? 72 : 0);
            final fullCount = _fullCount(tabs.length, usable);
            final compressed = <String>{
              for (var i = tabs.length - 1; i >= fullCount; i--) tabs[i],
            }..remove(activeId);
            return Row(
              children: [
                if (lightsGutter)
                  // The traffic lights' zone (Safari anatomy): inert,
                  // draggable, never interactive chrome.
                  const SizedBox(width: 72, height: ShellTokens.stripHeight),
                const SizedBox(width: 4),
                _StripControl(
                  key: ValueKey('view.group.back.$group'),
                  label: 'view.group.back.$group',
                  tooltip: l10n.stripBack,
                  icon: Icons.arrow_back,
                  enabled: state.canBack,
                  onTap: onBack,
                ),
                _StripControl(
                  key: ValueKey('view.group.forward.$group'),
                  label: 'view.group.forward.$group',
                  tooltip: l10n.stripForward,
                  icon: Icons.arrow_forward,
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
                              for (var i = 0; i < tabs.length; i++)
                                _dragTab(
                                  context,
                                  tabs,
                                  i,
                                  activeId,
                                  compressed,
                                ),
                            ],
                          ),
                        ),
                  ),
                ),
                if (group == 0)
                  _StripControl(
                    key: ValueKey('view.group.split.$group'),
                    label: 'view.group.split.$group',
                    tooltip: l10n.stripSplit,
                    icon: Icons.vertical_split,
                    enabled: true,
                    onTap: onSplit,
                  )
                else
                  _StripControl(
                    key: ValueKey('view.group.fold.$group'),
                    label: 'view.group.fold.$group',
                    tooltip: l10n.stripFold,
                    icon: Icons.close_fullscreen,
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
  /// the overlay.
  Widget _dragTab(
    final BuildContext context,
    final List<String> tabs,
    final int index,
    final String activeId,
    final Set<String> compressed,
  ) {
    final id = tabs[index];
    Widget pill() => _StripTab(
      surfaceId: id,
      title: _titleOf(id),
      leading:
          leadingFor?.call(id) ??
          (surfaces[id]?.icon != null
              ? Icon(surfaces[id]!.icon, size: 13, color: context.shellMuted)
              : null),
      focused: id == activeId,
      compact: compressed.contains(id),
      onTap: () => onSelect(id),
      onClose: () => onClose(id),
      onContext: onTabContext,
    );
    final leading =
        leadingFor?.call(id) ??
        (surfaces[id]?.icon != null
            ? Icon(surfaces[id]!.icon, size: 13, color: context.shellMuted)
            : null);
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
          _insertAt(tabs, details.data, index),
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

/// The drag's ghost chip (the mockup's ghost tab): the tab's identity
/// mark + title, styled like the strip's pills but elevated — a
/// floating layer, so ONE soft shadow (DESIGN §3), never an elevation
/// ladder.
final class _TabGhost extends StatelessWidget {
  const _TabGhost({required this.title, this.leading, super.key});

  final String title;
  final Widget? leading;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: ShellTokens.tabHeight,
      constraints: const BoxConstraints(maxWidth: 176),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: context.la.surfaceRaised,
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
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 12,
                color: context.la.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
/// the shell for the context menu.
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
  });

  final String surfaceId;
  final String title;
  final bool focused;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final void Function(String surfaceId, Offset globalPosition) onContext;
  final Widget? leading;

  @override
  State<_StripTab> createState() => _StripTabState();
}

final class _StripTabState extends State<_StripTab> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final showClose = widget.focused || _hovering;
    return Semantics(
      button: true,
      selected: widget.focused,
      // The agent contract: the Semantics name IS the widget key; the
      // human title rides the hint.
      label: 'view.tab.${widget.surfaceId}',
      hint: 'tab ${widget.title}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (final _) => setState(() => _hovering = true),
        onExit: (final _) => setState(() => _hovering = false),
        child: Listener(
          // Middle-click closes (the browser law), without disturbing
          // the primary tap path.
          onPointerDown: (final event) {
            if (event.buttons == kMiddleMouseButton) widget.onClose();
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onSecondaryTapUp: (final details) =>
                widget.onContext(widget.surfaceId, details.globalPosition),
            onLongPressStart: (final details) =>
                widget.onContext(widget.surfaceId, details.globalPosition),
            child: Container(
              height: ShellTokens.tabHeight,
              constraints: BoxConstraints(maxWidth: widget.compact ? 42 : 176),
              margin: const EdgeInsets.symmetric(vertical: 3.5),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                color: widget.focused
                    ? context.la.surfaceRaised
                    : _hovering
                    ? context.shellHover
                    : null,
                borderRadius: BorderRadius.circular(ShellTokens.tabRadius),
                boxShadow: widget.focused
                    ? [
                        const BoxShadow(
                          color: Color(0x2E000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 6),
                  ],
                  if (!widget.compact)
                    Flexible(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 12,
                          color: widget.focused
                              ? context.la.ink
                              : context.shellMuted,
                          fontWeight: widget.focused
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  if (showClose) ...[
                    const SizedBox(width: 5),
                    GestureDetector(
                      key: ValueKey('view.tab.close.${widget.surfaceId}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onClose,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: context.shellMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A strip control: the per-group chrome buttons (back/forward, split,
/// fold) — 24px quiet glyphs, the §2.3 Semantics-name-is-key contract.
final class _StripControl extends StatefulWidget {
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
  State<_StripControl> createState() => _StripControlState();
}

final class _StripControlState extends State<_StripControl> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    enabled: widget.enabled,
    label: widget.label,
    hint: widget.tooltip,
    child: Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (final _) => setState(() => _hovering = true),
        onExit: (final _) => setState(() => _hovering = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? widget.onTap : null,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _hovering && widget.enabled ? context.shellHover : null,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              widget.icon,
              size: 14,
              color: widget.enabled
                  ? context.shellMuted
                  : context.la.inkQuiet.withValues(alpha: 0.4),
            ),
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
          child: Icon(Icons.add, size: 16, color: context.shellMuted),
        ),
      ),
    ),
  );
}
