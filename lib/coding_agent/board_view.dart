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

import 'package:core/core.dart';
import 'package:ecsly_boards/ecsly_boards.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/coding_agent/planning_board_controller.dart';

/// The planning board: one lane per column, ranked rows, inline add,
/// lane moves, decomposition. The controller is injectable (tests hand
/// a prepared one); absent one, the view owns a session-scoped
/// controller — local-first by law, the sync lane is the next program.
final class BoardView extends StatefulWidget {
  const BoardView({this.controller, super.key});

  final PlanningBoardController? controller;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  PlanningBoardController? _owned;
  PlanningBoardController get controller =>
      widget.controller ?? (_owned ??= PlanningBoardController());

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return KeyedSubtree(
      key: const ValueKey('board'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.boardsTitle, style: theme.textTheme.titleMedium),
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
  });

  final PlanningBoardController controller;
  final String column;
  final VoidCallback onMutate;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final cards = controller.cardsOf(column);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$column (${cards.length})',
          key: ValueKey('board.column.$column'),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        for (final card in cards)
          _CardRow(
            key: ValueKey('board.card.${card.key}'),
            controller: controller,
            card: card,
            onMutate: onMutate,
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
/// moves, settle, and the child composer — always visible, one tap
/// per op.
final class _CardRow extends StatefulWidget {
  const _CardRow({
    required this.controller,
    required this.card,
    required this.onMutate,
    super.key,
  });

  final PlanningBoardController controller;
  final BoardCardView card;
  final VoidCallback onMutate;

  @override
  State<_CardRow> createState() => _CardRowState();
}

class _CardRowState extends State<_CardRow> {
  bool _addingChild = false;

  void _run(final void Function() action) {
    action();
    widget.onMutate();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;
    final columns = widget.controller.columns;
    final index = columns.indexOf(card.column ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('· ', style: theme.textTheme.labelSmall),
              Expanded(
                child: Text(card.title, style: theme.textTheme.bodyMedium),
              ),
              if (card.status == BoardTaskStatus.completed)
                Icon(Icons.check, size: 14, color: theme.colorScheme.primary),
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
                      key: card.key,
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
                      key: card.key,
                      column: columns[index + 1],
                    ),
                  ),
                ),
              if (card.status != BoardTaskStatus.completed)
                _QuietOp(
                  key: const ValueKey('board.op.done'),
                  tooltip: context.l10n.boardsSettleTooltip,
                  icon: Icons.check,
                  onTap: () => _run(
                    () => widget.controller.settle(
                      key: card.key,
                      status: BoardTaskStatus.completed,
                    ),
                  ),
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
                  parentKey: card.key,
                  childTitles: [title],
                );
                setState(() => _addingChild = false);
              }),
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
    child: TextField(
      decoration: InputDecoration(
        hintText: context.l10n.boardsAddStepHint,
        isDense: true,
      ),
      style: Theme.of(context).textTheme.labelSmall,
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
  Widget build(final BuildContext context) => IconButton(
    tooltip: tooltip,
    icon: Icon(icon, size: 14),
    constraints: const BoxConstraints(minWidth: 28, minHeight: 24),
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
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
  Widget build(final BuildContext context) => TextField(
    controller: _controller,
    decoration: InputDecoration(
      hintText: context.l10n.boardsAddCardHint(widget.column),
      isDense: true,
    ),
    style: Theme.of(context).textTheme.labelSmall,
    onSubmitted: (final value) {
      final text = value.trim();
      if (text.isEmpty) return;
      widget.controller.addCard(title: text, column: widget.column);
      _controller.clear();
      widget.onSubmit();
    },
  );
}
