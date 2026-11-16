import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'package:la_ui/src/chrome.dart';
import 'package:la_ui/src/icons.dart';
import 'package:la_ui/src/motion.dart';
import 'package:la_ui/src/pressable.dart';
import 'package:la_ui/src/theme.dart';

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
    this.label,
    this.child,
    this.icon,
    this.trailing,
    this.onPressed,
    this.destructive = false,
    this.checked = false,
    this.enabled = true,
    this.shortcutHint,
  });

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
              return _MenuRow(item: entry, focusNode: node);
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, this.focusNode});

  final LaMenuItem item;
  final FocusNode? focusNode;

  @override
  Widget build(final BuildContext context) {
    final theme = context.laUi;
    final fg = !item.enabled
        ? theme.inkQuiet
        : item.destructive
        ? theme.danger
        : theme.ink;
    return LaPressable(
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

  List<LaMenuEntry> get _wrapped {
    if (!widget.closeOnActivate) {
      return widget.entries;
    }
    return [
      for (final entry in widget.entries)
        if (entry is LaMenuItem)
          LaMenuItem(
            label: entry.label,
            child: entry.child,
            icon: entry.icon,
            trailing: entry.trailing,
            destructive: entry.destructive,
            checked: entry.checked,
            enabled: entry.enabled,
            shortcutHint: entry.shortcutHint,
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
  }

  @override
  Widget build(final BuildContext context) {
    final targetX = widget.alignRight ? 1.0 : -1.0;
    final trigger =
        widget.childBuilder?.call(context, this) ??
        widget.child ??
        const SizedBox.shrink();
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

/// Imperative context menu at a global position (right-click clusters,
/// long-press sheets on touch). Rides the root overlay — works above any
/// route, no Portal ancestor needed.
Future<void> showLaMenuAt(
  final BuildContext context, {
  required final Offset globalPosition,
  required final List<LaMenuEntry> entries,
  final double minWidth = 180,
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    return;
  }
  final theme = LaUiTheme.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _PositionedMenu(
      position: globalPosition,
      entries: entries,
      minWidth: minWidth,
      theme: theme,
      close: () {
        if (entry.mounted) {
          entry.remove();
        }
      },
    ),
  );
  overlay.insert(entry);
}

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Rough height estimate for edge flipping (32 px rows + chrome).
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
            left: openLeft ? null : widget.position.dx,
            right: openLeft ? size.width - widget.position.dx : null,
            top: top.clamp(8.0, size.height - 40),
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: laMotion(context, widget.theme.motionFast),
              child: LaMenu(
                entries: widget.entries,
                minWidth: widget.minWidth,
                onEscape: widget.close,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
