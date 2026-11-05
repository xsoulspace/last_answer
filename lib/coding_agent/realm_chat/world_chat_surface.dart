import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
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

class _ConversationPane extends StatelessWidget {
  const _ConversationPane({required this.service, required this.composer});
  final RealmChatService service;
  final TextEditingController composer;

  @override
  Widget build(final BuildContext context) {
    final threadId = service.activeThreadId;
    final thread = service.activeThread;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (threadId == null || thread == null) {
      // No thread open: calm empty state — the rail lists the
      // conversations, the surface never duplicates it.
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
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: beats.length,
                  itemBuilder: (final context, final index) {
                    final beat = beats[index];
                    final author = beat['author']! as String;
                    final previous = index == 0 ? null : beats[index - 1];
                    final grouped =
                        previous != null &&
                        previous['author'] == author &&
                        previous['addressedTo'].toString() ==
                            beat['addressedTo'].toString();
                    final profile =
                        roster?.get(author) ??
                        ActorProfile(
                          actorId: author,
                          displayName: displayNameOf(author),
                        );
                    return _MessageRow(
                      key: ValueKey('worldchat.beat.$threadId#${beat['beat']}'),
                      profile: profile,
                      isHuman: author == service.humanActorId,
                      text: beat['text']! as String,
                      at: beat['at'] as String?,
                      showHeader: !grouped,
                    );
                  },
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

/// The quiet conversation header, on the `_MessageRow` style system:
/// identity mark (avatar / channel disc), name in strong ink, muted
/// meta (kind·role for a DM, member/participant counts otherwise), then
/// the context-column toggle and the close affordance.
class _ConversationHeader extends StatelessWidget {
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
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final muted = context.shellMuted;
    final meta = channel != null
        ? l10n.worldChatMembers(channel!.memberIds.length)
        : other != null
        ? _kindAndRole(other!)
        : l10n.worldChatParticipants(participants.length);
    final name = channel != null
        ? '#${channel!.name}'
        : other?.displayName ?? topic;
    // Wave 3A — the quiet typing indicator, derived from the service's
    // narration for this thread's participants: a DM names its one bot,
    // a channel or group any member bot mid-reply (thinking or
    // generating). Absent = nothing rendered, no reserved space.
    final narrations = service.botNarration;
    final human = service.humanActorId;
    String? typingName;
    for (final participant in participants) {
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
        : other!.kind == ActorKind.human
        ? theme.colorScheme.primary
        : actorColor(other!.actorId);
    // The identity IS the entry point to the actor's profile: tapping
    // the avatar/name hosts the people view on that actor (phase 1:
    // the dock retired, the shell decides where — a tab). Channels and
    // group topics are not one identity — they stay inert.
    final onFocusActor = ViewScope.of(context)?.onFocusActor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
      child: Row(
        children: [
          InkWell(
            key: const ValueKey('worldchat.identity'),
            onTap: other == null || onFocusActor == null
                ? null
                : () => onFocusActor(other!.actorId),
            child: _headerMark(theme),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: other == null || onFocusActor == null
                  ? null
                  : () => onFocusActor(other!.actorId),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: nameColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ),
          if (typingName != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$typingName is thinking…',
                key: const ValueKey('worldchat.typing'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          IconButton(
            key: const ValueKey('worldchat.close'),
            tooltip: l10n.worldChatCloseTooltip,
            icon: const Icon(Icons.archive_outlined, size: 20),
            visualDensity: VisualDensity.compact,
            onPressed: () => unawaited(service.closeThread(threadId)),
          ),
        ],
      ),
    );
  }

  /// The header's identity mark: the DM avatar (with presence), the
  /// channel's bare `#` glyph in its quiet ink (no box — the glyph IS
  /// the mark), or a derived identicon for a group.
  Widget _headerMark(final ThemeData theme) => switch (this) {
    _ when channel != null => SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Text(
          '#',
          style: theme.textTheme.titleMedium?.copyWith(
            color: actorColor(channel!.channelId),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    _ when other != null => ActorAvatar(
      profile: other!,
      size: 28,
      showPresence: showPresence,
      presenceOnline: presenceOnline,
    ),
    _ => actorIdenticon(threadId, size: 28),
  };

  /// A DM's meta names WHO holds the agency: the kind, then the role
  /// the human authored for it (ADR 0024 §2 — labels, not icons;
  /// sentence case per DESIGN §2).
  static String _kindAndRole(final ActorProfile profile) => [
    profile.kind.name[0].toUpperCase() + profile.kind.name.substring(1),
    if (profile.role.isNotEmpty) profile.role,
  ].join(' · ');
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
