import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme/theme.dart';

class TransparentPage<T> extends Page<T> {
  const TransparentPage({
    required this.child,
    final LocalKey? key,
    final String? name,
    final Object? arguments,
    final String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  @override
  Route<T> createRoute(final BuildContext context) {
    final theme = AppTheme.of(context);
    return PageRouteBuilder(
      transitionDuration: theme.durations.regular,
      opaque: false,
      settings: this,
      barrierColor: theme.colors.foreground.withOpacity(0.5),
      pageBuilder: (
        final context,
        final animation,
        final secondaryAnimation,
      ) {
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (final context, final child) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20 * animation.value,
              sigmaY: 20 * animation.value,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
