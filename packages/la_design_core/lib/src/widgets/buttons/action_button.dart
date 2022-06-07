import 'package:flutter/material.dart';
import 'package:tap_builder/tap_builder.dart';

import '../../theme/theme.dart';
import 'button.dart';

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    final Key? key,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    return TapBuilder(
      onTap: onTap,
      builder: (final context, final state, final hasFocus) {
        switch (state) {
          case TapState.hover:
            return AppActionButtonLayout.hovered(
              icon: icon,
            );
          case TapState.pressed:
            return AppActionButtonLayout.pressed(
              icon: icon,
            );
          default:
            return AppActionButtonLayout.inactive(
              icon: icon,
            );
        }
      },
    );
  }
}

class AppActionButtonLayout extends StatelessWidget {
  const AppActionButtonLayout.inactive({
    final Key? key,
    required this.icon,
  })  : _state = AppButtonState.inactive,
        super(key: key);

  const AppActionButtonLayout.hovered({
    final Key? key,
    required this.icon,
  })  : _state = AppButtonState.hovered,
        super(key: key);

  const AppActionButtonLayout.pressed({
    final Key? key,
    required this.icon,
  })  : _state = AppButtonState.pressed,
        super(key: key);

  final String icon;
  final AppButtonState _state;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);
    switch (_state) {
      case AppButtonState.hovered:
        return AppButtonLayout.hovered(
          icon: icon,
          hoveredBackgroundColor: theme.colors.accentOpposite.withOpacity(0.15),
        );
      case AppButtonState.pressed:
        return AppButtonLayout.pressed(
          icon: icon,
          pressedBackgroundColor: theme.colors.accentOpposite.withOpacity(0.20),
        );
      case AppButtonState.inactive:
        return AppButtonLayout.inactive(
          icon: icon,
          inactiveBackgroundColor: theme.colors.accentOpposite.withOpacity(0),
        );
    }
  }
}
