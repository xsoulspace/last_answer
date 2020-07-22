import 'package:flutter/widgets.dart';
import 'package:lastanswer/components/CircularRevealComponent.dart';
import 'package:lastanswer/screens/MenuScreen.dart';

class MenuDrawer extends StatefulWidget {
  final Widget child;
  const MenuDrawer({Key key, @required this.child}) : super(key: key);

  static MenuDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<MenuDrawerState>();

  @override
  MenuDrawerState createState() => MenuDrawerState();
}

class MenuDrawerState extends State<MenuDrawer> with TickerProviderStateMixin {
  static const Duration toogleDuration = Duration(milliseconds: 300);
  AnimationController _controller;
  AnimationController _opacityController;
  Animation<double> _opacity;
  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: MenuDrawerState.toogleDuration);

    _opacityController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _opacity = Tween(begin: 0.0, end: 1.0).animate(_opacityController);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  void close() {
    setState(() {
      _isMenuScreenActive = false;
    });
    _opacityController.reverse();
    _controller.reverse();
  }

  bool _isMenuScreenActive = false;
  void open() {
    setState(() {
      _isMenuScreenActive = true;
    });
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _opacityController.forward();
      }
    });
  }

  void toggleDrawer() => _controller.isCompleted ? close() : open();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(size);

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
            return Stack(
              children: [
                child,
                CircularRevealComponent(
                  controller: _controller,
                ),
                _isMenuScreenActive
                    ? ModalBarrier(
                        dismissible: false,
                      )
                    : Container(),
                _isMenuScreenActive
                    ? Positioned.fill(
                        // child: _controller.isCompleted
                        //     ?
                        //     : Container(),
                        child: FadeTransition(
                            opacity: _opacity, child: MenuScreen()))
                    : Container()
              ],
            );
          },
        ));
  }
}
