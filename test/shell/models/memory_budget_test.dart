/// Local model memory budget (2026-11-18, v3) — the fit arithmetic and
/// the budget surfaces over CANNED facts (the shell test-lane laws:
/// hermetic machine, no sensor runs).
///
/// Under test:
/// * `evaluateLocalModelFit` — fits / unfit / never-fits / unknown with
///   real numbers, the exact boundary, the 25% slack, and the missing
///   megabytes the fit reason line renders;
/// * `MemoryBudgetBar` — the REAL bar (12px tall, separated segments)
///   as the v3 MAP: the system segment, one labeled segment PER loaded
///   model with tap-through to its row, the floor + available legend
///   (the "in use" label is gone — the system chunk is the dark
///   rest); the total-less sensor's proportional-of-available fallback
///   + honest note; the facts-null degraded line.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/local_models_state.dart';
import 'package:lastanswer/shell/models/memory_budget.dart';
import 'package:lastanswer/shell/models/memory_budget_bar.dart';
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
    test('a 1 GB model fits a healthy 16 GB machine with the floor '
        'kept, and names the numbers it used', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 16384,
        totalMegabytes: 16384,
        weightsBytes: gib,
      );
      // weights 1024 MB + 25% slack = 1280 MB required; available
      // 16384 − floor 4096 = 12288 ≥ 1280.
      expect(fit.unknown, isFalse);
      expect(fit.fitsNow, isTrue);
      expect(fit.neverFits, isFalse);
      expect(fit.requiredMegabytes, 1280);
      expect(fit.availableMegabytes, 16384);
      expect(fit.totalMegabytes, 16384);
      expect(fit.missingMegabytes, 0);
    });

    test('the exact boundary fits (required == available − floor)', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 5376, // 5376 − 4096 == 1280 == required
        totalMegabytes: 16384,
        weightsBytes: gib,
      );
      expect(fit.fitsNow, isTrue);
      expect(fit.missingMegabytes, 0);
    });

    test('a machine below the budget is unfit and names how much more '
        'available memory it needs', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 5120,
        totalMegabytes: 16384,
        weightsBytes: gib,
      );
      // 5120 − 4096 = 1024 < 1280 required → short by 1280 + 4096 −
      // 5120 = 256 MB.
      expect(fit.fitsNow, isFalse);
      expect(fit.neverFits, isFalse);
      expect(fit.missingMegabytes, 256);
      // The chip's sentence: 256 MB renders whole, 1.2 GB two decimals.
      expect(formatModelBytes(256 * mib), '256 MB');
      expect(formatModelBytes(1229 * mib), '1.2 GB');
    });

    test('weights + floor over the sensed total never fits, whatever '
        'is free today', () {
      final fit = evaluateLocalModelFit(
        availableMegabytes: 4096,
        totalMegabytes: 8192,
        weightsBytes: (4.5 * gib).round(), // 4608 MB + 4096 > 8192
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
      // 401 × 1.25 = 501.25 → 502.
      expect(fit.requiredMegabytes, 502);
    });
  });

  group('the MemoryBudgetBar', () {
    testWidgets('renders the system / floor / available segments and '
        'the legend without the dead in-use label', (final tester) async {
      const facts = MemoryFacts(
        availableMegabytes: 6144,
        freeMegabytes: 512,
        totalMegabytes: 16384,
      );
      await tester.pumpWidget(_wrap(const MemoryBudgetBar(facts: facts)));

      final bar = find.byKey(const ValueKey('models.local.budget.bar'));
      expect(bar, findsOneWidget);
      // A REAL bar: 12px tall, not a translucent hairline the
      // screenshot cannot see.
      expect(tester.getSize(bar).height, 12);
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.system')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.floor')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.available')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.legend')),
        findsOneWidget,
      );
      // The v3 fills: the dark system rest, the strong caution floor,
      // the quiet accent available.
      Color segColor(final String key) => tester
          .widget<ColoredBox>(
            find
                .descendant(
                  of: find.byKey(ValueKey(key)),
                  matching: find.byType(ColoredBox),
                )
                .first,
          )
          .color;
      expect(
        segColor('models.local.budget.seg.system').a,
        moreOrLessEquals(0.45),
      );
      expect(
        segColor('models.local.budget.seg.floor').a,
        moreOrLessEquals(0.85),
      );
      expect(
        segColor('models.local.budget.seg.available').a,
        moreOrLessEquals(0.30),
      );
      // The segments are SEPARATED (a segmented bar, not one flat
      // strip): system + gap + floor + gap + available.
      final row = tester.widget<Row>(
        find.descendant(of: bar, matching: find.byType(Row)),
      );
      expect(row.children, hasLength(5));
      // The legend names the floor + available values; "in use" is
      // GONE (the dark system chunk is the unlabeled rest).
      expect(find.text('kept free (headroom) 4.0 GB'), findsOneWidget);
      expect(find.text('available for local loads 2.0 GB'), findsOneWidget);
      expect(find.textContaining('in use'), findsNothing);
    });

    testWidgets('each loaded model owns a labeled segment, tap-through '
        'names its cast, and the legend names it', (final tester) async {
      const facts = MemoryFacts(
        availableMegabytes: 12288,
        freeMegabytes: 512,
        totalMegabytes: 16384,
      );
      final taps = <String>[];
      await tester.pumpWidget(
        _wrap(
          MemoryBudgetBar(
            facts: facts,
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
      // The legend entry names the model and its ≈size.
      expect(
        find.byKey(const ValueKey('models.local.budget.legend.qwen3.5-0.8b')),
        findsOneWidget,
      );
      expect(find.textContaining('Qwen3.5 0.8B'), findsOneWidget);
      // Tap-through: the segment selects the model's row.
      await tester.tap(
        find.descendant(of: modelSeg, matching: find.byType(GestureDetector)),
      );
      expect(taps, ['qwen3.5-0.8b']);
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
        find.byKey(const ValueKey('models.local.budget.seg.floor')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.seg.available')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('models.local.budget.totalUnknown')),
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
