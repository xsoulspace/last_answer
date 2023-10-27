part of 'hooks.dart';

ValueNotifier<bool> useKeyboardVisibility() =>
    use(const _KeyboardVisiblityHook());

class _KeyboardVisiblityHook extends Hook<ValueNotifier<bool>> {
  const _KeyboardVisiblityHook();

  @override
  _KeyboardVisiblityHookState createState() => _KeyboardVisiblityHookState();
}

class _KeyboardVisiblityHookState
    extends HookState<ValueNotifier<bool>, _KeyboardVisiblityHook> {
  late final _state = ValueNotifier<bool>(false)..addListener(_listener);
  StreamSubscription<bool>? keyboardSubscription;
  @override
  void initHook() {
    if (isNativeDesktop) return;

    final keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen(onKeyboardVisibiltyChange);

    super.initHook();
  }

  @override
  void dispose() {
    unawaited(keyboardSubscription?.cancel());
    _state.dispose();
  }

  // ignore: avoid_positional_boolean_parameters, use_setters_to_change_properties
  void onKeyboardVisibiltyChange(final bool visible) {
    _state.value = visible;
  }

  @override
  ValueNotifier<bool> build(final BuildContext context) => _state;

  void _listener() {
    setState(() {});
  }

  @override
  bool? get debugValue => _state.value;

  @override
  String get debugLabel => 'useState<$bool>';
}
