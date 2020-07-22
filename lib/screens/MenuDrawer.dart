import 'package:flutter/widgets.dart';
import 'package:lastanswer/components/CircularRevealComponent.dart';

class MenuDrawer extends StatefulWidget {
  final Widget child;
  const MenuDrawer({Key key, @required this.child}) : super(key: key);

  static MenuDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<MenuDrawerState>();

  @override
  MenuDrawerState createState() => MenuDrawerState();
}

class MenuDrawerState extends State<MenuDrawer>
    with SingleTickerProviderStateMixin {
  static const Duration toogleDuration = Duration(milliseconds: 400);
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: MenuDrawerState.toogleDuration);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void close() => _controller.reverse();
  void open() {
    _controller.forward();
  }

  void toogleDrawer() => _controller.isCompleted ? close() : open();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_controller.isCompleted) {
            close();
            return false;
          }
          return true;
        },
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            double _opacity = 1 - _controller.value;
            return Stack(
              children: [
                CircularRevealComponent(
                  controller: _controller,
                ),
                Opacity(
                  opacity: _opacity,
                  child: child,
                )
              ],
            );
          },
        ));
  }
}
