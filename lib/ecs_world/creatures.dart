/// Creatures IN LaWorld (3d) — DESIGN.md v2's "calm chrome, living
/// creatures" law, grown on the projection's own entities.
///
/// The la_world.dart doc reserves exactly this layer: Species/Mood/Blink
/// components attach to [ActorRow] entities — one world, two read
/// disciplines (UI selectors, simulation systems). The mechanism law
/// chosen here (and why): LaWorld has NO widget-tree loop host, so the
/// creature layer splits honestly in two —
///
/// 1. discrete STATE (species, mood) lives HERE as components on the
///    actor entities, re-derived by pure functions from journal facts
///    on every `put*` and on [LaWorld.refreshCreatures]; state changes
///    ride the existing `commitBatch` notification, never a per-frame
///    one (the selector discipline of la_world_test stays intact);
/// 2. per-frame MOTION (blink, hop, droop pose math) lives in the
///    widget-local controllers of `lib/ui/creature_mark.dart` — no
///    EcsFixedStepLoop is hosted, because a fixed-step simulation that
///    only feeds paint poses would either notify selectors per frame
///    (breaking the rebuild law) or duplicate what an
///    AnimationController already does under reduced-motion gating.
///
/// THE DERIVE LAW (DESIGN v2): a creature's state is world truth, never
/// decorative fiction. [deriveCreatureMood] reads ONLY honest facts —
/// the bot narration state (`BotNarrationState.name` strings folded in
/// by the UI via [LaWorld.refreshCreatures]; the loop says so, the
/// creature never invents), the actor's non-terminal addressed tasks,
/// the newest telemetry's `stalled` flag, a RECENT succeeded terminal
/// (the celebration window), and the daemon's liveness (the world
/// creature sleeps only when the daemon is down). Precedence: asleep >
/// sad > worried > focused > celebrating > calm — a fact closer to the
/// actor's own distress outranks the world's ambient state.
library;

import 'package:ecsly/ecsly.dart';

/// FNV-1a, 32-bit — the SAME byte-stable hash actor_avatar.dart uses
/// for the identicon (mirrored here because it is private there; never
/// [String.hashCode], which Dart randomizes per process). Species must
/// be deterministic from the actor id, on every device and session.
int creatureHash(final String s) {
  var h = 0x811c9dc5;
  for (var i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

/// The six shape families of the identicon (triad, diamond, leaf, bars,
/// ring, peaks), promoted to SPECIES by DESIGN v2 — in the identicon
/// painter's own case order, so ordinal == variant.
enum CreatureSpecies { triad, diamond, leaf, bars, ring, peaks }

/// The honest moods a creature may carry (DESIGN v2: no invented moods,
/// no mascots that talk unasked).
enum CreatureMood {
  /// The quiet normal: awake, idle, blinking.
  calm,

  /// The loop is live (thinking/generating narration, or a running
  /// addressed task) — a steady glow, never a wiggle.
  focused,

  /// The newest telemetry says `stalled` — a droop, not a panic.
  worried,

  /// The narration cycle failed — the saddest honest fact.
  sad,

  /// A terminal succeeded inside the celebration window — ONE hop
  /// (gated by reduced motion), then a raised static pose.
  celebrating,

  /// The daemon is down: the world sleeps. Only the daemon's own
  /// absence may set this.
  asleep,
}

/// The actor id of the WORLD creature (the landing-inbox greeter, the
/// status edge's daemon mark): a stable id so its species and hue are
/// as deterministic as any actor's.
const String kWorldCreatureId = 'la-world';

/// The celebration window: a succeeded terminal keeps the creature
/// celebrating for this long, then it settles back to calm on its own
/// (the hop is once; the mood is bounded — no permanent mascots).
const Duration kCelebrationWindow = Duration(minutes: 5);

/// The species of [actorId] — the SAME family the identicon's shape
/// hash picks (actor_avatar's `'$actorId\0shape'` salted rehash,
/// modulo the six families), so one actor is one creature everywhere.
CreatureSpecies speciesOf(final String actorId) =>
    CreatureSpecies.values[creatureHash('$actorId\u0000shape') % 6];

/// The blink-phase seed of [actorId]: a salted rehash so no two
/// creatures blink in lockstep (deterministic, never random per build).
int blinkSeedOf(final String actorId) => creatureHash('$actorId\u0000blink');

/// One derived mood plus the honest fact that set it (the cause rides
/// into the [Mood] component for diagnostics and Semantics — the state
/// word is the world's, never invented).
typedef MoodDerivation = ({CreatureMood mood, String cause});

/// THE DERIVE LAW, pure and unit-testable. [narrationState] is a
/// `BotNarrationState.name` string (or null — the loop's in-memory
/// fact, folded in by the UI); the rest are journal facts. Precedence:
/// asleep > sad > worried > focused > celebrating > calm.
MoodDerivation deriveCreatureMood({
  final String? narrationState,
  final bool telemetryStalled = false,
  final int runningTasks = 0,
  final bool recentlySucceeded = false,
  final bool daemonAsleep = false,
}) {
  if (daemonAsleep) return (mood: CreatureMood.asleep, cause: 'daemon-down');
  if (narrationState == 'failed') {
    return (mood: CreatureMood.sad, cause: 'narration-failed');
  }
  if (telemetryStalled) {
    return (mood: CreatureMood.worried, cause: 'telemetry-stalled');
  }
  if (narrationState == 'thinking' || narrationState == 'generating') {
    return (mood: CreatureMood.focused, cause: 'narration-$narrationState');
  }
  if (runningTasks > 0) {
    return (mood: CreatureMood.focused, cause: 'tasks-running');
  }
  if (recentlySucceeded) {
    return (mood: CreatureMood.celebrating, cause: 'task-succeeded');
  }
  return (mood: CreatureMood.calm, cause: 'quiet');
}

/// True when [at] (an ISO-8601 journal timestamp) is a real instant
/// inside the celebration window ending at [now]. Null or unparseable
/// timestamps are honestly NOT recent.
bool succeededRecently(
  final String? at,
  final DateTime now, {
  final Duration window = kCelebrationWindow,
}) {
  if (at == null || at.isEmpty) return false;
  final settled = DateTime.tryParse(at);
  if (settled == null) return false;
  final age = now.difference(settled);
  return !age.isNegative && age <= window;
}

// ---- the components (attached to ActorRow entities; see LaWorld) ----

/// The actor's species: the identicon's own shape family, fixed for
/// the entity's lifetime (identity never drifts).
final class Species extends Component {
  Species(final String actorId)
    : actorId = actorId,
      family = speciesOf(actorId);

  final String actorId;
  final CreatureSpecies family;
}

/// The actor's current honest mood — mutated in place by the derive
/// law, read by the UI on its own rebuilds. Discrete state only: no
/// phase, no per-frame field (motion is the painter's business).
final class Mood extends Component {
  Mood([this.value = CreatureMood.calm]);

  CreatureMood value;

  /// The fact that set [value] (`narration-failed`, `tasks-running`,
  /// `daemon-down`, `quiet`, …) — world truth, for diagnostics and the
  /// Semantics contract.
  String cause = 'quiet';
}

/// The actor's blink phase seed (salted id hash): creatures never blink
/// in lockstep, and the phase is deterministic per actor — the widget's
/// ticker owns the clock, this owns the offset.
final class Blink extends Component {
  Blink(final String actorId) : seed = blinkSeedOf(actorId);

  final int seed;
}
