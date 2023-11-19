import 'package:lastanswer/_library/widgets/buttons/cupertino_icon_button.dart';
import 'package:lastanswer/common_imports.dart';

class ProjectsDirectionSwitch extends StatelessWidget {
  const ProjectsDirectionSwitch({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    final settings = userNotifier.settings;
    void setReverse({required final bool isReversed}) =>
        userNotifier.updateIsProjectsReversed(isReversed: isReversed);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CupertinoIconButton(
            onPressed: settings.isProjectsListReversed
                ? null
                : () => setReverse(isReversed: true),
            icon: Icons.vertical_align_bottom_rounded,
            color: settings.isProjectsListReversed ? AppColors.primary : null,
          ),
          const SizedBox(width: 8),
          CupertinoIconButton(
            onPressed: settings.isProjectsListReversed
                ? () => setReverse(isReversed: false)
                : null,
            color: settings.isProjectsListReversed ? null : AppColors.primary,
            icon: Icons.vertical_align_top_rounded,
          ),
        ],
      ),
    );
  }
}
