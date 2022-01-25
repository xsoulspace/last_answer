part of hooks;

ValueNotifier<bool> useKeyboardVisibility() {
  return use(const _KeyboardVisiblityHook());
}

class _KeyboardVisiblityHook extends Hook<ValueNotifier<bool>> {
  const _KeyboardVisiblityHook();

  @override
  _KeyboardVisiblityHookState createState() => _KeyboardVisiblityHookState();
}

class _KeyboardVisiblityHookState
    extends HookState<ValueNotifier<bool>, _KeyboardVisiblityHook> {
  late final _state = ValueNotifier<bool>(false)..addListener(_listener);
  final keyboardVisiblityNotifier = KeyboardVisibilityNotification();
  int? keyboardSubscription;
  @override
  void initHook() {
    keyboardSubscription = keyboardVisiblityNotifier.addNewListener(
      onChange: onKeyboardVisibiltyChange,
    );
    super.initHook();
  }

  @override
  void dispose() {
    if (keyboardSubscription != null) {
      keyboardVisiblityNotifier.removeListener(keyboardSubscription);
    }

    keyboardVisiblityNotifier.dispose();
    _state.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  void onKeyboardVisibiltyChange(final bool visible) {}

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
