part of app_navigator;

class AppRouterDelegate extends RouterDelegate<AppRouteConfig>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<AppRouteConfig> {
  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  AppRouteConfig _config = AppRouteConfig.home();

  @override
  AppRouteConfig get currentConfiguration => _config;

  @override
  Future<void> setNewRoutePath(AppRouteConfig configuration) async {
    _config = configuration;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
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
            child: IdeaProjectScreen(projectId: _config.projectId),
          )
        else if (resolvedProject is NoteProject)
          MaterialPage(
            key: const ValueKey(AppRoutesName.note),
            child: NoteProjectScreen(projectId: _config.projectId),
          )
        else if (resolvedProject is StoryProject)
          MaterialPage(
            key: const ValueKey(AppRoutesName.story),
            child: StoryProjectScreen(projectId: _config.projectId),
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

  void onProjectTap(BasicProject project) {}

  void onSettingsTap() {}

  void onCreateIdeaTap() {}
}
