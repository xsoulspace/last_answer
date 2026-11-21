/// The ACTOR STATUS context fold (the manager's triage, 2026-11-18):
/// the one caller-side seam over [deriveActorPresence] — it gathers the
/// facts from where they live ([RealmChatService] for retirement,
/// narration and the bot statuses; [WorldStateService] for the running
/// durable tasks) and folds them into the ONE verdict. Every surface
/// that marks an actor's status rides this function, never its own
/// re-derivation — one actor reads as one status everywhere.
///
/// A null [world] simply contributes zero running tasks (hermetic
/// hosts) — honest absence, never a guess.
library;

import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/ui_chat/actor_presence.dart';

/// Folds [actorId]'s status from the live service (retirement,
/// narration, bot statuses) and the world's durable tasks.
ActorPresenceStatus presenceStatusOf(
  final RealmChatService service,
  final String actorId, {
  final WorldStateService? world,
}) {
  var running = 0;
  if (world != null) {
    for (final task in world.tasks) {
      if (!task.terminal && task.addressees.contains(actorId)) running++;
    }
  }
  return deriveActorPresence(
    retired: service.retiredInfo(actorId) != null,
    botStatus: service.bots?.statuses[actorId],
    narration: service.botNarration[actorId]?.state,
    runningTasks: running,
  );
}

/// The count of RUNNING durable tasks addressed to [actorId] — the
/// "is my cast busy" fact the people rows have spoken since 1b, now
/// shared (the manager rows and the info surface's Now section speak
/// the same number).
int runningTasksOf(final WorldStateService? world, final String actorId) {
  if (world == null) return 0;
  var running = 0;
  for (final task in world.tasks) {
    if (!task.terminal && task.addressees.contains(actorId)) running++;
  }
  return running;
}
