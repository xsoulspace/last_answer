part of '../widgets.dart';

class FadedRailPage<T> extends Page<T> {
  /// Creates a material page.
  const FadedRailPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(final BuildContext context) =>
      _PageBasedFadedRailPageRoute<T>(page: this);
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

  FadedRailPage<T> get _page => settings as FadedRailPage<T>;

  @override
  Widget buildContent(final BuildContext context) => _page.child;

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
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(final TransitionRoute<dynamic> nextRoute)
      // Don't perform outgoing animation if the next route is
      // a fullscreen dialog
      =>
      (nextRoute is MaterialRouteTransitionMixin &&
          !nextRoute.fullscreenDialog) ||
      (nextRoute is CupertinoRouteTransitionMixin &&
          !nextRoute.fullscreenDialog);

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
  ) =>
      FadedRailTransition(
        animation: animation,
        child: child,
      );
}

class FadedRailTransition extends StatelessWidget {
  const FadedRailTransition({
    required this.animation,
    required this.child,
    super.key,
  });
  final Widget child;
  final Animation<double> animation;
  static const _minScale = 1.1;
  static const _maxScale = 1.0;
  static const _scaleDiff = _maxScale - _minScale;

  @override
  Widget build(final BuildContext context) {
    final tween = Tween(begin: _minScale, end: _maxScale).chain(
      CurveTween(curve: Curves.easeInOutQuad),
    );
    final drivenAnimation = animation.drive(tween);
    double opacity = (drivenAnimation.value - _minScale) / _scaleDiff;
    if (opacity > 1) {
      opacity = 1;
    } else if (opacity < 0) {
      opacity = 0;
    }

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: drivenAnimation.value,
        child: child,
      ),
    );
  }
}

// TODO(antmalofeev): plugin FadeRailMagentController to FadeRailMagent
/// and FadedRailTransition
class RailMagnetController extends ChangeNotifier {}

/// Can scale up and down
class RailMagnet extends HookWidget {
  const RailMagnet({
    required this.child,
    super.key,
  });
  static const _minScale = 0.98;

  final Widget child;
  @override
  Widget build(final BuildContext context) {
    final animationController = useAnimationController(
      initialValue: 1,
      lowerBound: _minScale,
    );
    final animation = useAnimation(animationController);
    final railMagnetController = context.read<RailMagnetController>();

    return Transform.scale(scale: animation, child: child);
  }
}
