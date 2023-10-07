import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/library/theme/theme.dart';

class BackgroundFrostBox extends StatelessWidget {
  const BackgroundFrostBox({
    this.onTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onTap;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: theme.canvasColor.withOpacity(0),
        child: const SizedBox.expand(),
      ).frosted(
        blur: theme.brightness == Brightness.dark ? 15 : 12,
        frostOpacity: 0.4,
        frostColor: theme.brightness == Brightness.dark
            ? AppColors.black
            : AppColors.white,
      ),
    );
  }
}
