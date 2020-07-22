import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lastanswer/components/CircularRevealPainter.dart';
import 'package:lastanswer/screens/MenuDrawer.dart';

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
  double _fraction = 0.0;
  @override
  void initState() {
    super.initState();
    _animation = Tween(begin: 0.0, end: 1.0).animate(widget.controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });
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
    return Stack(
      children: [
        Positioned(
          left: 25,
          top: 25,
          child: CustomPaint(
            painter: CircularRevealPainter(_fraction, context),
            // child: Builder(
            //   builder: (context) => IconButton(
            //       onPressed: () {
            //         MenuDrawer.of(context).close();
            //       },
            //       icon: Icon(Icons.playlist_add_check)),
            // ),
          ),
        )
      ],
    );

    //         Material(
    // color: Colors.blueAccent,
    // child: SafeArea(
    //     child: Theme(
    //         data: ThemeData(brightness: Brightness.dark),
    //         child: ));
  }
}
