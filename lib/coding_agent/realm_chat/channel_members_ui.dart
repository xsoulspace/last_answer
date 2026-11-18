/// Channel membership management UI (the members lane, 2026-11-18):
/// ONE visual vocabulary for every entry point — the members popover's
/// add CTA, the rooms-column menu row, the people view's section verb,
/// and the creation dialog's member list.
///
/// Three pieces live here:
///
/// - [ChannelMemberPicker] — the searchable checkbox list extracted
///   from the creation dialog (its `rail.pick.actor.<id>` keys are the
///   frozen contract); hosts keep their own key family through
///   [ChannelMemberPicker.searchKey] / [ChannelMemberPicker.rowKeyPrefix].
/// - [confirmChannelRemoval] — the removal confirm that names WHAT the
///   actor loses: the channel's history (the message count, world
///   truth) and the durable tasks currently addressed to them
///   (world-durable — removal cancels nothing, the note says so). The
///   human is PERMANENT in channels (owner law): a human actor refuses
///   `channel_member_human_permanent` before any dialog.
/// - [openChannelMembersDialog] — the standalone add-members dialog
///   behind the rooms-column menu row and the people view's section
///   verb.
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `channel.member.remove.dialog|cancel|confirm` (the confirm family),
/// `channel.members.dialog|search|pick.<id>|confirm|outcome` (the
/// standalone dialog family) and `rail.pick.actor.<id>` (creation).
library;

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/conversation_spaces.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';

/// The searchable member picker: the creation dialog's checkbox list
/// (LaRow + LaCheckbox) with a filter field on top — the 2000-actor
/// world must not scroll a flat list to find one name. Pure: the
/// selected set and the toggle live with the host, so the same widget
/// serves creation, the popover's picker state and the standalone
/// dialog. The empty state is honest — no candidates renders the
/// no-candidates line (key `<rowKeyPrefix>.empty`), never a dead list.
final class ChannelMemberPicker extends StatefulWidget {
  const ChannelMemberPicker({
    required this.candidates,
    required this.selected,
    required this.onToggle,
    this.searchKey,
    this.rowKeyPrefix = 'rail.pick.actor',
    this.searchHint,
    this.emptyText,
    super.key,
  });

  /// The addable actors (the host filters out members and humans —
  /// world truth, never invented members).
  final List<ActorProfile> candidates;

  /// The currently checked ids (the host's set, mutated via
  /// [onToggle]).
  final Set<String> selected;

  final void Function(String actorId) onToggle;

  /// The search field's agent-contract key (null keeps the field
  /// anonymous — the creation dialog's original shape had no field).
  final Key? searchKey;

  /// The row keys' prefix (the creation dialog's frozen
  /// `rail.pick.actor` is the default).
  final String rowKeyPrefix;

  final String? searchHint;

  /// The honest empty-state line (default: the no-candidates string).
  final String? emptyText;

  @override
  State<ChannelMemberPicker> createState() => _ChannelMemberPickerState();
}

class _ChannelMemberPickerState extends State<ChannelMemberPicker> {
  String _query = '';

  @override
  Widget build(final BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = <ActorProfile>[
      for (final actor in widget.candidates)
        if (query.isEmpty ||
            actor.displayName.toLowerCase().contains(query) ||
            actor.actorId.toLowerCase().contains(query))
          actor,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LaField(
          key: widget.searchKey,
          placeholder:
              widget.searchHint ?? context.l10n.worldChatMembersSearchHint,
          onChanged: (final value) => setState(() => _query = value),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.emptyText ??
                        context.l10n.worldChatMembersNoCandidates,
                    key: ValueKey('${widget.rowKeyPrefix}.empty'),
                    textAlign: TextAlign.center,
                    style: context.laUi.compact.copyWith(
                      color: context.shellMuted,
                    ),
                  ),
                )
              : ListView.builder(
                  // Lazy: the picker may face the whole roster.
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (final context, final index) {
                    final actor = filtered[index];
                    return LaRow(
                      key: ValueKey(
                        '${widget.rowKeyPrefix}.${actor.actorId}',
                      ),
                      margin: EdgeInsets.zero,
                      leading: LaCheckbox(
                        value: widget.selected.contains(actor.actorId),
                        onChanged: (_) => widget.onToggle(actor.actorId),
                      ),
                      titleText: actor.displayName,
                      metaText: actor.role.isEmpty ? null : actor.role,
                      onTap: () => widget.onToggle(actor.actorId),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// One actor's channel-removal losses, computed from world truth (never
/// invented): [beatCount] is the channel thread's history size (`-1`
/// when no world can answer) and [runningTasks] holds the durable
/// tasks currently addressed to the actor. Removal cancels NOTHING —
/// the confirm's note says so; the rows are facts, not threats.
final class ChannelRemovalLosses {
  const ChannelRemovalLosses({
    required this.beatCount,
    required this.runningTasks,
  });

  /// The channel thread's beat count; `-1` = unknown (no world).
  final int beatCount;

  /// The task sentences addressed to the actor right now.
  final List<String> runningTasks;
}

/// Reads one actor's losses for [confirmChannelRemoval] — the beat
/// projection over the channel's thread plus the world's task rows.
Future<ChannelRemovalLosses> channelRemovalLosses(
  final BuildContext context, {
  required final RealmChatService service,
  required final String threadId,
  required final String actorId,
}) async {
  final world = service.world;
  var beats = -1;
  if (world != null) {
    try {
      beats = (await world.projection.beatsOfThread(threadId)).length;
    } on Object {
      // An unreadable projection keeps the honest unknown.
      beats = -1;
    }
  }
  final worldState = context.read<WorldStateService?>();
  final tasks = <String>[
    if (worldState != null)
      for (final task in worldState.tasks)
        if (task.running && task.addressees.contains(actorId)) task.task,
  ];
  return ChannelRemovalLosses(beatCount: beats, runningTasks: tasks);
}

/// The outcome verbs of [confirmChannelRemoval]: `null` = the human
/// cancelled or the dialog was dismissed; `'ok'` = the member set was
/// written; anything else = the named refusal verbatim (the
/// honest-refusal law — the caller renders it, never a paraphrase).
Future<String?> confirmChannelRemoval(
  final BuildContext context, {
  required final RealmChatService service,
  required final ChannelInfo channel,
  required final String actorId,
}) async {
  final roster = service.roster?.get(actorId);
  // The human is PERMANENT in channels (owner law, 2026-11-18): the
  // verb refuses before any dialog (the UI hides the affordance; this
  // is the honesty backstop).
  if (roster?.kind == ActorKind.human || actorId == service.humanActorId) {
    return 'channel_member_human_permanent';
  }
  final l10n = context.l10n;
  final actorName = roster?.displayName ?? actorDisplayFallback(actorId);
  final losses = await channelRemovalLosses(
    context,
    service: service,
    threadId: channel.threadId,
    actorId: actorId,
  );
  if (!context.mounted) return null;
  // Not showLaConfirm: the buttons' keys are the frozen agent contract
  // (`channel.member.remove.cancel/confirm`), so the confirm rides
  // showLaDialog+LaDialog with keyed kit buttons (the actor-info
  // removal's own pattern).
  final ok = await showLaDialog<bool>(
    context: context,
    builder: (final dialogContext) => LaDialog(
      key: const ValueKey('channel.member.remove.dialog'),
      titleText: l10n.worldChatMemberRemoveTitle(actorName, '#${channel.name}'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lossRow(
              dialogContext,
              'history',
              losses.beatCount < 0
                  ? '—'
                  : l10n.worldChatMemberRemoveMessages(losses.beatCount),
            ),
            _lossRow(
              dialogContext,
              'tasks',
              losses.runningTasks.isEmpty
                  ? l10n.worldChatMemberRemoveNoTasks
                  : l10n.worldChatMemberRemoveTasks(losses.runningTasks.length),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.worldChatMemberRemoveNote,
              style: dialogContext.laUi.micro.copyWith(
                color: dialogContext.shellMuted,
              ),
            ),
          ],
        ),
      ),
      actions: [
        LaButton(
          key: const ValueKey('channel.member.remove.cancel'),
          variant: LaButtonVariant.ghost,
          onPressed: () => Navigator.of(dialogContext).pop(false),
          label: l10n.modelsCancel,
        ),
        LaButton(
          key: const ValueKey('channel.member.remove.confirm'),
          variant: LaButtonVariant.destructive,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          label: l10n.worldChatMemberRemoveTooltip,
        ),
      ],
    ),
  );
  if (ok != true) return null;
  final removed = await service.setChannelMembers(
    channelId: channel.channelId,
    memberIds: [
      for (final id in channel.memberIds)
        if (id != actorId) id,
    ],
  );
  return removed ? 'ok' : (service.error ?? 'remove_refused');
}

/// One loss row: the journal-field label (never localized — the
/// facts-block law) over the value in mono.
Widget _lossRow(
  final BuildContext context,
  final String label,
  final String value,
) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 2),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 64,
        child: Text(label, style: LaTokens.mono(10.5, context.shellMuted)),
      ),
      Expanded(child: Text(value, style: LaTokens.mono(10.5, context.la.ink))),
    ],
  ),
);

/// The channel's add-members dialog — the rooms-column menu row's and
/// the people view's section verb's shared surface. Candidates are the
/// roster's model actors NOT already members; one confirm writes the
/// merged set through [RealmChatService.setChannelMembers] and closes.
/// A refusal keeps the dialog open with the service's named refusal
/// rendered verbatim (the honest-outcome law).
Future<void> openChannelMembersDialog(
  final BuildContext context, {
  required final RealmChatService service,
  required final ChannelInfo channel,
}) async {
  final picked = <String>{};
  String? outcome;
  var outcomeError = false;
  await showLaDialog<void>(
    context: context,
    builder: (final dialogContext) => StatefulBuilder(
      builder: (final dialogContext, final setDialogState) {
        // The channel re-reads per build: a membership changed elsewhere
        // lands here without a stale base set.
        final fresh = service.channelByThreadId(channel.threadId) ?? channel;
        final members = fresh.memberIds.toSet();
        final candidates = <ActorProfile>[
          for (final actor in service.roster?.all ?? const <ActorProfile>[])
            if (actor.kind != ActorKind.human &&
                !members.contains(actor.actorId))
              actor,
        ];
        return LaDialog(
          key: const ValueKey('channel.members.dialog'),
          titleText: dialogContext.l10n.worldChatMembersAddTitle(
            '#${fresh.name}',
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: ChannelMemberPicker(
                    searchKey: const ValueKey('channel.members.search'),
                    rowKeyPrefix: 'channel.members.pick',
                    candidates: candidates,
                    selected: picked,
                    onToggle: (final actorId) => setDialogState(() {
                      if (picked.contains(actorId)) {
                        picked.remove(actorId);
                      } else {
                        picked.add(actorId);
                      }
                    }),
                  ),
                ),
                if (outcome != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      outcome!,
                      key: const ValueKey('channel.members.outcome'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LaTokens.mono(
                        10,
                        outcomeError
                            ? dialogContext.la.danger
                            : dialogContext.la.inkMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            LaButton(
              variant: LaButtonVariant.ghost,
              onPressed: () => Navigator.of(dialogContext).pop(),
              label: dialogContext.l10n.worldChatCancel,
            ),
            LaButton(
              key: const ValueKey('channel.members.confirm'),
              variant: LaButtonVariant.primary,
              onPressed: picked.isEmpty
                  ? null
                  : () async {
                      final count = picked.length;
                      final ok = await service.setChannelMembers(
                        channelId: fresh.channelId,
                        memberIds: [...fresh.memberIds, ...picked],
                      );
                      if (!dialogContext.mounted) return;
                      setDialogState(() {
                        if (ok) {
                          picked.clear();
                          outcome = dialogContext.l10n.worldChatMembersAddCount(
                            count,
                            '#${fresh.name}',
                          );
                          outcomeError = false;
                        } else {
                          outcome = service.error ?? 'add_refused';
                          outcomeError = true;
                        }
                      });
                    },
              label: dialogContext.l10n.worldChatMembersAddSelected(
                picked.length,
              ),
            ),
          ],
        );
      },
    ),
  );
}
