import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/widgets.dart';

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
    final settings = context.read<GeneralSettingsController>();
    final reversed = settings.projectsListReversed;

    return Consumer<FolderStateNotifier>(
      builder: (final context, final folderState, final __) {
        final projects = folderState.state.projectsList;

        if (projects.isEmpty) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                S.current.noProjectsYet,
                style: textTheme.displayMedium,
              ),
            ),
          );
        } else {
          return ListTileTheme(
            textColor: screenLayout.small
                ? null
                : textTheme.titleSmall?.color?.withOpacity(0.7),
            child: RightScrollbar(
              controller: scrollController,
              child: ListView.builder(
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
                        folderProvider: folderState,
                        onGoHome: onGoHome,
                        project: project,
                      ),
                      onRemoveConfirm: (final _) async => showRemoveTitleDialog(
                        context: context,
                        title: project.title,
                      ),
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
  required final FolderStateNotifier folderProvider,
  required final BoolValueChanged<BasicProject> checkIsProjectActive,
  required final VoidCallback onGoHome,
}) async {
  if (project is IdeaProject) {
    final deleteAnswerFutures = project.answers?.map(
      (final answer) => answer.delete(),
    );
    if (deleteAnswerFutures != null) {
      await Future.wait(deleteAnswerFutures);
    }

    context.read<IdeaProjectsState>().remove(key: project.id);
  } else if (project is NoteProject) {
    context.read<NoteProjectsState>().remove(key: project.id);
  }
  project.folder?.removeProject(project);
  folderProvider.notify();
  await project.delete();
  if (checkIsProjectActive(project)) {
    onGoHome();
  }
}
