/// Phase 2 — the ⌘K command palette (docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md §2.2.6): ONE floating
/// layer over the unified search — views, people, channels and actions
/// in a single fuzzy list, keyboard-first (arrows + enter + esc). The
/// rail's search field is its trigger; the field no longer owns its own
/// inline filter grammar.
///
/// A floating layer by the shell's ONE depth declaration (DESIGN §3):
/// hairline + the shared offset shadow, never an elevation ladder.
/// Every row is key-contracted (`palette.entry.<id>`) for the agent
/// snapshot (redesign §2.3).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';

/// One palette row: a destination or an action.
final class CommandEntry {
  const CommandEntry({
    required this.id,
    required this.label,
    required this.group,
    required this.run,
    this.icon,
  });

  final String id;
  final String label;

  /// `views` | `people` | `channels` | `actions` — the render order.
  final String group;
  final IconData? icon;
  final VoidCallback run;
}

/// The palette overlay: search field + grouped results, keyboard-first.
final class CommandPalette extends StatefulWidget {
  const CommandPalette({
    required this.entries,
    required this.onClose,
    super.key,
  });

  final List<CommandEntry> entries;
  final VoidCallback onClose;

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

final class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _query = TextEditingController();
  int _selected = 0;

  static const _groupOrder = ['views', 'people', 'channels', 'actions'];

  List<CommandEntry> get _filtered {
    final q = _query.text.trim().toLowerCase();
    final matched = [
      for (final entry in widget.entries)
        if (q.isEmpty || entry.label.toLowerCase().contains(q)) entry,
    ];
    matched.sort((a, b) {
      final ga = _groupOrder.indexOf(a.group);
      final gb = _groupOrder.indexOf(b.group);
      if (ga != gb) return ga.compareTo(gb);
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
    return matched;
  }

  void _move(final int delta) {
    final count = _filtered.length;
    if (count == 0) return;
    setState(() => _selected = (_selected + delta) % count);
  }

  void _runSelected() {
    final filtered = _filtered;
    if (filtered.isEmpty) return;
    final entry = filtered[_selected.clamp(0, filtered.length - 1)];
    widget.onClose();
    entry.run();
  }

  /// The palette owns the keyboard while open: a HARDWARE-level handler
  /// (the field's internal text-editing shortcuts consume escape and
  /// the arrows before any focus bubble could reach an ancestor).
  /// Enter rides here too: a synthesized key (fmtk press_key, a raw
  /// hardware event without the platform IME) never reaches the field's
  /// onSubmitted, which fires on the IME's performAction — the palette
  /// must answer both paths.
  bool _handleKey(final KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.onClose();
        return true;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        _runSelected();
        return true;
      case LogicalKeyboardKey.arrowDown:
        _move(1);
        return true;
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
        return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    final filtered = _filtered;
    if (_selected >= filtered.length) _selected = 0;
    // Group headers render at each group boundary, in the fixed order.
    final rows = <Widget>[];
    String? lastGroup;
    for (var i = 0; i < filtered.length; i++) {
      final entry = filtered[i];
      if (entry.group != lastGroup) {
        lastGroup = entry.group;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Text(
              _groupTitle(context, entry.group),
              style: shellSectionLabel(context),
            ),
          ),
        );
      }
      rows.add(
        _PaletteRow(
          key: ValueKey('palette.entry.${entry.id}'),
          entry: entry,
          selected: i == _selected,
          onTap: () {
            setState(() => _selected = i);
            _runSelected();
          },
        ),
      );
    }
    return GestureDetector(
      // A click on the veil closes; the layer itself stops the tap.
      behavior: HitTestBehavior.opaque,
      onTap: widget.onClose,
      child: Container(
        color: la.ink.withValues(alpha: 0.18),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 72),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Material(
                color: la.surfaceOverlay,
                borderRadius: BorderRadius.circular(LaTokens.radiusFloating),
                child: Container(
                  key: const ValueKey('shell.commandPalette'),
                  width: 560,
                  constraints: const BoxConstraints(maxHeight: 420),
                  decoration: BoxDecoration(
                    border: Border.all(color: la.rule),
                    borderRadius: BorderRadius.circular(
                      LaTokens.radiusFloating,
                    ),
                    // The ONE floating-layer depth declaration.
                    boxShadow: shellFloatingShadow(context),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        // The agent contract: the snapshot's identifier
                        // is the palette's address (widget keys are not
                        // semantics identifiers).
                        identifier: 'palette.query',
                        child: TextField(
                          key: const ValueKey('palette.query'),
                          controller: _query,
                          autofocus: true,
                          onChanged: (_) => setState(() => _selected = 0),
                          onSubmitted: (_) => _runSelected(),
                          style: LaTokens.body.copyWith(color: la.ink),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: l10n.commandPaletteHint,
                            prefixIcon: const Icon(Icons.search, size: 16),
                          ),
                        ),
                      ),
                      Container(height: 1, color: la.rule),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          children: rows,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _groupTitle(final BuildContext context, final String group) =>
      switch (group) {
        'views' => context.l10n.commandPaletteViews,
        'people' => context.l10n.commandPalettePeople,
        'channels' => context.l10n.commandPaletteChannels,
        _ => context.l10n.commandPaletteActions,
      };
}

/// One palette row: identity mark + label, the selected row on the
/// shell's selected tint.
final class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.entry,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final CommandEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: 'palette.entry.${entry.id}',
    hint: entry.label,
    child: ShellRow(
      height: 34,
      selected: selected,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: onTap,
      child: Row(
        children: [
          if (entry.icon case final icon?)
            Icon(icon, size: 14, color: context.shellMuted),
          if (entry.icon != null) const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    ),
  );
}
