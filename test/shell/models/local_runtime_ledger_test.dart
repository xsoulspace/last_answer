/// The local runtime ledger (2026-11-18 v3) — the generation
/// observation the models surface reads for its realtime lane.
///
/// Under test: a run flips the cast to generating and keeps the last
/// stats visible; an end lands the ≈speed (tokens over the awaited
/// wall time); a failure names its reason verbatim WITHOUT un-knowing
/// the last speed; a begin-less end/fail is ignored (the ledger never
/// invents a run it did not see start); the bare-default alias lookup
/// answers through [LocalRuntimeLedger.runForAny].
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/ui_models/local_models_state.dart';
import 'package:lastanswer/ui_models/local_runtime_ledger.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

void main() {
  // The singleton is app-global; the tests use distinct cast names so
  // they never answer for each other.
  final ledger = LocalRuntimeLedger.instance;

  test('beginRun flips the cast to generating and keeps the last stats '
      'visible while the next decode warms up', () {
    expect(ledger.runFor('ledger-a'), isNull);
    expect(ledger.isGenerating('ledger-a'), isFalse);

    ledger
      ..beginRun('ledger-a')
      ..endRun('ledger-a', tokens: 40, elapsed: const Duration(seconds: 2));

    ledger.beginRun('ledger-a');
    final run = ledger.runFor('ledger-a');
    expect(run?.running, isTrue);
    // The previous speed did NOT blink off.
    expect(run?.lastTokensPerSecond, closeTo(20, 0.01));
  });

  test('endRun lands the approximate speed; a begin-less end is '
      'ignored', () {
    ledger.endRun('ledger-b', tokens: 10, elapsed: const Duration(seconds: 1));
    expect(ledger.runFor('ledger-b'), isNull);

    ledger.beginRun('ledger-b');
    ledger.endRun('ledger-b', tokens: 30, elapsed: const Duration(seconds: 3));
    final run = ledger.runFor('ledger-b');
    expect(run?.running, isFalse);
    expect(run?.lastTokensPerSecond, closeTo(10, 0.01));
    expect(run?.lastEndedAt, isNotNull);
    expect(run?.lastError, isNull);
  });

  test('failRun names the reason verbatim (truncated at 140) and keeps '
      'the last speed', () {
    ledger
      ..beginRun('ledger-c')
      ..endRun('ledger-c', tokens: 20, elapsed: const Duration(seconds: 1));

    ledger
      ..beginRun('ledger-c')
      ..failRun('ledger-c', 'native_engine · mlx status -971');
    final run = ledger.runFor('ledger-c');
    expect(run?.running, isFalse);
    expect(run?.lastError, 'native_engine · mlx status -971');
    expect(run?.lastTokensPerSecond, closeTo(20, 0.01));

    final long = 'x' * 200;
    ledger
      ..beginRun('ledger-c')
      ..failRun('ledger-c', long);
    final truncated = ledger.runFor('ledger-c')?.lastError;
    expect(truncated?.length, 141); // 140 + the ellipsis
    expect(truncated?.endsWith('…'), isTrue);
  });

  test('runForAny answers the first candidate cast with a record, and '
      'the catalog alias map matches the bare default qwen cast', () {
    ledger
      ..beginRun('qwen')
      ..endRun('qwen', tokens: 12, elapsed: const Duration(seconds: 1));

    expect(ledger.runForAny(const ['qwen3-0.6b', 'qwen']), isNotNull);
    expect(ledger.runForAny(const ['lfm']), isNull);

    // The default catalog entry resolves to BOTH the stripped ref and
    // the bare alias — the row reads its activity through that list.
    expect(
      localCastsForEntry(
        const MlxModelCatalogEntry(
          repoId: 'mlx-community/Qwen3-0.6B-4bit',
          label: 'Qwen3 0.6B',
          family: 'qwen3',
          paramLabel: '0.6B',
          quant: '4bit',
          approxDownloadBytes: 400 * 1024 * 1024,
        ),
      ),
      ['qwen3-0.6b-4bit', 'qwen3-0.6b', 'qwen'],
    );
  });

  test('approxTokens is the ~4-chars-per-token estimate, floored at 1', () {
    expect(approxTokens(''), 1);
    expect(approxTokens('ab'), 1);
    expect(approxTokens('a' * 8), 2);
  });
}
