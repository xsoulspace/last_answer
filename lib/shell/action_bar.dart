/// DESIGN.md v2, cut to the bone (owner law 2026-11-10, the chat-first
/// projection): the action bar is THREE buttons — `rail.search` (the
/// ⌘K palette), `rail.actors` (toggles the docked ROOMS COLUMN and
/// wears the total-unread badge) and `rail.settings` (the gear). The
/// nine kind buttons retired with their cycling law: views open from
/// the strip's + picker and the palette, and room navigation lives in
/// the rooms column — which is chrome like VSCode's sidebar, never a
/// tab and never a surface (the tabs+views law, shell.views.v4).
///
/// Widget keys are the agent's UI contract (DESIGN §6), kept on the
/// rail's grammar: `rail.search`, `rail.actors`, `rail.settings`,
/// `rail.unread.actors`.
library;

import 'package:ecsly_flutter/ecsly_flutter.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/la_world/la_world.dart';

import 'package:lastanswer/shell/shell_layout.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/surfaces.dart';

/// The shell's left edge: search first, the actors (rooms-column)
/// toggle beside it, the settings gear last (the cut bar's anatomy).
final class ActionBar extends StatelessWidget {
  const ActionBar({
    required this.layout,
    required this.actorsDocked,
    required this.onToggleActors,
    required this.onOpenSettings,
    required this.onOpenPalette,
    super.key,
  });

  /// The live layout — the settings button's active pip follows the
  /// focused tab, exactly as the retired kind buttons' did.
  final ShellLayout layout;

  /// Whether the rooms column is docked (the actors toggle's selected
  /// state — the projection fact, never a guess).
  final bool actorsDocked;

  final VoidCallback onToggleActors;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPalette;

  @override
  Widget build(final BuildContext context) {
    final settingsActive =
        kindOfSurfaceId(layout.activeSurfaceId) == kSettingsSurfaceId;
    return Container(
      key: const ValueKey('shell.actionBar'),
      width: ShellTokens.actionBarWidth,
      decoration: BoxDecoration(
        color: context.la.surface,
        border: Border(
          right: BorderSide(
            color: context.shellHairline,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _BarButton(
            key: const ValueKey('rail.search'),
            semanticsLabel: 'rail.search',
            tooltip: context.l10n.railSearchHint,
            icon: Icons.search,
            active: false,
            onTap: onOpenPalette,
          ),
          const SizedBox(height: 8),
          _BarButton(
            key: const ValueKey('rail.actors'),
            semanticsLabel: 'rail.actors',
            tooltip: context.l10n.railActors,
            icon: Icons.forum_outlined,
            // Selected WHILE docked: the button states the projection,
            // it never lies about a column that is not there.
            active: actorsDocked,
            onTap: onToggleActors,
            badge: const _TotalUnreadBadge(),
          ),
          const Spacer(),
          _BarButton(
            key: const ValueKey('rail.settings'),
            semanticsLabel: 'rail.settings',
            tooltip: context.l10n.settings,
            icon: Icons.settings_outlined,
            active: settingsActive,
            onTap: onOpenSettings,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// The actors button's unread total (1g law, carried over from the
/// retired conversations kind button): a compact status token (the one
/// place DESIGN.md allows a pill) fed by an [EcsWorldSelector] over the
/// journal projection — the count arrives reactively from the cursor
/// fold, never from a poll. The member gate lives in
/// [LaWorld.unreadByThread]; the open room's own count falls away
/// through its receipt. No LaWorld yet = honest absence, no badge.
final class _TotalUnreadBadge extends StatelessWidget {
  const _TotalUnreadBadge();

  @override
  Widget build(final BuildContext context) {
    final laWorld = context.read<LaWorld?>();
    if (laWorld == null) return const SizedBox.shrink();
    return EcsWorldSelector<int>(
      world: laWorld.world,
      controller: laWorld.controller,
      select: (final world) {
        var total = 0;
        for (final count in laWorld.unreadByThread().values) {
          total += count;
        }
        return total;
      },
      builder: (final context, final unread) {
        if (unread <= 0) return const SizedBox.shrink();
        final label = unread > 99 ? '99+' : '$unread';
        return Semantics(
          key: const ValueKey('rail.unread.actors'),
          label: 'rail.unread.actors',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: context.la.accent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.la.surface, width: 1.5),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.la.onAccent,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The one bar button shape: 40px rounded square, tinted fill, 18px
/// outline icon, the active pip hanging at the bar's left edge, the
/// optional badge at the bottom-right corner. Semantics: a named
/// button — the label IS the widget key (the §2.3 contract), the human
/// word rides the hint.
final class _BarButton extends StatefulWidget {
  const _BarButton({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.semanticsLabel,
    required this.tooltip,
    this.badge,
    super.key,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String semanticsLabel;
  final String tooltip;
  final Widget? badge;

  @override
  State<_BarButton> createState() => _BarButtonState();
}

final class _BarButtonState extends State<_BarButton> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final lit = widget.active || _hovering;
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.semanticsLabel,
      hint: widget.tooltip,
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: const Duration(milliseconds: 600),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (final _) => setState(() => _hovering = true),
          onExit: (final _) => setState(() => _hovering = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: SizedBox(
              width: ShellTokens.actionBarWidth,
              height: ShellTokens.actionButtonSize + 8,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // The active pip (Discord): a quiet ink bar at the
                  // bar's left edge — shape, never color alone.
                  if (widget.active)
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 3,
                        height: 20,
                        decoration: BoxDecoration(
                          color: context.la.ink,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    width: ShellTokens.actionButtonSize,
                    height: ShellTokens.actionButtonSize,
                    decoration: BoxDecoration(
                      color: lit ? context.shellSelected : context.shellHover,
                      borderRadius: BorderRadius.circular(
                        lit
                            ? ShellTokens.actionButtonRadiusActive
                            : ShellTokens.actionButtonRadius,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: lit ? context.la.ink : context.shellMuted,
                    ),
                  ),
                  if (widget.badge != null)
                    Positioned(right: 2, bottom: 0, child: widget.badge!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
