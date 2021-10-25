part of home;

typedef ProjectSelectionChanged = void Function({
  required bool? selected,
  required BasicProject project,
});

class SmallHomeScreen extends StatefulWidget {
  const SmallHomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onInfoTap,
    required final this.onCreateIdeaTap,
    required final this.onCreateNoteTap,
    required final this.onGoHome,
    final this.verticalMenuAlignment = Alignment.bottomLeft,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  final Alignment verticalMenuAlignment;
  final VoidCallback onGoHome;

  @override
  _SmallHomeScreenState createState() => _SmallHomeScreenState();
}

class _SmallHomeScreenState extends State<SmallHomeScreen> {
  final selectedProjects = <ProjectId, BasicProject>{};
  void changeProjectSelection({
    required final bool? selected,
    required final BasicProject project,
  }) {
    if (selected == true) {
      selectedProjects.remove(project.id);
    } else {
      selectedProjects[project.id] = project;
    }
  }

  bool checkSelection(final BasicProject project) =>
      selectedProjects.containsKey(project.id);

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final verticalMenu = ColoredBox(
      color: Theme.of(context).primaryColor.withOpacity(.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _VerticalProjectsBar(
            onIdeaTap: widget.onCreateIdeaTap,
            onNoteTap: widget.onCreateNoteTap,
          ),
          const SizedBox(height: 14),
          const SafeAreaBottom(),
        ],
      ),
    );
    final projectsList = Expanded(
      child: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (final _, final ref, final __) {
                final projects =
                    ref.watch(allProjectsProviders).reversed.toList();
                if (projects.isEmpty) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        S.current.noProjectsYet,
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  );
                }
                return Scrollbar(
                  isAlwaysShown: true,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(5),
                    reverse: true,
                    shrinkWrap: true,
                    restorationId: 'projects',
                    itemBuilder: (final _, final i) {
                      final project = projects[i];
                      return ProjectTile(
                        key: ValueKey(project.id),
                        project: project,
                        onSelected: changeProjectSelection,
                        onTap: widget.onProjectTap,
                        checkSelection: checkSelection,
                        onRemove: (final _) async {
                          if (project is IdeaProject) {
                            await Future.forEach<IdeaProjectAnswer>(
                              project.answers ?? [],
                              (final answer) => answer.delete(),
                            );
                            ref
                                .read(ideaProjectsProvider.notifier)
                                .remove(key: project.id);
                          } else if (project is NoteProject) {
                            ref
                                .read(noteProjectsProvider.notifier)
                                .remove(key: project.id);
                          } else if (project is StoryProject) {
                            // TODO(arenukvern): implement StoryProject removal
                          }
                          await project.delete();
                          widget.onGoHome();
                        },
                        onRemoveConfirm: (final _) async {
                          return showRemoveProjectDialog(
                            context: context,
                            project: project,
                          );
                        },
                      );
                    },
                    separatorBuilder: (final _, final __) =>
                        const SizedBox(height: 3),
                    itemCount: projects.length,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          const SafeAreaBottom(),
        ],
      ),
    );
    final greeting = Greeting();
    final appBar = AppBar(
      // TODO(arenukvern): make popup with translation for native language
      title: SelectableText(
        greeting.current,
        style: theme.textTheme.headline2,
      ),
      actions: [
        IconButton(
          onPressed: widget.onInfoTap,
          icon: const Icon(Icons.info_outline),
        ),
        IconButton(
          onPressed: widget.onSettingsTap,
          icon: const Icon(Icons.settings),
        ),
      ]
          .map(
            (final child) => Padding(
              padding: const EdgeInsets.only(right: 18),
              child: child,
            ),
          )
          .toList(),
    );
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          const SizedBox(height: 2),
          if (widget.verticalMenuAlignment == Alignment.bottomLeft)
            verticalMenu,
          projectsList,
          if (widget.verticalMenuAlignment == Alignment.bottomRight)
            verticalMenu,
        ],
      ),
    );
  }
}
