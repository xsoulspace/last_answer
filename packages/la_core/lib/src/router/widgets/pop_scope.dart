part of '../router.dart';

@immutable
class RouterPopper {
  const RouterPopper();
  Future<bool> handleWillPop() async => true;
  bool onPopPage(
    final Route<dynamic> route,
    final dynamic result,
  ) =>
      route.didPop(result);
}

class RouterPopScope extends StatelessWidget {
  const RouterPopScope({
    required final this.child,
    final this.popper = const RouterPopper(),
    final Key? key,
  }) : super(key: key);
  final RouterPopper popper;
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    return WillPopScope(
      onWillPop: popper.handleWillPop,
      child: child,
    );
  }
}
