import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lastanswer/widgets/CircularRevealPainter.dart';

class CircularProgress extends StatefulWidget {
  final AnimationController controller;

  CircularProgress({required Key key, required this.controller})
      : super(key: key);

  static _CircularProgressState? of(BuildContext context) =>
      context.findAncestorStateOfType<_CircularProgressState>();

  @override
  _CircularProgressState createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress>
    with SingleTickerProviderStateMixin {
  late Animation _animation;
  late Animation<double> _opacityAnimation;

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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void reveal() {
    // print({widget.controller, 'reveal'});

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
