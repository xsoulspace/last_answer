import 'dart:math';

import 'package:flutter/material.dart';

extension ColorExt on Color {
  MaterialColor generateMaterialColor() => MaterialColor(value, {
        50: tintColor(this, 0.5),
        100: tintColor(this, 0.4),
        200: tintColor(this, 0.3),
        300: tintColor(this, 0.2),
        400: tintColor(this, 0.1),
        500: tintColor(this, 0),
        600: tintColor(this, -0.1),
        700: tintColor(this, -0.2),
        800: tintColor(this, -0.3),
        900: tintColor(this, -0.4),
      });

  int tintValue(int value, double factor) =>
      max(0, min((value + ((255 - value) * factor)).round(), 255));

  Color tintColor(Color color, double factor) => Color.fromRGBO(
      tintValue(color.red, factor),
      tintValue(color.green, factor),
      tintValue(color.blue, factor),
      1);
}
