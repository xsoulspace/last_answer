// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'special_emoji_keyboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SpecialEmojisKeyboardControllerState {
  bool get isKeyboardOpen => throw _privateConstructorUsedError;
  bool get isKeyboardOpening => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SpecialEmojisKeyboardControllerStateCopyWith<
          SpecialEmojisKeyboardControllerState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpecialEmojisKeyboardControllerStateCopyWith<$Res> {
  factory $SpecialEmojisKeyboardControllerStateCopyWith(
          SpecialEmojisKeyboardControllerState value,
          $Res Function(SpecialEmojisKeyboardControllerState) then) =
      _$SpecialEmojisKeyboardControllerStateCopyWithImpl<$Res,
          SpecialEmojisKeyboardControllerState>;
  @useResult
  $Res call({bool isKeyboardOpen, bool isKeyboardOpening});
}

/// @nodoc
class _$SpecialEmojisKeyboardControllerStateCopyWithImpl<$Res,
        $Val extends SpecialEmojisKeyboardControllerState>
    implements $SpecialEmojisKeyboardControllerStateCopyWith<$Res> {
  _$SpecialEmojisKeyboardControllerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isKeyboardOpen = null,
    Object? isKeyboardOpening = null,
  }) {
    return _then(_value.copyWith(
      isKeyboardOpen: null == isKeyboardOpen
          ? _value.isKeyboardOpen
          : isKeyboardOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      isKeyboardOpening: null == isKeyboardOpening
          ? _value.isKeyboardOpening
          : isKeyboardOpening // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpecialEmojisKeyboardControllerStateImplCopyWith<$Res>
    implements $SpecialEmojisKeyboardControllerStateCopyWith<$Res> {
  factory _$$SpecialEmojisKeyboardControllerStateImplCopyWith(
          _$SpecialEmojisKeyboardControllerStateImpl value,
          $Res Function(_$SpecialEmojisKeyboardControllerStateImpl) then) =
      __$$SpecialEmojisKeyboardControllerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isKeyboardOpen, bool isKeyboardOpening});
}

/// @nodoc
class __$$SpecialEmojisKeyboardControllerStateImplCopyWithImpl<$Res>
    extends _$SpecialEmojisKeyboardControllerStateCopyWithImpl<$Res,
        _$SpecialEmojisKeyboardControllerStateImpl>
    implements _$$SpecialEmojisKeyboardControllerStateImplCopyWith<$Res> {
  __$$SpecialEmojisKeyboardControllerStateImplCopyWithImpl(
      _$SpecialEmojisKeyboardControllerStateImpl _value,
      $Res Function(_$SpecialEmojisKeyboardControllerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isKeyboardOpen = null,
    Object? isKeyboardOpening = null,
  }) {
    return _then(_$SpecialEmojisKeyboardControllerStateImpl(
      isKeyboardOpen: null == isKeyboardOpen
          ? _value.isKeyboardOpen
          : isKeyboardOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      isKeyboardOpening: null == isKeyboardOpening
          ? _value.isKeyboardOpening
          : isKeyboardOpening // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SpecialEmojisKeyboardControllerStateImpl
    with DiagnosticableTreeMixin
    implements _SpecialEmojisKeyboardControllerState {
  const _$SpecialEmojisKeyboardControllerStateImpl(
      {this.isKeyboardOpen = false, this.isKeyboardOpening = false});

  @override
  @JsonKey()
  final bool isKeyboardOpen;
  @override
  @JsonKey()
  final bool isKeyboardOpening;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SpecialEmojisKeyboardControllerState(isKeyboardOpen: $isKeyboardOpen, isKeyboardOpening: $isKeyboardOpening)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SpecialEmojisKeyboardControllerState'))
      ..add(DiagnosticsProperty('isKeyboardOpen', isKeyboardOpen))
      ..add(DiagnosticsProperty('isKeyboardOpening', isKeyboardOpening));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpecialEmojisKeyboardControllerStateImpl &&
            (identical(other.isKeyboardOpen, isKeyboardOpen) ||
                other.isKeyboardOpen == isKeyboardOpen) &&
            (identical(other.isKeyboardOpening, isKeyboardOpening) ||
                other.isKeyboardOpening == isKeyboardOpening));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isKeyboardOpen, isKeyboardOpening);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpecialEmojisKeyboardControllerStateImplCopyWith<
          _$SpecialEmojisKeyboardControllerStateImpl>
      get copyWith => __$$SpecialEmojisKeyboardControllerStateImplCopyWithImpl<
          _$SpecialEmojisKeyboardControllerStateImpl>(this, _$identity);
}

abstract class _SpecialEmojisKeyboardControllerState
    implements SpecialEmojisKeyboardControllerState {
  const factory _SpecialEmojisKeyboardControllerState(
          {final bool isKeyboardOpen, final bool isKeyboardOpening}) =
      _$SpecialEmojisKeyboardControllerStateImpl;

  @override
  bool get isKeyboardOpen;
  @override
  bool get isKeyboardOpening;
  @override
  @JsonKey(ignore: true)
  _$$SpecialEmojisKeyboardControllerStateImplCopyWith<
          _$SpecialEmojisKeyboardControllerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
