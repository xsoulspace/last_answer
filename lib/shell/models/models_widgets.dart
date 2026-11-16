/// Models refactor (2026-11-14) — the shared chrome of the three lenses:
/// the fact chip, the small verb button, the honest note line, and the
/// ONE dirty bar every editing lens rides (propose → receipt → apply,
/// the host's envelopes rendered VERBATIM). Moved out of the retired
/// `view_models.dart` monolith unchanged in law, renamed where the old
/// names carried the dialog's anatomy (`_DialogButton` → [ModelsButton]).
library;

import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/palette_candidate.dart';
import 'package:lastanswer/shell/shell_theme.dart';

/// The row's small fact chip (transport family, model count, env NAME,
/// cast reference): 16px, tinted fill, mono when the fact is a wire id.
final class ModelsChip extends StatelessWidget {
  const ModelsChip({
    required this.label,
    required this.color,
    this.mono = false,
    super.key,
  });

  final String label;
  final Color color;
  final bool mono;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 6),
    child: Container(
      // Padding, NOT a Center child: inside the model row's Wrap a
      // Center expands every chip to the wrap's full width (the same
      // bounded-loose law the lens pills hit, live-caught).
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: mono
            ? LaTokens.mono(9, color)
            : context.laUi.micro.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
      ),
    ),
  );
}

/// The small verb button (add / edit / remove / propose / apply …):
/// one height, one fill, a spinner while the lane is busy.
final class ModelsButton extends StatelessWidget {
  const ModelsButton({
    required this.keyName,
    required this.label,
    required this.onTap,
    this.busy = false,
    super.key,
  });

  final String keyName;
  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return Semantics(
      button: true,
      label: keyName,
      hint: label,
      child: MouseRegion(
        cursor: busy ? MouseCursor.defer : SystemMouseCursors.click,
        child: GestureDetector(
          key: ValueKey(keyName),
          behavior: HitTestBehavior.opaque,
          onTap: busy ? null : onTap,
          child: Container(
            // Padding, NOT a Center child: Align/Center expand to the
            // incoming max width under bounded-loose constraints (a
            // Wrap or a Row), which stretches every pill to the pane
            // (live-caught via the widget inspector, 2026-11-15).
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: la.ink.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: busy
                ? LaSpinner(size: 11, strokeWidth: 1.5, color: la.inkMuted)
                : Text(
                    label,
                    style: context.laUi.micro.copyWith(
                      fontWeight: FontWeight.w600,
                      color: la.inkMuted,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// The honest note line (local refusal, receipt, apply outcome): mono,
/// colored by kind, the host's text rendered VERBATIM.
final class ModelsNote extends StatelessWidget {
  const ModelsNote({
    required this.keyName,
    required this.text,
    required this.color,
    super.key,
  });

  final String keyName;
  final String text;
  final Color color;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      key: ValueKey(keyName),
      style: LaTokens.mono(11, color),
    ),
  );
}

/// A named refusal / quiet absence note (the house law: honest surfaces
/// render the code verbatim).
final class ModelsRefusalNote extends StatelessWidget {
  const ModelsRefusalNote({
    required this.keyName,
    required this.text,
    super.key,
  });

  final String keyName;
  final String text;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Container(
      key: ValueKey(keyName),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.la.caution.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ShellTokens.radius),
      ),
      child: Text(
        text,
        style: context.laUi.micro.copyWith(
          fontFamily: LaTokens.monoFamily,
          color: context.la.inkMuted,
        ),
      ),
    ),
  );
}

/// The builtin row's subtitle: its composition-root lane family as one
/// honest sentence (the mirror in `palette_lanes.dart`; an unknown
/// family says builtin-owned, never a guessed lane). Shared by the
/// bindings ladder and the catalog's on-device section (wave N4).
String builtinLaneSentence(final BuildContext context, final String id) =>
    switch (builtinLaneFamily(id)) {
      BuiltinLaneFamily.localMlx => context.l10n.modelsBuiltinLaneLocal,
      BuiltinLaneFamily.localDecision =>
        context.l10n.modelsBuiltinLaneDecision,
      BuiltinLaneFamily.appleFoundation => context.l10n.modelsBuiltinLaneAfm,
      BuiltinLaneFamily.hostedOpenRouter =>
        context.l10n.modelsBuiltinLaneOpenRouter,
      BuiltinLaneFamily.unknown => context.l10n.modelsBuiltinLaneUnknown,
    };

/// The candidate's structured refusal as one l10n sentence plus the
/// refs it names — the UI owns the wording, the model owns the fact.
String refusalText(final BuildContext context, final CandidateRefusal refusal) {
  final l10n = context.l10n;
  final refs = refusal.refs.join(', ');
  final sentence = switch (refusal.code) {
    'emptyId' => l10n.modelsRefusalEmptyId,
    'duplicateProvider' => '${l10n.modelsRefusalDuplicateProvider} "$refs"',
    'duplicateModel' => '${l10n.modelsRefusalDuplicateModel} "$refs"',
    'idImmutable' => '${l10n.modelsRefusalIdImmutable} $refs',
    'providerInUse' => '${l10n.modelsRefusalProviderInUse} $refs',
    'modelInUse' => '${l10n.modelsRefusalModelInUse} $refs',
    'noSeat' => l10n.modelsRefusalNoSeat,
    'badNumber' => l10n.modelsRefusalBadNumber,
    'jsonInvalid' =>
      '${l10n.modelsJsonInvalid}'
      '${refusal.detail == null ? '' : ' · ${refusal.detail}'}',
    _ => refusal.detail ?? refusal.code,
  };
  return sentence;
}

/// One honest line out of a host envelope: the bounce code plus the
/// refusal — a string message VERBATIM, or a detail map's `recovery`
/// text VERBATIM (the owner refusal's recovery is the helpful half; a
/// bare error is never rendered).
String envelopeLine(final Map<String, Object?> envelope) {
  final bounce = '${envelope['bounce'] ?? 'refused'}';
  final refusal = envelope['refusal'];
  if (refusal is String && refusal.isNotEmpty) return '$bounce: $refusal';
  if (refusal is Map) {
    final recovery = refusal['recovery'];
    if (recovery is String && recovery.isNotEmpty) {
      return '$bounce: $recovery';
    }
    return '$bounce: $refusal';
  }
  return bounce;
}

/// The receipt as readable lines: the before-sha, the cast diff, the
/// parser's warnings and the restart fact.
String receiptText(
  final BuildContext context,
  final Map<String, Object?> receipt,
) {
  final diff = receipt['diff'];
  final added = diff is Map
      ? (diff['added'] as List? ?? const <Object?>[])
      : const <Object?>[];
  final removed = diff is Map
      ? (diff['removed'] as List? ?? const <Object?>[])
      : const <Object?>[];
  final buffer = StringBuffer(
    'ok · beforeSha256 ${receipt['beforeSha256'] ?? 'none'}',
  );
  if (added.isNotEmpty) buffer.write('\n+ ${added.join(', ')}');
  if (removed.isNotEmpty) buffer.write('\n- ${removed.join(', ')}');
  for (final warning in (receipt['warnings'] as List? ?? const <Object?>[])) {
    if (warning is Map) {
      buffer.write('\n${warning['code']}: ${warning['detail'] ?? ''}');
    }
  }
  if (receipt['restartRequired'] == true) {
    buffer.write('\n${context.l10n.modelsRestartRequired}');
  }
  return buffer.toString();
}

/// The ONE dirty bar the editing lenses ride: the dirty fact, Propose
/// (every seat), Cancel (revert), and Apply only once a receipt says ok
/// — the owner-only verb's refusal renders its recovery verbatim below.
final class PaletteDirtyBar extends StatelessWidget {
  const PaletteDirtyBar({required this.model, super.key});

  final PaletteCandidateModel model;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final receipt = model.receipt;
    final outcome = model.applyOutcome;
    return Container(
      key: const ValueKey('models.dirtyBar'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.shellHairline, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  model.dirty
                      ? context.l10n.modelsUnsavedChanges
                      : context.l10n.modelsInSync,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaTokens.mono(
                    10,
                    model.dirty ? la.caution : la.inkQuiet,
                  ),
                ),
              ),
              if (model.dirty) ...[
                ModelsButton(
                  keyName: 'models.propose',
                  label: context.l10n.modelsPropose,
                  busy: model.busy,
                  onTap: () => unawaited(model.propose()),
                ),
                const SizedBox(width: 8),
                ModelsButton(
                  keyName: 'models.cancel',
                  label: context.l10n.modelsCancel,
                  onTap: model.revert,
                ),
              ],
              if (model.receiptOk) ...[
                const SizedBox(width: 8),
                ModelsButton(
                  keyName: 'models.apply',
                  label: context.l10n.modelsApply,
                  busy: model.busy,
                  onTap: () => unawaited(model.apply()),
                ),
              ],
            ],
          ),
          if (model.refusal case final refusal?)
            ModelsNote(
              keyName: 'models.refusal.local',
              text: refusalText(context, refusal),
              color: la.caution,
            ),
          if (receipt != null)
            ModelsNote(
              keyName: receipt['ok'] == true
                  ? 'models.receipt.ok'
                  : 'models.receipt.refusal',
              text: receipt['ok'] == true
                  ? receiptText(context, receipt)
                  : envelopeLine(receipt),
              color: receipt['ok'] == true ? la.accent : la.danger,
            ),
          if (outcome != null)
            ModelsNote(
              keyName: outcome['ok'] == true
                  ? 'models.apply.outcome'
                  : outcome['bounce'] == 'palette_apply_not_owner'
                  ? 'models.refusal.recovery'
                  : 'models.apply.outcome',
              text: outcome['ok'] == true
                  ? 'applied · ${outcome['revisionId']} · '
                        '${context.l10n.modelsRestartRequired}'
                  : envelopeLine(outcome),
              color: outcome['ok'] == true ? la.accent : la.danger,
            ),
        ],
      ),
    );
  }
}
