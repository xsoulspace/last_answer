/// WAVE 5 — the context panel's survivors. The panel AS A CONCEPT is
/// gone: its content became views in the ONE registry (people → the
/// `people` view, files → merged into the `filesystem` view, docs →
/// renamed `filesystem`, terminal/threads → quiet views), its private
/// tab enum died, and its frame became the dock ([ViewDock] renders
/// `pinned` from the ONE layout).
///
/// What remains here:
///
/// - [ContextColumnController] — the dock's session intent + the
///   conversation header's bridge. `visible` hides/shows the dock (the
///   conversation header's panel-right toggle drives it; the width
///   gate is NOT state — the shell recomputes it on every layout).
///   `focusActor` carries the header-identity tap ("show me this
///   actor"): the shell translates the intent into view operations
///   (focus the people pin when the dock will show it, open/focus the
///   people tab otherwise) and [PeopleFocus] state. The class keeps
///   its name and path: the conversation surface (which this module
///   must not break) reads it from the provider tree.
/// - [kContextColumnMinWindowWidth] — the width gate below which the
///   dock hides.
///
/// Session state only — no persistence (the layout document owns what
/// persists; see view_layout.dart).
library;

import 'package:flutter/foundation.dart';

/// Below this window width the dock auto-hides (LayoutBuilder gate in
/// the shell): this is the app's MINIMUM window width, so the dock is
/// effectively always laid out and the human's toggle is the only
/// hider — Discord keeps its member list on narrow windows.
const double kContextColumnMinWindowWidth = 980;

/// The dock's session intent state + the conversation header's bridge.
/// The shell installs [onFocusActorIntent]; a bare controller (hermetic
/// tests) just no-ops the focus intent while `visible` still works.
final class ContextColumnController extends ChangeNotifier {
  bool _visible = true;

  /// The callback the shell installs: carries a header-identity tap
  /// into view operations + people-focus state.
  void Function(String actorId)? onFocusActorIntent;

  /// Whether the dock is wanted; the shell still width-gates it (and a
  /// dock with nothing pinned does not render regardless).
  bool get visible => _visible;

  void setVisible({required final bool value}) {
    if (_visible == value) return;
    _visible = value;
    notifyListeners();
  }

  void toggle() => setVisible(value: !visible);

  /// The conversation header's intent: show me this actor. The shell's
  /// installed callback decides WHERE the people view appears (dock
  /// focus vs tab) — the header never learns about views.
  void focusActor(final String actorId) => onFocusActorIntent?.call(actorId);
}
