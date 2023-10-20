part of widgets;

abstract class StateInitializer extends Loadable {}

class StateLoader extends StatefulHookWidget {
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
  State<StateLoader> createState() => _StateLoaderState();
}

class _StateLoaderState extends State<StateLoader>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _loaded = false;
  bool _renderAllowed = false;
  late final animationController = AnimationController(
    vsync: this,
    duration: StateLoader._transitionDuration,
    value: StateLoader._minScale,
    lowerBound: StateLoader._minScale,
  );
  late final _initFuture = () async {
    if (_isLoading) return false;
    if (!_loaded) {
      _isLoading = true;
      _loaded = true;
      await widget.initializer.onLoad(context: context);
      _renderAllowed = true;
      await animationController.forward();
      _isLoading = false;
    }

    return true;
  }();
  @override
  Widget build(final BuildContext context) {
    final homeOpacity = useState<double>(0);
    final loaderOpacity = useState<double>(1);
    final loaderScale = useState<double>(1);
    final animation = useAnimation(animationController);
    useEffect(
      () {
        final progressPercent =
            (animation - StateLoader._minScale) / StateLoader._scaleDiff;
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
          if (_renderAllowed)
            Transform.scale(
              scale: animationController.value,
              child: widget.child,
            ),
          if (loaderOpacity.value > 0.0)
            Opacity(
              opacity: loaderOpacity.value,
              child: Transform.scale(
                scale: loaderScale.value,
                child: FutureBuilder(
                  future: _initFuture,
                  builder: (final context, final snapshot) {
                    if (snapshot.connectionState != ConnectionState.done ||
                        snapshot.data == false) {
                      return widget.loader;
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
