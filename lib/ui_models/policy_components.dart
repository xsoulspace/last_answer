/// Brain-policy components (stage C, 2026-11-16; the Observe-absorption
/// wave 2026-11-19) — the reusable atoms of the policy surface:
///
/// * [policySentenceFor] — the behavior sentence of a policy position
///   ("thinks first" / "if the previous model is down or stuck"). The
///   order IS the authoring; the sentence is how a zero-knowledge user
///   reads it.
/// * [EscalationNarration] — the chip that says what the world DID
///   ("stalled → tried Qwen3.8 Max Preview"), from the daemon's
///   flattened `escalatedFrom` telemetry tag (ADR 0122 promotion,
///   narrated).
/// * [groupTelemetryByCast] + [BrainHealthChip] / [BrainCacheChip] /
///   [BrainHistoryExpansion] — the Observe lens, dissolved into the
///   rows it describes (2026-11-19, the owner's merge law): health and
///   cache rate are chips on the model's row, the request history
///   opens UNDER the row that owns it.
///
/// Deliberately NOT taken here: an ecsly-selector read model for the
/// Models surface. The lenses already project WORLD TRUTH (the durable
/// realm store through `WorldStateService`); the ecsly selectors select
/// from the ECS world — mirroring realm rows into ECS components would
/// create a second source of truth (the ADR 0013 duplication class).
/// The migration becomes right only when the durable store and the ECS
/// world converge on one plane (design doc, stage C).
library;

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_journal/palette_lanes.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/ui_models/local_models_state.dart';
import 'package:lastanswer/ui_models/models_widgets.dart';
import 'package:lastanswer/ui_models/palette_candidate.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:lastanswer/ui_shell/status_edge.dart' show HealthDot, healthColor;
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// The behavior sentence of policy position [index] over the spoken
/// [labels] (labels[index] is THIS row's name; labels[index - 1] the
/// one it falls back FROM). Position 1 thinks first; every later row
/// names what happens when the previous model fails.
String policySentenceFor(
  final BuildContext context,
  final int index,
  final List<String> labels,
) => index == 0
    ? context.l10n.modelsPolicyFirst
    : context.l10n.modelsPolicyFallback(labels[index - 1]);

/// The dispatch telemetry grouped by the MODEL the actors serve (the
/// durable `brainCast` join, the old Observe ledger's grouping): newest
/// first inside each group, `unbound` sorted last. The cache chip and
/// the history expansion both read this one map.
Map<String, List<ActorTelemetry>> groupTelemetryByCast(
  final WorldStateService world,
  final RealmChatService? service,
) {
  final casts = service?.brainCasts ?? const <String, String>{};
  final groups = <String, List<ActorTelemetry>>{};
  for (final telemetry in world.telemetryByActor.values) {
    final key = casts[telemetry.actorId] ?? 'unbound';
    groups.putIfAbsent(key, () => <ActorTelemetry>[]).add(telemetry);
  }
  for (final rows in groups.values) {
    rows.sort((final a, final b) => (b.at ?? '').compareTo(a.at ?? ''));
  }
  return groups;
}

/// A compact age for a health timestamp (`2m`, `3h`, `5d`) — the chip
/// shows WHEN the daemon last spoke about this model without words.
String relativeAge(final String? isoAt, final DateTime now) {
  if (isoAt == null) return '';
  final at = DateTime.tryParse(isoAt);
  if (at == null) return '';
  final d = now.difference(at);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  return '${d.inDays}d';
}

/// The health chip on a brain row (the Observe health ledger, folded):
/// the dot is already on the row; the chip names the daemon's verdict
/// and how fresh it is. The verbatim code/detail/at render in the row's
/// [BrainHistoryExpansion] — the chip stays one glance wide.
final class BrainHealthChip extends StatelessWidget {
  const BrainHealthChip({
    required this.rung,
    required this.onToggle,
    this.open = false,
    super.key,
  });

  final WorldRung rung;

  /// Tapping the chip opens the row's history expansion (the verbatim
  /// health verdict lives IN there — the chip is its door).
  final VoidCallback onToggle;
  final bool open;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final status = rung.healthStatus;
    final age = relativeAge(rung.health?.at, DateTime.now());
    return Semantics(
      button: true,
      label: 'models.rung.${rung.id}.health',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: ModelsChip(
          key: ValueKey('models.rung.${rung.id}.health'),
          label: age.isEmpty ? status : '$status · $age',
          color: open ? la.accent : healthColor(la, status),
          mono: true,
        ),
      ),
    );
  }
}

/// The cache chip on a brain row (the Observe dispatch ledger, folded):
/// the model's request count + cache-hit rate at a glance; empty when
/// the world has no telemetry for it (silence — not a zero that lies).
/// Tapping opens the row's [BrainHistoryExpansion].
final class BrainCacheChip extends StatelessWidget {
  const BrainCacheChip({
    required this.castId,
    required this.rows,
    required this.open,
    required this.onToggle,
    super.key,
  });

  final String castId;
  final List<ActorTelemetry> rows;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(final BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    var rounds = 0;
    var weighted = 0.0;
    for (final row in rows) {
      rounds += row.rounds;
      final hit = row.cacheHitRate;
      if (hit != null) weighted += hit * row.rounds;
    }
    final hit = rounds > 0 ? weighted / rounds : null;
    return Semantics(
      button: true,
      label: 'models.rung.$castId.cache',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: ModelsChip(
          key: ValueKey('models.rung.$castId.cache'),
          label: hit == null
              ? '$rounds r'
              : 'cache ${(hit * 100).round()}% · $rounds r',
          color: open ? context.la.accent : context.la.inkQuiet,
          mono: true,
        ),
      ),
    );
  }
}

/// The expansion a brain row opens UNDER itself: the per-actor request
/// history (the old dispatch ledger's rows for this one model) plus the
/// health verdict VERBATIM (code · detail · at — the daemon's own
/// words, never merged away). Closed = nothing rendered.
final class BrainHistoryExpansion extends StatelessWidget {
  const BrainHistoryExpansion({
    required this.rung,
    required this.rows,
    required this.world,
    super.key,
  });

  final WorldRung rung;
  final List<ActorTelemetry> rows;
  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final health = [
      ?rung.health?.code,
      ?rung.health?.detail,
      ?rung.health?.at,
    ].join(' · ');
    return Container(
      key: ValueKey('models.rung.${rung.id}.history'),
      margin: const EdgeInsets.only(left: 24, bottom: 6),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: context.shellRaised,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (health.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                health,
                key: ValueKey('models.rung.${rung.id}.healthDetail'),
                style: LaTokens.mono(10, healthColor(la, rung.healthStatus)),
              ),
            ),
          if (rows.isEmpty)
            Text(
              context.l10n.modelsTelemetry,
              style: LaTokens.mono(10, la.inkQuiet),
            )
          else
            for (final row in rows.take(8))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
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
                    // The metadata cluster scales down as a whole (the
                    // daemon-cluster law) — the narration chip is the
                    // widest member and a narrow pane shrinks it instead
                    // of overflowing.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${row.rounds}r',
                              style: LaTokens.mono(10, la.inkQuiet),
                            ),
                            const SizedBox(width: 8),
                            if (row.cacheHitRate case final hit?)
                              Text(
                                'cache ${(hit * 100).round()}%',
                                style: LaTokens.mono(10, la.inkQuiet),
                              ),
                            const SizedBox(width: 8),
                            EscalationNarration(
                              escalatedFrom: row.escalatedFrom,
                              escalatedToLabel: brainModelLabel(
                                id: row.escalatedFrom ?? '',
                                model: world.rungs
                                    .where(
                                      (final r) => r.id == row.escalatedFrom,
                                    )
                                    .firstOrNull
                                    ?.model,
                              ),
                              stalled: row.stalled,
                            ),
                            if (row.at case final at?) ...[
                              const SizedBox(width: 8),
                              Text(at, style: LaTokens.mono(9, la.inkQuiet)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// The world's own decision, narrated: a promotion chip naming the
/// model it fell back TO, or the honest bare `stalled` when the run
/// stalled without a ladder target.
final class EscalationNarration extends StatelessWidget {
  const EscalationNarration({
    required this.escalatedFrom,
    required this.escalatedToLabel,
    required this.stalled,
    super.key,
  });

  /// The rung the dispatch escalated FROM (the daemon's tag); null on
  /// a run that was never promoted.
  final String? escalatedFrom;

  /// The spoken name of the rung it escalated TO.
  final String escalatedToLabel;

  /// Whether the run itself stalled (a stall WITHOUT a promotion stays
  /// visible — the ladder had no answer for it).
  final bool stalled;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    if (escalatedFrom != null) {
      return ModelsChip(
        key: const ValueKey('models.escalation'),
        label: context.l10n.modelsEscalatedTo(escalatedToLabel),
        color: la.caution,
      );
    }
    if (stalled) {
      return ModelsChip(label: 'stalled', color: la.caution);
    }
    return const SizedBox.shrink();
  }
}

/// The actor chips a ladder row shows before the "+N more" cap (the
/// first 2000-actor mitigation).
const int kMaxActorChips = 3;

/// The declared entry's provider map (transport / base_url facts for
/// the lane-class chip) — null when the provider id is not declared.
Map<Object?, Object?>? providerOf(
  final PaletteCandidateModel model,
  final Map<Object?, Object?> entry,
) {
  final id = entry['provider'];
  if (id is! String) return null;
  final raw = model.providers[id];
  return raw is Map ? Map<Object?, Object?>.from(raw) : null;
}

/// A ladder verb (up / down): dimmed when the move is a no-op at the
/// list's edge, never hidden — the table stays scannable.
final class LadderVerb extends StatelessWidget {
  const LadderVerb({
    required this.keyName,
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final String keyName;
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => LaTooltip(
    message: tooltip,
    child: Semantics(
      button: enabled,
      label: keyName,
      child: GestureDetector(
        key: ValueKey(keyName),
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Icon(
            icon,
            size: 14,
            color: enabled
                ? context.la.inkMuted
                : context.la.inkQuiet.withValues(alpha: 0.4),
          ),
        ),
      ),
    ),
  );
}

/// The decision-role rows, collapsed by default under one honest
/// sentence: the world's own quick-decision lanes — present, named,
/// and explicitly not the reader's business. A lane whose brain the
/// catalog provisions (laya's checkpoint) carries that lifecycle
/// inline: the disk-only row's status word + Download/Delete.
final class SystemLanes extends StatefulWidget {
  const SystemLanes({
    required this.entries,
    required this.compact,
    required this.world,
    required this.localModels,
    required this.onAskInstall,
    required this.onAskDelete,
    super.key,
  });

  final List<Map<Object?, Object?>> entries;
  final bool compact;
  final WorldStateService world;
  final LocalModelsState localModels;
  final Future<void> Function(BuildContext, MlxModelCatalogEntry) onAskInstall;
  final Future<void> Function(BuildContext, MlxModelCatalogEntry) onAskDelete;

  @override
  State<SystemLanes> createState() => _SystemLanesState();
}

final class _SystemLanesState extends State<SystemLanes> {
  bool _open = false;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return Semantics(
      key: const ValueKey('models.systemLanes'),
      button: true,
      label: 'models.systemLanes',
      // The WHOLE surface toggles (2026-11-19): the summary row sat
      // outside the old gesture and ate taps aimed at the expander.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _open = !_open),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _open
                        ? Icons.expand_less_outlined
                        : Icons.expand_more_outlined,
                    size: 16,
                    color: la.inkQuiet,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.modelsSystemLanes,
                    style: shellSectionLabel(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.modelsSystemLanesHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.laUi.micro.copyWith(
                        fontSize: 10,
                        color: la.inkQuiet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_open)
            for (final entry in widget.entries)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _SystemLaneRow(
                  entry: entry,
                  compact: widget.compact,
                  world: widget.world,
                  localModels: widget.localModels,
                  onAskInstall: widget.onAskInstall,
                  onAskDelete: widget.onAskDelete,
                ),
              ),
          if (!_open)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.entries
                          .map((final e) => '${e['id']}')
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.laUi.micro.copyWith(
                        fontSize: 10,
                        color: context.la.inkQuiet,
                      ),
                    ),
                  ),
                  // A provisionable lane's missing checkpoint keeps its
                  // download door ON the collapsed line (the fresh-
                  // install flow: the brain is one expansion away, its
                  // weights one tap away).
                  for (final entry in widget.entries)
                    if (installedEntryForCast(
                          widget.localModels,
                          '${entry['id']}',
                        )
                        case null)
                      for (final candidate in familyEntriesForCast(
                        widget.localModels,
                        '${entry['id']}',
                      ).take(1))
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ModelsButton(
                            keyName: 'models.local.'
                                '${localModelRefName(candidate)}.download',
                            label: context.l10n.modelsLocalDownload,
                            onTap: () => unawaited(
                              widget.onAskInstall(context, candidate),
                            ),
                          ),
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

/// One system-lane row: the ladder row's facts minus the order verbs
/// and the behavior sentence (these lanes do not climb) — plus, when
/// the catalog provisions the lane's brain (laya), its checkpoint's
/// disk lifecycle inline.
final class _SystemLaneRow extends StatelessWidget {
  const _SystemLaneRow({
    required this.entry,
    required this.compact,
    required this.world,
    required this.localModels,
    required this.onAskInstall,
    required this.onAskDelete,
  });

  final Map<Object?, Object?> entry;
  final bool compact;
  final WorldStateService world;
  final LocalModelsState localModels;
  final Future<void> Function(BuildContext, MlxModelCatalogEntry) onAskInstall;
  final Future<void> Function(BuildContext, MlxModelCatalogEntry) onAskDelete;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final laUi = context.laUi;
    final l10n = context.l10n;
    final id = '${entry['id']}';
    final rung = world.rungs.where((final r) => r.id == id).firstOrNull;
    final declaredModel = entry['model'] is String
        ? entry['model']! as String
        : null;
    // The alias law (2026-11-19): the lane speaks the MODEL it serves —
    // the installed checkpoint's label — with the lane name as the
    // empty-slot fallback.
    final checkpoint = installedEntryForCast(localModels, id);
    final ref = checkpoint == null ? null : localModelRefName(checkpoint);
    final installed =
        checkpoint != null && localModels.stateOf(checkpoint).installed;
    final busy = checkpoint != null && localModels.isBusy(checkpoint);
    return Container(
      key: ValueKey('models.systemLane.$id'),
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: la.rule, width: 0.5)),
      ),
      child: Row(
        children: [
          HealthDot(status: rung?.healthStatus ?? 'unknown', size: 8),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkpoint?.label ??
                      brainModelLabel(id: id, model: declaredModel),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: laUi.compact,
                ),
                // The lane-mirror law (2026-11-15): the subtitle names
                // the engine truth, never silence — a hosted lane must
                // not read as a local one.
                if (!compact)
                  Text(
                    builtinLaneSentence(context, id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: laUi.micro.copyWith(
                      fontSize: 10,
                      color: la.inkQuiet,
                    ),
                  ),
              ],
            ),
          ),
          // The checkpoint lifecycle (disk-only law: Download/Delete,
          // never a Load — the brain serves through the sidecar).
          if (checkpoint != null && !busy) ...[
            if (!installed)
              ModelsButton(
                keyName: 'models.local.$ref.download',
                label: l10n.modelsLocalDownload,
                onTap: () => unawaited(onAskInstall(context, checkpoint)),
              )
            else ...[
              Text(
                l10n.modelsLocalDiskDownloaded,
                style: LaTokens.mono(10, la.inkMuted),
              ),
              const SizedBox(width: 6),
              ModelsButton(
                keyName: 'models.local.$ref.menu',
                label: '⋯',
                onTap: () => unawaited(onAskDelete(context, checkpoint)),
              ),
            ],
          ] else if (busy)
            const LaSpinner(size: 11, strokeWidth: 1.5),
          // The class chip is the lane truth (wave N4): always on.
          ModelsChip(
            label: laneClassChipLabel(
              classOfBuiltin(builtinLaneFamily(id)),
            ),
            color: la.inkQuiet,
            mono: true,
          ),
        ],
      ),
    );
  }
}
