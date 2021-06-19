import 'package:flutter/material.dart';
import 'package:lastanswer/utils/color_generator.dart';

import 'palette.dart';

final primarySwatch = generateMaterialColor(Palette.primary);

final lightTheme = ThemeData(
  splashColor: primarySwatch.withOpacity(0.3),
  highlightColor: primarySwatch.shade300.withOpacity(0.08),
  hoverColor: primarySwatch.shade200.withOpacity(0.08),
  focusColor: primarySwatch.shade200.withOpacity(0.08),
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  ),
  primarySwatch: primarySwatch,
  fontFamily: 'IBM Plex Sans',
  brightness: Brightness.light,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: primarySwatch,
  toggleableActiveColor: primarySwatch,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: primarySwatch,
    primaryColorDark: primarySwatch,
    accentColor: primarySwatch,
    brightness: Brightness.dark,
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: primarySwatch,
  ),
  fontFamily: 'IBM Plex Sans',
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  ),
);
