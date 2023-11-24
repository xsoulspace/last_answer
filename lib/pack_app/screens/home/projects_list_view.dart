import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class ProjectsListView extends HookWidget {
  const ProjectsListView({
    required this.themeDefiner,
    required this.onGoHome,
    required this.onProjectTap,
    required this.checkIsProjectActive,
    super.key,
  });
  final VoidCallback onGoHome;
  final ValueChanged<BasicProject> onProjectTap;
  final ThemeDefiner themeDefiner;
  final BoolValueChanged<BasicProject> checkIsProjectActive;

  @override
  Widget build(final BuildContext context) {
    final scrollController = useScrollController();
    final screenLayout = ScreenLayout.of(context);
    final textTheme = themeDefiner.effectiveTheme.textTheme;
    // final settings = context.read<GeneralSettingsController>();
    // final reversed = settings.projectsListReversed;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          context.l10n.noProjectsYet,
          style: textTheme.displayMedium,
        ),
      ),
    );
    // } else {
    //   return ListTileTheme(
    //     textColor: screenLayout.small
    //         ? null
    //         : textTheme.titleSmall?.color?.withOpacity(0.7),
    //     child: RightScrollbar(
    //       controller: scrollController,
    //       child: ListView.builder(
    //         reverse: reversed,
    //         key: const PageStorageKey('projects_scroll_view'),
    //         controller: scrollController,
    //         padding: const EdgeInsets.all(5),
    //         // shrinkWrap: true,
    //         restorationId: 'projects',
    //         itemCount: 0,
    //         itemBuilder: (final _, final i) {
    //           final project = projects[i];

    //           return Padding(
    //             key: ValueKey(project.id),
    //             padding: const EdgeInsets.only(bottom: 3),
    //             child: ProjectTile(
    //               project: project,
    //               themeDefiner: themeDefiner,
    //               onTap: onProjectTap,
    //               isProjectActive: checkIsProjectActive(project),
    //               onRemove: (final _) async => {},
    //               onRemoveConfirm: (final _) async => showRemoveTitleDialog(
    //                 context: context,
    //                 title: project.title,
    //               ),
    //             ),
    //           );
    //         },
    //       ),
    //     ),
    //   );
  }
}
