part of widgets;

class ResponsiveNavigator extends StatelessWidget {
  const ResponsiveNavigator({
    required final this.navigatorKey,
    required final this.largeScreen,
    required final this.onPopPage,
    final this.mediumScreen,
    final this.smallScreen,
    final Key? key,
  }) : super(key: key);
  final List<Page<dynamic>> largeScreen;
  final List<Page<dynamic>>? mediumScreen;
  final List<Page<dynamic>>? smallScreen;
  final GlobalKey<NavigatorState> navigatorKey;
  final PopPageCallback? onPopPage;
  List<Page<dynamic>> getPages({required final BoxConstraints constraints}) {
    final screenLayout = ScreenLayout.from(constraints);
    if (screenLayout.large) {
      return largeScreen;
    } else if (screenLayout.medium) {
      /// if medium screen not available, then return large screen
      return mediumScreen ?? largeScreen;
    } else {
      /// if small screen implementation not available, then return
      /// large screen
      return smallScreen ?? largeScreen;
    }
  }

  @override
  Widget build(final BuildContext context) {
    /// Returns the widget which is more appropriate for the screen size
    return LayoutBuilder(
      builder: (final context, final constraints) {
        return Navigator(
          onGenerateRoute: (final _) => null,
          key: navigatorKey,
          onPopPage: onPopPage,
          pages: getPages(constraints: constraints),
        );
      },
    );
  }
}

class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({
    required final this.largeScreen,
    final this.mediumScreen,
    final this.smallScreen,
    final Key? key,
  }) : super(key: key);
  final Widget largeScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;

  @override
  Widget build(final BuildContext context) {
    /// Returns the widget which is more appropriate for the screen size
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final screenLayout = ScreenLayout.from(constraints);
        if (screenLayout.large) {
          return largeScreen;
        } else if (screenLayout.medium) {
          /// if medium screen not available, then return large screen
          return mediumScreen ?? largeScreen;
        } else {
          /// if small screen implementation not available, then return
          /// large screen
          return smallScreen ?? largeScreen;
        }
      },
    );
  }
}

class ScreenLayout {
  ScreenLayout._({final this.context, final this.constraints})
      : assert(
          context != null || constraints != null,
          'context or constraints should be filled',
        );
  factory ScreenLayout.from(final BoxConstraints constraints) =>
      ScreenLayout._(constraints: constraints);
  factory ScreenLayout.of(final BuildContext context) =>
      ScreenLayout._(context: context);

  final BuildContext? context;
  final BoxConstraints? constraints;

  static const maxSmallWidth = 800;
  static const maxMediumWidth = 1200;

  Size get size {
    if (constraints != null) {
      return Size(constraints!.maxWidth, constraints!.maxHeight);
    }
    return MediaQuery.of(context!).size;
  }

  //Large screen is any screen whose width is more than 1200 pixels
  bool get large => size.width > maxMediumWidth;

  //Medium screen is any screen whose width is less than 1200 pixels,
  //and more than 800 pixels
  bool get medium => size.width > maxSmallWidth && size.width < maxMediumWidth;

  //Small screen is any screen whose width is less than 800 pixels
  bool get small => size.width < maxSmallWidth;
}
