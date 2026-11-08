import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/landing_inbox.dart';
import 'package:lastanswer/shell/shell_scope.dart';
import 'package:lastanswer/shell/shell_theme.dart';

/// ADR 0024 — the world chat surface: the human-facing projection of the
/// realm's durable threads. Text-native, one grid: ONE focused
/// conversation — quiet header, beat column with actor gutter labels,
/// one composer. The conversation LIST lives in the shell's actor rail
/// (Discord model: every actor row is its DM); this surface never
/// duplicates it. With no thread selected it stays a calm empty state.
///
/// The rail's objects name the rows: a DM is the two-member thread with
/// one actor, a channel is a named thread registered in the `channels`
/// collection. Every visible word is a durable beat; nothing here is a
/// private message table.
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `worldchat.composer`, `worldchat.send`, `worldchat.close`,
/// `worldchat.context`, `worldchat.beat.<threadId>#<n>`.
final class WorldChatSurface extends StatefulWidget {
  const WorldChatSurface({this.service, super.key});

  /// Test seam; production resolves through DI.
  final RealmChatService? service;

  @override
  State<WorldChatSurface> createState() => _WorldChatSurfaceState();
}

class _WorldChatSurfaceState extends State<WorldChatSurface> {
  RealmChatService? _owned;
  final _composer = TextEditingController();

  /// Resolved once in [initState]: `dispose` must not look up ancestors
  /// on the deactivated element (it is unsafe there).
  RealmChatService? _resolved;

  RealmChatService get _service => _resolved ??=
      widget.service ??
      (context.read<RealmChatService?>() ??
          (_owned ??= RealmChatService(
            providerConfiguration: context.read<ProviderConfigurationStore?>(),
          )));

  @override
  void initState() {
    super.initState();
    final service = _service..addListener(_onChanged);
    unawaited(service.ensureReady());
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    _owned?.dispose();
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final service = _service;
    if (!service.isSupported) {
      return _CenteredNote(text: context.l10n.worldChatUnsupported);
    }
    if (!service.isReady) {
      if (service.error != null) {
        return _CenteredNote(
          text: 'The world chat failed to open: ${service.error}',
        );
      }
      return const Center(child: UiCircularProgress());
    }
    return _ConversationPane(service: service, composer: _composer);
  }
}

class _CenteredNote extends StatelessWidget {
  const _CenteredNote({required this.text});
  final String text;

  @override
  Widget build(final BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}

/// 0b — the inline work texture (the ZCode/Zed law: an actor's work is
/// CHAT TEXTURE, not a separate observability room). Rides the stream's
/// tail (reversed index 0 — under the newest beat, above the composer):
/// narration rows for the in-app loops' live states, and work cards for
/// the native actors' task loops joined by room participation — running
/// first, the newest settled last word per actor. Cards expand to the
/// loop's own facts (rounds, tool calls, applied writes, tokens, cache
/// share, spend, verdict line) — everything the journal already
/// carries; nothing here invents a summary.
class _WorkStrip extends StatefulWidget {
  const _WorkStrip({required this.service, required this.participants});

  final RealmChatService service;
  final List<String> participants;

  @override
  State<_WorkStrip> createState() => _WorkStripState();
}

class _WorkStripState extends State<_WorkStrip> {
  final Set<String> _expanded = <String>{};

  @override
  Widget build(final BuildContext context) {
    final world = context.read<WorldStateService?>();
    final service = widget.service;
    return ListenableBuilder(
      listenable: world == null
          ? service
          : Listenable.merge(<Listenable>[service, world]),
      builder: (final context, final _) {
        final human = service.humanActorId;
        final actors = [
          for (final id in widget.participants)
            if (id != human) id,
        ];
        final rows = <Widget>[];

        // 1) Narration rows — the in-app loops' live cycle states (the
        // service getter honors the debug seam the header shares).
        final narrations = service.botNarration;
        for (final actorId in actors) {
          final narration = narrations[actorId];
          if (narration == null) continue;
          final state = narration.state;
          if (state != BotNarrationState.thinking &&
              state != BotNarrationState.generating &&
              state != BotNarrationState.failed) {
            continue;
          }
          rows.add(
            _NarrationRow(
              key: ValueKey('worldchat.narration.$actorId'),
              service: service,
              actorId: actorId,
              narration: narration,
            ),
          );
        }

        // 2) Work cards — the native task loops of this room's actors.
        if (world != null && actors.isNotEmpty) {
          final actorSet = actors.toSet();
          bool inRoom(final WorldTaskRow task) =>
              task.addressees.any(actorSet.contains);
          final running = [
            for (final task in world.tasks)
              if (!task.terminal && inRoom(task)) task,
          ];
          // The newest settled last word per actor (one card each — the
          // room shows the verdict, the inbox keeps the full ledger).
          final settledByActor = <String, WorldTaskRow>{};
          for (final task in world.tasks) {
            if (!task.terminal || !inRoom(task)) continue;
            for (final actorId in task.addressees) {
              if (!actorSet.contains(actorId)) continue;
              final current = settledByActor[actorId];
              if (current == null ||
                  (task.at ?? '').compareTo(current.at ?? '') > 0) {
                settledByActor[actorId] = task;
              }
            }
          }
          for (final task in [...running, ...settledByActor.values]) {
            rows.add(
              _WorkCard(
                key: ValueKey('worldchat.work.${task.taskId}'),
                world: world,
                service: service,
                task: task,
                participants: actorSet,
                expanded: _expanded.contains(task.taskId),
                onToggle: () => setState(() {
                  if (!_expanded.remove(task.taskId)) {
                    _expanded.add(task.taskId);
                  }
                }),
              ),
            );
          }
        }

        // 3) 0f — honest absence: an actor bound in the daemon's
        // vocabulary with the daemon ASLEEP says so in the room, with
        // the one-click arm — never silence.
        if (world != null && !world.daemonLive) {
          for (final actorId in actors) {
            final profile = service.roster?.get(actorId);
            if (profile == null) continue;
            if (!service.daemonBoundActor(profile)) continue;
            rows.add(
              _DaemonAbsentRow(
                key: ValueKey('worldchat.daemonAbsent.$actorId'),
                world: world,
                name: profile.displayName,
              ),
            );
          }
        }

        // 4) 0c — permission interrupts, IN the conversation: an open
        // round whose title names one of this room's actors renders
        // here reject-first (the inbox keeps the global ledger; the
        // structural task→room join lands with the LaWorld fold — the
        // name join is the honest one available today).
        final permissions = world?.permissions ?? const <InboxPermission>[];
        if (permissions.isNotEmpty && actors.isNotEmpty) {
          final names = [
            for (final id in actors) ...<String>[
              id,
              service.roster?.get(id)?.displayName ?? '',
            ],
          ].where((name) => name.isNotEmpty).map((name) => name.toLowerCase());
          for (final permission in permissions) {
            final title = permission.title.toLowerCase();
            if (!names.any(title.contains)) continue;
            rows.add(
              _PermissionInterrupt(
                key: ValueKey('worldchat.perm.${permission.sessionId}'),
                permission: permission,
              ),
            );
          }
        }

        if (rows.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        );
      },
    );
  }
}

/// One live narration line: the actor's mark + its own status words
/// (the loop composes them — never invented here).
class _NarrationRow extends StatelessWidget {
  const _NarrationRow({
    required this.service,
    required this.actorId,
    required this.narration,
    super.key,
  });

  final RealmChatService service;
  final String actorId;
  final BotNarration narration;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final profile = service.roster?.get(actorId);
    final name = profile?.displayName ?? actorDisplayFallback(actorId);
    final line = narration.statusLine ?? narration.state.name;
    return Semantics(
      label: 'worldchat.narration.$actorId',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            ActorAvatar(
              profile:
                  profile ?? ActorProfile(actorId: actorId, displayName: name),
              size: 16,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '$name — $line',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: narration.state == BotNarrationState.failed
                      ? context.la.danger
                      : context.shellMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One work card: the delegated sentence + the world's own state word
/// + the rung; expanded, the loop's measured facts. Reject-first
/// honesty: a terminal card shows the verdict line verbatim (the
/// journal's summary or reason), never a prettified invention.
class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.world,
    required this.service,
    required this.task,
    required this.participants,
    required this.expanded,
    required this.onToggle,
    super.key,
  });

  final WorldStateService world;
  final RealmChatService service;
  final WorldTaskRow task;
  final Set<String> participants;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final stateColor = task.terminal
        ? (task.state == 'succeeded' ? context.la.accent : context.la.danger)
        : context.la.caution;
    // The telemetry join: the executing actor is one of the addressed
    // room participants (the journal rows are per-actor).
    final actorId = task.addressees.firstWhere(
      participants.contains,
      orElse: () => task.addressees.isEmpty ? '' : task.addressees.first,
    );
    final telemetry = actorId.isEmpty ? null : world.telemetryByActor[actorId];
    final verdict = expanded
        ? world.verdicts.where((v) => v.id == task.taskId).firstOrNull
        : null;
    return Semantics(
      label: 'worldchat.work.${task.taskId}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.shellHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                key: ValueKey('worldchat.work.expand.${task.taskId}'),
                onTap: onToggle,
                borderRadius: BorderRadius.circular(ShellTokens.radius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: stateColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.task,
                          maxLines: expanded ? 4 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.la.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.state,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: stateColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        size: 15,
                        color: context.shellMuted,
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.modelId != null && task.modelId!.isNotEmpty)
                        _factLine(theme, context, 'rung · ${task.modelId}'),
                      if (telemetry != null)
                        _factLine(theme, context, () {
                          final cache = telemetry.cacheHitRate == null
                              ? '—'
                              : '${(telemetry.cacheHitRate! * 100).round()}%';
                          final tokens =
                              telemetry.promptTokens +
                              telemetry.completionTokens;
                          return '${telemetry.rounds}r · '
                              '${telemetry.toolCalls} tools · '
                              '${telemetry.appliedWrites} writes · '
                              'cache $cache · $tokens tok';
                        }()),
                      if (task.at != null) _factLine(theme, context, task.at!),
                      if (verdict != null) ...[
                        if (verdict.spend != null && verdict.spend!.isNotEmpty)
                          _factLine(theme, context, 'spend · ${verdict.spend}'),
                        if (verdict.line.isNotEmpty)
                          _factLine(theme, context, verdict.line),
                      ] else if (task.summary != null &&
                          task.summary!.isNotEmpty)
                        _factLine(theme, context, task.summary!),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _factLine(
    final ThemeData theme,
    final BuildContext context,
    final String text,
  ) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: context.shellMuted,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

/// 0c — one open permission round interrupting the conversation,
/// reject-first (Deny leftmost, the inbox law): the answer lands
/// through the session's own handle, exactly as the inbox row does.
class _PermissionInterrupt extends StatelessWidget {
  const _PermissionInterrupt({required this.permission, super.key});

  final InboxPermission permission;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Semantics(
      label: 'worldchat.perm.${permission.sessionId}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.la.danger),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 14, color: context.la.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    permission.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                _StripButton(
                  keyName: 'worldchat.perm.deny.${permission.sessionId}',
                  label: l10n.inboxDeny,
                  danger: true,
                  onTap: () => unawaited(permission.answer(false)),
                ),
                const SizedBox(width: 6),
                _StripButton(
                  keyName: 'worldchat.perm.allow.${permission.sessionId}',
                  label: l10n.inboxAllow,
                  onTap: () => unawaited(permission.answer(true)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One quiet strip button (the inbox's button vocabulary, the shell's
/// hairline law).
class _StripButton extends StatelessWidget {
  const _StripButton({
    required this.keyName,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String keyName;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: keyName,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: ValueKey(keyName),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: danger ? context.la.danger : context.shellHairline,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: danger ? context.la.danger : context.la.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );
}

/// 0f — the honest absence row: this actor answers through the world
/// daemon, and the daemon is asleep. One click arms the supervised
/// converge; a refusal renders in the world's own words. Silence is
/// the one answer this row never gives.
class _DaemonAbsentRow extends StatelessWidget {
  const _DaemonAbsentRow({required this.world, required this.name, super.key});

  final WorldStateService world;
  final String name;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final arming = world.armState == WorldArmState.arming;
    return Semantics(
      label: 'worldchat.daemonAbsent',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(Icons.power_settings_new, size: 13, color: context.la.caution),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$name · ${l10n.inboxWorldDown}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: context.shellMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            if (world.armState == WorldArmState.error &&
                world.armError != null &&
                world.armError!.isNotEmpty)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    world.armError!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: context.la.danger,
                    ),
                  ),
                ),
              ),
            _StripButton(
              keyName: 'worldchat.daemonAbsent.arm',
              label: arming ? l10n.inboxWorldArming : l10n.edgeArmWorld,
              onTap: arming ? () {} : () => unawaited(world.armWorld()),
            ),
          ],
        ),
      ),
    );
  }
}

/// The visual top of an endless room: one quiet row that walks the
/// window one page into history. The scroll trigger's twin — tappable,
/// so keyboards and agents reach older beats too (the semantics label
/// IS the widget key, the phase-2 contract).
class _LoadOlderRow extends StatelessWidget {
  const _LoadOlderRow({required this.label, required this.onTap, super.key});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: 'worldchat.loadOlder',
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextButton(
          onPressed: onTap,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The jump-to-latest pill: appears once the reader has scrolled a
/// screenful away from the tail (Discord law — new beats never yank the
/// reading position), one tap animates back to the newest beat.
class _JumpToLatestPill extends StatelessWidget {
  const _JumpToLatestPill({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: 'worldchat.jumpLatest',
    hint: label,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.la.surfaceRaised,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: context.shellHairline),
            boxShadow: shellFloatingShadow(context),
          ),
          child: Icon(
            Icons.arrow_downward,
            size: 16,
            color: context.shellMuted,
          ),
        ),
      ),
    ),
  );
}

class _ConversationPane extends StatefulWidget {
  const _ConversationPane({required this.service, required this.composer});
  final RealmChatService service;
  final TextEditingController composer;

  @override
  State<_ConversationPane> createState() => _ConversationPaneState();
}

class _ConversationPaneState extends State<_ConversationPane> {
  /// The reversed list's controller: offset 0 = the newest beat (the
  /// bottom). An endless room lives at its tail; scrolling UP walks
  /// into history and triggers [RealmChatService.loadOlderBeats].
  final ScrollController _scroll = ScrollController();
  bool _showJumpToLatest = false;

  RealmChatService get service => widget.service;
  TextEditingController get composer => widget.composer;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final away = _scroll.offset > 240;
    if (away != _showJumpToLatest) {
      setState(() => _showJumpToLatest = away);
    }
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final threadId = service.activeThreadId;
    final thread = service.activeThread;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (threadId == null || thread == null) {
      // No thread open: the phase-1d LANDING INBOX — the void became a
      // decision surface (open permissions reject-first, running tasks,
      // last verdicts, recent threads). A hermetic shell without the
      // world read model keeps the calm note.
      final world = context.read<WorldStateService?>();
      if (world != null) {
        return LandingInbox(
          world: world,
          service: service,
          onOpenThread: service.selectThread,
        );
      }
      return _CenteredNote(text: l10n.worldChatSelectFromRail);
    }
    final roster = service.roster;
    String displayNameOf(String actorId) =>
        roster?.get(actorId)?.displayName ?? actorDisplayFallback(actorId);
    final participants = (thread['participants']! as List).cast<String>();
    final human = service.humanActorId;
    // ADR 0024 — what this pane shows: a channel (#name + member count),
    // a DM (the other actor + presence), or a plain group thread.
    final channel = service.channelByThreadId(threadId);
    final dmOther =
        human != null &&
            participants.length == 2 &&
            participants.contains(human)
        ? participants.firstWhere((participant) => participant != human)
        : null;
    final otherProfile = dmOther == null
        ? null
        : roster?.get(dmOther) ??
              ActorProfile(
                actorId: dmOther,
                displayName: displayNameOf(dmOther),
              );
    final bots = service.bots;
    final composerHint = channel != null
        ? l10n.worldChatMessageHint('#${channel.name}')
        : dmOther != null
        ? l10n.worldChatMessageHint(displayNameOf(dmOther))
        : l10n.worldChatComposerHint;
    final beats = service.beats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConversationHeader(
          service: service,
          threadId: threadId,
          channel: channel,
          other: otherProfile,
          topic: thread['topic']! as String,
          participants: participants,
          showPresence: bots != null,
          presenceOnline:
              otherProfile != null &&
              (bots?.isRunning(otherProfile.actorId) ?? false),
        ),
        Divider(height: 1, color: theme.dividerColor),
        Expanded(
          child: beats.isEmpty
              ? _CenteredNote(text: l10n.worldChatFirstWord)
              : Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (final notification) {
                        // Reversed list: OLDER beats live at larger
                        // offsets — nearing the top edge is the
                        // scroll-up pagination trigger. Prepending
                        // older pages never shifts the visible window
                        // (offsets anchor at the bottom), so the
                        // reading position survives the fetch.
                        final metrics = notification.metrics;
                        if (service.hasOlderBeats &&
                            metrics.maxScrollExtent - metrics.pixels < 160) {
                          unawaited(service.loadOlderBeats());
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scroll,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        // Index 0 = the work strip (the stream's live
                        // tail — under the newest beat, above the
                        // composer); beats follow newest-first; the
                        // load-older row sits at the visual top.
                        itemCount:
                            1 + beats.length + (service.hasOlderBeats ? 1 : 0),
                        itemBuilder: (final context, final index) {
                          if (index == 0) {
                            return _WorkStrip(
                              service: service,
                              participants: participants,
                            );
                          }
                          if (index > beats.length) {
                            // The visual top: the explicit load-older
                            // affordance (the scroll trigger's twin —
                            // tappable, so agents and keyboards reach
                            // it too).
                            return _LoadOlderRow(
                              key: const ValueKey('worldchat.loadOlder'),
                              label: l10n.worldChatLoadOlder,
                              onTap: () => unawaited(service.loadOlderBeats()),
                            );
                          }
                          // Newest-first: index 1 = the newest beat at
                          // the bottom; the visually-ABOVE neighbour is
                          // the next-older beat (grouping rule
                          // unchanged: same author + same addressing
                          // hides the header).
                          final beat = beats[beats.length - index];
                          final above = index < beats.length
                              ? beats[beats.length - index - 1]
                              : null;
                          final author = beat['author']! as String;
                          final grouped =
                              above != null &&
                              above['author'] == author &&
                              above['addressedTo'].toString() ==
                                  beat['addressedTo'].toString();
                          final profile =
                              roster?.get(author) ??
                              ActorProfile(
                                actorId: author,
                                displayName: displayNameOf(author),
                              );
                          return _MessageRow(
                            key: ValueKey(
                              'worldchat.beat.$threadId#${beat['beat']}',
                            ),
                            profile: profile,
                            isHuman: author == service.humanActorId,
                            text: beat['text']! as String,
                            at: beat['at'] as String?,
                            showHeader: !grouped,
                          );
                        },
                      ),
                    ),
                    if (_showJumpToLatest)
                      Positioned(
                        bottom: 12,
                        right: 20,
                        child: _JumpToLatestPill(
                          key: const ValueKey('worldchat.jumpLatest'),
                          label: l10n.worldChatJumpToLatest,
                          onTap: () => unawaited(
                            _scroll.animateTo(
                              0,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        Divider(height: 1, color: theme.dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Container(
            // Declare the field once: a quiet raised fill, no border —
            // border+fill together is the Material double declaration.
            decoration: BoxDecoration(
              color: context.shellField,
              borderRadius: BorderRadius.circular(ShellTokens.radius + 2),
            ),
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Semantics(
                    label: 'worldchat.composer',
                    child: TextField(
                      key: const ValueKey('worldchat.composer'),
                      controller: composer,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (final value) => unawaited(
                        service.say(value).then((_) => composer.clear()),
                      ),
                      decoration: InputDecoration(
                        hintText: composerHint,
                        border: InputBorder.none,
                        isDense: true,
                        filled: false,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('worldchat.send'),
                  tooltip: l10n.worldChatSend,
                  icon: service.sending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_upward, size: 18),
                  onPressed: service.sending
                      ? null
                      : () => unawaited(
                          service
                              .say(composer.text)
                              .then((_) => composer.clear()),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The COMPACT ACTOR HUD (DESIGN.md v2, owner law 2026-11-08): a room
/// header carries IDENTITY and MOOD, nothing else — creature mark
/// (20px), the name, one 6px pulse while the loop cycles, and a single
/// card button. The facts a debugger needs (brain, kind·role, health,
/// seat, thread) live one tap away in the actor-card popover, mono
/// 10.5px — field names, not prose (journal vocabulary, never
/// localized: every value is a durable fact). The law: if a fact is
/// not identity or live state, it does not sit between the human and
/// the conversation.
class _ConversationHeader extends StatefulWidget {
  const _ConversationHeader({
    required this.service,
    required this.threadId,
    required this.channel,
    required this.other,
    required this.topic,
    required this.participants,
    required this.showPresence,
    required this.presenceOnline,
  });

  final RealmChatService service;
  final String threadId;
  final ChannelInfo? channel;

  /// The other actor of a DM, null for channels and group threads.
  final ActorProfile? other;
  final String topic;
  final List<String> participants;
  final bool showPresence;
  final bool presenceOnline;

  @override
  State<_ConversationHeader> createState() => _ConversationHeaderState();
}

class _ConversationHeaderState extends State<_ConversationHeader> {
  final LayerLink _cardLink = LayerLink();
  OverlayEntry? _cardEntry;

  @override
  void dispose() {
    _removeCard();
    super.dispose();
  }

  void _removeCard() {
    _cardEntry?.remove();
    _cardEntry = null;
  }

  void _toggleCard() {
    if (_cardEntry != null) {
      setState(_removeCard);
      return;
    }
    setState(() {
      _cardEntry = OverlayEntry(
        builder: (final overlayContext) => Stack(
          children: [
            Positioned.fill(
              child: ModalBarrier(
                dismissible: true,
                color: const Color(0x00000000),
                onDismiss: () {
                  if (mounted) setState(_removeCard);
                },
              ),
            ),
            Positioned.fill(
              child: CompositedTransformFollower(
                link: _cardLink,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                offset: const Offset(0, 6),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _ActorCard(header: widget, onClose: _removeCard),
                ),
              ),
            ),
          ],
        ),
      );
      Overlay.of(context).insert(_cardEntry!);
    });
  }

  @override
  Widget build(final BuildContext context) {
    final service = widget.service;
    final theme = Theme.of(context);
    final other = widget.other;
    final channel = widget.channel;
    final name = channel != null
        ? '#${channel.name}'
        : other?.displayName ?? widget.topic;
    // The mood: a pulse while any non-human participant of THIS thread
    // is mid-reply (thinking or generating) — the state word lives in
    // the Semantics label and the creature's eyes, never as header
    // text (the HUD law). Absent = nothing rendered, no reserved space.
    final narrations = service.botNarration;
    final human = service.humanActorId;
    String? typingName;
    for (final participant in widget.participants) {
      if (participant == human) continue;
      final state = narrations[participant]?.state;
      if (state == BotNarrationState.thinking ||
          state == BotNarrationState.generating) {
        typingName =
            service.roster?.get(participant)?.displayName ??
            actorDisplayFallback(participant);
        break;
      }
    }
    final nameColor = other == null
        ? null // Channels and topics keep the ambient ink.
        : other.kind == ActorKind.human
        ? theme.colorScheme.primary
        : actorColor(other.actorId);
    // The identity IS the entry point to the actor's profile: tapping
    // the mark or name hosts the people view on that actor. Channels
    // and group topics are not one identity — they stay inert.
    final onFocusActor = ViewScope.of(context)?.onFocusActor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 5, 8, 5),
      child: Row(
        children: [
          // The identity cluster is BOUNDED (Flexible): the inner Row
          // shrink-wraps around mark + ellipsized name. An unbounded
          // inner flex crashes layout ("non-zero flex, unbounded
          // width") — paid once, 2026-11-08.
          Flexible(
            child: CompositedTransformTarget(
              link: _cardLink,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    key: const ValueKey('worldchat.identity'),
                    onTap: other == null || onFocusActor == null
                        ? null
                        : () => onFocusActor(other.actorId),
                    child: _headerMark(theme),
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: InkWell(
                      onTap: other == null || onFocusActor == null
                          ? null
                          : () => onFocusActor(other.actorId),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 13,
                          color: nameColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (typingName != null) ...[
            const SizedBox(width: 7),
            _ThinkingPulse(
              key: const ValueKey('worldchat.typing'),
              label: '$typingName is thinking…',
            ),
          ],
          const Spacer(),
          _CardButton(
            key: const ValueKey('worldchat.card'),
            open: _cardEntry != null,
            onTap: _toggleCard,
          ),
        ],
      ),
    );
  }

  /// The header's identity mark (20px — the HUD law): the DM avatar
  /// (with presence), the channel's bare `#` glyph in its quiet ink,
  /// or a derived identicon for a group.
  Widget _headerMark(final ThemeData theme) => switch (this) {
    _ when widget.channel != null => SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Text(
          '#',
          style: theme.textTheme.titleSmall?.copyWith(
            color: actorColor(widget.channel!.channelId),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    _ when widget.other != null => ActorAvatar(
      profile: widget.other!,
      size: 20,
      showPresence: widget.showPresence,
      presenceOnline: widget.presenceOnline,
    ),
    _ => actorIdenticon(widget.threadId, size: 20),
  };
}

/// A DM's card row: the kind, then the role the human authored for it
/// (ADR 0024 §2 — labels, not icons; sentence case per DESIGN §2).
String _kindAndRole(final ActorProfile profile) => [
  profile.kind.name[0].toUpperCase() + profile.kind.name.substring(1),
  if (profile.role.isNotEmpty) profile.role,
].join(' · ');

/// The one live-state mark of the HUD: a 6px pulse while the loop
/// cycles (caution ink — the state word rides the Semantics label,
/// never color alone). Reduced-motion renders it static at full
/// opacity: the motion-free truth of the same fact.
class _ThinkingPulse extends StatefulWidget {
  const _ThinkingPulse({required this.label, super.key});

  final String label;

  @override
  State<_ThinkingPulse> createState() => _ThinkingPulseState();
}

class _ThinkingPulseState extends State<_ThinkingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced-motion renders the pulse static at full opacity: the
    // motion-free truth of the same fact.
    if (!MediaQuery.disableAnimationsOf(context) && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final dot = Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: context.la.caution,
        borderRadius: BorderRadius.circular(3),
      ),
    );
    return Semantics(
      label: widget.label,
      child: MediaQuery.disableAnimationsOf(context)
          ? dot
          : FadeTransition(
              opacity: Tween<double>(begin: 0.35, end: 1).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: dot,
            ),
    );
  }
}

/// The HUD's single card button: one tap away from the facts.
class _CardButton extends StatelessWidget {
  const _CardButton({required this.open, required this.onTap, super.key});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: 'worldchat.card',
    hint: context.l10n.worldChatActorCard,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: open ? context.la.accent : context.shellHairline,
            ),
            borderRadius: BorderRadius.circular(6),
            color: open ? context.shellSelected : null,
          ),
          child: Text(
            'i',
            style: LaTokens.mono(
              11,
              open ? context.la.accent : context.la.inkQuiet,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The actor-card popover (the HUD law's other half): the facts a
/// debugger needs, mono 10.5px, one tap away — brain, kind·role,
/// health (the palette rung's own verdict), seat (who owns the loop),
/// thread — plus the room's close affordance (`worldchat.close`, the
/// key's home since ADR 0023). Rows the shell cannot fact are omitted
/// (honest absence, never a guess).
class _ActorCard extends StatelessWidget {
  const _ActorCard({required this.header, required this.onClose});

  final _ConversationHeader header;
  final VoidCallback onClose;

  @override
  Widget build(final BuildContext context) {
    final service = header.service;
    final other = header.other;
    final channel = header.channel;
    final worldState = context.read<WorldStateService?>();
    final rows = <(String, String)>[];
    if (other != null) {
      rows.add(('brain', other.brainRef.isEmpty ? '—' : other.brainRef));
      rows.add(('kind', _kindAndRole(other)));
      final entryId = other.brainRef.startsWith('cast:')
          ? other.brainRef.substring('cast:'.length)
          : null;
      if (entryId != null && worldState != null) {
        for (final rung in worldState.rungs) {
          if (rung.id == entryId) {
            rows.add(('health', rung.healthStatus));
            break;
          }
        }
      }
      rows.add((
        'seat',
        service.daemonOwnsActor(other)
            ? 'daemon-owned'
            : service.daemonBoundActor(other)
            ? 'daemon-bound · asleep'
            : 'app-hosted loop',
      ));
    } else if (channel != null) {
      rows.add((
        'members',
        context.l10n.worldChatMembers(channel.memberIds.length),
      ));
    } else {
      rows.add((
        'participants',
        context.l10n.worldChatParticipants(header.participants.length),
      ));
    }
    final threadId = header.threadId;
    rows.add((
      'thread',
      threadId.length > 12
          ? '…${threadId.substring(threadId.length - 8)}'
          : threadId,
    ));
    return Container(
      key: const ValueKey('worldchat.actorCard'),
      width: 252,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: context.la.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.shellHairline),
        boxShadow: shellFloatingShadow(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 76,
                    child: Text(
                      label,
                      style: LaTokens.mono(10.5, context.la.inkMuted),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: LaTokens.mono(10.5, context.la.ink),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('worldchat.close'),
              onPressed: () {
                onClose();
                unawaited(service.closeThread(header.threadId));
              },
              icon: const Icon(Icons.archive_outlined, size: 15),
              label: Text(context.l10n.worldChatCloseTooltip),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One durable beat: gutter actor label + text on the shared grid.
/// One beat as a message (Discord density, Tufte law): avatar gutter,
/// name + time header on the first line of a group, plain text body —
/// no bubbles; whitespace and the gutter do the grouping.
class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.profile,
    required this.isHuman,
    required this.text,
    required this.showHeader,
    this.at,
    super.key,
  });

  final ActorProfile profile;
  final bool isHuman;
  final String text;
  final String? at;
  final bool showHeader;

  String _timeLabel(final BuildContext context) {
    final raw = at;
    if (raw == null || raw.isEmpty) return '';
    final moment = DateTime.tryParse(raw);
    if (moment == null) return '';
    final local = moment.toLocal();
    final now = DateTime.now();
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final clock =
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return sameDay ? clock : '${local.month}/${local.day} $clock';
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final muted = context.shellMuted;
    final accent = actorColor(profile.actorId);
    final body = Padding(
      padding: const EdgeInsets.only(left: ShellTokens.messageGutter),
      child: Text(text, style: theme.textTheme.bodyMedium),
    );
    if (!showHeader) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: body,
      );
    }
    final time = _timeLabel(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ActorAvatar(profile: profile, size: ShellTokens.messageAvatar),
              const SizedBox(width: 10),
              Text(
                profile.displayName,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isHuman ? theme.colorScheme.primary : accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  time,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          body,
        ],
      ),
    );
  }
}
