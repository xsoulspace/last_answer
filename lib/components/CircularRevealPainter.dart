import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircularRevealPainter extends CustomPainter {
  double _fraction;
  BuildContext _context;
  CircularRevealPainter(this._fraction, this._context);
  Size get _screenSize {
    return MediaQuery.of(_context).size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintDown = Paint()
      ..style = PaintingStyle.fill
      ..color = Theme.of(_context).scaffoldBackgroundColor;
    Rect rectDown = Rect.fromLTWH(
        0, -45, _screenSize.width, (_screenSize.height + 45) * _fraction);
    canvas.drawRect(rectDown, paintDown);
  }

  @override
  bool shouldRepaint(CircularRevealPainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}
