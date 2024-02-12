// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'characters_limit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$CharacterLimitState {
  String get value => throw _privateConstructorUsedError;
  bool get isEditing => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CharacterLimitStateCopyWith<CharacterLimitState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterLimitStateCopyWith<$Res> {
  factory $CharacterLimitStateCopyWith(
          CharacterLimitState value, $Res Function(CharacterLimitState) then) =
      _$CharacterLimitStateCopyWithImpl<$Res, CharacterLimitState>;
  @useResult
  $Res call({String value, bool isEditing});
}

/// @nodoc
class _$CharacterLimitStateCopyWithImpl<$Res, $Val extends CharacterLimitState>
    implements $CharacterLimitStateCopyWith<$Res> {
  _$CharacterLimitStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? isEditing = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      isEditing: null == isEditing
          ? _value.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CharacterLimitStateImplCopyWith<$Res>
    implements $CharacterLimitStateCopyWith<$Res> {
  factory _$$CharacterLimitStateImplCopyWith(_$CharacterLimitStateImpl value,
          $Res Function(_$CharacterLimitStateImpl) then) =
      __$$CharacterLimitStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, bool isEditing});
}

/// @nodoc
class __$$CharacterLimitStateImplCopyWithImpl<$Res>
    extends _$CharacterLimitStateCopyWithImpl<$Res, _$CharacterLimitStateImpl>
    implements _$$CharacterLimitStateImplCopyWith<$Res> {
  __$$CharacterLimitStateImplCopyWithImpl(_$CharacterLimitStateImpl _value,
      $Res Function(_$CharacterLimitStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? isEditing = null,
  }) {
    return _then(_$CharacterLimitStateImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      isEditing: null == isEditing
          ? _value.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CharacterLimitStateImpl implements _CharacterLimitState {
  const _$CharacterLimitStateImpl({this.value = '', this.isEditing = false});

  @override
  @JsonKey()
  final String value;
  @override
  @JsonKey()
  final bool isEditing;

  @override
  String toString() {
    return 'CharacterLimitState(value: $value, isEditing: $isEditing)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterLimitStateImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.isEditing, isEditing) ||
                other.isEditing == isEditing));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value, isEditing);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterLimitStateImplCopyWith<_$CharacterLimitStateImpl> get copyWith =>
      __$$CharacterLimitStateImplCopyWithImpl<_$CharacterLimitStateImpl>(
          this, _$identity);
}

abstract class _CharacterLimitState implements CharacterLimitState {
  const factory _CharacterLimitState(
      {final String value, final bool isEditing}) = _$CharacterLimitStateImpl;

  @override
  String get value;
  @override
  bool get isEditing;
  @override
  @JsonKey(ignore: true)
  _$$CharacterLimitStateImplCopyWith<_$CharacterLimitStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
