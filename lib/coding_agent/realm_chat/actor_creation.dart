/// ADR 0023 §1a — THE one actor-identity creation mechanism.
///
/// Humans mint actors from Settings (the Grok-bot shape: pick a name and
/// a brain, and a peer appears), and internal actors mint actors while
/// spawning — both land here, so an identity is the same kind of object
/// whoever mints it: a roster [ActorProfile] (kernel doc, mesh-synced)
/// plus a durable `realm_actors` record in the world.
///
/// Editing lives on the same seam ([updateActorIdentity]): a profile is
/// an immutable value, so an edit is a new profile upserted over the same
/// id plus a re-registration — ONE mechanism, both edit surfaces (the
/// context column's actor panel and the Settings actors pane).
library;

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

/// Raised when an edit names an actor the roster does not know — the
/// named refusal (never an implicit mint of a dead id).
final class UnknownActorException implements Exception {
  const UnknownActorException(this.actorId);

  final String actorId;

  @override
  String toString() => 'unknown_actor:$actorId';
}

/// Mints one actor identity: roster profile + world registration.
///
/// Idempotent in the world (registration is keyed by actor id); the
/// roster id dedupe lives in [ActorRoster.newActorId].
Future<ActorProfile> createActorIdentity({
  required ActorRoster roster,
  required RealmWorld world,
  required String displayName,
  required ActorKind kind,
  required String brainRef,
  String role = '',
  String systemPrompt = '',
}) async {
  final profile = ActorProfile(
    actorId: roster.newActorId(displayName),
    displayName: displayName,
    kind: kind,
    brainRef: brainRef,
    role: role,
    systemPrompt: systemPrompt,
  );
  roster.upsert(profile);
  await world.registerActor(
    profile.actorId,
    displayName: profile.displayName,
    actorKind: profile.kind.name,
    brainRef: profile.brainRef,
    role: profile.role,
    systemPrompt: profile.systemPrompt,
  );
  return profile;
}

/// Edits one actor identity in place: a new [ActorProfile] upserted over
/// the SAME [actorId] (identity is stable; values change) plus a
/// re-registration of the durable world record, which a fresh process
/// adopts at start (the world is the identity, ADR 0025).
///
/// A null field keeps today's value; an empty string clears it (the
/// persona may be deliberately emptied). [displayName] must stay
/// non-empty — a blank name is refused, never silently ignored. Throws
/// [UnknownActorException] for an unknown [actorId]: the caller edits a
/// dead id, and the world refuses to mint one implicitly.
///
/// The live bot loop rebuild is the caller's job ([RealmBotHost.syncBots]
/// through `RealmChatService`).
Future<ActorProfile> updateActorIdentity({
  required ActorRoster roster,
  required RealmWorld world,
  required String actorId,
  String? displayName,
  String? role,
  String? systemPrompt,
  String? brainRef,
}) async {
  final current = roster.get(actorId);
  if (current == null) {
    throw UnknownActorException(actorId);
  }
  final name = displayName?.trim() ?? '';
  final updated = ActorProfile(
    actorId: current.actorId,
    displayName: name.isNotEmpty ? name : current.displayName,
    kind: current.kind,
    brainRef: brainRef?.trim() ?? current.brainRef,
    role: role?.trim() ?? current.role,
    systemPrompt: systemPrompt ?? current.systemPrompt,
  );
  roster.upsert(updated);
  await world.registerActor(
    updated.actorId,
    displayName: updated.displayName,
    actorKind: updated.kind.name,
    brainRef: updated.brainRef,
    role: updated.role,
    systemPrompt: updated.systemPrompt,
  );
  return updated;
}

/// Removes an actor identity from the roster. The world record stays
/// (durable participants are never erased by a roster edit); a stopped
/// bot loop is the caller's job ([RealmBotHost]).
void removeActorIdentity(ActorRoster roster, String actorId) {
  roster.remove(actorId);
}
