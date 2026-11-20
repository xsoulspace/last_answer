/// The local-model memory budget surface (2026-11-18, the storage-bar
/// grammar — macOS System Settings) — v3.3: the bar is Activity
/// Monitor's own decomposition, in Apple's categories, on the
/// owner-calibrated identity (total = working set + file cache + free,
/// ±1%). ONE animated segmented bar + legend as the "Local models"
/// section's lead: the WORKING SET chunk (anonymous + wired +
/// compressor — Activity Monitor's App/Wired/Compressed) with each
/// LOADED MODEL carved out as its own labeled accent segment
/// (tap-through selects that model's row, a generating model pulses),
/// then the RECLAIMABLE CACHE (file-backed — "Cached Files") and FREE
/// pages. No invented segment: the load policy is not observed memory —
/// it renders as the policy line under the bar ("load policy keeps X
/// for the system — available for local loads Y"), never as a colored
/// chunk (2026-11-20: the flat 4 GB floor became the size-aware law —
/// weights×(1+slack) + reserve — so the line names the fixed RESERVE).
///
/// Motion is encode-only: a segment's width animates its transition (a
/// load sweeps in, an unload drains out) and the pulse says "decoding
/// right now" — nothing decorates.
///
/// The per-row fit verdict rides the SAME arithmetic
/// (`memory_budget.dart`, basis = cache + free); the bar explains why a
/// LOAD would refuse. Install/Delete stay disk verbs and keep working —
/// disk is not RAM.
///
/// Kit-only paint (DESIGN.md v6 component-carrier law): flat
/// [ColoredBox] segments like the kit's own [LaProgress] grammar — no
/// Material, no decoration beyond the segment fills. Facts null degrade
/// to the honest unknown line; a sensor without the modern vm_stat rows
/// degrades to the proportional-of-available bar with its own note —
/// the surface never invents a segment it cannot see.
library;

import 'dart:math' as math;

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_models/local_models_state.dart';
import 'package:lastanswer/ui_models/memory_budget.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// One loaded model's bar segment data: the cast (the segment key and
/// the tap-through identity), the display label (the legend), and the
/// approximate residency the segment is drawn to (the catalog's
/// download bytes — the same approximation the fit verdict rides).
final class LoadedModelSegment {
  const LoadedModelSegment({
    required this.cast,
    required this.label,
    required this.approxBytes,
    this.generating = false,
  });

  final String cast;
  final String label;
  final int approxBytes;

  /// A run in flight (the ledger's answer) — the segment pulses.
  final bool generating;

  /// The segment's residency in whole MB, rounded UP (a partial
  /// megabyte occupies a whole one once resident).
  int get megabytes => (approxBytes / (1024 * 1024)).ceil();
}

/// One bar chunk: the key (test + identity), the whole-MB draw size,
/// the fill color, the pulse (a generating model), and the tap-through.
typedef _BudgetSegment =
    ({
      Key? key,
      int mb,
      Color color,
      bool generating,
      VoidCallback? onTap,
      String? semanticsLabel,
    });

/// The segmented budget bar + legend over one sensed [MemoryFacts].
final class MemoryBudgetBar extends StatelessWidget {
  const MemoryBudgetBar({
    required this.facts,
    this.loaded = const <LoadedModelSegment>[],
    this.onModelTap,
    super.key,
  });

  /// The freshest facts the state read (null: sensor absent /
  /// non-macOS — the degraded line, never a stale bar).
  final MemoryFacts? facts;

  /// The loaded models, in row order (the lens maps the state + the
  /// ledger into these).
  final List<LoadedModelSegment> loaded;

  /// Tap-through: a model segment selects that model's row.
  final ValueChanged<String>? onModelTap;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final l10n = context.l10n;
    final current = facts;
    if (current == null) {
      // The sensor-absent law: the load gate itself runs sensor-absent
      // (unknown facts allow), so the UI names that instead of drawing
      // a bar from nothing.
      return Text(
        key: const ValueKey('models.local.budget.unknown'),
        l10n.modelsBudgetUnknown,
        style: LaTokens.mono(10, la.inkQuiet),
      );
    }
    final reserve = kLocalModelLoadReserveMegabytes;
    const mib = 1024 * 1024;
    final cached = current.cachedMegabytes ?? 0;
    final free = current.freeMegabytes;
    // The weights budget: available minus the fixed reserve — a model's
    // size-aware requirement spends this on weights×(1+slack) (the
    // 2026-11-20 one-math law; there is no flat floor anymore).
    final availableForWeights =
        math.max(0, current.availableMegabytes - reserve);
    // The observed working set; a legacy sensor (no anonymous row)
    // falls back to the composite (total − available) and the bar says
    // so. Null on a total-less sensor too — the fallback bar scales to
    // available alone.
    final total = current.totalMegabytes;
    final used = current.usedMegabytes ?? (total == null
        ? null
        : math.max(0, total - current.availableMegabytes));

    // Carve the loaded models OUT of the working set (clamped to what
    // is actually resident — a sensor race never draws a negative
    // system). The carve is ordered, so an over-budget tail collapses
    // onto the last model rather than inventing residency.
    var remainingUsed = used ?? 0;
    final modelSegs = <({LoadedModelSegment model, int mb})>[
      for (final model in loaded)
        (() {
          final mb = math.min(model.megabytes, remainingUsed);
          remainingUsed = math.max(0, remainingUsed - mb);
          return (model: model, mb: mb);
        })(),
    ];
    final modelMbTotal = modelSegs.fold(0, (final sum, final s) => sum + s.mb);
    final systemSeg = used == null ? 0 : used - modelMbTotal;

    final segments = <_BudgetSegment>[
      if (used != null && systemSeg > 0)
        (
          key: const ValueKey('models.local.budget.seg.system'),
          mb: systemSeg,
          color: la.inkQuiet.withValues(alpha: 0.45),
          generating: false,
          onTap: null,
          semanticsLabel: null,
        ),
      for (final (:model, :mb) in modelSegs)
        if (mb > 0)
          (
            key: ValueKey('models.local.budget.seg.model.${model.cast}'),
            mb: mb,
            color: la.accent,
            generating: model.generating,
            onTap: onModelTap == null
                ? null
                : () => onModelTap!(model.cast),
            semanticsLabel: 'models.local.budget.seg.model.${model.cast}',
          ),
      // The reclaimable file cache (Activity Monitor's "Cached
      // Files") — quiet accent; and the free pages, the strongest
      // quiet accent (the actually-unallocated bucket).
      if (used != null && cached > 0)
        (
          key: const ValueKey('models.local.budget.seg.cache'),
          mb: cached,
          color: la.accent.withValues(alpha: 0.25),
          generating: false,
          onTap: null,
          semanticsLabel: null,
        ),
      if (used != null && free > 0)
        (
          key: const ValueKey('models.local.budget.seg.free'),
          mb: free,
          color: la.accent.withValues(alpha: 0.6),
          generating: false,
          onTap: null,
          semanticsLabel: null,
        ),
      // The legacy/total-less fallback: one available chunk, scaled to
      // itself — the bar exists, nothing is invented.
      if (used == null && current.availableMegabytes > 0)
        (
          key: const ValueKey('models.local.budget.seg.available'),
          mb: current.availableMegabytes,
          color: la.accent.withValues(alpha: 0.6),
          generating: false,
          onTap: null,
          semanticsLabel: null,
        ),
    ];

    final barTotal = segments.fold(0, (final sum, final s) => sum + s.mb);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A REAL bar (2026-11-18, owner screenshot law): 12px tall in a
        // rounded container the segments clip into. The segments ANIMATE
        // to their widths (a load sweeps in, an unload drains out).
        SizedBox(
          key: const ValueKey('models.local.budget.bar'),
          height: 12,
          width: double.infinity,
          child: barTotal <= 0
              ? const ColoredBox(color: Color(0x00000000))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LayoutBuilder(
                    builder: (final context, final constraints) {
                      // 2px gaps between segments; the widths animate
                      // over the usable span.
                      final gaps = (segments.length - 1) * 2;
                      final usable = math.max(0, constraints.maxWidth - gaps);
                      final children = <Widget>[];
                      for (var i = 0; i < segments.length; i++) {
                        if (i > 0) children.add(const SizedBox(width: 2));
                        final segment = segments[i];
                        children.add(
                          _AnimatedSegment(
                            key: segment.key,
                            width: segment.mb / barTotal * usable,
                            color: segment.color,
                            generating: segment.generating,
                            onTap: segment.onTap,
                            semanticsLabel: segment.semanticsLabel,
                          ),
                        );
                      }
                      // The segment run scales down AS A WHOLE (the
                      // daemon-cluster law): a mid-animation rebuild
                      // can transiently exceed the usable span (a gap
                      // disappears while widths tween) — an overflow
                      // is an error, never a layout.
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        // The height is BOUNDED here (the segments'
                        // inner infinity needs a finite parent — the
                        // invisible-bar class of bug).
                        child: SizedBox(
                          height: 12,
                          child: Row(children: children),
                        ),
                      );
                    },
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            key: const ValueKey('models.local.budget.legend'),
            spacing: 12,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // One legend entry PER chunk — the Apple-storage grammar:
              // every colored chunk names what it is (the v3 unlabeled
              // grey rest was exactly the owner's "doesn't mean
              // anything" complaint).
              if (used != null && systemSeg > 0)
                _legendEntry(
                  context,
                  keyName: 'models.local.budget.legend.system',
                  label: l10n.modelsBudgetUsed,
                  value: formatModelBytes(systemSeg * mib),
                  color: la.inkQuiet.withValues(alpha: 0.45),
                ),
              for (final (:model, :mb) in modelSegs)
                if (mb > 0)
                  _legendEntry(
                    context,
                    keyName: 'models.local.budget.legend.${model.cast}',
                    label: model.label,
                    value: '≈ ${formatModelBytes(mb * mib)}',
                    color: la.accent,
                  ),
              if (used != null && cached > 0)
                _legendEntry(
                  context,
                  keyName: 'models.local.budget.legend.cache',
                  label: l10n.modelsBudgetCached,
                  value: formatModelBytes(cached * mib),
                  color: la.accent.withValues(alpha: 0.25),
                ),
              if (used != null && free > 0)
                _legendEntry(
                  context,
                  keyName: 'models.local.budget.legend.free',
                  label: l10n.modelsBudgetFree,
                  value: formatModelBytes(free * mib),
                  color: la.accent.withValues(alpha: 0.6),
                ),
              // The congestion disclosure (2026-11-18 v3.2, the owner's
              // "the measure is incorrect"): a machine that already
              // spilled to disk must never read as uncongested.
              if ((current.swapUsedMegabytes ?? 0) >= 256)
                _legendEntry(
                  context,
                  keyName: 'models.local.budget.legend.swap',
                  label: l10n.modelsBudgetSwap,
                  value: formatModelBytes(
                    (current.swapUsedMegabytes ?? 0) * mib,
                  ),
                  color: la.danger,
                ),
            ],
          ),
        ),
        // The POLICY line (v3.3: the floor left the bar — a load-gate
        // target is not a region of RAM; 2026-11-20: the flat floor
        // became the size-aware law, so the line names the fixed
        // RESERVE — the weights spend the rest under the slack): the
        // gate's headroom target + today's actionable answer,
        // caution-colored when nothing fits.
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            key: const ValueKey('models.local.budget.policy'),
            l10n.modelsBudgetPolicy(
              formatModelBytes(reserve * mib),
              formatModelBytes(availableForWeights * mib),
            ),
            style: LaTokens.mono(
              10,
              availableForWeights > 0 ? la.inkMuted : la.caution,
            ),
          ),
        ),
        // The pressure note rides the swap fact — one quiet caution
        // line, never a second alarm per row.
        if ((current.swapUsedMegabytes ?? 0) >= 256)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              key: const ValueKey('models.local.budget.swap'),
              l10n.modelsBudgetSwapNote,
              style: LaTokens.mono(10, la.caution),
            ),
          ),
        // The legacy sensor's honest note: the bar scaled to available
        // alone, nothing invented for the unseen buckets.
        if (used == null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              key: const ValueKey('models.local.budget.totalUnknown'),
              l10n.modelsBudgetTotalUnknown,
              style: LaTokens.mono(10, la.inkQuiet),
            ),
          ),
      ],
    );
  }

  Widget _legendEntry(
    final BuildContext context, {
    required final String keyName,
    required final String label,
    required final String value,
    required final Color color,
  }) => Row(
    key: ValueKey(keyName),
    mainAxisSize: MainAxisSize.min,
    children: [
      ColoredBox(
        color: color,
        child: const SizedBox(width: 6, height: 6),
      ),
      const SizedBox(width: 4),
      Text('$label $value', style: LaTokens.mono(10, context.la.inkMuted)),
    ],
  );
}

/// One segment at its animated width: the fill sweeps to its new share
/// (a load grows the model's chunk out of the system's; an unload
/// drains it back), a generating model's fill pulses, and a model
/// segment taps through to its row.
final class _AnimatedSegment extends StatelessWidget {
  const _AnimatedSegment({
    required this.width,
    required this.color,
    required this.generating,
    required this.onTap,
    required this.semanticsLabel,
    super.key,
  });

  final double width;
  final Color color;
  final bool generating;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(final BuildContext context) {
    final fill = generating
        ? _PulsingBox(color: color)
        : ColoredBox(color: color);
    final sized = TweenAnimationBuilder<double>(
      tween: Tween(end: math.max(0, width)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (final context, final value, final child) => SizedBox(
        width: value,
        // The Row's full height: a loose height under a ColoredBox
        // with no child collapses to ZERO — the invisible-bar class
        // of bug, caught by the tap test.
        height: double.infinity,
        child: child,
      ),
      child: fill,
    );
    if (onTap == null) return sized;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: sized,
      ),
    );
  }
}

/// The encoding pulse: a decoding model's segment breathes between its
/// full fill and a quieter one — activity made visible, nothing else.
final class _PulsingBox extends StatefulWidget {
  const _PulsingBox({required this.color});

  final Color color;

  @override
  State<_PulsingBox> createState() => _PulsingBoxState();
}

final class _PulsingBoxState extends State<_PulsingBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 1,
    end: 0.55,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: ColoredBox(color: widget.color),
  );
}
