/// ADR 0007 §2 — presence: the small dot that says an actor is live.
///
/// Presence is DATA, derived by callers — never computed here. An actor
/// is online when its bot listener loop is running
/// (`RealmBotHost.statuses[actorId] == 'listening'`) or its
/// `realm_actors.lastSeenAt` is recent; the caller folds that into one
/// bool and hands it to [PresenceDot]. The dot renders the bool it is
/// given — nothing more, nothing networked.
///
/// Widget keys are the agent's UI contract (DESIGN §6): a caller that
/// places a dot for a known actor keys it
/// `ValueKey('actor.presence.<actorId>')`.
library;

import 'package:flutter/material.dart';

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
        online ? kActorPresenceOnline : Theme.of(context).colorScheme.outline;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
