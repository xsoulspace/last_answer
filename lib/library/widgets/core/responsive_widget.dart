part of widgets;

typedef PagesCallback = List<Page<dynamic>> Function();

class ResponsiveNavigator extends StatelessWidget {
  const ResponsiveNavigator({
    required final this.navigatorKey,
    required final this.onLargeScreen,
    required final this.onPopPage,
    final this.onMediumScreen,
    final this.onSmallScreen,
    final Key? key,
  }) : super(key: key);
  final PagesCallback onLargeScreen;
  final PagesCallback? onMediumScreen;
  final PagesCallback? onSmallScreen;
  final GlobalKey<NavigatorState> navigatorKey;
  final PopPageCallback? onPopPage;
  List<Page<dynamic>> getPages({required final BoxConstraints constraints}) {
    final screenLayout = ScreenLayout.from(constraints);
    if (screenLayout.large) {
      return onLargeScreen();
    } else if (screenLayout.medium) {
      /// if medium screen not available, then return large screen
      return onMediumScreen?.call() ?? onLargeScreen();
    } else {
      /// if small screen implementation not available, then return
      /// large screen
      return onSmallScreen?.call() ?? onLargeScreen();
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
  static const maxFullscreenPageWidth = 500.0;
  static const minFullscreenPageWidth = 450.0;
  static const maxSmallWidth = 700.0;
  static const maxMediumWidth = 1000.0;

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
  bool get notSmall => size.width > maxSmallWidth;
}
