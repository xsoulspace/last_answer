part of '../widgets.dart';

/// A widget that listens for [ScrollNotification]s bubbling up the tree
/// and close the keyboard on user scroll.
class ScrollKeyboardCloser extends StatelessWidget {
  const ScrollKeyboardCloser({
    required this.child,
    super.key,
  });
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
