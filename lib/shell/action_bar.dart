/// DESIGN.md v2 — the rail, rethought as a Discord-style ACTION BAR:
/// "mostly unnecessary by design". Rounded-square kind icons with
/// unread badges and an active pip; ONE click opens the kind's first
/// tab, FURTHER clicks cycle its open tabs (fast navigation among
/// similar tabs). The persistent 216px room list is retired — opening
/// lives in the strip's + picker and the ⌘K palette; creation flows
/// live in the picker too.
///
/// Widget keys are the agent's UI contract (DESIGN §6), kept on the
/// rail's grammar: `rail.view.<kindId>` per kind button, `rail.search`
/// (the palette trigger), `rail.settings`, `rail.unread.<kindId>`.
library;

import 'package:ecsly_flutter/ecsly_flutter.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/la_world/la_world.dart';

import 'package:lastanswer/shell/shell_layout.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/surfaces.dart';

/// One action-bar kind: the registry face it opens and the tabs it
/// cycles ([kindOfSurfaceId] folds content ids into kinds).
final class ActionBarKind {
  const ActionBarKind({
    required this.id,
    required this.icon,
    required this.tooltip,
  });

  final String id;
  final IconData icon;
  final String tooltip;
}

/// The shell's left edge: kind buttons top-down, search first, the
/// settings gear last (the mockup's anatomy).
final class ActionBar extends StatelessWidget {
  const ActionBar({
    required this.layout,
    required this.kinds,
    required this.onKindTap,
    required this.onOpenSettings,
    required this.onOpenPalette,
    super.key,
  });

  final ShellLayout layout;
  final List<ActionBarKind> kinds;
  final ValueChanged<String> onKindTap;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPalette;

  @override
  Widget build(final BuildContext context) {
    final activeKind = kindOfSurfaceId(layout.activeSurfaceId);
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
          Expanded(
            // A ListView, not a SingleChildScrollView: the SCV's
            // semantics subtree never assembles in a live desktop app
            // (measured — the rail-drop framework gap); ListView-backed
            // lists keep their nodes, and the bar is the agent's kind
            // index.
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final kind in kinds)
                  _KindButton(
                    key: ValueKey('rail.view.${kind.id}'),
                    kind: kind,
                    active: kind.id == activeKind,
                    onTap: () => onKindTap(kind.id),
                  ),
              ],
            ),
          ),
          _BarButton(
            key: const ValueKey('rail.settings'),
            semanticsLabel: 'rail.settings',
            tooltip: context.l10n.settings,
            icon: Icons.settings_outlined,
            active: activeKind == 'settings',
            onTap: onOpenSettings,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// One kind button: the rounded square (14 → 12 radius on hover/active,
/// the Discord settle), the active pip at the bar's left edge, and —
/// for the conversations kind — the unread badge fed by LaWorld.
final class _KindButton extends StatelessWidget {
  const _KindButton({
    required this.kind,
    required this.active,
    required this.onTap,
    super.key,
  });

  final ActionBarKind kind;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: _BarButton(
      semanticsLabel: 'rail.view.${kind.id}',
      tooltip: kind.tooltip,
      icon: kind.icon,
      active: active,
      onTap: onTap,
      badge: kind.id == kConversationsSurfaceId
          ? const _KindUnreadBadge()
          : null,
    ),
  );
}

/// The conversations kind's unread total (1g law, kind level): a
/// compact status token (the one place DESIGN.md allows a pill) fed by
/// an [EcsWorldSelector] over the journal projection — the count
/// arrives reactively from the cursor fold, never from a poll. The
/// member gate lives in [LaWorld.unreadByThread]; the open room's own
/// count falls away through its receipt. No LaWorld yet = honest
/// absence, no badge.
final class _KindUnreadBadge extends StatelessWidget {
  const _KindUnreadBadge();

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
          key: const ValueKey('rail.unread.conversations'),
          label: 'rail.unread.conversations',
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
