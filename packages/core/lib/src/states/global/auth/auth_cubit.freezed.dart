// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AuthCubitState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unauthorized,
    required TResult Function() authorized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unauthorized,
    TResult? Function()? authorized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unauthorized,
    TResult Function()? authorized,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthCubitStateUnathorized value) unauthorized,
    required TResult Function(AuthCubitStateAuthorized value) authorized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthCubitStateUnathorized value)? unauthorized,
    TResult? Function(AuthCubitStateAuthorized value)? authorized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthCubitStateUnathorized value)? unauthorized,
    TResult Function(AuthCubitStateAuthorized value)? authorized,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthCubitStateCopyWith<$Res> {
  factory $AuthCubitStateCopyWith(
          AuthCubitState value, $Res Function(AuthCubitState) then) =
      _$AuthCubitStateCopyWithImpl<$Res, AuthCubitState>;
}

/// @nodoc
class _$AuthCubitStateCopyWithImpl<$Res, $Val extends AuthCubitState>
    implements $AuthCubitStateCopyWith<$Res> {
  _$AuthCubitStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AuthCubitStateUnathorizedCopyWith<$Res> {
  factory _$$AuthCubitStateUnathorizedCopyWith(
          _$AuthCubitStateUnathorized value,
          $Res Function(_$AuthCubitStateUnathorized) then) =
      __$$AuthCubitStateUnathorizedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthCubitStateUnathorizedCopyWithImpl<$Res>
    extends _$AuthCubitStateCopyWithImpl<$Res, _$AuthCubitStateUnathorized>
    implements _$$AuthCubitStateUnathorizedCopyWith<$Res> {
  __$$AuthCubitStateUnathorizedCopyWithImpl(_$AuthCubitStateUnathorized _value,
      $Res Function(_$AuthCubitStateUnathorized) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AuthCubitStateUnathorized implements AuthCubitStateUnathorized {
  const _$AuthCubitStateUnathorized();

  @override
  String toString() {
    return 'AuthCubitState.unauthorized()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthCubitStateUnathorized);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unauthorized,
    required TResult Function() authorized,
  }) {
    return unauthorized();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unauthorized,
    TResult? Function()? authorized,
  }) {
    return unauthorized?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unauthorized,
    TResult Function()? authorized,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthCubitStateUnathorized value) unauthorized,
    required TResult Function(AuthCubitStateAuthorized value) authorized,
  }) {
    return unauthorized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthCubitStateUnathorized value)? unauthorized,
    TResult? Function(AuthCubitStateAuthorized value)? authorized,
  }) {
    return unauthorized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthCubitStateUnathorized value)? unauthorized,
    TResult Function(AuthCubitStateAuthorized value)? authorized,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(this);
    }
    return orElse();
  }
}

abstract class AuthCubitStateUnathorized implements AuthCubitState {
  const factory AuthCubitStateUnathorized() = _$AuthCubitStateUnathorized;
}

/// @nodoc
abstract class _$$AuthCubitStateAuthorizedCopyWith<$Res> {
  factory _$$AuthCubitStateAuthorizedCopyWith(_$AuthCubitStateAuthorized value,
          $Res Function(_$AuthCubitStateAuthorized) then) =
      __$$AuthCubitStateAuthorizedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthCubitStateAuthorizedCopyWithImpl<$Res>
    extends _$AuthCubitStateCopyWithImpl<$Res, _$AuthCubitStateAuthorized>
    implements _$$AuthCubitStateAuthorizedCopyWith<$Res> {
  __$$AuthCubitStateAuthorizedCopyWithImpl(_$AuthCubitStateAuthorized _value,
      $Res Function(_$AuthCubitStateAuthorized) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AuthCubitStateAuthorized implements AuthCubitStateAuthorized {
  const _$AuthCubitStateAuthorized();

  @override
  String toString() {
    return 'AuthCubitState.authorized()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthCubitStateAuthorized);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unauthorized,
    required TResult Function() authorized,
  }) {
    return authorized();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unauthorized,
    TResult? Function()? authorized,
  }) {
    return authorized?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unauthorized,
    TResult Function()? authorized,
    required TResult orElse(),
  }) {
    if (authorized != null) {
      return authorized();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthCubitStateUnathorized value) unauthorized,
    required TResult Function(AuthCubitStateAuthorized value) authorized,
  }) {
    return authorized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthCubitStateUnathorized value)? unauthorized,
    TResult? Function(AuthCubitStateAuthorized value)? authorized,
  }) {
    return authorized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthCubitStateUnathorized value)? unauthorized,
    TResult Function(AuthCubitStateAuthorized value)? authorized,
    required TResult orElse(),
  }) {
    if (authorized != null) {
      return authorized(this);
    }
    return orElse();
  }
}

abstract class AuthCubitStateAuthorized implements AuthCubitState {
  const factory AuthCubitStateAuthorized() = _$AuthCubitStateAuthorized;
}
