/// WAVE 5 — the ONE top bar of view tabs (docs/design/unified-views.md).
/// The old center strip moves above the whole row (rail | center |
/// dock) and becomes the session's single map: what is open, what is
/// pinned. Two surface vocabularies share the bar:
///
/// - **Station views** (`browser`, `inspector`, `filesystem`, …): one
///   tab each; opening an already-open station focuses it.
/// - **The conversation slot**: every conversation surface id —
///   `dm:<actorId>`, `channel:<channelId>`, and the plain world face
///   `conversations` — maps to THE SAME slot. The actor rail does not
///   know about tabs; it selects through the service
///   ([RealmChatService.openDm] / [RealmChatService.selectChannel]),
///   and the shell translates the service's `activeThreadId` back to a
///   `dm:`/`channel:` surface id and REPLACES the slot's id in place
///   (Discord flow — rail clicks accumulate zero tabs). An explicit
///   new-tab intent (a ⌘-click on a rail row) opens a second
///   conversation tab instead ([ViewLayout.openConversation] with
///   `forceNew`).
///
/// Every STATIC view's tab carries a pin glyph (filled = pinned,
/// outline = not; tap toggles — [ViewLayout.pin]/[ViewLayout.unpin]).
/// Safari COMPRESSION: when the bar runs out of width, non-active tabs
/// degrade gracefully — title truncation collapses to icon-only
/// identity pills; the ACTIVE tab never loses its title.
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `center.tabs` (the bar), `center.tabs.add` (the trailing `+`),
/// `pane.tab.<viewId>` (select), `pane.tab.close.<viewId>` (close),
/// `pane.tab.pin.<viewId>` (toggle pin), `view.dock.restore` (the
/// narrow-window dock glyph), `newtab.page` (the picker page) and
/// `newtab.entry.<viewId>` (its destinations).
///
/// The browser-model laws (WAVE 4T, carried over):
/// - the `+` opens/focuses the ONE newtab tab ([ViewLayout.openNewTab]);
/// - picking a destination replaces the newtab tab in place
///   ([ViewLayout.pick]);
/// - closing the LAST tab swaps the newtab surface in — the window
///   keeps a page ([ViewLayout.close]);
/// - the picker is session chrome: a lone newtab tab never survives a
///   restart ([ViewLayout.fromJson]).
library;

import 'package:flutter/gestures.dart' show kMiddleMouseButton;

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_layout.dart';

/// The Codex-quiet tab bar: text tabs on one hairline — the active tab
/// reads through stronger ink plus a hairline underline, every tab
/// carries a pin glyph (static views) and a ✕ (browser law: closing
/// the last real tab swaps the picker in, so only a lone PICKER tab
/// keeps no ✕), the trailing `+` opens the picker, tabs close on
/// middle-click and drag to reorder. Zero Material chrome:
/// GestureDetector and hover only, no elevation, no ripple.
///
/// Overflow law (Safari compression): the bar measures its tabs'
/// natural widths and collapses non-active tabs to icon-only identity
/// pills (rightmost first) until the row fits; the active tab never
/// loses its title. A row that cannot fit even compressed scrolls
/// horizontally (Codex-like).
final class ViewTabBar extends StatelessWidget {
  const ViewTabBar({
    required this.layout,
    required this.surfaces,
    this.onSelect,
    this.onClose,
    this.onNewTab,
    this.onReorder,
    this.onTogglePin,
    this.titleFor,
    this.leadingFor,
    this.onDockRestore,
    super.key,
  });

  /// The bar's state (ids + active index + pins).
  final ViewLayout layout;

  /// The surface registry (titles, icons, identity widgets).
  final SurfaceRegistry surfaces;

  /// Focuses a tab.
  final ValueChanged<String>? onSelect;

  /// Closes a tab; invoked from tabs whose close keeps a valid bar
  /// (✕, middle-click — the same availability law drives both).
  final ValueChanged<String>? onClose;

  /// Opens/focuses the new-tab picker (the bar's trailing `+`).
  final VoidCallback? onNewTab;

  /// Repositions a tab (drag reorder), as [ViewLayout.move] arguments.
  final void Function(int from, int to)? onReorder;

  /// Toggles a static view's pin ([ViewLayout.pin]/[ViewLayout.unpin]);
  /// null hides the glyph entirely.
  final ValueChanged<String>? onTogglePin;

  /// Human title for ids the registry does not know (conversation
  /// surface ids); null falls back to the registry title, then the id.
  final String? Function(String surfaceId)? titleFor;

  /// Identity widget for ids the registry has no leading for
  /// (conversation surface ids: the actor's avatar, the channel's
  /// disc); null falls back to the registry icon in compressed pills.
  final Widget? Function(String surfaceId)? leadingFor;

  /// The narrow-window dock restore (the width gate hides the dock;
  /// the glyph focuses the first pinned view full-width). Null hides
  /// the glyph.
  final VoidCallback? onDockRestore;

  /// A tab's ✕/middle-click is offered whenever closing it keeps the
  /// browser law intact: any tab while others exist, and the lone last
  /// REAL tab too (the picker swaps in). Only the lone PICKER keeps no
  /// close affordance — nothing exists to swap into it.
  bool _canClose(final int index) =>
      layout.tabs.length > 1 || layout.tabs[index] != kNewTabSurfaceId;

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
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final style = theme.textTheme.labelMedium ?? const TextStyle();
            final widths = <double>[
              for (var i = 0; i < layout.tabs.length; i++)
                _measureTabWidth(
                  _titleOf(layout.tabs[i]),
                  style,
                  icon: surfaces[layout.tabs[i]]?.icon != null ||
                      leadingFor?.call(layout.tabs[i]) != null,
                  pinnable: _isPinnable(i),
                  canClose: _canClose(i),
                ),
            ];
            final modes = _computeTabModes(
              widths: widths,
              activeIndex: layout.active,
              availableWidth: constraints.maxWidth,
            );
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < layout.tabs.length; i++)
                    _ViewTab(
                      key: ValueKey('pane.tab.${layout.tabs[i]}'),
                      surfaceId: layout.tabs[i],
                      index: i,
                      tabCount: layout.tabs.length,
                      title: _titleOf(layout.tabs[i]),
                      icon: surfaces[layout.tabs[i]]?.icon,
                      leading:
                          surfaces[layout.tabs[i]]?.leading ??
                          leadingFor?.call(layout.tabs[i]),
                      active: i == layout.active,
                      pinned: layout.isPinned(layout.tabs[i]),
                      pinnable: _isPinnable(i),
                      iconOnly: modes[i] == _TabMode.iconOnly,
                      style: style,
                      onTap: () => onSelect?.call(layout.tabs[i]),
                      onClose: _canClose(i)
                          ? () => onClose?.call(layout.tabs[i])
                          : null,
                      onTogglePin: _isPinnable(i)
                          ? () => onTogglePin?.call(layout.tabs[i])
                          : null,
                      onReorder: onReorder,
                    ),
                  if (onNewTab != null) _NewTabButton(onTap: onNewTab!),
                  if (onDockRestore != null)
                    _DockRestoreButton(onTap: onDockRestore!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isPinnable(final int index) => isPinnableSurfaceId(layout.tabs[index]);

  String _titleOf(final String surfaceId) =>
      titleFor?.call(surfaceId) ??
      surfaces[surfaceId]?.title ??
      surfaceId;
}

/// One tab's presentation mode: the full chrome (title + pin + ✕) or
/// the compressed icon-only identity pill. The ACTIVE tab is always
/// full (its title never disappears).
enum _TabMode { full, iconOnly }

/// Fixed chrome widths of one tab (kept in one place so the natural
/// width measure and the widget's paddings agree).
const double _kTabHorizontalPadding = 12;
const double _kIconSize = 14;
const double _kGlyphGap = 6;
const double _kCloseSize = 13;
const double _kPinSize = 13;

/// Measures one tab's natural width (the full mode) with a
/// [TextPainter] — deterministic enough for the compression decision;
/// the row still scrolls if the estimate runs out.
double _measureTabWidth(
  final String title,
  final TextStyle style, {
  required final bool icon,
  required final bool pinnable,
  required final bool canClose,
}) {
  final painter = TextPainter(
    text: TextSpan(text: title, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  var width = _kTabHorizontalPadding * 2 + painter.width;
  if (icon) width += _kIconSize + _kGlyphGap;
  if (pinnable) width += _kPinSize + _kGlyphGap;
  if (canClose) width += _kCloseSize + _kGlyphGap;
  return width;
}

/// The icon-only pill's width: padding + the identity mark.
const double _kIconOnlyTabWidth =
    _kTabHorizontalPadding * 2 - 4 + _kIconSize;

/// Safari compression: collapse non-active tabs to icon-only identity
/// pills, rightmost first, until the row fits [availableWidth]. The
/// active tab never collapses.
List<_TabMode> _computeTabModes({
  required final List<double> widths,
  required final int activeIndex,
  required final double availableWidth,
}) {
  final count = widths.length;
  final modes = List<_TabMode>.filled(count, _TabMode.full);
  var total = widths.fold<double>(0, (final a, final b) => a + b) +
      // The trailing `+` (and, when shown, the dock glyph) ride along.
      _kNewTabButtonWidth + _kDockRestoreButtonWidth;
  if (total <= availableWidth) return modes;
  final order = <int>[
    for (var i = count - 1; i >= 0; i--)
      if (i != activeIndex) i,
  ];
  for (final i in order) {
    modes[i] = _TabMode.iconOnly;
    total -= widths[i] - _kIconOnlyTabWidth;
    if (total <= availableWidth) break;
  }
  return modes;
}

/// The `+` and dock-glyph buttons' fixed outer width (icon 15 + 10*2
/// horizontal padding), so the compression budget knows what the
/// trailing chrome costs.
const double _kNewTabButtonWidth = 35;
const double _kDockRestoreButtonWidth = 35;

/// The bar's trailing `+`: opens/focuses the new-tab picker. Quiet
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

/// The narrow-window dock glyph: the width gate hid the dock (its
/// pinned state survives); the glyph focuses the first pinned view
/// full-width — the simplest honest restore.
final class _DockRestoreButton extends StatefulWidget {
  const _DockRestoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_DockRestoreButton> createState() => _DockRestoreButtonState();
}

final class _DockRestoreButtonState extends State<_DockRestoreButton> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        key: const ValueKey('view.dock.restore'),
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          height: ShellTokens.tabHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Tooltip(
              message: context.l10n.viewDockRestoreTooltip,
              child: Icon(
                Icons.view_sidebar_outlined,
                size: 15,
                color: _hovering
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.78)
                    : context.shellMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One tab: quiet ink, hover emphasis, the active hairline underline,
/// a pin glyph on static views (filled = pinned, outline = not; tap
/// toggles), a ✕ while its close keeps a valid bar, middle-click to
/// close, and horizontal drag to reposition (the simplest honest
/// reorder: one swap per dragged-tab-width of travel — the tap and the
/// ✕ stay tappable because taps resolve before the drag slop).
/// Compressed ([_TabMode.iconOnly]) the tab degrades to its identity
/// pill: leading/icon only — title, pin and ✕ give way (middle-click
/// still closes).
final class _ViewTab extends StatefulWidget {
  const _ViewTab({
    required this.surfaceId,
    required this.index,
    required this.tabCount,
    required this.title,
    required this.active,
    required this.pinned,
    required this.pinnable,
    required this.iconOnly,
    required this.style,
    required this.onTap,
    this.onClose,
    this.onTogglePin,
    this.onReorder,
    this.icon,
    this.leading,
    super.key,
  });

  final String surfaceId;
  final String title;

  /// This tab's position in the bar (the drag's `from`).
  final int index;

  /// The bar's size (the drag's clamp).
  final int tabCount;
  final bool active;

  /// Whether the view is pinned (the glyph's fill).
  final bool pinned;

  /// Whether the tab carries the pin affordance at all (static views).
  final bool pinnable;

  /// Safari compression: the icon-only identity pill.
  final bool iconOnly;
  final TextStyle style;
  final VoidCallback onTap;

  /// Closes the tab; null when no close affordance is offered (the
  /// lone picker tab).
  final VoidCallback? onClose;

  /// Toggles the pin; null when the view is not pin-able.
  final VoidCallback? onTogglePin;

  /// Repositions this tab, as [ViewLayout.move] arguments; null
  /// disables drag reorder.
  final void Function(int from, int to)? onReorder;
  final IconData? icon;
  final Widget? leading;

  @override
  State<_ViewTab> createState() => _ViewTabState();
}

final class _ViewTabState extends State<_ViewTab> {
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
    if (widget.iconOnly) {
      // The compressed identity pill: leading/icon only, tooltip with
      // the honest title. No title, no pin, no ✕ (middle-click still
      // closes).
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Listener(
          onPointerDown: (final event) {
            if (event.buttons == kMiddleMouseButton) widget.onClose?.call();
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Tooltip(
              message: widget.title,
              child: Container(
                width: _kIconOnlyTabWidth,
                height: ShellTokens.tabHeight,
                margin: const EdgeInsets.symmetric(vertical: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.active ? context.shellSelected : null,
                  borderRadius: BorderRadius.circular(ShellTokens.radius),
                ),
                child: _identityMark(color),
              ),
            ),
          ),
        ),
      );
    }
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
            padding: const EdgeInsets.symmetric(
              horizontal: _kTabHorizontalPadding,
            ),
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
                  const SizedBox(width: _kGlyphGap),
                ] else ...[
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: _kIconSize, color: color),
                    const SizedBox(width: _kGlyphGap),
                  ],
                ],
                Text(
                  widget.title,
                  style: widget.style.copyWith(
                    color: color,
                    fontWeight: widget.active
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (widget.onTogglePin != null) ...[
                  const SizedBox(width: _kGlyphGap),
                  GestureDetector(
                    key: ValueKey('pane.tab.pin.${widget.surfaceId}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTogglePin,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: widget.pinned
                            ? context.l10n.viewUnpinTooltip
                            : context.l10n.viewPinTooltip,
                        child: Icon(
                          widget.pinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          size: _kPinSize,
                          color: widget.pinned
                              ? theme.colorScheme.primary
                              : context.shellMuted.withValues(
                                  alpha: emphasized ? 0.9 : 0.55,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (widget.onClose != null) ...[
                  const SizedBox(width: _kGlyphGap),
                  GestureDetector(
                    key: ValueKey('pane.tab.close.${widget.surfaceId}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onClose,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        Icons.close,
                        size: _kCloseSize,
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

  /// The tab's identity mark: the explicit leading (an avatar), else
  /// the registry icon.
  Widget _identityMark(final Color color) {
    final leading = widget.leading;
    if (leading != null) return leading;
    return Icon(
      widget.icon ?? Icons.crop_square,
      size: _kIconSize,
      color: color,
    );
  }
}

/// The shell's view scope: the layout state, the surface registry and
/// the change callback, inherited by the `/home` route body (and by
/// the new-tab picker, which navigates through it).
class ViewScope extends InheritedWidget {
  const ViewScope({
    required this.layout,
    required this.surfaces,
    required this.onChanged,
    required super.child,
    super.key,
  });

  final ViewLayout layout;
  final SurfaceRegistry surfaces;
  final ValueChanged<ViewLayout> onChanged;

  static ViewScope? of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ViewScope>();

  @override
  bool updateShouldNotify(final ViewScope oldWidget) =>
      oldWidget.layout != layout || !identical(oldWidget.surfaces, surfaces);
}

/// WAVE 4T — the new-tab picker (Zed's New Tab, the browser model): a
/// quiet menu of destinations, not decorative cards. Each entry carries
/// a small icon tile, the surface's name and a one-line hint; tapping
/// one replaces THIS tab in place ([ViewLayout.pick]). Structure law:
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
      kFilesystemSurfaceId => l10n.newTabHintFilesystem,
      kPeopleSurfaceId => l10n.newTabHintPeople,
      _ => null,
    };
  }

  @override
  Widget build(final BuildContext context) {
    final scope = ViewScope.of(context);
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
                          scope.onChanged(scope.layout.pick(spec.id)),
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
