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
    final d = '';
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
        if (_config.isUnknownPage)
          const MaterialPage(
            key: ValueKey(AppRoutesName.unknown404),
            child: UnknownScreen(),
          ),
        if (_config.isIdeaPage)
          MaterialPage(
            key: const ValueKey(AppRoutesName.idea),
            child: IdeaProjectScreen(projectId: _config.projectId),
          ),
        if (_config.isNotePage)
          MaterialPage(
            key: const ValueKey(AppRoutesName.note),
            child: NoteProjectScreen(projectId: _config.projectId),
          ),
        if (_config.isStoryPage)
          MaterialPage(
            key: const ValueKey(AppRoutesName.story),
            child: StoryProjectScreen(projectId: _config.projectId),
          )
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  void onProjectTap(BasicProject project) {}

  void onSettingsTap() {}

  void onCreateIdeaTap() {}
}
