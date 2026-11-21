/// Local model memory budget (2026-11-18, v3.3) — the fit arithmetic
/// and the budget surfaces over CANNED facts (the shell test-lane laws:
/// hermetic machine, no sensor runs).
///
/// Under test:
/// * `evaluateLocalModelFit` — fits / unfit / never-fits / unknown with
///   real numbers, the exact boundary, the 25% slack, and the missing
///   megabytes the fit reason line renders;
/// * `MemoryBudgetBar` — the REAL bar (12px tall, separated segments)
///   as the v3.3 MAP, Activity Monitor's own decomposition: the
///   LABELED working-set chunk (anonymous + wired + compressor — the
///   v3 unlabeled grey rest was exactly the owner's "doesn't mean
///   anything" complaint), one labeled segment PER loaded model carved
///   out of it with tap-through to its row, the reclaimable cache
///   (file-backed = "Cached Files"), the free pages — and the load
///   policy as the POLICY LINE under the bar (2026-11-20: the
///   size-aware law's fixed RESERVE — a load-gate target is not a
///   region of RAM, so it draws no chunk); the legacy sensor's
///   composite fallback + honest note; the facts-null degraded line.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_models/local_models_state.dart';
import 'package:lastanswer/ui_models/memory_budget.dart';
import 'package:lastanswer/ui_models/memory_budget_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

Widget _wrap(final Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: Scaffold(body: child),
);

const mib = 1024 * 1024;
const gib = 1024 * mib;

void main() {
  group('evaluateLocalModelFit', () {
    test('a 1 GB model fits a healthy 16 GB machine, and names the '
        'numbers it used (the size-aware one-math law)', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 16384,
        totalMegabytes: 16384,
        weightsBytes: gib,
      );
      // The MODEL's rent: weights 1024 MB + 25% slack = 1280 — the
      // gate's own number, NOT carrying the machine's 1 GB pressure
      // point (owner law: the reserve is never the model's requirement).
      expect(fit.unknown, isFalse);
      expect(
        fit.requiredMegabytes,
        MlxLoadGate.defaults.requiredMegabytes(gib),
      );
      expect(fit.requiredMegabytes, 1280);
      expect(fit.fitsNow, isTrue);
      expect(fit.neverFits, isFalse);
      expect(fit.availableMegabytes, 16384);
      expect(fit.totalMegabytes, 16384);
      expect(fit.missingMegabytes, 0);
    });

    test('the exact boundary fits (available == requirement + the '
        'machine pressure point)', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 2304, // 1280 rent + 1024 pressure point
        totalMegabytes: 16384,
        weightsBytes: gib,
      );
      expect(fit.fitsNow, isTrue);
      expect(fit.missingMegabytes, 0);
    });

    test('a machine below the requirement is unfit and names how much '
        'more available memory it needs', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 2048,
        totalMegabytes: 16384,
        weightsBytes: gib,
      );
      // 2304 required − 2048 available = 256 MB short.
      expect(fit.fitsNow, isFalse);
      expect(fit.neverFits, isFalse);
      expect(fit.missingMegabytes, 256);
      // The chip's sentence: 256 MB renders whole, 1.2 GB two decimals.
      expect(formatModelBytes(256 * mib), '256 MB');
      expect(formatModelBytes(1229 * mib), '1.2 GB');
    });

    test('a SMALL checkpoint fits under pressure the old flat floor '
        'refused — the size-aware point of the 2026-11-20 law', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 2048, // far below the old 4096 floor
        totalMegabytes: 16384,
        weightsBytes: 400 * mib, // the 0.6B: 500 rent, 1548 headroom left
      );
      expect(fit.fitsNow, isTrue);
      expect(fit.requiredMegabytes, 500);
    });

    test('the requirement over the sensed total never fits, whatever '
        'is free today', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 4096,
        totalMegabytes: 6144,
        weightsBytes: (4.5 * gib).round(), // 4608 MB → 6784 required > 6144
      );
      expect(fit.neverFits, isTrue);
      expect(fit.fitsNow, isFalse);
    });

    test('an unseen total never convicts the machine (neverFits stays '
        'false), but the fit still reads honestly unfit', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 5120,
        totalMegabytes: null,
        weightsBytes: (4.5 * gib).round(),
      );
      expect(fit.unknown, isFalse);
      expect(fit.neverFits, isFalse);
      expect(fit.fitsNow, isFalse);
    });

    test('null facts degrade to the unknown verdict (no claim at all)', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: null,
        totalMegabytes: null,
        weightsBytes: gib,
      );
      expect(fit.unknown, isTrue);
      expect(fit.fitsNow, isFalse);
      expect(fit.neverFits, isFalse);
      expect(fit.requiredMegabytes, isNull);
      expect(fit.missingMegabytes, isNull);
    });

    test('fractional weights round UP (a partial megabyte still '
        'occupies a whole one once resident)', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 16384,
        totalMegabytes: 16384,
        weightsBytes: 400 * mib + 1, // 400.0000x MB → 401 MB
      );
      // 401 × 1.25 = 501.25 → 502 — the model's rent alone.
      expect(fit.requiredMegabytes, 502);
    });
  });

  group('the MemoryBudgetBar', () {
    // The owner's real machine, captured 2026-11-18 and pinned in the
    // dfp parse test: 16 GB physical, working set 13388 MB, file
    // cache 1774 MB ("Cached Files" in Activity Monitor), free+spec
    // 741 MB. Nothing fits (2515 available < the 0.6B's 1524 MB
    // requirement — the smallest requirement in the catalog).
    const calibrated = MemoryFacts(
      availableMegabytes: 2515,
      freeMegabytes: 741,
      totalMegabytes: 16384,
      usedMegabytes: 13388,
      cachedMegabytes: 1774,
    );

    testWidgets('renders the calibrated decomposition — labeled '
        'working set, reclaimable cache, free — and draws NO floor '
        'chunk (the floor is the policy line, not a region of RAM)', (
      final tester,
    ) async {
      await tester.pumpWidget(_wrap(const MemoryBudgetBar(facts: calibrated)));
      await tester.pumpAndSettle();

      final bar = find.byKey(const ValueKey('models.local.budget.bar'));
      expect(bar, findsOneWidget);
      // A REAL bar: 12px tall, not a translucent hairline the
      // screenshot cannot see.
      expect(tester.getSize(bar).height, 12);
      // The three OBSERVED buckets, keyed; no floor, no legacy
      // available chunk in the calibrated path.
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.system')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.cache')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.free')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.floor')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.available')),
        findsNothing,
      );
      // Every chunk is labeled — the Apple-storage grammar (the v3
      // unlabeled grey rest was exactly the owner's "doesn't mean
      // anything" complaint). formatModelBytes: 13388 MB → '13 GB',
      // 1774 MB → '1.7 GB', 741 MB → '741 MB'.
      expect(find.text('in use 13 GB'), findsOneWidget);
      expect(find.text('reclaimable cache 1.7 GB'), findsOneWidget);
      expect(find.text('free 741 MB'), findsOneWidget);
      // The policy line names the machine's pressure point AND
      // today's answer (2515 available − 1024 = 1491 → '1.5 GB').
      expect(
        find.text(
          'load pressure point 1.0 GB — available for local loads 1.5 GB',
        ),
        findsOneWidget,
      );
    });

    testWidgets('each loaded model owns a labeled segment carved from '
        'the working set, tap-through names its cast, and the legend '
        'names it', (final tester) async {
      final taps = <String>[];
      await tester.pumpWidget(
        _wrap(
          MemoryBudgetBar(
            facts: calibrated,
            loaded: const [
              LoadedModelSegment(
                cast: 'qwen3.5-0.8b',
                label: 'Qwen3.5 0.8B',
                approxBytes: 700 * mib,
              ),
            ],
            onModelTap: taps.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final modelSeg = find.byKey(
        const ValueKey('models.local.budget.seg.model.qwen3.5-0.8b'),
      );
      expect(modelSeg, findsOneWidget);
      // The legend entry names the model and its ≈size; the in-use
      // chunk shrank by the carve (13388 − 700 = 12688 → '12 GB' —
      // ≥10 GB renders without decimals).
      expect(
        find.byKey(const ValueKey('models.local.budget.legend.qwen3.5-0.8b')),
        findsOneWidget,
      );
      expect(find.textContaining('Qwen3.5 0.8B'), findsOneWidget);
      expect(find.text('in use 12 GB'), findsOneWidget);
      // Tap-through: the segment selects the model's row.
      await tester.tap(
        find.descendant(of: modelSeg, matching: find.byType(GestureDetector)),
      );
      expect(taps, ['qwen3.5-0.8b']);
    });

    testWidgets('a legacy sensor (no anonymous/file-backed rows) '
        'degrades to the composite working set and hides the cache '
        'chunk instead of inventing it', (final tester) async {
      const facts = MemoryFacts(
        availableMegabytes: 12288,
        freeMegabytes: 512,
        totalMegabytes: 16384,
      );
      await tester.pumpWidget(_wrap(const MemoryBudgetBar(facts: facts)));
      await tester.pumpAndSettle();

      // Composite working set: total − available = 4100 → 'in use
      // 4.0 GB'; free shows; cache stays unnamed (the sensor never
      // saw it); the total IS known, so no total-unknown note.
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.system')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.free')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.cache')),
        findsNothing,
      );
      expect(find.text('in use 4.0 GB'), findsOneWidget);
      expect(find.text('free 512 MB'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.budget.totalUnknown')),
        findsNothing,
      );
      // The healthy policy line: 12288 − 1024 = 11264 → '11 GB'.
      expect(
        find.text(
          'load pressure point 1.0 GB — available for local loads 11 GB',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a total-less sensor scales the bar to available and '
        'says so (no invented system segment)', (final tester) async {
      const facts = MemoryFacts(availableMegabytes: 6144, freeMegabytes: 0);
      await tester.pumpWidget(_wrap(const MemoryBudgetBar(facts: facts)));

      expect(
        find.byKey(const ValueKey('models.local.budget.seg.system')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.available')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.totalUnknown')),
        findsOneWidget,
      );
      expect(
        find.text(
          'load pressure point 1.0 GB — available for local loads 5.0 GB',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a swapping machine discloses it (legend + caution '
        'note) — available is never read as uncongested', (final tester) async {
      const facts = MemoryFacts(
        availableMegabytes: 3967,
        freeMegabytes: 158,
        totalMegabytes: 16384,
        usedMegabytes: 12417,
        cachedMegabytes: 1551,
        compressorMegabytes: 6131,
        swapUsedMegabytes: 7135,
      );
      await tester.pumpWidget(_wrap(const MemoryBudgetBar(facts: facts)));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('models.local.budget.legend.swap')),
        findsOneWidget,
      );
      expect(find.text('swapped to disk 7.0 GB'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('models.local.budget.swap')),
        findsOneWidget,
      );
      expect(find.textContaining('the machine is swapping'), findsOneWidget);
      // The policy line keeps the pressure point visible even when
      // the machine is short (3967 − 1024 = 2943 → '2.9 GB').
      expect(
        find.text(
          'load pressure point 1.0 GB — available for local loads 2.9 GB',
        ),
        findsOneWidget,
      );
    });

    testWidgets('null facts render only the honest degraded line', (
      final tester,
    ) async {
      await tester.pumpWidget(_wrap(const MemoryBudgetBar(facts: null)));

      expect(
        find.byKey(const ValueKey('models.local.budget.unknown')),
        findsOneWidget,
      );
      expect(
        find.text(
          'memory facts unavailable — the load gate runs sensor-absent',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.bar')),
        findsNothing,
      );
    });
  });
}
