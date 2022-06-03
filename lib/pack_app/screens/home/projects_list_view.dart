part of pack_app;

class ProjectsListView extends HookWidget {
  const ProjectsListView({
    required final this.themeDefiner,
    required final this.onGoHome,
    required final this.onProjectTap,
    required final this.checkIsProjectActive,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onGoHome;
  final ValueChanged<BasicProject> onProjectTap;
  final ThemeDefiner themeDefiner;
  final BoolValueChanged<BasicProject> checkIsProjectActive;

  @override
  Widget build(final BuildContext context) {
    final scrollController = useScrollController();
    final screenLayout = ScreenLayout.of(context);
    final textTheme = themeDefiner.effectiveTheme.textTheme;
    final settings = context.watch<GeneralSettingsController>();
    final reversed = settings.projectsListReversed;

    return Consumer<CurrentFolderNotifier>(
      builder: (final context, final folderState, final __) {
        final projects = folderState.state.projectsList;

        if (projects.isEmpty) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                S.current.noProjectsYet,
                style: textTheme.headline2,
              ),
            ),
          );
        } else {
          return ListTileTheme(
            textColor: screenLayout.small
                ? null
                : textTheme.subtitle2?.color?.withOpacity(0.7),
            child: RightScrollbar(
              controller: scrollController,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                reverse: reversed,
                key: const PageStorageKey('projects_scroll_view'),
                controller: scrollController,
                padding: const EdgeInsets.all(5),
                // shrinkWrap: true,
                restorationId: 'projects',
                itemCount: projects.length,
                itemBuilder: (final _, final i) {
                  final project = projects[i];

                  return Padding(
                    key: ValueKey(project.id),
                    padding: const EdgeInsets.only(bottom: 3),
                    child: ProjectTile(
                      project: project,
                      themeDefiner: themeDefiner,
                      onTap: onProjectTap,
                      isProjectActive: checkIsProjectActive(project),
                      onRemove: (final _) async => removeProject(
                        checkIsProjectActive: checkIsProjectActive,
                        context: context,
                        onGoHome: onGoHome,
                        project: project,
                      ),
                      onRemoveConfirm: (final _) async {
                        return showRemoveTitleDialog(
                          context: context,
                          title: project.title,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}

// TODO(arenukvern): move it to global functions
Future<void> removeProject({
  required final BuildContext context,
  required final BasicProject project,
  required final BoolValueChanged<BasicProject> checkIsProjectActive,
  required final VoidCallback onGoHome,
}) async {
  await project.deleteWithRelatives(context: context);
  context.read<CurrentFolderNotifier>().notify();
  if (checkIsProjectActive(project)) {
    onGoHome();
  }
}
