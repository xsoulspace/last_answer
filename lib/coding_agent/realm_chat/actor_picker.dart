/// ADR 0024 — "message an actor": the searchable roster picker behind
/// the new-conversation menu. The rail's first-class object is the
/// ACTOR, so starting a DM means picking an identity, not naming a
/// transcript; reuse-or-create of the two-member thread is the
/// service's [RealmChatService.openDm] job.
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';

/// The actor picker: dialog content listing [actors] (the roster's
/// non-human actors) with avatar, display name and role; picking one
/// calls [onPick] (→ open a DM with them), and [onCreateActor] leads to
/// the Settings create flow. Widget keys are the agent's UI contract:
/// rows are `picker.actor.<actorId>`.
final class ActorPicker extends StatelessWidget {
  const ActorPicker({
    required this.actors,
    required this.onPick,
    required this.onCreateActor,
    super.key,
  });

  /// The roster's non-human actors — the human talks to everyone else.
  final List<ActorProfile> actors;

  /// Picking an actor opens (or reuses) the DM with them.
  final ValueChanged<ActorProfile> onPick;

  /// The create-actor affordance — minting identities lives in Settings
  /// → Agents & Models, never in the conversation (ADR 0023 §2).
  final VoidCallback onCreateActor;

  @override
  Widget build(final BuildContext context) => _ActorPickerContent(
    actors: actors,
    onPick: onPick,
    onCreateActor: onCreateActor,
  );
}

class _ActorPickerContent extends StatefulWidget {
  const _ActorPickerContent({
    required this.actors,
    required this.onPick,
    required this.onCreateActor,
  });

  final List<ActorProfile> actors;
  final ValueChanged<ActorProfile> onPick;
  final VoidCallback onCreateActor;

  @override
  State<_ActorPickerContent> createState() => _ActorPickerContentState();
}

class _ActorPickerContentState extends State<_ActorPickerContent> {
  String _query = '';

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final query = _query.trim().toLowerCase();
    final matches = [
      for (final actor in widget.actors)
        if (query.isEmpty ||
            actor.displayName.toLowerCase().contains(query) ||
            actor.role.toLowerCase().contains(query))
          actor,
    ];
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: TextField(
            key: const ValueKey('picker.search'),
            autofocus: true,
            onChanged: (final value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: l10n.worldChatSearchActors,
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Flexible(
          child: matches.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.worldChatNoMatchingActors,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: matches.length,
                  itemBuilder: (final context, final index) {
                    final actor = matches[index];
                    return ListTile(
                      key: ValueKey('picker.actor.${actor.actorId}'),
                      dense: true,
                      leading: ActorAvatar(profile: actor, size: 28),
                      title: Text(
                        actor.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: actor.role.isEmpty
                          ? null
                          : Text(
                              actor.role,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () => widget.onPick(actor),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        ListTile(
          key: const ValueKey('picker.createActor'),
          dense: true,
          leading: const Icon(Icons.person_add_alt, size: 20),
          title: Text(l10n.actorsCreateActor),
          onTap: widget.onCreateActor,
        ),
      ],
    );
  }
}
