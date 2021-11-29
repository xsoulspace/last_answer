part of home;

typedef ProjectSelectionChanged = void Function({
  required bool? selected,
  required BasicProject project,
});

class SmallHomeScreen extends StatefulHookWidget {
  const SmallHomeScreen({
    required final this.onProjectTap,
    required final this.onSettingsTap,
    required final this.onInfoTap,
    required final this.onCreateIdeaTap,
    required final this.onCreateNoteTap,
    required final this.onGoHome,
    required final this.checkIsProjectActive,
    final this.verticalMenuAlignment = Alignment.bottomLeft,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<BasicProject> onProjectTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCreateIdeaTap;
  final VoidCallback onCreateNoteTap;
  final Alignment verticalMenuAlignment;
  final BoolValueChanged<BasicProject> checkIsProjectActive;
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
    final scrollController = useScrollController();
    final themeDefiner = ThemeDefiner.of(context);
    final screenLayout = ScreenLayout.of(context);
    final effectiveTheme = themeDefiner.effectiveTheme;

    final verticalMenu = ColoredBox(
      color: themeDefiner.useContextTheme
          ? effectiveTheme.primaryColor.withOpacity(.03)
          : Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _VerticalProjectsBar(
            onIdeaTap: widget.onCreateIdeaTap,
            onNoteTap: widget.onCreateNoteTap,
          ),
          const SizedBox(height: 14),
          const BottomSafeArea(),
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
                    ref.watch(currentFolderProjects).reversed.toList();
                if (projects.isEmpty) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        S.current.noProjectsYet,
                        style: effectiveTheme.textTheme.headline2,
                      ),
                    ),
                  );
                }
                return ListTileTheme(
                  textColor: screenLayout.small
                      ? null
                      : effectiveTheme.textTheme.subtitle2?.color
                          ?.withOpacity(0.7),
                  child: RightScrollbar(
                    controller: scrollController,
                    child: ReorderableListView.builder(
                      scrollController: scrollController,
                      onReorder: (final oldIndex, final newIndex) {
                        final currentFolder =
                            ref.read(currentFolderProvider.notifier);

                        int effectiveIndex = newIndex;
                        final list = [...currentFolder.state.projectsList];
                        if (effectiveIndex > oldIndex) {
                          effectiveIndex -= 1;
                        }
                        final item = list.removeAt(oldIndex);
                        list.insert(effectiveIndex, item);
                        currentFolder.setExistedProjectsList(list);
                      },
                      padding: const EdgeInsets.all(5),
                      shrinkWrap: true,
                      restorationId: 'projects',
                      itemBuilder: (final _, final i) {
                        final project = projects[i];
                        return Padding(
                          key: ValueKey(project.id),
                          padding: const EdgeInsets.only(bottom: 3),
                          child: ProjectTile(
                            project: project,
                            themeDefiner: themeDefiner,
                            onSelected: changeProjectSelection,
                            onTap: widget.onProjectTap,
                            checkSelection: checkSelection,
                            isProjectActive:
                                widget.checkIsProjectActive(project),
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
                                // TODO(arenukvern): implement Story removal
                              }
                              await project.delete();
                              widget.onGoHome();
                            },
                            onRemoveConfirm: (final _) async {
                              return showRemoveTitleDialog(
                                context: context,
                                title: project.title,
                              );
                            },
                          ),
                        );
                      },
                      itemCount: projects.length,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          const BottomSafeArea(),
        ],
      ),
    );

    final greeting = Greeting();

    AppBar createAppBar() {
      if (Platform.isMacOS) {
        return LeftPanelMacosAppBar(
          context: context,
          title: greeting.current,
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
      }
      return AppBar(
        // TODO(arenukvern): make popup with translation for native language
        title: SelectableText(
          greeting.current,
          style: effectiveTheme.textTheme.headline2,
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
    }

    return Theme(
      data: effectiveTheme,
      child: Scaffold(
        appBar: createAppBar(),
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
      ),
    );
  }
}
