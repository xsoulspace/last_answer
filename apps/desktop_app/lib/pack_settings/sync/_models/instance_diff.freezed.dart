// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instance_diff.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$InstanceDiff<T extends HasId, TOther extends HasId> {
  T get original => throw _privateConstructorUsedError;
  TOther get other => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InstanceDiffCopyWith<T, TOther, InstanceDiff<T, TOther>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstanceDiffCopyWith<T extends HasId, TOther extends HasId,
    $Res> {
  factory $InstanceDiffCopyWith(InstanceDiff<T, TOther> value,
          $Res Function(InstanceDiff<T, TOther>) then) =
      _$InstanceDiffCopyWithImpl<T, TOther, $Res, InstanceDiff<T, TOther>>;
  @useResult
  $Res call({T original, TOther other});
}

/// @nodoc
class _$InstanceDiffCopyWithImpl<T extends HasId, TOther extends HasId, $Res,
        $Val extends InstanceDiff<T, TOther>>
    implements $InstanceDiffCopyWith<T, TOther, $Res> {
  _$InstanceDiffCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? original = null,
    Object? other = null,
  }) {
    return _then(_value.copyWith(
      original: null == original
          ? _value.original
          : original // ignore: cast_nullable_to_non_nullable
              as T,
      other: null == other
          ? _value.other
          : other // ignore: cast_nullable_to_non_nullable
              as TOther,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InstanceDiffCopyWith<T extends HasId, TOther extends HasId,
    $Res> implements $InstanceDiffCopyWith<T, TOther, $Res> {
  factory _$$_InstanceDiffCopyWith(_$_InstanceDiff<T, TOther> value,
          $Res Function(_$_InstanceDiff<T, TOther>) then) =
      __$$_InstanceDiffCopyWithImpl<T, TOther, $Res>;
  @override
  @useResult
  $Res call({T original, TOther other});
}

/// @nodoc
class __$$_InstanceDiffCopyWithImpl<T extends HasId, TOther extends HasId, $Res>
    extends _$InstanceDiffCopyWithImpl<T, TOther, $Res,
        _$_InstanceDiff<T, TOther>>
    implements _$$_InstanceDiffCopyWith<T, TOther, $Res> {
  __$$_InstanceDiffCopyWithImpl(_$_InstanceDiff<T, TOther> _value,
      $Res Function(_$_InstanceDiff<T, TOther>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? original = null,
    Object? other = null,
  }) {
    return _then(_$_InstanceDiff<T, TOther>(
      original: null == original
          ? _value.original
          : original // ignore: cast_nullable_to_non_nullable
              as T,
      other: null == other
          ? _value.other
          : other // ignore: cast_nullable_to_non_nullable
              as TOther,
    ));
  }
}

/// @nodoc

class _$_InstanceDiff<T extends HasId, TOther extends HasId>
    extends _InstanceDiff<T, TOther> {
  const _$_InstanceDiff({required this.original, required this.other})
      : super._();

  @override
  final T original;
  @override
  final TOther other;

  @override
  String toString() {
    return 'InstanceDiff<$T, $TOther>(original: $original, other: $other)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InstanceDiff<T, TOther> &&
            const DeepCollectionEquality().equals(other.original, original) &&
            const DeepCollectionEquality().equals(other.other, this.other));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(original),
      const DeepCollectionEquality().hash(other));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InstanceDiffCopyWith<T, TOther, _$_InstanceDiff<T, TOther>>
      get copyWith =>
          __$$_InstanceDiffCopyWithImpl<T, TOther, _$_InstanceDiff<T, TOther>>(
              this, _$identity);
}

abstract class _InstanceDiff<T extends HasId, TOther extends HasId>
    extends InstanceDiff<T, TOther> {
  const factory _InstanceDiff(
      {required final T original,
      required final TOther other}) = _$_InstanceDiff<T, TOther>;
  const _InstanceDiff._() : super._();

  @override
  T get original;
  @override
  TOther get other;
  @override
  @JsonKey(ignore: true)
  _$$_InstanceDiffCopyWith<T, TOther, _$_InstanceDiff<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UpdatableInstanceDiff<T extends HasId, TOther extends HasId> {
  T get original => throw _privateConstructorUsedError;
  TOther get other => throw _privateConstructorUsedError;
  bool get originalWasUpdated => throw _privateConstructorUsedError;
  bool get otherWasUpdated => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UpdatableInstanceDiffCopyWith<T, TOther, UpdatableInstanceDiff<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdatableInstanceDiffCopyWith<T extends HasId,
    TOther extends HasId, $Res> {
  factory $UpdatableInstanceDiffCopyWith(UpdatableInstanceDiff<T, TOther> value,
          $Res Function(UpdatableInstanceDiff<T, TOther>) then) =
      _$UpdatableInstanceDiffCopyWithImpl<T, TOther, $Res,
          UpdatableInstanceDiff<T, TOther>>;
  @useResult
  $Res call(
      {T original,
      TOther other,
      bool originalWasUpdated,
      bool otherWasUpdated});
}

/// @nodoc
class _$UpdatableInstanceDiffCopyWithImpl<T extends HasId, TOther extends HasId,
        $Res, $Val extends UpdatableInstanceDiff<T, TOther>>
    implements $UpdatableInstanceDiffCopyWith<T, TOther, $Res> {
  _$UpdatableInstanceDiffCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? original = null,
    Object? other = null,
    Object? originalWasUpdated = null,
    Object? otherWasUpdated = null,
  }) {
    return _then(_value.copyWith(
      original: null == original
          ? _value.original
          : original // ignore: cast_nullable_to_non_nullable
              as T,
      other: null == other
          ? _value.other
          : other // ignore: cast_nullable_to_non_nullable
              as TOther,
      originalWasUpdated: null == originalWasUpdated
          ? _value.originalWasUpdated
          : originalWasUpdated // ignore: cast_nullable_to_non_nullable
              as bool,
      otherWasUpdated: null == otherWasUpdated
          ? _value.otherWasUpdated
          : otherWasUpdated // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UpdatableInstanceDiffCopyWith<
    T extends HasId,
    TOther extends HasId,
    $Res> implements $UpdatableInstanceDiffCopyWith<T, TOther, $Res> {
  factory _$$_UpdatableInstanceDiffCopyWith(
          _$_UpdatableInstanceDiff<T, TOther> value,
          $Res Function(_$_UpdatableInstanceDiff<T, TOther>) then) =
      __$$_UpdatableInstanceDiffCopyWithImpl<T, TOther, $Res>;
  @override
  @useResult
  $Res call(
      {T original,
      TOther other,
      bool originalWasUpdated,
      bool otherWasUpdated});
}

/// @nodoc
class __$$_UpdatableInstanceDiffCopyWithImpl<T extends HasId,
        TOther extends HasId, $Res>
    extends _$UpdatableInstanceDiffCopyWithImpl<T, TOther, $Res,
        _$_UpdatableInstanceDiff<T, TOther>>
    implements _$$_UpdatableInstanceDiffCopyWith<T, TOther, $Res> {
  __$$_UpdatableInstanceDiffCopyWithImpl(
      _$_UpdatableInstanceDiff<T, TOther> _value,
      $Res Function(_$_UpdatableInstanceDiff<T, TOther>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? original = null,
    Object? other = null,
    Object? originalWasUpdated = null,
    Object? otherWasUpdated = null,
  }) {
    return _then(_$_UpdatableInstanceDiff<T, TOther>(
      original: null == original
          ? _value.original
          : original // ignore: cast_nullable_to_non_nullable
              as T,
      other: null == other
          ? _value.other
          : other // ignore: cast_nullable_to_non_nullable
              as TOther,
      originalWasUpdated: null == originalWasUpdated
          ? _value.originalWasUpdated
          : originalWasUpdated // ignore: cast_nullable_to_non_nullable
              as bool,
      otherWasUpdated: null == otherWasUpdated
          ? _value.otherWasUpdated
          : otherWasUpdated // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_UpdatableInstanceDiff<T extends HasId, TOther extends HasId>
    implements _UpdatableInstanceDiff<T, TOther> {
  const _$_UpdatableInstanceDiff(
      {required this.original,
      required this.other,
      required this.originalWasUpdated,
      required this.otherWasUpdated});

  @override
  final T original;
  @override
  final TOther other;
  @override
  final bool originalWasUpdated;
  @override
  final bool otherWasUpdated;

  @override
  String toString() {
    return 'UpdatableInstanceDiff<$T, $TOther>(original: $original, other: $other, originalWasUpdated: $originalWasUpdated, otherWasUpdated: $otherWasUpdated)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UpdatableInstanceDiff<T, TOther> &&
            const DeepCollectionEquality().equals(other.original, original) &&
            const DeepCollectionEquality().equals(other.other, this.other) &&
            (identical(other.originalWasUpdated, originalWasUpdated) ||
                other.originalWasUpdated == originalWasUpdated) &&
            (identical(other.otherWasUpdated, otherWasUpdated) ||
                other.otherWasUpdated == otherWasUpdated));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(original),
      const DeepCollectionEquality().hash(other),
      originalWasUpdated,
      otherWasUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UpdatableInstanceDiffCopyWith<T, TOther,
          _$_UpdatableInstanceDiff<T, TOther>>
      get copyWith => __$$_UpdatableInstanceDiffCopyWithImpl<T, TOther,
          _$_UpdatableInstanceDiff<T, TOther>>(this, _$identity);
}

abstract class _UpdatableInstanceDiff<T extends HasId, TOther extends HasId>
    implements UpdatableInstanceDiff<T, TOther> {
  const factory _UpdatableInstanceDiff(
          {required final T original,
          required final TOther other,
          required final bool originalWasUpdated,
          required final bool otherWasUpdated}) =
      _$_UpdatableInstanceDiff<T, TOther>;

  @override
  T get original;
  @override
  TOther get other;
  @override
  bool get originalWasUpdated;
  @override
  bool get otherWasUpdated;
  @override
  @JsonKey(ignore: true)
  _$$_UpdatableInstanceDiffCopyWith<T, TOther,
          _$_UpdatableInstanceDiff<T, TOther>>
      get copyWith => throw _privateConstructorUsedError;
}
