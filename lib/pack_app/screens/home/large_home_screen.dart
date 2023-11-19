import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/screens/home/small_home_screen.dart';

class LargeHomeScreen extends StatelessWidget {
  const LargeHomeScreen({
    required this.onProjectTap,
    required this.onSettingsTap,
    required this.onInfoTap,
    required this.onCreateIdeaTap,
    required this.onCreateNoteTap,
    required this.mainScreenNavigator,
    required this.onGoHome,
    required this.checkIsProjectActive,
    super.key,
  });
  final ValueChanged<BasicProject> onProjectTap;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  final Widget mainScreenNavigator;
  final VoidCallback onGoHome;

  @override
  Widget build(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    final leftColumn = (size.width / 4).clamp(300, 400).toDouble();
    const centerRightBorder = 0.6;
    final rightColumn = ScreenLayout.of(context).large ? leftColumn : 0.0;
    final centerPart =
        size.width - leftColumn - rightColumn - centerRightBorder;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: leftColumn,
          child: SmallHomeScreen(
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cleanBlack
                    : AppColors.grey4,
                width: centerRightBorder,
              ),
            ),
            color: Theme.of(context).canvasColor,
          ),
          child: SizedBox(
            width: centerPart,
            child: mainScreenNavigator,
          ),
        ),
        if (rightColumn > 0)
          Container(
            color: PlatformInfo.isNativeDesktop
                ? Theme.of(context).canvasColor.withOpacity(0.9)
                : Theme.of(context).canvasColor,
            width: rightColumn,
          ),
      ],
    );
  }
}
