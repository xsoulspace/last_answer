/// Brain-policy components (stage C, 2026-11-16) — the reusable atoms
/// of the policy surface, extracted from the lenses that proved them:
///
/// * [policySentenceFor] — the behavior sentence of a policy position
///   ("thinks first" / "if the previous model is down or stuck"). The
///   order IS the authoring; the sentence is how a zero-knowledge user
///   reads it.
/// * [EscalationNarration] — the chip that says what the world DID
///   ("stalled → tried Qwen3.8 Max Preview"), from the daemon's
///   flattened `escalatedFrom` telemetry tag (ADR 0122 promotion,
///   narrated).
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
import 'package:lastanswer/shell/models/models_widgets.dart';

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
