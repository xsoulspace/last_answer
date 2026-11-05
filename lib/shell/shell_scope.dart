/// Phase 1 — the shell's inherited scope: the ONE layout document
/// ([ShellLayout]), the ONE surface registry, and the shell's intents,
/// handed to everything below the scaffold (rail, strips, view bodies).
/// Replaces the WAVE 5 scope of the same name (global bar + dock).
library;

import 'package:flutter/widgets.dart';

import 'package:lastanswer/shell/shell_layout.dart';
import 'package:lastanswer/shell/surfaces.dart';

/// The shell's composition context. Null outside the shell (surfaces
/// render their honest empty states instead of guessing).
final class ViewScope extends InheritedWidget {
  const ViewScope({
    required this.layout,
    required this.surfaces,
    required this.onChanged,
    this.onFocusActor,
    this.titleFor,
    this.leadingFor,
    required super.child,
    super.key,
  });

  /// The live layout: hosted view + every view's tab strip.
  final ShellLayout layout;

  /// The ONE surface registry (specs, titles, icons), newtab included.
  final SurfaceRegistry surfaces;

  /// Commits a layout change (state + persistence).
  final ValueChanged<ShellLayout> onChanged;

  /// The conversation header's "show me this actor" intent; the shell
  /// decides where the people view appears (a tab, since the dock
  /// retired). Null in hermetic shells.
  final ValueChanged<String>? onFocusActor;

  /// Human title for ids the registry does not name (conversation ids);
  /// null falls back to the registry title, then the raw id.
  final String? Function(String surfaceId)? titleFor;

  /// Identity mark for ids the registry has no leading for (the actor's
  /// avatar, the channel's `#` disc); null falls back to the icon.
  final Widget? Function(String surfaceId)? leadingFor;

  static ViewScope? of(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ViewScope>();

  @override
  bool updateShouldNotify(final ViewScope old) =>
      layout != old.layout ||
      surfaces != old.surfaces ||
      onChanged != old.onChanged ||
      onFocusActor != old.onFocusActor ||
      titleFor != old.titleFor ||
      leadingFor != old.leadingFor;
}
