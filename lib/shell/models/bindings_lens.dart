/// Models refactor (2026-11-14) — the POLICY lens (the brain-policy
/// vocabulary law, 2026-11-16: no palette words on user surfaces; design
/// doc docs/design/brain-policy-models-2026-11-16.md). The world default
/// reads as SENTENCES: position 1 "thinks first", every following row
/// "if the previous model is down or stuck" — the order IS the policy,
/// and the
/// persisted default rides position 1 ([PaletteCandidateModel.moveCast]
/// maintains the mark, so order and default can never disagree; the old
/// primary radio is gone). The row's main text is the model's spoken
/// name with the raw entry id as the mono subtitle — the id stays the
/// stable handle agents reference. Actor chips name who USES each model,
/// capped at three + "+N" (the first 2000-actor mitigation). Decision-
/// role rows collapse under System lanes with one sentence — a layperson
/// learns they exist and not to touch them. Health joins by entry id
/// from the live rungs, so a dirty candidate still shows the daemon's
/// truth beside the pending order.
///
/// Widget-key law (DESIGN.md — the agent UI contract): rows stay
/// `models.rung.<id>`, verbs `models.cast.<id>.up/down`; the retired
/// radio key `models.cast.<id>.primary` is REMOVED — moving a row to
/// the top IS "set as default" now.
library;

import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/models_widgets.dart';
import 'package:lastanswer/shell/models/palette_candidate.dart';
import 'package:lastanswer/shell/models/policy_components.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/status_edge.dart' show HealthDot;

/// The actor chips a model row shows before the "+N more" cap.
const int _maxActorChips = 3;

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
    // The spoken names up front: each row's sentence names the row
    // BEFORE it ("if Qwen3.8 Max is down or stuck"), not an id.
    final labels = <String>[
      for (final entry in generative)
        brainModelLabel(
          id: '${entry['id']}',
          model: entry['model'] is String ? entry['model']! as String : null,
        ),
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
        Text(
          context.l10n.modelsPolicySection,
          style: shellSectionLabel(context),
        ),
        const SizedBox(height: 6),
        if (generative.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(context.l10n.modelsNoModels),
          ),
        for (var i = 0; i < generative.length; i++)
          _policyRow(context, generative[i], i, labels, generative),
        if (decision.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SystemLanes(entries: decision, compact: compact, world: world),
        ],
      ],
    );
  }

  /// One policy row: position number, health, the model's spoken name
  /// over the raw entry id, the behavior sentence, the lane-class chip
  /// and the actor chips (capped).
  Widget _policyRow(
    final BuildContext context,
    final Map<Object?, Object?> entry,
    final int index,
    final List<String> labels,
    final List<Map<Object?, Object?>> generative,
  ) {
    final count = generative.length;
    final la = context.la;
    final laUi = context.laUi;
    final id = '${entry['id']}';
    final rung = world.rungs.where((final r) => r.id == id).firstOrNull;
    final label = labels[index];
    final actors = <String>[
      for (final binding
          in (service?.brainCasts ?? const <String, String>{}).entries)
        if (binding.value == id) binding.key,
    ];
    // The session delegate-via law survives the refactor: tapping a row
    // is the session-only override (the world default is position 1,
    // never a row tap).
    return Semantics(
      key: ValueKey('models.rung.$id'),
      button: true,
      label: 'models.rung.$id',
      hint: id,
      child: ShellRow(
        height: 44,
        selected: index == 0,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: () => world.selectRung(world.selectedRungId == id ? null : id),
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            // The pane law: a narrow split pane on a wide window
            // compresses like a phone — the chip run is a WIDTH fact,
            // not a window fact.
            final tight = compact || constraints.maxWidth < 420;
            // The absorb window made honest (Stage B absorbs the
            // explicit `realm_actor_escalation` map into the order):
            // while an explicit row DISAGREES with the adjacency the
            // sentence shows, the declared target stays visible — the
            // daemon follows it, and silence would hide the
            // disagreement.
            final divergesFromAdjacency =
                index + 1 < count &&
                rung?.ladderNext != null &&
                rung!.ladderNext != '${generative[index + 1]['id']}';
            return Row(
              children: [
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
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: laUi.compact.copyWith(
                          fontWeight: index == 0 ? FontWeight.w600 : null,
                        ),
                      ),
                      // The subtitle is the row's ENGINE truth: a
                      // builtin row names its lane family in a sentence
                      // (the lane-mirror law, 2026-11-15 — silence made
                      // `jev` read as a local model), a declared row
                      // names the raw entry id — the stable handle
                      // agents and refs name.
                      if (!tight)
                        Text(
                          entry['builtin'] == true
                              ? builtinLaneSentence(context, id)
                              : id,
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
                // The behavior sentence IS the "when to use" authoring:
                // position 1 thinks first; every later row names the one
                // it falls back FROM (the shared component — the actor
                // card can speak the same sentence).
                if (!tight)
                  Text(
                    policySentenceFor(context, index, labels),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: laUi.micro.copyWith(
                      fontSize: 10,
                      color: la.inkQuiet,
                    ),
                  ),
                // The lane chip is the owner's CLASS truth (wave N4):
                // remote / loopback / on-device / builtin — never the
                // bare `builtin` guess the old chip made (`jev` rides
                // the hosted OpenRouter lane, so it chips remote).
                if (entry['builtin'] == true)
                  ModelsChip(
                    label: laneClassChipLabel(
                      classOfBuiltin(builtinLaneFamily(id)),
                    ),
                    color: la.inkQuiet,
                    mono: true,
                  )
                else
                  ModelsChip(
                    label: laneClassChipLabel(
                      classOfProvider(
                        '${_providerOf(model, entry)?['transport'] ?? ''}',
                        '${_providerOf(model, entry)?['base_url'] ?? ''}',
                      ),
                    ),
                    color: la.inkQuiet,
                    mono: true,
                  ),
                if (!tight && divergesFromAdjacency)
                  ModelsChip(
                    label: '→ ${rung.ladderNext}',
                    color: la.caution,
                    mono: true,
                  ),
                if (!tight)
                  for (final actor in actors.take(_maxActorChips))
                    ModelsChip(label: actor, color: la.inkQuiet, mono: true),
                // The 2000-actor mitigation: a count, never N chips.
                if (!tight && actors.length > _maxActorChips)
                  ModelsChip(
                    label: context.l10n.modelsActorsMore(
                      actors.length - _maxActorChips,
                    ),
                    color: la.inkQuiet,
                    mono: true,
                  ),
                if (count > 1) ...[
                  const SizedBox(width: 6),
                  _LadderVerb(
                    keyName: 'models.cast.$id.up',
                    icon: Icons.arrow_upward_outlined,
                    tooltip: context.l10n.modelsMoveUp,
                    enabled: index > 0,
                    onTap: () => _move(model, index - 1, id),
                  ),
                  _LadderVerb(
                    keyName: 'models.cast.$id.down',
                    icon: Icons.arrow_downward_outlined,
                    tooltip: context.l10n.modelsMoveDown,
                    enabled: index < count - 1,
                    onTap: () => _move(model, index + 1, id),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// Moves the generative entry [id] to subset position [targetSubset].
  /// The persisted cast list interleaves decision rows, so the subset
  /// index resolves to FULL list positions ([_fullIndexOfGenerative]);
  /// after the candidate's removeAt, inserting AT the target's index
  /// lands beside it in both directions.
  void _move(
    final PaletteCandidateModel model,
    final int targetSubset,
    final String id,
  ) {
    final target = _fullIndexOfGenerative(
      model.cast.whereType<Map<Object?, Object?>>().toList(),
      targetSubset,
    );
    if (target < 0) return;
    model.moveCast(id, target);
  }

  /// The full cast-list index of the [subsetIndex]-th generative entry.
  int _fullIndexOfGenerative(
    final List<Map<Object?, Object?>> cast,
    final int subsetIndex,
  ) {
    var seen = -1;
    for (var i = 0; i < cast.length; i++) {
      if (cast[i]['role'] == 'generative') {
        seen++;
        if (seen == subsetIndex) return i;
      }
    }
    return -1;
  }
}

/// The decision-role rows, collapsed by default under one honest
/// sentence: these are the world's own quick-decision lanes — present,
/// named, and explicitly not the reader's business.
final class _SystemLanes extends StatefulWidget {
  const _SystemLanes({
    required this.entries,
    required this.compact,
    required this.world,
  });

  final List<Map<Object?, Object?>> entries;
  final bool compact;
  final WorldStateService world;

  @override
  State<_SystemLanes> createState() => _SystemLanesState();
}

final class _SystemLanesState extends State<_SystemLanes> {
  bool _open = false;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return Semantics(
      key: const ValueKey('models.systemLanes'),
      button: true,
      label: 'models.systemLanes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _open = !_open),
            child: Padding(
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
          ),
          if (_open)
            for (final entry in widget.entries)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _SystemLaneRow(
                  entry: entry,
                  compact: widget.compact,
                  world: widget.world,
                ),
              ),
          if (!_open)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                widget.entries.map((final e) => '${e['id']}').join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.laUi.micro.copyWith(
                  fontSize: 10,
                  color: context.la.inkQuiet,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One system-lane row: the same facts as a policy row, minus the order
/// verbs and the behavior sentence (these lanes do not climb).
final class _SystemLaneRow extends StatelessWidget {
  const _SystemLaneRow({
    required this.entry,
    required this.compact,
    required this.world,
  });

  final Map<Object?, Object?> entry;
  final bool compact;
  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final laUi = context.laUi;
    final id = '${entry['id']}';
    final rung = world.rungs.where((final r) => r.id == id).firstOrNull;
    final declaredModel = entry['model'] is String
        ? entry['model']! as String
        : null;
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
          // The class chip is the lane truth (wave N4): always on,
          // like the policy rows — only the subtitle width-gates.
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

/// A ladder verb (up / down): dimmed when the move is a no-op at the
/// list's edge, never hidden — the table stays scannable.
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

/// The builtin row's subtitle and the declared row's provider facts
/// come from different sources: the lane mirror vs the candidate's
/// provider map (wave N4 class chips).
Map<Object?, Object?>? _providerOf(
  final PaletteCandidateModel model,
  final Map<Object?, Object?> entry,
) {
  final id = entry['provider'];
  if (id is! String) return null;
  final raw = model.providers[id];
  return raw is Map ? Map<Object?, Object?>.from(raw) : null;
}
