/// The pane's surface resolution and the named unknown-surface state.
/// DESIGN.md v2 retired the picker-as-a-tab ([NewTabSurface] is gone —
/// the picker is the anchored menu in new_tab_menu.dart); what remains
/// here is the ONE resolution law every pane content slot shares:
/// registry id → conversation id (`dm:`/`channel:`) → document id
/// (`doc:`) → browser instance (`browser:<n>`) → honest unknown.
library;

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/surfaces.dart';

/// Resolves [surfaceId] to its spec: the static registry first, then
/// the prefix-generic kinds (conversation slot, document, browser
/// instance). Null = the registry does not know the id.
SurfaceSpec? resolveSurfaceSpec(
  final String surfaceId,
  final SurfaceRegistry surfaces,
) =>
    surfaces[surfaceId] ??
    conversationSurfaceSpec(surfaceId, surfaces) ??
    documentSurfaceSpec(surfaceId) ??
    browserSurfaceSpec(surfaceId, surfaces);

/// One pane slot's content: the resolved surface keyed
/// `pane.leaf.<surfaceId>` (tab ids are unique across groups, so the
/// key stays a pure function of the id), or the named unknown state.
Widget buildSurfaceFor(
  final BuildContext context,
  final String surfaceId,
  final SurfaceRegistry surfaces,
) {
  final spec = resolveSurfaceSpec(surfaceId, surfaces);
  return KeyedSubtree(
    key: ValueKey('pane.leaf.$surfaceId'),
    child: spec == null
        ? UnknownSurface(surfaceId: surfaceId)
        : Builder(builder: spec.builder),
  );
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
