import 'package:flutter/material.dart';

import '../brand/color_schemes.dart';

class AppColorSchemes {
  AppColorSchemes._({
    required this.dark,
    required this.light,
  });

  factory AppColorSchemes.brand() => AppColorSchemes._(
        dark: BrandColorSchemes.dark,
        light: BrandColorSchemes.light,
      );

  /// Use this factory to create a new AppColorSchemes based on
  /// Material You token generation principle.
  // ignore: avoid_unused_constructor_parameters
  factory AppColorSchemes.fromAccentColor(final Color color) =>
      // TODO(arenukvern): add accent color scheme generation
      throw UnimplementedError();

  final ColorScheme light;
  final ColorScheme dark;
}
