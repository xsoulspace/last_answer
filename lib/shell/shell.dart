/// ADR 0024 — the app shell: the flat center tab strip workspace core.
///
/// The center is one ordered strip of surfaces via [CenterTabs]; every
/// surface kind is described by a [SurfaceSpec]. The pane tree
/// (splits/stacks/tree editing) retired in favor of the strip.
library;

export 'actor_rail.dart';
export 'app_shell.dart';
export 'center_tabs.dart';
export 'context_column.dart';
export 'surfaces.dart';
