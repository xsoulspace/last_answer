import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core.dart';

void closeKeyboard({required final BuildContext context}) {
  final FocusScopeNode currentFocus = FocusScope.of(context);
  if (currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
  unawaited(SoftKeyboard.close());
}

class SoftKeyboard {
  SoftKeyboard._();
  static Future<void> close() async {
    if (!PlatformInfo.isNativeMobile) return;
    try {
      return SystemChannels.textInput.invokeMethod('TextInput.hide');
      // ignore: empty_catches
    } on PlatformException {}
  }

  static Future<void> open() async {
    if (!PlatformInfo.isNativeMobile) return;
    try {
      return SystemChannels.textInput.invokeMethod('TextInput.show');
      // ignore: empty_catches
    } on PlatformException {}
  }
}
