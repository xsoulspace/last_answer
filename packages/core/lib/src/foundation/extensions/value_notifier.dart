import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

extension ValueNotifierExtension<T> on ValueNotifier<T> {
  // ignore: use_setters_to_change_properties
  void setValue(final T state) {
    value = state;
  }
}

class LoadableStateNotifier<T> extends ValueNotifier<LoadableContainer<T>> {
  LoadableStateNotifier(final T value) : super(LoadableContainer(value: value));
  bool get isLoading => value.isLoading;
  T get state => value.value;
  set state(final T v) => setState(v);
  // ignore: avoid_positional_boolean_parameters
  void setIsLoading(final bool isLoading) =>
      value = value.copyWith(isLoaded: !isLoading);
  void setState(final T state) =>
      value = value.copyWith(isLoaded: true, value: state);
}
