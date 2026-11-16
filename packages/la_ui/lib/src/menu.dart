import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'package:la_ui/src/chrome.dart';
import 'package:la_ui/src/icons.dart';
import 'package:la_ui/src/motion.dart';
import 'package:la_ui/src/pressable.dart';
import 'package:la_ui/src/theme.dart';
import 'package:la_ui/src/tooltip.dart';

/// One menu entry — items, separators, headers or custom content.
sealed class LaMenuEntry {
  /// Base for menu entries.
  const LaMenuEntry();
}

/// A tappable menu row: label, optional leading icon/trailing hint, checked
/// and destructive states.
class LaMenuItem extends LaMenuEntry {
  /// A menu action row (32 px metric).
  const LaMenuItem({
    this.key,
    this.label,
    this.child,
    this.icon,
    this.trailing,
    this.onPressed,
    this.destructive = false,
    this.checked = false,
    this.enabled = true,
    this.shortcutHint,
    this.tooltip,
  });

  /// Stable widget key for the rendered row — the frozen agent-UI contract
  /// (e.g. `worldchat.ctx.edit`) rides here; tests find the row via
  /// `find.byKey` and read `tester.widget<LaMenuRow>(...).item`.
  final Key? key;

  /// Row text (control style).
  final String? label;

  /// Custom row content.
  final Widget? child;

  /// Leading glyph (14 px box).
  final Widget? icon;

  /// Trailing widget (overrides [shortcutHint]/[checked] placement).
  final Widget? trailing;

  /// Activation; null disables.
  final VoidCallback? onPressed;

  /// Danger ink (delete rows).
  final bool destructive;

  /// Draws the check glyph (single/multi-select menus).
  final bool checked;

  /// False greys the row out.
  final bool enabled;

  /// Right-aligned micro key hint (⌘K style).
  final String? shortcutHint;

  /// Hover tooltip — the honest-DISABLED law (DESIGN v4 §6): a disabled
  /// row names the missing capability here instead of silently greying.
  final String? tooltip;
}

/// A hairline between menu groups.
class LaMenuSeparator extends LaMenuEntry {
  /// Separator.
  const LaMenuSeparator();
}

/// A quiet section label (micro, muted — the rooms-column grammar).
class LaMenuHeader extends LaMenuEntry {
  /// Section header.
  const LaMenuHeader(this.label);

  /// Header text.
  final String label;
}

/// Arbitrary content inside a menu (filter fields, color pickers).
class LaMenuCustom extends LaMenuEntry {
  /// Custom menu content.
  const LaMenuCustom(this.child);

  /// The content.
  final Widget child;
}

/// The menu popover content: floating overlay surface, hairline, the ONE
/// shadow, 32 px rows, arrow-key navigation, Escape to close. Rendered by
/// [LaMenuAnchor] (declarative) or [showLaMenuAt] (imperative).
class LaMenu extends StatefulWidget {
  /// A keyboard-navigable popover list.
  const LaMenu({
    required this.entries,
    this.minWidth = 180,
    this.maxWidth = 320,
    this.onEscape,
    this.width,
    super.key,
  });

  /// The entries.
  final List<LaMenuEntry> entries;

  /// Minimum menu width.
  final double minWidth;

  /// Maximum menu width.
  final double maxWidth;

  /// Escape handler (closes the host when provided).
  final VoidCallback? onEscape;

  /// Fixed width (overrides min/max growth).
  final double? width;

  @override
  State<LaMenu> createState() => _LaMenuState();
}

class _LaMenuState extends State<LaMenu> {
  final List<FocusNode> _itemNodes = [];
  int _focused = -1;

  @override
  void initState() {
    super.initState();
    _rebuildNodes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _itemNodes.isNotEmpty) {
        _focusItem(0);
      }
    });
  }

  @override
  void didUpdateWidget(final LaMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _rebuildNodes();
    }
  }

  void _rebuildNodes() {
    for (final node in _itemNodes) {
      node.dispose();
    }
    _itemNodes
      ..clear()
      ..addAll(List.generate(_itemCount, (_) => FocusNode()));
    _focused = -1;
  }

  int get _itemCount => widget.entries.whereType<LaMenuItem>().length;

  @override
  void dispose() {
    for (final node in _itemNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _focusItem(final int index) {
    if (index < 0 || index >= _itemNodes.length) {
      return;
    }
    _focused = index;
    _itemNodes[index].requestFocus();
  }

  KeyEventResult _onKey(final FocusNode node, final KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      widget.onEscape?.call();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _focusItem((_focused + 1) % _itemNodes.length);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _focusItem((_focused - 1 + _itemNodes.length) % _itemNodes.length);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _focusItem(0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _focusItem(_itemNodes.length - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    var itemIndex = -1;
    final children = <Widget>[
      const SizedBox(height: 4),
      for (final entry in widget.entries)
        switch (entry) {
          LaMenuItem() => Builder(
            builder: (context) {
              itemIndex++;
              final node = itemIndex < _itemNodes.length
                  ? _itemNodes[itemIndex]
                  : null;
              return LaMenuRow(item: entry, focusNode: node, key: entry.key);
            },
          ),
          LaMenuSeparator() => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: LaHairline(color: theme.rule),
          ),
          LaMenuHeader() => Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
            child: Text(entry.label, style: theme.micro),
          ),
          LaMenuCustom() => entry.child,
        },
      const SizedBox(height: 4),
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.minWidth,
        maxWidth: widget.width ?? widget.maxWidth,
      ),
      child: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: TapRegion(
          child: LaBox(
            color: theme.surfaceOverlay,
            radius: theme.floatingRadius,
            border: BorderSide(color: theme.rule),
            floating: true,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One rendered menu row. Public so tests and automation can find it by its
/// frozen key (`find.byKey(Key('worldchat.ctx.edit'))`) and read the entry
/// state via `tester.widget<LaMenuRow>(finder).item`.
class LaMenuRow extends StatelessWidget {
  /// Renders one [LaMenuItem] (32 px metric).
  const LaMenuRow({required this.item, this.focusNode, super.key});

  /// The entry this row renders.
  final LaMenuItem item;

  /// Focus node for the menu's arrow-key traversal.
  final FocusNode? focusNode;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final fg = !item.enabled
        ? theme.inkQuiet
        : item.destructive
        ? theme.danger
        : theme.ink;
    final row = LaPressable(
      onTap: item.enabled ? item.onPressed : null,
      enabled: item.enabled,
      focusNode: focusNode,
      radius: theme.smallRadius,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      scaleOnPress: false,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            SizedBox(
              width: 18,
              child: item.checked
                  ? LaCheck(color: fg)
                  : item.icon != null
                  ? IconTheme.merge(
                      data: IconThemeData(size: 14, color: fg),
                      child: item.icon!,
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Expanded(
              child:
                  item.child ??
                  Text(
                    item.label ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.control.copyWith(color: fg),
                  ),
            ),
            if (item.trailing != null)
              item.trailing!
            else if (item.shortcutHint != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  item.shortcutHint!,
                  style: theme.micro.copyWith(color: theme.inkQuiet),
                ),
              ),
          ],
        ),
      ),
    );
    if (item.tooltip == null) {
      return row;
    }
    return LaTooltip(message: item.tooltip!, child: row);
  }
}

/// Anchored menu (the declarative dropdown). Two wiring modes:
/// - shorthand [LaMenuAnchor.new] with [child]: pointer-down on the child
///   toggles the popover (native dropdown feel; the child needs no wiring);
/// - [LaMenuAnchor.builder]: the childBuilder receives the anchor state and
///   wires activation itself (keyboard-friendly triggers, e.g. LaSelect's).
class LaMenuAnchor extends StatefulWidget {
  /// A trigger widget with an anchored popover menu (pointer-down toggle).
  const LaMenuAnchor({
    required this.entries,
    required Widget this.child,
    this.dropUp = false,
    this.alignRight = false,
    this.minWidth = 180,
    this.enabled = true,
    this.onOpenChange,
    this.closeOnActivate = true,
    super.key,
  }) : childBuilder = null;

  /// Explicit-wiring variant: `childBuilder(context, anchorState)`.
  const LaMenuAnchor.builder({
    required this.entries,
    required this.childBuilder,
    this.dropUp = false,
    this.alignRight = false,
    this.minWidth = 180,
    this.enabled = true,
    this.onOpenChange,
    this.closeOnActivate = true,
    super.key,
  }) : child = null;

  /// Menu content.
  final List<LaMenuEntry> entries;

  /// The trigger (shorthand mode).
  final Widget? child;

  /// Explicit trigger builder (builder mode).
  final Widget Function(BuildContext context, LaMenuAnchorState anchor)?
  childBuilder;

  /// Open upward (bottom-anchored toolbars).
  final bool dropUp;

  /// Right-align the popover to the trigger.
  final bool alignRight;

  /// Minimum menu width.
  final double minWidth;

  /// False disables the toggle.
  final bool enabled;

  /// Open-state changes.
  final ValueChanged<bool>? onOpenChange;

  /// Close after an item activates (default shadcn behavior).
  final bool closeOnActivate;

  @override
  State<LaMenuAnchor> createState() => LaMenuAnchorState();
}

/// Public so hosts (composers, pickers) can close programmatically.
class LaMenuAnchorState extends State<LaMenuAnchor> {
  bool _open = false;

  /// Whether the popover is showing.
  bool get isOpen => _open;

  /// Open the popover.
  void open() {
    if (!laHasPortal(context)) {
      // Bare host (unit test, embed): no Portal theater to render into.
      return;
    }
    if (!_open && widget.enabled) {
      setState(() => _open = true);
      widget.onOpenChange?.call(true);
    }
  }

  /// Close the popover.
  void close() {
    if (_open) {
      setState(() => _open = false);
      widget.onOpenChange?.call(false);
    }
  }

  /// Toggle the popover.
  void toggle() => _open ? close() : open();

  List<LaMenuEntry> get _wrapped => widget.closeOnActivate
      ? wrapLaMenuEntriesCloseOnActivate(widget.entries, close)
      : widget.entries;

  @override
  Widget build(final BuildContext context) {
    final targetX = widget.alignRight ? 1.0 : -1.0;
    final trigger =
        widget.childBuilder?.call(context, this) ??
        widget.child ??
        const SizedBox.shrink();
    if (!laHasPortal(context)) {
      // Bare host (unit test, embed): no Portal theater to render the
      // popover into — serve the trigger alone instead of throwing
      // flutter_portal's PortalNotFoundError on every mount.
      return widget.childBuilder != null
          ? trigger
          : Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: widget.enabled ? (_) => toggle() : null,
              child: trigger,
            );
    }
    return PortalTarget(
      visible: _open,
      anchor: Aligned(
        follower: Alignment(targetX, widget.dropUp ? 1 : -1),
        target: Alignment(targetX, widget.dropUp ? -1 : 1),
      ),
      portalFollower: _open
          ? TapRegion(
              onTapOutside: (_) => close(),
              child: LaMenu(
                entries: _wrapped,
                minWidth: widget.minWidth,
                onEscape: close,
              ),
            )
          : null,
      child: widget.childBuilder != null
          ? trigger
          : Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: widget.enabled ? (_) => toggle() : null,
              child: trigger,
            ),
    );
  }
}

/// Handle for an imperatively opened menu: [close] dismisses it
/// programmatically, [closed] completes when it goes away for any reason
/// (activation, outside tap, Escape, barrier).
class LaMenuHandle {
  LaMenuHandle._(this._close, this.closed);

  final VoidCallback _close;

  /// Completes once when the menu is dismissed.
  final Future<void> closed;

  /// Dismiss the menu (idempotent).
  void close() => _close();
}

/// Imperative context menu at a global position (right-click clusters,
/// long-press sheets on touch). Rides the root overlay — works above any
/// route, no Portal ancestor needed. Items close the menu on activation
/// by default (shadcn grammar); the returned handle allows programmatic
/// dismissal and completion tracking.
LaMenuHandle? showLaMenuAt(
  final BuildContext context, {
  required final Offset globalPosition,
  required final List<LaMenuEntry> entries,
  final double minWidth = 180,
  final bool closeOnActivate = true,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    return null;
  }
  final theme = LaUiTheme.of(context);
  final completer = Completer<void>();
  var closed = false;
  late final OverlayEntry entry;
  void close() {
    if (closed) {
      return;
    }
    closed = true;
    if (entry.mounted) {
      entry.remove();
    }
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  final wrapped = closeOnActivate
      ? wrapLaMenuEntriesCloseOnActivate(entries, close)
      : entries;
  entry = OverlayEntry(
    builder: (context) => _PositionedMenu(
      position: globalPosition,
      entries: wrapped,
      minWidth: minWidth,
      theme: theme,
      close: close,
    ),
  );
  overlay.insert(entry);
  return LaMenuHandle._(close, completer.future);
}

/// Wraps every [LaMenuItem]'s onPressed so activation also runs [close] —
/// the shared close-on-activate grammar for anchored and imperative menus.
List<LaMenuEntry> wrapLaMenuEntriesCloseOnActivate(
  final List<LaMenuEntry> entries,
  final VoidCallback close,
) => [
  for (final entry in entries)
    if (entry is LaMenuItem)
      LaMenuItem(
        key: entry.key,
        label: entry.label,
        child: entry.child,
        icon: entry.icon,
        trailing: entry.trailing,
        destructive: entry.destructive,
        checked: entry.checked,
        enabled: entry.enabled,
        shortcutHint: entry.shortcutHint,
        tooltip: entry.tooltip,
        onPressed: entry.onPressed == null
            ? null
            : () {
                entry.onPressed!.call();
                close();
              },
      )
    else
      entry,
];

class _PositionedMenu extends StatefulWidget {
  const _PositionedMenu({
    required this.position,
    required this.entries,
    required this.minWidth,
    required this.theme,
    required this.close,
  });

  final Offset position;
  final List<LaMenuEntry> entries;
  final double minWidth;
  final LaUiTheme theme;
  final VoidCallback close;

  @override
  State<_PositionedMenu> createState() => _PositionedMenuState();
}

class _PositionedMenuState extends State<_PositionedMenu> {
  bool _visible = false;
  final GlobalKey _menuKey = GlobalKey();
  Offset _shift = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
      _correctToViewport();
    });
  }

  /// Post-frame measure-and-correct: the pre-layout flip only estimates
  /// size (rows wider than [LaMenu.minWidth] would paint off-screen), so
  /// once the real box exists, shift it back inside the viewport.
  void _correctToViewport() {
    final box = _menuKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return;
    }
    final screen = MediaQuery.maybeSizeOf(context);
    if (screen == null) {
      return;
    }
    final pos = box.localToGlobal(Offset.zero);
    var dx = 0.0;
    var dy = 0.0;
    final rightOverflow = pos.dx + box.size.width - (screen.width - 8);
    if (rightOverflow > 0) {
      dx = -rightOverflow;
    }
    if (pos.dx < 8) {
      dx = math.max(dx, 8 - pos.dx);
    }
    final bottomOverflow = pos.dy + box.size.height - (screen.height - 8);
    if (bottomOverflow > 0) {
      dy = -bottomOverflow;
    }
    if (pos.dy < 8) {
      dy = math.max(dy, 8 - pos.dy);
    }
    if (dx != 0 || dy != 0) {
      setState(() => _shift = Offset(dx, dy));
    }
  }

  @override
  Widget build(final BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Rough height estimate for edge flipping (32 px rows + chrome) —
    // refined by the post-frame correction above.
    final estimate = widget.entries.length * 34.0 + 16;
    final openUp = widget.position.dy + estimate > size.height - 8;
    final openLeft = widget.position.dx + widget.minWidth > size.width - 8;
    final top = openUp ? widget.position.dy - estimate : widget.position.dy;
    return LaUiThemeProvider(
      theme: widget.theme,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.close,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: openLeft ? null : widget.position.dx + _shift.dx,
            right: openLeft
                ? size.width - widget.position.dx - _shift.dx
                : null,
            top: (top + _shift.dy).clamp(8.0, size.height - 40),
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: laMotion(context, widget.theme.motionFast),
              child: KeyedSubtree(
                key: _menuKey,
                child: LaMenu(
                  entries: widget.entries,
                  minWidth: widget.minWidth,
                  onEscape: widget.close,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
