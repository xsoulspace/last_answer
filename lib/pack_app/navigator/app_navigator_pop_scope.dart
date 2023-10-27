part of pack_app;

class AppNavigatorPopScope extends StatelessWidget {
  const AppNavigatorPopScope({
    required this.popper,
    required this.child,
    super.key,
  });
  final AppNavigatorPopper popper;
  final Widget child;
  @override
  Widget build(final BuildContext context) => WillPopScope(
        onWillPop: popper.handleWillPop,
        child: child,
      );
}
