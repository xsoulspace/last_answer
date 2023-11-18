import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/buttons/cupertino_icon_button.dart';

class ProjectsDirectionSwitch extends StatelessWidget {
  const ProjectsDirectionSwitch({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final globalStateNotifier = context.watch<GlobalStateNotifier>();
    final settings = globalStateNotifier.value.user.settings;
    void setReverse({required final bool reverse}) {
      globalStateNotifier.updateUser(
        (final user) => user.copyWith(
          settings: settings.copyWith(
            isProjectsListReversed: reverse,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CupertinoIconButton(
            onPressed: settings.isProjectsListReversed
                ? null
                : () => setReverse(reverse: true),
            icon: Icons.vertical_align_bottom_rounded,
            color: settings.isProjectsListReversed ? AppColors.primary : null,
          ),
          const SizedBox(width: 8),
          CupertinoIconButton(
            onPressed: settings.isProjectsListReversed
                ? () => setReverse(reverse: false)
                : null,
            color: settings.isProjectsListReversed ? null : AppColors.primary,
            icon: Icons.vertical_align_top_rounded,
          ),
        ],
      ),
    );
  }
}
