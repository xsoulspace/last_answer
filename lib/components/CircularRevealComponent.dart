import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lastanswer/components/CircularRevealPainter.dart';

class CircularRevealComponent extends StatefulWidget {
  final AnimationController controller;
  CircularRevealComponent({Key key, @required this.controller})
      : super(key: key);
  static CircularRevealComponentState of(BuildContext context) =>
      context.findAncestorStateOfType<CircularRevealComponentState>();

  @override
  CircularRevealComponentState createState() => CircularRevealComponentState();
}

class CircularRevealComponentState extends State<CircularRevealComponent>
    with SingleTickerProviderStateMixin {
  Animation _animation;
  Animation _opacityAnimation;
  double _fraction = 0.0;
  @override
  void initState() {
    super.initState();
    _animation = CurveTween(curve: Curves.easeInOut).animate(widget.controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });
    _opacityAnimation =
        CurveTween(curve: Curves.ease).animate(widget.controller);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void reveal() {
    print({widget.controller, 'reveal'});

    widget.controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        top: 30,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: CustomPaint(
            painter: CircularRevealPainter(_fraction, context),
          ),
        ));
  }
}
