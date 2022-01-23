part of pack_app;

class AppNavigatorPopper extends AppNavigatorDataProvider {
  AppNavigatorPopper({
    required final RouteState routeState,
    required final BuildContext context,
  }) : super(
          routeState: routeState,
          context: context,
        );

  Future<bool> handleWillPop() async {
    switch (pathTemplate) {
      case AppRoutesName.ideaAnswer:
        navigatorController.goIdeaScreen(ideaId: params.ideaId!);
        break;
      case AppRoutesName.idea:
      case AppRoutesName.note:
      case AppRoutesName.createIdea:
      case AppRoutesName.settings:
      case AppRoutesName.generalSettings:
        navigatorController.goHome();
        break;
      case AppRoutesName.subscription:
      case AppRoutesName.changelog:
      case AppRoutesName.profile:
        navigatorController.goSettings();
        break;
      case AppRoutesName.home:
    }

    return false;
  }

  bool onPopPage(
    final Route<dynamic> route,
    final dynamic result,
  ) {
    /// ! here will go selected pages logic.
    final maybePage = route.settings;
    if (maybePage is Page) {
      if (maybePage.key == NavigatorValueKeys._createIdea) {
        navigatorController.goHome();
      } else if (maybePage.key == NavigatorValueKeys._ideasIdea) {
        navigatorController.goHome();
      } else if (maybePage.key == NavigatorValueKeys._ideasIdeaAnswer) {
        final arr = maybePage.name?.split('/') ?? [];
        if (arr.length == 4) {
          navigatorController.goIdeaScreen(ideaId: arr[4]);
        } else {
          navigatorController.goHome();
        }
      } else if (maybePage.name?.contains(AppRoutesName.settings) == true) {
        if (maybePage.name == AppRoutesName.settings) {
          navigatorController.goHome();
        } else {
          navigatorController.goSettings();
        }
      }
    }

    final popped = route.didPop(result);

    return popped;
  }
}
