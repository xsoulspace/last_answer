part of widgets;

/// A widget that listens for [ScrollNotification]s bubbling up the tree
/// and close the keyboard on user scroll.
class ScrollKeyboardCloser extends StatelessWidget {
  const ScrollKeyboardCloser({
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return NotificationListener<ScrollNotification>(
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
}
