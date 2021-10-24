part of home;

class LargeHomeScreen extends StatelessWidget {
  const LargeHomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onInfoTap,
    required final this.onCreateIdeaTap,
    required final this.onCreateNoteTap,
    required final this.mainScreenNavigator,
    required final this.onGoHome,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
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
            color: Theme.of(context).canvasColor,
            width: rightColumn,
          ),
      ],
    );
  }
}