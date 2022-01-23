part of widgets;

class FadedRailPage<T> extends Page<T> {
  /// Creates a material page.
  const FadedRailPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    final LocalKey? key,
    final String? name,
    final Object? arguments,
    final String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(final BuildContext context) {
    return _PageBasedFadedRailPageRoute<T>(page: this);
  }
}

// A page-based version of MaterialPageRoute.
//
// This route uses the builder from the page to build its content. This ensures
// the content is up to date after page updates.
class _PageBasedFadedRailPageRoute<T> extends PageRoute<T>
    with FadedRailRouteTransitionMixin<T> {
  _PageBasedFadedRailPageRoute({
    required final FadedRailPage<T> page,
  }) : super(settings: page);

  MaterialPage<T> get _page => settings as MaterialPage<T>;

  @override
  Widget buildContent(final BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

mixin FadedRailRouteTransitionMixin<T> on PageRoute<T> {
  /// Builds the primary contents of the route.
  @protected
  Widget buildContent(final BuildContext context);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(final TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog
    return (nextRoute is MaterialRouteTransitionMixin &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoRouteTransitionMixin &&
            !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(
    final BuildContext context,
    final Animation<double> animation,
    final Animation<double> secondaryAnimation,
  ) {
    final Widget result = buildContent(context);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(
    final BuildContext context,
    final Animation<double> animation,
    final Animation<double> secondaryAnimation,
    final Widget child,
  ) {
    return child;
  }
}

class FadedRailTransition extends StatelessWidget {
  const FadedRailTransition({
    required this.animation,
    required this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  final Animation<double> animation;
  static const _minScale = 0.98;
  static const _maxScale = 1.0;
  static const _scaleDiff = _maxScale - _minScale;

  @override
  Widget build(final BuildContext context) {
    final tween = Tween(begin: _minScale, end: _maxScale).chain(
      CurveTween(curve: Curves.easeOutBack),
    );
    final animationValue = animation.drive(tween);
    return Container();
  }
}

// TODO(antmalofeev): plugin FadeRailMagentController to FadeRailMagent
/// and FadedRailTransition
class FadeRailMagentController extends ChangeNotifier {}

/// Can scale up and down
class FadeRailMagent extends HookWidget {
  const FadeRailMagent({
    required this.child,
    final Key? key,
  }) : super(key: key);
  static const _minScale = 0.98;

  final Widget child;
  @override
  Widget build(final BuildContext context) {
    final animationController = useAnimationController(
      initialValue: 1.0,
      lowerBound: _minScale,
    );
    final animation = useAnimation(animationController);

    return Transform.scale(scale: animation, child: child);
  }
}
