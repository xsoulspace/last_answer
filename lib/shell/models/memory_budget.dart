/// The local-model memory budget (2026-11-18) — whether a catalog entry
/// fits the machine BEFORE any load is attempted, as pure math over the
/// sensed facts.
///
/// The disk/RAM boundary is the honesty law here: installing writes the
/// hub cache and is always allowed, but the runtime's load gate
/// (`MlxLoadGate.defaults`) refuses a weight load that would push the
/// machine below the 4 GB AVAILABLE incident floor. This file renders
/// that gate's arithmetic as a named, unit-tested verdict so the catalog
/// rows can say "fits now" / "needs X more" / "exceeds machine memory"
/// without anyone pressing Install to find out.
///
/// Pure: no I/O, no clocks — the facts come in as nullable ints exactly
/// as [MemoryFacts.current] yields them, and a null fact degrades to the
/// `unknown` verdict (an absent sensor never invents a verdict).
library;

import 'dart:math' as math;

import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// The load gate's incident floor, in MB: the AVAILABLE memory the
/// runtime refuses to dip below (single-sourced from
/// [MlxLoadGate.defaults] — the UI never re-states the number). A
/// `final`, not a `const`: Dart reads no const property off a const
/// instance, and re-stating 4096 here would be exactly the drift the
/// single-sourcing exists to prevent.
final int kLocalModelLoadFloorMegabytes =
    MlxLoadGate.defaults.minFreeMegabytes;

/// The KV-cache / runtime slack fraction the fit adds on top of the
/// weights: the load gate's own incident note names the KV cache and the
/// host app as the reason the floor exists, so the verdict reserves 25%
/// of the weights for it rather than pretending weights are the whole
/// residency.
const double kLocalModelSlackFraction = 0.25;

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

  /// The computed verdict over known facts.
  ///
  /// - `fitsNow`: weights + 25% KV/runtime slack ≤ available − floor.
  /// - `neverFits`: weights + floor > total, when the total is known —
  ///   no amount of closing tabs makes the machine hold it.
  /// - [missingMegabytes]: how much more AVAILABLE memory the fit still
  ///   needs (0 when it fits; null only with unknown facts).
  factory LocalModelFit.evaluate({
    required final int? availableMegabytes,
    required final int? totalMegabytes,
    required final int weightsBytes,
  }) {
    // Weights in MB, rounded UP (a partial megabyte still occupies a
    // whole one once resident).
    final weightsMb = (weightsBytes / (1024 * 1024)).ceil();
    final requiredMb = (weightsMb * (1 + kLocalModelSlackFraction)).ceil();
    final available = availableMegabytes;
    if (available == null) return const LocalModelFit.unknown();
    final floor = kLocalModelLoadFloorMegabytes;
    final fits = available - floor >= requiredMb;
    final total = totalMegabytes;
    final never = total != null && weightsMb + floor > total;
    final missing = math.max(0, requiredMb + floor - available);
    return LocalModelFit._(
      unknown: false,
      fitsNow: fits,
      neverFits: never,
      requiredMegabytes: requiredMb,
      availableMegabytes: available,
      totalMegabytes: total,
      missingMegabytes: missing,
    );
  }

  /// True when the facts never arrived (sensor failure, non-macOS).
  /// The other fields keep their null/false degenerate values.
  final bool unknown;

  /// Weights + slack fit under the available-minus-floor budget right
  /// now — the load gate would not refuse on today's memory.
  final bool fitsNow;

  /// The machine cannot hold the weights + floor even at its total —
  /// closing apps changes nothing.
  final bool neverFits;

  /// The MB the load actually needs: weights rounded up, plus the 25%
  /// KV/runtime slack. Null only with unknown facts.
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
/// approximation at consent time).
LocalModelFit evaluateLocalModelFit({
  required final int? availableMegabytes,
  required final int? totalMegabytes,
  required final int weightsBytes,
}) => LocalModelFit.evaluate(
  availableMegabytes: availableMegabytes,
  totalMegabytes: totalMegabytes,
  weightsBytes: weightsBytes,
);
