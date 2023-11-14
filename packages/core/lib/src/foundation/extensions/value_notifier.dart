import 'package:flutter/foundation.dart';

extension ValueNotifierExtension<T> on ValueNotifier<T> {
  // ignore: use_setters_to_change_properties
  void setValue(final T state) {
    value = state;
  }
}
