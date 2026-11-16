import 'package:lastanswer/common_imports.dart';

class ProjectsDirectionSwitch extends StatelessWidget {
  const ProjectsDirectionSwitch({super.key});

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    final settings = userNotifier.settings;
    void setReverse({required final bool isReversed}) =>
        userNotifier.updateIsProjectsReversed(isReversed: isReversed);
    final laUi = context.laUi;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          LaButton.icon(
            onPressed: () => setReverse(isReversed: true),
            icon: Icon(
              Icons.vertical_align_bottom_rounded,
              color: settings.isProjectsListReversed ? laUi.accent : laUi.ink,
            ),
          ),
          LaButton.icon(
            onPressed: () => setReverse(isReversed: false),
            icon: Icon(
              Icons.vertical_align_top_rounded,
              color: settings.isProjectsListReversed ? laUi.ink : laUi.accent,
            ),
          ),
        ],
      ),
    );
  }
}
