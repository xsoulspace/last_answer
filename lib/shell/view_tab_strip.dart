/// Phase 1 — the per-view Safari-like tab strip (docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md §2.1): EVERY view owns one
/// of these above its content. Zero Material chrome (hover + gesture +
/// hairline, the de-Material law), Safari compression on overflow
/// (rightmost-first, the focused tab keeps its title), middle-click
/// close, and — phase 2's contract — a Semantics button per tab whose
/// label is its widget key, so screen readers and agents see the strip.
library;

import 'package:flutter/gestures.dart' show kMiddleMouseButton;
import 'package:flutter/material.dart';

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_layout.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/surfaces.dart';

/// One view's tab strip: its tabs, the `+` that opens the picker in THIS
/// view, and the quiet hairline under the row.
final class ViewTabStrip extends StatelessWidget {
  const ViewTabStrip({
    required this.viewId,
    required this.layout,
    required this.surfaces,
    required this.onSelect,
    required this.onClose,
    required this.onNewTab,
    this.titleFor,
    this.leadingFor,
    super.key,
  });

  /// The view whose strip this is.
  final String viewId;
  final ShellLayout layout;
  final SurfaceRegistry surfaces;

  /// A tab tap.
  final ValueChanged<String> onSelect;

  /// A tab's ✕ (or middle-click).
  final ValueChanged<String> onClose;

  /// The strip's `+` (and ⌘T): the picker as a tab of THIS view.
  final VoidCallback onNewTab;

  final String? Function(String surfaceId)? titleFor;
  final Widget? Function(String surfaceId)? leadingFor;

  String _titleOf(final String surfaceId) =>
      titleFor?.call(surfaceId) ?? surfaces[surfaceId]?.title ?? surfaceId;

  @override
  Widget build(final BuildContext context) {
    final tabs = layout.tabsOf(viewId);
    final activeId = layout.activeTabOf(viewId);
    return Container(
      key: ValueKey('view.strip.$viewId'),
      height: ShellTokens.tabHeight,
      decoration: BoxDecoration(
        color: context.la.surface,
        border: Border(
          bottom: BorderSide(
            color: context.shellHairline,
            width: ShellTokens.hairline,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (final context, final constraints) {
          // Safari compression: the strip's usable width minus the `+`;
          // full pills first, then compress rightmost-first until they
          // fit; the focused tab keeps its title longest.
          const addWidth = 35.0;
          const fullWidth = 168.0;
          const compactWidth = 36.0;
          final usable = constraints.maxWidth - addWidth;
          final fullCount = _fullCount(tabs.length, usable);
          final compressed = <String>{
            for (var i = tabs.length - 1; i >= fullCount; i--) tabs[i],
          }..remove(activeId);
          return Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: [
                      for (final id in tabs)
                        _StripTab(
                          key: ValueKey('view.tab.$id'),
                          surfaceId: id,
                          title: _titleOf(id),
                          leading:
                              leadingFor?.call(id) ??
                              (surfaces[id]?.icon != null
                                  ? Icon(
                                      surfaces[id]!.icon,
                                      size: 14,
                                      color: context.shellMuted,
                                    )
                                  : null),
                          focused: id == activeId,
                          compact: compressed.contains(id),
                          onTap: () => onSelect(id),
                          onClose: () => onClose(id),
                        ),
                    ],
                  ),
                ),
              ),
              _AddTabButton(
                key: ValueKey('view.strip.add.$viewId'),
                label: 'view.strip.add.$viewId',
                onTap: onNewTab,
              ),
              const SizedBox(width: 6),
            ],
          );
        },
      ),
    );
  }

  /// How many tabs keep their title at [usable] width when the rest
  /// compress (the focused tab is never counted as compressible).
  int _fullCount(final int tabCount, final double usable) {
    const fullWidth = 168.0;
    const compactWidth = 36.0;
    for (var full = tabCount; full >= 0; full--) {
      final width = full * fullWidth + (tabCount - full) * compactWidth;
      if (width <= usable) return full;
    }
    return 0;
  }
}

/// One tab pill: identity mark + title (+ ✕ on hover/focus), the focused
/// tab on the selected tint with a 2px accent underline. Semantics: a
/// named button — the agent/screen-reader contract (phase 2).
final class _StripTab extends StatefulWidget {
  const _StripTab({
    required this.surfaceId,
    required this.title,
    required this.focused,
    required this.compact,
    required this.onTap,
    required this.onClose,
    this.leading,
    super.key,
  });

  final String surfaceId;
  final String title;
  final bool focused;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onClose;
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
      // Phase 2 — the agent contract: the Semantics name IS the widget
      // key; the human title rides the hint.
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
            child: Container(
              height: ShellTokens.tabHeight,
              constraints: BoxConstraints(maxWidth: widget.compact ? 44 : 200),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.focused ? context.shellSelected : null,
                border: Border(
                  bottom: BorderSide(
                    color: widget.focused
                        ? theme.colorScheme.primary
                        : const Color(0x00000000),
                    width: 2,
                  ),
                ),
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
                          color: widget.focused
                              ? theme.colorScheme.onSurface
                              : context.shellMuted,
                          fontWeight: widget.focused
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  if (showClose) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      key: ValueKey('view.tab.close.${widget.surfaceId}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onClose,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Icon(
                          Icons.close,
                          size: 13,
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

/// The strip's `+`: opens the picker as a tab of THIS view.
final class _AddTabButton extends StatelessWidget {
  const _AddTabButton({required this.onTap, required this.label, super.key});

  final VoidCallback onTap;

  /// The Semantics name (the widget key — phase 2 contract).
  final String label;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: label,
    hint: 'new tab',
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 29,
          height: ShellTokens.tabHeight,
          child: Icon(Icons.add, size: 16, color: context.shellMuted),
        ),
      ),
    ),
  );
}
