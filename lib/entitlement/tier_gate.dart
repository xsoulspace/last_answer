/// Plan v5 4b — the tier layer: FREE vs PRO, composed ON TOP of the
/// platform-fact layer, never replacing it. The composition law:
/// [DeviceCapabilitySnapshot] answers "what can THIS device host?"
/// (mesh, ACP installs, AFM, laya reachability); [tierAllows] answers
/// "what may THIS user unlock?" A PRO surface opens only when both
/// answer yes — a tier never fakes a capability, and a capability
/// never grants a tier.
///
/// Tier law (the plan's two lists):
/// - FREE, never gated (fail OPEN): endless conversations with actors,
///   documents / notes / ideas, basic artifact editing. None of these
///   has a [TierFeature] — the FREE core is not expressible as a gate.
/// - PRO (fail QUIET): debugging / observability / customization —
///   [ProGate] renders a quiet named absence with the upgrade route
///   ([PaywallFlow.pushPaywall]), never a crash, never a locked-out
///   blank screen.
library;

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/entitlement/pro_entitlement.dart';
import 'package:lastanswer/ui_pay/paywall_flow.dart';

/// PROVISIONAL FREE cast limit — N is TBD with the owner (plan v5 4b);
/// 5 is the named default until the product owner pins the number
/// (pending owner decision, plan v5 4b).
const freeCastLimit = 5;

/// The PRO feature list (plan v5 4b). Membership here IS the gate:
/// anything not listed stays FREE by law.
enum TierFeature {
  /// The Models palette EDITOR (the rungs/telemetry read model stays
  /// FREE — reading the truth is never a paid feature).
  paletteEditor('palette editor'),

  /// The world inspector (debugging/observability).
  worldInspector('world inspector'),

  /// The terminal surface.
  terminal('terminal'),

  /// Mesh sync (cross-device replica transport).
  meshSync('mesh sync'),

  /// Daemon arm/restart/stop controls.
  daemonControl('daemon control'),

  /// Per-call trace depth (observability).
  traceDepth('per-call trace depth'),

  /// The ACP bridge (later — reserved, plan v5 4b).
  acpBridge('ACP bridge'),

  /// Casting more than [freeCastLimit] actors.
  castBeyondFreeLimit('cast beyond $freeCastLimit actors');

  const TierFeature(this.label);

  /// The unlocalized field word naming the feature in a quiet absence
  /// (the house mono-fact vocabulary).
  final String label;
}

/// The pure tier law: every listed PRO feature answers `isPro`. Kept
/// as an exhaustive switch so a future feature with a different rule
/// (a metered tier, a grace window) is a named edit, not a silent
/// default.
bool tierAllows(
  final TierFeature feature, {
  required final bool isPro,
}) => switch (feature) {
  TierFeature.paletteEditor ||
  TierFeature.worldInspector ||
  TierFeature.terminal ||
  TierFeature.meshSync ||
  TierFeature.daemonControl ||
  TierFeature.traceDepth ||
  TierFeature.acpBridge ||
  TierFeature.castBeyondFreeLimit => isPro,
};

/// The cast-count companion law (pure): PRO casts any number; FREE is
/// capped at [freeCastLimit] (provisional — see its TODO).
bool tierAllowsCastCount(
  final int castCount, {
  required final bool isPro,
}) => isPro || castCount <= freeCastLimit;

/// The composable tier gate: [child] when the tier allows [feature],
/// otherwise the quiet named absence ([TierAbsence]) with the upgrade
/// route.
///
/// Absent-entitlement law: when NO [ProEntitlement] is mounted the
/// gate fails OPEN — an unmounted tier layer is not a free verdict,
/// and hermetic surfaces (and their tests) are never locked out by a
/// layer that was never installed. In production the entitlement is
/// provided app-wide (global_states_provider), so absence only occurs
/// in hermetic harnesses.
class ProGate extends StatelessWidget {
  const ProGate({required this.feature, required this.child, super.key});

  final TierFeature feature;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final entitlement = context.watch<ProEntitlement?>();
    final isPro = entitlement?.isPro ?? true;
    if (tierAllows(feature, isPro: isPro)) return child;
    return TierAbsence(feature: feature);
  }
}

/// The quiet named absence (the house honest-absence pattern): names
/// WHAT is absent and WHY, and offers the one upgrade route. Never a
/// blank lock, never a crash.
class TierAbsence extends StatelessWidget {
  const TierAbsence({required this.feature, super.key});

  final TierFeature feature;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return Semantics(
      button: true,
      label: 'tier.absence.${feature.name}',
      hint: '${feature.label} · PRO',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: ValueKey('tier.absence.${feature.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => unawaited(PaywallFlow.pushPaywall(context)),
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: la.ink.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: la.rule),
            ),
            child: Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${feature.label} · ',
                      style: LaTokens.mono(10, la.inkQuiet),
                    ),
                    TextSpan(
                      text: 'PRO',
                      style: LaTokens.mono(10, la.accent),
                    ),
                    TextSpan(
                      text: ' — See Plans',
                      style: LaTokens.mono(10, la.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
