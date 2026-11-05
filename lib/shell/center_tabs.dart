/// The new-tab picker (Zed's New Tab, the browser model) and the named
/// unknown-surface state. PHASE 1: the global top bar and its tab widget
/// retired — every view owns its strip ([ViewTabStrip]); what remains
/// here is the picker a strip's `+`/⌘T opens IN THAT VIEW, and the
/// honest unknown state.
///
/// The picker is a quiet menu of destinations, not decorative cards:
/// each entry carries a small icon tile, the surface's name and a
/// one-line hint; tapping one replaces THIS tab in place
/// ([ShellLayout.pick]). Structure law: generous tap targets on a
/// hairline grid, no shadows, no elevation — this is navigation.
library;

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/shell_scope.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/surfaces.dart';

/// WAVE 4T — the new-tab picker: a quiet menu of destinations.
final class NewTabSurface extends StatelessWidget {
  const NewTabSurface({super.key});

  /// The one hint line per destination; unknown ids render name-only.
  static String? _hintFor(final BuildContext context, final String id) {
    final l10n = context.l10n;
    return switch (id) {
      kConversationsSurfaceId => l10n.newTabHintConversations,
      kBrowserSurfaceId => l10n.newTabHintBrowser,
      kInspectorSurfaceId => l10n.newTabHintInspector,
      kFilesystemSurfaceId => l10n.newTabHintFilesystem,
      kBoardsSurfaceId => l10n.newTabHintBoards,
      kPeopleSurfaceId => l10n.newTabHintPeople,
      _ => null,
    };
  }

  @override
  Widget build(final BuildContext context) {
    final scope = ViewScope.of(context);
    if (scope == null) {
      // Honest absence: the picker only makes sense inside the shell.
      return const Center(child: Text('new tab requires the app shell'));
    }
    final destinations = <SurfaceSpec>[
      for (final entry in scope.surfaces.entries)
        if (entry.key != kNewTabSurfaceId) entry.value,
    ];
    return KeyedSubtree(
      key: const ValueKey('newtab.page'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                scope.surfaces[kNewTabSurfaceId]?.title ??
                    context.l10n.newTabPageTitle,
                style: shellSectionLabel(context),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 4.6,
                children: [
                  for (final spec in destinations)
                    _NewTabEntry(
                      key: ValueKey('newtab.entry.${spec.id}'),
                      spec: spec,
                      hint: _hintFor(context, spec.id),
                      onOpen: () => scope.onChanged(scope.layout.pick(spec.id)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One picker destination: icon tile, name, one-line hint — a menu row
/// on the hairline grid, hover emphasis only.
final class _NewTabEntry extends StatefulWidget {
  const _NewTabEntry({
    required this.spec,
    required this.hint,
    required this.onOpen,
    super.key,
  });

  final SurfaceSpec spec;

  /// The one-line hint; null renders the name alone.
  final String? hint;
  final VoidCallback onOpen;

  @override
  State<_NewTabEntry> createState() => _NewTabEntryState();
}

final class _NewTabEntryState extends State<_NewTabEntry> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _hovering
        ? context.la.ink.withValues(alpha: 0.35)
        : context.shellHairline;
    return Semantics(
      button: true,
      label: widget.spec.title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onOpen,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(ShellTokens.radius),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: context.shellHairline),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    widget.spec.icon ?? Icons.crop_square,
                    size: 15,
                    color: context.shellMuted,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.spec.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.hint != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          widget.hint!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.shellMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Named empty-state for a surface id the registry does not know.
final class UnknownSurface extends StatelessWidget {
  const UnknownSurface({required this.surfaceId, super.key});

  final String surfaceId;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.unknownSurfaceTitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.shellMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(surfaceId, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
