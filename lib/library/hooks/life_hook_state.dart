part of hooks;

abstract class LifeState {
  void initState();
  void dispose();
  ValueChanged<VoidCallback>? setState;
}

class LifeHook<T extends LifeState> extends Hook<T> {
  const LifeHook({
    required this.debugLabel,
    required this.state,
  });

  final String debugLabel;
  final T state;

  @override
  _LifeHookState<T> createState() => _LifeHookState<T>(state: state);
}

class _LifeHookState<T extends LifeState> extends HookState<T, LifeHook<T>> {
  _LifeHookState({required final T state}) : _innerState = state;
  final T _innerState;
  @override
  void initHook() {
    _innerState
      ..setState = setState
      ..initState();
    super.initHook();
  }

  @override
  T build(final BuildContext context) => _innerState;

  @override
  void dispose() {
    _innerState
      ..setState = null
      ..dispose();
  }

  @override
  String get debugLabel => hook.debugLabel;
}
