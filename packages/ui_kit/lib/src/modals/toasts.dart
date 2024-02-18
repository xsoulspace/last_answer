import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Toasts {
  Toasts.of(this.context) : _messanger = ScaffoldMessenger.of(context);
  final ScaffoldMessengerState _messanger;
  final BuildContext context;
  Future<void> showBottomToast({
    required final String message,
  }) async {
    final controller = _messanger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: 2.seconds,
      ),
    );
  }
}
