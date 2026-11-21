/// The local-model memory budget (2026-11-18; 2026-11-20 one-math law,
/// owner-corrected the same day) — whether a catalog entry fits the
/// machine BEFORE any load is attempted, as pure math over the sensed
/// facts.
///
/// THE arithmetic lives in the runtime's gate (`MlxLoadGate`), in two
/// separate quantities the owner named apart:
///
/// * the MODEL's requirement — `weightsMb.ceil() × (1 + slack)` — what
///   this checkpoint itself adds to RAM (KV cache included);
/// * the MACHINE's pressure point — the fixed 1 GB reserve — ONE shared
///   post-load headroom floor for all models, never per-model rent,
///   never baked into what a model "requires".
///
/// The gate allows a load iff `available − modelRequirement ≥ pressure
/// point`. This file renders the SAME comparison as a named verdict so
/// the catalog rows say "fits now" / "needs X more" / "exceeds machine
/// memory" without anyone pressing Load to find out — and so the fit
/// can never claim a refusal the gate would not make (the 2026-11-20
/// finding: the old UI verdict added its own stricter floor+slack
/// arithmetic and disabled loads the gate would have allowed).
///
/// Size-aware by the same law: the requirement scales with the
/// checkpoint (a small model must not pay a big model's rent); the old
/// flat 4 GB gate survives only as the weights-UNKNOWN fallback inside
/// the package (the chat clients' lazy loads keep the calibrated
/// incident floor).
///
/// Pure: no I/O, no clocks — the facts come in as nullable ints exactly
/// as [MemoryFacts.current] yields them, and a null fact degrades to the
/// `unknown` verdict (an absent sensor never invents a verdict).
library;

import 'dart:math' as math;

import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// The machine's pressure point, in MB — the shared post-load headroom
/// every size-aware load must leave free (single-sourced from
/// [MlxLoadGate.defaults]; the budget bar's policy line renders it).
/// The old flat-floor constant is retired: the requirement is
/// per-checkpoint, the pressure point is the machine's.
final int kLocalModelLoadPressurePointMegabytes =
    MlxLoadGate.defaults.reserveMegabytes;

/// One entry's fit verdict, with the numbers that drove it (the UI
/// renders them verbatim — a verdict without its arithmetic is a
/// rumor).
final class LocalModelFit {
  /// Build the verdict directly; the named constructors below cover the
  /// two degenerate shapes (unknown facts, computed verdict).
  const LocalModelFit._({
    required this.unknown,
    required this.fitsNow,
    required this.neverFits,
    required this.requiredMegabytes,
    required this.availableMegabytes,
    required this.totalMegabytes,
    required this.missingMegabytes,
  });

  /// The sensor-absent verdict: no facts, no claim. The row renders NO
  /// fit chip (an honest absence — never a guessed "fits").
  const LocalModelFit.unknown()
    : this._(
        unknown: true,
        fitsNow: false,
        neverFits: false,
        requiredMegabytes: null,
        availableMegabytes: null,
        totalMegabytes: null,
        missingMegabytes: null,
      );

  /// The computed verdict over known facts — the gate's own
  /// [MlxLoadGate.requiredMegabytes] (the MODEL's weights+slack
  /// requirement) against the machine's pressure point, verbatim:
  ///
  /// - `fitsNow`: available − requirement ≥ pressure point — the same
  ///   fact `MlxLoadGate.evaluate(weightsBytes:)` answers.
  /// - `neverFits`: requirement + pressure point over the sensed total
  ///   — no amount of closing tabs makes the machine hold it.
  /// - [missingMegabytes]: how much more AVAILABLE memory the load
  ///   still needs (0 when it fits; null only with unknown facts).
  factory LocalModelFit.evaluate({
    required final int? availableMegabytes,
    required final int? totalMegabytes,
    required final int weightsBytes,
  }) {
    const gate = MlxLoadGate.defaults;
    final required = gate.requiredMegabytes(weightsBytes);
    final pressurePoint = gate.reserveMegabytes;
    final available = availableMegabytes;
    if (available == null) return const LocalModelFit.unknown();
    final total = totalMegabytes;
    final never = total != null && required + pressurePoint > total;
    final missing = math.max(0, required + pressurePoint - available);
    return LocalModelFit._(
      unknown: false,
      fitsNow: available - required >= pressurePoint,
      neverFits: never,
      requiredMegabytes: required,
      availableMegabytes: available,
      totalMegabytes: total,
      missingMegabytes: missing,
    );
  }

  /// True when the facts never arrived (sensor failure, non-macOS).
  /// The other fields keep their null/false degenerate values.
  final bool unknown;

  /// The machine keeps its pressure point free with this checkpoint
  /// resident — the load gate would not refuse it on today's memory.
  final bool fitsNow;

  /// The machine cannot hold the requirement plus its pressure point
  /// even at its total — closing apps changes nothing.
  final bool neverFits;

  /// The MODEL's requirement (weights + KV/runtime slack), in MB — the
  /// gate's own number, WITHOUT the machine's pressure point (that is
  /// never this model's rent). Null only with unknown facts.
  final int? requiredMegabytes;

  /// The sensed AVAILABLE memory the verdict used (MB), verbatim from
  /// the facts. Null only with unknown facts.
  final int? availableMegabytes;

  /// The sensed total memory (MB), verbatim from the facts; null when
  /// the sensor could not see the total (`neverFits` then stays false —
  /// an unseen total never convicts a machine).
  final int? totalMegabytes;

  /// How much more AVAILABLE memory the load needs — the gap between
  /// today's reclaimable memory and (requirement + pressure point).
  /// The "needs X more" chip renders this through `formatModelBytes`.
  final int? missingMegabytes;
}

/// The catalog lens's fit evaluator: one entry's verdict over the given
/// memory facts. The weights ride the catalog's approximate download
/// bytes — [InstalledState] carries NO on-disk size, so this is the
/// APPROXIMATE residency, not a sensed one (the doc comment on
/// [MlxModelCatalogEntry.approxDownloadBytes] fronts the same
/// approximation at consent time) — and the LOAD verb passes the same
/// bytes to the gate, so the verdict and the enforcement agree by
/// construction.
LocalModelFit evaluateLocalModelFit({
  required final int? availableMegabytes,
  required final int? totalMegabytes,
  required final int weightsBytes,
}) => LocalModelFit.evaluate(
  availableMegabytes: availableMegabytes,
  totalMegabytes: totalMegabytes,
  weightsBytes: weightsBytes,
);
