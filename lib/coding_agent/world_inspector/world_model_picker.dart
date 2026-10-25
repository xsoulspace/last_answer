/// The model picker and the tool menu — the seat's WORK affordances on the
/// same grid as the conversation (DESIGN §2/§3).
///
/// No cards, no chips, no segmented controls, no icons: a hairline rule and
/// typography per entry, a fixed role gutter, small-caps labels with
/// tracking, and model ids in tabular monospace. The palette is DATA the
/// world declared — an empty palette says so, and an entry the world has
/// not bound is shown as unbound rather than hidden.
library;

import 'package:flutter/material.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_work_verbs.dart';

// DESIGN §3 reference constants (the agent-doc surface's own grid).
const _gutterWidth = 52.0;
const _hairline = 0.6;

TextStyle _label(final ThemeData theme) => theme.textTheme.labelSmall!.copyWith(
  fontSize: 9.5,
  letterSpacing: 1.2,
  color: theme.colorScheme.onSurfaceVariant,
  fontFeatures: const [FontFeature.tabularFigures()],
);

TextStyle _mono(final ThemeData theme, {final Color? color}) =>
    theme.textTheme.bodySmall!.copyWith(
      fontFamily: 'Menlo',
      fontFamilyFallback: const ['monospace'],
      fontSize: 11,
      height: 1.45,
      color: color ?? theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// The gutter vocabulary for palette entries: the ROLE the entry plays,
/// never an icon.
String worldPaletteKindLabel(final String kind) => switch (kind) {
  'generative' => 'GEN',
  'decision' => 'DEC',
  'mechanical' => 'MECH',
  'humanSeam' => 'HUMAN',
  'externalAgent' => 'EXT',
  _ => kind.isEmpty ? '···' : kind.toUpperCase(),
};

/// The purposes a human may delegate with. `coding` never carries a model
/// (the world bounces `decision_purpose_required`); `decision` may.
const worldDelegatePurposes = ['coding', 'decision'];

/// The palette picker: one hairline row per entry the world declared.
///
/// [purpose] is the delegate purpose the human chose; [selectedId] is the
/// palette entry id (never a provider model string).
class WorldModelPicker extends StatelessWidget {
  const WorldModelPicker({
    required this.palette,
    required this.absence,
    required this.purpose,
    required this.selectedId,
    required this.onPurpose,
    required this.onSelect,
    required this.onBind,
    this.busy = false,
    super.key,
  });

  final WorldModelPalette palette;

  /// Why the palette could not be read; null when it was read.
  final String? absence;
  final String purpose;
  final String? selectedId;
  final ValueChanged<String> onPurpose;
  final ValueChanged<String> onSelect;
  final VoidCallback onBind;
  final bool busy;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final selected = palette.entryById(selectedId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GridLine(
          role: 'MODEL',
          child: Row(
            children: [
              for (final option in worldDelegatePurposes) ...[
                _PurposeToggle(
                  purpose: option,
                  active: option == purpose,
                  onTap: busy ? null : () => onPurpose(option),
                ),
                const SizedBox(width: 14),
              ],
              const Spacer(),
              _TextAction(
                key: const Key('coding_agent.world.bind'),
                label: 'BIND',
                onTap: busy || selected == null || !selected.bound
                    ? null
                    : onBind,
              ),
            ],
          ),
        ),
        if (absence != null)
          _GridLine(
            role: 'SYS',
            child: Text(
              'model palette not available · $absence',
              key: const Key('coding_agent.world.model.absence'),
              style: _mono(theme),
            ),
          )
        else if (palette.isEmpty)
          _GridLine(
            role: 'SYS',
            child: Text(
              'no model palette declared for this world',
              key: const Key('coding_agent.world.model.empty'),
              style: _mono(theme),
            ),
          )
        else
          for (final entry in palette.entries)
            _PaletteRow(
              entry: entry,
              selected: entry.id == selectedId,
              declaredForPurpose: palette.roles[purpose] == entry.id,
              onTap: busy ? null : () => onSelect(entry.id),
            ),
      ],
    );
  }
}

/// One palette entry: role gutter, model id in mono, and the entry's own
/// state (bound / unbound, primary, the role the world declares it for).
class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.entry,
    required this.selected,
    required this.declaredForPurpose,
    required this.onTap,
  });

  final WorldPaletteEntry entry;
  final bool selected;
  final bool declaredForPurpose;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final annotations = [
      entry.id,
      if (entry.provider.isNotEmpty) entry.provider,
      if (entry.primary) 'PRIMARY',
      if (declaredForPurpose) 'ROLE',
      if (!entry.bound) 'UNBOUND',
    ].join(' · ');
    return InkWell(
      key: Key('coding_agent.world.model.entry.${entry.id}'),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.dividerColor,
              width: selected ? 1.2 : _hairline,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _gutterWidth,
              child: Text(
                worldPaletteKindLabel(entry.kind),
                style: _label(theme).copyWith(
                  color: selected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.model.isEmpty ? entry.id : entry.model,
                    style: _mono(
                      theme,
                      color: selected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(annotations, style: _mono(theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tool menu: what the seat may invoke through `tool_action`, with the
/// revision the call must echo.
class WorldToolMenuList extends StatelessWidget {
  const WorldToolMenuList({
    required this.tools,
    required this.revision,
    required this.absence,
    required this.onRun,
    this.busy = false,
    super.key,
  });

  final List<WorldToolEntry> tools;
  final String? revision;
  final String? absence;
  final ValueChanged<String> onRun;
  final bool busy;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GridLine(
          role: 'TOOLS',
          child: Text(
            revision == null ? 'no tool menu' : 'rev $revision',
            key: const Key('coding_agent.world.tools.revision'),
            style: _mono(theme),
          ),
        ),
        if (absence != null)
          _GridLine(
            role: 'SYS',
            child: Text(
              'tool menu not available · $absence',
              key: const Key('coding_agent.world.tools.absence'),
              style: _mono(theme),
            ),
          )
        else
          for (final tool in tools)
            InkWell(
              key: Key('coding_agent.world.tool.${tool.name}'),
              onTap: busy ? null : () => onRun(tool.name),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: _gutterWidth,
                      child: Text('TOOL', style: _label(theme)),
                    ),
                    Expanded(
                      child: Text(
                        tool.summary.isEmpty
                            ? tool.name
                            : '${tool.name}  ${tool.summary}',
                        style: _mono(theme),
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

/// One grid line: role gutter + content. The layout primitive here, the
/// same one the conversation uses.
class _GridLine extends StatelessWidget {
  const _GridLine({required this.role, required this.child});

  final String role;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _gutterWidth,
            child: Text(
              role,
              style: _label(theme),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// A small-caps text toggle — no segmented control, no chip.
class _PurposeToggle extends StatelessWidget {
  const _PurposeToggle({
    required this.purpose,
    required this.active,
    required this.onTap,
  });

  final String purpose;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      key: Key('coding_agent.world.purpose.$purpose'),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? theme.colorScheme.onSurface : Colors.transparent,
              width: 1.2,
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 1),
        child: Text(
          purpose.toUpperCase(),
          style: _label(theme).copyWith(
            color: active
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// A small-caps text action (the reference surface's `[edit]` vocabulary,
/// without the brackets: the label IS the affordance).
class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: _label(theme).copyWith(
          color: onTap == null
              ? theme.disabledColor
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
