import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void closeKeyboard({required final BuildContext context}) {
  final FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.focusedChild?.unfocus();
  }
}

class SoftKeyboard {
  SoftKeyboard._();
  static Future<void> close() async =>
      SystemChannels.textInput.invokeMethod('TextInput.hide');
  static Future<void> open() async =>
      SystemChannels.textInput.invokeMethod('TextInput.show');
}
