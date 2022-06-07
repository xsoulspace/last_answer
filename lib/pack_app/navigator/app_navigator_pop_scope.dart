import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/pack_app/navigator/app_navigator_popper.dart';

class AppNavigatorPopScope extends StatelessWidget {
  const AppNavigatorPopScope({
    required final this.popper,
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final AppNavigatorPopper popper;
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    return WillPopScope(
      onWillPop: popper.handleWillPop,
      child: child,
    );
  }
}
