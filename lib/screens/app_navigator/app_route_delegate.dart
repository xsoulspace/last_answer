part of app_navigator;

class AppRouterDelegate extends RouterDelegate<AppRouteConfig>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<AppRouteConfig> {
  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  BasicProject? _selectedProject;
  bool showUnknown404 = false;
  bool showCreateIdea = false;
  bool showSettings = false;
  void _resetState() {
    showUnknown404 = false;
    showCreateIdea = false;
    showSettings = false;
    _selectedProject = null;
  }

  @override
  AppRouteConfig get currentConfiguration {
    final project = _selectedProject;
    if (showUnknown404) {
      return AppRouteConfig.unknown();
    } else if (showSettings) {
      return AppRouteConfig.settings();
    } else if (showCreateIdea) {
      return AppRouteConfig.createIdea();
    } else if (project is IdeaProject) {
      return AppRouteConfig.idea(id: project.id);
    } else if (project is NoteProject) {
      return AppRouteConfig.note(id: project.id);
    } else if (project is StoryProject) {
      return AppRouteConfig.story(id: project.id);
    } else {
      return AppRouteConfig.home();
    }
  }

  @override
  Future<void> setNewRoutePath(AppRouteConfig configuration) async {
    _resetState();

    if (configuration.isHome) {
      return;
    } else if (configuration.isCreateIdea) {
      showCreateIdea = true;
    } else if (configuration.isIdea) {
      final box = Hive.box(HiveBoxesIds.ideaProjectKey);
      _selectedProject = box.get(configuration.id);
    } else if (configuration.isNote) {
      final box = Hive.box(HiveBoxesIds.noteProjectKey);
      _selectedProject = box.get(configuration.id);
    } else if (configuration.isSettings) {
      showSettings = true;
    } else if (configuration.isStory) {
      final box = Hive.box(HiveBoxesIds.storyProjectKey);
      _selectedProject = box.get(configuration.id);
    } else if (configuration.isUnknown) {
      showUnknown404 = true;
    }
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedProject = _selectedProject;
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey(AppRoutesName.home),
          child: HomeScreen(
            onProjectTap: onProjectTap,
            onSettingsTap: onSettingsTap,
            onCreateIdeaTap: onCreateIdeaTap,
          ),
        ),
        if (showUnknown404)
          MaterialPage(
            key: const ValueKey(AppRoutesName.unknown404),
            child: UnknownScreen(),
          )
        else if (resolvedProject is IdeaProject)
          MaterialPage(
            key: const ValueKey(AppRoutesName.idea),
            child: IdeaProjectScreen(project: resolvedProject),
          )
        else if (resolvedProject is NoteProject)
          MaterialPage(
            key: const ValueKey(AppRoutesName.note),
            child: NoteProjectScreen(project: resolvedProject),
          )
        else if (resolvedProject is StoryProject)
          MaterialPage(
            key: const ValueKey(AppRoutesName.story),
            child: StoryProjectScreen(project: resolvedProject),
          )
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting _selectedBook to null
        // _selected = null;
        // showUnknown404 = false;
        // notifyListeners();

        return true;
      },
    );
  }

  void onProjectTap(BasicProject project) {
    _resetState();
    _selectedProject = project;
    notifyListeners();
  }

  void onSettingsTap() {
    _resetState();
    showSettings = true;
    notifyListeners();
  }

  void onCreateIdeaTap() {
    _resetState();
    showCreateIdea = true;
    notifyListeners();
  }
}
