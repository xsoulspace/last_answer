/// ADR 0007 §2 — presence: the small dot that says an actor is live.
///
/// Presence is DATA, derived by callers — never computed here. An actor
/// is online when its bot listener loop is running
/// (`RealmBotHost.statuses[actorId] == 'listening'`) or its
/// `realm_actors.lastSeenAt` is recent; the caller folds that into one
/// bool and hands it to [PresenceDot]. The dot renders the bool it is
/// given — nothing more, nothing networked.
///
/// The ACTOR STATUS fold (the manager's triage, 2026-11-18) lives in
/// the same law: one pure derivation over the facts the service and the
/// world already hold — [deriveActorPresence] folds retirement,
/// narration, the bot status string and the running-task count into ONE
/// [ActorPresenceStatus]; [ActorStatusMark] renders the verdict as a
/// dot. Every surface (the Actors manager, the rooms column, the info
/// surface) folds through the same function, so one actor reads as one
/// status everywhere.
///
/// Widget keys are the agent's UI contract (DESIGN §6): a caller that
/// places a dot for a known actor keys it
/// `ValueKey('actor.presence.<actorId>')`; a status mark rides
/// `ValueKey('actor.status.<actorId>')`.
library;

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:la_ui/la_ui.dart';
import 'package:lastanswer/journal/realm_bot_host.dart';

/// One actor's folded work state — the manager's triage vocabulary.
///
/// - [working]: the reply cycle is live (thinking/generating) or at
///   least one durable task is addressed to the actor — WORK exists.
/// - [idle]: awake and quiet (the listening normal, an idle narration,
///   or the bot host's own idle status) — the actor answers.
/// - [failed]: the last cycle failed (the narration or the bot status
///   says so).
/// - [retired]: the durable row carries the retirement marks (ADR 0120)
///   — wins over everything, a retired actor answers nothing.
/// - [absent]: no foldable fact — no mark renders at all (honest
///   absence, never an invented state; humans fold here).
enum ActorPresenceStatus { working, idle, failed, retired, absent }

/// The ONE status fold (the derive law: data folded once, rendered
/// dumb). Precedence, highest first: retirement → running tasks → the
/// narration cycle → the bot status string → honest absence. A failed
/// narration under a running task reads WORKING — the task exists; the
/// failure line rides the narration beside the mark, never instead of
/// it.
ActorPresenceStatus deriveActorPresence({
  final bool retired = false,
  final String? botStatus,
  final BotNarrationState? narration,
  final int runningTasks = 0,
}) {
  if (retired) return ActorPresenceStatus.retired;
  if (runningTasks > 0) return ActorPresenceStatus.working;
  switch (narration) {
    case BotNarrationState.thinking:
    case BotNarrationState.generating:
      return ActorPresenceStatus.working;
    case BotNarrationState.failed:
      return ActorPresenceStatus.failed;
    case BotNarrationState.idle:
    case BotNarrationState.listening:
    case BotNarrationState.droppedEcho:
    case null:
      break;
  }
  final status = botStatus;
  if (status != null && status.startsWith('failed')) {
    return ActorPresenceStatus.failed;
  }
  // A quiet narration is a LIVE worker's fact (idle/listening/droppedEcho
  // are written only by a running loop) — it reads idle on its own; the
  // bot status string says the same for a loop the host still tracks.
  if (narration != null) return ActorPresenceStatus.idle;
  if (status == 'listening' || status == 'idle') {
    return ActorPresenceStatus.idle;
  }
  return ActorPresenceStatus.absent;
}

/// The online color — one restrained green across light and dark
/// surfaces, so a live actor reads the same everywhere. Deep, not
/// neon: liveness is data, not decoration.
const Color kActorPresenceOnline = Color(0xFF1F7A46);

/// The small presence dot: green when [online], the theme's quiet
/// outline gray otherwise. Discord-scale — drop it on an avatar corner
/// or beside a gutter label.
final class PresenceDot extends StatelessWidget {
  const PresenceDot({required this.online, this.size = 8, super.key});

  /// Whether the actor is live (bot loop listening, or a recent
  /// `lastSeenAt`) — derived by the caller, never guessed here.
  final bool online;

  /// Dot diameter; the caller keys the dot when it stands for an actor.
  final double size;

  @override
  Widget build(final BuildContext context) {
    final color =
        online ? kActorPresenceOnline : context.laUi.inkQuiet;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// The folded status mark: one restrained dot per [ActorPresenceStatus]
/// — accent for working, the presence green for idle, danger for
/// failed. Retired and absent render NOTHING: a retired row carries its
/// own verbatim text mark (the retirement law), and absence is never a
/// decoration. The word rides the narration line beside the dot, never
/// inside it — the mark is the glance, the line is the fact.
final class ActorStatusMark extends StatelessWidget {
  const ActorStatusMark({required this.status, this.size = 7, super.key});

  /// The folded verdict — [deriveActorPresence] is the only derivation.
  final ActorPresenceStatus status;

  /// Dot diameter; the caller keys the mark for its actor
  /// (`actor.status.<actorId>`).
  final double size;

  @override
  Widget build(final BuildContext context) {
    final Color? color = switch (status) {
      ActorPresenceStatus.working => context.la.accent,
      ActorPresenceStatus.idle => kActorPresenceOnline,
      ActorPresenceStatus.failed => context.la.danger,
      ActorPresenceStatus.retired || ActorPresenceStatus.absent => null,
    };
    if (color == null) return const SizedBox.shrink();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
