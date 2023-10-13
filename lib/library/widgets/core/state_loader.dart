part of widgets;

abstract class StateInitializer extends Loadable {}

class StateLoader extends HookWidget {
  const StateLoader({
    required this.child,
    required this.initializer,
    required this.loader,
    super.key,
  });
  final Widget child;
  final StateInitializer initializer;
  final Widget loader;
  static const _transitionDuration = Duration(milliseconds: 450);
  static const _minScale = 0.98;
  static const _maxScale = 1.0;
  static const _scaleDiff = _maxScale - _minScale;
  @override
  Widget build(final BuildContext context) {
    final loaded = useIsBool();
    final renderAllowed = useIsBool();
    final loading = useIsBool();
    final homeOpacity = useState<double>(0);
    final loaderOpacity = useState<double>(1);
    final loaderScale = useState<double>(1);

    final animationController = useAnimationController(
      duration: _transitionDuration,
      initialValue: _minScale,
      lowerBound: _minScale,
    );
    final animation = useAnimation(animationController);

    useEffect(
      () {
        final progressPercent = (animation - _minScale) / _scaleDiff;
        homeOpacity.value = progressPercent;
        loaderOpacity.value = 1 - progressPercent;
        loaderScale.value = animation + 0.1;

        return null;
      },
      [animation],
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          if (!nativeTransparentBackgroundSupported)
            Container(
              color: AppColors.black,
            ),
          if (nativeTransparentBackgroundSupported && loaderOpacity.value > 0.0)
            Opacity(
              opacity: loaderOpacity.value,
              child: Container(
                color: AppColors.black,
              ),
            ),
          if (renderAllowed.value)
            Transform.scale(
              scale: animationController.value,
              child: child,
            ),
          if (loaderOpacity.value > 0.0)
            Opacity(
              opacity: loaderOpacity.value,
              child: Transform.scale(
                scale: loaderScale.value,
                child: FutureBuilder(
                  future: () async {
                    if (loading.value) return false;
                    loading.value = true;
                    loaded.value = true;
                    await initializer.onLoad(context: context);
                    renderAllowed.value = true;
                    await animationController.forward();
                    loading.value = false;

                    return true;
                  }(),
                  builder: (final context, final snapshot) {
                    if (snapshot.connectionState != ConnectionState.done ||
                        snapshot.data == false) {
                      return loader;
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}