/// Legacy-kit port of `_library/widgets/core/right_scrollbar.dart`.
/// The original wrapped a Material `Scrollbar` with a hand-rolled
/// `ScrollbarTheme`; the kit owns scrollbar paint now, so this is a thin
/// [LaScrollArea]. Public API identical to the original ([controller] is
/// retained for call-site compatibility and rides the inner scrollable).
library;

import 'package:flutter/widgets.dart';
import 'package:la_ui/la_ui.dart';

class RightScrollbar extends StatelessWidget {
  const RightScrollbar({
    required this.child,
    required this.controller,
    super.key,
  });
  final Widget child;

  /// Retained for API compatibility; the scrollable inside [child] carries
  /// it. [LaScrollArea] is a paint-behavior wrapper and needs no controller.
  final ScrollController controller;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: LaScrollArea(child: child),
  );
}
