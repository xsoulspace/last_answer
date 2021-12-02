part of pack_app;

class AppNavigatorPopper extends AppNavigatorDataProvider {
  AppNavigatorPopper({
    required final RouteState routeState,
  }) : super(routeState: routeState);

  Future<bool> handleWillPop() async {
    switch (pathTemplate) {
      case AppRoutesName.ideaAnswer:
        navigatorController.goIdeaScreen(ideaId: params.ideaId!);
        break;
      case AppRoutesName.idea:
      case AppRoutesName.note:
      case AppRoutesName.createIdea:
      case AppRoutesName.settings:
        navigatorController.goHome();
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
      if (maybePage.key == _ValueKeys._createIdea) {
        navigatorController.goHome();
      } else if (maybePage.key == _ValueKeys._ideasIdea) {
        navigatorController.goHome();
      } else if (maybePage.key == _ValueKeys._ideasIdeaAnswer) {
        final arr = maybePage.name?.split('/') ?? [];
        if (arr.length == 4) {
          navigatorController.goIdeaScreen(ideaId: arr[4]);
        } else {
          navigatorController.goHome();
        }
      } else if (maybePage.key == _ValueKeys._settings) {
        navigatorController.goHome();
      }
    }

    final popped = route.didPop(result);
    return popped;
  }
}
