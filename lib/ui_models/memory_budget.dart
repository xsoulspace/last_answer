/// The local-model memory budget (2026-11-18; 2026-11-20 one-math law)
/// — whether a catalog entry fits the machine BEFORE any load is
/// attempted, as pure math over the sensed facts.
///
/// THE arithmetic lives in the runtime's gate (`MlxLoadGate`):
/// `required = weightsMb.ceil() × (1 + slack) + reserve` — weights
/// rounded up, the KV/runtime slack over them, and the fixed system
/// reserve. This file renders that SAME function as a named verdict so
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

/// The gate's fixed system reserve, in MB — the part of the load
/// requirement that does NOT scale with the checkpoint (single-sourced
/// from [MlxLoadGate.defaults]; the budget bar's policy line renders
/// it). The old flat-floor constant is retired: there is no single
/// floor anymore, the requirement is per-checkpoint.
final int kLocalModelLoadReserveMegabytes =
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
  /// [MlxLoadGate.requiredMegabytes], verbatim:
  ///
  /// - `fitsNow`: available ≥ weights×(1+slack) + reserve — the same
  ///   fact `MlxLoadGate.evaluate(weightsBytes:)` answers.
  /// - `neverFits`: the requirement exceeds the sensed total — no
  ///   amount of closing tabs makes the machine hold it.
  /// - [missingMegabytes]: how much more AVAILABLE memory the fit
  ///   still needs (0 when it fits; null only with unknown facts).
  factory LocalModelFit.evaluate({
    required final int? availableMegabytes,
    required final int? totalMegabytes,
    required final int weightsBytes,
  }) {
    final required = MlxLoadGate.defaults.requiredMegabytes(weightsBytes);
    final available = availableMegabytes;
    if (available == null) return const LocalModelFit.unknown();
    final total = totalMegabytes;
    final never = total != null && required > total;
    final missing = math.max(0, required - available);
    return LocalModelFit._(
      unknown: false,
      fitsNow: available >= required,
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

  /// Available memory covers the size-aware requirement right now —
  /// the load gate would not refuse this checkpoint on today's memory.
  final bool fitsNow;

  /// The machine cannot hold the requirement even at its total —
  /// closing apps changes nothing.
  final bool neverFits;

  /// The full size-aware requirement (weights + slack + reserve), in
  /// MB — the gate's own number, not a UI-side approximation. Null only
  /// with unknown facts.
  final int? requiredMegabytes;

  /// The sensed AVAILABLE memory the verdict used (MB), verbatim from
  /// the facts. Null only with unknown facts.
  final int? availableMegabytes;

  /// The sensed total memory (MB), verbatim from the facts; null when
  /// the sensor could not see the total (`neverFits` then stays false —
  /// an unseen total never convicts a machine).
  final int? totalMegabytes;

  /// How much more AVAILABLE memory the fit needs, in MB (0 when it
  /// fits now). The "needs X more" chip renders this through
  /// `formatModelBytes`.
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
