part of app_navigator;

class AppRouteInformationParser extends RouteInformationParser<AppRouteConfig> {
  @override
  SynchronousFuture<AppRouteConfig> parseRouteInformation(
          RouteInformation routeInformation) =>
      SynchronousFuture(_parseRouteInformation(routeInformation));

  /// This method is separated to make easier
  /// [SynchronousFuture] creation for [parseRouteInformation]
  AppRouteConfig _parseRouteInformation(RouteInformation routeInformation) {
    final resolvedLocation = routeInformation.location;

    if (resolvedLocation == null) return AppRouteConfig.home();

    final uri = Uri.parse(resolvedLocation);

    /// Handle '/'
    if (uri.pathSegments.isEmpty) {
      return AppRouteConfig.home();
    }

    /// Handle two segmented paths, like
    /// '/idea/:id'
    /// '/note/:id'
    /// '/story/:id'
    if (uri.pathSegments.length == 2) {
      final sectionOne = uri.pathSegments[0];
      final sectionTwo = uri.pathSegments[1];
      switch (sectionOne) {
        case AppRoutesName.idea:
          return AppRouteConfig.idea(id: sectionTwo);
        case AppRoutesName.note:
          return AppRouteConfig.note(id: sectionTwo);
        case AppRoutesName.story:
          return AppRouteConfig.story(id: sectionTwo);
      }

      /// Handle one segmented paths, like
      /// /settings
      /// /idea-c
    } else if (uri.pathSegments.length == 1) {
      final sectionType = uri.pathSegments[0];
      switch (sectionType) {
        case AppRoutesName.createIdea:
          return AppRouteConfig.createIdea();
        case AppRoutesName.settings:
          return AppRouteConfig.settings();
      }
    }

    // Handle unknown routes
    return AppRouteConfig.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRouteConfig configuration) {
    if (configuration.isUnknownPage) {
      return const RouteInformation(location: '/${AppRoutesName.unknown404}');
    } else if (configuration.isHomePage) {
      return const RouteInformation(location: AppRoutesName.home);
    } else if (configuration.isIdeaPage) {
      return RouteInformation(
          location: '/${AppRoutesName.idea}/${configuration.projectId}');
    } else if (configuration.isCreateIdeaPage) {
      return const RouteInformation(location: '/${AppRoutesName.createIdea}');
    } else if (configuration.isNotePage) {
      return RouteInformation(
          location: '/${AppRoutesName.note}/${configuration.projectId}');
    } else if (configuration.isStoryPage) {
      return RouteInformation(
          location: '/${AppRoutesName.story}/${configuration.projectId}');
    } else if (configuration.isSettingsPage) {
      return const RouteInformation(location: '/${AppRoutesName.settings}');
    }
    return null;
  }
}
