/// Phase 1 — the shell's inherited scope: the ONE layout document
/// ([ShellLayout]), the ONE surface registry, and the shell's intents,
/// handed to everything below the scaffold (rail, strips, view bodies).
/// Replaces the WAVE 5 scope of the same name (global bar + dock).
library;

import 'package:flutter/widgets.dart';

import 'package:lastanswer/ui_shell/shell_layout.dart';
import 'package:lastanswer/ui_shell/surfaces.dart';

/// The shell's composition context. Null outside the shell (surfaces
/// render their honest empty states instead of guessing).
final class ViewScope extends InheritedWidget {
  const ViewScope({
    required this.layout,
    required this.surfaces,
    required this.onChanged,
    required super.child,
    this.onFocusActor,
    this.onOpenThread,
    this.onOpenConversation,
    this.titleFor,
    this.leadingFor,
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

  /// The "open this thread as a room" intent (work-thread cards, the
  /// landing inbox's rows): the shell routes it through the ONE router
  /// (select + tab), because a bare service select no longer moves any
  /// pane — panes render their OWN thread (the pane-instance law).
  /// Null outside the shell: hosts fall back to selectThread.
  final ValueChanged<String>? onOpenThread;

  /// The "open this conversation surface" intent (`dm:<actorId>` /
  /// `channel:<channelId>` / `room:<threadId>` — the channel view's
  /// threads browser rows and the beat text's linkified references):
  /// the shell's own [onOpenThread] vocabulary at full surface-id
  /// breadth — the ONE `_onSelectTab` router the registry and the
  /// actor-info surface already ride. Null outside the shell: hosts
  /// fall back to the service verbs.
  final ValueChanged<String>? onOpenConversation;

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
      onOpenThread != old.onOpenThread ||
      onOpenConversation != old.onOpenConversation ||
      titleFor != old.titleFor ||
      leadingFor != old.leadingFor;
}
