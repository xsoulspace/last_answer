import 'package:flutter/material.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/screens/home/small_home_screen.dart';
import 'package:lastanswer/pack_app/widgets/project_tile.dart';

class LargeHomeScreen extends StatelessWidget {
  const LargeHomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onInfoTap,
    required final this.onCreateIdeaTap,
    required final this.onCreateNoteTap,
    required final this.mainScreenNavigator,
    required final this.onGoHome,
    required final this.checkIsProjectActive,
    required final this.onFolderTap,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  final Widget mainScreenNavigator;
  final ValueChanged<ProjectFolder> onFolderTap;
  final VoidCallback onGoHome;

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
          child: SmallHomeScreen(
            onFolderTap: onFolderTap,
            verticalMenuAlignment: Alignment.bottomRight,
            onGoHome: onGoHome,
            checkIsProjectActive: checkIsProjectActive,
            onCreateIdeaTap: onCreateIdeaTap,
            onCreateNoteTap: onCreateNoteTap,
            onInfoTap: onInfoTap,
            onProjectTap: onProjectTap,
            onSettingsTap: onSettingsTap,
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
