/// Wave F — the `actor:<id>` info surface: ONE actor's identity as a
/// first-class tab (the owner law: clicking an actor name opens their
/// information in a split, never a modal, never a face swap). It is a
/// pure projection of the live [RealmChatService] — a
/// [ListenableBuilder] over the service, never a cached snapshot (the
/// title-stuck bug law).
///
/// Anatomy, top to bottom:
/// - the identity header (avatar, name, KIND · role — the people
///   panel's own vocabulary);
/// - a READ-ONLY facts block (kind, actorId in mono — journal field
///   names, never localized, because every value is a durable fact);
/// - the EXISTING [ActorProfileEditor] for the editable fields
///   (displayName, role, systemPrompt, brainRef), saved through the
///   EXISTING `RealmChatService.updateActor` verb — one edit mechanism,
///   no second lane;
/// - the channel memberships computed from `service.channels`; a row
///   tap routes back into the shell's conversation grammar through
///   [ActorInfoSurface.onOpenConversation] (`channel:<id>`);
/// - the PROJECT ACCESS grants section — the SAME [ProjectAccessSection]
///   the people view's actor panel renders (row pattern reused, keys
///   shared: `shell.people.access*`).
///
/// Widget keys are the agent's UI contract (DESIGN §6): `actor.info`,
/// `actor.info.facts`, `actor.info.save`, `actor.info.channels`,
/// `actor.info.channel.<channelId>`, `actor.info.absent`.
library;

import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_profile_editor.dart';
import 'package:lastanswer/coding_agent/realm_chat/conversation_spaces.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/view_people.dart';

/// One actor's info tab body: identity, facts, the inline editor, the
/// channel memberships and the project-access grants.
final class ActorInfoSurface extends StatelessWidget {
  const ActorInfoSurface({
    required this.service,
    required this.actorId,
    this.onOpenConversation,
    super.key,
  });

  /// The world conversation service — the surface's ONLY state source
  /// (roster, channels, grants); listened to, never cached.
  final RealmChatService service;

  /// The actor this tab is about (the `actor:<id>` family's identity).
  final String actorId;

  /// Routes a membership-row tap into the shell's conversation grammar
  /// (`channel:<channelId>`); null keeps the rows inert (hermetic
  /// hosts outside the shell).
  final void Function(String surfaceId)? onOpenConversation;

  @override
  Widget build(final BuildContext context) => ListenableBuilder(
    listenable: service,
    builder: (final context, final _) {
      final profile = service.roster?.get(actorId);
      final display =
          profile ??
          ActorProfile(
            actorId: actorId,
            displayName: actorDisplayFallback(actorId),
          );
      final memberships = <ChannelInfo>[
        for (final channel in service.channels)
          if (channel.memberIds.contains(actorId)) channel,
      ];
      return SingleChildScrollView(
        child: Column(
          key: const ValueKey('actor.info'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(
              context,
              display,
              service.retiredInfo(actorId) == null,
            ),
            _facts(context, display),
            if (profile != null)
              _editor(context, profile)
            else if (service.retiredInfo(actorId) case final retired?)
              // Retirement is world truth (ADR 0120): named verbatim,
              // never a read-only ghost and never a live editor.
              Padding(
                padding: ShellTokens.sectionPadding,
                child: Text(
                  '${context.l10n.actorsRetiredNote} '
                  '${retired['retiredAt'] ?? ''}'
                  '${retired['retireReason'] == null
                      ? ''
                      : ' · ${retired['retireReason']}'}',
                  key: const ValueKey('actor.info.retired'),
                  style: LaTokens.mono(10.5, context.shellMuted),
                ),
              )
            else
              // Honest absence: an id with no roster profile shows its
              // facts and grants, and NAMES the missing profile — never
              // an invented identity, never a dead editor.
              Padding(
                padding: ShellTokens.sectionPadding,
                child: Text(
                  'no roster profile',
                  key: const ValueKey('actor.info.absent'),
                  style: LaTokens.mono(10.5, context.shellMuted),
                ),
              ),
            _channels(context, memberships),
            ProjectAccessSection(service: service, actorId: actorId),
          ],
        ),
      );
    },
  );

  /// The identity header: avatar + name + the KIND · role line (the
  /// people panel's vocabulary, one scale up).
  Widget _header(
    final BuildContext context,
    final ActorProfile display,
    final bool live,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: ShellTokens.sectionPadding,
      child: Row(
        children: [
          ActorAvatar(profile: display, size: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    display.kind.name.toUpperCase(),
                    if (display.role.isNotEmpty) display.role,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.shellMuted,
                  ),
                ),
              ],
            ),
          ),
          // ACTOR EQUALITY verbs (owner law, 2026-11-16): every
          // non-human LIVE actor is messageable and removable from
          // their own surface — the DM is the reuse-or-create thread,
          // the removal retires the durable row AND tombstones the
          // roster behind one confirm. A retired row names its
          // retirement instead (verbs there would lie).
          if (display.kind != ActorKind.human && live) ...[
            IconButton(
              key: const ValueKey('actor.info.message'),
              tooltip: context.l10n.actorsMessage,
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                unawaited(service.openDm(actorId));
                onOpenConversation?.call('dm:$actorId');
              },
            ),
            IconButton(
              key: const ValueKey('actor.info.remove'),
              tooltip: context.l10n.actorsRemove,
              icon: const Icon(Icons.delete_outlined, size: 16),
              visualDensity: VisualDensity.compact,
              onPressed: () => unawaited(_confirmRemove(context)),
            ),
          ],
        ],
      ),
    );
  }

  /// Removal is deliberate: one confirm names the actor, then the
  /// host's retire verb runs FIRST (the durable row is the identity);
  /// a bounce renders VERBATIM and the roster stays untouched.
  Future<void> _confirmRemove(final BuildContext context) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (final dialogContext) => AlertDialog(
        title: Text(l10n.actorsRemove),
        content: Text('${l10n.actorsRemoveConfirm} $actorId'),
        actions: [
          TextButton(
            key: const ValueKey('actor.info.remove.cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.modelsCancel),
          ),
          TextButton(
            key: const ValueKey('actor.info.remove.confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actorsRemove),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final receipt = await service.retireActor(actorId);
    if (receipt['ok'] != true) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (final dialogContext) => AlertDialog(
          key: const ValueKey('actor.info.remove.bounce'),
          content: Text('${receipt['bounce'] ?? 'retire_refused'}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.modelsCancel),
            ),
          ],
        ),
      );
      return;
    }
    service.removeActor(actorId);
    onOpenConversation?.call('conversations');
  }

  /// The read-only facts block: journal field names in mono, verbatim
  /// values (the beat-details actor-card law — facts are never
  /// localized, never paraphrased).
  Widget _facts(final BuildContext context, final ActorProfile display) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
        child: Column(
          key: const ValueKey('actor.info.facts'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _factRow(context, 'kind', display.kind.name, 'kind'),
            _factRow(context, 'actorId', display.actorId, 'actorId'),
            if (display.brainRef.isNotEmpty)
              _factRow(context, 'brainRef', display.brainRef, 'brainRef'),
            // ADR 0143 — the actor's own set, as the durable fact it
            // is (empty = the world policy whole).
            if (service.brainSets[actorId] case final set?
                when set.isNotEmpty)
              _factRow(context, 'brainSet', set.join(', '), 'brainSet'),
          ],
        ),
      );

  Widget _factRow(
    final BuildContext context,
    final String field,
    final String value,
    final String name,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            field,
            style: LaTokens.mono(10.5, context.shellMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            key: ValueKey('actor.info.fact.$name'),
            style: LaTokens.mono(10.5, context.la.ink),
          ),
        ),
      ],
    ),
  );

  /// The editable identity: the EXISTING one actor editor (ADR 0023
  /// §1a), saved through the EXISTING [RealmChatService.updateActor]
  /// verb — the persistence and the bot-loop rebuild live there.
  Widget _editor(final BuildContext context, final ActorProfile profile) =>
      Padding(
        padding: ShellTokens.sectionPadding,
        child: ActorProfileEditor(
          profile: profile,
          brainOptions: availableBrainOptions(
            paletteRungs:
                context.read<WorldStateService?>()?.generativeDecls ??
                const [],
            defaultOpenRouterModel: _defaultOpenRouterModel(context),
          ),
          tiersForBrain: (final ref) => reasoningTiersForBrainRef(
            ref,
            transportOfRung: (final id) =>
                context.read<WorldStateService?>()?.transportOfRung(id),
          ),
          saveKey: const ValueKey('actor.info.save'),
          initialBrainSet: service.brainSets[actorId] ?? const <String>[],
          initialSelfBind: (service.selfBinds[actorId] ?? 'allow') != 'deny',
          onSave:
              ({
                required displayName,
                required role,
                required systemPrompt,
                required brainRef,
                required avatar,
                required brainSet,
                required selfBind,
              }) {
                unawaited(
                  service.updateActor(
                    actorId: actorId,
                    displayName: displayName,
                    role: role,
                    systemPrompt: systemPrompt,
                    brainRef: brainRef,
                    avatar: avatar,
                    brainSet: brainSet,
                    selfBind: selfBind ? 'allow' : 'deny',
                  ),
                );
              },
        ),
      );

  /// The channel memberships: every registered channel listing this
  /// actor. A row tap routes into the shell's conversation grammar
  /// (`channel:<id>`) — the info surface never selects threads itself.
  Widget _channels(
    final BuildContext context,
    final List<ChannelInfo> memberships,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: ShellTokens.sectionPadding,
      child: Column(
        key: const ValueKey('actor.info.channels'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.railChannels, style: shellSectionLabel(context)),
          const SizedBox(height: 6),
          if (memberships.isEmpty)
            Text(
              '—',
              key: const ValueKey('actor.info.channels.empty'),
              style: LaTokens.mono(10.5, context.shellMuted),
            )
          else
            for (final channel in memberships)
              InkWell(
                key: ValueKey('actor.info.channel.${channel.channelId}'),
                borderRadius: BorderRadius.circular(6),
                hoverColor: context.shellHover,
                onTap: onOpenConversation == null
                    ? null
                    : () => onOpenConversation!('channel:${channel.channelId}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(Icons.tag, size: 13, color: context.shellMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '#${channel.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  /// The hosted-model option the brain picker offers (the people
  /// panel's derivation; absence keeps the local casts).
  String _defaultOpenRouterModel(final BuildContext context) {
    try {
      final config = context.read<AgentConfigStore>().config;
      return config.chat.defaultModel.isNotEmpty
          ? config.chat.defaultModel
          : (config.providers[AgentPlatformConfig.openRouterId]?.defaultModel ??
                '');
    } on Object {
      return '';
    }
  }
}
