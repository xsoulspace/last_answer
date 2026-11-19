import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:lastanswer/ui_models/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/media_asset_card.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_profile_editor.dart';
import 'package:lastanswer/coding_agent/realm_chat/beat_linkify.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_members_ui.dart';
import 'package:lastanswer/coding_agent/realm_chat/conversation_spaces.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_media.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/work_thread_spawn.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/coding_agent/subscription_provider.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/ui_shell/landing_inbox.dart';
import 'package:lastanswer/ui_shell/project_scope_picker.dart';
import 'package:lastanswer/ui_shell/shell_scope.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show
        ActorGrantCaps,
        ActorScopeGrant,
        grantScopePathOf,
        mediaAttachmentOf,
        resolveConversationMediaPath;

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
/// ADR 0129 work-order seam — `worldchat.scope.*` (the armed-scope chip;
/// the arm itself rides the Wave E attach menu's Work order row),
/// `worldchat.workthread.<workThreadId>` (the parent room's card of a
/// project-sealed child) and `worldchat.spawnRefusal` (the typed refusal
/// with its one-tap grant).
///
/// Wave E keys: `worldchat.attach` (the composer's ONE attach/mention
/// menu — merged mentionables + the image row + the work-order lane +
/// named absences), `worldchat.meta.{perms,members,info}` (the channel's
/// meta row above the composer), `worldchat.mentionOverlay` (the `@`
/// completion panel), and the per-beat hover cluster
/// `worldchat.beat.{reply,edit,thread,menu}.<threadId>#<n>`.
/// The MESSENGER MEDIA law (2026-11-18): the composer's own field is a
/// drop target — OS-dragged images stage as pending attachments
/// (`worldchat.mediaStrip` + `worldchat.mediaChip.<n>[.remove]`) and
/// ride the NEXT send with the text; picking an image from the attach
/// menu stages the same way. Nothing sends on pick/drop alone.
/// The CHANNEL and DM panes' THREADS BROWSER (owner law 2026-11-16:
/// rooms left the rooms column and surface Discord-threads-style INSIDE
/// the channel view; owner decision 2026-11-16: people (dms) too —
/// just talking with one actor can do some work too):
/// `worldchat.threads.toggle` (the header affordance),
/// `worldchat.threads.panel` (the compact drawer with its labelled
/// groups) and the rows `worldchat.threads.row.work.<workThreadId>` /
/// `worldchat.threads.row.room.<threadId>` — every row opens its
/// `room:<id>` tab through the shell's ONE router.
/// The thread-open lane (the Wave H regression pin, 2026-11-10):
/// inside the shell, opening a thread ROUTES its `room:<id>` tab —
/// a bare `selectThread` moves no pane anymore, because panes render
/// their OWN thread (the pane-instance law); the landing inbox's
/// rows, the work-thread cards' Open button and the threads browser's
/// rows all ride here.
/// Single-pane hosts (no [ViewScope]) fall back to selecting the
/// global active thread — today's behavior for them.
void openThreadLane(
  final BuildContext context,
  final RealmChatService service,
  final String threadId,
) {
  final routed = ViewScope.of(context)?.onOpenThread;
  if (routed != null) {
    routed(threadId);
    return;
  }
  service.selectThread(threadId);
}

// Wave K's `chromeIconButtonStyle` retired with the ui-kit sweep: the
// chat chrome's icon buttons are `LaButton.icon` now — the kit's
// LaPressable owns the hover/press treatment (DESIGN v6: the kit is the
// component carrier), so there is no ButtonStyle left to share.

final class WorldChatSurface extends StatefulWidget {
  const WorldChatSurface({
    this.service,
    this.onTapActor,
    this.surfaceId,
    super.key,
  });

  /// Test seam; production resolves through DI.
  final RealmChatService? service;

  /// Wave E — where a tapped actor goes (the channel-members popover):
  /// the host's decision (focus the people view, open the DM, …). Null
  /// falls back to the shell's [ViewScope.onFocusActor] when the surface
  /// is hosted inside the shell; outside it a tap only closes the
  /// popover (honest absence, never a crash).
  final void Function(String actorId)? onTapActor;

  /// Wave H — the PANE-INSTANCE law: the conversation surface id this
  /// pane renders (`channel:<id>` / `dm:<actor>` / `room:<threadId>`),
  /// resolved through [RealmChatService.threadIdForSurface] — the ONE
  /// resolver, shared with the shell's activation lane. Null keeps
  /// today's behavior byte-identical: the pane follows the service's
  /// GLOBAL active thread. Non-null, the pane renders its OWN thread —
  /// header, beats, composer target, meta row — even while another
  /// pane's thread holds the service's focus (the 2026-11-10 defect:
  /// two visible conversation tabs both rendered the active thread).
  /// Selection still follows focus (the activation lane selects the
  /// activated tab's thread — unread/receipts law unchanged); only the
  /// RENDERING is per instance.
  final String? surfaceId;

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
      return const Center(child: LaSpinner());
    }
    return _ConversationPane(
      service: service,
      composer: _composer,
      onTapActor: widget.onTapActor,
      surfaceId: widget.surfaceId,
    );
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
        style: TextStyle(color: context.laUi.inkMuted),
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
  const _WorkStrip({
    required this.service,
    required this.threadId,
    required this.participants,
  });

  final RealmChatService service;

  /// Wave H — the PANE's thread (the surface id's own resolution, or
  /// the service's active thread for a null-surfaceId pane): the work-
  /// thread cards are the children of the room being RENDERED, never of
  /// whichever room happens to hold the global focus.
  final String threadId;
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
        // strip already rides. Wave H: the parent is the PANE's thread.
        final paneThreadId = widget.threadId;
        for (final link in service.workThreadsOf(paneThreadId)) {
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
    final laUi = context.laUi;
    final profile = service.roster?.get(actorId);
    final name = profile?.displayName ?? actorDisplayFallback(actorId);
    final line = narration.statusLine ?? narration.state.name;
    return Semantics(
      label: 'worldchat.narration.$actorId',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
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
                style: laUi.compact.copyWith(
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
    final laUi = context.laUi;
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
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.shellHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LaPressable(
                key: ValueKey('worldchat.work.expand.${task.taskId}'),
                onTap: onToggle,
                scaleOnPress: false,
                radius: BorderRadius.circular(ShellTokens.radius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: stateColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.task,
                          maxLines: expanded ? 4 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: laUi.compact.copyWith(color: context.la.ink),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.state,
                        style: laUi.micro.copyWith(
                          color: stateColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        expanded
                            ? Icons.expand_less_outlined
                            : Icons.expand_more_outlined,
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
                        _factLine(laUi, context, 'rung · ${task.modelId}'),
                      if (telemetry != null)
                        _factLine(laUi, context, () {
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
                      if (task.at != null) _factLine(laUi, context, task.at!),
                      if (verdict != null) ...[
                        if (verdict.spend != null && verdict.spend!.isNotEmpty)
                          _factLine(laUi, context, 'spend · ${verdict.spend}'),
                        if (verdict.line.isNotEmpty)
                          _factLine(laUi, context, verdict.line),
                      ] else if (task.summary != null &&
                          task.summary!.isNotEmpty)
                        _factLine(laUi, context, task.summary!),
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
    final LaUiTheme laUi,
    final BuildContext context,
    final String text,
  ) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      text,
      // Wave K: the card's preview/fact lines stay ONE line, ellipsized
      // in the muted tone — the expanded card never grows a text wall.
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: laUi.micro.copyWith(
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
    final laUi = context.laUi;
    final diff = permission.diff;
    final actorName = widget.actorName;
    return Semantics(
      label: 'worldchat.perm.${permission.sessionId}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.la.danger),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            style: laUi.compact,
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
                    const SizedBox(width: 4),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: danger ? context.la.danger : context.shellHairline,
            ),
          ),
          child: Text(
            label,
            style: context.laUi.micro.copyWith(
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
    final laUi = context.laUi;
    final arming = world.armState == WorldArmState.arming;
    return Semantics(
      label: 'worldchat.daemonAbsent',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.power_settings_new_outlined,
              size: 13,
              color: context.la.caution,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$name · ${l10n.inboxWorldDown}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: laUi.compact.copyWith(
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
                    style: laUi.micro.copyWith(color: context.la.danger),
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
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: LaButton(
          variant: LaButtonVariant.ghost,
          size: LaButtonSize.sm,
          onPressed: onTap,
          child: Text(
            label,
            style: context.laUi.micro.copyWith(
              fontSize: 12,
              color: context.shellMuted,
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
            Icons.arrow_downward_outlined,
            size: 16,
            color: context.shellMuted,
          ),
        ),
      ),
    ),
  );
}

class _ConversationPane extends StatefulWidget {
  const _ConversationPane({
    required this.service,
    required this.composer,
    this.onTapActor,
    this.surfaceId,
  });
  final RealmChatService service;
  final TextEditingController composer;
  final void Function(String actorId)? onTapActor;

  /// Wave H — the pane-instance law (see [WorldChatSurface.surfaceId]):
  /// null = the service's global active thread (today's behavior);
  /// non-null = this pane's OWN thread, resolved through the service's
  /// ONE [RealmChatService.threadIdForSurface] helper.
  final String? surfaceId;

  @override
  State<_ConversationPane> createState() => _ConversationPaneState();
}

class _ConversationPaneState extends State<_ConversationPane> {
  /// The reversed list's controller: offset 0 = the newest beat (the
  /// bottom). An endless room lives at its tail; scrolling UP walks
  /// into history and triggers the window walk — the pane-local
  /// [_loadOlderOwnBeats] for a pinned pane, the service's
  /// [RealmChatService.loadOlderBeats] for the active-thread pane.
  final ScrollController _scroll = ScrollController();
  bool _showJumpToLatest = false;

  /// The channel view's threads browser (owner law 2026-11-16): the
  /// panel's open/closed is the ONLY state this affordance keeps — the
  /// rows inside read the service's live getters on every rebuild (the
  /// service's notify is the freshness signal; no caching, no polling).
  bool _threadsOpen = false;

  /// The composer's focus node (the first-entry law): landing in a room
  /// — boot-restored, seeded or clicked — puts the caret in the
  /// composer without a click. Focus is requested post-frame and NEVER
  /// stolen from another EditableText mid-edit (the shell anchor's
  /// `_reclaimFocusUnlessEditing` law, mirrored).
  final FocusNode _composerFocus = FocusNode(debugLabel: 'worldchat.composer');

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

  /// The last human-share refusal (named; rendered beside the composer).
  String? _shareError;

  // ---- The messenger media law (2026-11-18) ----
  // The composer STAGES images instead of sending them outright: a pick
  // from the attach menu or an OS drop on the field lands here as
  // pending media v1 entries, the strip renders them above the
  // composer, and Send carries them with the text (the messenger
  // flow). [_pendingMedia] clears on thread switch (attachments belong
  // to the room being answered) and after a plain send.
  final List<RealmStagedMedia> _pendingMedia = [];

  /// A drag hovers the composer field (the accent-border state).
  bool _dropHover = false;

  // ---- Wave E: the `@` mention completion state ----
  // Typing `@` at a word boundary opens the filtered overlay above the
  // composer; [_mentionStart] is the index of the `@` the partial token
  // began at, so picking a row replaces exactly `@partial` with the
  // mention token. Null query = the overlay is closed.

  /// The partial token after the live `@`, null = no completion open.
  String? _mentionQuery;
  int _mentionStart = -1;

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

  // ---- Wave H: the pane's OWN thread and its beats window ----
  // A surfaceId-pinned pane renders its own thread: its beats come
  // from the PURE `beatsFor` read (re-scheduled on every rebuild — the
  // service notifies on journal refreshes, so the pane never goes
  // stale), never from the active-thread `service.beats` cache. The
  // tail-window/pagination arithmetic mirrors the service's cache
  // ([RealmChatService.tailPageSize], prepend-only) per pane. A
  // null-surfaceId pane keeps reading the service cache — byte-for-byte
  // today's behavior.

  /// The thread the own-beats cache belongs to (null = none loaded).
  String? _ownThreadId;

  /// The pane's thread's full folded beats (oldest → newest), from the
  /// pure windowed read.
  List<Map<String, Object?>> _ownAll = const <Map<String, Object?>>[];

  /// The pane-local window start into [_ownAll] (null = not normalized
  /// yet; the landing read normalizes it to the tail page, exactly like
  /// the service's `_refreshBeats`).
  int? _ownWindowStart;

  /// The cheap content signature of [_ownAll] (count + first/last beat
  /// numbers — the journal is append-only, so any change moves one of
  /// them): an unchanged read skips the rebuild, so the build-scheduled
  /// read never loops with its own setState.
  String _ownSignature = '';

  /// The stale-read guard: only the newest scheduled read may land.
  int _ownReadGen = 0;

  RealmChatService get service => widget.service;
  TextEditingController get composer => widget.composer;

  /// Whether this pane renders its OWN thread (Wave H) instead of the
  /// service's global active thread (today's law).
  bool get _ownThreadPane => widget.surfaceId != null;

  /// The thread id this pane renders: the pinned surface id resolved
  /// through the service's ONE resolver, or — null surfaceId — the
  /// global active thread.
  String? get _paneThreadId {
    final surfaceId = widget.surfaceId;
    if (surfaceId == null) return service.activeThreadId;
    return service.threadIdForSurface(surfaceId);
  }

  /// The projection row of the pane's thread (the same lookup the
  /// service's `activeThread` getter rides, for ANY thread id).
  Map<String, Object?>? _threadRow(final String? threadId) {
    if (threadId == null) return null;
    for (final thread in service.threads) {
      if (thread['threadId'] == threadId) return thread;
    }
    return null;
  }

  /// Schedules the pane's pure beats read (called from build — every
  /// rebuild re-reads, so the journal-watch notify is the freshness
  /// signal). The generation guard drops stale reads; an unchanged
  /// signature skips the setState.
  void _scheduleOwnBeatRead(final String threadId) {
    final generation = ++_ownReadGen;
    unawaited(() async {
      final all = await service.beatsFor(threadId, windowStart: 0);
      if (!mounted || generation != _ownReadGen) return;
      if (_ownThreadId != threadId) return;
      final signature = all.isEmpty
          ? '0::'
          : '${all.length}:${all.first['beat']}:${all.last['beat']}';
      if (signature == _ownSignature) return;
      setState(() {
        _ownAll = all;
        _ownSignature = signature;
        final start = _ownWindowStart;
        // The service cache's normalization, mirrored: the first read
        // lands on the tail page; a kept window only clamps.
        _ownWindowStart = start == null
            ? (all.length > RealmChatService.tailPageSize
                  ? all.length - RealmChatService.tailPageSize
                  : 0)
            : (start > all.length ? all.length : start);
      });
    }());
  }

  /// The loaded tail window of the pane's own beats (oldest → newest) —
  /// the pane-local twin of the service's `beats` cache.
  List<Map<String, Object?>> _ownBeats() {
    final all = _ownAll;
    final start = (_ownWindowStart ?? 0).clamp(0, all.length);
    return start == 0 ? all : all.sublist(start);
  }

  /// Whether the pane's thread has older beats above the loaded window
  /// (the twin of the service's `hasOlderBeats`).
  bool get _ownHasOlderBeats => (_ownWindowStart ?? 0) > 0;

  /// Walks the pane's window one [RealmChatService.tailPageSize] page
  /// toward the thread's beginning — the twin of the service's
  /// `loadOlderBeats`, a pure re-slice of the already-read fold
  /// (prepend-only: the loaded tail never changes, so the reading
  /// position survives).
  void _loadOlderOwnBeats() {
    final all = _ownAll;
    final start =
        _ownWindowStart ??
        (all.length > RealmChatService.tailPageSize
            ? all.length - RealmChatService.tailPageSize
            : 0);
    if (start <= 0) return;
    setState(() {
      final next = start - RealmChatService.tailPageSize;
      _ownWindowStart = next < 0 ? 0 : next;
    });
  }

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
    // Wave E — the `@` completion rides the controller's own changes
    // (typing, paste and programmatic inserts all flow through it).
    widget.composer.addListener(_onComposerEdited);
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

  /// A beat's right-click / long-press (1g) — and the hover cluster's
  /// menu button (Wave E): Reply anchors the composer; Details opens the
  /// beat's durable facts (mono, journal vocabulary — never localized,
  /// every value is a fact); New thread spawns the linked child. Edit
  /// and Delete render as honest DISABLED rows: the journal is
  /// append-only and both verbs are harness-owned — a named absence with
  /// its gap tooltip, never a fake affordance.
  Future<void> _onBeatContext(
    final Map<String, Object?> beat,
    final Offset globalPosition,
    final String Function(String actorId) displayNameOf,
  ) async {
    final l10n = context.l10n;
    final isOwn = beat['author'] == service.humanActorId;
    // The kit menu's answer channel: each row's onPressed records the
    // pick, the handle's `closed` future replaces showMenu's pop-value.
    String? choice;
    final handle = showLaMenuAt(
      context,
      globalPosition: globalPosition,
      entries: [
        LaMenuItem(
          key: const ValueKey('worldchat.ctx.reply'),
          label: l10n.worldChatBeatReply,
          onPressed: () => choice = 'reply',
        ),
        // Edit exists only where it could ever apply (the human's own
        // beat) — and stays disabled: the verb is the harness's. The
        // tooltip names the gap (the honest-DISABLED law).
        if (isOwn)
          LaMenuItem(
            key: const ValueKey('worldchat.ctx.edit'),
            label: l10n.worldChatBeatEdit,
            enabled: false,
            tooltip: l10n.worldChatEditGap,
          ),
        LaMenuItem(
          key: const ValueKey('worldchat.ctx.details'),
          label: l10n.worldChatBeatDetails,
          onPressed: () => choice = 'details',
        ),
        LaMenuItem(
          key: const ValueKey('worldchat.ctx.thread'),
          label: l10n.worldChatBeatNewThread,
          onPressed: () => choice = 'thread',
        ),
        LaMenuItem(
          key: const ValueKey('worldchat.ctx.delete'),
          label: l10n.worldChatBeatDelete,
          enabled: false,
          tooltip: l10n.worldChatDeleteGap,
        ),
      ],
    );
    if (handle != null) await handle.closed;
    if (!mounted || choice == null) return;
    if (choice == 'reply') {
      setState(() => _replyBeat = beat);
      return;
    }
    if (choice == 'thread') {
      await _startChildThread(beat);
      return;
    }
    await showLaDialog<void>(
      context: context,
      builder: (final dialogContext) => _BeatDetailsDialog(
        beat: beat,
        displayNameOf: displayNameOf,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  /// The HUMAN image share, messenger-law edition (native-image-assets
  /// DMs/channels wave): pick → copy into the world asset dir → STAGE
  /// the media v1 entry on the composer. Nothing sends here; Send
  /// carries the staged strip with the text (the messenger flow).
  Future<void> _pickAndStageImage() async {
    final world = service.world;
    final target = _ownThreadPane ? _paneThreadId : service.activeThreadId;
    if (world == null || target == null) return;
    try {
      final staged = await RealmChatMediaShare(
        worldHome: Directory(world.worldHome),
      ).pickNamed(threadId: target);
      if (staged == null) return;
      if (!mounted) return;
      setState(() => _pendingMedia.add(staged));
    } on RealmMediaShareException catch (error) {
      if (mounted) setState(() => _shareError = error.code);
    }
  }

  /// The composer field's DROP lane (the messenger law, 2026-11-18):
  /// OS-dragged files stage as pending media — every IMAGE lands (one
  /// entry each), non-media files are skipped quietly (a drag of a
  /// pdf is not an error, it is not an image); a drop that staged
  /// nothing names the refusal honestly beside the composer.
  Future<void> _stageDroppedFiles(final List<DropItem> files) async {
    final world = service.world;
    final target = _ownThreadPane ? _paneThreadId : service.activeThreadId;
    if (world == null || target == null || files.isEmpty) return;
    final share = RealmChatMediaShare(worldHome: Directory(world.worldHome));
    var staged = 0;
    for (final item in files) {
      if (item is DropItemDirectory) continue;
      try {
        final bytes = await item.readAsBytes();
        final entry = await share.buildFromBytes(
          bytes: bytes,
          threadId: target,
          nameHint: item.name.isEmpty ? null : item.name,
        );
        // The messenger law: the composer stages IMAGES only — a sniffed
        // video/audio entry is not staged (the beat vocabulary keeps
        // media v1 image-first).
        final mime = '${entry['mimeType']}';
        if (!mime.startsWith('image/')) continue;
        if (!mounted) return;
        setState(
          () => _pendingMedia.add(
            RealmStagedMedia(entry: entry, name: item.name),
          ),
        );
        staged++;
      } on RealmMediaShareException {
        continue; // not a media file — skipped, never a crash
      } on Exception {
        continue; // an unreadable drop item — skipped honestly
      }
    }
    if (staged == 0 && files.isNotEmpty && mounted) {
      setState(() => _shareError = 'media_share_not_media');
    }
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
    // Wave E — the mention parse runs on every plain send; a non-empty
    // parse narrows the addressees (the mention grammar), null keeps
    // the all-participants default inside the service. Wave H: a
    // pinned pane says into ITS OWN thread (null keeps the service's
    // active-thread default byte-identical).
    final mentioned = _mentionedActors(raw);
    // The messenger media law: the staged strip rides the PLAIN send
    // (text + images leave together, one beat). The ADR 0129 work-order
    // lane above stays text-native and consumes NO media — a staged
    // strip under an armed scope is never silently spent: it stays
    // visible until the human disarms the scope or clears the strip.
    final staged = List<RealmStagedMedia>.of(_pendingMedia);
    await service.say(
      raw,
      replyTo: replyTo,
      addressedTo: mentioned.isEmpty ? null : mentioned,
      threadId: _ownThreadPane ? _paneThreadId : null,
      attachments: [for (final m in staged) m.entry],
    );
    if (!mounted) return;
    composer.clear();
    if (staged.isNotEmpty) setState(_pendingMedia.clear);
    if (_replyBeat != null) setState(() => _replyBeat = null);
    if (_shareError != null) setState(() => _shareError = null);
  }

  /// The thread-open lane (the Wave H regression pin, 2026-11-10):
  /// inside the shell, opening a thread ROUTES its `room:<id>` tab —
  /// a bare `selectThread` moves no pane anymore, because panes render
  /// their OWN thread (the pane-instance law); the landing inbox's
  /// rows and the work-thread cards' Open button both ride here.
  /// Single-pane hosts (no [ViewScope]) fall back to selecting the
  /// global active thread — today's behavior for them.
  void _openThreadLane(final BuildContext context, final String threadId) =>
      openThreadLane(context, service, threadId);

  /// The linkifier v1's resolvability oracle (the beat text's tappable
  /// references): a reference names a LIVE object — a known thread, a
  /// registered channel's id (BOTH spellings — the row-built
  /// threadId-as-id and a legacy registry mint — [channelByAnyId]),
  /// a rostered actor. Everything else stays plain text (honest
  /// absence, never a dead link).
  bool _beatRefResolves(final BeatRefKind kind, final String id) =>
      switch (kind) {
        BeatRefKind.room || BeatRefKind.thread => service.knowsThread(id),
        BeatRefKind.channel => service.channelByAnyId(id) != null,
        BeatRefKind.dm => service.roster?.get(id) != null,
      };

  /// The conversation-surface lane (`dm:<actorId>` / `channel:<id>` /
  /// `room:<threadId>` — the beat text's linkified references): the
  /// shell's ONE router through [ViewScope.onOpenConversation] (the
  /// same `_onSelectTab` the registry and the actor-info surface ride).
  /// Hosts without the scope fall back to the service verbs — the
  /// [openThreadLane] fallback law.
  void _openConversationLane(
    final BuildContext context,
    final String surfaceId,
  ) {
    final routed = ViewScope.of(context)?.onOpenConversation;
    if (routed != null) {
      routed(surfaceId);
      return;
    }
    if (surfaceId.startsWith('dm:')) {
      unawaited(service.openDm(surfaceId.substring('dm:'.length)));
    } else if (surfaceId.startsWith('channel:')) {
      service.selectChannel(surfaceId.substring('channel:'.length));
    } else if (surfaceId.startsWith('room:')) {
      service.selectThread(surfaceId.substring('room:'.length));
    }
  }

  /// The room's ACTOR members — the work order's addressees: the PANE's
  /// thread participants minus the humans (the human authority's own
  /// id and any rostered [ActorKind.human] participant). Unrostered ids
  /// stay: they were invited as members, and the service remains the
  /// authority on what the harness admits (it drops the human again on
  /// its side).
  List<String> _actorMembers() {
    final human = service.humanActorId;
    final participants =
        (_threadRow(_paneThreadId)?['participants'] as List? ??
                const <Object?>[])
            .cast<String>();
    return <String>[
      for (final id in participants)
        if (id != human && service.roster?.get(id)?.kind != ActorKind.human) id,
    ];
  }

  /// The scoped send (ADR 0129's delegation seam, UI half): the spawn
  /// serializes per reuse key inside the service, so a double-tap here
  /// cannot mint two threads either. On success the composer clears and
  /// the scope STAYS armed (a workstream continues — the owner's
  /// decision); on refusal the typed result renders with its own
  /// evidence and the composer KEEPS the order text (nothing is lost).
  Future<void> _sendWorkOrder(final String raw, final String scope) async {
    // Wave H — the order's parent is the PANE's thread (a pinned pane
    // delegates from the room it renders, not from whichever room
    // holds the global focus).
    final parent = _paneThreadId;
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

  // ---- Wave E: mentions, the attach menu and the child-thread verb ----

  /// The composer's caret (clamped; an invalid selection — a programmatic
  /// edit or `enterText` — reads as the end of the text, the honest
  /// fallback for "where the next word lands").
  int _caretOffset(final String text) {
    final selection = composer.selection;
    if (selection.isValid && selection.extentOffset >= 0) {
      return selection.extentOffset.clamp(0, text.length);
    }
    return text.length;
  }

  /// The `@` completion tracker: a word-boundary `@` with no space
  /// between it and the caret opens the overlay with the partial token;
  /// anything else closes it. Never invents a query the text does not
  /// carry.
  void _onComposerEdited() {
    final text = composer.text;
    final caret = _caretOffset(text);
    final upto = text.substring(0, caret);
    final at = upto.lastIndexOf('@');
    if (at < 0) {
      _closeMention();
      return;
    }
    if (at > 0) {
      final prev = upto[at - 1];
      if (prev != ' ' && prev != '\n') {
        _closeMention(); // an email-shaped token is not a mention
        return;
      }
    }
    final partial = upto.substring(at + 1);
    if (partial.contains(' ') || partial.contains('\n')) {
      _closeMention();
      return;
    }
    if (_mentionQuery == partial && _mentionStart == at) return;
    setState(() {
      _mentionQuery = partial;
      _mentionStart = at;
    });
  }

  void _closeMention() {
    if (_mentionQuery == null && _mentionStart == -1) return;
    setState(() {
      _mentionQuery = null;
      _mentionStart = -1;
    });
  }

  /// ONE merged list of everything this room can name (the attach menu
  /// and the `@` overlay share it — one vocabulary, two doors): the
  /// room's actors first, then the rest of the roster, the live
  /// channels, the watchable rooms (never the room being viewed) and
  /// the documents the registry page has ALREADY paged in. Documents are
  /// a read-only projection here: the attach menu never triggers a
  /// registry fetch, and a shell without [ProjectsNotifier] honestly
  /// lists no docs (named absence, never a fake).
  List<_Mentionable> _mentionables(final BuildContext context) {
    final items = <_Mentionable>[];
    final human = service.humanActorId;
    final roster = service.roster;
    final seenActors = <String>{};
    void addActor(final String id) {
      if (id == human || !seenActors.add(id)) return;
      final name = roster?.get(id)?.displayName ?? actorDisplayFallback(id);
      if (name.isEmpty) return;
      items.add(_Mentionable(kind: _MentionKind.actor, id: id, name: name));
    }

    final participants =
        (_threadRow(_paneThreadId)?['participants'] as List? ??
                const <Object?>[])
            .cast<String>();
    for (final id in <String>[
      ...participants,
      for (final profile in roster?.all ?? const <ActorProfile>[])
        profile.actorId,
    ]) {
      addActor(id);
    }
    for (final channel in service.channels) {
      items.add(
        _Mentionable(
          kind: _MentionKind.channel,
          id: channel.threadId,
          name: channel.name,
        ),
      );
    }
    // Wave H — "never the room being viewed" is the PANE's room.
    final paneThreadId = _paneThreadId;
    for (final room in service.roomThreads) {
      final id = '${room['threadId'] ?? ''}';
      if (id.isEmpty || id == paneThreadId) continue;
      items.add(
        _Mentionable(
          kind: _MentionKind.room,
          id: id,
          name: '${room['topic'] ?? id}',
        ),
      );
    }
    ProjectsNotifier? projects;
    try {
      projects = context.read<ProjectsNotifier?>();
    } on ProviderNotFoundException {
      projects = null;
    }
    for (final project
        in projects?.projectsPagedController.items ?? const <ProjectModel>[]) {
      items.add(
        _Mentionable(
          kind: _MentionKind.doc,
          id: project.id.value,
          name: _docTitleOf(project),
        ),
      );
    }
    return items;
  }

  /// The registry project's human title (the Documents view's own
  /// derivation, mirrored locally — importing view_documents.dart would
  /// ride the project_view → world_chat_surface cycle).
  String _docTitleOf(final ProjectModel project) => project.map(
    idea: (final idea) => idea.title,
    note: (final note) => note.note,
    changelog: (final _) => 'changelog',
    doc: (final doc) => doc.title,
  );

  List<_Mentionable> _filterMentionables(
    final List<_Mentionable> items,
    final String query,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return [
      for (final item in items)
        if (item.name.toLowerCase().contains(q)) item,
    ];
  }

  /// Inserts one mention token at the caret: a plain insertion for the
  /// attach dialog's pick, or the replacement of the live `@partial`
  /// token for the overlay's pick (the caret grammar of criterion 3 —
  /// `@<displayName> ` with its trailing space).
  void _insertToken(
    final _Mentionable item, {
    final bool replacePartial = false,
  }) {
    final text = composer.text;
    final caret = _caretOffset(text);
    final start = replacePartial && _mentionStart >= 0 && _mentionStart <= caret
        ? _mentionStart
        : caret;
    final needsLeading =
        start > 0 && text[start - 1] != ' ' && text[start - 1] != '\n';
    final insert = '${needsLeading ? ' ' : ''}${item.token}';
    composer.value = TextEditingValue(
      text: text.replaceRange(start, caret, insert),
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
    setState(() {
      _mentionQuery = null;
      _mentionStart = -1;
    });
    _composerFocus.requestFocus();
  }

  /// Wave E — the attach button's ONE menu: a search dialog over the
  /// merged mentionables plus the action rows. The ADR 0129 work-order
  /// lane rides its own row and opens the EXISTING [_openScopePicker]
  /// unchanged; Plugins and MCP servers are named-absent rows (the
  /// honest disabled state, never a fake).
  Future<void> _openAttachMenu() async {
    final pick = await showLaDialog<_AttachPick>(
      context: context,
      builder: (final dialogContext) =>
          _AttachDialog(items: _mentionables(dialogContext)),
    );
    if (!mounted || pick == null) return;
    // The messenger media law: the menu's image row STAGES — the same
    // pending strip the drop lane fills; nothing sends from a menu.
    if (pick.image) {
      await _pickAndStageImage();
      return;
    }
    if (pick.workOrder) {
      await _openScopePicker();
      return;
    }
    final item = pick.item;
    if (item != null) _insertToken(item);
  }

  /// Wave E — the send-time mention parse: `@<displayName>` tokens map
  /// to actor ids against the pane's thread participants and the
  /// roster (longest names match first, so '@Worker Alpha' never loses
  /// to '@Worker').
  ///
  /// Wave H — the parse follows the PANE's thread: a pinned pane
  /// mentions the members of the room IT renders, and the parsed set
  /// rides [RealmChatService.say]'s `addressedTo` into that same
  /// thread (the earlier honest gap — no `addressedTo` parameter — is
  /// closed; the no-mention default stays byte-for-byte today's
  /// all-participants behavior).
  List<String> _mentionedActors(final String raw) {
    final human = service.humanActorId;
    final roster = service.roster;
    final byName = <String, String>{};
    void add(final String id, final String? name) {
      if (id == human || name == null || name.isEmpty) return;
      byName.putIfAbsent(name, () => id);
    }

    final participants =
        (_threadRow(_paneThreadId)?['participants'] as List? ??
                const <Object?>[])
            .cast<String>();
    for (final id in participants) {
      add(id, roster?.get(id)?.displayName ?? actorDisplayFallback(id));
    }
    for (final profile in roster?.all ?? const <ActorProfile>[]) {
      add(profile.actorId, profile.displayName);
    }
    final names = byName.keys.toList()
      ..sort((final a, final b) => b.length.compareTo(a.length));
    return [
      for (final name in names)
        if (raw.contains('@$name')) byName[name]!,
    ];
  }

  /// Wave E — "new thread" from a beat: a realm-sealed child through the
  /// EXISTING [RealmChatService.startThread] route (which selects the
  /// child — the existing open path), durably linked in the LA-owned
  /// `work_threads` registry under the ONE-LEVEL law: a child of a child
  /// links to the ROOT, never a grandchild chain.
  ///
  /// HONEST GAPS (reported): the link's `projectRoot` is the empty
  /// string — a conversational child carries no project seal and the
  /// registry vocabulary has no "no project" value, so it is honestly
  /// empty, never an invented root; and the service's `workThreads`
  /// cache refreshes only inside its own spawn/start verbs, so the fresh
  /// link becomes visible through [RealmChatService.workThreadsOf] after
  /// the next spawn or restart (the durable row lands immediately).
  Future<void> _startChildThread(final Map<String, Object?> beat) async {
    // Wave H — the child hangs off the PANE's thread (the room being
    // rendered), never off whichever room holds the global focus.
    final currentId = _paneThreadId;
    final world = service.world;
    final human = service.humanActorId;
    if (currentId == null || world == null || human == null) return;
    // The ONE-LEVEL law: when the room being viewed is itself a linked
    // child, the new link attaches to the ROOT parent.
    var parentId = currentId;
    for (final link in service.workThreads) {
      if (link.workThreadId == currentId) {
        parentId = link.parentThreadId;
        break;
      }
    }
    final others = [
      for (final id
          in (_threadRow(currentId)?['participants'] as List? ??
                  const <Object?>[])
              .cast<String>())
        if (id != human) id,
    ];
    final text = _oneLine('${beat['text'] ?? ''}').trim();
    final topic = text.isEmpty ? context.l10n.worldChatBeatNewThread : text;
    // ADR 0146 W3 — the parent link rides the CHILD'S ROW
    // (`parentThreadId` via open); the registry mirror write was the
    // W1 dual-write and rides the flip.
    await service.startThread(
      topic: topic,
      participants: others,
      parentThreadId: parentId,
    );
    final childId = service.activeThreadId;
    if (!mounted || childId == null || childId == currentId) return;
    if (kWorkThreadRegistryReadsOn) {
      final registry = WorkThreadRegistry(store: world.store);
      await registry.create(
        workThreadId: childId,
        parentThreadId: parentId,
        // Conversational child — no project seal (honest empty, never
        // an invented root).
        projectRoot: '',
        name: topic,
        createdBy: human,
      );
    }
    if (!mounted) return;
    // The links cache rebuilds NOW (the row landed): the parent room's
    // browser/cards see the child without waiting for the next spawn.
    await service.refreshWorkThreads();
    if (!mounted) return;
    setState(() {});
  }

  /// everything-from-LA decision): [RealmChatService.grantAccess] runs
  /// the host's canonical `grantProjectAccess` with the VERIFY re-read,
  /// and only a VERIFIED grant retries the refused order — exactly
  /// once. A refused grant or a refused retry renders the message
  /// verbatim and stops; there is no second automatic attempt.
  Future<void> _grantAndRetry() async {
    final refusal = _refusal;
    final human = service.humanActorId;
    // Wave H — the retry's parent is the PANE's thread (the room the
    // refused order was typed in).
    final parent = _paneThreadId;
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
    widget.composer.removeListener(_onComposerEdited);
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  /// The room-entry focus law: once the frame settles, the caret lands
  /// in the composer — unless ANOTHER editable holds focus (typing is
  /// never stolen; the shell anchor is not a text field, so it yields).
  /// The request rides a post-frame callback because focus never moves
  /// mid-build.
  void _focusComposerOnEntry() {
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (!mounted) return;
      final current = FocusManager.instance.primaryFocus;
      if (current == _composerFocus) return;
      final focusedContext = current?.context;
      if (focusedContext != null &&
          (focusedContext.widget is EditableText ||
              focusedContext.findAncestorWidgetOfExactType<EditableText>() !=
                  null)) {
        return;
      }
      _composerFocus.requestFocus();
    });
  }

  @override
  Widget build(final BuildContext context) {
    // Wave H — the pane-instance law: a pinned pane renders ITS OWN
    // thread (resolved through the service's ONE helper); a null-
    // surfaceId pane keeps following the global active thread.
    final threadId = _paneThreadId;
    final thread = _threadRow(threadId);
    if (_ownThreadPane) {
      // Invalidate the own-beats cache when the resolved thread moved
      // (a dm: pane whose thread was just minted, a tab re-routed),
      // then re-read the pure fold on EVERY rebuild — the service's
      // journal-refresh notify is the freshness signal.
      if (threadId != _ownThreadId) {
        _ownThreadId = threadId;
        _ownAll = const <Map<String, Object?>>[];
        _ownWindowStart = null;
        _ownSignature = '';
      }
      if (threadId != null) _scheduleOwnBeatRead(threadId);
    }
    final laUi = context.laUi;
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
          onOpenThread: (final threadId) => _openThreadLane(context, threadId),
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
      // The messenger media law: staged images belong to the room being
      // answered — switching rooms drops the pending strip (the files
      // stay in the world tree; the entries were never sent).
      _pendingMedia.clear();
      // Room entry IS the focus entry (the first-entry law): boot,
      // seed or click — the composer takes the caret.
      _focusComposerOnEntry();
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
    // Wave H — a pinned pane renders its OWN pure beatsFor window; a
    // null-surfaceId pane keeps the service's active-thread cache
    // (byte-for-byte today's behavior, down to the read receipt the
    // cache refresh advances for the SELECTED thread only).
    final beats = _ownThreadPane ? _ownBeats() : service.beats;
    final hasOlderBeats = _ownThreadPane
        ? _ownHasOlderBeats
        : service.hasOlderBeats;
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
          // The threads browser rides CHANNEL and DM panes (owner law
          // 2026-11-16: rooms left the rooms column and surface
          // Discord-threads-style INSIDE the channel view; owner
          // decision 2026-11-16: people (dms) get it too — just talking
          // with one actor can do some work too). A plain group thread
          // carries no registry facts and keeps the quiet header.
          threadsToggle: (channel == null && dmOther == null)
              ? null
              : () => setState(() => _threadsOpen = !_threadsOpen),
          threadsOpen: _threadsOpen,
        ),
        // The CHANNEL and DM panes' THREADS BROWSER (owner law
        // 2026-11-16): the watchable rooms left the rooms column; a
        // channel or dm pane lists its work threads and the realm's
        // rooms one panel away.
        if ((channel != null || dmOther != null) && _threadsOpen)
          _ThreadsBrowserPanel(
            service: service,
            parentThreadId: threadId,
            onOpenThread: (final id) => _openThreadLane(context, id),
          ),
        LaHairline(color: context.shellHairline),
        Expanded(
          // The strip (work cards, 0c interrupts, narration) renders
          // EVEN in a beat-less room: a fresh general room whose first
          // send auto-spawned a work thread has no parent beats yet —
          // and the merged view (the owner's auto-spawn law) is exactly
          // the card in that empty room. The first-word note sits
          // BEHIND the list then, not instead of it.
          child: Stack(
            children: [
              if (beats.isEmpty) _CenteredNote(text: l10n.worldChatFirstWord),
              NotificationListener<ScrollNotification>(
                onNotification: (final notification) {
                  // Reversed list: OLDER beats live at larger
                  // offsets — nearing the top edge is the
                  // scroll-up pagination trigger. Prepending
                  // older pages never shifts the visible window
                  // (offsets anchor at the bottom), so the
                  // reading position survives the fetch.
                  final metrics = notification.metrics;
                  if (hasOlderBeats &&
                      metrics.maxScrollExtent - metrics.pixels < 160) {
                    if (_ownThreadPane) {
                      _loadOlderOwnBeats();
                    } else {
                      unawaited(service.loadOlderBeats());
                    }
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
                  itemCount: 1 + beats.length + (hasOlderBeats ? 1 : 0),
                  itemBuilder: (final context, final index) {
                    if (index == 0) {
                      return _WorkStrip(
                        service: service,
                        threadId: threadId,
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
                        onTap: () => _ownThreadPane
                            ? _loadOlderOwnBeats()
                            : unawaited(service.loadOlderBeats()),
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
                        (final candidate) => candidate['beat'] == replyNum,
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
                        (beat['addressedTo'] as List? ?? const <Object?>[])
                            .cast<String>();
                    final chips = addressed.length < participants.length - 1
                        ? [
                            for (final id in addressed)
                              (id: id, name: displayNameOf(id)),
                          ]
                        : const <({String id, String name})>[];
                    final row = _MessageRow(
                      key: ValueKey('worldchat.beat.$threadId#${beat['beat']}'),
                      profile: profile,
                      isHuman: author == service.humanActorId,
                      text: beat['text']! as String,
                      at: beat['at'] as String?,
                      showHeader: !grouped,
                      replyQuote: replyQuote,
                      replyQuoteKey: replyNum == null
                          ? null
                          : ValueKey('worldchat.quote.$threadId#$replyNum'),
                      addressedChips: chips,
                      attachments: (beat['attachments'] as List? ?? const [])
                          .cast<Map>(),
                      mediaWorldHome: service.world?.worldHome,
                      beatSuffix: '$threadId#${beat['beat']}',
                      // The linkifier v1: the pane's service
                      // facts decide resolvability; a tap rides
                      // the shell's ONE router (the
                      // conversation-surface lane).
                      refResolves: _beatRefResolves,
                      onOpenSurface: (final surfaceId) =>
                          _openConversationLane(context, surfaceId),
                      // Wave F — the beat's display name is an
                      // actor affordance too: same seam (and same
                      // ViewScope fallback) as the members popover.
                      onTapActor:
                          widget.onTapActor ??
                          ViewScope.of(context)?.onFocusActor,
                      onReply: () => setState(() => _replyBeat = beat),
                      onNewThread: () => unawaited(_startChildThread(beat)),
                      onMenu: (final position) => unawaited(
                        _onBeatContext(beat, position, displayNameOf),
                      ),
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
        LaHairline(color: context.shellHairline),
        // 1g — the reply anchor: a quiet strip naming the beat the
        // next word answers (cancel returns to the plain say).
        if (_replyBeat != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Container(
              key: const ValueKey('worldchat.replying'),
              padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
              decoration: BoxDecoration(
                color: context.shellField,
                borderRadius: BorderRadius.circular(ShellTokens.radius),
                border: Border.all(color: context.shellHairline),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_outlined,
                    size: 14,
                    color: context.shellMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.worldChatReplyingTo(displayNameOf(_replyBeat!['author']! as String))}: ${_oneLine('${_replyBeat!['text'] ?? ''}')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: laUi.micro.copyWith(color: context.shellMuted),
                    ),
                  ),
                  LaButton.icon(
                    key: const ValueKey('worldchat.replying.close'),
                    size: LaButtonSize.sm,
                    tooltip: l10n.worldChatCancelReply,
                    icon: const Icon(Icons.close_outlined, size: 14),
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
              style: laUi.micro.copyWith(
                color: context.shellMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        // Wave E — the channel's meta row: ONE quiet row of three icon
        // buttons (permissions, members, info) above the composer,
        // channel rooms ONLY (a DM's identity already lives in the
        // header; a plain group thread has no registry facts to show).
        if (channel != null)
          _ChannelMetaRow(
            service: service,
            channel: channel,
            participants: participants,
            onTapActor:
                widget.onTapActor ?? ViewScope.of(context)?.onFocusActor,
          ),
        // Wave E — the `@` completion overlay: anchored directly above
        // the composer, filtered live by the partial token, one tap
        // replaces `@partial` with the mention token.
        if (_mentionQuery != null)
          _MentionOverlay(
            items: _filterMentionables(_mentionables(context), _mentionQuery!),
            onPick: (final item) => _insertToken(item, replacePartial: true),
          ),
        if (_shareError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              _shareError!,
              key: const ValueKey('worldchat.shareError'),
              style: laUi.micro.copyWith(color: laUi.danger),
            ),
          ),
        // The messenger media law's visible strip: every staged image
        // waits HERE as a quiet chip (the human's file name), one tap
        // removes it; Send spends the strip with the text.
        if (_pendingMedia.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              key: const ValueKey('worldchat.mediaStrip'),
              children: [
                for (var i = 0; i < _pendingMedia.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _PendingMediaChip(
                      key: ValueKey('worldchat.mediaChip.$i'),
                      staged: _pendingMedia[i],
                      index: i,
                      onRemove: () => setState(() => _pendingMedia.removeAt(i)),
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: DropTarget(
            // The drop lane (the messenger law): OS-dragged images stage
            // onto the composer — the field lights ONE accent border
            // while a drag hovers it, and the drop stages every image,
            // skipping the rest honestly. Web has no OS file drop lane
            // here; the target stays off rather than pretending.
            enable: !kIsWeb,
            onDragEntered: (final _) => setState(() => _dropHover = true),
            onDragExited: (final _) => setState(() => _dropHover = false),
            onDragDone: (final details) {
              if (_dropHover) setState(() => _dropHover = false);
              unawaited(_stageDroppedFiles(details.files));
            },
            child: Container(
              // Declare the field once: a quiet raised fill, no border —
              // border+fill together is the Material double declaration.
              // The one exception is the drop-hover accent: a dragged
              // file over the field is worth exactly one accent border.
              decoration: BoxDecoration(
                color: context.shellField,
                // Wave K: the field rides the shell radius token — the
                // ad-hoc `radius + 2` was chrome drift (floating layers
                // keep their 10–12; controls ride 8).
                borderRadius: BorderRadius.circular(ShellTokens.radius),
                border: _dropHover
                    ? Border.all(color: context.la.accent, width: 1.5)
                    : null,
              ),
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Wave E — the attach button REPLACES the bare scope
                  // toggle: ONE menu over the merged mentionables and the
                  // action rows (the ADR 0129 work-order lane keeps its
                  // own row and opens the unchanged picker; the image
                  // row STAGES like the drop; Plugins and MCP servers
                  // are named-absent rows). The armed scope still tints
                  // the icon as its second carrier — the chip above the
                  // composer remains the visible state.
                  LaButton.icon(
                    key: const ValueKey('worldchat.attach'),
                    tooltip: l10n.worldChatAttach,
                    size: LaButtonSize.sm,
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: _armedScope != null
                          ? context.la.accent
                          : context.shellMuted,
                    ),
                    onPressed: () => unawaited(_openAttachMenu()),
                  ),
                  Expanded(
                    child: Semantics(
                      label: 'worldchat.composer',
                      child: LaField(
                        key: const ValueKey('worldchat.composer'),
                        controller: composer,
                        focusNode: _composerFocus,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (final value) => unawaited(_send(value)),
                        placeholder: composerHint,
                        // The composer's own Container declares the field
                        // fill (Wave K law) — the kit field stays a quiet
                        // borderless carrier inside it.
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        showFocusHairline: false,
                      ),
                    ),
                  ),
                  // The send's other busy half: a scoped spawn in flight
                  // (the service's `sending` flag covers the plain say).
                  // Wave K: SAME density + icon size as the attach button
                  // — the two share one optical size and baseline.
                  LaButton.icon(
                    key: const ValueKey('worldchat.send'),
                    tooltip: l10n.worldChatSend,
                    size: LaButtonSize.sm,
                    icon: sendBusy
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: LaSpinner(size: 14),
                          )
                        : const Icon(Icons.arrow_upward_outlined, size: 18),
                    onPressed: sendBusy
                        ? null
                        : () => unawaited(_send(composer.text)),
                  ),
                ],
              ),
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
    this.threadsToggle,
    this.threadsOpen = false,
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

  /// The threads browser's toggle (channel panes only; null keeps the
  /// affordance honestly absent — the pane owns the panel's state).
  final VoidCallback? threadsToggle;

  /// The browser's visible state (the toggle's open tint).
  final bool threadsOpen;

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
      // The base-type law for floats: this card rides an overlay, above
      // LaChrome's body DefaultTextStyle — MaterialApp's error style (the
      // yellow double underline) would otherwise bleed into its texts
      // (the kit's LaDialog law, applied app-side).
      final theme = context.laUi;
      _cardEntry = OverlayEntry(
        builder: (final overlayContext) => DefaultTextStyle(
          style: theme.body,
          child: Stack(
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
                  offset: const Offset(0, 6),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: _ActorCard(header: widget, onClose: _removeCard),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      Overlay.of(context).insert(_cardEntry!);
    });
  }

  @override
  Widget build(final BuildContext context) {
    final service = widget.service;
    final laUi = context.laUi;
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
        ? laUi.accent
        : actorColor(other.actorId);
    // The identity IS the entry point to the actor's profile: tapping
    // the mark or name hosts the people view on that actor. Channels
    // and group topics are not one identity — they stay inert.
    final onFocusActor = ViewScope.of(context)?.onFocusActor;
    final threadsToggle = widget.threadsToggle;
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
                  LaPressable(
                    key: const ValueKey('worldchat.identity'),
                    scaleOnPress: false,
                    radius: BorderRadius.circular(ShellTokens.radius),
                    onTap: other == null || onFocusActor == null
                        ? null
                        : () => onFocusActor(other.actorId),
                    child: _headerMark(laUi),
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: LaPressable(
                      scaleOnPress: false,
                      radius: BorderRadius.circular(ShellTokens.radius),
                      onTap: other == null || onFocusActor == null
                          ? null
                          : () => onFocusActor(other.actorId),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: laUi.compact.copyWith(
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
          // The threads browser's affordance (channel panes only — the
          // pane passes null elsewhere): the quiet text mark beside the
          // card button, the same 22px grammar.
          if (threadsToggle != null) ...[
            _ThreadsToggle(
              open: widget.threadsOpen,
              label: context.l10n.worldChatThreadsToggle,
              onTap: threadsToggle,
            ),
            const SizedBox(width: 6),
          ],
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
  Widget _headerMark(final LaUiTheme laUi) => switch (this) {
    _ when widget.channel != null => SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Text(
          '#',
          style: laUi.compact.copyWith(
            fontSize: 14,
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

/// The threads browser's header affordance (the _CardButton grammar at
/// text width): a quiet label on the shell's hairline — muted ink at
/// rest, the accent only while the panel is open (DESIGN: chrome never
/// shouts, no attention-seeking animation). The Semantics name IS the
/// widget key (DESIGN §6).
class _ThreadsToggle extends StatelessWidget {
  const _ThreadsToggle({
    required this.open,
    required this.label,
    required this.onTap,
  });

  final bool open;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: 'worldchat.threads.toggle',
    hint: label,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: const ValueKey('worldchat.threads.toggle'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: open ? context.la.accent : context.shellHairline,
            ),
            borderRadius: BorderRadius.circular(6),
            color: open ? context.shellSelected : null,
          ),
          child: Text(
            label,
            style: context.laUi.micro.copyWith(
              fontSize: 11,
              color: open ? context.la.accent : context.shellMuted,
              fontWeight: open ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The channel and DM panes' THREADS BROWSER (owner law 2026-11-16:
/// rooms left the rooms column; they surface Discord-threads-style
/// INSIDE the channel view; owner decision 2026-11-16: dms get it too
/// — just talking with one actor can do some work too). One compact
/// panel under the conversation header, two labelled groups over the
/// service's LIVE getters — no caching, no polling (the service's
/// notify is the freshness signal):
/// "Threads" — the work threads spawned from THIS pane's thread (a dm
/// parent is a valid work-order parent, [RealmChatService.workThreadsOf]);
/// "Rooms" — the watchable actor↔actor and plain group threads
/// ([RealmChatService.roomThreads], the topic or the honest raw id).
/// ADR 0145 — declared session rows (machine-life rooms) sort AFTER
/// the organic rooms and carry a quiet kind mark (ink is data, no
/// icons). Every row opens its `room:<id>` tab through the shell's ONE
/// router (the work cards' lane). No work threads and no rooms renders
/// one quiet line — honest absence, never a fake list.
class _ThreadsBrowserPanel extends StatelessWidget {
  const _ThreadsBrowserPanel({
    required this.service,
    required this.parentThreadId,
    required this.onOpenThread,
  });

  final RealmChatService service;
  final String parentThreadId;
  final ValueChanged<String> onOpenThread;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final workThreads = service.workThreadsOf(parentThreadId);
    final rooms = service.roomThreads;
    // ADR 0145 — organic rooms first, declared sessions after (both
    // keep the projection's own newest-activity order).
    final organicRooms = [
      for (final thread in rooms)
        if (thread['kind'] != 'session') thread,
    ];
    final sessionRooms = [
      for (final thread in rooms)
        if (thread['kind'] == 'session') thread,
    ];
    return Container(
      key: const ValueKey('worldchat.threads.panel'),
      decoration: BoxDecoration(
        color: context.shellField,
        border: Border(bottom: BorderSide(color: context.shellHairline)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (workThreads.isEmpty && rooms.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                l10n.worldChatThreadsEmpty,
                style: context.laUi.micro.copyWith(
                  color: context.shellMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else ...[
            if (workThreads.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  l10n.worldChatThreadsGroup,
                  style: shellSectionLabel(context),
                ),
              ),
              for (final link in workThreads)
                _ThreadsRow(
                  rowKey: 'worldchat.threads.row.work.${link.workThreadId}',
                  title: link.name,
                  icon: Icons.alt_route_outlined,
                  onTap: () => onOpenThread(link.workThreadId),
                ),
            ],
            if (rooms.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  l10n.worldChatRoomsGroup,
                  style: shellSectionLabel(context),
                ),
              ),
              for (final thread in organicRooms)
                _ThreadsRow(
                  rowKey: 'worldchat.threads.row.room.${thread['threadId']}',
                  title: _roomTitle(service, thread),
                  icon: Icons.forum_outlined,
                  onTap: () => onOpenThread('${thread['threadId']}'),
                ),
              for (final thread in sessionRooms)
                _ThreadsRow(
                  rowKey: 'worldchat.threads.row.room.${thread['threadId']}',
                  title: _roomTitle(service, thread),
                  icon: Icons.forum_outlined,
                  mark: l10n.worldChatSessionKindMark,
                  onTap: () => onOpenThread('${thread['threadId']}'),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

/// One room row's title: the projection's topic, else the honest raw
/// thread id (the rooms-column row's grammar — the service's own
/// [RealmChatService.topicOf] is the fallback lookup).
String _roomTitle(
  final RealmChatService service,
  final Map<String, Object?> thread,
) {
  final topic = thread['topic'] as String?;
  if (topic != null && topic.isNotEmpty) return topic;
  final threadId = '${thread['threadId']}';
  return service.topicOf(threadId) ?? threadId;
}

/// One browser row: the mark, the title, the hover fill — the
/// [_RoomsRow] grammar at compact height. An optional [mark] renders a
/// quiet kind word at the row's end (ADR 0145's session rows — labels,
/// not icons, DESIGN §2). The Semantics name IS the widget key
/// (DESIGN §6); the human title rides the hint.
class _ThreadsRow extends StatelessWidget {
  const _ThreadsRow({
    required this.rowKey,
    required this.title,
    required this.icon,
    required this.onTap,
    this.mark,
  });

  final String rowKey;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  /// The quiet kind word (e.g. the localized 'session'), null for the
  /// organic rows.
  final String? mark;

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    return Semantics(
      button: true,
      label: rowKey,
      hint: title,
      child: LaPressable(
        key: ValueKey(rowKey),
        onTap: onTap,
        scaleOnPress: false,
        radius: BorderRadius.circular(ShellTokens.radius),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 26,
          child: Row(
            children: [
              Icon(icon, size: 13, color: context.shellMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: laUi.compact.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.shellMuted,
                  ),
                ),
              ),
              if (mark != null) ...[
                const SizedBox(width: 6),
                Text(
                  mark!,
                  style: laUi.micro.copyWith(
                    fontSize: 10,
                    color: context.shellMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
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
        // The card bounds the editor's height (≤ 90% of the window):
        // the body SCROLLS to reach Save, never overflows past the
        // card's edge or the window's bottom (the other embeddings
        // own their scroll — view_people and the actor info pane
        // wrap the editor themselves). The kit's LaField carries its
        // own painting, so no Material sheet is needed underneath.
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: SingleChildScrollView(
            child: ActorProfileEditor(
              profile: other,
              brainOptions: availableBrainOptions(
                defaultOpenRouterModel: _defaultOpenRouterModel(context),
                paletteRungs: worldState?.generativeDecls ?? const [],
                subscriptionModels: subscriptionModelsOf(context),
              ),
              tiersForBrain: (final ref) => reasoningTiersForBrainRef(
                ref,
                transportOfRung: (final id) => worldState?.transportOfRung(id),
              ),
              saveKey: const ValueKey('worldchat.card.save'),
              onCancel: () => setState(() => _editing = false),
              initialBrainSet:
                  service.brainSets[other.actorId] ?? const <String>[],
              initialSelfBind:
                  (service.selfBinds[other.actorId] ?? 'allow') != 'deny',
              onSave:
                  ({
                    required final displayName,
                    required final role,
                    required final systemPrompt,
                    required final brainRef,
                    required final avatar,
                    required final brainSet,
                    required final selfBind,
                  }) {
                    unawaited(
                      service
                          .updateActor(
                            actorId: other.actorId,
                            displayName: displayName,
                            role: role,
                            systemPrompt: systemPrompt,
                            brainRef: brainRef,
                            avatar: avatar,
                            brainSet: brainSet,
                            selfBind: selfBind ? 'allow' : 'deny',
                          )
                          .then((final _) => onClose()),
                    );
                  },
            ),
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
                LaButton(
                  key: const ValueKey('worldchat.card.edit'),
                  variant: LaButtonVariant.ghost,
                  size: LaButtonSize.sm,
                  dense: true,
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: context.l10n.actorsEditTooltip,
                ),
              LaButton(
                key: const ValueKey('worldchat.close'),
                variant: LaButtonVariant.ghost,
                size: LaButtonSize.sm,
                dense: true,
                onPressed: () {
                  onClose();
                  unawaited(service.closeThread(header.threadId));
                },
                icon: const Icon(Icons.archive_outlined, size: 15),
                label: context.l10n.worldChatCloseTooltip,
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
///
/// Wave E — the hover texture (the _RoomsRow precedent): the pointer
/// fills the row with [ShellColors.shellHover] and reveals the trailing
/// action cluster: reply, edit (OWN beats only, and DISABLED — the
/// journal is append-only and the verb is harness-owned; the tooltip
/// names the gap, never a fake), new thread, and the menu button that
/// opens the beat's extended context menu.
class _MessageRow extends StatefulWidget {
  const _MessageRow({
    required this.profile,
    required this.isHuman,
    required this.text,
    required this.showHeader,
    required this.beatSuffix,
    required this.refResolves,
    required this.onOpenSurface,
    this.at,
    this.replyQuote,
    this.replyQuoteKey,
    this.addressedChips = const <({String id, String name})>[],
    this.attachments = const <Map>[],
    this.mediaWorldHome,
    this.onTapActor,
    this.onReply,
    this.onNewThread,
    this.onMenu,
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

  /// The beat's raw `media v1` attachments (native-image-assets
  /// conversation wave): rendered as media cards ABOVE the text, the
  /// alt text as semantics, the honest placeholder when the file is
  /// not resolvable here.
  final List<Map> attachments;

  /// The realm world home (the conversation media path law's share
  /// root): world-relative entry paths resolve against it; null leaves
  /// them honestly unresolved (the placeholder).
  final String? mediaWorldHome;

  /// `<threadId>#<beat>` — the hover cluster's key family (the beat
  /// row's own suffix, so every action key is as unique as the beat).
  final String beatSuffix;

  /// The linkifier v1's resolvability oracle (the pane's service
  /// facts): a reference naming no live object stays plain text.
  final bool Function(BeatRefKind kind, String id) refResolves;

  /// Where a tapped reference goes (the shell's ONE router through the
  /// pane's conversation-surface lane).
  final void Function(String surfaceId) onOpenSurface;

  /// Wave F — where a tapped display name goes (the actor's info
  /// surface); null keeps the name inert (honest absence).
  final void Function(String actorId)? onTapActor;
  final VoidCallback? onReply;
  final VoidCallback? onNewThread;
  final void Function(Offset globalPosition)? onMenu;

  @override
  State<_MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<_MessageRow> {
  bool _hovering = false;

  ActorProfile get profile => widget.profile;
  bool get isHuman => widget.isHuman;
  String get text => widget.text;
  bool get showHeader => widget.showHeader;
  String? get at => widget.at;
  String? get replyQuote => widget.replyQuote;
  Key? get replyQuoteKey => widget.replyQuoteKey;
  List<({String id, String name})> get addressedChips => widget.addressedChips;

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
        bottom: 4,
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
          style: context.laUi.micro.copyWith(color: context.shellMuted),
        ),
      ),
    );
  }

  /// The hover-revealed trailing cluster: quiet compact icons on the
  /// shell grammar. Edit renders ONLY for own beats and stays disabled
  /// (the gap tooltip is the honesty); delete lives in the menu.
  Widget _cluster(final BuildContext context) {
    final l10n = context.l10n;
    final suffix = widget.beatSuffix;
    final muted = context.shellMuted;
    Widget button({
      required final Key key,
      required final IconData icon,
      required final String tooltip,
      required final VoidCallback? onPressed,
    }) => LaButton.icon(
      key: key,
      size: LaButtonSize.sm,
      tooltip: tooltip,
      icon: Icon(icon, size: 14, color: muted),
      onPressed: onPressed,
    );
    return Semantics(
      container: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            key: ValueKey('worldchat.beat.reply.$suffix'),
            icon: Icons.reply_outlined,
            tooltip: l10n.worldChatBeatReply,
            onPressed: widget.onReply,
          ),
          if (isHuman)
            button(
              key: ValueKey('worldchat.beat.edit.$suffix'),
              icon: Icons.edit_outlined,
              tooltip: l10n.worldChatEditGap,
              onPressed: null,
            ),
          button(
            key: ValueKey('worldchat.beat.thread.$suffix'),
            icon: Icons.alt_route_outlined,
            tooltip: l10n.worldChatBeatNewThread,
            onPressed: widget.onNewThread,
          ),
          Builder(
            builder: (final buttonContext) => button(
              key: ValueKey('worldchat.beat.menu.$suffix'),
              icon: Icons.more_horiz_outlined,
              tooltip: l10n.worldChatBeatMenu,
              onPressed: () {
                final box = buttonContext.findRenderObject()! as RenderBox;
                widget.onMenu?.call(
                  box.localToGlobal(box.size.bottomRight(Offset.zero)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// The beat's body text (the linkifier v1, owner law 2026-11-16):
  /// resolvable references — `room:`/`channel:`/`dm:` tokens, bare
  /// minted `thread-` ids — render as tappable spans on the app's link
  /// ink and open their surface through the shell's ONE router; every
  /// non-resolvable token stays plain text (honest absence, never a
  /// dead link). A beat with no resolvable reference renders the plain
  /// Text, byte-identical to before.
  Widget _beatText(final BuildContext context) {
    final laUi = context.laUi;
    final segments = linkifyBeatText(text, resolves: widget.refResolves);
    if (segments.length == 1 && segments.single.link == null) {
      return Text(text, style: laUi.body);
    }
    return Text.rich(
      TextSpan(
        style: laUi.body,
        children: [
          for (final segment in segments)
            if (segment.link == null)
              TextSpan(text: segment.text)
            else
              TextSpan(
                text: segment.text,
                style: TextStyle(color: laUi.accent),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => widget.onOpenSurface(segment.link!.surfaceId),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    final muted = context.shellMuted;
    final accent = actorColor(profile.actorId);
    // The media branch (native-image-assets Wave D2): a beat whose
    // text IS an `asset-media v1` header renders as the media card —
    // pixels from the file, alt as semantics, honest placeholder when
    // the sandbox root is unknown here. Every other beat is text,
    // linkified (the linkifier v1) over the same bodyMedium style.
    final mediaBeat = MediaBeat.tryParse(text);
    // The STRUCTURED attachments (the media v1 vocabulary) render
    // first — one honest card per entry; the header-in-text parse
    // stays the fallback for beats that only carry the projection.
    // THE CONVERSATION MEDIA PATH RULE: the entry path resolves
    // through the host's shared law (world-relative shares against
    // the world home; absolute v1 records as-is) — unresolvable HERE
    // renders the honest placeholder, never a guess.
    String? mediaRoot(Object? path) => path is String
        ? resolveConversationMediaPath(path, worldHome: widget.mediaWorldHome)
        : null;
    final mediaCards = [
      for (final entry in widget.attachments)
        if (mediaAttachmentOf(entry) != null)
          MediaAssetCard.fromAttachment(
            Map<String, Object?>.from(entry),
            absPathOverride: mediaRoot(entry['path']),
          ),
    ];
    final body = Padding(
      padding: const EdgeInsets.only(left: ShellTokens.messageGutter),
      child: mediaCards.isEmpty
          ? mediaBeat == null
                ? _beatText(context)
                : MediaAssetCard.fromBeat(
                    mediaBeat,
                    absPathOverride: mediaRoot(mediaBeat.provenance.path),
                  )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...mediaCards,
                if (mediaBeat == null && text.trim().isNotEmpty)
                  _beatText(context),
              ],
            ),
    );
    final Widget content;
    if (!showHeader) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [if (replyQuote != null) _quote(context)!, body],
        ),
      );
    } else {
      final time = _timeLabel(context);
      content = Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ActorAvatar(profile: profile, size: ShellTokens.messageAvatar),
                const SizedBox(width: 8),
                // Wave F — the display name is an actor affordance: a
                // tap opens the actor (info surface via the host's
                // onTapActor seam; inert when the host gives none).
                GestureDetector(
                  key: ValueKey('worldchat.beat.actor.${profile.actorId}'),
                  onTap: widget.onTapActor == null
                      ? null
                      : () => widget.onTapActor!.call(profile.actorId),
                  child: Text(
                    profile.displayName,
                    style: laUi.compact.copyWith(
                      fontSize: 14,
                      color: isHuman ? laUi.accent : accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(time, style: laUi.micro.copyWith(color: muted)),
                ],
                for (final chip in addressedChips) ...[
                  const SizedBox(width: 4),
                  Text(
                    '@${chip.name}',
                    key: ValueKey('worldchat.addressed.${chip.id}'),
                    style: laUi.micro.copyWith(
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
    return MouseRegion(
      onEnter: (final _) => setState(() => _hovering = true),
      onExit: (final _) => setState(() => _hovering = false),
      child: DecoratedBox(
        decoration: _hovering
            ? BoxDecoration(
                color: context.shellHover,
                borderRadius: BorderRadius.circular(ShellTokens.radius),
              )
            : const BoxDecoration(),
        child: Stack(
          children: [
            content,
            if (_hovering)
              Positioned(right: 8, top: 0, child: _cluster(context)),
          ],
        ),
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
              style: context.laUi.micro.copyWith(
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: LaBox(
        key: const ValueKey('worldchat.beatDetails'),
        color: context.shellRaised,
        floating: true,
        radius: BorderRadius.circular(ShellTokens.radius + 2),
        border: BorderSide(color: context.shellHairline),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.worldChatBeatDetails,
                style: context.laUi.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: LaButton(
                  key: const ValueKey('worldchat.beatDetails.close'),
                  variant: LaButtonVariant.ghost,
                  onPressed: onClose,
                  label: context.l10n.worldChatCloseTooltip,
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
    final laUi = context.laUi;
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
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.shellHairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.alt_route_outlined,
                      size: 14,
                      color: context.la.accent,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: LaTooltip(
                        message: link.projectRoot,
                        child: Text(
                          link.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: laUi.compact.copyWith(
                            color: context.la.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // The kind word: the card's type never rides the
                    // color or the icon alone (DESIGN a11y law). A
                    // conversational child thread carries no project
                    // seal, so it says "thread", not "work thread".
                    Text(
                      link.projectRoot.isEmpty
                          ? l10n.worldChatThreadKind
                          : l10n.worldChatWorkThreadKind,
                      style: laUi.micro.copyWith(color: context.shellMuted),
                    ),
                    const Spacer(),
                    _StripButton(
                      keyName: 'worldchat.workthread.open.$id',
                      label: l10n.worldChatOpen,
                      onTap: () =>
                          openThreadLane(context, service, link.workThreadId),
                    ),
                  ],
                ),
                if (hasPreview)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$authorName: $text',
                            key: ValueKey('worldchat.workthread.preview.$id'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: laUi.micro.copyWith(
                              color: context.shellMuted,
                            ),
                          ),
                        ),
                        if (at != null && _instant(at).isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            _instant(at),
                            style: laUi.micro.copyWith(
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
    final laUi = context.laUi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onClear,
        child: Container(
          key: const ValueKey('worldchat.scope.armed'),
          padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.shellHairline),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_outlined, size: 14, color: context.la.accent),
              const SizedBox(width: 8),
              Text(
                projectScopeDisplayName(scope),
                style: laUi.micro.copyWith(
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
              LaButton.icon(
                key: const ValueKey('worldchat.scope.clear'),
                size: LaButtonSize.sm,
                tooltip: l10n.worldChatScopeDismiss,
                icon: const Icon(Icons.close_outlined, size: 14),
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
    final laUi = context.laUi;
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
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.shellField,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
            border: Border.all(color: context.la.danger),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        style: laUi.compact.copyWith(
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _StripButton(
                      keyName: 'worldchat.spawnRefusal.dismiss',
                      label: l10n.worldChatCancel,
                      onTap: onDismiss,
                    ),
                    if (needsGrant) ...[
                      const SizedBox(width: 4),
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

// ---- Wave E: the attach/mention vocabulary and the channel meta row ----

/// The merged mentionable list's kinds (the trailing kind word rides
/// mono, journal vocabulary — never localized, every value is a fact).
enum _MentionKind { actor, channel, room, doc }

/// ONE nameable target of the attach menu and the `@` overlay (one
/// vocabulary, two doors).
final class _Mentionable {
  const _Mentionable({
    required this.kind,
    required this.id,
    required this.name,
  });

  final _MentionKind kind;
  final String id;
  final String name;

  // Stroke-family note: `person_outline` is the legacy-named OUTLINED
  // twin (no `person_outlined` constant) — same stroke family as the
  // `*_outlined` glyphs beside it.
  IconData get icon => switch (kind) {
    _MentionKind.actor => Icons.person_outline,
    _MentionKind.channel => Icons.tag_outlined,
    _MentionKind.room => Icons.forum_outlined,
    _MentionKind.doc => Icons.description_outlined,
  };

  /// What the row displays (channels keep the `#` grammar).
  String get display => kind == _MentionKind.channel ? '#$name' : name;

  /// The inserted token: criterion 3's `@<name> ` shape with its
  /// trailing space; channels ride `#<name> `.
  String get token => kind == _MentionKind.channel ? '#$name ' : '@$name ';
}

/// The attach dialog's answer: ONE picked mentionable, the image stage
/// (the messenger lane — same strip the drop fills), or the ADR 0129
/// work-order lane (which opens the EXISTING scope picker unchanged).
final class _AttachPick {
  const _AttachPick.item(this.item) : workOrder = false, image = false;
  const _AttachPick.workOrder() : item = null, workOrder = true, image = false;
  const _AttachPick.image() : item = null, workOrder = false, image = true;

  final _Mentionable? item;
  final bool workOrder;
  final bool image;
}

/// One attach-menu row shared by the dialog and the overlay.
class _MentionRow extends StatelessWidget {
  const _MentionRow({required this.item, required this.onTap, super.key});

  final _Mentionable item;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    child: LaPressable(
      onTap: onTap,
      scaleOnPress: false,
      radius: BorderRadius.circular(ShellTokens.radius),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Icon(item.icon, size: 15, color: context.shellMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.display,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.laUi.compact.copyWith(color: context.la.ink),
            ),
          ),
          const SizedBox(width: 8),
          Text(item.kind.name, style: LaTokens.mono(9.5, context.la.inkQuiet)),
        ],
      ),
    ),
  );
}

/// The attach button's ONE menu (Wave E): a keyboard-friendly search
/// dialog — autofocus field, one keystroke filters — over the merged
/// mentionables, plus the action rows. The work-order row pops with the
/// [_AttachPick.workOrder] answer and the pane opens the EXISTING scope
/// picker (the ADR 0129 lane, unchanged). Plugins and MCP servers are
/// honest DISABLED rows with the named absence trailing — never a fake.
class _AttachDialog extends StatefulWidget {
  const _AttachDialog({required this.items});

  final List<_Mentionable> items;

  @override
  State<_AttachDialog> createState() => _AttachDialogState();
}

class _AttachDialogState extends State<_AttachDialog> {
  // The dialog owns its controller (the shell test-lane law: a
  // controller disposed when showDialog returns is used-after-dispose
  // by the route's exit animation).
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final laUi = context.laUi;
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.items
        : [
            for (final item in widget.items)
              if (item.name.toLowerCase().contains(query)) item,
          ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
      child: LaBox(
        key: const ValueKey('worldchat.attach.dialog'),
        color: context.shellRaised,
        floating: true,
        radius: BorderRadius.circular(ShellTokens.radius + 2),
        border: BorderSide(color: context.shellHairline),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.worldChatAttach,
                style: laUi.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              LaField(
                key: const ValueKey('worldchat.attach.search'),
                controller: _search,
                autofocus: true,
                onChanged: (final value) => setState(() => _query = value),
                style: laUi.compact,
                placeholder: l10n.worldChatAttachSearchHint,
                prefix: const Icon(Icons.search_outlined, size: 16),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.worldChatNoMatches,
                          textAlign: TextAlign.center,
                          style: laUi.micro.copyWith(color: context.shellMuted),
                        ),
                      )
                    : ListView(
                        key: const ValueKey('worldchat.attach.list'),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final item in filtered)
                            _MentionRow(
                              key: ValueKey(
                                'worldchat.attach.${item.kind.name}.${item.id}',
                              ),
                              item: item,
                              onTap: () => Navigator.of(
                                context,
                              ).pop(_AttachPick.item(item)),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 4),
              LaHairline(color: context.shellHairline),
              // The image row (the messenger law): picking STAGES one
              // image onto the composer's pending strip — the same lane
              // the OS drop fills; nothing sends from a menu.
              _AttachActionRow(
                key: const ValueKey('worldchat.attach.image'),
                icon: Icons.image_outlined,
                label: l10n.attachImage,
                onTap: () =>
                    Navigator.of(context).pop(const _AttachPick.image()),
              ),
              _AttachActionRow(
                key: const ValueKey('worldchat.attach.workOrder'),
                icon: Icons.folder_outlined,
                label: l10n.worldChatAttachWorkOrder,
                onTap: () =>
                    Navigator.of(context).pop(const _AttachPick.workOrder()),
              ),
              _AttachActionRow(
                key: const ValueKey('worldchat.attach.plugins'),
                icon: Icons.extension_outlined,
                label: l10n.worldChatAttachPlugins,
                note: l10n.worldChatAttachNoneYet,
              ),
              _AttachActionRow(
                key: const ValueKey('worldchat.attach.mcp'),
                icon: Icons.hub_outlined,
                label: l10n.worldChatAttachMcpServers,
                note: l10n.worldChatAttachNoneYet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One attach-menu ACTION row: enabled rows pop an answer; the disabled
/// rows carry the named absence as their trailing note (the honest
/// disabled state — a row that says "none yet" is a fact, a row that
/// hides is a lie).
class _AttachActionRow extends StatelessWidget {
  const _AttachActionRow({
    required this.icon,
    required this.label,
    this.note,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: LaPressable(
        onTap: onTap,
        enabled: enabled,
        scaleOnPress: false,
        radius: BorderRadius.circular(ShellTokens.radius),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: enabled ? context.shellMuted : context.la.inkQuiet,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.laUi.compact.copyWith(
                  color: enabled ? context.la.ink : context.la.inkQuiet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (note != null)
              Text(note!, style: LaTokens.mono(10, context.la.inkQuiet)),
          ],
        ),
      ),
    );
  }
}

/// One STAGED attachment chip (the messenger law's visible strip): the
/// human's file name beside a quiet image mark, one tap removes it —
/// the world asset id the entry's path carries stays under the hood.
class _PendingMediaChip extends StatelessWidget {
  const _PendingMediaChip({
    required this.staged,
    required this.index,
    required this.onRemove,
    super.key,
  });

  final RealmStagedMedia staged;

  /// The chip's seat in the strip (the remove affordance's key seat).
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(final BuildContext context) {
    final name = staged.name.isEmpty ? 'image' : staged.name;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      decoration: BoxDecoration(
        color: context.shellField,
        borderRadius: BorderRadius.circular(ShellTokens.radius),
        border: Border.all(color: context.shellHairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 14, color: context.shellMuted),
          const SizedBox(width: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.laUi.compact.copyWith(color: context.la.ink),
          ),
          const SizedBox(width: 4),
          LaButton.icon(
            key: ValueKey('worldchat.mediaChip.$index.remove'),
            tooltip: context.l10n.worldChatRemoveAttachment,
            size: LaButtonSize.sm,
            icon: const Icon(Icons.close_outlined, size: 14),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

/// The `@` completion panel: anchored directly above the composer in
/// the pane's own Column (no route, no animation — settle-clean in
/// tests), filtered live by the partial token.
class _MentionOverlay extends StatelessWidget {
  const _MentionOverlay({required this.items, required this.onPick});

  final List<_Mentionable> items;
  final ValueChanged<_Mentionable> onPick;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
    child: Container(
      key: const ValueKey('worldchat.mentionOverlay'),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: context.shellRaised,
        borderRadius: BorderRadius.circular(ShellTokens.radius + 2),
        border: Border.all(color: context.shellHairline),
        boxShadow: shellFloatingShadow(context),
      ),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                context.l10n.worldChatNoMatches,
                style: context.laUi.micro.copyWith(color: context.shellMuted),
              ),
            )
          : ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                for (final item in items)
                  _MentionRow(
                    key: ValueKey(
                      'worldchat.mention.${item.kind.name}.${item.id}',
                    ),
                    item: item,
                    onTap: () => onPick(item),
                  ),
              ],
            ),
    ),
  );
}

/// Wave E — the channel's meta row above the composer (channel rooms
/// ONLY): permissions, members, info — three quiet icon buttons on the
/// shell grammar, each opening its own durable-fact surface.
class _ChannelMetaRow extends StatelessWidget {
  const _ChannelMetaRow({
    required this.service,
    required this.channel,
    required this.participants,
    this.onTapActor,
  });

  final RealmChatService service;
  final ChannelInfo channel;
  final List<String> participants;
  final void Function(String actorId)? onTapActor;

  Future<void> _openPermissions(final BuildContext context) =>
      showLaDialog<void>(
        context: context,
        builder: (final _) => _ChannelPermissionsDialog(
          service: service,
          channel: channel,
          memberIds: participants,
        ),
      );

  Future<void> _openMembers(final BuildContext context) => showLaDialog<void>(
    context: context,
    // The members popover hangs top-right (the Dialog alignment/inset of
    // the Material draft, on the kit dialog's alignment slot).
    alignment: Alignment.topRight,
    builder: (final dialogContext) => _ChannelMembersDialog(
      service: service,
      channel: channel,
      onTapMember: (final actorId) {
        Navigator.of(dialogContext).pop();
        onTapActor?.call(actorId);
      },
    ),
  );

  Future<void> _openInfo(final BuildContext context) => showLaDialog<void>(
    context: context,
    builder: (final _) =>
        _ChannelInfoDialog(service: service, channel: channel),
  );

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      // Wave K optical alignment: the meta row's left inset equals the
      // composer field's (12 outer + 12 inner = 24), so the meta icons
      // ride the attach button's vertical axis.
      padding: const EdgeInsets.fromLTRB(24, 4, 12, 0),
      child: Row(
        children: [
          LaButton.icon(
            key: const ValueKey('worldchat.meta.perms'),
            tooltip: l10n.worldChatPermsTooltip,
            size: LaButtonSize.sm,
            icon: Icon(Icons.lock_outline, size: 15, color: context.shellMuted),
            onPressed: () => unawaited(_openPermissions(context)),
          ),
          LaButton.icon(
            key: const ValueKey('worldchat.meta.members'),
            tooltip: l10n.worldChatMembersTooltip,
            size: LaButtonSize.sm,
            icon: Icon(
              Icons.group_outlined,
              size: 15,
              color: context.shellMuted,
            ),
            onPressed: () => unawaited(_openMembers(context)),
          ),
          LaButton.icon(
            key: const ValueKey('worldchat.meta.info'),
            tooltip: l10n.worldChatInfoTooltip,
            size: LaButtonSize.sm,
            icon: Icon(Icons.info_outline, size: 15, color: context.shellMuted),
            onPressed: () => unawaited(_openInfo(context)),
          ),
        ],
      ),
    );
  }
}

/// The channel's permissions dialog — ADR 0147: the channel's whole
/// permission fact in one calm surface (mono rows, no ceremony).
///
/// * ACCESS — the thread row's `access` policy as quiet strip toggles
///   over [RealmChatService.setChannelAccess]: `read`/`say` ∈ {realm,
///   members} (a CLOSED channel — read: members — hides its beats from
///   non-members; joining rides the request plane) and `manage` ∈
///   {realm, members, owners} (the default `realm` is today's ungated
///   law — the values are FACTS and stay unlocalized mono, like
///   `granted`/`pending`). The owners list renders verbatim; it is
///   verb-managed (realm_channel_access {action: policy}), not a UI
///   editor — yet.
/// * WORK SCOPE — the channel's `workScope` (kind/root/subpath/caps)
///   verbatim with Clear, and Bind… over the shared project scope
///   picker: every member DERIVES the scope as a grant while a member
///   (the Discord-side model, owner decision 2026-11-18), and leaving
///   sheds it with nothing to chase. The seal stays the sandbox
///   (ADR 0129) — the scope only widens what members may seal into.
/// * MEMBERS' GRANTS — every member's effective scope grants
///   ([RealmChatService.listScopeGrants]: legacy ∪ ledger ∪ conferred,
///   caps + provenance named) with per-row Revoke, and the realm's
///   pending access requests with the one-tap approve (the pre-0147
///   behavior, preserved).
/// * GRANT — a member row's "grant…" affordance opens the compact form
///   (kind project/folder, root prefilled from the scope picker,
///   subpath, caps checkboxes, optional image.spend ceiling) over
///   [RealmChatService.grantScope] — folder grain included, the ask
///   that started ADR 0147.
///
/// Keys: `worldchat.meta.perms.dialog` (the box), the existing
/// `worldchat.meta.perms.grants.<id>` grant rows, `.pending.<i>` /
/// `.approve.<i>` request rows, `.outcome`, `.close`; the new
/// `.access.<key>.<value>` policy toggles, `.scope.*` work-scope rows,
/// `.ledger.<id>.<n>` member scope rows with `.ledger.<id>.<n>.revoke`,
/// and the `.grant.*` form keys.
class _ChannelPermissionsDialog extends StatefulWidget {
  const _ChannelPermissionsDialog({
    required this.service,
    required this.channel,
    required this.memberIds,
  });

  final RealmChatService service;
  final ChannelInfo channel;
  final List<String> memberIds;

  @override
  State<_ChannelPermissionsDialog> createState() =>
      _ChannelPermissionsDialogState();
}

/// The discrete cap choices the grant form offers (the vocabulary is
/// the harness's ActorGrantCaps; the value-bearing `image.spend:<usd>`
/// rides its own numeric field).
const _kGrantCapChoices = <String>[
  'fs.read',
  'fs.write',
  'fs.run',
  'vcs.commit',
  'world.verbs',
  'channel.manage',
  'palette.apply',
  'models.selfbind',
];

class _ChannelPermissionsDialogState extends State<_ChannelPermissionsDialog> {
  Map<String, Object?> _access = const <String, Object?>{};
  Map<String, Object?>? _workScope;
  Map<String, List<ActorScopeGrant>> _scopes =
      const <String, List<ActorScopeGrant>>{};
  List<Map<String, Object?>> _pending = const <Map<String, Object?>>[];
  var _loading = true;
  var _busy = false;

  /// The grant form: which member it edits, its fields, its caps.
  String? _grantingFor;
  var _formKind = 'project';
  final _formRoot = TextEditingController();
  final _formSubpath = TextEditingController();
  final _formSpend = TextEditingController();
  final _formCaps = <String>{'fs.read'};

  /// The last action's honest outcome line (the host's own message,
  /// verbatim — never a paraphrase, never a guess).
  String? _outcome;

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  @override
  void dispose() {
    _formRoot.dispose();
    _formSubpath.dispose();
    _formSpend.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final scopes = <String, List<ActorScopeGrant>>{};
    var pending = const <Map<String, Object?>>[];
    Map<String, Object?> access = const <String, Object?>{};
    Map<String, Object?>? workScope;
    try {
      final world = widget.service.world;
      final row = world == null
          ? null
          : await world.store.read('threads', widget.channel.threadId);
      access =
          (row?['access'] as Map?)?.cast<String, Object?>() ??
          const <String, Object?>{};
      workScope = (row?['workScope'] as Map?)?.cast<String, Object?>();
      for (final id in widget.memberIds) {
        scopes[id] = await widget.service.listScopeGrants(id);
      }
      pending = await widget.service.pendingAccessRequests();
    } on Object catch (error) {
      // An unreadable ledger keeps the quiet state; the outcome line
      // names the failure honestly.
      _outcome = '$error';
    }
    if (!mounted) return;
    setState(() {
      _access = access;
      _workScope = workScope;
      _scopes = scopes;
      _pending = pending;
      _loading = false;
    });
  }

  Future<void> _setPolicy(final String key, final String value) async {
    setState(() => _busy = true);
    final channelId = widget.channel.channelId;
    final ok = switch (key) {
      'read' => await widget.service.setChannelAccess(
        channelId: channelId,
        read: value,
      ),
      'say' => await widget.service.setChannelAccess(
        channelId: channelId,
        say: value,
      ),
      _ => await widget.service.setChannelAccess(
        channelId: channelId,
        manage: value,
      ),
    };
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = ok ? null : (widget.service.error ?? 'policy_refused');
    });
    await _reload();
  }

  Future<void> _bindScope() async {
    final l10n = context.l10n;
    final root = await pickProjectScope(
      context,
      service: widget.service,
      title: l10n.worldChatPermsScopeBind,
      optionKeyPrefix: 'worldchat.meta.perms.scope.option',
      listKey: 'worldchat.meta.perms.scope.options',
    );
    if (root == null || root.isEmpty) return;
    final ok = await widget.service.setChannelWorkScope(
      channelId: widget.channel.channelId,
      kind: 'project',
      root: root,
    );
    if (!mounted) return;
    setState(() {
      _outcome = ok ? null : (widget.service.error ?? 'scope_refused');
    });
    await _reload();
  }

  Future<void> _clearScope() async {
    final ok = await widget.service.setChannelWorkScope(
      channelId: widget.channel.channelId,
      kind: null,
      root: null,
    );
    if (!mounted) return;
    setState(() {
      _outcome = ok ? null : (widget.service.error ?? 'scope_refused');
    });
    await _reload();
  }

  void _openGrantForm(final String actorId) {
    setState(() {
      _grantingFor = actorId;
      _formKind = 'project';
      _formRoot.clear();
      _formSubpath.clear();
      _formSpend.clear();
      _formCaps
        ..clear()
        ..add('fs.read');
    });
  }

  Future<void> _pickFormRoot() async {
    final l10n = context.l10n;
    final root = await pickProjectScope(
      context,
      service: widget.service,
      title: l10n.worldChatPermsRoot,
      optionKeyPrefix: 'worldchat.meta.perms.grant.root.option',
      listKey: 'worldchat.meta.perms.grant.root.options',
    );
    if (root == null || root.isEmpty) return;
    _formRoot.text = root;
  }

  Future<void> _applyGrant() async {
    final l10n = context.l10n;
    final actor = _grantingFor;
    final root = _formRoot.text.trim();
    if (actor == null) return;
    if (root.isEmpty) {
      setState(() => _outcome = l10n.worldChatPermsRootRequired);
      return;
    }
    final subpath = _formKind == 'folder' ? _formSubpath.text.trim() : null;
    final caps = _formCaps.toList()..sort();
    final spend = double.tryParse(_formSpend.text.trim().replaceAll(',', '.'));
    if (spend != null && spend > 0) caps.add('image.spend:$spend');
    setState(() => _busy = true);
    final result = await widget.service.grantScope(
      actorId: actor,
      kind: _formKind,
      root: root,
      subpath: (subpath == null || subpath.isEmpty) ? null : subpath,
      caps: caps.isEmpty ? null : caps,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = result.message;
      if (result.granted) _grantingFor = null;
    });
    await _reload();
  }

  Future<void> _revoke(final String actorId, final String path) async {
    setState(() => _busy = true);
    final result = await widget.service.revokeScope(
      actorId: actorId,
      path: path,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = result.message;
    });
    await _reload();
  }

  Future<void> _approve(final Map<String, Object?> row) async {
    final actor = '${row['actorId'] ?? ''}';
    final project = '${row['projectId'] ?? ''}';
    if (actor.isEmpty || project.isEmpty) return;
    setState(() => _busy = true);
    final grant = await widget.service.grantAccess(actor, project);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = grant.message;
    });
    await _reload();
  }

  /// One policy strip row: the label, then the options as quiet mono
  /// toggles — the CURRENT value renders as plain fact text (selected
  /// states are facts, not buttons), the others as strip buttons.
  Widget _policyRow(
    final BuildContext context, {
    required final String label,
    required final String key,
    required final String current,
    required final List<String> options,
  }) {
    String optionKey(final String value) =>
        'worldchat.meta.perms.access.$key.$value';
    return Padding(
      key: ValueKey('worldchat.meta.perms.access.$key'),
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(label, style: context.laUi.compact)),
          const SizedBox(width: 8),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: current == option
                  ? Text(
                      option,
                      key: ValueKey('${optionKey(option)}.on'),
                      style: LaTokens.mono(10.5, context.la.ink),
                    )
                  : _StripButton(
                      keyName: optionKey(option),
                      label: option,
                      onTap: _busy
                          ? () {}
                          : () => unawaited(_setPolicy(key, option)),
                    ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final laUi = context.laUi;
    final service = widget.service;
    String nameOf(final String id) =>
        service.roster?.get(id)?.displayName ?? actorDisplayFallback(id);
    final read = '${_access['read'] ?? 'realm'}';
    final say = '${_access['say'] ?? 'realm'}';
    final manage = '${_access['manage'] ?? 'realm'}';
    final owners =
        (_access['owners'] as List? ?? const <Object?>[])
            .cast<String>()
            .toList()
          ..sort();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
      child: LaBox(
        key: const ValueKey('worldchat.meta.perms.dialog'),
        color: context.shellRaised,
        floating: true,
        radius: BorderRadius.circular(ShellTokens.radius + 2),
        border: BorderSide(color: context.shellHairline),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: LaSpinner()),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.worldChatPermsTitle,
                      style: laUi.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          // ---- ACCESS ----
                          Text(
                            l10n.worldChatPermsAccess,
                            style: LaTokens.mono(10.5, context.la.inkMuted),
                          ),
                          const SizedBox(height: 2),
                          _policyRow(
                            context,
                            label: l10n.worldChatPermsRead,
                            key: 'read',
                            current: read,
                            options: const ['realm', 'members'],
                          ),
                          _policyRow(
                            context,
                            label: l10n.worldChatPermsSay,
                            key: 'say',
                            current: say,
                            options: const ['realm', 'members'],
                          ),
                          _policyRow(
                            context,
                            label: l10n.worldChatPermsManage,
                            key: 'manage',
                            current: manage,
                            options: const ['realm', 'members', 'owners'],
                          ),
                          if (owners.isNotEmpty)
                            Padding(
                              key: const ValueKey(
                                'worldchat.meta.perms.owners',
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                owners.map(nameOf).join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LaTokens.mono(10.5, context.la.inkMuted),
                              ),
                            ),
                          // ---- WORK SCOPE ----
                          const SizedBox(height: 8),
                          Text(
                            l10n.worldChatPermsScope,
                            style: LaTokens.mono(10.5, context.la.inkMuted),
                          ),
                          const SizedBox(height: 2),
                          if (_workScope == null)
                            Text(
                              l10n.worldChatPermsScopeNone,
                              key: const ValueKey(
                                'worldchat.meta.perms.scope.none',
                              ),
                              style: LaTokens.mono(10.5, context.la.inkMuted),
                            )
                          else
                            Padding(
                              key: const ValueKey(
                                'worldchat.meta.perms.scope.bound',
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      [
                                        '${_workScope!['kind'] ?? 'project'}',
                                        grantScopePathOf(_workScope!),
                                        if (_workScope!['caps'] is List)
                                          (_workScope!['caps']! as List).join(
                                            ' ',
                                          ),
                                      ].join(' '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: LaTokens.mono(
                                        10.5,
                                        context.la.ink,
                                      ),
                                    ),
                                  ),
                                  _StripButton(
                                    keyName: 'worldchat.meta.perms.scope.clear',
                                    label: l10n.worldChatPermsScopeClear,
                                    danger: true,
                                    onTap: _busy
                                        ? () {}
                                        : () => unawaited(_clearScope()),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _StripButton(
                                keyName: 'worldchat.meta.perms.scope.bind',
                                label: l10n.worldChatPermsScopeBind,
                                onTap: _busy
                                    ? () {}
                                    : () => unawaited(_bindScope()),
                              ),
                            ),
                          ),
                          // ---- MEMBERS' GRANTS ----
                          const SizedBox(height: 8),
                          for (final id in widget.memberIds) ...[
                            Padding(
                              key: ValueKey('worldchat.meta.perms.grants.$id'),
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      nameOf(id),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: laUi.compact,
                                    ),
                                  ),
                                  _StripButton(
                                    keyName: 'worldchat.meta.perms.grant.$id',
                                    label: l10n.worldChatPermsGrant,
                                    onTap: _busy
                                        ? () {}
                                        : () => _openGrantForm(id),
                                  ),
                                ],
                              ),
                            ),
                            if ((_scopes[id] ?? const <ActorScopeGrant>[])
                                .isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '—',
                                  style: LaTokens.mono(
                                    10.5,
                                    context.la.inkMuted,
                                  ),
                                ),
                              )
                            else
                              for (var i = 0; i < _scopes[id]!.length; i++)
                                Padding(
                                  key: ValueKey(
                                    'worldchat.meta.perms.ledger.$id.$i',
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          [
                                            _scopes[id]![i].path,
                                            if (_scopes[id]![i].caps != null)
                                              _scopes[id]![i].caps!.join(' '),
                                            if (_scopes[id]![i].via != null)
                                              _scopes[id]![i].via!,
                                          ].join('  '),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: LaTokens.mono(
                                            10.5,
                                            context.la.ink,
                                          ),
                                        ),
                                      ),
                                      _StripButton(
                                        keyName:
                                            'worldchat.meta.perms.ledger'
                                            '.$id.$i.revoke',
                                        label: l10n.worldChatPermsRevoke,
                                        danger: true,
                                        onTap: _busy
                                            ? () {}
                                            : () => unawaited(
                                                _revoke(
                                                  id,
                                                  _scopes[id]![i].path,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                          if (_grantingFor != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              key: const ValueKey(
                                'worldchat.meta.perms.grant.form',
                              ),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.shellHairline,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${l10n.worldChatPermsGrant}'
                                    ' · ${nameOf(_grantingFor!)}',
                                    style: laUi.compact,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        l10n.worldChatPermsKind,
                                        style: laUi.compact,
                                      ),
                                      const SizedBox(width: 8),
                                      for (final kind in const [
                                        'project',
                                        'folder',
                                      ])
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: _formKind == kind
                                              ? Text(
                                                  kind,
                                                  key: ValueKey(
                                                    'worldchat.meta.perms'
                                                    '.grant.kind.$kind.on',
                                                  ),
                                                  style: LaTokens.mono(
                                                    10.5,
                                                    context.la.ink,
                                                  ),
                                                )
                                              : _StripButton(
                                                  keyName:
                                                      'worldchat.meta.perms'
                                                      '.grant.kind.$kind',
                                                  label: kind,
                                                  onTap: () => setState(
                                                    () => _formKind = kind,
                                                  ),
                                                ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        l10n.worldChatPermsRoot,
                                        style: laUi.compact,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: LaField(
                                          key: const ValueKey(
                                            'worldchat.meta.perms.grant.root',
                                          ),
                                          controller: _formRoot,
                                          placeholder: '/path/to/project',
                                          style: LaTokens.mono(
                                            10.5,
                                            context.la.ink,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      _StripButton(
                                        keyName:
                                            'worldchat.meta.perms'
                                            '.grant.root.pick',
                                        label: '…',
                                        onTap: _busy
                                            ? () {}
                                            : () => unawaited(_pickFormRoot()),
                                      ),
                                    ],
                                  ),
                                  if (_formKind == 'folder') ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          l10n.worldChatPermsSubpath,
                                          style: laUi.compact,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: LaField(
                                            key: const ValueKey(
                                              'worldchat.meta.perms'
                                              '.grant.subpath',
                                            ),
                                            controller: _formSubpath,
                                            placeholder: 'packages/app',
                                            style: LaTokens.mono(
                                              10.5,
                                              context.la.ink,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.worldChatPermsCaps,
                                    style: laUi.compact,
                                  ),
                                  const SizedBox(height: 2),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      for (final cap in _kGrantCapChoices)
                                        _formCaps.contains(cap)
                                            ? Text(
                                                cap,
                                                key: ValueKey(
                                                  'worldchat.meta.perms'
                                                  '.grant.cap.$cap.on',
                                                ),
                                                style: LaTokens.mono(
                                                  10.5,
                                                  context.la.ink,
                                                ),
                                              )
                                            : _StripButton(
                                                keyName:
                                                    'worldchat.meta.perms'
                                                    '.grant.cap.$cap',
                                                label: cap,
                                                onTap: () => setState(
                                                  () => _formCaps.add(cap),
                                                ),
                                              ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        ActorGrantCaps.imageSpendPrefix,
                                        style: LaTokens.mono(
                                          10.5,
                                          context.la.inkMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: LaField(
                                          key: const ValueKey(
                                            'worldchat.meta.perms.grant.spend',
                                          ),
                                          controller: _formSpend,
                                          placeholder: '—',
                                          style: LaTokens.mono(
                                            10.5,
                                            context.la.ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: LaButton(
                                      key: const ValueKey(
                                        'worldchat.meta.perms.grant.apply',
                                      ),
                                      variant: LaButtonVariant.primary,
                                      size: LaButtonSize.sm,
                                      onPressed: _busy
                                          ? null
                                          : () => unawaited(_applyGrant()),
                                      label: l10n.worldChatPermsApply,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (_pending.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'pending',
                              style: LaTokens.mono(10.5, context.la.inkMuted),
                            ),
                            for (var i = 0; i < _pending.length; i++)
                              Padding(
                                key: ValueKey(
                                  'worldchat.meta.perms.pending.$i',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${nameOf('${_pending[i]['actorId'] ?? ''}')} → ${_pending[i]['projectId'] ?? ''}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: LaTokens.mono(
                                          10.5,
                                          context.la.ink,
                                        ),
                                      ),
                                    ),
                                    _StripButton(
                                      keyName:
                                          'worldchat.meta.perms.approve.$i',
                                      label: l10n.contextApprove,
                                      onTap: _busy
                                          ? () {}
                                          : () => unawaited(
                                              _approve(_pending[i]),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    if (_outcome != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _outcome!,
                          key: const ValueKey('worldchat.meta.perms.outcome'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LaTokens.mono(10, context.la.danger),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: LaButton(
                        key: const ValueKey('worldchat.meta.perms.close'),
                        variant: LaButtonVariant.ghost,
                        onPressed: () => Navigator.of(context).pop(),
                        label: l10n.worldChatCancel,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The channel's members popover — the MEMBERSHIP MANAGER (one fact,
/// one surface): the member list, the quiet per-row removal verb
/// (non-human members only — the human is PERMANENT in channels), the
/// add CTA over the shared [ChannelMemberPicker], and the mono outcome
/// line carrying the verb's named refusals verbatim. A member row's
/// tap still closes the popover into the actor's info surface (the
/// Wave E law); the removal verb rides beside it, never through it.
///
/// Keys: `worldchat.meta.members.popover` (the box),
/// `worldchat.meta.member.<id>` (the row tap — unchanged),
/// `worldchat.meta.member.<id>.remove` (the removal verb),
/// `worldchat.meta.members.add` (the CTA), `worldchat.meta.members.
/// pick|pick.search|pick.row.<id>|pick.back|pick.confirm` (the picker
/// state) and `worldchat.meta.members.outcome` (the outcome line).
class _ChannelMembersDialog extends StatefulWidget {
  const _ChannelMembersDialog({
    required this.service,
    required this.channel,
    required this.onTapMember,
  });

  final RealmChatService service;
  final ChannelInfo channel;
  final ValueChanged<String> onTapMember;

  @override
  State<_ChannelMembersDialog> createState() => _ChannelMembersDialogState();
}

class _ChannelMembersDialogState extends State<_ChannelMembersDialog> {
  var _picking = false;
  final Set<String> _picked = <String>{};
  String? _outcome;
  var _outcomeError = false;

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    return ListenableBuilder(
      listenable: widget.service,
      builder: (final context, final _) {
        // The channel re-reads per build: a membership change (this
        // popover's own verb, or an agent's through the MCP verb)
        // lands here without a stale list.
        final channel =
            widget.service.channelByThreadId(widget.channel.threadId) ??
            widget.channel;
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280, maxHeight: 360),
          child: LaBox(
            key: const ValueKey('worldchat.meta.members.popover'),
            color: context.shellRaised,
            floating: true,
            radius: BorderRadius.circular(ShellTokens.radius + 2),
            border: BorderSide(color: context.shellHairline),
            // The kit dialog insets 24 all around; the Material draft's
            // 110px top inset rides the extra 86 here.
            margin: const EdgeInsets.only(top: 86),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: _picking
                  ? _pickerBody(context, channel)
                  : _listBody(context, channel),
            ),
          ),
        );
      },
    );
  }

  /// The member list: the count fact on top, one row per member, the
  /// add CTA at the end, the outcome line under it.
  Widget _listBody(final BuildContext context, final ChannelInfo channel) {
    final l10n = context.l10n;
    final laUi = context.laUi;
    final roster = widget.service.roster;
    final human = widget.service.humanActorId;
    final members = channel.memberIds;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
          child: Text(
            l10n.worldChatMembers(members.length),
            style: laUi.compact.copyWith(color: context.shellMuted),
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: members.length,
            itemBuilder: (final context, final index) =>
                _memberRow(context, channel, members[index], roster, human),
          ),
        ),
        const SizedBox(height: 4),
        // The add CTA (the access-request grammar): quiet accent text
        // with a 13px plus, swapping the body to the picker state.
        LaPressable(
          key: const ValueKey('worldchat.meta.members.add'),
          radius: BorderRadius.circular(6),
          scaleOnPress: false,
          onTap: () => setState(() {
            _picking = true;
            _picked.clear();
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                Icon(Icons.add, size: 13, color: context.shellMuted),
                const SizedBox(width: 6),
                Text(
                  l10n.worldChatMembersAdd,
                  style: laUi.micro.copyWith(
                    color: context.la.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_outcome != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Text(
              _outcome!,
              key: const ValueKey('worldchat.meta.members.outcome'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LaTokens.mono(
                10,
                _outcomeError ? context.la.danger : context.la.inkMuted,
              ),
            ),
          ),
      ],
    );
  }

  /// One member row: the tap-into-actor pressable (the frozen Wave E
  /// key) with the quiet removal verb beside it — never through it.
  /// Human members carry no removal verb: permanence is the owner law.
  Widget _memberRow(
    final BuildContext context,
    final ChannelInfo channel,
    final String id,
    final ActorRoster? roster,
    final String? human,
  ) {
    final profile =
        roster?.get(id) ??
        ActorProfile(actorId: id, displayName: actorDisplayFallback(id));
    final removable = profile.kind != ActorKind.human && id != human;
    return Row(
      children: [
        Expanded(
          child: LaPressable(
            key: ValueKey('worldchat.meta.member.$id'),
            onTap: () => widget.onTapMember(id),
            scaleOnPress: false,
            radius: BorderRadius.circular(ShellTokens.radius),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                ActorAvatar(profile: profile, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profile.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.laUi.compact,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (removable)
          LaButton.icon(
            key: ValueKey('worldchat.meta.member.$id.remove'),
            tooltip: context.l10n.worldChatMemberRemoveTooltip,
            size: LaButtonSize.sm,
            icon: Icon(Icons.close, size: 14, color: context.shellMuted),
            onPressed: () =>
                unawaited(_removeMember(context, channel, id, profile)),
          ),
      ],
    );
  }

  /// Removal rides the shared confirm (the losses dialog: history +
  /// running tasks, world truth) and renders the outcome verbatim —
  /// `ok` becomes the removed line, a refusal the service's named
  /// string, a cancel nothing at all.
  Future<void> _removeMember(
    final BuildContext context,
    final ChannelInfo channel,
    final String actorId,
    final ActorProfile profile,
  ) async {
    final result = await confirmChannelRemoval(
      context,
      service: widget.service,
      channel: channel,
      actorId: actorId,
    );
    if (!mounted) return;
    if (result == null) return;
    setState(() {
      _outcomeError = result != 'ok';
      _outcome = result == 'ok'
          ? context.l10n.worldChatMemberRemoved(
              profile.displayName,
              '#${channel.name}',
            )
          : result;
    });
  }

  /// The picker state: the shared [ChannelMemberPicker] over the
  /// not-yet-members, a back affordance, and the Add-N confirm.
  Widget _pickerBody(final BuildContext context, final ChannelInfo channel) {
    final l10n = context.l10n;
    final members = channel.memberIds.toSet();
    final candidates = <ActorProfile>[
      for (final actor in widget.service.roster?.all ?? const <ActorProfile>[])
        if (actor.kind != ActorKind.human && !members.contains(actor.actorId))
          actor,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
          child: Text(
            l10n.worldChatMembersAddTitle('#${channel.name}'),
            style: context.laUi.compact.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Flexible(
          child: ChannelMemberPicker(
            key: const ValueKey('worldchat.meta.members.pick'),
            searchKey: const ValueKey('worldchat.meta.members.pick.search'),
            rowKeyPrefix: 'worldchat.meta.members.pick.row',
            candidates: candidates,
            selected: _picked,
            onToggle: (final actorId) => setState(() {
              if (_picked.contains(actorId)) {
                _picked.remove(actorId);
              } else {
                _picked.add(actorId);
              }
            }),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            LaButton(
              key: const ValueKey('worldchat.meta.members.pick.back'),
              variant: LaButtonVariant.ghost,
              size: LaButtonSize.sm,
              onPressed: () => setState(() => _picking = false),
              label: l10n.worldChatCancel,
            ),
            const Spacer(),
            LaButton(
              key: const ValueKey('worldchat.meta.members.pick.confirm'),
              variant: LaButtonVariant.primary,
              size: LaButtonSize.sm,
              onPressed: _picked.isEmpty
                  ? null
                  : () => unawaited(_addPicked(channel)),
              label: l10n.worldChatMembersAddSelected(_picked.length),
            ),
          ],
        ),
      ],
    );
  }

  /// The add confirm: the merged set through the service verb, then
  /// back to the list with the outcome line (the list itself rebuilds
  /// off the service notification).
  Future<void> _addPicked(final ChannelInfo channel) async {
    final l10n = context.l10n;
    final count = _picked.length;
    final ok = await widget.service.setChannelMembers(
      channelId: channel.channelId,
      memberIds: [...channel.memberIds, ..._picked],
    );
    if (!mounted) return;
    setState(() {
      if (ok) {
        _picking = false;
        _picked.clear();
        _outcomeError = false;
        _outcome = l10n.worldChatMembersAddCount(count, '#${channel.name}');
      } else {
        _outcomeError = true;
        _outcome = widget.service.error ?? 'add_refused';
      }
    });
  }
}

/// The channel's info dialog: the registry's durable facts (name,
/// member count, thread id — mono, journal vocabulary) plus the two
/// channel-management verbs the service ALREADY exposes
/// ([RealmChatService.renameChannel], [RealmChatService.closeChannel] —
/// closing ARCHIVES, never destroys). The change-icon row is honest-
/// disabled: the verb arrives with Wave D's rooms-column menu, and the
/// tooltip names that gap instead of faking the affordance.
class _ChannelInfoDialog extends StatefulWidget {
  const _ChannelInfoDialog({required this.service, required this.channel});

  final RealmChatService service;
  final ChannelInfo channel;

  @override
  State<_ChannelInfoDialog> createState() => _ChannelInfoDialogState();
}

class _ChannelInfoDialogState extends State<_ChannelInfoDialog> {
  // The dialog owns its controller (the shell test-lane law).
  late final TextEditingController _rename = TextEditingController(
    text: widget.channel.name,
  );
  var _busy = false;
  String? _outcome;

  @override
  void dispose() {
    _rename.dispose();
    super.dispose();
  }

  Future<void> _applyRename() async {
    setState(() => _busy = true);
    final renamed = await widget.service.renameChannel(
      widget.channel.channelId,
      _rename.text,
    );
    if (!mounted) return;
    if (renamed) {
      Navigator.of(context).pop();
      return;
    }
    // The service's own named refusal, verbatim (channel_name_empty,
    // channel_name_taken, …) — never a paraphrase.
    setState(() {
      _busy = false;
      _outcome = widget.service.error ?? 'rename_refused';
    });
  }

  Future<void> _archive() async {
    setState(() => _busy = true);
    final closed = await widget.service.closeChannel(widget.channel.channelId);
    if (!mounted) return;
    if (closed) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = false;
      _outcome = widget.service.error ?? 'close_refused';
    });
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final laUi = context.laUi;
    final channel = widget.channel;
    final facts = <(String, String)>[
      ('name', channel.name),
      ('members', l10n.worldChatMembers(channel.memberIds.length)),
      ('thread', channel.threadId),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: LaBox(
        key: const ValueKey('worldchat.meta.info.dialog'),
        color: context.shellRaised,
        floating: true,
        radius: BorderRadius.circular(ShellTokens.radius + 2),
        border: BorderSide(color: context.shellHairline),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '#${channel.name}',
                style: laUi.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              for (final (label, value) in facts)
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LaField(
                      key: const ValueKey('worldchat.meta.info.rename.field'),
                      controller: _rename,
                      enabled: !_busy,
                      style: laUi.compact,
                      placeholder: l10n.worldChatChannelNameHint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StripButton(
                    keyName: 'worldchat.meta.info.rename',
                    label: l10n.roomsRenameAction,
                    onTap: _busy ? () {} : () => unawaited(_applyRename()),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // The honest-disabled icon row: the gap tooltip names
              // WHERE the verb arrives (Wave D's column menu).
              LaTooltip(
                message: l10n.worldChatIconViaColumn,
                child: Semantics(
                  enabled: false,
                  child: Container(
                    key: const ValueKey('worldchat.meta.info.icon'),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 15,
                          color: context.la.inkQuiet,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.worldChatChangeIcon,
                          style: laUi.compact.copyWith(
                            color: context.la.inkQuiet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_outcome != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _outcome!,
                    key: const ValueKey('worldchat.meta.info.outcome'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LaTokens.mono(10, context.la.danger),
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _StripButton(
                    keyName: 'worldchat.meta.info.archive',
                    label: l10n.roomsCloseChannel,
                    danger: true,
                    onTap: _busy ? () {} : () => unawaited(_archive()),
                  ),
                  const SizedBox(width: 4),
                  LaButton(
                    key: const ValueKey('worldchat.meta.info.close'),
                    variant: LaButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                    label: l10n.worldChatCancel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
