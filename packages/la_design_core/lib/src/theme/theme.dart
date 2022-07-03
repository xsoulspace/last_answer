import 'package:flutter/material.dart';

import 'data/data.dart';

export 'app/colors.dart';
export 'data/data.dart';
export 'data/icons.dart';
export 'data/radius.dart';
export 'data/shadows.dart';
export 'data/spacing.dart';

class AppTheme extends InheritedWidget {
  const AppTheme({
    final Key? key,
    required this.data,
    required final Widget child,
  }) : super(
          key: key,
          child: child,
        );

  final AppThemeData data;

  static AppThemeData of(final BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    return widget!.data;
  }

  @override
  bool updateShouldNotify(covariant final AppTheme oldWidget) {
    return data != oldWidget.data;
  }
}
