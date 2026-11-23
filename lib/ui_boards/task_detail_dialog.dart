import 'dart:convert';

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';

/// The task's durable detail (wave N5): the journal row VERBATIM —
/// sentence, state, the timeline stamps the queue wrote, the terminal
/// verdict when settled — plus the control-event tail and the owner's
/// Cancel through the queue's own verb. Bounces render verbatim.
///
/// Public since the boards program (ADR 0039): the realm coordination
/// board opens the SAME detail for its rows — one truth pane, two
/// projections (the inbox's list, the board's lanes). Lives here, not
/// in the shell: it is world-task presentation, and the boards module
/// stays a leaf (never imports the shell).
final class TaskDetailDialog extends StatefulWidget {
  const TaskDetailDialog({
    required this.world,
    required this.taskId,
    super.key,
  });

  final WorldStateService world;
  final String taskId;

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

final class _TaskDetailDialogState extends State<TaskDetailDialog> {
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
