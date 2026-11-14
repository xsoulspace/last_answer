/// Models refactor (2026-11-14) — the BINDINGS lens: the cast layer the
/// old view led with, promoted to an EDITABLE ladder over the shared
/// candidate. The escalation order IS the cast list's order (up/down
/// verbs = `moveCast`), the persisted `primary` mark is a radio on the
/// row (`setPrimary`), and the session-only "delegate via" override
/// rides the header as a labelled chip — never confused with the
/// persisted primary. Health joins by cast id from the live rungs, so
/// a dirty candidate still shows the daemon's truth beside the pending
/// order. Actor chips name who rides each rung (the durable
/// `brainCast` rows), linking the binding layer to the actor surface.
library;

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/models_widgets.dart';
import 'package:lastanswer/shell/models/palette_candidate.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/status_edge.dart' show HealthDot;

final class BindingsLens extends StatelessWidget {
  const BindingsLens({
    required this.model,
    required this.world,
    required this.compact,
    this.service,
    super.key,
  });

  final PaletteCandidateModel model;
  final WorldStateService world;
  final bool compact;
  final RealmChatService? service;

  @override
  Widget build(final BuildContext context) {
    final cast = model.cast.whereType<Map<Object?, Object?>>().toList();
    final generative = <Map<Object?, Object?>>[
      for (final entry in cast)
        if (entry['role'] == 'generative') entry,
    ];
    final decision = <Map<Object?, Object?>>[
      for (final entry in cast)
        if (entry['role'] != 'generative') entry,
    ];
    return ListView(
      key: const ValueKey('models.bindings'),
      padding: EdgeInsets.zero,
      children: [
        if (world.selectedRungId case final session?)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                ModelsChip(
                  label: '${context.l10n.modelsSessionPrefix} $session',
                  color: context.la.accent,
                  mono: true,
                ),
                const SizedBox(width: 8),
                ModelsButton(
                  keyName: 'models.session.clear',
                  label: context.l10n.modelsSessionClear,
                  onTap: () => world.selectRung(null),
                ),
              ],
            ),
          ),
        Text(context.l10n.modelsGenerative, style: shellSectionLabel(context)),
        const SizedBox(height: 6),
        if (generative.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(context.l10n.modelsNoPalette),
          ),
        for (var i = 0; i < generative.length; i++)
          _ladderRow(context, generative[i], i, generative.length, true),
        if (decision.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(context.l10n.modelsDecision, style: shellSectionLabel(context)),
          const SizedBox(height: 6),
          for (final entry in decision)
            _ladderRow(context, entry, null, decision.length, false),
        ],
      ],
    );
  }

  Widget _ladderRow(
    final BuildContext context,
    final Map<Object?, Object?> entry,
    final int? index,
    final int count,
    final bool editable,
  ) {
    final la = context.la;
    final theme = Theme.of(context);
    final id = '${entry['id']}';
    final rung = world.rungs.where((final r) => r.id == id).firstOrNull;
    final primary = entry['primary'] == true;
    final actors = <String>[
      for (final binding
          in (service?.brainCasts ?? const <String, String>{}).entries)
        if (binding.value == id) binding.key,
    ];
    // The session delegate-via law survives the refactor: tapping a
    // GENERATIVE row is the session-only override (the persisted
    // primary is the radio verb, never the row tap).
    return Semantics(
      key: ValueKey('models.rung.$id'),
      button: editable,
      label: 'models.rung.$id',
      hint: id,
      child: ShellRow(
        height: 44,
        selected: primary,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: editable
            ? () => world.selectRung(world.selectedRungId == id ? null : id)
            : null,
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            // The pane law: a narrow split pane on a wide window
            // compresses like a phone — the chip run is a WIDTH fact,
            // not a window fact.
            final tight = compact || constraints.maxWidth < 420;
            return Row(
              children: [
                if (index != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${index + 1}',
                      style: LaTokens.mono(10, la.inkQuiet),
                    ),
                  ),
                HealthDot(status: rung?.healthStatus ?? 'unknown', size: 8),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: primary ? FontWeight.w600 : null,
                        ),
                      ),
                      if (!tight)
                        if (entry['model'] case final modelName?)
                          Text(
                            '${entry['provider'] ?? ''}/$modelName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: la.inkQuiet,
                            ),
                          ),
                    ],
                  ),
                ),
                if (primary)
                  ModelsChip(
                    label: context.l10n.modelsChipPrimary,
                    color: la.accent,
                  ),
                if (entry['builtin'] == true)
                  ModelsChip(
                    label: context.l10n.modelsChipLocal,
                    color: la.inkQuiet,
                  ),
                if (!tight)
                  if (rung?.ladderNext case final next?)
                    ModelsChip(
                      label: '→ $next',
                      color: la.inkQuiet,
                      mono: true,
                    ),
                if (!tight)
                  for (final actor in actors)
                    ModelsChip(label: actor, color: la.inkQuiet, mono: true),
                if (editable && index != null) ...[
                  const SizedBox(width: 6),
                  _LadderVerb(
                    keyName: 'models.cast.$id.up',
                    icon: Icons.arrow_upward_outlined,
                    tooltip: context.l10n.modelsMoveUp,
                    enabled: index > 0,
                    onTap: () => model.moveCast(id, index - 1),
                  ),
                  _LadderVerb(
                    keyName: 'models.cast.$id.down',
                    icon: Icons.arrow_downward_outlined,
                    tooltip: context.l10n.modelsMoveDown,
                    enabled: index < count - 1,
                    onTap: () => model.moveCast(id, index + 1),
                  ),
                  _LadderVerb(
                    keyName: 'models.cast.$id.primary',
                    icon: primary
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    tooltip: context.l10n.modelsSetPrimary,
                    enabled: !primary,
                    onTap: () => model.setPrimary(id),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A ladder verb (up / down / primary): dimmed when the move is a
/// no-op at the list's edge, never hidden — the table stays scannable.
final class _LadderVerb extends StatelessWidget {
  const _LadderVerb({
    required this.keyName,
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Tooltip(
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
