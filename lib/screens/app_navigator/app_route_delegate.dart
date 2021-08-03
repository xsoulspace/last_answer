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

  @override
  AppRouteConfig get currentConfiguration {
    final project = _selectedProject;
    if (showUnknown404) {
      return AppRouteConfig.unknown();
    }
    if (project is IdeaProject) {
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
    // if (path.isUnknown) {
    //   _selectedBook = null;
    //   showUnknown404 = true;
    //   return;
    // }

    // if (path.isDetailsPage) {
    //   if (path.id < 0 || path.id > books.length - 1) {
    //     showUnknown404 = true;
    //     return;
    //   }

    //   _selectedBook = books[path.id];
    // } else {
    //   _selectedBook = null;
    // }

    // showUnknown404 = false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Navigator(
  //     key: navigatorKey,
  //     pages: [
  //       MaterialPage(
  //         key: ValueKey('BooksListPage'),
  //         child: BooksListScreen(
  //           books: books,
  //           onTapped: _handleBookTapped,
  //         ),
  //       ),
  //       if (showUnknown404)
  //         MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
  //       else if (_selectedBook != null)
  //         BookDetailsPage(book: _selectedBook)
  //     ],
  //     onPopPage: (route, result) {
  //       if (!route.didPop(result)) {
  //         return false;
  //       }

  //       // Update the list of pages by setting _selectedBook to null
  //       _selectedBook = null;
  //       showUnknown404 = false;
  //       notifyListeners();

  //       return true;
  //     },
  //   );
  // }

}
