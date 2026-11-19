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
/// - the durable IMAGE SPEND (the ledger's per-actor projection, the
///   native-image-assets follow-up): rendered from the realm store's
///   `image_spend` fold — absent rows render NOTHING (honest absence,
///   not zeros).
///
/// Widget keys are the agent's UI contract (DESIGN §6): `actor.info`,
/// `actor.info.facts`, `actor.info.now(.status/.line/.tasks)`,
/// `actor.info.save`, `actor.info.channels`,
/// `actor.info.channel.<channelId>`, `actor.info.absent`,
/// `actor.info.imageSpend`, and the retired card's
/// `actor.info.retired` + `actor.info.revive` (with `.bounce`).
library;

import 'package:lastanswer/ui_models/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_presence.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_profile_editor.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_status.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_members_ui.dart';
import 'package:lastanswer/coding_agent/realm_chat/conversation_spaces.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/coding_agent/subscription_provider.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:lastanswer/ui_shell/view_people.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show ImageSpendSummary, imageSpendOf;

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
            _header(context, display, service.retiredInfo(actorId) == null),
            _facts(context, display),
            _NowSection(service: service, actorId: actorId),
            _ImageSpendSection(service: service, actorId: actorId),
            if (profile != null)
              _editor(context, profile)
            else if (service.retiredInfo(actorId) case final retired?)
              // Retirement is world truth (ADR 0120): named verbatim,
              // never a read-only ghost and never a live editor. The
              // Revive verb rides the note (2026-11-18) — the UI face of
              // the revival law ("a fresh ensure revives"): the marks
              // come off the row, the identity re-adopts, and this very
              // surface re-renders live (verbs included) through the
              // service's notification.
              Padding(
                padding: ShellTokens.sectionPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.l10n.actorsRetiredNote} '
                      '${retired['retiredAt'] ?? ''}'
                      '${retired['retireReason'] == null ? '' : ' · ${retired['retireReason']}'}',
                      key: const ValueKey('actor.info.retired'),
                      style: LaTokens.mono(10.5, context.shellMuted),
                    ),
                    const SizedBox(height: 8),
                    LaButton(
                      key: const ValueKey('actor.info.revive'),
                      variant: LaButtonVariant.ghost,
                      size: LaButtonSize.sm,
                      onPressed: () => unawaited(_revive(context)),
                      label: context.l10n.actorsRevive,
                    ),
                  ],
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
            // The leave verb rides only a non-human card: the human is
            // PERMANENT in channels (owner law, 2026-11-18) — their own
            // card never offers a channel removal.
            _channels(
              context,
              memberships,
              display.kind != ActorKind.human &&
                  actorId != service.humanActorId,
            ),
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
    final laUi = context.laUi;
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
                  style: laUi.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    display.kind.name.toUpperCase(),
                    if (display.role.isNotEmpty) display.role,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: laUi.micro.copyWith(color: context.shellMuted),
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
            LaButton.icon(
              key: const ValueKey('actor.info.message'),
              tooltip: context.l10n.actorsMessage,
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              size: LaButtonSize.sm,
              onPressed: () {
                unawaited(service.openDm(actorId));
                onOpenConversation?.call('dm:$actorId');
              },
            ),
            LaButton.icon(
              key: const ValueKey('actor.info.remove'),
              tooltip: context.l10n.actorsRemove,
              icon: const Icon(Icons.delete_outlined, size: 16),
              size: LaButtonSize.sm,
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
    // Not showLaConfirm: the action buttons' keys are the frozen agent
    // contract (`actor.info.remove.cancel/confirm`), so the confirm
    // rides showLaDialog+LaDialog with keyed kit buttons.
    final ok = await showLaDialog<bool>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        titleText: l10n.actorsRemove,
        content: Text(
          '${l10n.actorsRemoveConfirm} $actorId',
          style: dialogContext.laUi.body.copyWith(fontSize: 13),
        ),
        actions: [
          LaButton(
            key: const ValueKey('actor.info.remove.cancel'),
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            label: l10n.modelsCancel,
          ),
          LaButton(
            key: const ValueKey('actor.info.remove.confirm'),
            variant: LaButtonVariant.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: l10n.actorsRemove,
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final receipt = await service.retireActor(actorId);
    if (receipt['ok'] != true) {
      if (!context.mounted) return;
      await showLaDialog<void>(
        context: context,
        builder: (final dialogContext) => LaDialog(
          key: const ValueKey('actor.info.remove.bounce'),
          content: Text(
            '${receipt['bounce'] ?? 'retire_refused'}',
            style: dialogContext.laUi.body.copyWith(fontSize: 13),
          ),
          actions: [
            LaButton(
              variant: LaButtonVariant.ghost,
              onPressed: () => Navigator.of(dialogContext).pop(),
              label: l10n.modelsCancel,
            ),
          ],
        ),
      );
      return;
    }
    service.removeActor(actorId);
    onOpenConversation?.call('conversations');
  }

  /// Revival needs NO confirm (it is reversible — retire again): the
  /// service's verb strips the retirement marks and re-adopts the
  /// identity, whose notification re-renders this surface live. A
  /// bounce renders VERBATIM — the remove dialog's refusal shape.
  Future<void> _revive(final BuildContext context) async {
    final receipt = await service.reviveActor(actorId);
    if (receipt['ok'] == true || !context.mounted) return;
    await showLaDialog<void>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        key: const ValueKey('actor.info.revive.bounce'),
        content: Text(
          '${receipt['bounce'] ?? 'revive_refused'}',
          style: dialogContext.laUi.body.copyWith(fontSize: 13),
        ),
        actions: [
          LaButton(
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(),
            label: context.l10n.modelsCancel,
          ),
        ],
      ),
    );
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
            if (service.brainSets[actorId] case final set? when set.isNotEmpty)
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
          child: Text(field, style: LaTokens.mono(10.5, context.shellMuted)),
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
                context.read<WorldStateService?>()?.generativeDecls ?? const [],
            defaultOpenRouterModel: _defaultOpenRouterModel(context),
            subscriptionModels: subscriptionModelsOf(context),
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
  /// A non-human card's rows carry the quiet leave verb (the members
  /// lane's reverse direction): the shared removal confirm runs, the
  /// ListenableBuilder above rebuilds the section off the service, and
  /// a named refusal bounces verbatim (the retire-confirm's pattern).
  Widget _channels(
    final BuildContext context,
    final List<ChannelInfo> memberships,
    final bool canLeave,
  ) => Padding(
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
            LaPressable(
              key: ValueKey('actor.info.channel.${channel.channelId}'),
              radius: BorderRadius.circular(6),
              scaleOnPress: false,
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
                        style: context.laUi.micro,
                      ),
                    ),
                    if (canLeave)
                      LaButton.icon(
                        key: ValueKey(
                          'actor.info.channel.${channel.channelId}.leave',
                        ),
                        tooltip: context.l10n.worldChatMemberRemoveTooltip,
                        size: LaButtonSize.sm,
                        icon: Icon(Icons.close, size: 13, color: context.shellMuted),
                        onPressed: () =>
                            unawaited(_leaveChannel(context, channel)),
                      ),
                  ],
                ),
              ),
            ),
      ],
    ),
  );

  /// The leave verb: the shared confirm (the losses dialog — history +
  /// running tasks), then silence on success (the section's rebuild IS
  /// the outcome) and the verbatim bounce on a refusal.
  Future<void> _leaveChannel(
    final BuildContext context,
    final ChannelInfo channel,
  ) async {
    final l10n = context.l10n;
    final result = await confirmChannelRemoval(
      context,
      service: service,
      channel: channel,
      actorId: actorId,
    );
    if (result == null || result == 'ok' || !context.mounted) return;
    await showLaDialog<void>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        key: const ValueKey('actor.info.channel.leave.bounce'),
        content: Text(
          result,
          style: dialogContext.laUi.body.copyWith(fontSize: 13),
        ),
        actions: [
          LaButton(
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(),
            label: l10n.modelsCancel,
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

/// The NOW section (the manager's triage on the info tab, 2026-11-18):
/// the actor's folded live status — the [deriveActorPresence] verdict
/// as mark + word, the quiet narration line and the running durable
/// tasks. One honest glance at what the actor is doing right now, from
/// the same fold every other surface reads. No foldable facts render
/// NOTHING (a human card, a never-started worker: no section — honest
/// absence, never an invented state).
final class _NowSection extends StatelessWidget {
  const _NowSection({required this.service, required this.actorId});

  final RealmChatService service;
  final String actorId;

  @override
  Widget build(final BuildContext context) {
    final worldState = context.read<WorldStateService?>();
    final presence = presenceStatusOf(service, actorId, world: worldState);
    if (presence == ActorPresenceStatus.absent) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final word = switch (presence) {
      ActorPresenceStatus.working => l10n.actorsStatusWorking,
      ActorPresenceStatus.idle => l10n.actorsStatusIdle,
      ActorPresenceStatus.failed => l10n.actorsStatusFailed,
      ActorPresenceStatus.retired => l10n.actorsRetiredMark,
      ActorPresenceStatus.absent => null,
    }!;
    final line = service.botNarration[actorId]?.statusLine;
    final running = runningTasksOf(worldState, actorId);
    return Padding(
      padding: ShellTokens.sectionPadding,
      child: Column(
        key: const ValueKey('actor.info.now'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.actorInfoNowSection, style: shellSectionLabel(context)),
          const SizedBox(height: 4),
          Row(
            children: [
              ActorStatusMark(
                key: const ValueKey('actor.info.now.status'),
                status: presence,
              ),
              const SizedBox(width: 6),
              Text(word, style: context.laUi.compact),
            ],
          ),
          if (line != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                line,
                key: const ValueKey('actor.info.now.line'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LaTokens.mono(10, context.shellMuted),
              ),
            ),
          if (running > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                running == 1 ? '1 task running' : '$running tasks running',
                key: const ValueKey('actor.info.now.tasks'),
                style: LaTokens.mono(10, context.shellMuted),
              ),
            ),
        ],
      ),
    );
  }
}

/// The durable IMAGE SPEND (the ledger's per-actor projection): folded
/// from the realm store's `image_spend` collection — the settled cost,
/// calls, images, plus the honest unknowns (estimated / failed /
/// refused). Absent rows render NOTHING: no store, no rows, no
/// section — honest absence, not zeros (the placeholder law's UI
/// face). One FutureBuilder over a columnar fold of a small
/// collection; the scale law keeps it cheap.
final class _ImageSpendSection extends StatelessWidget {
  const _ImageSpendSection({required this.service, required this.actorId});
  final RealmChatService service;
  final String actorId;

  @override
  Widget build(final BuildContext context) {
    final world = service.world;
    if (world == null) return const SizedBox.shrink();
    return FutureBuilder<ImageSpendSummary?>(
      future: imageSpendOf(world.store, actor: actorId),
      builder: (final context, final snapshot) {
        final spend = snapshot.data;
        if (spend == null ||
            (spend.totalCalls == 0 && spend.refusedCalls == 0)) {
          return const SizedBox.shrink();
        }
        final line = [
          '\$${spend.spendUsd.toStringAsFixed(2)}',
          '${spend.totalImages} img',
          '${spend.totalCalls} calls',
          if (spend.estimatedCalls > 0) '${spend.estimatedCalls} est',
          if (spend.failedCalls > 0) '${spend.failedCalls} failed',
          if (spend.refusedCalls > 0) '${spend.refusedCalls} refused',
        ].join(' · ');
        return Padding(
          padding: ShellTokens.sectionPadding,
          child: Column(
            key: const ValueKey('actor.info.imageSpend'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.actorsImageSpend,
                style: shellSectionLabel(context),
              ),
              const SizedBox(height: 4),
              Text(
                line,
                key: const ValueKey('actor.info.imageSpend.line'),
                style: LaTokens.mono(10.5, context.shellMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}
