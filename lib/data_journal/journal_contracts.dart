/// The journal's DATA CONTRACTS — the row shapes other layers fold
/// without importing the service. The projection law's interface leg
/// (ARCHITECTURE.md, the scheduled inversion, applied): `ecs_world/`
/// consumes these value types, never `WorldStateService` itself —
/// realm publishes state; the fold folds the contract.
library;

import 'package:meta/meta.dart';

/// One actor's newest tool-loop telemetry (the cache/spend read model,
/// leg B §2.3d — the journal already carries it).
@immutable
final class ActorTelemetry {
  const ActorTelemetry({
    required this.actorId,
    required this.rounds,
    required this.promptTokens,
    required this.cachedTokens,
    required this.stalled,
    this.toolCalls = 0,
    this.completionTokens = 0,
    this.promptChars = 0,
    this.appliedWrites = 0,
    this.escalatedFrom,
    this.at,
  });

  final String actorId;
  final int rounds;
  final int promptTokens;
  final int cachedTokens;
  final bool stalled;

  /// ADR 0122 — the rung this dispatch ESCALATED FROM: the daemon
  /// records the flattened tag on the promoted run's telemetry row, so
  /// the world can narrate its own decision ("X stalled → tried Y").
  /// Null = this run was not a promotion.
  final String? escalatedFrom;

  /// The rest of the journal row (0b — the inline work texture): the
  /// loop's per-dispatch counts. The journal carries them; the old
  /// projection discarded them and the work cards starved.
  final int toolCalls;
  final int completionTokens;
  final int promptChars;
  final int appliedWrites;
  final String? at;

  /// Cached-token share of the prompt (ADR 0122's hit-rate), null when
  /// the dispatch measured no prompt tokens.
  double? get cacheHitRate =>
      promptTokens <= 0 ? null : cachedTokens / promptTokens;
}
