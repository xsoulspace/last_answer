/// The miniwindow's pinned-conversation peek (ADR 0027): a quiet,
/// read-only live observation of ONE thread — who is in it, what each
/// actor is doing, and the recent beats as they land. The beats flow
/// through `RealmChatService.beatsFor` (the in-memory kernel replica —
/// cheap to poll): read on mount, on every service notification, and
/// on a 2s timer while mounted. Replying stays in the main surface
/// (select the conversation in the rail).
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `miniwindow.peek.<threadId>` and `miniwindow.peek.<threadId>.beat.<n>`.
library;

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/shell_theme.dart';

/// A miniwindow's read-only live peek at one conversation.
final class PinnedConversationPeek extends StatefulWidget {
  const PinnedConversationPeek({
    required this.service,
    required this.threadId,
    super.key,
  });

  final RealmChatService service;
  final String threadId;

  @override
  State<PinnedConversationPeek> createState() =>
      _PinnedConversationPeekState();
}

final class _PinnedConversationPeekState extends State<PinnedConversationPeek> {
  /// The live poll cadence — the read is the kernel's in-memory
  /// replica, so this is quiet, and it runs only while mounted.
  static const Duration pollInterval = Duration(seconds: 2);

  /// The thread's recent beats (oldest → newest), refreshed on mount,
  /// on every service notification and on [pollInterval].
  List<Map<String, Object?>> _beats = const <Map<String, Object?>>[];
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onServiceChanged);
    _poll = Timer.periodic(pollInterval, (_) => _refreshBeats());
    unawaited(_refreshBeats());
  }

  @override
  void didUpdateWidget(final PinnedConversationPeek oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadId != widget.threadId ||
        oldWidget.service != widget.service) {
      _beats = const <Map<String, Object?>>[];
      unawaited(_refreshBeats());
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    widget.service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    // A notification may carry fresh thread projections; the beats
    // read rides the same signal (the poll covers quiet kernel
    // changes). beatsFor never notifies, so this cannot loop.
    unawaited(_refreshBeats());
    if (mounted) setState(() {});
  }

  Future<void> _refreshBeats() async {
    final beats = await widget.service.beatsFor(widget.threadId);
    if (!mounted) return;
    setState(() => _beats = beats);
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final thread = _threadRecord();
    if (thread == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l10n.worldChatNoConversations,
            key: ValueKey('miniwindow.peek.${widget.threadId}'),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.shellMuted,
            ),
          ),
        ),
      );
    }
    final topic = (thread['topic'] as String?) ?? widget.threadId;
    final participantIds = <String>[
      for (final id in (thread['participants'] as List? ?? const []))
        if (id is String) id,
    ];
    final participants = [
      for (final id in participantIds) _displayName(id),
    ];
    // The peek is an observation surface: a member bot's activity line
    // (wave 3A narration) is exactly what it exists to show.
    final narrationLine = _narrationLine(participantIds);
    return Padding(
      key: ValueKey('miniwindow.peek.${widget.threadId}'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            topic,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            participants.join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.shellMuted,
            ),
          ),
          if (narrationLine != null) ...[
            const SizedBox(height: 3),
            Text(
              narrationLine,
              key: ValueKey(
                'miniwindow.peek.${widget.threadId}.narration',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.shellMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: _beats.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.worldChatSelectFromRail,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.shellMuted,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final beat in _beats) _beatRow(context, beat),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// One beat: the author's display name and a quiet time on a label
  /// line, the text below (labelSmall/bodySmall, shellMuted — no
  /// Material chrome, DESIGN §2–3). Keyed
  /// `miniwindow.peek.<threadId>.beat.<n>` (n = the beat number).
  Widget _beatRow(final BuildContext context, final Map<String, Object?> beat) {
    final theme = Theme.of(context);
    final number = (beat['beat'] as num?)?.toInt() ?? 0;
    final author = (beat['author'] as String?) ?? '';
    final text = (beat['text'] as String?) ?? '';
    final time = _quietTime(beat['at'] as String?);
    return Padding(
      key: ValueKey('miniwindow.peek.${widget.threadId}.beat.$number'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _displayName(author),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.shellMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (time.isNotEmpty)
                Text(
                  time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.shellMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Map<String, Object?>? _threadRecord() {
    for (final thread in widget.service.threads) {
      if (thread['threadId'] == widget.threadId) return thread;
    }
    return null;
  }

  /// The first member bot's active narration line (null when every
  /// member is quietly listening/idle).
  String? _narrationLine(final List<String> participantIds) {
    final narrations = widget.service.botNarration;
    for (final id in participantIds) {
      final line = narrations[id]?.statusLine;
      if (line != null) return line;
    }
    return null;
  }

  /// Roster display name; without a profile the honest fallback law
  /// (`actorDisplayFallback`): the bare id, `human-<digits>` → 'Human'.
  String _displayName(final String actorId) =>
      widget.service.roster?.get(actorId)?.displayName ??
      actorDisplayFallback(actorId);

  /// Quiet time for the beat's ISO timestamp: local `HH:MM` (with the
  /// date when the beat is not from today). Unparseable reads as no
  /// time at all.
  String _quietTime(final String? atRaw) {
    final at = DateTime.tryParse(atRaw ?? '')?.toLocal();
    if (at == null) return '';
    final now = DateTime.now();
    final sameDay =
        at.year == now.year && at.month == now.month && at.day == now.day;
    final hh = at.hour.toString().padLeft(2, '0');
    final mm = at.minute.toString().padLeft(2, '0');
    return sameDay ? '$hh:$mm' : '${at.month}/${at.day} $hh:$mm';
  }
}
