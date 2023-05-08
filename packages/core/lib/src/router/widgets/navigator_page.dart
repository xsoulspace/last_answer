part of '../router.dart';

class NavigatorPage extends MaterialPage<void> {
  NavigatorPage({
    required final Widget child,
    required final ValueKey key,
    final RouterPopper popper = const RouterPopper(),
    final bool fullscreenDialog = false,
  }) : super(
          fullscreenDialog: fullscreenDialog,
          key: key,
          child: RouterPopScope(
            popper: popper,
            child: child,
          ),
        );
}
