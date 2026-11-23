/// The realm coordination board (ADR 0039, stages 1–3): the durable
/// task queue RENDERED — never a second store. Rows are [WorldTaskRow]s
/// the world-state service already folds from the realm journal's
/// `durable_tasks` collection; the lane word is the canonical
/// [BoardTaskStatus] via `cardStatusOfQueue` (the ONE-vocabulary law:
/// queue words never leak onto lanes, and `unknown` renders failed —
/// an unproven outcome is a visible failure, never a success).
///
/// Owner decisions (2026-11-23): workspace scoping is a FILTER over one
/// substrate (all / per project) — never separate boards; "requires
/// attention" is a preset over the same rows, not another surface.
/// Tapping a row opens the SAME durable detail the inbox opens (one
/// truth pane, two projections). This module is a leaf: the kit, the
/// journal projection and the shared detail dialog — never the shell.
library;

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/ui_boards/task_detail_dialog.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';

/// The coordination strip: five canonical lanes over the realm's
/// durable tasks, filtered by workspace and (optionally) reduced to
/// the rows that need the operator.
final class RealmTaskBoard extends StatefulWidget {
  const RealmTaskBoard({required this.world, super.key});

  /// The journal projection; null renders the honest quiet note (a
  /// shell without the world service has no coordination to show).
  final WorldStateService? world;

  @override
  State<RealmTaskBoard> createState() => _RealmTaskBoardState();
}

class _RealmTaskBoardState extends State<RealmTaskBoard> {
  /// The workspace filter — null shows every row (the owner's "see
  /// all, or per workspace" law: one substrate, different filters).
  String? _workspace;

  /// The "requires attention" preset (stage 3): non-terminal rows,
  /// durable cancels riding live work, and unproven settlements.
  bool _attentionOnly = false;

  /// The lanes in canonical order — the ONE task vocabulary.
  static const List<BoardTaskStatus> _lanes = BoardTaskStatus.values;

  /// Attention facts: still in flight, a cancel riding live work, or
  /// a settlement that could not be proven (`unknown` → failed lane,
  /// and it stays an attention row — honesty keeps asking).
  static bool needsAttention(final WorldTaskRow task) =>
      !task.terminal || task.cancelRequested || task.state == 'unknown';

  bool _visible(final WorldTaskRow task) =>
      (_workspace == null || task.projectId == _workspace) &&
      (!_attentionOnly || needsAttention(task));

  /// The workspace choices the rows actually carry — never invented.
  List<String> _workspacesOf(final List<WorldTaskRow> tasks) =>
      <String>{for (final task in tasks) ?task.projectId}.toList()..sort();

  @override
  Widget build(final BuildContext context) {
    final world = widget.world;
    final laUi = context.laUi;
    return KeyedSubtree(
      key: const ValueKey('board.realm'),
      child: ListenableBuilder(
        listenable: world ?? ValueNotifier<int>(0),
        builder: (final context, final _) {
          if (world == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.l10n.boardsNoWorld,
                style: LaTokens.mono(10, context.la.inkQuiet),
              ),
            );
          }
          final tasks = [
            for (final task in world.tasks)
              if (_visible(task)) task,
          ];
          final workspaces = _workspacesOf(world.tasks);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.boardsCoordinationTitle,
                      style: laUi.emphasis,
                    ),
                    const Spacer(),
                    // LaSelect's trigger carries an Expanded — it
                    // needs a bounded width inside a header row.
                    SizedBox(
                      width: 170,
                      child: LaSelect<String?>(
                        key: const ValueKey('board.realm.filter.workspace'),
                        value: _workspace,
                        onChanged: (final value) =>
                            setState(() => _workspace = value),
                        items: [
                          LaSelectItem(
                            value: null,
                            label: context.l10n.boardsWorkspaceAll,
                          ),
                          for (final workspace in workspaces)
                            LaSelectItem(value: workspace, label: workspace),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    LaButton(
                      key: const ValueKey('board.realm.filter.attention'),
                      variant: LaButtonVariant.ghost,
                      onPressed: () =>
                          setState(() => _attentionOnly = !_attentionOnly),
                      label: context.l10n.boardsAttentionToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 190,
                  child: tasks.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text(
                            context.l10n.boardsNoTasks,
                            style: LaTokens.mono(10, context.la.inkQuiet),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < _lanes.length; i++) ...[
                              if (i > 0) const SizedBox(width: 12),
                              Expanded(
                                child: _RealmLane(
                                  lane: _lanes[i],
                                  tasks: [
                                    for (final task in tasks)
                                      if (cardStatusOfQueue(task.state) ==
                                          _lanes[i])
                                        task,
                                  ],
                                  world: world,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One canonical lane: the rows the queue's own states render here.
final class _RealmLane extends StatelessWidget {
  const _RealmLane({
    required this.lane,
    required this.tasks,
    required this.world,
  });

  final BoardTaskStatus lane;
  final List<WorldTaskRow> tasks;
  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${lane.name} (${tasks.length})',
          key: ValueKey('board.realm.lane.${lane.name}'),
          style: laUi.micro,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final task in tasks)
                _RealmTaskRow(
                  key: ValueKey('board.realm.card.${task.taskId}'),
                  task: task,
                  world: world,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One coordination row: the delegated sentence, the canonical state
/// word (never the queue's own), the rung, the origin actor and the
/// addressed executors — who announced it, who works it. Tap opens the
/// SAME durable detail the inbox opens.
final class _RealmTaskRow extends StatelessWidget {
  const _RealmTaskRow({required this.task, required this.world, super.key});

  final WorldTaskRow task;
  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final laUi = context.laUi;
    final sentence = task.task.isEmpty ? task.taskId : task.task;
    final lane = cardStatusOfQueue(task.state);
    final laneColor = switch (lane) {
      BoardTaskStatus.running => la.caution,
      BoardTaskStatus.failed => la.danger,
      BoardTaskStatus.cancelled => la.inkMuted,
      _ => la.inkQuiet,
    };
    return Semantics(
      button: true,
      label: 'board.realm.card.${task.taskId}',
      hint: sentence,
      child: LaBox(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: BorderSide(color: laUi.rule),
        radius: BorderRadius.circular(4),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => unawaited(
            showLaDialog<void>(
              context: context,
              builder: (final _) =>
                  TaskDetailDialog(world: world, taskId: task.taskId),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sentence,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: laUi.compact,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  // The state cell expands (absorbing free width) so
                  // narrow lanes never overflow — the marks shrink
                  // with an ellipsis instead.
                  Expanded(
                    child: Text(
                      task.state,
                      key: ValueKey('board.realm.card.${task.taskId}.state'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LaTokens.mono(9, laneColor),
                    ),
                  ),
                  if (task.cancelRequested)
                    Flexible(
                      child: Text(
                        context.l10n.boardsCancelRequested,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LaTokens.mono(9, la.caution),
                      ),
                    ),
                  if (task.modelId case final model?)
                    Flexible(
                      child: Text(
                        model,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: LaTokens.mono(9, la.inkQuiet),
                      ),
                    ),
                ],
              ),
              if (task.actorId != null ||
                  task.addressees.isNotEmpty ||
                  task.projectId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    [
                      if (task.actorId case final actor?) 'by $actor',
                      if (task.addressees.isNotEmpty)
                        'to ${task.addressees.join(', ')}',
                      if (task.projectId case final project?) '@$project',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LaTokens.mono(9, la.inkQuiet),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
