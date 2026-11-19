/// Phase 1d — the landing inbox (docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md §2.1 "Landing state"):
/// what the Conversations view shows when no thread is open — the void
/// becomes a decision surface. Open permissions REJECT-FIRST (the
/// default action is the safe one, North Star §6: one screen, one
/// decision at a time), running/queued tasks with the spend the journal
/// already carries, the last verdicts, and the recent threads' last
/// words. Assembled from the same projections the MCP tools read — no
/// second source of truth ([WorldStateService], [RealmChatService]).
library;


import 'dart:convert';

import 'package:lastanswer/journal/realm_chat_service.dart';
import 'package:lastanswer/journal/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/world/creatures.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:lastanswer/ui_shell/status_edge.dart' show HealthDot;
import 'package:lastanswer/world/creature_mark.dart';

/// The inbox's readable column (the Tufte measure — the shell never
/// stretches text edge-to-edge).
const double _kInboxMeasure = 620;

/// The landing inbox: the Conversations view's no-thread state.
final class LandingInbox extends StatelessWidget {
  const LandingInbox({
    required this.world,
    required this.service,
    required this.onOpenThread,
    super.key,
  });

  final WorldStateService world;
  final RealmChatService? service;

  /// Opens one recent thread (the shell maps the selection onto its
  /// conversation tab).
  final ValueChanged<String> onOpenThread;

  @override
  Widget build(final BuildContext context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kInboxMeasure),
        child: ListenableBuilder(
          listenable: world,
          // The sections are composed INSIDE the builder: every notify
          // must mint fresh widget instances (a cached instance updates
          // as identical and its children never rebuild — the shell's
          // title-stuck law).
          builder: (final context, final _) => ListView(
            key: const ValueKey('shell.landingInbox'),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: _sections(context),
          ),
        ),
      ),
    );

  List<Widget> _sections(final BuildContext context) {
    final l10n = context.l10n;
    return <Widget>[
      if (!world.daemonLive)
        _ArmRow(world: world)
      else if (world.attentionCount == 0 && world.verdicts.isEmpty)
        _QuietRow(text: l10n.inboxEmpty),
      if (world.permissions.isNotEmpty)
        _Section(
          title: l10n.inboxPermissions,
          keyName: 'inbox.permissions',
          children: [
            for (final permission in world.permissions)
              _PermissionRow(
                key: ValueKey('inbox.perm.${permission.sessionId}'),
                permission: permission,
              ),
          ],
        ),
      if (world.runningTasks.isNotEmpty)
        _Section(
          title: l10n.inboxRunning,
          keyName: 'inbox.running',
          children: [
            for (final task in world.runningTasks)
              _TaskRow(
                key: ValueKey('inbox.task.${task.taskId}'),
                task: task,
                daemonLive: world.daemonLive,
                onOpen: () => unawaited(
                  showLaDialog<void>(
                    context: context,
                    builder: (final _) =>
                        _TaskDetailDialog(world: world, taskId: task.taskId),
                  ),
                ),
              ),
          ],
        ),
      if (world.verdicts.isNotEmpty)
        _Section(
          title: l10n.inboxVerdicts,
          keyName: 'inbox.verdicts',
          children: [
            for (final verdict in world.verdicts.take(6))
              _VerdictRow(
                key: ValueKey('inbox.verdict.${verdict.id}'),
                verdict: verdict,
              ),
          ],
        ),
      if (_recentThreads().isNotEmpty)
        _Section(
          title: l10n.inboxThreads,
          keyName: 'inbox.threads',
          children: [
            for (final thread in _recentThreads())
              _ThreadRow(
                key: ValueKey('inbox.thread.${thread.$1}'),
                threadId: thread.$1,
                preview: thread.$2,
                onOpen: onOpenThread,
              ),
          ],
        ),
    ];
  }

  /// The five most recent threads with a last-word preview (the
  /// service's own thread projection — newest activity first).
  List<(String, String)> _recentThreads() {
    final chat = service;
    if (chat == null) return const [];
    final previews = chat.beatPreviews();
    return [
      for (final thread in chat.threads.take(5))
        if (thread['threadId'] is String)
          (
            thread['threadId']! as String,
            previews[thread['threadId']] ??
                '${thread['topic'] ?? thread['threadId']}',
          ),
    ];
  }
}

/// The daemon-down row: one honest line + the ONE-click arm (the first
/// session script's step 1 — the edge's action, at the point of need).
final class _ArmRow extends StatelessWidget {
  const _ArmRow({required this.world});

  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    final arming = world.armState == WorldArmState.arming;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        key: const ValueKey('inbox.arm'),
        children: [
          // 3d — the world sleeps when the daemon is down (DESIGN v2:
          // it sleeps ONLY when the daemon is down); the honest health
          // dot stays — the creature carries the state, never the fact.
          const CreatureMark(
            actorId: kWorldCreatureId,
            mood: CreatureMood.asleep,
            size: 18,
          ),
          const SizedBox(width: 6),
          HealthDot(status: arming ? 'loading' : 'failed', size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              arming
                  ? l10n.inboxWorldArming
                  : world.armState == WorldArmState.error
                  ? '${l10n.inboxWorldArmFailed}: ${world.armError ?? ''}'
                  : l10n.inboxWorldDown,
              style: context.laUi.compact.copyWith(color: la.inkMuted),
            ),
          ),
          if (!arming)
            LaButton(
              key: const ValueKey('inbox.arm.button'),
              variant: LaButtonVariant.ghost,
              onPressed: () => unawaited(world.armWorld()),
              label: l10n.edgeArmWorld,
            ),
        ],
      ),
    );
  }
}

/// The all-quiet row: no decision waits — the inbox says so and stays
/// out of the way. 3d: the world creature is the greeter here (DESIGN
/// v2's one larger creature moment on an empty state) — calm, awake,
/// quietly blinking in place of the plain health dot; the words stay
/// the state's carrier (never color/shape alone).
final class _QuietRow extends StatelessWidget {
  const _QuietRow({required this.text});

  final String text;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      key: const ValueKey('inbox.quiet'),
      children: [
        const CreatureMark(
          actorId: kWorldCreatureId,
          mood: CreatureMood.calm,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: context.laUi.compact.copyWith(color: context.la.inkMuted),
        ),
      ],
    ),
  );
}

/// One inbox section: a micro label + its rows.
final class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.keyName,
    required this.children,
  });

  final String title;
  final String keyName;
  final List<Widget> children;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      key: ValueKey(keyName),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(title, style: shellSectionLabel(context)),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.shellRaised,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    ),
  );
}

/// One permission row — REJECT-FIRST: Deny is the left/default action,
/// Allow is the deliberate one (the safe default needs no aim).
final class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.permission, super.key});

  final InboxPermission permission;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: la.rule, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 14, color: la.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.compact,
                ),
                if (permission.kind != null || permission.since != null)
                  Text(
                    [
                      if (permission.kind != null) '${permission.kind}',
                      if (permission.since != null) '${permission.since}',
                    ].join(' · '),
                    style: context.laUi.micro.copyWith(
                      color: la.inkQuiet,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _InboxButton(
            keyName: 'inbox.perm.deny.${permission.sessionId}',
            label: l10n.inboxDeny,
            danger: true,
            onTap: () => unawaited(permission.answer(false)),
          ),
          const SizedBox(width: 6),
          _InboxButton(
            keyName: 'inbox.perm.allow.${permission.sessionId}',
            label: l10n.inboxAllow,
            onTap: () => unawaited(permission.answer(true)),
          ),
        ],
      ),
    );
  }
}

/// One running/queued task row: the delegated sentence, its state word
/// and the rung it rides (spend lands on the verdict when the world
/// settles it — the creation receipt is not a completion). Wave N5:
/// the row OPENS the task's durable detail (tap), and a queued row
/// under a sleeping daemon names WHY it waits (the scheduler is the
/// queue's only claimant pump) instead of reading as "running".
final class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.daemonLive,
    required this.onOpen,
    super.key,
  });

  final WorldTaskRow task;
  final bool daemonLive;
  final VoidCallback onOpen;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final waiting = task.state == 'queued' && !daemonLive;
    return Semantics(
      button: true,
      label: 'inbox.task.${task.taskId}',
      hint: task.task,
      child: ShellRow(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LaSpinner(size: 10, strokeWidth: 1.5, color: la.inkQuiet),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    task.task.isEmpty ? task.taskId : task.task,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.laUi.compact,
                  ),
                ),
                const SizedBox(width: 8),
                if (task.modelId case final model?)
                  Text(model, style: LaTokens.mono(10, la.inkQuiet)),
                const SizedBox(width: 8),
                Text(
                  task.state,
                  style: context.laUi.micro.copyWith(
                    color: la.caution,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            if (waiting)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 0, 2),
                child: Text(
                  context.l10n.inboxQueuedReason,
                  key: ValueKey('inbox.task.${task.taskId}.waiting'),
                  style: LaTokens.mono(9, la.inkQuiet),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The task's durable detail (wave N5): the journal row VERBATIM —
/// sentence, state, the timeline stamps the queue wrote, the terminal
/// verdict when settled — plus the control-event tail and the owner's
/// Cancel through the queue's own verb. Bounces render verbatim.
final class _TaskDetailDialog extends StatefulWidget {
  const _TaskDetailDialog({required this.world, required this.taskId});

  final WorldStateService world;
  final String taskId;

  @override
  State<_TaskDetailDialog> createState() => _TaskDetailDialogState();
}

final class _TaskDetailDialogState extends State<_TaskDetailDialog> {
  Map<String, Object?>? _row;
  List<Map<String, Object?>> _events = const [];
  String? _bounce;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final row = await widget.world.taskDetail(widget.taskId);
    final events = await widget.world.taskEvents(widget.taskId);
    if (!mounted) return;
    setState(() {
      _row = row;
      _events = events;
    });
  }

  Future<void> _cancel() async {
    final receipt = await widget.world.taskCancel(widget.taskId);
    if (!mounted) return;
    setState(
      () => _bounce = receipt['ok'] == true ? null : envelopeOf(receipt),
    );
    if (receipt['ok'] == true) await _load();
  }

  /// The delegated sentence verbatim: the payload prompt when the
  /// row carries one, else the row's own task text.
  String _sentenceOf(final Map<String, Object?>? row) {
    final payload = row?['payload'];
    if (payload is Map) return '${payload['prompt'] ?? ''}';
    return '${row?['task'] ?? ''}';
  }

  String envelopeOf(final Map<String, Object?> receipt) =>
      '${receipt['bounce'] ?? 'cancel_refused'}';

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    final row = _row;
    final terminal = row?['terminal'];
    return LaDialog(
      key: ValueKey('inbox.task.${widget.taskId}.detail'),
      title: Text(
        l10n.inboxTaskDetail,
        style: context.laUi.body.copyWith(fontWeight: FontWeight.w600),
      ),
      width: 500,
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_sentenceOf(row), style: context.laUi.body),
              const SizedBox(height: 8),
              for (final key in const [
                'state',
                'model',
                'admittedAt',
                'leaseAcquiredAt',
                'startedAt',
                'settledAt',
              ])
                if (row?[key] != null)
                  Text(
                    '$key: ${row![key]}',
                    style: LaTokens.mono(10, la.inkMuted),
                  ),
              if (terminal is Map) ...[
                const SizedBox(height: 6),
                Text(
                  'terminal: ${terminal['state'] ?? ''}'
                  '${terminal['summary'] ?? terminal['reason'] ?? ''}',
                  style: LaTokens.mono(10, la.caution),
                ),
              ],
              const SizedBox(height: 8),
              Text(l10n.inboxTaskEvents, style: LaTokens.mono(10, la.inkMuted)),
              if (_events.isEmpty)
                Text(
                  l10n.inboxTaskNoEvents,
                  style: LaTokens.mono(10, la.inkQuiet),
                )
              else
                for (final event in _events.take(8))
                  Text(
                    const JsonEncoder.withIndent(' ').convert(event),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: LaTokens.mono(9, la.inkQuiet),
                  ),
              if (_bounce != null)
                Text(_bounce!, style: LaTokens.mono(10, la.danger)),
            ],
          ),
        ),
      ),
      actions: [
        if (row != null && terminal == null)
          LaButton(
            key: ValueKey('inbox.task.${widget.taskId}.cancel'),
            variant: LaButtonVariant.ghost,
            onPressed: () => unawaited(_cancel()),
            label: l10n.inboxTaskCancel,
          ),
        LaButton(
          variant: LaButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
          label: l10n.modelsCancel,
        ),
      ],
    );
  }
}

/// One verdict row: the terminal truth, colored by outcome.
final class _VerdictRow extends StatelessWidget {
  const _VerdictRow({required this.verdict, super.key});

  final WorldVerdictRow verdict;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final color = switch (verdict.state) {
      'succeeded' => la.accent,
      'failed' => la.danger,
      'cancelled' => la.inkQuiet,
      _ => la.inkMuted,
    };
    return Semantics(
      label: 'inbox.verdict.${verdict.id}',
      hint: verdict.line,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: la.rule, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                verdict.line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.laUi.compact,
              ),
            ),
            const SizedBox(width: 8),
            if (verdict.spend case final spend?)
              Text(spend, style: LaTokens.mono(10, la.inkQuiet)),
            const SizedBox(width: 8),
            Text(
              verdict.state,
              style: context.laUi.micro.copyWith(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// One recent-thread row: the last word across the thread, a click
/// re-opens it.
final class _ThreadRow extends StatelessWidget {
  const _ThreadRow({
    required this.threadId,
    required this.preview,
    required this.onOpen,
    super.key,
  });

  final String threadId;
  final String preview;
  final ValueChanged<String> onOpen;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return Semantics(
      button: true,
      label: 'inbox.thread.$threadId',
      hint: preview,
      child: ShellRow(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: () => onOpen(threadId),
        child: Row(
          children: [
            Icon(Icons.forum_outlined, size: 13, color: la.inkQuiet),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.laUi.compact.copyWith(color: la.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The inbox's small row button (Deny/Allow): quiet fill, sentence case.
final class _InboxButton extends StatelessWidget {
  const _InboxButton({
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
  Widget build(final BuildContext context) {
    final la = context.la;
    final color = danger ? la.danger : la.inkMuted;
    return Semantics(
      button: true,
      label: keyName,
      hint: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: ValueKey(keyName),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                label,
                style: context.laUi.micro.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
