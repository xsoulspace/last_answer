import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_profile_editor.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/work_thread_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/shell/landing_inbox.dart';
import 'package:lastanswer/shell/project_scope_picker.dart';
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
/// `worldchat.context`, `worldchat.beat.<threadId>#<n>`, and — with the
/// ADR 0129 work-order seam — `worldchat.scope.*` (the composer's
/// workspace arm), `worldchat.workthread.<workThreadId>` (the parent
/// room's card of a project-sealed child) and `worldchat.spawnRefusal`
/// (the typed refusal with its one-tap grant).
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

        // 2t — ADR 0129 work-thread cards: the parent room's merged
        // view of its project-SEALED children (the owner's auto-spawn
        // decision — the human never manages threads). The card is a
        // pure projection: the registry link plus the threads
        // projection's own last-beat triple (author/text/instant —
        // never invented here), kept live by the journal watch this
        // strip already rides.
        final activeId = service.activeThreadId;
        if (activeId != null) {
          for (final link in service.workThreadsOf(activeId)) {
            Map<String, Object?>? preview;
            for (final row in service.threads) {
              if (row['threadId'] == link.workThreadId) {
                preview = row;
                break;
              }
            }
            rows.add(
              _WorkThreadCard(
                key: ValueKey('worldchat.workthread.${link.workThreadId}'),
                service: service,
                link: link,
                preview: preview,
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
          for (final permission in permissions) {
            // The join law, upgraded by 2c: the ASKING ACTOR's id is
            // the primary fact; the title-name match stays the
            // fallback for registry snapshots that carry no actor
            // identity (the harness gap). The matched actor IS the
            // attribution — the card never says "SYS".
            final title = permission.title.toLowerCase();
            String? matched =
                permission.actorId != null &&
                    actors.contains(permission.actorId)
                ? permission.actorId
                : null;
            if (matched == null) {
              for (final id in actors) {
                final display = (service.roster?.get(id)?.displayName ?? '')
                    .toLowerCase();
                if ((display.isNotEmpty && title.contains(display)) ||
                    title.contains(id.toLowerCase())) {
                  matched = id;
                  break;
                }
              }
            }
            if (matched == null) continue;
            rows.add(
              _PermissionInterrupt(
                key: ValueKey('worldchat.perm.${permission.sessionId}'),
                permission: permission,
                actorName: service.roster?.get(matched)?.displayName ?? matched,
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
/// 2c — the interrupt is an ATTRIBUTED change card: the asking actor's
/// name rides the title (never an anonymous ask), and when the pending
/// round-trip carries the proposed unified diff, one quiet toggle
/// expands it inline (the Replit pattern on the native lane: review the
/// change where the ask lives; Apply/Reject IS the round-trip).
class _PermissionInterrupt extends StatefulWidget {
  const _PermissionInterrupt({
    required this.permission,
    this.actorName,
    super.key,
  });

  final InboxPermission permission;
  final String? actorName;

  @override
  State<_PermissionInterrupt> createState() => _PermissionInterruptState();
}

class _PermissionInterruptState extends State<_PermissionInterrupt> {
  var _diffOpen = false;

  @override
  Widget build(final BuildContext context) {
    final permission = widget.permission;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final diff = permission.diff;
    final actorName = widget.actorName;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: context.la.danger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            permission.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                          if (actorName != null)
                            Text(
                              'proposed by $actorName',
                              key: ValueKey(
                                'worldchat.perm.${permission.sessionId}.actor',
                              ),
                              style: LaTokens.mono(10, context.la.inkMuted),
                            ),
                        ],
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
                if (diff != null && diff.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      key: ValueKey(
                        'worldchat.perm.${permission.sessionId}.diff',
                      ),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _diffOpen = !_diffOpen),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _diffOpen ? 'diff ▾' : 'diff ▸',
                          style: LaTokens.mono(10.5, context.la.accent),
                        ),
                      ),
                    ),
                  ),
                  if (_diffOpen) _UnifiedDiffView(diff: diff),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The unified diff's quiet read (2c): mono 10.5, one bounded scroll
/// region — additions in the accent, removals in the danger color,
/// hunk/file headers quiet. No syntax theater; the diff IS the data.
class _UnifiedDiffView extends StatelessWidget {
  const _UnifiedDiffView({required this.diff});

  final String diff;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: SingleChildScrollView(
        key: const ValueKey('worldchat.diffview'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final line in diff.split('\n'))
              Text(
                line.isEmpty ? ' ' : line,
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: LaTokens.mono(
                  10.5,
                  line.startsWith('+++') || line.startsWith('---')
                      ? la.inkQuiet
                      : line.startsWith('@@')
                      ? la.inkMuted
                      : line.startsWith('+')
                      ? la.accent
                      : line.startsWith('-')
                      ? la.danger
                      : la.ink,
                ),
              ),
          ],
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

  // ---- 1g: the unread divider's capture-at-entry state ----
  // Reading IS the receipt (ADR 0124): the projection's lastReadBeat
  // advances the moment the tail loads, so the pane snapshots the
  // receipt AT ROOM ENTRY and keeps the divider for the whole visit —
  // the boundary between what the human had read and what arrived.
  String? _receiptThreadId;
  int? _dividerBeat;
  int _dividerUnread = 0;

  /// The beat the composer is replying to (1g: replyTo rides the say).
  Map<String, Object?>? _replyBeat;

  // ---- ADR 0129: the work-order scope (the owner's auto-spawn
  // decision — the human never manages threads; arming one workspace
  // scope turns the NEXT send into a work order for it) ----

  /// The armed workspace root, null = plain conversational sends.
  String? _armedScope;

  /// A scoped spawn is in flight (the send button's other spinner half
  /// — `service.sending` covers the plain `say` only).
  bool _spawning = false;

  /// The transient honest status after a landed order (the spawn
  /// result's own fact: fresh thread vs reused workstream).
  String? _scopeStatus;
  Timer? _scopeStatusTimer;

  /// The pending spawn refusal plus the order text it refused (the
  /// one-retry law resends EXACTLY this) and the grant flow's state.
  WorkThreadSpawn? _refusal;
  String? _refusalOrder;
  bool _grantBusy = false;
  bool _grantRetried = false;
  String? _grantOutcome;

  RealmChatService get service => widget.service;
  TextEditingController get composer => widget.composer;

  /// LaWorld when the shell provides it; a hermetic surface without the
  /// projection keeps working (no divider — honest absence, never a
  /// crash: the provider may legitimately not exist outside the shell).
  LaWorld? _laWorldOf(final BuildContext context) {
    try {
      return context.read<LaWorld?>();
    } on ProviderNotFoundException {
      return null;
    }
  }

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

  static String _oneLine(final String raw) {
    final text = raw.replaceAll('\n', ' ');
    const max = 90;
    return text.length <= max ? text : '${text.substring(0, max - 1)}…';
  }

  /// A beat's right-click / long-press (1g): Reply anchors the
  /// composer; Details opens the beat's durable facts (mono, journal
  /// vocabulary — never localized, every value is a fact).
  Future<void> _onBeatContext(
    final Map<String, Object?> beat,
    final Offset globalPosition,
    final String Function(String actorId) displayNameOf,
  ) async {
    final l10n = context.l10n;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        overlay.size.width - globalPosition.dx,
        overlay.size.height - globalPosition.dy,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'reply',
          child: Text(l10n.worldChatBeatReply),
        ),
        PopupMenuItem<String>(
          value: 'details',
          child: Text(l10n.worldChatBeatDetails),
        ),
      ],
    );
    if (!mounted || choice == null) return;
    if (choice == 'reply') {
      setState(() => _replyBeat = beat);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (final dialogContext) => _BeatDetailsDialog(
        beat: beat,
        displayNameOf: displayNameOf,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  Future<void> _send(final String raw) async {
    // ADR 0129 — the scoped send: with a workspace armed, the text is
    // a WORK ORDER (auto-spawn/reuse the project-sealed thread and
    // forward it there), never a beat of this room. Unarmed, the plain
    // `say` is byte-for-byte today's behavior.
    final scope = _armedScope;
    if (scope != null) {
      await _sendWorkOrder(raw, scope);
      return;
    }
    final replyTo = _replyBeat?['beat'] as int?;
    await service.say(raw, replyTo: replyTo);
    if (!mounted) return;
    composer.clear();
    if (_replyBeat != null) setState(() => _replyBeat = null);
  }

  /// The room's ACTOR members — the work order's addressees: the active
  /// thread's participants minus the humans (the human authority's own
  /// id and any rostered [ActorKind.human] participant). Unrostered ids
  /// stay: they were invited as members, and the service remains the
  /// authority on what the harness admits (it drops the human again on
  /// its side).
  List<String> _actorMembers() {
    final human = service.humanActorId;
    final participants =
        (service.activeThread?['participants'] as List? ?? const <Object?>[])
            .cast<String>();
    return <String>[
      for (final id in participants)
        if (id != human && service.roster?.get(id)?.kind != ActorKind.human)
          id,
    ];
  }

  /// The scoped send (ADR 0129's delegation seam, UI half): the spawn
  /// serializes per reuse key inside the service, so a double-tap here
  /// cannot mint two threads either. On success the composer clears and
  /// the scope STAYS armed (a workstream continues — the owner's
  /// decision); on refusal the typed result renders with its own
  /// evidence and the composer KEEPS the order text (nothing is lost).
  Future<void> _sendWorkOrder(final String raw, final String scope) async {
    final parent = service.activeThreadId;
    final order = raw.trim();
    if (parent == null || order.isEmpty || _spawning) return;
    setState(() {
      _spawning = true;
      _refusal = null;
      _refusalOrder = null;
      _grantOutcome = null;
      _grantRetried = false;
    });
    final spawn = await service.spawnWorkThread(
      parentThreadId: parent,
      projectRoot: scope,
      memberIds: _actorMembers(),
      orderText: order,
    );
    if (!mounted) return;
    if (spawn.refusal != null) {
      setState(() {
        _spawning = false;
        _refusal = spawn;
        _refusalOrder = order;
      });
      return;
    }
    composer.clear();
    setState(() {
      _spawning = false;
      _replyBeat = null;
    });
    _announceScopeStatus(spawn);
  }

  /// The order's transient honest status: the spawn result's own fact
  /// (fresh thread vs reused workstream) in the room's words, self-
  /// clearing. A quiet text line, not a pulse — the chrome layer has no
  /// attention-seeking animation (DESIGN v2 motion law), so the announce
  /// IS the "new work card" signal and the card itself carries the live
  /// preview from then on.
  void _announceScopeStatus(final WorkThreadSpawn spawn) {
    final l10n = context.l10n;
    final name = spawn.workThread?.name ?? '';
    _scopeStatusTimer?.cancel();
    setState(() {
      _scopeStatus = spawn.reused
          ? l10n.worldChatWorkOrderSent(name)
          : l10n.worldChatWorkThreadOpened(name);
    });
    _scopeStatusTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _scopeStatus = null);
    });
  }

  /// Opens the ADR 0129 scope picker (the human's durable grants ∪ the
  /// workspace folders — an ungranted folder stays selectable; the
  /// refusal flow owns that honesty).
  Future<void> _openScopePicker() async {
    final title = context.l10n.worldChatScopePickTitle;
    final picked = await pickProjectScope(
      context,
      service: service,
      title: title,
      optionKeyPrefix: 'worldchat.scope.option',
      listKey: 'worldchat.scope.picker',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _armedScope = picked;
      _refusal = null;
      _refusalOrder = null;
      _grantOutcome = null;
      _grantRetried = false;
    });
  }

  /// The one-tap grant + ONE automatic retry (the owner's
  /// everything-from-LA decision): [RealmChatService.grantAccess] runs
  /// the host's canonical `grantProjectAccess` with the VERIFY re-read,
  /// and only a VERIFIED grant retries the refused order — exactly
  /// once. A refused grant or a refused retry renders the message
  /// verbatim and stops; there is no second automatic attempt.
  Future<void> _grantAndRetry() async {
    final refusal = _refusal;
    final human = service.humanActorId;
    final parent = service.activeThreadId;
    final project = refusal?.requestedProject;
    if (refusal == null || human == null || parent == null || project == null) {
      return;
    }
    setState(() => _grantBusy = true);
    final grant = await service.grantAccess(human, project);
    if (!mounted) return;
    if (!grant.granted) {
      setState(() {
        _grantBusy = false;
        _grantOutcome = grant.message;
      });
      return;
    }
    final spawn = await service.spawnWorkThread(
      parentThreadId: parent,
      projectRoot: project,
      memberIds: _actorMembers(),
      orderText: _refusalOrder,
    );
    if (!mounted) return;
    if (spawn.refusal == null) {
      composer.clear();
      setState(() {
        _spawning = false;
        _grantBusy = false;
        _refusal = null;
        _refusalOrder = null;
        _grantOutcome = null;
        _replyBeat = null;
      });
      _announceScopeStatus(spawn);
      return;
    }
    setState(() {
      _grantBusy = false;
      _grantRetried = true;
      _refusal = spawn;
      _grantOutcome = spawn.message;
    });
  }

  @override
  void dispose() {
    _scopeStatusTimer?.cancel();
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
    // 1g — capture the receipt AT ENTRY: the build right after
    // selectThread runs before the async tail read writes the new
    // receipt, so this snapshot is the pre-visit read position.
    if (threadId != _receiptThreadId) {
      _receiptThreadId = threadId;
      final receipt = _laWorldOf(context)?.roomReceipt(threadId);
      _dividerBeat = receipt?.lastReadBeat ?? 0;
      _dividerUnread = receipt?.unread ?? 0;
      _replyBeat = null;
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
    // ADR 0129 — with a scope armed the composer writes WORK ORDERS,
    // and its hint says so (the chip names the scope; the hint names
    // the mode).
    final composerHint = _armedScope != null
        ? l10n.worldChatWorkOrderHint
        : channel != null
        ? l10n.worldChatMessageHint('#${channel.name}')
        : dmOther != null
        ? l10n.worldChatMessageHint(displayNameOf(dmOther))
        : l10n.worldChatComposerHint;
    final beats = service.beats;
    // The send button's busy truth: a plain `say` in flight (the
    // service's flag) or a scoped spawn (this pane's flag).
    final sendBusy = service.sending || _spawning;
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
          // The strip (work cards, 0c interrupts, narration) renders
          // EVEN in a beat-less room: a fresh general room whose first
          // send auto-spawned a work thread has no parent beats yet —
          // and the merged view (the owner's auto-spawn law) is exactly
          // the card in that empty room. The first-word note sits
          // BEHIND the list then, not instead of it.
          child: Stack(
            children: [
              if (beats.isEmpty)
                _CenteredNote(text: l10n.worldChatFirstWord),
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
                          // 1g — the replyTo quote: the referenced beat
                          // when the loaded window carries it, an
                          // honest "#n" when it does not (the tail page
                          // is a window, not the room).
                          final replyNum = beat['replyTo'] as int?;
                          String? replyQuote;
                          if (replyNum != null) {
                            final target = beats.firstWhereOrNull(
                              (final candidate) =>
                                  candidate['beat'] == replyNum,
                            );
                            replyQuote = target == null
                                ? '#$replyNum'
                                : '${displayNameOf(target['author']! as String)}: '
                                      '${_oneLine('${target['text'] ?? ''}')}';
                          }
                          // 1g — addressedTo chips: only a PROPER
                          // SUBSET of the other participants is a
                          // mention worth showing; addressing everyone
                          // is the default, not a fact.
                          final addressed =
                              (beat['addressedTo'] as List? ??
                                      const <Object?>[])
                                  .cast<String>();
                          final chips =
                              addressed.length < participants.length - 1
                              ? [
                                  for (final id in addressed)
                                    (id: id, name: displayNameOf(id)),
                                ]
                              : const <({String id, String name})>[];
                          final row = _MessageRow(
                            key: ValueKey(
                              'worldchat.beat.$threadId#${beat['beat']}',
                            ),
                            profile: profile,
                            isHuman: author == service.humanActorId,
                            text: beat['text']! as String,
                            at: beat['at'] as String?,
                            showHeader: !grouped,
                            replyQuote: replyQuote,
                            replyQuoteKey: replyNum == null
                                ? null
                                : ValueKey(
                                    'worldchat.quote.$threadId#$replyNum',
                                  ),
                            addressedChips: chips,
                          );
                          // The beat's context affordance (1g): a
                          // right-click / long-press opens Reply and
                          // the durable-facts popover.
                          final contextual = GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onSecondaryTapUp: (final details) => _onBeatContext(
                              beat,
                              details.globalPosition,
                              displayNameOf,
                            ),
                            onLongPressEnd: (final details) => _onBeatContext(
                              beat,
                              details.globalPosition,
                              displayNameOf,
                            ),
                            child: row,
                          );
                          // 1g — the "N new" divider: under the newest
                          // beat the human had read at entry (unread
                          // messages follow it downward), captured once
                          // per visit; never for a never-read room (the
                          // badge already says "all of it is new").
                          final dividerBeat = _dividerBeat;
                          if (dividerBeat != null &&
                              dividerBeat > 0 &&
                              _dividerUnread > 0 &&
                              beat['beat'] == dividerBeat) {
                            return Column(
                              key: const ValueKey('worldchat.unreadDivider'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                contextual,
                                _UnreadDivider(count: _dividerUnread),
                              ],
                            );
                          }
                          return contextual;
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
        // 1g — the reply anchor: a quiet strip naming the beat the
        // next word answers (cancel returns to the plain say).
        if (_replyBeat != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Container(
              key: const ValueKey('worldchat.replying'),
              padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
              decoration: BoxDecoration(
                color: context.shellField,
                borderRadius: BorderRadius.circular(ShellTokens.radius),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 14, color: context.shellMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.worldChatReplyingTo(displayNameOf(_replyBeat!['author']! as String))}: ${_oneLine('${_replyBeat!['text'] ?? ''}')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.shellMuted,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('worldchat.replying.close'),
                    visualDensity: VisualDensity.compact,
                    iconSize: 14,
                    tooltip: l10n.worldChatCancelReply,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _replyBeat = null),
                  ),
                ],
              ),
            ),
          ),
        // ADR 0129 — the armed workspace scope: the visible,
        // dismissible arm state of the auto-spawn decision. With it
        // armed, Send routes the text as a work order through
        // `spawnWorkThread`; one tap on the chip clears the arm and
        // Send returns to the plain `say`.
        if (_armedScope != null)
          _ScopeChip(
            scope: _armedScope!,
            onClear: () => setState(() => _armedScope = null),
          ),
        // The spawn refusal IN the room (the 0c discipline): the typed
        // result's own evidence, verbatim. `project_not_granted` offers
        // the one-tap grant + ONE automatic retry; every other refusal
        // renders name + message honestly, no retry.
        if (_refusal != null)
          _SpawnRefusalCard(
            spawn: _refusal!,
            busy: _grantBusy,
            retried: _grantRetried,
            outcome: _grantOutcome,
            onGrant: () => unawaited(_grantAndRetry()),
            onDismiss: () => setState(() {
              _refusal = null;
              _refusalOrder = null;
              _grantOutcome = null;
              _grantRetried = false;
            }),
          ),
        // The landed order's transient honest status (fresh vs reused —
        // the spawn result's own fact, never an invention).
        if (_scopeStatus != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              _scopeStatus!,
              key: const ValueKey('worldchat.scope.status'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.shellMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
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
                // ADR 0129 — the scope arm: one tap opens the project
                // picker (the human's grants ∪ the workspace folders);
                // the armed chip above the composer names the scope and
                // dismisses it. The accent icon is a second carrier,
                // never the only one (the chip is the visible state).
                IconButton(
                  key: const ValueKey('worldchat.scope.toggle'),
                  tooltip: l10n.worldChatScopeArm,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  icon: Icon(
                    Icons.folder_outlined,
                    color: _armedScope != null
                        ? context.la.accent
                        : context.shellMuted,
                  ),
                  onPressed: () => unawaited(_openScopePicker()),
                ),
                Expanded(
                  child: Semantics(
                    label: 'worldchat.composer',
                    child: TextField(
                      key: const ValueKey('worldchat.composer'),
                      controller: composer,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (final value) => unawaited(_send(value)),
                      decoration: InputDecoration(
                        hintText: composerHint,
                        border: InputBorder.none,
                        isDense: true,
                        filled: false,
                      ),
                    ),
                  ),
                ),
                // The send's other busy half: a scoped spawn in flight
                // (the service's `sending` flag covers the plain say).
                IconButton(
                  key: const ValueKey('worldchat.send'),
                  tooltip: l10n.worldChatSend,
                  icon: sendBusy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_upward, size: 18),
                  onPressed: sendBusy
                      ? null
                      : () => unawaited(_send(composer.text)),
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
                color: const Color(0x00000000),
                onDismiss: () {
                  if (mounted) setState(_removeCard);
                },
              ),
            ),
            Positioned.fill(
              child: CompositedTransformFollower(
                link: _cardLink,
                // The HUD's identity cluster sits at the LEFT edge, so
                // the card hangs from its bottom-left corner rightward
                // (the right-anchored recipe belongs to the picker on
                // the strip's right edge — one law, two edges).
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
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
/// (honest absence, never a guess). 1b: the card is also where the
/// human TUNES the actor from conversation context — Edit switches the
/// card in place to [ActorProfileEditor] (no modals anywhere, the
/// editor's own law); Save routes through `updateActor` and closes the
/// card (the reopened card reads the fresh facts).
class _ActorCard extends StatefulWidget {
  const _ActorCard({required this.header, required this.onClose});

  final _ConversationHeader header;
  final VoidCallback onClose;

  @override
  State<_ActorCard> createState() => _ActorCardState();
}

class _ActorCardState extends State<_ActorCard> {
  var _editing = false;

  _ConversationHeader get header => widget.header;
  VoidCallback get onClose => widget.onClose;

  /// The hosted-model option the brain pickers offer (the actors-pane
  /// derivation; absence keeps the local casts only).
  static String _defaultOpenRouterModel(final BuildContext context) {
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

  @override
  Widget build(final BuildContext context) {
    final service = header.service;
    final other = header.other;
    final channel = header.channel;
    final worldState = context.read<WorldStateService?>();
    if (_editing && other != null) {
      return Container(
        key: const ValueKey('worldchat.actorCard'),
        width: 252,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        decoration: _decoration(context),
        // The overlay floats above the Scaffold's Material — the
        // editor's fields need their own sheet (transparent: the
        // card's decoration stays the visible surface).
        child: Material(
          type: MaterialType.transparency,
          child: ActorProfileEditor(
            profile: other,
            brainOptions: availableBrainOptions(
              defaultOpenRouterModel: _defaultOpenRouterModel(context),
              paletteRungs: worldState?.generativeDecls ?? const [],
            ),
            saveKey: const ValueKey('worldchat.card.save'),
            onCancel: () => setState(() => _editing = false),
            onSave:
                ({
                  required final String displayName,
                  required final String role,
                  required final String systemPrompt,
                  required final String brainRef,
                }) {
                  unawaited(
                    service
                        .updateActor(
                          actorId: other.actorId,
                          displayName: displayName,
                          role: role,
                          systemPrompt: systemPrompt,
                          brainRef: brainRef,
                        )
                        .then((final _) => onClose()),
                  );
                },
          ),
        ),
      );
    }
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
      decoration: _decoration(context),
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
          // The affordance row WRAPS: two honest labels never fit one
          // 252px line — an overflow stripe is louder than a second
          // row (calm chrome).
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 4,
            runSpacing: 2,
            children: [
              if (other != null)
                TextButton.icon(
                  key: const ValueKey('worldchat.card.edit'),
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: Text(context.l10n.actorsEditTooltip),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              TextButton.icon(
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
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoration(final BuildContext context) => BoxDecoration(
    color: context.la.surfaceRaised,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: context.shellHairline),
    boxShadow: shellFloatingShadow(context),
  );
}

/// One durable beat: gutter actor label + text on the shared grid.
/// One beat as a message (Discord density, Tufte law): avatar gutter,
/// name + time header on the first line of a group, plain text body —
/// no bubbles; whitespace and the gutter do the grouping. 1g adds the
/// conversational facts the substrate already carries: the replyTo
/// quote above the body and addressedTo chips beside the name (a
/// proper subset only — addressing everyone is the default).
class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.profile,
    required this.isHuman,
    required this.text,
    required this.showHeader,
    this.at,
    this.replyQuote,
    this.replyQuoteKey,
    this.addressedChips = const <({String id, String name})>[],
    super.key,
  });

  final ActorProfile profile;
  final bool isHuman;
  final String text;
  final String? at;
  final bool showHeader;
  final String? replyQuote;
  final Key? replyQuoteKey;
  final List<({String id, String name})> addressedChips;

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

  Widget? _quote(final BuildContext context) {
    final quote = replyQuote;
    if (quote == null) return null;
    return Padding(
      padding: const EdgeInsets.only(
        left: ShellTokens.messageGutter,
        bottom: 3,
      ),
      child: Container(
        key: replyQuoteKey,
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: context.shellHairline, width: 2),
          ),
        ),
        child: Text(
          quote,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.shellMuted),
        ),
      ),
    );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [if (replyQuote != null) _quote(context)!, body],
        ),
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
              for (final chip in addressedChips) ...[
                const SizedBox(width: 6),
                Text(
                  '@${chip.name}',
                  key: ValueKey('worldchat.addressed.${chip.id}'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: actorColor(chip.id),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          if (replyQuote != null) _quote(context)!,
          body,
        ],
      ),
    );
  }
}

/// The 1g "N new" divider: one quiet accent rule with the count — the
/// boundary between the beats the human had read at entry and the ones
/// that arrived while away. Calm chrome: no pill, no danger color; the
/// accent says "this is new", nothing shouts.
class _UnreadDivider extends StatelessWidget {
  const _UnreadDivider({required this.count});
  final int count;

  @override
  Widget build(final BuildContext context) {
    final accent = context.la.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: accent)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              context.l10n.worldChatUnreadDivider(count),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: accent)),
        ],
      ),
    );
  }
}

/// The beat's durable facts (1g's per-beat detail popover): journal
/// vocabulary in mono — field names, never localized, because every
/// value is a durable fact (the actor-card law, one scale down).
class _BeatDetailsDialog extends StatelessWidget {
  const _BeatDetailsDialog({
    required this.beat,
    required this.displayNameOf,
    required this.onClose,
  });

  final Map<String, Object?> beat;
  final String Function(String actorId) displayNameOf;
  final VoidCallback onClose;

  @override
  Widget build(final BuildContext context) {
    final addressed = (beat['addressedTo'] as List? ?? const <Object?>[])
        .cast<String>()
        .map(displayNameOf)
        .join(', ');
    final facts = <(String, String)>[
      ('beat', '${beat['beat'] ?? ''}'),
      (
        'author',
        '${displayNameOf('${beat['author'] ?? ''}')} · ${beat['author'] ?? ''}',
      ),
      ('at', '${beat['at'] ?? ''}'),
      if (addressed.isNotEmpty) ('addressedTo', addressed),
      if (beat['replyTo'] != null) ('replyTo', '#${beat['replyTo']}'),
    ];
    return Dialog(
      key: const ValueKey('worldchat.beatDetails'),
      backgroundColor: context.shellRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ShellTokens.radius + 2),
        side: BorderSide(color: context.shellHairline),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.worldChatBeatDetails,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              for (final (label, value) in facts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 84,
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
                child: TextButton(
                  key: const ValueKey('worldchat.beatDetails.close'),
                  onPressed: onClose,
                  child: Text(context.l10n.worldChatCloseTooltip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ADR 0129 — one work-thread card: the parent room's merged view of a
/// project-sealed child (the owner's auto-spawn decision — the human
/// never manages threads, LA renders the link). The name is the link's
/// own (the project basename, the full root on the tooltip), the
/// preview is the threads projection's last-beat triple (author · text ·
/// instant — the projection carries it, and the journal watch the strip
/// already rides keeps it live); OPEN selects the child through the
/// existing room-selection route (`selectThread`, the landing inbox's
/// own). No new rendering plane: the card is a pure projection of the
/// durable link + the existing thread preview.
class _WorkThreadCard extends StatelessWidget {
  const _WorkThreadCard({
    required this.service,
    required this.link,
    this.preview,
    super.key,
  });

  final RealmChatService service;
  final WorkThreadLink link;

  /// The child's thread-projection row (`lastBeatAuthor`/`lastBeatText`/
  /// `lastBeatAt`), null until the projection carries it — honest
  /// absence; the card keeps the link facts either way.
  final Map<String, Object?>? preview;

  /// The last-beat instant in the message row's own time vocabulary
  /// (HH:MM same day, M/D HH:MM otherwise).
  static String _instant(final String raw) {
    final moment = DateTime.tryParse(raw);
    if (moment == null) return '';
    final local = moment.toLocal();
    final now = DateTime.now();
    final clock =
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    return sameDay ? clock : '${local.month}/${local.day} $clock';
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final id = link.workThreadId;
    final author = preview?['lastBeatAuthor'] as String?;
    final text = preview?['lastBeatText'] as String?;
    final at = preview?['lastBeatAt'] as String?;
    final hasPreview = author != null && text != null && text.isNotEmpty;
    final authorName = author == null
        ? ''
        : service.roster?.get(author)?.displayName ??
              actorDisplayFallback(author);
    return Semantics(
      label: 'worldchat.workthread.$id',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.shellHairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.alt_route, size: 14, color: context.la.accent),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Tooltip(
                        message: link.projectRoot,
                        child: Text(
                          link.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.la.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // The kind word: the card's type never rides the
                    // color or the icon alone (DESIGN a11y law).
                    Text(
                      l10n.worldChatWorkThreadKind,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.shellMuted,
                      ),
                    ),
                    const Spacer(),
                    _StripButton(
                      keyName: 'worldchat.workthread.open.$id',
                      label: l10n.worldChatOpen,
                      onTap: () => service.selectThread(link.workThreadId),
                    ),
                  ],
                ),
                if (hasPreview)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$authorName: $text',
                            key: ValueKey(
                              'worldchat.workthread.preview.$id',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: context.shellMuted,
                            ),
                          ),
                        ),
                        if (at != null && _instant(at).isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            _instant(at),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: context.la.inkQuiet,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ADR 0129 — the armed workspace scope above the composer: the visible
/// half of the auto-spawn decision. The chip names the scope (basename +
/// the durable root in mono) and is dismissible — one tap anywhere on it
/// (or its ×) clears the arm and Send returns to the plain `say`. The
/// reply-anchor strip's grammar, one fact swapped in.
class _ScopeChip extends StatelessWidget {
  const _ScopeChip({required this.scope, required this.onClear});

  final String scope;
  final VoidCallback onClear;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onClear,
        child: Container(
          key: const ValueKey('worldchat.scope.armed'),
          padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_outlined, size: 14, color: context.la.accent),
              const SizedBox(width: 8),
              Text(
                projectScopeDisplayName(scope),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: context.la.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scope,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaTokens.mono(10, context.shellMuted),
                ),
              ),
              IconButton(
                key: const ValueKey('worldchat.scope.clear'),
                visualDensity: VisualDensity.compact,
                iconSize: 14,
                tooltip: l10n.worldChatScopeDismiss,
                icon: const Icon(Icons.close),
                onPressed: onClear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ADR 0129 — the spawn refusal in the room, following the 0c
/// permission-interrupt discipline (danger hairline on the shell field,
/// the safe action leftmost): the typed result's OWN evidence renders
/// verbatim — refusal name, requested project, the current grants, the
/// message — never paraphrased friendlier. `project_not_granted` adds
/// the one-tap grant (the owner's everything-from-LA decision): a
/// VERIFIED grant retries the refused order exactly ONCE; a refused
/// grant or a refused retry shows the honest message and stops.
class _SpawnRefusalCard extends StatelessWidget {
  const _SpawnRefusalCard({
    required this.spawn,
    required this.busy,
    required this.retried,
    required this.outcome,
    required this.onGrant,
    required this.onDismiss,
  });

  final WorkThreadSpawn spawn;
  final bool busy;

  /// The one-retry law: after the automatic retry refused, the grant
  /// action does not render again — the message stands verbatim.
  final bool retried;

  /// The grant flow's own outcome line (the host's message, verbatim).
  final String? outcome;
  final VoidCallback onGrant;
  final VoidCallback onDismiss;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final needsGrant = spawn.refusal == 'project_not_granted' && !retried;
    final title = spawn.refusal == 'project_not_granted'
        ? l10n.worldChatGrantNeeded
        : l10n.worldChatWorkOrderRefused;
    // Journal vocabulary in mono (the beat-details law): field names are
    // never localized; every value is the typed result's own.
    final facts = <(String, String)>[
      ('refusal', spawn.refusal ?? ''),
      if (spawn.requestedProject != null) ('project', spawn.requestedProject!),
      ('grants', spawn.grants.isEmpty ? '—' : spawn.grants.join('\n')),
      if (spawn.message != null) ('message', spawn.message!),
      if (outcome != null) ('outcome', outcome!),
    ];
    return Semantics(
      label: 'worldchat.spawnRefusal',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.la.danger),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Column(
              key: const ValueKey('worldchat.spawnRefusal'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: context.la.danger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                for (final (label, value) in facts)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 62,
                          child: Text(
                            label,
                            style: LaTokens.mono(10.5, context.la.inkMuted),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            value,
                            key: label == 'grants'
                                ? const ValueKey(
                                    'worldchat.spawnRefusal.grants',
                                  )
                                : null,
                            style: LaTokens.mono(
                              10.5,
                              label == 'outcome'
                                  ? context.la.danger
                                  : context.la.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _StripButton(
                      keyName: 'worldchat.spawnRefusal.dismiss',
                      label: l10n.worldChatCancel,
                      onTap: onDismiss,
                    ),
                    if (needsGrant) ...[
                      const SizedBox(width: 6),
                      _StripButton(
                        keyName: 'worldchat.spawnRefusal.grant',
                        label: busy
                            ? l10n.worldChatGrantGranting
                            : l10n.worldChatGrantAction,
                        onTap: busy ? () {} : onGrant,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
