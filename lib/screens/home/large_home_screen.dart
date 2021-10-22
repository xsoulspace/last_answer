part of home;

class LargeHomeScreen extends StatelessWidget {
  const LargeHomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onInfoTap,
    required final this.onCreateIdeaTap,
    required final this.onCreateNoteTap,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;

  @override
  Widget build(final BuildContext context) {
    final size = MediaQuery.of(context).size;
    final leftColumn = (size.width / 4).clamp(300, 400).toDouble();
    final rightColumn = ScreenLayout.of(context).large ? leftColumn : 0.0;

    final centerPart = size.width - leftColumn - rightColumn;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: leftColumn,
          child: SmallHomeScreen(
            verticalMenuAlignment: Alignment.bottomRight,
            onCreateIdeaTap: onCreateIdeaTap,
            onCreateNoteTap: onCreateNoteTap,
            onInfoTap: onInfoTap,
            onProjectTap: onProjectTap,
            onSettingsTap: onSettingsTap,
          ),
        ),
        SizedBox(
          width: centerPart,
          child: Container(
            color: Colors.greenAccent,
          ),
        ),
        if (rightColumn > 0) SizedBox(width: rightColumn),
      ],
    );
  }
}
