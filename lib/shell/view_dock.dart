/// WAVE 5 — the DOCK: the right column repurposed as the pinned views'
/// home (docs/design/unified-views.md). The dock renders `pinned` from
/// the ONE [ViewLayout] — a vertical Safari-style pill strip (identity
/// mark + short title) above the focused pin's content (Notion peek:
/// one focused pinned view at a time — calmest at 240px).
///
/// The dock is a PRESENTATION, not a taxonomy: there is no second tab
/// enum here. A view may be pinned AND open as a tab (Notion: a page
/// in peek AND in a tab); unpinning removes the pin only.
///
/// The width gate governs FIT, never existence: below
/// [kContextColumnMinWindowWidth] the shell hides the dock (the pinned
/// state survives; the top bar's dock glyph focuses the first pinned
/// view full-width).
///
/// Widget keys are the agent's UI contract (DESIGN §6): `view.dock`
/// (the container), `view.dock.pill.<viewId>` (focus that pin),
/// `view.dock.unpin.<viewId>` (remove the pin), `view.dock.content.<id>`
/// (the focused pin's content host).
library;

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/center_tabs.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_layout.dart';

/// The shell's right column: the pinned views' pill strip + the
/// focused pin's content. Rebuilt per call from [layout] — the strip
/// is never a cached widget instance (the title-stuck bug law).
final class ViewDock extends StatelessWidget {
  const ViewDock({
    required this.layout,
    required this.surfaces,
    this.service,
    this.onFocusPin,
    this.onUnpin,
    this.titleFor,
    this.leadingFor,
    super.key,
  });

  /// The shell's layout (the dock reads `pinned` + `focusedDockId`).
  final ViewLayout layout;

  /// The ONE surface registry (specs, titles, icons).
  final SurfaceRegistry surfaces;

  /// The world conversation service — conversation pin titles ride its
  /// projections; the strip follows its notifications.
  final RealmChatService? service;

  /// Focuses a pin (a pill tap).
  final ValueChanged<String>? onFocusPin;

  /// Unpins a view (the pill's unpin glyph).
  final ValueChanged<String>? onUnpin;

  /// Human title for ids the registry does not know (conversation
  /// surface ids); null falls back to the registry title, then the id.
  final String? Function(String surfaceId)? titleFor;

  /// Identity widget for ids the registry has no leading for
  /// (conversation surface ids: the actor's avatar, the channel's
  /// disc); null falls back to the registry icon.
  final Widget? Function(String surfaceId)? leadingFor;

  String _titleOf(final String surfaceId) =>
      titleFor?.call(surfaceId) ??
      surfaces[surfaceId]?.title ??
      surfaceId;

  @override
  Widget build(final BuildContext context) {
    final focusedId = layout.focusedDockId;
    return DecoratedBox(
      key: const ValueKey('view.dock'),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: context.shellHairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The pill strip follows the service's notifications so
          // rail-driven title facts (roster, channels) land without a
          // layout change — and it is rebuilt per call (never a cached
          // instance).
          if (service == null)
            _pillStrip(context)
          else
            ListenableBuilder(
              listenable: service!,
              builder: (final context, final _) => _pillStrip(context),
            ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey('view.dock.content.$focusedId'),
              child: _content(context, focusedId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillStrip(final BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final id in layout.pinned)
          _DockPill(
            key: ValueKey('view.dock.pill.$id'),
            viewId: id,
            title: _titleOf(id),
            leading:
                surfaces[id]?.leading ??
                leadingFor?.call(id) ??
                (surfaces[id]?.icon != null
                    ? Icon(
                        surfaces[id]!.icon,
                        size: 14,
                        color: context.shellMuted,
                      )
                    : null),
            focused: id == layout.focusedDockId,
            onTap: onFocusPin == null ? null : () => onFocusPin!(id),
            onUnpin: onUnpin == null ? null : () => onUnpin!(id),
          ),
      ],
    ),
  );

  Widget _content(final BuildContext context, final String? focusedId) {
    if (focusedId == null) {
      // Unreachable behind the shell's gate (a non-empty pin list), but
      // honest if a caller renders the dock anyway.
      return const SizedBox.shrink();
    }
    final spec =
        surfaces[focusedId] ?? conversationSurfaceSpec(focusedId, surfaces);
    if (spec == null) return UnknownSurface(surfaceId: focusedId);
    // Built per call, never cached: a widget INSTANCE handed back from
    // a builder is treated as unchanged and its subtree never rebuilds.
    return Builder(builder: spec.builder);
  }
}

/// One dock pill: identity mark + short title on the shared selected
/// tint when focused; the unpin glyph shows on the focused pill and on
/// hover (Safari book bar anatomy).
final class _DockPill extends StatefulWidget {
  const _DockPill({
    required this.viewId,
    required this.title,
    required this.focused,
    this.leading,
    this.onTap,
    this.onUnpin,
    super.key,
  });

  final String viewId;
  final String title;
  final bool focused;
  final Widget? leading;
  final VoidCallback? onTap;
  final VoidCallback? onUnpin;

  @override
  State<_DockPill> createState() => _DockPillState();
}

final class _DockPillState extends State<_DockPill> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final showUnpin = widget.focused || _hovering;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: widget.focused
                ? context.shellSelected
                : _hovering
                ? context.shellHover
                : null,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 6),
              ],
              Expanded(
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
              if (showUnpin && widget.onUnpin != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  key: ValueKey('view.dock.unpin.${widget.viewId}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onUnpin,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message: context.l10n.viewUnpinTooltip,
                      child: Icon(
                        Icons.push_pin,
                        size: 12,
                        color: context.shellMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
