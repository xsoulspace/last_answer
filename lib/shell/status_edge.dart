/// Phase 1d — the status edge (docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md §2.1, DESIGN §30): ONE
/// honest line at the window bottom — mesh · backend · daemon ·
/// attention — the operator's ambient awareness and the landing
/// surface's seed. Every segment is source-honest (the doctor truth,
/// the discovered palette, the session registry) and clickable into the
/// surface that owns the fact: backend → Models tab, attention → the
/// landing inbox, a dead daemon → the ONE-click arm (G2 + G1: the arm
/// converges the WHOLE world — daemon AND realm scheduler — through
/// the supervised `startSupervisedWorld` seam).
library;


import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/creatures.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:lastanswer/ui/creature_mark.dart';

/// The edge's height — one compact line, quieter than a tab strip.
const double kStatusEdgeHeight = 26;

/// The color of a palette-health status word (the one mapping the shell
/// uses: edge dot, Models rows, inbox chips).
Color healthColor(final LaPalette palette, final String status) =>
    switch (status) {
      'ok' => palette.accent,
      'failed' => palette.danger,
      'not_downloaded' || 'downloading' || 'loading' => palette.caution,
      _ => palette.inkQuiet,
    };

/// One health dot: a 7px disc, the status word's color.
final class HealthDot extends StatelessWidget {
  const HealthDot({required this.status, this.size = 7, super.key});

  final String status;
  final double size;

  @override
  Widget build(final BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: healthColor(context.la, status),
      shape: BoxShape.circle,
    ),
  );
}

/// The window-bottom status line.
final class StatusEdge extends StatelessWidget {
  const StatusEdge({
    required this.world,
    required this.onOpenModels,
    required this.onOpenInbox,
    super.key,
  });

  final WorldStateService world;

  /// Opens the Models surface as a tab of the active view (the backend
  /// segment's click).
  final VoidCallback onOpenModels;

  /// Shows the Conversations view whose landing state is the inbox (the
  /// attention segment's click).
  final VoidCallback onOpenInbox;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final la = context.la;
    final style = theme.textTheme.labelSmall?.copyWith(
      fontSize: 11,
      color: la.inkMuted,
    );
    final backends = context.read<StorageBackendsNotifier?>();
    return Container(
      key: const ValueKey('shell.statusEdge'),
      height: kStatusEdgeHeight,
      decoration: BoxDecoration(
        color: la.surface,
        border: Border(
          top: BorderSide(color: la.rule),
        ),
      ),
      child: ListenableBuilder(
        listenable: Listenable.merge([
          world,
          if (backends is Listenable) backends,
        ]),
        builder: (final context, final _) => DefaultTextStyle.merge(
          style: style,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            // ONE honest line — and it DEGRADES honestly (the owner's
            // half-screen desktop is a first-class width): the world
            // and backend segments ellipsize before anything drops;
            // the chosen-rung segment hides below [560]; the ambient
            // mesh segment below [720]; the attention segment keeps
            // its natural width (a waiting human decision is the
            // loudest fact the edge carries) and compacts below [560].
            child: LayoutBuilder(
              builder: (final context, final constraints) {
                final showMesh = constraints.maxWidth >= 720;
                final showVia =
                    constraints.maxWidth >= 560 && world.selectedRungId != null;
                return Row(
                  children: [
                    Flexible(
                      child: _WorldSegment(
                        world: world,
                        onOpenModels: onOpenModels,
                      ),
                    ),
                    _SegmentDivider(),
                    Flexible(
                      child: _BackendSegment(
                        world: world,
                        onOpenModels: onOpenModels,
                      ),
                    ),
                    if (showMesh) ...[
                      _SegmentDivider(),
                      _MeshSegment(backends: backends),
                    ],
                    const Spacer(),
                    if (showVia) ...[
                      Flexible(
                        child: _EdgeSegment(
                          keyName: 'edge.rung',
                          label: viaLabel(context, world.selectedRungId!),
                          onTap: onOpenModels,
                        ),
                      ),
                      _SegmentDivider(),
                    ],
                    _AttentionSegment(
                      world: world,
                      onOpenInbox: onOpenInbox,
                      compact: constraints.maxWidth < 560,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The chosen delegation rung's segment label.
  static String viaLabel(final BuildContext context, final String rung) =>
      context.l10n.statusEdgeVia(rung);
}

/// The daemon segment: live / down / arming / arm-failed, with the
/// ONE-click arm when the world is down (G2's acceptance: a click
/// converges a dead daemon to live, findings render, never a spinner
/// without an end).
final class _WorldSegment extends StatelessWidget {
  const _WorldSegment({required this.world, required this.onOpenModels});

  final WorldStateService world;
  final VoidCallback onOpenModels;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final l10n = context.l10n;
    if (world.armState == WorldArmState.arming) {
      return _EdgeSegment(
        keyName: 'edge.world',
        dotColor: la.caution,
        label: l10n.statusEdgeWorldArming,
        spinner: true,
        onTap: onOpenModels,
      );
    }
    if (world.armState == WorldArmState.error) {
      return _EdgeSegment(
        keyName: 'edge.world',
        dotColor: la.danger,
        label: l10n.statusEdgeArmFailed(world.armError ?? 'retry'),
        onTap: () {
          onOpenModels();
          unawaited(world.armWorld());
        },
      );
    }
    if (world.daemonLive) {
      return _EdgeSegment(
        keyName: 'edge.world',
        // 3d — the world creature: awake and calm while the daemon
        // lives, asleep while it is down (DESIGN v2: it sleeps ONLY
        // when the daemon is down). The label stays the state's word.
        leading: const CreatureMark(
          actorId: kWorldCreatureId,
          mood: CreatureMood.calm,
          size: 14,
        ),
        label: world.daemonBinaryStale == true
            ? l10n.statusEdgeWorldLiveStale
            : l10n.statusEdgeWorldLive,
        onTap: onOpenModels,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The label ellipsizes before the Arm button ever shrinks: the
        // action stays clickable at any width.
        Flexible(
          child: _EdgeSegment(
            keyName: 'edge.world',
            leading: const CreatureMark(
              actorId: kWorldCreatureId,
              mood: CreatureMood.asleep,
              size: 14,
            ),
            label: l10n.statusEdgeWorldDown,
            onTap: onOpenModels,
          ),
        ),
        const SizedBox(width: 6),
        _ArmButton(world: world),
      ],
    );
  }
}

/// The edge's one action button: arm the world (G2).
final class _ArmButton extends StatelessWidget {
  const _ArmButton({required this.world});

  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return Semantics(
      button: true,
      label: 'edge.arm',
      hint: context.l10n.edgeArmWorld,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: const ValueKey('edge.arm'),
          behavior: HitTestBehavior.opaque,
          onTap: () => unawaited(world.armWorld()),
          child: Container(
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              color: la.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                context.l10n.statusEdgeArm,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: la.accent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The backend segment: the declared primary rung with its health dot —
/// the degraded primary is visible BEFORE the send (G3).
final class _BackendSegment extends StatelessWidget {
  const _BackendSegment({required this.world, required this.onOpenModels});

  final WorldStateService world;
  final VoidCallback onOpenModels;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final primary = world.primaryRung;
    if (primary == null) {
      return _EdgeSegment(
        keyName: 'edge.backend',
        label: world.paletteAbsence != null
            ? l10n.statusEdgePaletteRefused
            : l10n.statusEdgeNoPalette,
        onTap: onOpenModels,
      );
    }
    return _EdgeSegment(
      keyName: 'edge.backend',
      dotColor: healthColor(context.la, primary.healthStatus),
      label: l10n.statusEdgePrimary(primary.id),
      tooltip: [
        if (primary.model != null) '${primary.provider ?? ''}/${primary.model}',
        if (primary.health?.code != null) '${primary.health!.code}',
        if (primary.health?.detail != null) '${primary.health!.detail}',
      ].join(' · '),
      onTap: onOpenModels,
    );
  }
}

/// The mesh segment: the app's own mesh role (separate plane from the
/// harness world — both named, neither guessed).
final class _MeshSegment extends StatelessWidget {
  const _MeshSegment({required this.backends});

  final StorageBackendsNotifier? backends;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final role = backends?.meshRole;
    final connected = backends?.meshService?.isConnected ?? false;
    final label = switch (role) {
      MeshRole.main => l10n.statusEdgeMeshMain,
      MeshRole.joined =>
        connected ? l10n.statusEdgeMeshJoined : l10n.statusEdgeMeshJoining,
      _ => l10n.statusEdgeMeshOff,
    };
    return _EdgeSegment(
      keyName: 'edge.mesh',
      dotColor: switch (role) {
        MeshRole.main => context.la.accent,
        MeshRole.joined => connected ? context.la.accent : context.la.caution,
        _ => context.la.inkQuiet,
      },
      label: label,
    );
  }
}

/// The attention segment: open permissions + running tasks (the inbox's
/// count). Danger-colored when a permission waits — a human decision is
/// the loudest fact the edge can carry.
final class _AttentionSegment extends StatelessWidget {
  const _AttentionSegment({
    required this.world,
    required this.onOpenInbox,
    this.compact = false,
  });

  final WorldStateService world;
  final VoidCallback onOpenInbox;

  /// Narrow windows keep the count-only label (the permissions split
  /// is the inbox's detail, not the edge's at that width).
  final bool compact;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final count = world.attentionCount;
    final waiting = world.permissions.isNotEmpty;
    return _EdgeSegment(
      keyName: 'edge.attention',
      dotColor: waiting
          ? context.la.danger
          : count > 0
          ? context.la.caution
          : null,
      label: waiting && !compact
          ? l10n.statusEdgeAttentionWaiting(
              world.permissions.length,
              world.runningTasks.length,
            )
          : l10n.statusEdgeAttention(count),
      onTap: onOpenInbox,
    );
  }
}

/// One edge segment: optional dot + label, optionally clickable. The
/// agent-facing identity is the inner [ValueKey] ([keyName]), never the
/// widget key.
final class _EdgeSegment extends StatelessWidget {
  const _EdgeSegment({
    required this.keyName,
    required this.label,
    this.leading,
    this.dotColor,
    this.tooltip,
    this.spinner = false,
    this.onTap,
  });

  final String keyName;
  final String label;

  /// 3d — an optional creature mark before the dot/label (the world
  /// segment's living state); the segment's contract key and Semantics
  /// stay exactly as they were.
  final Widget? leading;
  final Color? dotColor;
  final String? tooltip;
  final bool spinner;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    Widget segment = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading case final lead?) ...[
          lead,
          const SizedBox(width: 5),
        ],
        if (spinner)
          SizedBox(
            width: 9,
            height: 9,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: dotColor ?? context.la.inkQuiet,
            ),
          )
        else if (dotColor case final color?)
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        if (dotColor != null || spinner) const SizedBox(width: 5),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    if (tooltip != null && tooltip!.isNotEmpty) {
      segment = Tooltip(message: tooltip, child: segment);
    }
    // Phase 2 — the agent/screen-reader contract: the Semantics name
    // IS the widget key; the human words ride the hint.
    segment = Semantics(
      button: onTap != null,
      label: keyName,
      hint: label,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          key: ValueKey(keyName),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: segment,
        ),
      ),
    );
    return segment;
  }
}

/// The quiet `·` between segments.
final class _SegmentDivider extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text('·', style: TextStyle(color: context.la.inkQuiet)),
  );
}
