/// The boards view: the product planning board as a unified-view
/// surface (the boards program, stage 4) — text-native lanes on one
/// grid (DESIGN law), every op through [PlanningBoardController] (the
/// `ecsly_boards` substrate), widget keys as the agent's UI contract.
///
/// Interaction law: a card's affordances (lane moves, settle, add
/// child) are ALWAYS visible quiet icon buttons on the row — no
/// selection state machine, one tap per op. This module is a leaf: it
/// imports the ontology and the controller, never the shell.
library;

import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/ecs_plugins/boards/planning_board_controller.dart';
import 'package:lastanswer/ecs_plugins/boards/planning_board_replica.dart';
import 'package:lastanswer/ui_boards/delegation.dart';
import 'package:lastanswer/ui_boards/task_detail_dialog.dart';

/// The planning board: one lane per column, ranked rows, inline add,
/// lane moves, decomposition. The controller is injectable (tests hand
/// a prepared one); absent one, the view owns a session-scoped
/// controller — local-first by law, the sync lane is the next program.
///
/// ADR 0039 stage 4 — dispatch is an op: when a [delegate] seam is
/// mounted (the shell builds it over the app's own harness seat), a
/// card row gains a quiet delegate op; the admitted task id renders on
/// the card as provenance and opens the SAME durable detail the inbox
/// uses. The board never dispatches by itself — no seam, no op.
final class BoardView extends StatefulWidget {
  const BoardView({
    this.controller,
    this.delegate,
    this.world,
    this.ledger,
    super.key,
  });

  final PlanningBoardController? controller;

  /// The delegation seam (shell-mounted); null hides the op.
  final BoardDelegate? delegate;

  /// The journal projection, for opening a delegated task's durable
  /// detail from its provenance line. Null renders the task id read-only.
  final WorldStateService? world;

  /// Card→task provenance; defaults to a fresh ledger.
  final BoardDelegationLedger? ledger;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  PlanningBoardController? _owned;
  Timer? _poll;
  late final BoardDelegationLedger _ledger =
      widget.ledger ?? BoardDelegationLedger();
  PlanningBoardController get controller =>
      widget.controller ?? (_owned ??= PlanningBoardController());

  Future<BoardDelegationResult> _delegateCard(
    final PlanningCardRecord card,
  ) async {
    final delegate = widget.delegate;
    if (delegate == null) {
      return const BoardDelegationResult.refused('no delegation seam');
    }
    return delegate(card.title);
  }

  @override
  void initState() {
    super.initState();
    // Remote arrivals fold into the replica on mesh sync cycles; the
    // lane re-reads on a quiet poll — the same cadence the Settings
    // mesh-tasks page uses (ADR 0023 observability).
    _poll = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // Delegation provenance loads once, before first read.
    unawaited(_ledger.ensureLoaded());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    return KeyedSubtree(
      key: const ValueKey('board'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.boardsTitle, style: laUi.emphasis),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < controller.columns.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(
                      child: _ColumnLane(
                        controller: controller,
                        column: controller.columns[i],
                        onMutate: () {
                          if (mounted) setState(() {});
                        },
                        onDelegate: _delegateCard,
                        canDelegate: widget.delegate != null,
                        ledger: _ledger,
                        world: widget.world,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One lane: the column's cards in board order, an inline composer.
final class _ColumnLane extends StatelessWidget {
  const _ColumnLane({
    required this.controller,
    required this.column,
    required this.onMutate,
    required this.onDelegate,
    required this.canDelegate,
    required this.ledger,
    this.world,
  });

  final PlanningBoardController controller;
  final String column;
  final VoidCallback onMutate;
  final Future<BoardDelegationResult> Function(PlanningCardRecord) onDelegate;
  final bool canDelegate;
  final BoardDelegationLedger ledger;
  final WorldStateService? world;

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    final cards = controller.cardsOf(column);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$column (${cards.length})',
          key: ValueKey('board.column.$column'),
          style: laUi.micro,
        ),
        const SizedBox(height: 8),
        for (final card in cards)
          _CardRow(
            key: ValueKey('board.card.${card.cardId}'),
            controller: controller,
            card: card,
            onMutate: onMutate,
            onDelegate: onDelegate,
            canDelegate: canDelegate,
            ledger: ledger,
            world: world,
          ),
        const SizedBox(height: 8),
        _Composer(
          key: ValueKey('board.add.$column'),
          controller: controller,
          column: column,
          onSubmit: onMutate,
        ),
      ],
    );
  }
}

/// One card row: title, plan marker, and the quiet op buttons — lane
/// moves, settle, delegate, and the child composer — always visible,
/// one tap per op. A delegated card renders its realm task id as
/// provenance (tap opens the durable detail when the world is bound).
final class _CardRow extends StatefulWidget {
  const _CardRow({
    required this.controller,
    required this.card,
    required this.onMutate,
    required this.onDelegate,
    required this.canDelegate,
    required this.ledger,
    this.world,
    super.key,
  });

  final PlanningBoardController controller;
  final PlanningCardRecord card;
  final VoidCallback onMutate;
  final Future<BoardDelegationResult> Function(PlanningCardRecord) onDelegate;
  final bool canDelegate;
  final BoardDelegationLedger ledger;
  final WorldStateService? world;

  @override
  State<_CardRow> createState() => _CardRowState();
}

class _CardRowState extends State<_CardRow> {
  bool _addingChild = false;
  bool _delegating = false;
  String? _refusal;

  void _run(final void Function() action) {
    action();
    widget.onMutate();
  }

  /// One delegate op: the seam admits the card as realm work; the
  /// ledger records the provenance, a refusal renders in words.
  Future<void> _delegate() async {
    if (_delegating) return;
    setState(() {
      _delegating = true;
      _refusal = null;
    });
    final result = await widget.onDelegate(widget.card);
    if (!mounted) return;
    if (result case BoardDelegationResult(taskId: final taskId?)) {
      await widget.ledger.record(widget.card.cardId, taskId);
    }
    if (mounted) {
      setState(() {
        _delegating = false;
        _refusal = result.refusal;
      });
    }
    widget.onMutate();
  }

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    final la = context.la;
    final card = widget.card;
    final columns = widget.controller.columns;
    final index = columns.indexOf(card.column);
    final delegatedTaskId = widget.ledger.taskIdOf(card.cardId);
    return LaBox(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      border: BorderSide(color: laUi.rule),
      radius: BorderRadius.circular(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('· ', style: laUi.micro),
              Expanded(child: Text(card.title, style: laUi.body)),
              if (card.status == BoardTaskStatus.completed.name)
                Icon(Icons.check, size: 14, color: laUi.accent),
            ],
          ),
          Row(
            children: [
              if (index > 0)
                _QuietOp(
                  key: const ValueKey('board.op.prev'),
                  tooltip: context.l10n.boardsMoveTooltip(columns[index - 1]),
                  icon: Icons.arrow_back,
                  onTap: () => _run(
                    () => widget.controller.moveCard(
                      cardId: card.cardId,
                      column: columns[index - 1],
                    ),
                  ),
                ),
              if (index != -1 && index < columns.length - 1)
                _QuietOp(
                  key: const ValueKey('board.op.next'),
                  tooltip: context.l10n.boardsMoveTooltip(columns[index + 1]),
                  icon: Icons.arrow_forward,
                  onTap: () => _run(
                    () => widget.controller.moveCard(
                      cardId: card.cardId,
                      column: columns[index + 1],
                    ),
                  ),
                ),
              if (card.status != BoardTaskStatus.completed.name)
                _QuietOp(
                  key: const ValueKey('board.op.done'),
                  tooltip: context.l10n.boardsSettleTooltip,
                  icon: Icons.check,
                  onTap: () => _run(
                    () => widget.controller.settle(
                      cardId: card.cardId,
                      status: BoardTaskStatus.completed,
                    ),
                  ),
                ),
              if (widget.canDelegate)
                _QuietOp(
                  key: const ValueKey('board.op.delegate'),
                  tooltip: context.l10n.boardsDelegateTooltip,
                  icon: _delegating ? Icons.hourglass_top : Icons.bolt,
                  onTap: () => unawaited(_delegate()),
                ),
              _QuietOp(
                key: const ValueKey('board.op.decompose'),
                tooltip: 'add a step',
                icon: Icons.account_tree_outlined,
                onTap: () => setState(() => _addingChild = !_addingChild),
              ),
            ],
          ),
          if (_addingChild)
            _ChildComposer(
              key: const ValueKey('board.child.input'),
              onSubmit: (final title) => _run(() {
                widget.controller.addChildren(
                  parentCardId: card.cardId,
                  childTitles: [title],
                );
                setState(() => _addingChild = false);
              }),
            ),
          if (delegatedTaskId case final taskId?)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.world == null
                    ? null
                    : () => unawaited(
                        showLaDialog<void>(
                          context: context,
                          builder: (final _) => TaskDetailDialog(
                            world: widget.world!,
                            taskId: taskId,
                          ),
                        ),
                      ),
                child: Text(
                  '→ $taskId',
                  key: ValueKey('board.card.${card.cardId}.taskId'),
                  style: LaTokens.mono(9, la.inkMuted),
                ),
              ),
            ),
          if (_refusal case final refusal?)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                refusal,
                key: ValueKey('board.card.${card.cardId}.refusal'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: LaTokens.mono(9, la.danger),
              ),
            ),
        ],
      ),
    );
  }
}

/// The inline child composer for decomposition — one keystroke away,
/// never a dialog.
final class _ChildComposer extends StatelessWidget {
  const _ChildComposer({required this.onSubmit, super.key});

  final void Function(String title) onSubmit;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: LaField(
      placeholder: context.l10n.boardsAddStepHint,
      style: context.laUi.micro,
      autofocus: true,
      onSubmitted: (final value) {
        final text = value.trim();
        if (text.isEmpty) return;
        onSubmit(text);
      },
    ),
  );
}

/// A quiet op button — one small icon, the agent keys it once.
final class _QuietOp extends StatelessWidget {
  const _QuietOp({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => LaButton.icon(
    icon: Icon(icon, size: 14),
    tooltip: tooltip,
    size: LaButtonSize.sm,
    onPressed: onTap,
  );
}

/// The lane composer: one field, submit adds to THIS lane.
final class _Composer extends StatefulWidget {
  const _Composer({
    required this.controller,
    required this.column,
    required this.onSubmit,
    super.key,
  });

  final PlanningBoardController controller;
  final String column;
  final VoidCallback onSubmit;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => LaField(
    controller: _controller,
    placeholder: context.l10n.boardsAddCardHint(widget.column),
    style: context.laUi.micro,
    onSubmitted: (final value) {
      final text = value.trim();
      if (text.isEmpty) return;
      widget.controller.addCard(title: text, column: widget.column);
      _controller.clear();
      widget.onSubmit();
    },
  );
}
