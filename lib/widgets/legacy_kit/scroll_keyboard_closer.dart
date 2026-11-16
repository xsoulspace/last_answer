/// Legacy-kit port of `_library/widgets/core/scroll_keyboard_closer.dart`.
/// Widgets-layer only; public API identical to the original.
library;

import 'package:core/core.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';

/// A widget that listens for [ScrollNotification]s bubbling up the tree
/// and close the keyboard on user scroll.
class ScrollKeyboardCloser extends StatelessWidget {
  const ScrollKeyboardCloser({required this.child, super.key});
  final Widget child;

  @override
  Widget build(final BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (final scrollNotification) {
          if (scrollNotification is UserScrollNotification &&
              scrollNotification.direction == ScrollDirection.forward) {
            closeKeyboard(context: context);
          }

          return false;
        },
        child: child,
      );
}
