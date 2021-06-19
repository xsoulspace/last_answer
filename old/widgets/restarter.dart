import 'package:flutter/material.dart';

class Restarter extends StatefulWidget {
  final Widget child;
  const Restarter({
    required this.child,
  });

  static void restartApp(BuildContext context) {
    context.findRootAncestorStateOfType<_RestarterState>()?.restartApp();
  }

  @override
  _RestarterState createState() => _RestarterState();
}

class _RestarterState extends State<Restarter> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
