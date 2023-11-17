// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_state_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GlobalStateNotifierState {
  RequestProjectsDto get requestProjectsDto =>
      throw _privateConstructorUsedError;
  UserModel get user => throw _privateConstructorUsedError;
  AppStateLoadingStatuses get appLoadingStatus =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GlobalStateNotifierStateCopyWith<GlobalStateNotifierState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalStateNotifierStateCopyWith<$Res> {
  factory $GlobalStateNotifierStateCopyWith(GlobalStateNotifierState value,
          $Res Function(GlobalStateNotifierState) then) =
      _$GlobalStateNotifierStateCopyWithImpl<$Res, GlobalStateNotifierState>;
  @useResult
  $Res call(
      {RequestProjectsDto requestProjectsDto,
      UserModel user,
      AppStateLoadingStatuses appLoadingStatus});

  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class _$GlobalStateNotifierStateCopyWithImpl<$Res,
        $Val extends GlobalStateNotifierState>
    implements $GlobalStateNotifierStateCopyWith<$Res> {
  _$GlobalStateNotifierStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestProjectsDto = null,
    Object? user = null,
    Object? appLoadingStatus = null,
  }) {
    return _then(_value.copyWith(
      requestProjectsDto: null == requestProjectsDto
          ? _value.requestProjectsDto
          : requestProjectsDto // ignore: cast_nullable_to_non_nullable
              as RequestProjectsDto,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      appLoadingStatus: null == appLoadingStatus
          ? _value.appLoadingStatus
          : appLoadingStatus // ignore: cast_nullable_to_non_nullable
              as AppStateLoadingStatuses,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto {
    return $RequestProjectsDtoCopyWith<$Res>(_value.requestProjectsDto,
        (value) {
      return _then(_value.copyWith(requestProjectsDto: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GlobalStateNotifierStateImplCopyWith<$Res>
    implements $GlobalStateNotifierStateCopyWith<$Res> {
  factory _$$GlobalStateNotifierStateImplCopyWith(
          _$GlobalStateNotifierStateImpl value,
          $Res Function(_$GlobalStateNotifierStateImpl) then) =
      __$$GlobalStateNotifierStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RequestProjectsDto requestProjectsDto,
      UserModel user,
      AppStateLoadingStatuses appLoadingStatus});

  @override
  $RequestProjectsDtoCopyWith<$Res> get requestProjectsDto;
  @override
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class __$$GlobalStateNotifierStateImplCopyWithImpl<$Res>
    extends _$GlobalStateNotifierStateCopyWithImpl<$Res,
        _$GlobalStateNotifierStateImpl>
    implements _$$GlobalStateNotifierStateImplCopyWith<$Res> {
  __$$GlobalStateNotifierStateImplCopyWithImpl(
      _$GlobalStateNotifierStateImpl _value,
      $Res Function(_$GlobalStateNotifierStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestProjectsDto = null,
    Object? user = null,
    Object? appLoadingStatus = null,
  }) {
    return _then(_$GlobalStateNotifierStateImpl(
      requestProjectsDto: null == requestProjectsDto
          ? _value.requestProjectsDto
          : requestProjectsDto // ignore: cast_nullable_to_non_nullable
              as RequestProjectsDto,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      appLoadingStatus: null == appLoadingStatus
          ? _value.appLoadingStatus
          : appLoadingStatus // ignore: cast_nullable_to_non_nullable
              as AppStateLoadingStatuses,
    ));
  }
}

/// @nodoc

class _$GlobalStateNotifierStateImpl implements _GlobalStateNotifierState {
  const _$GlobalStateNotifierStateImpl(
      {this.requestProjectsDto = RequestProjectsDto.empty,
      this.user = UserModel.empty,
      this.appLoadingStatus = AppStateLoadingStatuses.settings});

  @override
  @JsonKey()
  final RequestProjectsDto requestProjectsDto;
  @override
  @JsonKey()
  final UserModel user;
  @override
  @JsonKey()
  final AppStateLoadingStatuses appLoadingStatus;

  @override
  String toString() {
    return 'GlobalStateNotifierState(requestProjectsDto: $requestProjectsDto, user: $user, appLoadingStatus: $appLoadingStatus)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalStateNotifierStateImpl &&
            (identical(other.requestProjectsDto, requestProjectsDto) ||
                other.requestProjectsDto == requestProjectsDto) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.appLoadingStatus, appLoadingStatus) ||
                other.appLoadingStatus == appLoadingStatus));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, requestProjectsDto, user, appLoadingStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalStateNotifierStateImplCopyWith<_$GlobalStateNotifierStateImpl>
      get copyWith => __$$GlobalStateNotifierStateImplCopyWithImpl<
          _$GlobalStateNotifierStateImpl>(this, _$identity);
}

abstract class _GlobalStateNotifierState implements GlobalStateNotifierState {
  const factory _GlobalStateNotifierState(
          {final RequestProjectsDto requestProjectsDto,
          final UserModel user,
          final AppStateLoadingStatuses appLoadingStatus}) =
      _$GlobalStateNotifierStateImpl;

  @override
  RequestProjectsDto get requestProjectsDto;
  @override
  UserModel get user;
  @override
  AppStateLoadingStatuses get appLoadingStatus;
  @override
  @JsonKey(ignore: true)
  _$$GlobalStateNotifierStateImplCopyWith<_$GlobalStateNotifierStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
