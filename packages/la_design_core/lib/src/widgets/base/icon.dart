import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';

enum AppIconSize {
  small,
  regular,
  big,
}

extension AppIconSizeExtension on AppIconSizesData {
  double resolve(final AppIconSize size) {
    switch (size) {
      case AppIconSize.small:
        return small;
      case AppIconSize.regular:
        return regular;
      case AppIconSize.big:
        return big;
    }
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.data, {
    final Key? key,
    this.color,
    this.size = AppIconSize.regular,
  }) : super(key: key);

  const AppIcon.small(
    this.data, {
    final Key? key,
    this.color,
  })  : size = AppIconSize.small,
        super(key: key);

  const AppIcon.regular(
    this.data, {
    final Key? key,
    this.color,
  })  : size = AppIconSize.regular,
        super(key: key);

  const AppIcon.big(
    this.data, {
    final Key? key,
    this.color,
  })  : size = AppIconSize.big,
        super(key: key);

  final String data;
  final Color? color;
  final AppIconSize size;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);
    final color = this.color ?? theme.colors.foreground;
    return Text(
      data,
      style: TextStyle(
        fontFamily: theme.icons.fontFamily,
        package: theme.icons.fontPackage,
        color: color,
        fontSize: theme.icons.sizes.resolve(size),
        decoration: TextDecoration.none,
      ),
    );
  }
}

class AppAnimatedIcon extends StatelessWidget {
  const AppAnimatedIcon(
    this.data, {
    final Key? key,
    this.color,
    this.size = AppIconSize.small,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  final String data;
  final Color? color;
  final AppIconSize size;
  final Duration duration;

  bool get isAnimated => duration.inMilliseconds > 0;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);
    final color = this.color ?? theme.colors.foreground;
    if (!isAnimated) {
      return AppIcon(
        data,
        key: key,
        color: color,
        size: size,
      );
    }
    return AnimatedDefaultTextStyle(
      style: TextStyle(
        fontFamily: theme.icons.fontFamily,
        package: theme.icons.fontPackage,
        color: color,
        fontSize: theme.icons.sizes.resolve(size),
        decoration: TextDecoration.none,
      ),
      duration: duration,
      child: Text(
        data,
      ),
    );
  }
}
