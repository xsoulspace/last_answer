import 'package:flutter/material.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/screens/home/small_home_screen.dart';

class LargeHomeScreen extends StatelessWidget {
  const LargeHomeScreen({
    required this.mainScreenNavigator,
    final Key? key,
  }) : super(key: key);
  final Widget mainScreenNavigator;

  @override
  Widget build(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    final leftColumn = (size.width / 4).clamp(300, 400).toDouble();
    const centerRightBorder = 0.6;
    final rightColumn = ScreenLayout.of(context).large ? leftColumn : 0.0;
    final centerPart =
        size.width - leftColumn - rightColumn - centerRightBorder;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: leftColumn,
          child: const SmallHomeScreen(
            verticalMenuAlignment: Alignment.bottomRight,
          ),
        ),
        Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? AppColors.cleanBlack
                    : AppColors.grey4,
                width: centerRightBorder,
              ),
            ),
            color: theme.canvasColor,
          ),
          child: SizedBox(
            width: centerPart,
            child: mainScreenNavigator,
          ),
        ),
        if (rightColumn > 0)
          Container(
            color: DeviceRuntimeType.isNativeDesktop
                ? theme.canvasColor.withOpacity(0.9)
                : theme.canvasColor,
            width: rightColumn,
          ),
      ],
    );
  }
}
