// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AppNotifierState {
  AppStatus get status => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppNotifierStateCopyWith<AppNotifierState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppNotifierStateCopyWith<$Res> {
  factory $AppNotifierStateCopyWith(
          AppNotifierState value, $Res Function(AppNotifierState) then) =
      _$AppNotifierStateCopyWithImpl<$Res, AppNotifierState>;
  @useResult
  $Res call({AppStatus status});
}

/// @nodoc
class _$AppNotifierStateCopyWithImpl<$Res, $Val extends AppNotifierState>
    implements $AppNotifierStateCopyWith<$Res> {
  _$AppNotifierStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AppStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppNotifierStateImplCopyWith<$Res>
    implements $AppNotifierStateCopyWith<$Res> {
  factory _$$AppNotifierStateImplCopyWith(_$AppNotifierStateImpl value,
          $Res Function(_$AppNotifierStateImpl) then) =
      __$$AppNotifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AppStatus status});
}

/// @nodoc
class __$$AppNotifierStateImplCopyWithImpl<$Res>
    extends _$AppNotifierStateCopyWithImpl<$Res, _$AppNotifierStateImpl>
    implements _$$AppNotifierStateImplCopyWith<$Res> {
  __$$AppNotifierStateImplCopyWithImpl(_$AppNotifierStateImpl _value,
      $Res Function(_$AppNotifierStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_$AppNotifierStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AppStatus,
    ));
  }
}

/// @nodoc

class _$AppNotifierStateImpl implements _AppNotifierState {
  const _$AppNotifierStateImpl({this.status = AppStatus.loading});

  @override
  @JsonKey()
  final AppStatus status;

  @override
  String toString() {
    return 'AppNotifierState(status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppNotifierStateImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppNotifierStateImplCopyWith<_$AppNotifierStateImpl> get copyWith =>
      __$$AppNotifierStateImplCopyWithImpl<_$AppNotifierStateImpl>(
          this, _$identity);
}

abstract class _AppNotifierState implements AppNotifierState {
  const factory _AppNotifierState({final AppStatus status}) =
      _$AppNotifierStateImpl;

  @override
  AppStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$AppNotifierStateImplCopyWith<_$AppNotifierStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
