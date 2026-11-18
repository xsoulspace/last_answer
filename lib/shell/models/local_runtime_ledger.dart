/// The local runtime's observation ledger (2026-11-18 redesign v3) —
/// the per-cast generation activity the models surface reads for its
/// "health in realtime" lane: what is generating RIGHT NOW, the last
/// run's approximate decode speed, and the last failure verbatim.
///
/// The seam is deliberately LA-side and thin: `_LocalCastBrain.generate`
/// (the only caller of the engine isolate's host) wraps its await with
/// [beginRun]/[endRun]/[failRun] — zero engine change, zero isolate
/// plumbing. Speeds are APPROXIMATE (the reply text rides no token
/// count, so tokens are the ~4-chars-per-token estimate in
/// [approxTokens]); the UI renders them with the "≈" that honesty
/// requires. Load/unload residency is NOT here — that is
/// `LocalModelsState`'s law over the dylib registry; this ledger only
/// carries the runs between loads.
///
/// A global singleton on purpose: the brain runs anywhere in the app
/// (bot hosts, chat lanes), and the models pane is just one reader. It
/// extends [ChangeNotifier] so panes subscribe; every mutation
/// notifies.
library;

import 'package:flutter/foundation.dart';

/// The approximate token count of a decoded reply: ~4 characters per
/// English token, floored at 1. An ESTIMATE by construction — the
/// native engine's own counter never crossed the FFI.
int approxTokens(final String text) {
  final tokens = (text.length / 4).ceil();
  return tokens < 1 ? 1 : tokens;
}

/// One cast's generation record: whether a run is in flight RIGHT NOW
/// and the last finished run's stats. `lastTokensPerSecond` is the
/// approximate decode speed (null until one run has finished — a model
/// that never generated claims no speed).
final class LocalModelRun {
  const LocalModelRun({
    required this.cast,
    this.startedAt,
    this.lastEndedAt,
    this.lastTokens,
    this.lastDuration,
    this.lastError,
  });

  /// The cast name (the brain-side key after `local:` — `qwen`, `lfm`,
  /// or a variant ref like `qwen3.5-0.8b`).
  final String cast;

  /// When the in-flight run began; null when idle. A run whose brain
  /// died without an end/fail answer never claims speed — the UI reads
  /// a stuck "generating" only while the await is genuinely parked.
  final DateTime? startedAt;

  /// The last finished (or failed) run's end wall time.
  final DateTime? lastEndedAt;

  /// The last run's estimated token count; null until one finished.
  final int? lastTokens;

  /// The last run's wall duration (attach + prefill + decode — the
  /// whole awaited generate, honestly coarser than decode-only).
  final Duration? lastDuration;

  /// The last failure's short reason (code-first, message truncated —
  /// the same diagnosability law the bot narration rides). Null when
  /// the last run succeeded.
  final String? lastError;

  /// Whether a run is in flight.
  bool get running => startedAt != null;

  /// The last run's approximate decode speed, or null before the first
  /// finished run.
  double? get lastTokensPerSecond {
    final tokens = lastTokens;
    final duration = lastDuration;
    if (tokens == null || duration == null) return null;
    final seconds = duration.inMicroseconds / 1e6;
    if (seconds <= 0) return null;
    return tokens / seconds;
  }
}

/// The generation ledger over every local cast (see the library docs).
final class LocalRuntimeLedger extends ChangeNotifier {
  LocalRuntimeLedger._();

  static final LocalRuntimeLedger instance = LocalRuntimeLedger._();

  final Map<String, LocalModelRun> _runs = <String, LocalModelRun>{};

  /// One cast's record, or null when the cast never generated.
  LocalModelRun? runFor(final String cast) => _runs[cast];

  /// Whether the cast has a run in flight.
  bool isGenerating(final String cast) => _runs[cast]?.running ?? false;

  /// The first cast's record in [casts] with one, or null — the row
  /// lookup over a catalog entry's candidate casts (a variant ref and
  /// the bare default `qwen` alias).
  LocalModelRun? runForAny(final List<String> casts) {
    for (final cast in casts) {
      final run = _runs[cast];
      if (run != null) return run;
    }
    return null;
  }

  /// A run begins: the cast flips to generating. The last finished
  /// run's stats ride along (the row keeps showing the previous speed
  /// while the next decode warms up — dropping them would blink the
  /// honest number off).
  void beginRun(final String cast) {
    if (cast.isEmpty) return;
    final previous = _runs[cast];
    _runs[cast] = LocalModelRun(
      cast: cast,
      startedAt: DateTime.now(),
      lastEndedAt: previous?.lastEndedAt,
      lastTokens: previous?.lastTokens,
      lastDuration: previous?.lastDuration,
      lastError: previous?.lastError,
    );
    _notify();
  }

  /// The run finished: tokens (estimated) and the awaited duration
  /// land as the cast's new "last". A begin-less end is ignored — the
  /// ledger never invents a run it did not see start.
  void endRun(
    final String cast, {
    required final int tokens,
    required final Duration elapsed,
  }) {
    final previous = _runs[cast];
    if (previous == null || !previous.running) return;
    _runs[cast] = LocalModelRun(
      cast: cast,
      lastEndedAt: DateTime.now(),
      lastTokens: tokens,
      lastDuration: elapsed,
    );
    _notify();
  }

  /// The run failed: the short reason lands verbatim-rendered, the
  /// last successful stats stay (a failure does not un-know the last
  /// speed). Same begin-less honesty as [endRun].
  void failRun(final String cast, final String reason) {
    final previous = _runs[cast];
    if (previous == null || !previous.running) return;
    _runs[cast] = LocalModelRun(
      cast: cast,
      lastEndedAt: DateTime.now(),
      lastTokens: previous.lastTokens,
      lastDuration: previous.lastDuration,
      lastError: reason.length <= 140 ? reason : '${reason.substring(0, 140)}…',
    );
    _notify();
  }

  void _notify() {
    if (hasListeners) notifyListeners();
  }
}
