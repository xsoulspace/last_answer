/// Models refactor (2026-11-14) — the OBSERVE lens: LA's differentiator
/// (no prior-art tool has any of it). Three blocks over the daemon's
/// own truth:
/// * the daemon card (live/pid/path, scheduler, arm/restart/stop) — the
///   process verbs live HERE, not in the catalog's chrome;
/// * the health ledger: one row per cast with the daemon's verdict
///   rendered VERBATIM (status · code · detail · at) — the ADR 0135
///   cooldowns and named skips are visible at last, never merged away;
/// * the dispatch ledger keyed by MODEL: telemetry rows join the actor
///   to its durable `brainCast`, so "which model is failing / what is
///   its cache-hit rate" is a read, not a mental join. An unbound
///   actor groups under an honest `unbound` header.
library;

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/models_widgets.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/status_edge.dart' show HealthDot, healthColor;

final class ObserveLens extends StatelessWidget {
  const ObserveLens({
    required this.world,
    required this.compact,
    this.service,
    super.key,
  });

  final WorldStateService world;
  final bool compact;
  final RealmChatService? service;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return ListView(
      key: const ValueKey('models.observe'),
      padding: EdgeInsets.zero,
      children: [
        _daemonCard(context),
        const SizedBox(height: 14),
        Text(
          context.l10n.modelsHealthSection,
          style: shellSectionLabel(context),
        ),
        const SizedBox(height: 6),
        Container(
          key: const ValueKey('models.health'),
          decoration: BoxDecoration(
            color: context.shellRaised,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (world.rungs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(context.l10n.modelsNoPalette),
                ),
              for (final rung in world.rungs)
                Container(
                  key: ValueKey('models.health.${rung.id}'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: la.rule, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      HealthDot(status: rung.healthStatus, size: 8),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              rung.id,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              [
                                rung.healthStatus,
                                ?rung.health?.code,
                                ?rung.health?.detail,
                                if (!compact)
                                ?rung.health?.at,
                              ].join(' · '),
                              style: LaTokens.mono(
                                10,
                                healthColor(la, rung.healthStatus),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.modelsLedgerSection,
          style: shellSectionLabel(context),
        ),
        const SizedBox(height: 6),
        ..._ledger(context),
      ],
    );
  }

  /// The daemon card: facts + the process verb cluster (moved here
  /// from the old header chrome — observe/stop controls, not catalog
  /// chrome). The cluster scales as a whole in a narrow split.
  Widget _daemonCard(final BuildContext context) {
    final la = context.la;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      key: const ValueKey('models.daemonCard'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.shellRaised,
        borderRadius: BorderRadius.circular(ShellTokens.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  world.daemonLive
                      ? world.daemonPid == null
                            ? l10n.modelsDaemonLive
                            : '${l10n.modelsDaemonLive} · '
                                  'pid ${world.daemonPid}'
                      : l10n.modelsDaemonDown,
                  key: const ValueKey('models.daemon'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: world.daemonLive ? null : la.caution,
                  ),
                ),
                if (world.paletteConfigPath case final path?)
                  Text(path, style: LaTokens.mono(10, la.inkQuiet)),
                Text(
                  world.schedulerLive
                      ? world.schedulerPid == null
                            ? l10n.modelsSchedulerLive
                            : '${l10n.modelsSchedulerLive} · '
                                  'pid ${world.schedulerPid}'
                      : l10n.modelsSchedulerDown,
                  key: const ValueKey('models.scheduler'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: world.schedulerLive ? la.inkQuiet : la.caution,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            // A split group can be arbitrarily narrow: the daemon's
            // verb cluster scales down as a whole instead of
            // overflowing (a RenderFlex overflow is an error, never a
            // layout).
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!world.daemonLive)
                    ModelsButton(
                      keyName: 'models.arm',
                      label: world.armState == WorldArmState.arming
                          ? l10n.edgeArming
                          : l10n.edgeArmWorld,
                      busy: world.armState == WorldArmState.arming,
                      onTap: () => unawaited(world.armWorld()),
                    )
                  else ...[
                    ModelsButton(
                      keyName: 'models.restart',
                      label: l10n.edgeRestartWorld,
                      onTap: () => unawaited(world.restartWorld()),
                    ),
                    const SizedBox(width: 6),
                    ModelsButton(
                      keyName: 'models.stop',
                      label: l10n.edgeStopWorld,
                      onTap: () => unawaited(world.stopWorld()),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The dispatch ledger, grouped by the model the actor is bound to
  /// (the durable `brainCast`), newest first inside each group.
  List<Widget> _ledger(final BuildContext context) {
    final la = context.la;
    final casts = service?.brainCasts ?? const <String, String>{};
    final groups = <String, List<ActorTelemetry>>{};
    for (final telemetry in world.telemetryByActor.values) {
      final key = casts[telemetry.actorId] ?? 'unbound';
      groups.putIfAbsent(key, () => <ActorTelemetry>[]).add(telemetry);
    }
    for (final rows in groups.values) {
      rows.sort((final a, final b) => (b.at ?? '').compareTo(a.at ?? ''));
    }
    final keys = groups.keys.toList()
      ..sort(
        (final a, final b) => a == 'unbound'
            ? 1
            : b == 'unbound'
            ? -1
            : a.compareTo(b),
      );
    if (keys.isEmpty) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            context.l10n.modelsTelemetry,
            style: LaTokens.mono(10, la.inkQuiet),
          ),
        ),
      ];
    }
    return <Widget>[
      for (final key in keys) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            key == 'unbound' ? context.l10n.modelsUnbound : key,
            key: ValueKey('models.ledger.$key'),
            style: LaTokens.mono(11, la.inkMuted),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.shellRaised,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              for (final row in groups[key]!.take(8))
                Container(
                  key: ValueKey('models.ledger.$key.${row.actorId}'),
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: la.rule, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.actorId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LaTokens.mono(11, la.inkMuted),
                        ),
                      ),
                      Text(
                        '${row.rounds}r',
                        style: LaTokens.mono(10, la.inkQuiet),
                      ),
                      if (row.cacheHitRate case final hit?) ...[
                        const SizedBox(width: 8),
                        Text(
                          'cache ${(hit * 100).round()}%',
                          style: LaTokens.mono(10, la.inkQuiet),
                        ),
                      ],
                      if (row.stalled)
                        ModelsChip(label: 'stalled', color: la.caution),
                      if (!compact)
                      if (row.at case final at?) ...[
                        const SizedBox(width: 8),
                        Text(at, style: LaTokens.mono(9, la.inkQuiet)),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ];
  }
}
