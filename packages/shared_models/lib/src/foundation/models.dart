part of 'foundation.dart';

/// Use this object to mark some state
/// as loadable and get clean and visible
/// way to declare loading state without null checks.
@freezed
class LoadableContainer<T> with _$LoadableContainer<T> {
  const factory LoadableContainer({
    required final T value,
    @Default(false) final bool isLoaded,
  }) = _LoadableContainer<T>;
  factory LoadableContainer.loaded(final T value) =>
      LoadableContainer<T>(value: value, isLoaded: true);
  const LoadableContainer._();
  bool get isLoading => !isLoaded;
}

/// Use this object to mark some state
/// as loadable and get clean and visible
/// way to declare loading state without null checks.
@freezed
class FieldContainer<T> with _$FieldContainer<T> {
  const factory FieldContainer({
    required final T value,
    @Default('') final String errorText,
    @Default(false) final bool isLoading,
  }) = _FieldContainer<T>;
}
