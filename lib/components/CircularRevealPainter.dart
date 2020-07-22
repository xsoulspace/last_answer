import 'dart:math';

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
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Theme.of(_context).scaffoldBackgroundColor;
    final exponent = 2;
    final double finalRadius = sqrt(pow(_screenSize.width / exponent, 2.3) +
        pow(_screenSize.height / exponent, 2.3));
    final double startRadius = 1.0;
    double currentRadius =
        startRadius + (finalRadius - startRadius) * _fraction;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), currentRadius, paint);
  }

  @override
  bool shouldRepaint(CircularRevealPainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}
