part of utils;

void closeKeyboard({required final BuildContext context}) {
  final FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.focusedChild?.unfocus();
  }
}

class SoftKeyboard {
  SoftKeyboard._();
  static void close() =>
      SystemChannels.textInput.invokeMethod('TextInput.hide');
  static void open() => SystemChannels.textInput.invokeMethod('TextInput.show');
}
