/// DESIGN.md v2, cut to the bone (owner law 2026-11-10, the chat-first
/// projection; amended by ADR 0032 — automations earned the fourth
/// slot the same way models earned its surface: a distinct top-level
/// mode, never a settings row): the action bar is FOUR buttons —
/// `rail.search` (the ⌘K palette), `rail.actors` (toggles the docked
/// ROOMS COLUMN and wears the total-unread badge), `rail.automations`
/// (the device's declared automations — run-state is not a preference)
/// and `rail.settings` (the gear). The nine kind buttons retired with
/// their cycling law: views open from the strip's + picker and the
/// palette, and room navigation lives in the rooms column — which is
/// chrome like VSCode's sidebar, never a tab and never a surface (the
/// tabs+views law, shell.views.v4).
///
/// Widget keys are the agent's UI contract (DESIGN §6), kept on the
/// rail's grammar: `rail.search`, `rail.actors`, `rail.automations`,
/// `rail.settings`, `rail.unread.actors`. Lights gutter law v2 (Wave
/// D): the rail is ALWAYS the window's leftmost chrome, so on macOS it
/// ALWAYS owns the traffic-light gutter (`rail.lightsGutter`) — docked
/// or not; the rooms column's head and the strips' heads are
/// gutter-free.
library;

import 'package:ecsly_flutter/ecsly_flutter.dart';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/ecs_world/world.dart';

import 'package:lastanswer/ui_shell/shell_layout.dart';

import 'package:lastanswer/ui_shell/shell_theme.dart';

import 'package:lastanswer/ui_shell/surfaces.dart';

import 'package:lastanswer/ui_shell/window_drag.dart';

/// The shell's left edge: search first, the actors (rooms-column)
/// toggle beside it, automations and the settings gear last (the cut
/// bar's anatomy, ADR 0032's fourth button).
final class ActionBar extends StatelessWidget {
  const ActionBar({
    required this.layout,
    required this.actorsDocked,
    required this.onToggleActors,
    required this.onOpenAutomations,
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
  final VoidCallback onOpenAutomations;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPalette;

  @override
  Widget build(final BuildContext context) {
    final kind = kindOfSurfaceId(layout.activeSurfaceId);
    final automationsActive = kind == kAutomationsSurfaceId;
    final settingsActive = kind == kSettingsSurfaceId;
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
          // The lights gutter law v2 (owner law 2026-11-10, Wave D): the
          // rail is ALWAYS the window's leftmost chrome — docked or not
          // — so on macOS the rail ALWAYS owns the traffic lights: an
          // inert, draggable gutter at its head, never interactive
          // chrome. Off macOS the quiet 8px head stays.
            if (defaultTargetPlatform == TargetPlatform.macOS)
              const WindowDragRegion(
                child: SizedBox(
                  key: ValueKey('rail.lightsGutter'),
                  height: ShellTokens.stripHeight,
                  width: double.infinity,
                ),
            )
          else
            const SizedBox(height: 8),
          _BarButton(
            key: const ValueKey('rail.search'),
            semanticsLabel: 'rail.search',
            tooltip: context.l10n.railSearchHint,
            icon: Icons.search_outlined,
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
            key: const ValueKey('rail.automations'),
            semanticsLabel: 'rail.automations',
            tooltip: context.l10n.railAutomations,
            icon: Icons.bolt_outlined,
            active: automationsActive,
            onTap: onOpenAutomations,
          ),
          const SizedBox(height: 8),
          _BarButton(
            key: const ValueKey('rail.settings'),
            semanticsLabel: 'rail.settings',
            tooltip: context.l10n.settings,
            icon: Icons.settings_outlined,
            active: settingsActive,
            onTap: onOpenSettings,
          ),
          const SizedBox(height: 8),
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
              style: context.laUi.micro.copyWith(
                color: context.laUi.onAccent,
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

/// The one bar button shape: 40px rounded square, 18px outline icon,
/// the active pip hanging at the bar's left edge, the optional badge at
/// the bottom-right corner. Flat at rest (shadcn discipline): the hover
/// fill is [ShellColors.shellHover], the selected fill
/// [ShellColors.shellSelected] — the resting button carries no tint.
/// Semantics: a named button — the label IS the widget key (the §2.3
/// contract), the human word rides the hint.
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
      child: LaTooltip(
        message: widget.tooltip,
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
                      color: context.laUi.ink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              // Wave K: flat at rest — hover/selected fills come from
              // LaPressable's ONE state layer (never hand-rolled); the
              // 14→12 radius settle (the Discord squircle grammar) rides
              // a bounded TweenAnimationBuilder on the kit's motion budget.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  end: lit
                      ? ShellTokens.actionButtonRadiusActive
                      : ShellTokens.actionButtonRadius,
                ),
                duration: context.laUi.motionFast,
                curve: Curves.easeOut,
                builder:
                    (final context, final radius, _) =>
                        LaPressable.builder(
                          onTap: widget.onTap,
                          selected: widget.active,
                          radius: BorderRadius.circular(radius),
                          // The outer Semantics already carries the §2.3
                          // contract (button + selected + label + hint) —
                          // frozen; the pressable stays a pure state and
                          // gesture carrier.
                          semanticsButton: false,
                          onHoverChange: (final value) {
                            if (value != _hovering) {
                              setState(() => _hovering = value);
                            }
                          },
                          childBuilder: (final context, final state) {
                            final innerLit = widget.active || state.hovered;
                            return SizedBox(
                              width: ShellTokens.actionButtonSize,
                              height: ShellTokens.actionButtonSize,
                              child: Icon(
                                widget.icon,
                                size: 18,
                                color: innerLit
                                    ? context.laUi.ink
                                    : context.shellMuted,
                              ),
                            );
                          },
                        ),
              ),
              if (widget.badge != null)
                Positioned(right: 2, bottom: 0, child: widget.badge!),
            ],
          ),
        ),
      ),
    );
  }
}
