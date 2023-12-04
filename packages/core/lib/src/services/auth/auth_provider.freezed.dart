// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$ProviderResponseModel {
  String get token => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProviderResponseModelCopyWith<ProviderResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderResponseModelCopyWith<$Res> {
  factory $ProviderResponseModelCopyWith(ProviderResponseModel value,
          $Res Function(ProviderResponseModel) then) =
      _$ProviderResponseModelCopyWithImpl<$Res, ProviderResponseModel>;
  @useResult
  $Res call({String token});
}

/// @nodoc
class _$ProviderResponseModelCopyWithImpl<$Res,
        $Val extends ProviderResponseModel>
    implements $ProviderResponseModelCopyWith<$Res> {
  _$ProviderResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProviderResponseModelImplCopyWith<$Res>
    implements $ProviderResponseModelCopyWith<$Res> {
  factory _$$ProviderResponseModelImplCopyWith(
          _$ProviderResponseModelImpl value,
          $Res Function(_$ProviderResponseModelImpl) then) =
      __$$ProviderResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token});
}

/// @nodoc
class __$$ProviderResponseModelImplCopyWithImpl<$Res>
    extends _$ProviderResponseModelCopyWithImpl<$Res,
        _$ProviderResponseModelImpl>
    implements _$$ProviderResponseModelImplCopyWith<$Res> {
  __$$ProviderResponseModelImplCopyWithImpl(_$ProviderResponseModelImpl _value,
      $Res Function(_$ProviderResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_$ProviderResponseModelImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ProviderResponseModelImpl implements _ProviderResponseModel {
  const _$ProviderResponseModelImpl({required this.token});

  @override
  final String token;

  @override
  String toString() {
    return 'ProviderResponseModel(token: $token)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderResponseModelImpl &&
            (identical(other.token, token) || other.token == token));
  }

  @override
  int get hashCode => Object.hash(runtimeType, token);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderResponseModelImplCopyWith<_$ProviderResponseModelImpl>
      get copyWith => __$$ProviderResponseModelImplCopyWithImpl<
          _$ProviderResponseModelImpl>(this, _$identity);
}

abstract class _ProviderResponseModel implements ProviderResponseModel {
  const factory _ProviderResponseModel({required final String token}) =
      _$ProviderResponseModelImpl;

  @override
  String get token;
  @override
  @JsonKey(ignore: true)
  _$$ProviderResponseModelImplCopyWith<_$ProviderResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
