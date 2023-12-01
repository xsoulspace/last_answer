// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'foundation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$LoadableContainer<T> {
  T get value => throw _privateConstructorUsedError;
  bool get isLoaded => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoadableContainerCopyWith<T, LoadableContainer<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoadableContainerCopyWith<T, $Res> {
  factory $LoadableContainerCopyWith(LoadableContainer<T> value,
          $Res Function(LoadableContainer<T>) then) =
      _$LoadableContainerCopyWithImpl<T, $Res, LoadableContainer<T>>;
  @useResult
  $Res call({T value, bool isLoaded});
}

/// @nodoc
class _$LoadableContainerCopyWithImpl<T, $Res,
        $Val extends LoadableContainer<T>>
    implements $LoadableContainerCopyWith<T, $Res> {
  _$LoadableContainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
    Object? isLoaded = null,
  }) {
    return _then(_value.copyWith(
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
      isLoaded: null == isLoaded
          ? _value.isLoaded
          : isLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoadableContainerImplCopyWith<T, $Res>
    implements $LoadableContainerCopyWith<T, $Res> {
  factory _$$LoadableContainerImplCopyWith(_$LoadableContainerImpl<T> value,
          $Res Function(_$LoadableContainerImpl<T>) then) =
      __$$LoadableContainerImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T value, bool isLoaded});
}

/// @nodoc
class __$$LoadableContainerImplCopyWithImpl<T, $Res>
    extends _$LoadableContainerCopyWithImpl<T, $Res, _$LoadableContainerImpl<T>>
    implements _$$LoadableContainerImplCopyWith<T, $Res> {
  __$$LoadableContainerImplCopyWithImpl(_$LoadableContainerImpl<T> _value,
      $Res Function(_$LoadableContainerImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
    Object? isLoaded = null,
  }) {
    return _then(_$LoadableContainerImpl<T>(
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
      isLoaded: null == isLoaded
          ? _value.isLoaded
          : isLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$LoadableContainerImpl<T> extends _LoadableContainer<T> {
  const _$LoadableContainerImpl({required this.value, this.isLoaded = false})
      : super._();

  @override
  final T value;
  @override
  @JsonKey()
  final bool isLoaded;

  @override
  String toString() {
    return 'LoadableContainer<$T>(value: $value, isLoaded: $isLoaded)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadableContainerImpl<T> &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.isLoaded, isLoaded) ||
                other.isLoaded == isLoaded));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(value), isLoaded);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadableContainerImplCopyWith<T, _$LoadableContainerImpl<T>>
      get copyWith =>
          __$$LoadableContainerImplCopyWithImpl<T, _$LoadableContainerImpl<T>>(
              this, _$identity);
}

abstract class _LoadableContainer<T> extends LoadableContainer<T> {
  const factory _LoadableContainer(
      {required final T value,
      final bool isLoaded}) = _$LoadableContainerImpl<T>;
  const _LoadableContainer._() : super._();

  @override
  T get value;
  @override
  bool get isLoaded;
  @override
  @JsonKey(ignore: true)
  _$$LoadableContainerImplCopyWith<T, _$LoadableContainerImpl<T>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FieldContainer<T> {
  T get value => throw _privateConstructorUsedError;
  String get errorText => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FieldContainerCopyWith<T, FieldContainer<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldContainerCopyWith<T, $Res> {
  factory $FieldContainerCopyWith(
          FieldContainer<T> value, $Res Function(FieldContainer<T>) then) =
      _$FieldContainerCopyWithImpl<T, $Res, FieldContainer<T>>;
  @useResult
  $Res call({T value, String errorText, bool isLoading});
}

/// @nodoc
class _$FieldContainerCopyWithImpl<T, $Res, $Val extends FieldContainer<T>>
    implements $FieldContainerCopyWith<T, $Res> {
  _$FieldContainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
    Object? errorText = null,
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
      errorText: null == errorText
          ? _value.errorText
          : errorText // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FieldContainerImplCopyWith<T, $Res>
    implements $FieldContainerCopyWith<T, $Res> {
  factory _$$FieldContainerImplCopyWith(_$FieldContainerImpl<T> value,
          $Res Function(_$FieldContainerImpl<T>) then) =
      __$$FieldContainerImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T value, String errorText, bool isLoading});
}

/// @nodoc
class __$$FieldContainerImplCopyWithImpl<T, $Res>
    extends _$FieldContainerCopyWithImpl<T, $Res, _$FieldContainerImpl<T>>
    implements _$$FieldContainerImplCopyWith<T, $Res> {
  __$$FieldContainerImplCopyWithImpl(_$FieldContainerImpl<T> _value,
      $Res Function(_$FieldContainerImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
    Object? errorText = null,
    Object? isLoading = null,
  }) {
    return _then(_$FieldContainerImpl<T>(
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
      errorText: null == errorText
          ? _value.errorText
          : errorText // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$FieldContainerImpl<T> implements _FieldContainer<T> {
  const _$FieldContainerImpl(
      {required this.value, this.errorText = '', this.isLoading = false});

  @override
  final T value;
  @override
  @JsonKey()
  final String errorText;
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'FieldContainer<$T>(value: $value, errorText: $errorText, isLoading: $isLoading)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldContainerImpl<T> &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.errorText, errorText) ||
                other.errorText == errorText) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(value), errorText, isLoading);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldContainerImplCopyWith<T, _$FieldContainerImpl<T>> get copyWith =>
      __$$FieldContainerImplCopyWithImpl<T, _$FieldContainerImpl<T>>(
          this, _$identity);
}

abstract class _FieldContainer<T> implements FieldContainer<T> {
  const factory _FieldContainer(
      {required final T value,
      final String errorText,
      final bool isLoading}) = _$FieldContainerImpl<T>;

  @override
  T get value;
  @override
  String get errorText;
  @override
  bool get isLoading;
  @override
  @JsonKey(ignore: true)
  _$$FieldContainerImplCopyWith<T, _$FieldContainerImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
