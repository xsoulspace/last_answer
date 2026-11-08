/// Phase 3b — the Threads view (docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md §2.2.2): the home of the
/// threads the rail cannot name. DMs and channels live in the rail's
/// roster; plain group threads (and the closed ones) had no chrome at
/// all — here they are, as a read-only projection of the SAME sources
/// the MCP tools read: the realm's thread list ([RealmChatService]) and
/// the live session registry (the index the inspector polls). A click
/// opens the thread in the Conversations view; sessions are observed,
/// never driven, from here.
library;

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// The Threads view body: world threads + live session rows.
final class ThreadsView extends StatelessWidget {
  const ThreadsView({
    required this.service,
    required this.onOpenThread,
    super.key,
  });

  final RealmChatService? service;

  /// Opens one world thread in the Conversations view.
  final ValueChanged<String> onOpenThread;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final threads = service?.threads ?? const <Map<String, Object?>>[];
    final previews = service?.beatPreviews() ?? const <String, String>{};
    final sessions = HarnessSessionRegistry.instance.sessions.entries.toList();
    return ListenableBuilder(
      listenable: service ?? ValueNotifier(0),
      builder: (final context, final _) => ListView(
        key: const ValueKey('shell.threadsView'),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          Text(l10n.threadsWorld, style: shellSectionLabel(context)),
          const SizedBox(height: 6),
          if (threads.isEmpty)
            _QuietNote(text: l10n.threadsEmpty)
          else
            for (final thread in threads)
              _ThreadRow(
                key: ValueKey('threads.row.${thread['threadId']}'),
                thread: thread,
                preview: previews[thread['threadId']],
                onTap: () => onOpenThread('${thread['threadId']}'),
              ),
          if (sessions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.threadsSessions, style: shellSectionLabel(context)),
            const SizedBox(height: 6),
            for (final session in sessions)
              _SessionRow(
                key: ValueKey('threads.session.${session.key}'),
                sessionId: session.key,
                snapshot: session.value.state,
              ),
          ],
        ],
      ),
    );
  }
}

/// One world thread: topic, participant count, the last word. A click
/// opens it in the Conversations view (the slot's own grammar).
final class _ThreadRow extends StatelessWidget {
  const _ThreadRow({
    required this.thread,
    required this.onTap,
    this.preview,
    super.key,
  });

  final Map<String, Object?> thread;
  final String? preview;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final id = '${thread['threadId']}';
    final topic = '${thread['topic'] ?? id}';
    final participants = (thread['participants'] as List? ?? const []).length;
    final closed = thread['closed'] == true;
    return Semantics(
      button: true,
      label: 'threads.row.$id',
      hint: topic,
      child: ShellRow(
        height: 40,
        onTap: closed ? null : onTap,
        child: Row(
          children: [
            Icon(
              closed ? Icons.lock_outline : Icons.forum_outlined,
              size: 14,
              color: closed ? la.inkQuiet : la.inkMuted,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: closed ? la.inkQuiet : null,
                    ),
                  ),
                  if (preview != null && preview!.isNotEmpty)
                    Text(
                      preview!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: la.inkQuiet,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('$participants', style: LaTokens.mono(10, la.inkQuiet)),
          ],
        ),
      ),
    );
  }
}

/// One live session row: presence data from the registry the inspector
/// polls — state, verdict, spend. Read-only by law: sessions are
/// observed here, never driven.
final class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.sessionId,
    required this.snapshot,
    super.key,
  });

  final String sessionId;
  final SessionSnapshot snapshot;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final state = snapshot.running ? 'running' : 'idle';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: la.rule, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: snapshot.running ? la.accent : la.inkQuiet,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              sessionId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          if (snapshot.verdict case final verdict?)
            Text(verdict, maxLines: 1, style: LaTokens.mono(10, la.inkMuted)),
          const SizedBox(width: 8),
          Text(
            state,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: snapshot.running ? la.accent : la.inkQuiet,
            ),
          ),
        ],
      ),
    );
  }
}

/// The view's quiet named absence.
final class _QuietNote extends StatelessWidget {
  const _QuietNote({required this.text});

  final String text;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      text,
      key: const ValueKey('threads.empty'),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: context.shellMuted),
    ),
  );
}
